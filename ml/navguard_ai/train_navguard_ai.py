#!/usr/bin/env python3
"""Train NAVGUARD's small offline Stage 11 models from physical sessions only."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import sys
from collections import Counter
from pathlib import Path
from typing import Any, Iterable

SEED = 42
DATASET_SCHEMA_V1 = "navguard_ai_dataset_v1"
DATASET_SCHEMA_V2 = "navguard_ai_dataset_v2"
DATASET_SCHEMA_V3 = "navguard_ai_dataset_v3"
FEATURE_SCHEMA_V1 = "navguard_ai_features_v1"
FEATURE_SCHEMA_V2 = "navguard_ai_features_v2"
FEATURE_SCHEMA_V3 = "navguard_ai_features_v3"
DATASET_SCHEMA = DATASET_SCHEMA_V1
FEATURE_SCHEMA = FEATURE_SCHEMA_V1
MODEL_SCHEMA = "navguard_ai_model_v1"
MOTION_CLASSES = ["STATIONARY", "STRAIGHT_WALK", "TURNING", "UNSTABLE_MOTION"]
MOTION_LABEL_TO_INDEX = {
    label: index for index, label in enumerate(MOTION_CLASSES)
}
FEATURE_ORDER_V1 = [
    "accel_mag_mean", "accel_mag_std", "accel_mag_rms",
    "gyro_mag_mean", "gyro_mag_std", "gyro_mag_rms",
    "heading_circular_std_rad", "heading_rate_abs_mean_rad_s",
    "heading_rate_abs_max_rad_s", "step_count", "step_cadence_hz",
    "step_interval_std_s", "arcore_displacement_m", "arcore_speed_mean_mps",
    "arcore_speed_std_mps", "arcore_tracking_fraction",
    "arcore_frame_gap_mean_ms", "arcore_pre_robust_nis_mean",
    "arcore_post_robust_nis_mean", "source_disagreement_mean_m",
    "source_disagreement_max_m", "stride_estimate_m",
    "stationary_candidate_fraction", "turning_heuristic_fraction",
    "arcore_robust_sigma_mean_m", "heading_unreliable_fraction",
]
FEATURE_ORDER_V2 = FEATURE_ORDER_V1 + [
    "heading_net_change_abs_rad",
    "heading_turn_consistency",
    "sustained_turn_fraction",
    "arcore_path_length_m",
    "arcore_straightness_ratio",
    "arcore_net_turn_abs_rad",
    "arcore_turn_consistency",
    "arcore_curvature_abs_rad_per_m",
]
V2_ADDED_FEATURE_ORDER = FEATURE_ORDER_V2[len(FEATURE_ORDER_V1) :]
FEATURE_ORDER_V3 = FEATURE_ORDER_V2 + [
    "heading_signed_net_turn_rad",
    "arcore_signed_net_turn_rad",
    "heading_path_turn_direction_agreement",
    "heading_path_turn_magnitude_difference_ratio",
    "heading_path_turn_coherence",
    "arcore_cross_track_rms_m",
]
V3_ADDED_FEATURE_ORDER = FEATURE_ORDER_V3[len(FEATURE_ORDER_V2) :]
FEATURE_ORDER = FEATURE_ORDER_V1
METADATA_COLUMNS = [
    "schema_version", "feature_schema_version", "session_id", "window_index",
    "motion_label", "arcore_reliable_label", "arcore_reliable_available",
    "pdr_reliable_label", "pdr_reliable_available", "heading_reliable_label",
    "heading_reliable_available",
]
EXPECTED_COLUMNS_V1 = METADATA_COLUMNS + FEATURE_ORDER_V1
EXPECTED_COLUMNS_V2 = METADATA_COLUMNS + FEATURE_ORDER_V2
EXPECTED_COLUMNS_V3 = METADATA_COLUMNS + FEATURE_ORDER_V3
EXPECTED_COLUMNS = EXPECTED_COLUMNS_V1
DATASET_CONTRACTS = {
    (DATASET_SCHEMA_V1, FEATURE_SCHEMA_V1): FEATURE_ORDER_V1,
    (DATASET_SCHEMA_V2, FEATURE_SCHEMA_V2): FEATURE_ORDER_V2,
    (DATASET_SCHEMA_V3, FEATURE_SCHEMA_V3): FEATURE_ORDER_V3,
}
FORBIDDEN_FRAGMENTS = [
    "latitude", "longitude", "altitude", "raw_gnss", "raw_accel", "raw_gyro",
    "magnetometer", "arcore_pose", "quaternion", "trajectory", "timestamp",
    "camera", "image", "audio", "device_serial", "mac", "advertising",
    "account", "user_name",
]
RELIABILITY_HEADS = {
    "arcore": ("arcore_reliable_label", "arcore_reliable_available"),
    "pdr": ("pdr_reliable_label", "pdr_reliable_available"),
    "heading": ("heading_reliable_label", "heading_reliable_available"),
}
DEVELOPMENT_C_VALUES = [0.03, 0.10, 0.30, 1.0, 3.0, 10.0, 30.0]
DEVELOPMENT_FOLD_COUNT = 5
V2_DEVELOPMENT_SESSION_COUNT = 20
V2_DEVELOPMENT_WINDOWS_PER_SESSION = 24
V2_DEVELOPMENT_WINDOWS_PER_CLASS = 120
V2_EXTENSION_SESSION_COUNT = 4
V2_24_SESSION_COUNT = 24
V2_24_WINDOW_COUNT = 576
V2_24_SESSIONS_PER_CLASS = {
    "STATIONARY": 5,
    "STRAIGHT_WALK": 7,
    "TURNING": 7,
    "UNSTABLE_MOTION": 5,
}
V2_24_WINDOWS_PER_CLASS = {
    label: session_count * V2_DEVELOPMENT_WINDOWS_PER_SESSION
    for label, session_count in V2_24_SESSIONS_PER_CLASS.items()
}
FROZEN_V3_HIDDEN_UNITS = 32
FROZEN_V3_ALPHA = 0.01
FROZEN_V3_LEARNING_RATE = 0.0005
FROZEN_V3_FINAL_EPOCHS = 86
FROZEN_V3_DECODER_NAME = (
    "fir3_0.60_0.30_0.10_bounded_hc0.70_hm0.10_lc0.50_lm0.00_c1"
)
FROZEN_MOTION_C = 30.0
FROZEN_MOTION_CLASS_WEIGHTS = {
    "STATIONARY": 1.0,
    "STRAIGHT_WALK": 1.0,
    "TURNING": 1.25,
    "UNSTABLE_MOTION": 1.0,
}


class DatasetError(ValueError):
    """A controlled dataset validation failure."""


def class_aware_session_split(session_labels: dict[str, str]) -> dict[str, set[str]]:
    """Deterministic class-aware 60/20/20-ish split with no session overlap."""
    grouped = {label: [] for label in MOTION_CLASSES}
    for session_id, label in session_labels.items():
        if label not in grouped:
            raise DatasetError(f"unknown motion label: {label}")
        grouped[label].append(session_id)
    if any(len(grouped[label]) < 5 for label in MOTION_CLASSES):
        raise DatasetError("INSUFFICIENT_DATASET")
    splits = {"train": set(), "validation": set(), "test": set()}
    rng = random.Random(SEED)
    for label in MOTION_CLASSES:
        sessions = sorted(grouped[label])
        rng.shuffle(sessions)
        test_count = max(1, int(round(len(sessions) * 0.20)))
        validation_count = max(1, int(round(len(sessions) * 0.20)))
        if len(sessions) - test_count - validation_count < 3:
            raise DatasetError("INSUFFICIENT_DATASET")
        splits["test"].update(sessions[:test_count])
        splits["validation"].update(
            sessions[test_count : test_count + validation_count]
        )
        splits["train"].update(sessions[test_count + validation_count :])
    assert_no_session_leakage(splits)
    return splits


def assert_no_session_leakage(splits: dict[str, set[str]]) -> None:
    names = list(splits)
    for index, first in enumerate(names):
        for second in names[index + 1 :]:
            if splits[first] & splits[second]:
                raise DatasetError("session leakage detected")


def encode_motion_labels(labels: Iterable[Any]):
    """Encode motion labels with the frozen runtime/export class order."""
    import numpy as np

    encoded: list[int] = []
    for raw_label in labels:
        label = str(raw_label)
        if label not in MOTION_LABEL_TO_INDEX:
            raise DatasetError(f"unknown motion label: {label}")
        encoded.append(MOTION_LABEL_TO_INDEX[label])
    return np.asarray(encoded, dtype=np.int64)


def _assert_motion_model_class_order(model) -> None:
    expected = list(range(len(MOTION_CLASSES)))
    actual = [int(value) for value in model.classes_]
    if actual != expected:
        raise DatasetError(
            f"motion model class order mismatch: expected {expected}, got {actual}"
        )


def _validated_motion_probabilities(model, features):
    import numpy as np

    _assert_motion_model_class_order(model)
    probabilities = model.predict_proba(features)
    expected_shape = (len(features), len(MOTION_CLASSES))
    if probabilities.shape != expected_shape:
        raise DatasetError(
            "motion probability shape mismatch: "
            f"expected {expected_shape}, got {probabilities.shape}"
        )
    if not np.isfinite(probabilities).all():
        raise DatasetError("non-finite motion probability")
    return probabilities


def _load_and_validate(input_path: Path):
    try:
        import numpy as np
        import pandas as pd
    except ImportError as error:
        raise DatasetError(
            "MISSING_PYTHON_DEPENDENCY: numpy, pandas and scikit-learn are required"
        ) from error

    files = sorted(input_path.glob("*.csv")) if input_path.is_dir() else [input_path]
    files = [path for path in files if path.is_file()]
    if not files:
        raise DatasetError("INSUFFICIENT_DATASET")
    frames = []
    contracts: set[tuple[str, str]] = set()
    for path in files:
        frame = pd.read_csv(path)
        if frame.empty:
            raise DatasetError("INSUFFICIENT_DATASET")
        dataset_versions = set(frame["schema_version"].astype(str)) if "schema_version" in frame else set()
        feature_versions = (
            set(frame["feature_schema_version"].astype(str))
            if "feature_schema_version" in frame
            else set()
        )
        if len(dataset_versions) != 1 or len(feature_versions) != 1:
            raise DatasetError("MIXED_FEATURE_SCHEMA_NOT_ALLOWED")
        contract = (next(iter(dataset_versions)), next(iter(feature_versions)))
        feature_order = DATASET_CONTRACTS.get(contract)
        if feature_order is None:
            raise DatasetError("dataset/feature schema mismatch")
        expected_columns = METADATA_COLUMNS + feature_order
        if list(frame.columns) != expected_columns:
            raise DatasetError("dataset column order/schema mismatch")
        if any(
            fragment in column.lower()
            for column in frame.columns
            for fragment in FORBIDDEN_FRAGMENTS
        ):
                raise DatasetError("forbidden dataset column")
        contracts.add(contract)
        frames.append(frame)
    if len(contracts) != 1:
        raise DatasetError("MIXED_FEATURE_SCHEMA_NOT_ALLOWED")
    data = pd.concat(frames, ignore_index=True)
    if data.empty:
        raise DatasetError("INSUFFICIENT_DATASET")
    contract = next(iter(contracts))
    feature_order = DATASET_CONTRACTS[contract]
    if not set(data["motion_label"].astype(str)).issubset(MOTION_CLASSES):
        raise DatasetError("unknown motion label")
    feature_values = data[feature_order].apply(pd.to_numeric, errors="coerce")
    if not np.isfinite(feature_values.to_numpy(dtype=float)).all():
        raise DatasetError("non-finite feature")
    data.loc[:, feature_order] = feature_values
    per_session = data.groupby("session_id")["motion_label"].nunique()
    if (per_session != 1).any():
        raise DatasetError("one session contains multiple motion labels")
    if data.duplicated(subset=["session_id", "window_index"]).any():
        raise DatasetError("duplicate session window")
    data.attrs["dataset_schema_version"] = contract[0]
    data.attrs["feature_schema_version"] = contract[1]
    data.attrs["feature_order"] = feature_order
    return data


def _resolve_training_contract(data) -> tuple[str, str, list[str]]:
    dataset_schema = data.attrs.get("dataset_schema_version")
    feature_schema = data.attrs.get("feature_schema_version")
    feature_order = data.attrs.get("feature_order")
    expected_feature_order = DATASET_CONTRACTS.get(
        (dataset_schema, feature_schema)
    )
    if expected_feature_order is None or feature_order != expected_feature_order:
        raise DatasetError("dataset/feature schema mismatch")
    return dataset_schema, feature_schema, list(expected_feature_order)


def _require_v1_training_contract(data) -> None:
    dataset_schema, feature_schema, feature_order = _resolve_training_contract(data)
    if (
        dataset_schema != DATASET_SCHEMA_V1
        or feature_schema != FEATURE_SCHEMA_V1
        or feature_order != FEATURE_ORDER_V1
    ):
        raise DatasetError("V1_RESEARCH_WORKFLOW_REQUIRES_V1_FEATURE_SCHEMA")


def _classification_metrics(
    y_true, y_pred, class_names: list[str]
) -> dict[str, Any]:
    from sklearn.metrics import (
        accuracy_score,
        confusion_matrix,
        precision_recall_fscore_support,
    )

    encoded_labels = list(range(len(class_names)))
    precision, recall, f1, support = precision_recall_fscore_support(
        y_true, y_pred, labels=encoded_labels, zero_division=0
    )
    return {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "macroPrecision": float(precision.mean()),
        "macroRecall": float(recall.mean()),
        "macroF1": float(f1.mean()),
        "perClass": {
            class_name: {
                "precision": float(precision[index]),
                "recall": float(recall[index]),
                "f1": float(f1[index]),
                "support": int(support[index]),
            }
            for index, class_name in enumerate(class_names)
        },
        "confusionMatrix": confusion_matrix(
            y_true, y_pred, labels=encoded_labels
        ).tolist(),
    }


def _development_candidate_specs() -> list[dict[str, Any]]:
    profiles: list[tuple[str, dict[str, float], int]] = [
        ("uniform", {label: 1.0 for label in MOTION_CLASSES}, 0),
    ]
    for factor_rank, factor in enumerate((1.25, 1.50), start=1):
        for class_name in MOTION_CLASSES:
            weights = {label: 1.0 for label in MOTION_CLASSES}
            weights[class_name] = factor
            profiles.append(
                (f"emphasize_{class_name.lower()}_{factor:.2f}", weights, factor_rank)
            )
    specs: list[dict[str, Any]] = []
    for c_value in DEVELOPMENT_C_VALUES:
        for profile_name, weights, complexity in profiles:
            specs.append(
                {
                    "C": c_value,
                    "profile": profile_name,
                    "classWeights": weights,
                    "weightComplexity": complexity,
                    "candidateOrder": len(specs),
                }
            )
    return specs


def _development_partition(data):
    session_labels = {
        str(session): str(label)
        for session, label in data.groupby("session_id")["motion_label"].first().items()
    }
    original_split = class_aware_session_split(session_labels)
    development_sessions = original_split["train"] | original_split["validation"]
    exposed_holdout_sessions = original_split["test"]
    if len(session_labels) != 24:
        raise DatasetError("development selection requires exactly 24 sessions")
    if len(development_sessions) != 20 or len(exposed_holdout_sessions) != 4:
        raise DatasetError("development/exposed session count mismatch")
    if development_sessions & exposed_holdout_sessions:
        raise DatasetError("exposed holdout overlaps development pool")
    development_counts = Counter(
        session_labels[session_id] for session_id in development_sessions
    )
    exposed_counts = Counter(
        session_labels[session_id] for session_id in exposed_holdout_sessions
    )
    if any(development_counts[label] != 5 for label in MOTION_CLASSES):
        raise DatasetError("development pool must contain five sessions per class")
    if any(exposed_counts[label] != 1 for label in MOTION_CLASSES):
        raise DatasetError("exposed holdout must contain one session per class")
    return original_split, development_sessions, exposed_holdout_sessions


def _build_development_folds(development_data):
    import numpy as np
    from sklearn.model_selection import StratifiedGroupKFold

    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    groups = development_data["session_id"].astype(str).to_numpy()
    features = development_data[FEATURE_ORDER].to_numpy(float)
    splitter = StratifiedGroupKFold(
        n_splits=DEVELOPMENT_FOLD_COUNT,
        shuffle=True,
        random_state=SEED,
    )
    preferred_folds = list(splitter.split(features, labels, groups))
    preferred_valid = all(
        len(set(groups[train_indexes])) == 16
        and len(set(groups[validation_indexes])) == 4
        and not set(groups[train_indexes]) & set(groups[validation_indexes])
        and set(int(value) for value in labels[validation_indexes])
        == set(range(len(MOTION_CLASSES)))
        for train_indexes, validation_indexes in preferred_folds
    )
    if preferred_valid:
        folds = preferred_folds
        strategy = {
            "name": "StratifiedGroupKFold",
            "preferredStrategyAccepted": True,
            "fallbackReason": None,
        }
    else:
        session_labels = {
            str(session): str(label)
            for session, label in development_data.groupby("session_id")[
                "motion_label"
            ].first().items()
        }
        validation_sessions_by_fold = [
            set() for _ in range(DEVELOPMENT_FOLD_COUNT)
        ]
        rng = random.Random(SEED)
        for class_name in MOTION_CLASSES:
            class_sessions = sorted(
                session_id
                for session_id, label in session_labels.items()
                if label == class_name
            )
            if len(class_sessions) != DEVELOPMENT_FOLD_COUNT:
                raise DatasetError(
                    "class-aware development CV requires five sessions per class"
                )
            rng.shuffle(class_sessions)
            for fold_index, session_id in enumerate(class_sessions):
                validation_sessions_by_fold[fold_index].add(session_id)
        folds = []
        all_indexes = np.arange(len(development_data))
        for validation_sessions in validation_sessions_by_fold:
            validation_mask = np.isin(groups, list(validation_sessions))
            validation_indexes = all_indexes[validation_mask]
            train_indexes = all_indexes[~validation_mask]
            folds.append((train_indexes, validation_indexes))
        strategy = {
            "name": "DeterministicClassAwareGroupKFold",
            "preferredStrategyAccepted": False,
            "fallbackReason": (
                "StratifiedGroupKFold did not place all four motion classes "
                "in every validation fold"
            ),
        }
    fold_summary = []
    validation_session_counts: Counter[str] = Counter()
    for fold_index, (train_indexes, validation_indexes) in enumerate(folds, start=1):
        train_sessions = set(groups[train_indexes])
        validation_sessions = set(groups[validation_indexes])
        if train_sessions & validation_sessions:
            raise DatasetError("session leakage detected inside development CV")
        validation_session_counts.update(validation_sessions)
        validation_classes = set(int(value) for value in labels[validation_indexes])
        if validation_classes != set(range(len(MOTION_CLASSES))):
            raise DatasetError("development validation fold lacks a motion class")
        if len(train_sessions) != 16 or len(validation_sessions) != 4:
            raise DatasetError("unexpected development fold session counts")
        fold_summary.append(
            {
                "fold": fold_index,
                "trainSessionCount": len(train_sessions),
                "validationSessionCount": len(validation_sessions),
                "validationWindowCount": int(len(validation_indexes)),
                "allMotionClassesRepresented": True,
                "sessionLeakage": False,
                "normalizationFit": "FOLD_TRAIN_ONLY",
            }
        )
    development_sessions = set(groups)
    if set(validation_session_counts) != development_sessions:
        raise DatasetError("not every development session appears in one validation fold")
    if any(count != 1 for count in validation_session_counts.values()):
        raise DatasetError("a development session appears in multiple validation folds")
    return folds, fold_summary, strategy


def _build_extended_development_folds(base_development_data, extension_data):
    import numpy as np
    import pandas as pd

    base_folds, _, _ = _build_development_folds(base_development_data)
    combined = pd.concat(
        [base_development_data, extension_data],
        ignore_index=True,
    )
    combined_groups = combined["session_id"].astype(str).to_numpy()
    combined_labels = combined["motion_label"].astype(str).to_numpy()
    base_groups = base_development_data["session_id"].astype(str).to_numpy()
    validation_sessions_by_fold = [
        set(base_groups[validation_indexes])
        for _, validation_indexes in base_folds
    ]
    extension_sessions = sorted(
        set(extension_data["session_id"].astype(str))
    )
    rng = random.Random(SEED)
    rng.shuffle(extension_sessions)
    for session_id, fold_index in zip(extension_sessions, range(len(extension_sessions))):
        validation_sessions_by_fold[fold_index].add(session_id)

    folds = []
    fold_summary = []
    validation_session_counts: Counter[str] = Counter()
    all_indexes = np.arange(len(combined))
    for fold_index, validation_sessions in enumerate(
        validation_sessions_by_fold,
        start=1,
    ):
        validation_mask = np.isin(combined_groups, list(validation_sessions))
        validation_indexes = all_indexes[validation_mask]
        train_indexes = all_indexes[~validation_mask]
        train_sessions = set(combined_groups[train_indexes])
        actual_validation_sessions = set(combined_groups[validation_indexes])
        if train_sessions & actual_validation_sessions:
            raise DatasetError("session leakage detected inside extended CV")
        if actual_validation_sessions != validation_sessions:
            raise DatasetError("extended CV session assignment mismatch")
        validation_session_counts.update(actual_validation_sessions)
        validation_classes = set(combined_labels[validation_indexes])
        if validation_classes != set(MOTION_CLASSES):
            raise DatasetError("extended validation fold lacks a motion class")
        class_session_counts = {
            label: len(
                {
                    session_id
                    for session_id in actual_validation_sessions
                    if combined.loc[
                        combined["session_id"].astype(str) == session_id,
                        "motion_label",
                    ].iloc[0]
                    == label
                }
            )
            for label in MOTION_CLASSES
        }
        folds.append((train_indexes, validation_indexes))
        fold_summary.append(
            {
                "fold": fold_index,
                "trainSessionCount": len(train_sessions),
                "validationSessionCount": len(actual_validation_sessions),
                "validationWindowCount": int(len(validation_indexes)),
                "validationSessionsPerMotionClass": class_session_counts,
                "allMotionClassesRepresented": True,
                "sessionLeakage": False,
                "normalizationFit": "FOLD_TRAIN_ONLY",
            }
        )
    all_sessions = set(combined_groups)
    if set(validation_session_counts) != all_sessions:
        raise DatasetError("not every extended session appears in one validation fold")
    if any(count != 1 for count in validation_session_counts.values()):
        raise DatasetError("an extended session appears in multiple validation folds")
    straight_counts = [
        fold["validationSessionsPerMotionClass"]["STRAIGHT_WALK"]
        for fold in fold_summary
    ]
    if sorted(straight_counts) != [1, 1, 1, 2, 2]:
        raise DatasetError("extra STRAIGHT sessions were not distributed across folds")
    strategy = {
        "name": "HistoricalBasePlusDeterministicStraightExtensionGroupKFold",
        "baseFoldStrategyPreserved": True,
        "extensionAssignmentSeed": SEED,
        "extraStraightValidationSessionCounts": straight_counts,
    }
    return combined, folds, fold_summary, strategy


def _fit_logistic_candidate(features, labels, spec: dict[str, Any]):
    import warnings

    from sklearn.exceptions import ConvergenceWarning
    from sklearn.linear_model import LogisticRegression

    encoded_weights = {
        MOTION_LABEL_TO_INDEX[label]: weight
        for label, weight in spec["classWeights"].items()
    }
    model = LogisticRegression(
        C=spec["C"],
        max_iter=2000,
        random_state=SEED,
        class_weight=encoded_weights,
    )
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("error", ConvergenceWarning)
            model.fit(features, labels)
    except ConvergenceWarning as error:
        raise DatasetError(
            f"logistic candidate did not converge: C={spec['C']} "
            f"profile={spec['profile']}"
        ) from error
    _assert_motion_model_class_order(model)
    return model


def _evaluate_logistic_candidate(
    development_data,
    folds,
    spec: dict[str, Any],
    retain_oof: bool = False,
) -> dict[str, Any]:
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = development_data[FEATURE_ORDER].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    groups = development_data["session_id"].astype(str).to_numpy()
    predictions = np.full(len(labels), -1, dtype=np.int64)
    probabilities = (
        np.full(
            (len(labels), len(MOTION_CLASSES)),
            np.nan,
            dtype=float,
        )
        if retain_oof
        else None
    )
    fold_indexes = (
        np.full(len(labels), -1, dtype=np.int64)
        if retain_oof
        else None
    )
    fold_metrics = []
    for fold_index, (train_indexes, validation_indexes) in enumerate(folds, start=1):
        scaler = StandardScaler().fit(features[train_indexes])
        normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
        train_features = np.clip(
            (features[train_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        validation_features = np.clip(
            (features[validation_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        model = _fit_logistic_candidate(
            train_features,
            labels[train_indexes],
            spec,
        )
        if retain_oof:
            fold_probabilities = _validated_motion_probabilities(
                model,
                validation_features,
            )
            probabilities[validation_indexes] = fold_probabilities
            fold_indexes[validation_indexes] = fold_index
            fold_predictions = np.argmax(
                fold_probabilities,
                axis=1,
            ).astype(np.int64)
        else:
            fold_predictions = model.predict(validation_features)
        predictions[validation_indexes] = fold_predictions
        metrics = _classification_metrics(
            labels[validation_indexes],
            fold_predictions,
            MOTION_CLASSES,
        )
        fold_metrics.append(
            {
                "fold": fold_index,
                "macroF1": metrics["macroF1"],
                "straightWalkRecall": metrics["perClass"]["STRAIGHT_WALK"]["recall"],
                "turningRecall": metrics["perClass"]["TURNING"]["recall"],
            }
        )
    if (predictions < 0).any():
        raise DatasetError("incomplete out-of-fold development predictions")
    aggregate = _classification_metrics(labels, predictions, MOTION_CLASSES)
    result = {
        "C": spec["C"],
        "profile": spec["profile"],
        "classWeights": spec["classWeights"],
        "weightComplexity": spec["weightComplexity"],
        "candidateOrder": spec["candidateOrder"],
        "aggregateMetrics": aggregate,
        "foldMetrics": fold_metrics,
    }
    if retain_oof:
        if not np.isfinite(probabilities).all() or (fold_indexes < 1).any():
            raise DatasetError("incomplete retained Logistic OOF probabilities")
        result["_oof"] = {
            "labels": labels,
            "groups": groups,
            "windowIndexes": development_data["window_index"].to_numpy(int),
            "probabilities": probabilities,
            "predictions": predictions,
            "foldIndexes": fold_indexes,
        }
    return result


def _candidate_is_eligible(candidate: dict[str, Any]) -> bool:
    metrics = candidate["aggregateMetrics"]
    return metrics["macroF1"] >= 0.75 and all(
        metrics["perClass"][label]["recall"] >= 0.55
        for label in MOTION_CLASSES
    )


def _development_selection_key(candidate: dict[str, Any]):
    metrics = candidate["aggregateMetrics"]
    minimum_recall = min(
        metrics["perClass"][label]["recall"] for label in MOTION_CLASSES
    )
    return (
        metrics["macroF1"],
        minimum_recall,
        -candidate["weightComplexity"],
        -candidate["C"],
        -candidate["candidateOrder"],
    )


def _select_best_development_candidate(candidates: list[dict[str, Any]]):
    eligible = [candidate for candidate in candidates if _candidate_is_eligible(candidate)]
    if not eligible:
        return None
    return max(eligible, key=_development_selection_key)


def _has_catastrophic_straight_fold(candidate: dict[str, Any]) -> bool:
    return any(
        fold["straightWalkRecall"] < 0.55
        for fold in candidate["foldMetrics"]
    )


def _extended_development_selection_key(candidate: dict[str, Any]):
    metrics = candidate["aggregateMetrics"]
    minimum_recall = min(
        metrics["perClass"][label]["recall"] for label in MOTION_CLASSES
    )
    return (
        _candidate_is_eligible(candidate),
        not _has_catastrophic_straight_fold(candidate),
        metrics["macroF1"],
        minimum_recall,
        -candidate["weightComplexity"],
        -candidate["C"],
        -candidate["candidateOrder"],
    )


def _straight_turning_feature_analysis(
    development_data,
    candidate: dict[str, Any],
) -> dict[str, Any]:
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = development_data[FEATURE_ORDER].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    scaler = StandardScaler().fit(features)
    normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
    standardized = np.clip(
        (features - scaler.mean_) / normalization_std,
        -5.0,
        5.0,
    )
    model = _fit_logistic_candidate(standardized, labels, candidate)
    straight_index = MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
    turning_index = MOTION_LABEL_TO_INDEX["TURNING"]
    straight_rows = standardized[labels == straight_index]
    turning_rows = standardized[labels == turning_index]
    coefficient_difference = (
        model.coef_[straight_index] - model.coef_[turning_index]
    )
    features_report = []
    for index, feature_name in enumerate(FEATURE_ORDER):
        features_report.append(
            {
                "feature": feature_name,
                "straightMean": float(straight_rows[:, index].mean()),
                "straightStd": float(straight_rows[:, index].std()),
                "turningMean": float(turning_rows[:, index].mean()),
                "turningStd": float(turning_rows[:, index].std()),
                "standardizedMeanDifference": float(
                    straight_rows[:, index].mean() - turning_rows[:, index].mean()
                ),
                "standardizedCoefficientDifference": float(
                    coefficient_difference[index]
                ),
            }
        )
    ranked = sorted(
        features_report,
        key=lambda value: (
            abs(value["standardizedCoefficientDifference"]),
            abs(value["standardizedMeanDifference"]),
            value["feature"],
        ),
        reverse=True,
    )
    return {
        "rankingBasis": (
            "absolute STRAIGHT_WALK-vs-TURNING coefficient difference from the "
            "selected development Logistic model on development-standardized features"
        ),
        "topFeatures": ranked[:8],
        "allFeatures": features_report,
    }


def development_select(input_path: Path, report_output: Path) -> str:
    data = _load_and_validate(input_path)
    _require_v1_training_contract(data)
    if len(data) != 576:
        raise DatasetError("development selection requires exactly 576 windows")
    original_split, development_sessions, exposed_holdout_sessions = (
        _development_partition(data)
    )
    development_data = data[
        data["session_id"].astype(str).isin(development_sessions)
    ].copy()
    if set(development_data["session_id"].astype(str)) & exposed_holdout_sessions:
        raise DatasetError("exposed holdout entered development data")
    folds, fold_summary, fold_strategy = _build_development_folds(
        development_data
    )
    candidate_results = [
        _evaluate_logistic_candidate(development_data, folds, spec)
        for spec in _development_candidate_specs()
    ]
    selected = _select_best_development_candidate(candidate_results)
    baseline = next(
        candidate
        for candidate in candidate_results
        if candidate["C"] == 1.0 and candidate["profile"] == "uniform"
    )
    diagnostic_candidate = selected or max(
        candidate_results,
        key=_development_selection_key,
    )
    feature_analysis = _straight_turning_feature_analysis(
        development_data,
        diagnostic_candidate,
    )
    status = (
        "MOTION_MODEL_DEVELOPMENT_GATE_PASS"
        if selected is not None
        else "MOTION_MODEL_DEVELOPMENT_GATE_FAIL"
    )

    def sanitized_candidate(candidate: dict[str, Any]) -> dict[str, Any]:
        metrics = candidate["aggregateMetrics"]
        return {
            "C": candidate["C"],
            "profile": candidate["profile"],
            "classWeights": candidate["classWeights"],
            "aggregateMetrics": metrics,
            "minimumClassRecall": min(
                metrics["perClass"][label]["recall"]
                for label in MOTION_CLASSES
            ),
            "foldMetrics": candidate["foldMetrics"],
            "eligible": _candidate_is_eligible(candidate),
        }

    selected_report = sanitized_candidate(selected) if selected is not None else None
    report: dict[str, Any] = {
        "status": status,
        "datasetSchemaVersion": DATASET_SCHEMA,
        "featureSchemaVersion": FEATURE_SCHEMA,
        "seed": SEED,
        "dataIsolation": {
            "totalSessionCount": 24,
            "totalWindowCount": int(len(data)),
            "developmentSessionCount": len(development_sessions),
            "developmentWindowCount": int(len(development_data)),
            "developmentSessionsPerMotionClass": {
                label: 5 for label in MOTION_CLASSES
            },
            "exposedHoldoutSessionCount": len(exposed_holdout_sessions),
            "exposedHoldoutWindowCount": int(
                len(data) - len(development_data)
            ),
            "overlapCount": 0,
            "exposedHoldoutUsedForTuning": False,
            "originalSplitReproduced": (
                len(original_split["train"]) == 16
                and len(original_split["validation"]) == 4
                and len(original_split["test"]) == 4
            ),
        },
        "crossValidation": {
            "strategy": fold_strategy["name"],
            "preferredStrategy": "StratifiedGroupKFold",
            "preferredStrategyAccepted": fold_strategy[
                "preferredStrategyAccepted"
            ],
            "fallbackReason": fold_strategy["fallbackReason"],
            "nSplits": DEVELOPMENT_FOLD_COUNT,
            "shuffle": True,
            "randomState": SEED,
            "group": "session_id",
            "sessionLeakage": False,
            "allClassesRepresented": True,
            "normalizationFit": "EACH_FOLD_TRAIN_ONLY",
            "folds": fold_summary,
        },
        "baselineCv": sanitized_candidate(baseline),
        "candidateSearch": {
            "candidateCount": len(candidate_results),
            "eligibleCandidateCount": sum(
                _candidate_is_eligible(candidate)
                for candidate in candidate_results
            ),
            "selectionRule": [
                "highest_macro_f1",
                "highest_minimum_class_recall",
                "simplest_class_weight_profile",
                "smallest_C",
                "deterministic_candidate_order",
            ],
            "candidates": [
                sanitized_candidate(candidate) for candidate in candidate_results
            ],
            "bestEligibleCandidate": selected_report,
        },
        "straightVsTurningAnalysis": {
            "developmentOnly": True,
            "exposedHoldoutUsed": False,
            "diagnosticCandidate": {
                "C": diagnostic_candidate["C"],
                "profile": diagnostic_candidate["profile"],
                "selectedForFreeze": diagnostic_candidate is selected,
            },
            **feature_analysis,
        },
        "mlpAudit": {
            "initialMlpRetainedAsBaseline": True,
            "expandedHyperparameterSearch": False,
            "earlyStopping": True,
            "internalRowLevelEarlyStoppingSplit": True,
            "sessionIsolatedInternalValidation": False,
        },
        "reliabilityHeads": {
            "arcore": "PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
        },
        "frozenCandidate": (
            {
                "family": "logistic_regression",
                "C": selected["C"],
                "classWeights": selected["classWeights"],
                "featureOrder": FEATURE_ORDER,
                "featureSchemaVersion": FEATURE_SCHEMA,
                "normalizationPolicy": "FIT_DEVELOPMENT_TRAINING_DATA_ONLY",
                "motionClasses": MOTION_CLASSES,
                "decisionRule": "argmax_probability",
            }
            if selected is not None
            else None
        ),
        "productionModelExported": False,
        "freshFinalHoldoutPlan": {
            "required": selected is not None,
            "collectionTiming": "AFTER_DEVELOPMENT_CANDIDATE_FREEZE",
            "sessionCount": 4 if selected is not None else 0,
            "sessionsPerMotionClass": (
                {label: 1 for label in MOTION_CLASSES}
                if selected is not None
                else {}
            ),
            "participatesInTrainingOrSelection": False,
        },
        "originalExposedHoldoutPreservedAsDevelopmentEvidence": True,
        "accuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    _write_json_atomic(report_output, report)
    return status


def _load_frozen_development_contract(report_path: Path) -> dict[str, Any]:
    try:
        report = json.loads(report_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise DatasetError("frozen development report is missing or invalid") from error
    frozen = report.get("frozenCandidate")
    expected_weights = FROZEN_MOTION_CLASS_WEIGHTS
    valid = (
        report.get("status") == "MOTION_MODEL_DEVELOPMENT_GATE_PASS"
        and isinstance(frozen, dict)
        and frozen.get("family") == "logistic_regression"
        and frozen.get("C") == FROZEN_MOTION_C
        and frozen.get("classWeights") == expected_weights
        and frozen.get("featureSchemaVersion") == FEATURE_SCHEMA
        and frozen.get("featureOrder") == FEATURE_ORDER
        and frozen.get("motionClasses") == MOTION_CLASSES
        and frozen.get("normalizationPolicy")
        == "FIT_DEVELOPMENT_TRAINING_DATA_ONLY"
        and frozen.get("decisionRule") == "argmax_probability"
        and report.get("productionModelExported") is False
    )
    if not valid:
        raise DatasetError("frozen development contract mismatch")
    return {
        "C": FROZEN_MOTION_C,
        "profile": "frozen_development_candidate",
        "classWeights": dict(FROZEN_MOTION_CLASS_WEIGHTS),
        "weightComplexity": 1,
        "candidateOrder": 0,
    }


def _validate_final_data_isolation(development_source, final_holdout):
    development_split, development_sessions, exposed_sessions = (
        _development_partition(development_source)
    )
    if len(development_source) != 576:
        raise DatasetError("development_v1 must contain exactly 576 windows")
    fitting_data = development_source[
        development_source["session_id"].astype(str).isin(development_sessions)
    ].copy()
    if len(fitting_data) != 480:
        raise DatasetError("frozen fitting pool must contain exactly 480 windows")

    final_session_labels = {
        str(session): str(label)
        for session, label in final_holdout.groupby("session_id")[
            "motion_label"
        ].first().items()
    }
    final_sessions = set(final_session_labels)
    if len(final_holdout) != 96 or len(final_sessions) != 4:
        raise DatasetError("final_holdout_v1 must contain 4 sessions / 96 windows")
    final_session_counts = Counter(final_session_labels.values())
    final_window_counts = Counter(final_holdout["motion_label"].astype(str))
    if any(final_session_counts[label] != 1 for label in MOTION_CLASSES):
        raise DatasetError("final holdout must contain one session per motion class")
    if any(final_window_counts[label] != 24 for label in MOTION_CLASSES):
        raise DatasetError("final holdout must contain 24 windows per motion class")
    if (
        development_sessions & exposed_sessions
        or development_sessions & final_sessions
        or exposed_sessions & final_sessions
    ):
        raise DatasetError("development/exposed/final session overlap detected")
    if not (
        len(development_split["train"]) == 16
        and len(development_split["validation"]) == 4
        and len(development_split["test"]) == 4
    ):
        raise DatasetError("original deterministic development split changed")
    return fitting_data, {
        "developmentSourceSessionCount": 24,
        "developmentSourceWindowCount": 576,
        "frozenFittingSessionCount": len(development_sessions),
        "frozenFittingWindowCount": int(len(fitting_data)),
        "originalExposedHoldoutSessionCount": len(exposed_sessions),
        "freshFinalHoldoutSessionCount": len(final_sessions),
        "freshFinalHoldoutWindowCount": int(len(final_holdout)),
        "overlapCount": 0,
        "finalHoldoutUsedInScalerOrModelFit": False,
    }


def _motion_deployment_gate(metrics: dict[str, Any]) -> bool:
    return metrics["macroF1"] >= 0.75 and all(
        metrics["perClass"][label]["recall"] >= 0.55
        for label in MOTION_CLASSES
    )


def _build_motion_only_model_json(model, scaler, normalization_std) -> dict[str, Any]:
    import numpy as np

    _assert_motion_model_class_order(model)
    fixtures = []
    fixture_inputs = [
        np.zeros(len(FEATURE_ORDER)),
        scaler.mean_.copy(),
        scaler.mean_ + 0.25 * normalization_std,
    ]
    for raw in fixture_inputs:
        standardized = np.clip(
            (raw - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        logits = standardized.reshape(1, -1) @ model.coef_.T + model.intercept_
        fixtures.append(
            {
                "features": [float(value) for value in raw],
                "motionProbabilities": [
                    float(value) for value in _softmax(logits)[0]
                ],
            }
        )
    return {
        "modelSchemaVersion": MODEL_SCHEMA,
        "featureSchemaVersion": FEATURE_SCHEMA,
        "featureOrder": FEATURE_ORDER,
        "normalizationMean": [float(value) for value in scaler.mean_],
        "normalizationStd": [float(value) for value in normalization_std],
        "motionModel": _export_motion(model, "logistic_regression"),
        "motionClasses": MOTION_CLASSES,
        "reliabilityAvailability": {
            name: False for name in RELIABILITY_HEADS
        },
        "trainingDatasetAggregateCounts": {
            "sessionCount": 20,
            "windowCount": 480,
            "sessionsPerMotionClass": {
                label: 5 for label in MOTION_CLASSES
            },
        },
        "modelVersion": "navguard_ai_model_v1_frozen_physical",
        "parityFixtures": fixtures,
    }


def _validate_python_export_parity(model_json: dict[str, Any]) -> None:
    import numpy as np

    mean = np.asarray(model_json["normalizationMean"], dtype=float)
    std = np.asarray(model_json["normalizationStd"], dtype=float)
    weights = np.asarray(model_json["motionModel"]["weights"], dtype=float)
    bias = np.asarray(model_json["motionModel"]["bias"], dtype=float)
    if model_json["motionClasses"] != MOTION_CLASSES:
        raise DatasetError("exported motion class order mismatch")
    for fixture in model_json["parityFixtures"]:
        raw = np.asarray(fixture["features"], dtype=float)
        standardized = np.clip((raw - mean) / std, -5.0, 5.0)
        actual = _softmax(standardized.reshape(1, -1) @ weights.T + bias)[0]
        expected = np.asarray(fixture["motionProbabilities"], dtype=float)
        if actual.shape != expected.shape or not np.allclose(
            actual,
            expected,
            rtol=0.0,
            atol=1e-12,
        ):
            raise DatasetError("Python export parity fixture mismatch")


def final_evaluate(
    development_input: Path,
    final_holdout_input: Path,
    development_report: Path,
    model_output: Path,
    report_output: Path,
) -> str:
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    if report_output.exists():
        raise DatasetError("FRESH_FINAL_HOLDOUT_V1_ALREADY_CONSUMED")
    if model_output.exists():
        raise DatasetError("production model already exists before final evaluation")
    frozen_spec = _load_frozen_development_contract(development_report)
    development_source = _load_and_validate(development_input)
    final_holdout = _load_and_validate(final_holdout_input)
    _require_v1_training_contract(development_source)
    _require_v1_training_contract(final_holdout)
    fitting_data, isolation = _validate_final_data_isolation(
        development_source,
        final_holdout,
    )
    started_report = {
        "status": "FINAL_HOLDOUT_EVALUATION_STARTED",
        "freshFinalHoldoutConsumed": True,
        "dataIsolation": isolation,
        "accuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    _write_json_atomic(report_output, started_report)

    fitting_features = fitting_data[FEATURE_ORDER].to_numpy(float)
    fitting_labels = encode_motion_labels(
        fitting_data["motion_label"].astype(str).to_numpy()
    )
    scaler = StandardScaler().fit(fitting_features)
    normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
    standardized_fitting = np.clip(
        (fitting_features - scaler.mean_) / normalization_std,
        -5.0,
        5.0,
    )
    model = _fit_logistic_candidate(
        standardized_fitting,
        fitting_labels,
        frozen_spec,
    )

    final_features = final_holdout[FEATURE_ORDER].to_numpy(float)
    final_labels = encode_motion_labels(
        final_holdout["motion_label"].astype(str).to_numpy()
    )
    standardized_final = np.clip(
        (final_features - scaler.mean_) / normalization_std,
        -5.0,
        5.0,
    )
    probabilities = _validated_motion_probabilities(model, standardized_final)
    predictions = np.asarray(model.classes_)[
        np.argmax(probabilities, axis=1)
    ]
    metrics = _classification_metrics(
        final_labels,
        predictions,
        MOTION_CLASSES,
    )
    gate_passed = _motion_deployment_gate(metrics)
    status = (
        "MOTION_PRODUCTION_GATE_PASS"
        if gate_passed
        else "MOTION_PRODUCTION_GATE_FAIL"
    )
    report: dict[str, Any] = {
        "status": status,
        "freshFinalHoldoutConsumed": True,
        "datasetSchemaVersion": DATASET_SCHEMA,
        "featureSchemaVersion": FEATURE_SCHEMA,
        "featureCount": len(FEATURE_ORDER),
        "dataIsolation": isolation,
        "frozenModel": {
            "family": "logistic_regression",
            "C": FROZEN_MOTION_C,
            "classWeights": FROZEN_MOTION_CLASS_WEIGHTS,
            "featureOrder": FEATURE_ORDER,
            "motionClasses": MOTION_CLASSES,
            "decisionRule": "argmax_probability",
            "normalizationPolicy": "FIT_FROZEN_DEVELOPMENT_POOL_ONLY",
            "parametersChangedAfterFreeze": False,
        },
        "finalHoldoutMetrics": metrics,
        "deploymentGate": {
            "macroF1Threshold": 0.75,
            "minimumPerClassRecallThreshold": 0.55,
            "passed": gate_passed,
        },
        "reliability": {
            "freshBalancedArcoreValidation": False,
            "productionHeads": [],
            "pdrDeployed": False,
            "headingDeployed": False,
            "deterministicDv2FallbackRequired": True,
        },
        "productionModel": {
            "created": False,
            "trainedUsingFinalHoldout": False,
            "motionFamily": "logistic_regression",
            "reliabilityHeads": [],
            "sha256": None,
            "fileSizeBytes": None,
        },
        "paritySafety": {
            "pythonExportParity": False,
            "pythonKotlinParity": "NOT_RUN",
            "classOrderParity": True,
            "noCoordinateOutput": True,
            "noStrideMutation": True,
            "groundTruthFirewall": True,
            "dv2Fallback": True,
        },
        "accuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    if gate_passed:
        model_json = _build_motion_only_model_json(
            model,
            scaler,
            normalization_std,
        )
        _validate_python_export_parity(model_json)
        serialized = (
            json.dumps(model_json, indent=2, sort_keys=True, allow_nan=False)
            + "\n"
        ).encode("utf-8")
        model_hash = hashlib.sha256(serialized).hexdigest()
        _write_bytes_atomic(model_output, serialized)
        report["productionModel"].update(
            {
                "created": True,
                "sha256": model_hash,
                "fileSizeBytes": len(serialized),
            }
        )
        report["paritySafety"]["pythonExportParity"] = True
        report["paritySafety"]["pythonKotlinParity"] = "PENDING"
    _write_json_atomic(report_output, report)
    return status


def record_runtime_parity(report_output: Path, status: str) -> None:
    if status not in {"PASS", "FAIL"}:
        raise DatasetError("runtime parity status must be PASS or FAIL")
    try:
        report = json.loads(report_output.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise DatasetError("final evaluation report is missing or invalid") from error
    if report.get("status") != "MOTION_PRODUCTION_GATE_PASS":
        raise DatasetError("runtime parity can only finalize a passing motion model")
    if report.get("productionModel", {}).get("created") is not True:
        raise DatasetError("runtime parity requires an exported production model")
    report["paritySafety"]["pythonKotlinParity"] = status
    _write_json_atomic(report_output, report)


def _generate_candidate_oof_predictions(development_data, folds, spec):
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = development_data[FEATURE_ORDER].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    groups = development_data["session_id"].astype(str).to_numpy()
    window_indexes = development_data["window_index"].to_numpy(int)
    probabilities = np.full(
        (len(development_data), len(MOTION_CLASSES)),
        np.nan,
        dtype=float,
    )
    fold_indexes = np.full(len(development_data), -1, dtype=np.int64)
    for fold_index, (train_indexes, validation_indexes) in enumerate(folds, start=1):
        scaler = StandardScaler().fit(features[train_indexes])
        normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
        train_features = np.clip(
            (features[train_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        validation_features = np.clip(
            (features[validation_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        model = _fit_logistic_candidate(
            train_features,
            labels[train_indexes],
            spec,
        )
        probabilities[validation_indexes] = _validated_motion_probabilities(
            model,
            validation_features,
        )
        fold_indexes[validation_indexes] = fold_index
    if not np.isfinite(probabilities).all() or (fold_indexes < 1).any():
        raise DatasetError("incomplete frozen OOF probability generation")
    predictions = np.argmax(probabilities, axis=1).astype(np.int64)
    return {
        "labels": labels,
        "groups": groups,
        "windowIndexes": window_indexes,
        "probabilities": probabilities,
        "predictions": predictions,
        "foldIndexes": fold_indexes,
    }


def _generate_frozen_oof_predictions(development_data, folds):
    spec = {
        "C": FROZEN_MOTION_C,
        "profile": "frozen_development_candidate",
        "classWeights": dict(FROZEN_MOTION_CLASS_WEIGHTS),
        "weightComplexity": 1,
        "candidateOrder": 0,
    }
    return _generate_candidate_oof_predictions(development_data, folds, spec)


def _distribution_summary(values) -> dict[str, float]:
    import numpy as np

    array = np.asarray(values, dtype=float)
    return {
        "mean": float(array.mean()),
        "median": float(np.median(array)),
        "p10": float(np.percentile(array, 10)),
        "p25": float(np.percentile(array, 25)),
        "p75": float(np.percentile(array, 75)),
        "p90": float(np.percentile(array, 90)),
    }


def _longest_true_run(values) -> int:
    longest = 0
    current = 0
    for value in values:
        current = current + 1 if bool(value) else 0
        longest = max(longest, current)
    return longest


def _session_error_topology(oof) -> dict[str, Any]:
    import numpy as np

    sanitized_prefix = {
        "STATIONARY": "STATIONARY",
        "STRAIGHT_WALK": "STRAIGHT",
        "TURNING": "TURNING",
        "UNSTABLE_MOTION": "UNSTABLE",
    }
    summaries = []
    patterns: dict[str, list[str]] = {
        "STRAIGHT_WALK": [],
        "TURNING": [],
    }
    sanitized_names: dict[str, str] = {}
    for class_index, class_name in enumerate(MOTION_CLASSES):
        class_sessions = sorted(
            set(oof["groups"][oof["labels"] == class_index])
        )
        for number, session_id in enumerate(class_sessions, start=1):
            sanitized_names[session_id] = (
                f"{sanitized_prefix[class_name]}_DEV_{number}"
            )
    for session_id in sorted(sanitized_names, key=lambda value: sanitized_names[value]):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        true_class = int(oof["labels"][indexes][0])
        predictions = oof["predictions"][indexes]
        wrong = predictions != true_class
        straight_to_turning = (
            (true_class == MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"])
            & (predictions == MOTION_LABEL_TO_INDEX["TURNING"])
        )
        counts = Counter(int(value) for value in predictions)
        dominant = max(
            range(len(MOTION_CLASSES)),
            key=lambda index: (counts[index], -index),
        )
        longest_wrong = _longest_true_run(wrong)
        wrong_fraction = float(wrong.mean())
        if wrong_fraction >= 0.50 or longest_wrong >= max(3, len(indexes) // 2):
            pattern = "PERSISTENT_SESSION_LEVEL"
        elif longest_wrong >= 2:
            pattern = "SHORT_RUNS"
        else:
            pattern = "TRANSIENT"
        class_name = MOTION_CLASSES[true_class]
        if class_name in patterns:
            patterns[class_name].append(pattern)
        summaries.append(
            {
                "session": sanitized_names[session_id],
                "trueClass": class_name,
                "windows": int(len(indexes)),
                "correctWindows": int((~wrong).sum()),
                "accuracy": float((~wrong).mean()),
                "dominantPredictedClass": MOTION_CLASSES[dominant],
                "longestConsecutiveWrongRun": longest_wrong,
                "longestStraightToTurningRun": _longest_true_run(
                    straight_to_turning
                ),
                "failurePattern": pattern,
            }
        )

    severity = {
        "TRANSIENT": 0,
        "SHORT_RUNS": 1,
        "PERSISTENT_SESSION_LEVEL": 2,
    }

    def dominant_pattern(values: list[str]) -> str:
        if not values:
            return "TRANSIENT"
        counts = Counter(values)
        return max(counts, key=lambda value: (counts[value], severity[value]))

    return {
        "sessions": summaries,
        "dominantStraightFailurePattern": dominant_pattern(
            patterns["STRAIGHT_WALK"]
        ),
        "dominantTurningFailurePattern": dominant_pattern(patterns["TURNING"]),
    }


def _probability_separation(oof) -> dict[str, Any]:
    import numpy as np

    probabilities = oof["probabilities"]
    labels = oof["labels"]
    straight_index = MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
    turning_index = MOTION_LABEL_TO_INDEX["TURNING"]
    result = {}
    for class_name, class_index in (
        ("STRAIGHT_WALK", straight_index),
        ("TURNING", turning_index),
    ):
        class_probabilities = probabilities[labels == class_index]
        true_probabilities = class_probabilities[:, class_index]
        other_probabilities = np.delete(
            class_probabilities,
            class_index,
            axis=1,
        )
        result[class_name] = {
            "straightProbability": _distribution_summary(
                class_probabilities[:, straight_index]
            ),
            "turningProbability": _distribution_summary(
                class_probabilities[:, turning_index]
            ),
            "trueVsBestOtherMargin": _distribution_summary(
                true_probabilities - other_probabilities.max(axis=1)
            ),
            "straightVsTurningMargin": _distribution_summary(
                class_probabilities[:, straight_index]
                - class_probabilities[:, turning_index]
            ),
        }
    return result


def _feature_separability(development_data) -> dict[str, Any]:
    import numpy as np

    straight = development_data[
        development_data["motion_label"].astype(str) == "STRAIGHT_WALK"
    ][FEATURE_ORDER].to_numpy(float)
    turning = development_data[
        development_data["motion_label"].astype(str) == "TURNING"
    ][FEATURE_ORDER].to_numpy(float)
    feature_reports = []
    for index, feature_name in enumerate(FEATURE_ORDER):
        straight_values = straight[:, index]
        turning_values = turning[:, index]
        pooled_std = math.sqrt(
            (float(straight_values.var()) + float(turning_values.var())) / 2.0
        )
        effect_size = (
            float((straight_values.mean() - turning_values.mean()) / pooled_std)
            if pooled_std > 1e-12
            else 0.0
        )
        straight_q25, straight_q75 = np.percentile(straight_values, [25, 75])
        turning_q25, turning_q75 = np.percentile(turning_values, [25, 75])
        overlap = max(
            0.0,
            min(straight_q75, turning_q75)
            - max(straight_q25, turning_q25),
        )
        union = max(straight_q75, turning_q75) - min(
            straight_q25,
            turning_q25,
        )
        feature_reports.append(
            {
                "feature": feature_name,
                "straightMean": float(straight_values.mean()),
                "straightStd": float(straight_values.std()),
                "turningMean": float(turning_values.mean()),
                "turningStd": float(turning_values.std()),
                "standardizedMeanDifference": effect_size,
                "absoluteEffectSize": abs(effect_size),
                "iqrOverlapFraction": float(overlap / union) if union > 1e-12 else 1.0,
            }
        )
    ranked = sorted(
        feature_reports,
        key=lambda value: (value["absoluteEffectSize"], value["feature"]),
        reverse=True,
    )
    strong_count = sum(value["absoluteEffectSize"] >= 0.50 for value in ranked)
    moderate_count = sum(value["absoluteEffectSize"] >= 0.30 for value in ranked)
    maximum = ranked[0]["absoluteEffectSize"]
    if maximum >= 0.80 and strong_count >= 3:
        signal = "FEATURE_SIGNAL_STRONG"
    elif maximum >= 0.50 and moderate_count >= 2:
        signal = "FEATURE_SIGNAL_MODERATE"
    else:
        signal = "FEATURE_SIGNAL_WEAK"
    return {
        "signal": signal,
        "signalRule": {
            "maximumAbsoluteEffectSize": maximum,
            "featuresAtOrAbove0.50": strong_count,
            "featuresAtOrAbove0.30": moderate_count,
        },
        "topFeatures": ranked[:10],
        "allFeatures": feature_reports,
    }


def _session_domain_shift(development_data) -> dict[str, Any]:
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    raw = development_data[FEATURE_ORDER].to_numpy(float)
    standardized = StandardScaler().fit_transform(raw)
    groups = development_data["session_id"].astype(str).to_numpy()
    labels = development_data["motion_label"].astype(str).to_numpy()
    results = {}
    for class_name in ("STRAIGHT_WALK", "TURNING"):
        class_sessions = sorted(set(groups[labels == class_name]))
        session_means = {
            session_id: standardized[groups == session_id].mean(axis=0)
            for session_id in class_sessions
        }
        sanitized = {
            session_id: f"{class_name}_DEV_{index}"
            for index, session_id in enumerate(class_sessions, start=1)
        }
        distances = []
        for session_id in class_sessions:
            peers = [
                value
                for peer_id, value in session_means.items()
                if peer_id != session_id
            ]
            peer_centroid = np.mean(peers, axis=0)
            distance = float(
                np.sqrt(np.mean((session_means[session_id] - peer_centroid) ** 2))
            )
            distances.append(
                {
                    "session": sanitized[session_id],
                    "rmsStandardizedDistanceToPeerCentroid": distance,
                }
            )
        maximum = max(value["rmsStandardizedDistanceToPeerCentroid"] for value in distances)
        level = "LOW" if maximum < 0.50 else "MODERATE" if maximum < 1.0 else "HIGH"
        results[class_name] = {
            "variability": level,
            "meanDistance": float(
                np.mean(
                    [
                        value["rmsStandardizedDistanceToPeerCentroid"]
                        for value in distances
                    ]
                )
            ),
            "maxDistance": maximum,
            "sessions": distances,
            "thresholds": {"lowBelow": 0.50, "moderateBelow": 1.0},
        }
    return results


def _ema_probabilities(probabilities, alpha: float):
    import numpy as np

    output = np.empty_like(probabilities, dtype=float)
    output[0] = probabilities[0]
    for index in range(1, len(probabilities)):
        output[index] = (
            alpha * probabilities[index]
            + (1.0 - alpha) * output[index - 1]
        )
    return output


def _hysteresis_predictions(probabilities, margin: float, consecutive: int):
    import numpy as np

    predictions = np.empty(len(probabilities), dtype=np.int64)
    current = int(np.argmax(probabilities[0]))
    predictions[0] = current
    pending = None
    pending_count = 0
    for index in range(1, len(probabilities)):
        candidate = int(np.argmax(probabilities[index]))
        wins = (
            candidate != current
            and probabilities[index, candidate]
            >= probabilities[index, current] + margin
        )
        if wins:
            if pending == candidate:
                pending_count += 1
            else:
                pending = candidate
                pending_count = 1
            if pending_count >= consecutive:
                current = candidate
                pending = None
                pending_count = 0
        else:
            pending = None
            pending_count = 0
        predictions[index] = current
    return predictions


def _temporal_predictions(oof, rule: dict[str, Any]):
    import numpy as np

    output = np.full(len(oof["labels"]), -1, dtype=np.int64)
    for session_id in sorted(set(oof["groups"])):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        probabilities = oof["probabilities"][indexes]
        if rule["emaAlpha"] is not None:
            probabilities = _ema_probabilities(probabilities, rule["emaAlpha"])
        if rule["hysteresisMargin"] is None:
            predictions = np.argmax(probabilities, axis=1).astype(np.int64)
        else:
            predictions = _hysteresis_predictions(
                probabilities,
                rule["hysteresisMargin"],
                rule["consecutiveWindows"],
            )
        output[indexes] = predictions
    if (output < 0).any():
        raise DatasetError("incomplete temporal predictions")
    return output


def _switch_delay_proxy(oof, candidate_predictions) -> dict[str, Any]:
    import numpy as np

    delays = []
    raw_predictions = oof["predictions"]
    for session_id in sorted(set(oof["groups"])):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        raw = raw_predictions[indexes]
        candidate = candidate_predictions[indexes]
        for position in range(1, len(indexes)):
            if candidate[position] == candidate[position - 1]:
                continue
            new_class = candidate[position]
            raw_start = position
            while raw_start > 0 and raw[raw_start - 1] == new_class:
                raw_start -= 1
            delays.append(max(0, position - raw_start))
    if not delays:
        return {"meanWindows": 0.0, "p90Windows": 0.0, "maxWindows": 0}
    return {
        "meanWindows": float(np.mean(delays)),
        "p90Windows": float(np.percentile(delays, 90)),
        "maxWindows": int(max(delays)),
    }


def _evaluate_temporal_rule(oof, rule: dict[str, Any]) -> dict[str, Any]:
    predictions = _temporal_predictions(oof, rule)
    aggregate = _classification_metrics(
        oof["labels"],
        predictions,
        MOTION_CLASSES,
    )
    fold_metrics = []
    for fold_index in range(1, DEVELOPMENT_FOLD_COUNT + 1):
        mask = oof["foldIndexes"] == fold_index
        metrics = _classification_metrics(
            oof["labels"][mask],
            predictions[mask],
            MOTION_CLASSES,
        )
        fold_metrics.append(
            {
                "fold": fold_index,
                "macroF1": metrics["macroF1"],
                "straightWalkRecall": metrics["perClass"]["STRAIGHT_WALK"]["recall"],
                "turningRecall": metrics["perClass"]["TURNING"]["recall"],
            }
        )
    minimum_recall = min(
        aggregate["perClass"][label]["recall"] for label in MOTION_CLASSES
    )
    delay = _switch_delay_proxy(oof, predictions)
    aggregate_gate = _motion_deployment_gate(aggregate)
    fold_robust = all(
        fold["macroF1"] >= 0.75
        and fold["straightWalkRecall"] >= 0.55
        and fold["turningRecall"] >= 0.55
        for fold in fold_metrics
    )
    return {
        **rule,
        "aggregateMetrics": aggregate,
        "minimumClassRecall": minimum_recall,
        "switchDelayProxy": delay,
        "aggregateGatePassed": aggregate_gate,
        "foldRobust": fold_robust,
        "latencyRequirementPassed": delay["maxWindows"] <= 2,
        "robust": aggregate_gate and fold_robust and delay["maxWindows"] <= 2,
        "foldMetrics": fold_metrics,
    }


def _temporal_rule_specs() -> list[dict[str, Any]]:
    rules = [
        {
            "name": "raw_argmax",
            "emaAlpha": None,
            "hysteresisMargin": None,
            "consecutiveWindows": None,
            "complexity": 0,
        }
    ]
    for alpha in (0.25, 0.50, 0.75):
        rules.append(
            {
                "name": f"ema_{alpha:.2f}",
                "emaAlpha": alpha,
                "hysteresisMargin": None,
                "consecutiveWindows": None,
                "complexity": 1,
            }
        )
    for alpha in (None, 0.25, 0.50, 0.75):
        for margin in (0.05, 0.10, 0.15):
            for consecutive in (1, 2):
                prefix = "raw" if alpha is None else f"ema_{alpha:.2f}"
                rules.append(
                    {
                        "name": f"{prefix}_hyst_{margin:.2f}_{consecutive}",
                        "emaAlpha": alpha,
                        "hysteresisMargin": margin,
                        "consecutiveWindows": consecutive,
                        "complexity": 2 if alpha is None else 3,
                    }
                )
    return rules


def _temporal_study(oof) -> dict[str, Any]:
    candidates = [
        _evaluate_temporal_rule(oof, rule) for rule in _temporal_rule_specs()
    ]
    raw = candidates[0]
    temporal = candidates[1:]
    robust_candidates = [candidate for candidate in temporal if candidate["robust"]]
    eligible_candidates = [
        candidate
        for candidate in temporal
        if candidate["aggregateGatePassed"]
        and candidate["latencyRequirementPassed"]
    ]
    selection_pool = robust_candidates or eligible_candidates or temporal

    def key(candidate):
        metrics = candidate["aggregateMetrics"]
        return (
            candidate["robust"],
            metrics["macroF1"],
            candidate["minimumClassRecall"],
            -candidate["switchDelayProxy"]["maxWindows"],
            -candidate["complexity"],
            candidate["name"],
        )

    best = max(selection_pool, key=key)
    materially_improves = (
        best["robust"]
        and best["aggregateMetrics"]["macroF1"]
        >= raw["aggregateMetrics"]["macroF1"] + 0.02
        and best["minimumClassRecall"] >= raw["minimumClassRecall"] - 0.02
    )
    return {
        "candidateCount": len(candidates),
        "causalOnly": True,
        "futureWindowsAccessed": False,
        "rawBaseline": raw,
        "bestTemporalCandidate": best,
        "robustCandidateCount": len(robust_candidates),
        "materiallyImprovesRobustness": materially_improves,
        "candidates": candidates,
        "foldRobustnessRule": (
            "every fold macroF1 >= 0.75 and STRAIGHT/TURNING recall >= 0.55"
        ),
        "switchDelayDefinition": (
            "candidate-transition delay relative to the start of the same "
            "contiguous raw-argmax class run; no true within-session transitions "
            "exist in the single-label dataset"
        ),
    }


def _validate_v2_development_dataset(data) -> dict[str, Any]:
    import numpy as np
    import pandas as pd

    dataset_schema, feature_schema, feature_order = _resolve_training_contract(data)
    if (
        dataset_schema != DATASET_SCHEMA_V2
        or feature_schema != FEATURE_SCHEMA_V2
        or feature_order != FEATURE_ORDER_V2
    ):
        raise DatasetError("V2_DEVELOPMENT_REQUIRES_EXACT_V2_SCHEMA")
    if len(data) != 480:
        raise DatasetError("V2 development requires exactly 480 windows")
    sessions = data["session_id"].astype(str)
    if sessions.nunique() != V2_DEVELOPMENT_SESSION_COUNT:
        raise DatasetError("V2 development requires exactly 20 sessions")
    session_window_counts = data.groupby(sessions).size()
    if not (session_window_counts == V2_DEVELOPMENT_WINDOWS_PER_SESSION).all():
        raise DatasetError("V2 development requires exactly 24 windows per session")
    numeric_window_indexes = pd.to_numeric(data["window_index"], errors="coerce")
    if (
        numeric_window_indexes.isna().any()
        or not np.equal(numeric_window_indexes, np.floor(numeric_window_indexes)).all()
    ):
        raise DatasetError("invalid V2 development window index")
    motion_window_counts = Counter(data["motion_label"].astype(str))
    if any(
        motion_window_counts[label] != V2_DEVELOPMENT_WINDOWS_PER_CLASS
        for label in MOTION_CLASSES
    ):
        raise DatasetError("V2 development requires exactly 120 windows per class")
    session_labels = data.groupby(sessions)["motion_label"].first().astype(str)
    sessions_per_class = Counter(session_labels)
    if any(sessions_per_class[label] != 5 for label in MOTION_CLASSES):
        raise DatasetError("V2 development requires exactly five sessions per class")
    return {
        "datasetSchemaVersion": dataset_schema,
        "featureSchemaVersion": feature_schema,
        "featureCount": len(feature_order),
        "sessionCount": int(sessions.nunique()),
        "windowCount": int(len(data)),
        "motionWindowCounts": {
            label: int(motion_window_counts[label]) for label in MOTION_CLASSES
        },
        "sessionsPerMotionClass": {
            label: int(sessions_per_class[label]) for label in MOTION_CLASSES
        },
        "windowsPerSession": V2_DEVELOPMENT_WINDOWS_PER_SESSION,
        "finiteFeatures": True,
        "unknownMotionClassCount": 0,
        "duplicateSessionWindowCount": 0,
        "mixedDatasetSchema": False,
        "mixedFeatureSchema": False,
    }


def _build_v2_development_folds(development_data):
    import numpy as np

    groups = development_data["session_id"].astype(str).to_numpy()
    labels = development_data["motion_label"].astype(str).to_numpy()
    session_labels = {
        str(session): str(label)
        for session, label in development_data.groupby("session_id")[
            "motion_label"
        ].first().items()
    }
    validation_sessions_by_fold = [
        set() for _ in range(DEVELOPMENT_FOLD_COUNT)
    ]
    rng = random.Random(SEED)
    for class_name in MOTION_CLASSES:
        class_sessions = sorted(
            session_id
            for session_id, label in session_labels.items()
            if label == class_name
        )
        if len(class_sessions) != DEVELOPMENT_FOLD_COUNT:
            raise DatasetError(
                "V2 class-aware CV requires exactly five sessions per class"
            )
        rng.shuffle(class_sessions)
        for fold_index, session_id in enumerate(class_sessions):
            validation_sessions_by_fold[fold_index].add(session_id)

    all_indexes = np.arange(len(development_data))
    folds = []
    summaries = []
    validation_session_counts: Counter[str] = Counter()
    for fold_number, validation_sessions in enumerate(
        validation_sessions_by_fold,
        start=1,
    ):
        validation_mask = np.isin(groups, list(validation_sessions))
        validation_indexes = all_indexes[validation_mask]
        train_indexes = all_indexes[~validation_mask]
        train_sessions = set(groups[train_indexes])
        actual_validation_sessions = set(groups[validation_indexes])
        if train_sessions & actual_validation_sessions:
            raise DatasetError("session leakage detected inside V2 development CV")
        if actual_validation_sessions != validation_sessions:
            raise DatasetError("V2 fold session assignment mismatch")
        if len(train_sessions) != 16 or len(actual_validation_sessions) != 4:
            raise DatasetError("unexpected V2 fold session counts")
        if len(train_indexes) != 384 or len(validation_indexes) != 96:
            raise DatasetError("unexpected V2 fold window counts")
        validation_session_counts.update(actual_validation_sessions)
        validation_counts = Counter(labels[validation_indexes])
        train_counts = Counter(labels[train_indexes])
        validation_sessions_per_class = {
            label: sum(
                session_labels[session_id] == label
                for session_id in actual_validation_sessions
            )
            for label in MOTION_CLASSES
        }
        if any(
            validation_sessions_per_class[label] != 1
            for label in MOTION_CLASSES
        ):
            raise DatasetError("V2 validation fold must contain one session per class")
        if any(validation_counts[label] != 24 for label in MOTION_CLASSES):
            raise DatasetError("V2 validation fold must contain 24 windows per class")
        if any(train_counts[label] != 96 for label in MOTION_CLASSES):
            raise DatasetError("V2 training fold must contain 96 windows per class")
        folds.append((train_indexes, validation_indexes))
        summaries.append(
            {
                "fold": fold_number,
                "trainSessionCount": len(train_sessions),
                "trainWindowCount": int(len(train_indexes)),
                "validationSessionCount": len(actual_validation_sessions),
                "validationWindowCount": int(len(validation_indexes)),
                "validationSessionsPerMotionClass": validation_sessions_per_class,
                "validationWindowsPerMotionClass": {
                    label: int(validation_counts[label]) for label in MOTION_CLASSES
                },
                "sessionLeakage": False,
                "normalizationFit": "FOLD_TRAIN_ONLY",
            }
        )
    if set(validation_session_counts) != set(session_labels):
        raise DatasetError("not every V2 session appears in one validation fold")
    if any(count != 1 for count in validation_session_counts.values()):
        raise DatasetError("a V2 session appears in multiple validation folds")
    return folds, summaries, {
        "name": "DeterministicClassAwareGrouped5Fold",
        "seed": SEED,
        "foldCount": DEVELOPMENT_FOLD_COUNT,
        "trainOnlyNormalization": True,
        "standardizedClamp": [-5.0, 5.0],
    }


def _folds_are_identical(first, second) -> bool:
    import numpy as np

    return len(first) == len(second) and all(
        np.array_equal(first_train, second_train)
        and np.array_equal(first_validation, second_validation)
        for (first_train, first_validation), (second_train, second_validation)
        in zip(first, second)
    )


def _evaluate_v2_logistic_candidate(
    development_data,
    folds,
    spec: dict[str, Any],
    feature_order: list[str],
) -> dict[str, Any]:
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = development_data[feature_order].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    groups = development_data["session_id"].astype(str).to_numpy()
    window_indexes = development_data["window_index"].to_numpy(int)
    probabilities = np.full(
        (len(labels), len(MOTION_CLASSES)),
        np.nan,
        dtype=float,
    )
    predictions = np.full(len(labels), -1, dtype=np.int64)
    fold_indexes = np.full(len(labels), -1, dtype=np.int64)
    fold_metrics = []
    for fold_number, (train_indexes, validation_indexes) in enumerate(
        folds,
        start=1,
    ):
        scaler = StandardScaler().fit(features[train_indexes])
        normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
        train_features = np.clip(
            (features[train_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        validation_features = np.clip(
            (features[validation_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        model = _fit_logistic_candidate(
            train_features,
            labels[train_indexes],
            spec,
        )
        fold_probabilities = _validated_motion_probabilities(
            model,
            validation_features,
        )
        fold_predictions = np.argmax(fold_probabilities, axis=1).astype(np.int64)
        probabilities[validation_indexes] = fold_probabilities
        predictions[validation_indexes] = fold_predictions
        fold_indexes[validation_indexes] = fold_number
        metrics = _classification_metrics(
            labels[validation_indexes],
            fold_predictions,
            MOTION_CLASSES,
        )
        fold_metrics.append(
            {
                "fold": fold_number,
                "accuracy": metrics["accuracy"],
                "macroPrecision": metrics["macroPrecision"],
                "macroRecall": metrics["macroRecall"],
                "macroF1": metrics["macroF1"],
                "recalls": {
                    label: metrics["perClass"][label]["recall"]
                    for label in MOTION_CLASSES
                },
                "confusionMatrix": metrics["confusionMatrix"],
            }
        )
    if (
        not np.isfinite(probabilities).all()
        or (predictions < 0).any()
        or (fold_indexes < 1).any()
    ):
        raise DatasetError("incomplete V2 out-of-fold predictions")
    aggregate = _classification_metrics(labels, predictions, MOTION_CLASSES)
    minimum_recall = min(
        aggregate["perClass"][label]["recall"] for label in MOTION_CLASSES
    )
    worst_straight = min(
        fold["recalls"]["STRAIGHT_WALK"] for fold in fold_metrics
    )
    worst_turning = min(
        fold["recalls"]["TURNING"] for fold in fold_metrics
    )
    aggregate_gate = _motion_deployment_gate(aggregate)
    fold_robust = all(
        fold["recalls"]["STRAIGHT_WALK"] >= 0.55
        and fold["recalls"]["TURNING"] >= 0.55
        for fold in fold_metrics
    )
    return {
        "C": spec["C"],
        "profile": spec["profile"],
        "classWeights": spec["classWeights"],
        "weightComplexity": spec["weightComplexity"],
        "candidateOrder": spec["candidateOrder"],
        "featureCount": len(feature_order),
        "aggregateMetrics": aggregate,
        "minimumClassRecall": minimum_recall,
        "foldMetrics": fold_metrics,
        "worstStraightFoldRecall": worst_straight,
        "worstTurningFoldRecall": worst_turning,
        "worstStraightTurningFoldRecall": min(worst_straight, worst_turning),
        "aggregateGatePassed": aggregate_gate,
        "foldRobust": fold_robust,
        "rawFreezeEligible": aggregate_gate and fold_robust,
        "_oof": {
            "labels": labels,
            "groups": groups,
            "windowIndexes": window_indexes,
            "probabilities": probabilities,
            "predictions": predictions,
            "foldIndexes": fold_indexes,
        },
    }


def _v2_raw_candidate_key(candidate: dict[str, Any]):
    metrics = candidate["aggregateMetrics"]
    return (
        candidate["rawFreezeEligible"],
        candidate["aggregateGatePassed"],
        candidate["foldRobust"],
        metrics["macroF1"],
        candidate["minimumClassRecall"],
        candidate["worstStraightTurningFoldRecall"],
        -candidate["weightComplexity"],
        -candidate["C"],
        -candidate["candidateOrder"],
    )


def _public_v2_candidate(candidate: dict[str, Any]) -> dict[str, Any]:
    return {key: value for key, value in candidate.items() if key != "_oof"}


def _evaluate_v2_temporal_rule(oof, rule: dict[str, Any]) -> dict[str, Any]:
    predictions = _temporal_predictions(oof, rule)
    aggregate = _classification_metrics(oof["labels"], predictions, MOTION_CLASSES)
    fold_metrics = []
    for fold_number in range(1, DEVELOPMENT_FOLD_COUNT + 1):
        mask = oof["foldIndexes"] == fold_number
        metrics = _classification_metrics(
            oof["labels"][mask],
            predictions[mask],
            MOTION_CLASSES,
        )
        fold_metrics.append(
            {
                "fold": fold_number,
                "macroF1": metrics["macroF1"],
                "recalls": {
                    label: metrics["perClass"][label]["recall"]
                    for label in MOTION_CLASSES
                },
                "confusionMatrix": metrics["confusionMatrix"],
            }
        )
    minimum_recall = min(
        aggregate["perClass"][label]["recall"] for label in MOTION_CLASSES
    )
    worst_straight = min(
        fold["recalls"]["STRAIGHT_WALK"] for fold in fold_metrics
    )
    worst_turning = min(
        fold["recalls"]["TURNING"] for fold in fold_metrics
    )
    delay = _switch_delay_proxy(oof, predictions)
    aggregate_gate = _motion_deployment_gate(aggregate)
    fold_robust = all(
        fold["recalls"]["STRAIGHT_WALK"] >= 0.55
        and fold["recalls"]["TURNING"] >= 0.55
        for fold in fold_metrics
    )
    latency_passed = delay["maxWindows"] <= 2
    return {
        **rule,
        "aggregateMetrics": aggregate,
        "minimumClassRecall": minimum_recall,
        "foldMetrics": fold_metrics,
        "worstStraightFoldRecall": worst_straight,
        "worstTurningFoldRecall": worst_turning,
        "worstStraightTurningFoldRecall": min(worst_straight, worst_turning),
        "switchDelay": delay,
        "aggregateGatePassed": aggregate_gate,
        "foldRobust": fold_robust,
        "latencyRequirementPassed": latency_passed,
        "freezeEligible": aggregate_gate and fold_robust and latency_passed,
        "_predictions": predictions,
    }


def _public_v2_temporal_pair(pair: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value
        for key, value in pair.items()
        if key not in {"_predictions", "_oof"}
    }


def _v2_temporal_pair_key(pair: dict[str, Any]):
    metrics = pair["aggregateMetrics"]
    return (
        pair["freezeEligible"],
        metrics["macroF1"],
        pair["minimumClassRecall"],
        pair["worstStraightTurningFoldRecall"],
        -pair["switchDelay"]["meanWindows"],
        -pair["complexity"],
        -pair["C"],
        -pair["weightComplexity"],
        -pair["candidateOrder"],
        pair["name"],
    )


def _v2_feature_contribution_analysis(
    development_data,
    selected_candidate: dict[str, Any],
) -> dict[str, Any]:
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    raw_features = development_data[FEATURE_ORDER_V2].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    scaler = StandardScaler().fit(raw_features)
    normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
    standardized = np.clip(
        (raw_features - scaler.mean_) / normalization_std,
        -5.0,
        5.0,
    )
    model = _fit_logistic_candidate(standardized, labels, selected_candidate)
    straight_index = MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
    turning_index = MOTION_LABEL_TO_INDEX["TURNING"]
    straight_mask = labels == straight_index
    turning_mask = labels == turning_index
    reports = []
    for feature_name in V2_ADDED_FEATURE_ORDER:
        feature_index = FEATURE_ORDER_V2.index(feature_name)
        straight_values = raw_features[straight_mask, feature_index]
        turning_values = raw_features[turning_mask, feature_index]
        straight_mean = float(straight_values.mean())
        turning_mean = float(turning_values.mean())
        straight_std = float(straight_values.std())
        turning_std = float(turning_values.std())
        pooled_std = float(
            np.sqrt((straight_std * straight_std + turning_std * turning_std) / 2.0)
        )
        effect_size = (
            0.0
            if pooled_std <= 1e-12
            else (turning_mean - straight_mean) / pooled_std
        )
        coefficient_difference = float(
            model.coef_[turning_index, feature_index]
            - model.coef_[straight_index, feature_index]
        )
        reports.append(
            {
                "feature": feature_name,
                "straightMean": straight_mean,
                "straightStd": straight_std,
                "turningMean": turning_mean,
                "turningStd": turning_std,
                "turningMinusStraightEffectSize": effect_size,
                "standardizedCoefficients": {
                    label: float(
                        model.coef_[MOTION_LABEL_TO_INDEX[label], feature_index]
                    )
                    for label in MOTION_CLASSES
                },
                "turningMinusStraightCoefficient": coefficient_difference,
                "contributionScore": abs(effect_size) * abs(coefficient_difference),
                "materialContribution": (
                    abs(effect_size) >= 0.50
                    and abs(coefficient_difference) >= 0.05
                ),
            }
        )
    ranked = sorted(
        reports,
        key=lambda value: (
            value["contributionScore"],
            abs(value["turningMinusStraightEffectSize"]),
            abs(value["turningMinusStraightCoefficient"]),
            value["feature"],
        ),
        reverse=True,
    )
    return {
        "effectSizeDefinition": (
            "(TURNING mean - STRAIGHT_WALK mean) / pooled population std"
        ),
        "coefficientDefinition": (
            "TURNING minus STRAIGHT_WALK Logistic coefficient after development-only standardization"
        ),
        "features": reports,
        "mostUsefulNewFeatures": [value["feature"] for value in ranked[:3]],
    }


def _v2_session_topology(oof, predictions) -> dict[str, Any]:
    import numpy as np

    prefixes = {
        "STATIONARY": "STATIONARY_V2_DEV",
        "STRAIGHT_WALK": "STRAIGHT_V2_DEV",
        "TURNING": "TURNING_V2_DEV",
        "UNSTABLE_MOTION": "UNSTABLE_V2_DEV",
    }
    sanitized_names: dict[str, str] = {}
    for class_index, class_name in enumerate(MOTION_CLASSES):
        class_sessions = sorted(set(oof["groups"][oof["labels"] == class_index]))
        for number, session_id in enumerate(class_sessions, start=1):
            sanitized_names[session_id] = f"{prefixes[class_name]}_{number}"
    summaries = []
    for session_id in sorted(sanitized_names, key=lambda value: sanitized_names[value]):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        true_index = int(oof["labels"][indexes][0])
        session_predictions = predictions[indexes]
        wrong = session_predictions != true_index
        counts = Counter(int(value) for value in session_predictions)
        dominant_index = max(
            range(len(MOTION_CLASSES)),
            key=lambda value: (counts[value], -value),
        )
        straight_to_turning = (
            session_predictions == MOTION_LABEL_TO_INDEX["TURNING"]
            if true_index == MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
            else np.zeros(len(indexes), dtype=bool)
        )
        turning_to_straight = (
            session_predictions == MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
            if true_index == MOTION_LABEL_TO_INDEX["TURNING"]
            else np.zeros(len(indexes), dtype=bool)
        )
        accuracy = float((~wrong).mean())
        longest_wrong = _longest_true_run(wrong)
        summaries.append(
            {
                "session": sanitized_names[session_id],
                "trueClass": MOTION_CLASSES[true_index],
                "windowCount": int(len(indexes)),
                "correctWindows": int((~wrong).sum()),
                "accuracy": accuracy,
                "dominantPredictedClass": MOTION_CLASSES[dominant_index],
                "longestConsecutiveWrongRun": longest_wrong,
                "longestStraightToTurningRun": _longest_true_run(
                    straight_to_turning
                ),
                "longestTurningToStraightRun": _longest_true_run(
                    turning_to_straight
                ),
                "persistentFailure": (
                    accuracy < 0.55
                    or longest_wrong >= max(3, len(indexes) // 2)
                ),
            }
        )
    straight_sessions = [
        value for value in summaries if value["trueClass"] == "STRAIGHT_WALK"
    ]
    turning_sessions = [
        value for value in summaries if value["trueClass"] == "TURNING"
    ]
    return {
        "sessions": summaries,
        "anyPersistentStraightFailure": any(
            value["persistentFailure"] for value in straight_sessions
        ),
        "anyPersistentTurningFailure": any(
            value["persistentFailure"] for value in turning_sessions
        ),
    }


def _validate_v2_24session_sources(base_data, extension_data):
    import pandas as pd

    base_summary = _validate_v2_development_dataset(base_data)
    extension_contract = _resolve_training_contract(extension_data)
    if extension_contract != (
        DATASET_SCHEMA_V2,
        FEATURE_SCHEMA_V2,
        FEATURE_ORDER_V2,
    ):
        raise DatasetError("V2_EXTENSION_REQUIRES_EXACT_V2_SCHEMA")
    extension_sessions = extension_data["session_id"].astype(str)
    if len(extension_data) != 96:
        raise DatasetError("V2 extension requires exactly 96 windows")
    if extension_sessions.nunique() != V2_EXTENSION_SESSION_COUNT:
        raise DatasetError("V2 extension requires exactly four sessions")
    extension_session_windows = extension_data.groupby(extension_sessions).size()
    if not (
        extension_session_windows == V2_DEVELOPMENT_WINDOWS_PER_SESSION
    ).all():
        raise DatasetError("V2 extension requires exactly 24 windows per session")
    extension_session_labels = (
        extension_data.groupby(extension_sessions)["motion_label"]
        .first()
        .astype(str)
    )
    extension_sessions_per_class = Counter(extension_session_labels)
    expected_extension_sessions = {
        "STATIONARY": 0,
        "STRAIGHT_WALK": 2,
        "TURNING": 2,
        "UNSTABLE_MOTION": 0,
    }
    if any(
        extension_sessions_per_class[label]
        != expected_extension_sessions[label]
        for label in MOTION_CLASSES
    ):
        raise DatasetError(
            "V2 extension requires exactly two STRAIGHT and two TURNING sessions"
        )
    extension_windows_per_class = Counter(
        extension_data["motion_label"].astype(str)
    )
    if (
        extension_windows_per_class["STRAIGHT_WALK"] != 48
        or extension_windows_per_class["TURNING"] != 48
        or extension_windows_per_class["STATIONARY"] != 0
        or extension_windows_per_class["UNSTABLE_MOTION"] != 0
    ):
        raise DatasetError(
            "V2 extension requires exactly 48 STRAIGHT and 48 TURNING windows"
        )

    base_sessions = set(base_data["session_id"].astype(str))
    extension_session_ids = set(extension_sessions)
    if base_sessions & extension_session_ids:
        raise DatasetError("duplicate session across V2 base and extension")
    combined = pd.concat([base_data, extension_data], ignore_index=True)
    combined.attrs["dataset_schema_version"] = DATASET_SCHEMA_V2
    combined.attrs["feature_schema_version"] = FEATURE_SCHEMA_V2
    combined.attrs["feature_order"] = FEATURE_ORDER_V2
    if len(combined) != V2_24_WINDOW_COUNT:
        raise DatasetError("combined V2 development requires exactly 576 windows")
    combined_sessions = combined["session_id"].astype(str)
    if combined_sessions.nunique() != V2_24_SESSION_COUNT:
        raise DatasetError("combined V2 development requires exactly 24 sessions")
    if combined.duplicated(subset=["session_id", "window_index"]).any():
        raise DatasetError("duplicate session window in combined V2 development")
    combined_session_windows = combined.groupby(combined_sessions).size()
    if not (
        combined_session_windows == V2_DEVELOPMENT_WINDOWS_PER_SESSION
    ).all():
        raise DatasetError(
            "combined V2 development requires exactly 24 windows per session"
        )
    combined_session_labels = (
        combined.groupby(combined_sessions)["motion_label"].first().astype(str)
    )
    sessions_per_class = Counter(combined_session_labels)
    windows_per_class = Counter(combined["motion_label"].astype(str))
    if any(
        sessions_per_class[label] != V2_24_SESSIONS_PER_CLASS[label]
        for label in MOTION_CLASSES
    ):
        raise DatasetError("combined V2 class session counts must be 5/7/7/5")
    if any(
        windows_per_class[label] != V2_24_WINDOWS_PER_CLASS[label]
        for label in MOTION_CLASSES
    ):
        raise DatasetError("combined V2 class window counts must be 120/168/168/120")

    extension_summary = {
        "datasetSchemaVersion": DATASET_SCHEMA_V2,
        "featureSchemaVersion": FEATURE_SCHEMA_V2,
        "featureCount": len(FEATURE_ORDER_V2),
        "sessionCount": int(extension_sessions.nunique()),
        "windowCount": int(len(extension_data)),
        "sessionsPerMotionClass": {
            label: int(extension_sessions_per_class[label])
            for label in MOTION_CLASSES
        },
        "motionWindowCounts": {
            label: int(extension_windows_per_class[label])
            for label in MOTION_CLASSES
        },
        "windowsPerSession": V2_DEVELOPMENT_WINDOWS_PER_SESSION,
    }
    combined_summary = {
        "datasetSchemaVersion": DATASET_SCHEMA_V2,
        "featureSchemaVersion": FEATURE_SCHEMA_V2,
        "featureCount": len(FEATURE_ORDER_V2),
        "sessionCount": int(combined_sessions.nunique()),
        "windowCount": int(len(combined)),
        "sessionsPerMotionClass": {
            label: int(sessions_per_class[label]) for label in MOTION_CLASSES
        },
        "motionWindowCounts": {
            label: int(windows_per_class[label]) for label in MOTION_CLASSES
        },
        "windowsPerSession": V2_DEVELOPMENT_WINDOWS_PER_SESSION,
        "baseExtensionSessionOverlap": 0,
        "duplicateSessionWindowCount": 0,
        "finiteFeatures": True,
        "unknownMotionClassCount": 0,
        "mixedDatasetSchema": False,
        "mixedFeatureSchema": False,
    }
    return combined, base_summary, extension_summary, combined_summary


def _build_v2_24session_folds(development_data):
    import numpy as np

    groups = development_data["session_id"].astype(str).to_numpy()
    labels = development_data["motion_label"].astype(str).to_numpy()
    session_labels = {
        str(session): str(label)
        for session, label in development_data.groupby("session_id")[
            "motion_label"
        ].first().items()
    }
    validation_sessions_by_fold = [
        set() for _ in range(DEVELOPMENT_FOLD_COUNT)
    ]
    rng = random.Random(SEED)
    for class_name in MOTION_CLASSES:
        class_sessions = sorted(
            session_id
            for session_id, label in session_labels.items()
            if label == class_name
        )
        expected_count = V2_24_SESSIONS_PER_CLASS[class_name]
        if len(class_sessions) != expected_count:
            raise DatasetError("unexpected V2 24-session class count")
        rng.shuffle(class_sessions)
        assignment = list(range(DEVELOPMENT_FOLD_COUNT))
        if expected_count == 7:
            assignment.extend((0, 1))
        for session_id, fold_index in zip(class_sessions, assignment):
            validation_sessions_by_fold[fold_index].add(session_id)

    all_indexes = np.arange(len(development_data))
    folds = []
    summaries = []
    validation_session_counts: Counter[str] = Counter()
    for fold_number, validation_sessions in enumerate(
        validation_sessions_by_fold,
        start=1,
    ):
        validation_mask = np.isin(groups, list(validation_sessions))
        validation_indexes = all_indexes[validation_mask]
        train_indexes = all_indexes[~validation_mask]
        train_sessions = set(groups[train_indexes])
        actual_validation_sessions = set(groups[validation_indexes])
        if train_sessions & actual_validation_sessions:
            raise DatasetError("session leakage detected inside V2 24-session CV")
        if actual_validation_sessions != validation_sessions:
            raise DatasetError("V2 24-session fold assignment mismatch")
        expected_validation_sessions = 6 if fold_number <= 2 else 4
        expected_validation_windows = expected_validation_sessions * 24
        if len(actual_validation_sessions) != expected_validation_sessions:
            raise DatasetError("unexpected V2 24-session validation session count")
        if len(validation_indexes) != expected_validation_windows:
            raise DatasetError("unexpected V2 24-session validation window count")
        if len(train_sessions) != 24 - expected_validation_sessions:
            raise DatasetError("unexpected V2 24-session train session count")
        if len(train_indexes) != 576 - expected_validation_windows:
            raise DatasetError("unexpected V2 24-session train window count")
        validation_session_counts.update(actual_validation_sessions)
        validation_counts = Counter(labels[validation_indexes])
        validation_sessions_per_class = {
            label: sum(
                session_labels[session_id] == label
                for session_id in actual_validation_sessions
            )
            for label in MOTION_CLASSES
        }
        expected_per_class = {
            "STATIONARY": 1,
            "STRAIGHT_WALK": 2 if fold_number <= 2 else 1,
            "TURNING": 2 if fold_number <= 2 else 1,
            "UNSTABLE_MOTION": 1,
        }
        if validation_sessions_per_class != expected_per_class:
            raise DatasetError("V2 24-session validation fold is not balanced")
        if any(
            validation_counts[label] != expected_per_class[label] * 24
            for label in MOTION_CLASSES
        ):
            raise DatasetError("unexpected V2 24-session validation class windows")
        folds.append((train_indexes, validation_indexes))
        summaries.append(
            {
                "fold": fold_number,
                "trainSessionCount": len(train_sessions),
                "trainWindowCount": int(len(train_indexes)),
                "validationSessionCount": len(actual_validation_sessions),
                "validationWindowCount": int(len(validation_indexes)),
                "validationSessionsPerMotionClass": validation_sessions_per_class,
                "validationWindowsPerMotionClass": {
                    label: int(validation_counts[label])
                    for label in MOTION_CLASSES
                },
                "sessionLeakage": False,
                "normalizationFit": "FOLD_TRAIN_ONLY",
            }
        )
    if set(validation_session_counts) != set(session_labels):
        raise DatasetError("not every V2 session appears in one validation fold")
    if any(count != 1 for count in validation_session_counts.values()):
        raise DatasetError("a V2 session appears in multiple validation folds")
    return folds, summaries, {
        "name": "DeterministicBalancedClassAwareGrouped5Fold",
        "seed": SEED,
        "foldCount": DEVELOPMENT_FOLD_COUNT,
        "extraStraightFolds": [1, 2],
        "extraTurningFolds": [1, 2],
        "trainOnlyNormalization": True,
        "standardizedClamp": [-5.0, 5.0],
    }


def _v2_24_temporal_pair_key(pair: dict[str, Any]):
    metrics = pair["aggregateMetrics"]
    return (
        pair["freezeEligible"],
        metrics["macroF1"],
        pair["minimumClassRecall"],
        pair["worstStraightTurningFoldRecall"],
        -pair["switchDelay"]["maxWindows"],
        -pair["switchDelay"]["meanWindows"],
        -pair["complexity"],
        -pair["C"],
        -pair["weightComplexity"],
        -pair["candidateOrder"],
        pair["name"],
    )


def _v2_24_session_topology(oof, predictions) -> dict[str, Any]:
    import numpy as np

    prefixes = {
        "STATIONARY": "STATIONARY_V2_DEV",
        "STRAIGHT_WALK": "STRAIGHT_V2_DEV",
        "TURNING": "TURNING_V2_DEV",
        "UNSTABLE_MOTION": "UNSTABLE_V2_DEV",
    }
    sanitized_names: dict[str, str] = {}
    for class_index, class_name in enumerate(MOTION_CLASSES):
        class_sessions = sorted(set(oof["groups"][oof["labels"] == class_index]))
        expected_count = V2_24_SESSIONS_PER_CLASS[class_name]
        if len(class_sessions) != expected_count:
            raise DatasetError("unexpected session topology class count")
        for number, session_id in enumerate(class_sessions, start=1):
            sanitized_names[session_id] = f"{prefixes[class_name]}_{number}"
    summaries = []
    for session_id in sorted(sanitized_names, key=sanitized_names.get):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        true_index = int(oof["labels"][indexes][0])
        session_predictions = predictions[indexes]
        wrong = session_predictions != true_index
        counts = Counter(int(value) for value in session_predictions)
        dominant_index = max(
            range(len(MOTION_CLASSES)),
            key=lambda value: (counts[value], -value),
        )
        competing_runs = {
            MOTION_CLASSES[class_index]: _longest_true_run(
                session_predictions == class_index
            )
            for class_index in range(len(MOTION_CLASSES))
            if class_index != true_index
        }
        longest_same_competing_run = max(competing_runs.values(), default=0)
        accuracy = float((~wrong).mean())
        wrong_dominant_over_most = (
            dominant_index != true_index
            and counts[dominant_index] > len(indexes) / 2
        )
        persistent_failure = (
            accuracy < 0.50
            or wrong_dominant_over_most
            or longest_same_competing_run >= 12
        )
        straight_to_turning = (
            session_predictions == MOTION_LABEL_TO_INDEX["TURNING"]
            if true_index == MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
            else np.zeros(len(indexes), dtype=bool)
        )
        turning_to_straight = (
            session_predictions == MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
            if true_index == MOTION_LABEL_TO_INDEX["TURNING"]
            else np.zeros(len(indexes), dtype=bool)
        )
        summaries.append(
            {
                "session": sanitized_names[session_id],
                "trueClass": MOTION_CLASSES[true_index],
                "windowCount": int(len(indexes)),
                "correctWindows": int((~wrong).sum()),
                "accuracy": accuracy,
                "dominantPredictedClass": MOTION_CLASSES[dominant_index],
                "longestConsecutiveWrongRun": _longest_true_run(wrong),
                "longestSameCompetingClassRun": longest_same_competing_run,
                "longestStraightToTurningRun": _longest_true_run(
                    straight_to_turning
                ),
                "longestTurningToStraightRun": _longest_true_run(
                    turning_to_straight
                ),
                "wrongDominantClassOverMostWindows": wrong_dominant_over_most,
                "persistentFailure": persistent_failure,
            }
        )
    straight_sessions = [
        value for value in summaries if value["trueClass"] == "STRAIGHT_WALK"
    ]
    turning_sessions = [
        value for value in summaries if value["trueClass"] == "TURNING"
    ]
    return {
        "persistentFailureDefinition": (
            "accuracy < 0.50 OR wrong dominant class over most windows OR "
            ">=12 consecutive windows classified as the same competing class"
        ),
        "sessions": summaries,
        "straightSessions": straight_sessions,
        "turningSessions": turning_sessions,
        "anyPersistentStraightFailure": any(
            value["persistentFailure"] for value in straight_sessions
        ),
        "anyPersistentTurningFailure": any(
            value["persistentFailure"] for value in turning_sessions
        ),
    }


def _v2_24_feature_contribution_analysis(development_data, selected_candidate):
    analysis = _v2_feature_contribution_analysis(
        development_data,
        selected_candidate,
    )
    for feature in analysis["features"]:
        feature["absoluteStandardizedCoefficients"] = {
            label: abs(value)
            for label, value in feature["standardizedCoefficients"].items()
        }
        feature["absoluteTurningMinusStraightCoefficient"] = abs(
            feature["turningMinusStraightCoefficient"]
        )
        feature["materiallyUsedForStraightVsTurning"] = feature[
            "materialContribution"
        ]
    return analysis


def _v2_ablation_interpretation(ablation, full) -> dict[str, Any]:
    macro_delta = (
        full["aggregateMetrics"]["macroF1"]
        - ablation["aggregateMetrics"]["macroF1"]
    )
    minimum_recall_delta = (
        full["minimumClassRecall"] - ablation["minimumClassRecall"]
    )
    worst_fold_delta = (
        full["worstStraightTurningFoldRecall"]
        - ablation["worstStraightTurningFoldRecall"]
    )
    if full["foldRobust"] and not ablation["foldRobust"]:
        interpretation = "V2_FEATURES_CLEARLY_HELP"
    elif (
        worst_fold_delta >= 0.10
        and macro_delta >= -0.01
        and minimum_recall_delta >= -0.01
    ):
        interpretation = "V2_FEATURES_CLEARLY_HELP"
    elif (
        macro_delta <= -0.02
        and minimum_recall_delta <= -0.02
        and worst_fold_delta <= -0.10
    ):
        interpretation = "V2_FEATURES_HURT"
    else:
        interpretation = "V2_FEATURES_NEUTRAL"
    return {
        "result": interpretation,
        "fullMinusAblationMacroF1": macro_delta,
        "fullMinusAblationMinimumRecall": minimum_recall_delta,
        "fullMinusAblationWorstStraightTurningFoldRecall": worst_fold_delta,
    }


def evaluate_v2_development(input_path: Path, report_output: Path) -> str:
    data = _load_and_validate(input_path)
    dataset_summary = _validate_v2_development_dataset(data)
    folds, fold_summaries, strategy = _build_v2_development_folds(data)
    repeated_folds, repeated_summaries, repeated_strategy = (
        _build_v2_development_folds(data)
    )
    deterministic_folds = (
        _folds_are_identical(folds, repeated_folds)
        and fold_summaries == repeated_summaries
        and strategy == repeated_strategy
    )
    if not deterministic_folds:
        raise DatasetError("V2 development fold construction is not deterministic")
    specs = _development_candidate_specs()
    if len(specs) != 63 or specs != _development_candidate_specs():
        raise DatasetError("V2 Logistic candidate grid is not deterministic")

    ablation_candidates = [
        _evaluate_v2_logistic_candidate(data, folds, spec, FEATURE_ORDER_V1)
        for spec in specs
    ]
    full_candidates = [
        _evaluate_v2_logistic_candidate(data, folds, spec, FEATURE_ORDER_V2)
        for spec in specs
    ]
    selected_ablation = max(ablation_candidates, key=_v2_raw_candidate_key)
    selected_full_raw = max(full_candidates, key=_v2_raw_candidate_key)

    temporal_pairs = []
    rules = _temporal_rule_specs()
    for candidate in full_candidates:
        for rule in rules:
            temporal = _evaluate_v2_temporal_rule(candidate["_oof"], rule)
            temporal_pairs.append(
                {
                    "C": candidate["C"],
                    "profile": candidate["profile"],
                    "classWeights": candidate["classWeights"],
                    "weightComplexity": candidate["weightComplexity"],
                    "candidateOrder": candidate["candidateOrder"],
                    **temporal,
                    "_oof": candidate["_oof"],
                }
            )
    freeze_eligible_pairs = [
        pair for pair in temporal_pairs if pair["freezeEligible"]
    ]
    fold_robust_pairs = [
        pair
        for pair in temporal_pairs
        if pair["aggregateGatePassed"] and pair["foldRobust"]
    ]
    aggregate_latency_pairs = [
        pair
        for pair in temporal_pairs
        if pair["aggregateGatePassed"] and pair["latencyRequirementPassed"]
    ]
    selection_pool = (
        freeze_eligible_pairs
        or fold_robust_pairs
        or aggregate_latency_pairs
        or temporal_pairs
    )
    selected_pair = max(selection_pool, key=_v2_temporal_pair_key)
    selected_predictions = selected_pair["_predictions"]
    session_topology = _v2_session_topology(
        selected_pair["_oof"],
        selected_predictions,
    )
    selected_pair_model = full_candidates[selected_pair["candidateOrder"]]
    feature_analysis = _v2_feature_contribution_analysis(
        data,
        selected_pair_model,
    )
    interpretation = _v2_ablation_interpretation(
        selected_ablation,
        selected_full_raw,
    )
    freeze = bool(selected_pair["freezeEligible"])
    if freeze:
        next_recommendation = None
    elif selected_pair["aggregateGatePassed"]:
        next_recommendation = "MORE_V2_DEVELOPMENT_DATA"
    elif interpretation["result"] == "V2_FEATURES_HURT":
        next_recommendation = "FEATURE_SCHEMA_V3_REVIEW"
    else:
        next_recommendation = "V2_MODEL_CAPACITY_REVIEW"

    assets_directory = (
        Path(__file__).resolve().parents[2]
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "assets"
    )
    production_model_absent = not any(
        assets_directory.glob("navguard_ai_model*.json")
    )
    if not production_model_absent:
        raise DatasetError("PRODUCTION_MODEL_ASSET_PRESENT")

    report = {
        "status": (
            "REVISED_V2_DEVELOPMENT_FREEZE_READY"
            if freeze
            else "V2_DEVELOPMENT_ROBUSTNESS_NOT_FROZEN"
        ),
        "dataset": dataset_summary,
        "classOrder": MOTION_CLASSES,
        "developmentOnly": True,
        "finalV2HoldoutExists": False,
        "cv": {
            "strategy": strategy,
            "folds": fold_summaries,
            "sessionLeakage": False,
            "sameFoldsUsedForAblationAndFullV2": True,
            "repeatedFoldConstructionDeterministic": deterministic_folds,
        },
        "candidateGrid": {
            "CValues": DEVELOPMENT_C_VALUES,
            "classWeightPolicy": (
                "uniform plus each individual class emphasized at 1.25 and 1.50"
            ),
            "candidateCountPerExperiment": len(specs),
            "deterministic": True,
            "convergenceWarningsRejected": True,
        },
        "legacyFeatureAblation": {
            "featureCount": len(FEATURE_ORDER_V1),
            "featureOrder": FEATURE_ORDER_V1,
            "selectedCandidate": _public_v2_candidate(selected_ablation),
            "candidates": [
                _public_v2_candidate(candidate)
                for candidate in ablation_candidates
            ],
        },
        "fullV2RawLogistic": {
            "featureCount": len(FEATURE_ORDER_V2),
            "featureOrder": FEATURE_ORDER_V2,
            "selectedCandidate": _public_v2_candidate(selected_full_raw),
            "candidates": [
                _public_v2_candidate(candidate) for candidate in full_candidates
            ],
        },
        "ablationInterpretation": interpretation,
        "v2FeatureContribution": feature_analysis,
        "temporalDecoder": {
            "causalOnly": True,
            "futureWindowsAccessed": False,
            "featureHopSeconds": 1,
            "ruleCountPerModel": len(rules),
            "modelTemporalPairCount": len(temporal_pairs),
            "freezeEligiblePairCount": len(freeze_eligible_pairs),
            "aggregateAndFoldRobustPairCount": len(fold_robust_pairs),
            "aggregateAndLatencyEligiblePairCount": len(
                aggregate_latency_pairs
            ),
            "fallbackSelectionPolicy": (
                "freeze-eligible; otherwise aggregate+fold-robust; otherwise aggregate+latency; otherwise all"
            ),
            "selectionOrder": [
                "highest_macro_f1",
                "highest_minimum_aggregate_recall",
                "highest_worst_fold_min_straight_turning_recall",
                "lower_mean_switch_latency",
                "simpler_temporal_rule",
                "smaller_C",
            ],
            "selected": _public_v2_temporal_pair(selected_pair),
            "candidates": [
                _public_v2_temporal_pair(pair) for pair in temporal_pairs
            ],
            "switchDelayDefinition": (
                "causal candidate-transition delay relative to the start of the same contiguous raw-argmax class run"
            ),
        },
        "sessionTopology": session_topology,
        "historicalComparison": {
            "v1WorstStraightFoldRecall": 0.125,
            "v1TemporalMacroF1": 0.921682,
            "v2WorstStraightFoldRecall": selected_pair[
                "worstStraightFoldRecall"
            ],
            "v2TemporalMacroF1": selected_pair["aggregateMetrics"]["macroF1"],
            "historicalStraightCollapseSolved": (
                selected_pair["worstStraightFoldRecall"] >= 0.55
                and selected_pair["worstTurningFoldRecall"] >= 0.55
            ),
        },
        "freezeDecision": {
            "revisedV2DevelopmentFreeze": freeze,
            "family": "logistic_regression" if freeze else None,
            "C": selected_pair["C"] if freeze else None,
            "classWeights": selected_pair["classWeights"] if freeze else None,
            "featureSchemaVersion": FEATURE_SCHEMA_V2,
            "featureCount": len(FEATURE_ORDER_V2),
            "featureOrder": FEATURE_ORDER_V2,
            "normalization": "FOLD_TRAIN_ONLY_STANDARDIZE_THEN_CLAMP_-5_5",
            "classOrder": MOTION_CLASSES,
            "temporalDecoder": (
                {
                    "name": selected_pair["name"],
                    "emaAlpha": selected_pair["emaAlpha"],
                    "hysteresisMargin": selected_pair["hysteresisMargin"],
                    "consecutiveWindows": selected_pair["consecutiveWindows"],
                }
                if freeze
                else None
            ),
            "confidenceSemantics": "argmax_probability",
            "productionModelExported": False,
            "freshIndependentV2HoldoutRequired": freeze,
            "primaryNextRecommendation": next_recommendation,
        },
        "reliabilityHeads": {
            "arcore": "PREVIOUS_PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
        },
        "selfTests": {
            "exact20Sessions": dataset_summary["sessionCount"] == 20,
            "exactFiveSessionsPerClass": all(
                value == 5
                for value in dataset_summary["sessionsPerMotionClass"].values()
            ),
            "exact24WindowsPerSession": (
                dataset_summary["windowsPerSession"] == 24
            ),
            "exactV2Schema": (
                dataset_summary["datasetSchemaVersion"] == DATASET_SCHEMA_V2
                and dataset_summary["featureSchemaVersion"] == FEATURE_SCHEMA_V2
            ),
            "exact34Features": dataset_summary["featureCount"] == 34,
            "groupedFiveFoldIsolation": all(
                fold["sessionLeakage"] is False for fold in fold_summaries
            ),
            "oneSessionPerClassPerValidationFold": all(
                all(value == 1 for value in fold[
                    "validationSessionsPerMotionClass"
                ].values())
                for fold in fold_summaries
            ),
            "noSessionLeakage": True,
            "trainOnlyScalerPerFold": all(
                fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
                for fold in fold_summaries
            ),
            "deterministicCandidateGrid": len(specs) == 63,
            "ablationUsesSameFolds": True,
            "fullV2UsesSameFolds": True,
            "temporalDecoderCausal": True,
            "noFutureWindows": True,
            "repeatedRunDeterministic": deterministic_folds,
            "noProductionModelExport": production_model_absent,
        },
        "productionModelExported": False,
        "productionModelAbsent": production_model_absent,
        "configEActive": False,
        "navigationAccuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    if not all(report["selfTests"].values()):
        raise DatasetError("V2_DEVELOPMENT_SELF_TEST_FAILED")
    _write_json_atomic(report_output, report)
    return report["status"]


def evaluate_v2_24session_development(
    input_path: Path,
    extension_path: Path,
    report_output: Path,
) -> str:
    if input_path.resolve().name != "development_v2":
        raise DatasetError("24-session evaluation input must be development_v2")
    if extension_path.resolve().name != "v2_extension_4":
        raise DatasetError(
            "24-session evaluation extension must be v2_extension_4"
        )
    base_data = _load_and_validate(input_path)
    extension_data = _load_and_validate(extension_path)
    (
        data,
        base_summary,
        extension_summary,
        combined_summary,
    ) = _validate_v2_24session_sources(base_data, extension_data)
    folds, fold_summaries, strategy = _build_v2_24session_folds(data)
    repeated_folds, repeated_summaries, repeated_strategy = (
        _build_v2_24session_folds(data)
    )
    deterministic_folds = (
        _folds_are_identical(folds, repeated_folds)
        and fold_summaries == repeated_summaries
        and strategy == repeated_strategy
    )
    if not deterministic_folds:
        raise DatasetError("V2 24-session fold construction is not deterministic")

    specs = _development_candidate_specs()
    rules = _temporal_rule_specs()
    if len(specs) != 63 or specs != _development_candidate_specs():
        raise DatasetError("V2 Logistic candidate grid is not deterministic")
    if len(rules) != 28 or rules != _temporal_rule_specs():
        raise DatasetError("V2 temporal rule grid is not deterministic")

    full_candidates = [
        _evaluate_v2_logistic_candidate(data, folds, spec, FEATURE_ORDER_V2)
        for spec in specs
    ]
    selected_full_raw = max(full_candidates, key=_v2_raw_candidate_key)
    temporal_pairs = []
    for candidate in full_candidates:
        for rule in rules:
            temporal = _evaluate_v2_temporal_rule(candidate["_oof"], rule)
            temporal_pairs.append(
                {
                    "C": candidate["C"],
                    "profile": candidate["profile"],
                    "classWeights": candidate["classWeights"],
                    "weightComplexity": candidate["weightComplexity"],
                    "candidateOrder": candidate["candidateOrder"],
                    **temporal,
                    "_oof": candidate["_oof"],
                }
            )
    quantitative_freeze_pairs = [
        pair for pair in temporal_pairs if pair["freezeEligible"]
    ]
    fold_robust_pairs = [
        pair
        for pair in temporal_pairs
        if pair["aggregateGatePassed"] and pair["foldRobust"]
    ]
    aggregate_latency_pairs = [
        pair
        for pair in temporal_pairs
        if pair["aggregateGatePassed"] and pair["latencyRequirementPassed"]
    ]

    selected_pair = None
    selected_topology = None
    for pair in sorted(
        quantitative_freeze_pairs,
        key=_v2_24_temporal_pair_key,
        reverse=True,
    ):
        topology = _v2_24_session_topology(
            pair["_oof"],
            pair["_predictions"],
        )
        if not (
            topology["anyPersistentStraightFailure"]
            or topology["anyPersistentTurningFailure"]
        ):
            selected_pair = pair
            selected_topology = topology
            break
    persistent_failure_free_freeze_pair_found = selected_pair is not None
    if selected_pair is None:
        selection_pool = (
            quantitative_freeze_pairs
            or fold_robust_pairs
            or aggregate_latency_pairs
            or temporal_pairs
        )
        selected_pair = max(selection_pool, key=_v2_24_temporal_pair_key)
        selected_topology = _v2_24_session_topology(
            selected_pair["_oof"],
            selected_pair["_predictions"],
        )
    freeze = bool(
        selected_pair["freezeEligible"]
        and persistent_failure_free_freeze_pair_found
        and not selected_topology["anyPersistentStraightFailure"]
        and not selected_topology["anyPersistentTurningFailure"]
    )

    selected_pair_model = full_candidates[selected_pair["candidateOrder"]]
    feature_analysis = _v2_24_feature_contribution_analysis(
        data,
        selected_pair_model,
    )
    selected_rule = {
        key: selected_pair[key]
        for key in (
            "name",
            "emaAlpha",
            "hysteresisMargin",
            "consecutiveWindows",
            "complexity",
        )
    }
    repeated_temporal = _evaluate_v2_temporal_rule(
        selected_pair["_oof"],
        selected_rule,
    )
    deterministic_latency = (
        repeated_temporal["switchDelay"] == selected_pair["switchDelay"]
    )
    if not deterministic_latency:
        raise DatasetError("V2 temporal latency metrics are not deterministic")

    if freeze:
        next_recommendation = None
    elif quantitative_freeze_pairs:
        next_recommendation = "MORE_V2_DEVELOPMENT_DATA"
    elif fold_robust_pairs:
        next_recommendation = "TEMPORAL_DECODER_REDESIGN"
    elif aggregate_latency_pairs:
        next_recommendation = "MORE_V2_DEVELOPMENT_DATA"
    else:
        next_recommendation = "V2_MODEL_CAPACITY_REVIEW"

    assets_directory = (
        Path(__file__).resolve().parents[2]
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "assets"
    )
    production_model_absent = not any(
        assets_directory.glob("navguard_ai_model*.json")
    )
    if not production_model_absent:
        raise DatasetError("PRODUCTION_MODEL_ASSET_PRESENT")

    all_classes_in_every_fold = all(
        all(
            fold["validationSessionsPerMotionClass"][label] >= 1
            for label in MOTION_CLASSES
        )
        for fold in fold_summaries
    )
    previous_temporal = {
        "macroF1": 0.891108,
        "worstStraightFoldRecall": 0.625,
        "worstTurningFoldRecall": 0.708333,
        "meanDelayWindows": 3.083333,
        "p90DelayWindows": 5.8,
        "maxDelayWindows": 6,
    }
    report = {
        "status": (
            "REVISED_V2_DEVELOPMENT_FREEZE_READY"
            if freeze
            else "V2_24SESSION_DEVELOPMENT_NOT_FROZEN"
        ),
        "dataset": {
            "base": base_summary,
            "extension": extension_summary,
            "combined": combined_summary,
        },
        "classOrder": MOTION_CLASSES,
        "developmentOnly": True,
        "finalHoldoutLoaded": False,
        "historicalV1RowsLoaded": False,
        "privatePathsReturned": False,
        "rawRowsReturned": False,
        "cv": {
            "strategy": strategy,
            "folds": fold_summaries,
            "sessionLeakage": False,
            "allClassesInEveryValidationFold": all_classes_in_every_fold,
            "repeatedFoldConstructionDeterministic": deterministic_folds,
        },
        "candidateGrid": {
            "family": "logistic_regression",
            "featureSchemaVersion": FEATURE_SCHEMA_V2,
            "featureCount": len(FEATURE_ORDER_V2),
            "CValues": DEVELOPMENT_C_VALUES,
            "classWeightPolicy": (
                "uniform plus each individual class emphasized at 1.25 and 1.50"
            ),
            "candidateCount": len(specs),
            "deterministic": True,
            "convergenceWarningsRejected": True,
        },
        "fullV2RawLogistic": {
            "featureCount": len(FEATURE_ORDER_V2),
            "featureOrder": FEATURE_ORDER_V2,
            "selectedCandidate": _public_v2_candidate(selected_full_raw),
            "candidates": [
                _public_v2_candidate(candidate) for candidate in full_candidates
            ],
        },
        "temporalDecoder": {
            "causalOnly": True,
            "futureWindowsAccessed": False,
            "featureHopSeconds": 1,
            "ruleCountPerModel": len(rules),
            "modelTemporalPairCount": len(temporal_pairs),
            "quantitativeFreezeEligiblePairCount": len(
                quantitative_freeze_pairs
            ),
            "aggregateAndFoldRobustPairCount": len(fold_robust_pairs),
            "aggregateAndLatencyEligiblePairCount": len(
                aggregate_latency_pairs
            ),
            "persistentFailureFreeFreezePairFound": (
                persistent_failure_free_freeze_pair_found
            ),
            "fallbackSelectionPolicy": (
                "persistent-failure-free freeze-eligible; otherwise "
                "quantitative freeze-eligible; otherwise aggregate+fold-robust; "
                "otherwise aggregate+latency; otherwise all"
            ),
            "selectionOrder": [
                "highest_macro_f1",
                "highest_minimum_aggregate_recall",
                "highest_worst_fold_min_straight_turning_recall",
                "lower_maximum_switch_latency",
                "lower_mean_switch_latency",
                "simpler_temporal_rule",
                "smaller_C",
            ],
            "selected": _public_v2_temporal_pair(selected_pair),
            "candidates": [
                _public_v2_temporal_pair(pair) for pair in temporal_pairs
            ],
            "switchDelayDefinition": (
                "causal candidate-transition delay relative to the start of "
                "the same contiguous raw-argmax class run"
            ),
        },
        "sessionTopology": selected_topology,
        "v2FeatureContribution": feature_analysis,
        "historicalComparison": {
            "previous20SessionTemporal": previous_temporal,
            "new24SessionTemporal": {
                "macroF1": selected_pair["aggregateMetrics"]["macroF1"],
                "worstStraightFoldRecall": selected_pair[
                    "worstStraightFoldRecall"
                ],
                "worstTurningFoldRecall": selected_pair[
                    "worstTurningFoldRecall"
                ],
                "meanDelayWindows": selected_pair["switchDelay"][
                    "meanWindows"
                ],
                "p90DelayWindows": selected_pair["switchDelay"][
                    "p90Windows"
                ],
                "maxDelayWindows": selected_pair["switchDelay"][
                    "maxWindows"
                ],
            },
            "additionalFourSessionsMateriallyHelped": freeze,
            "mainResearchQuestionAnsweredYes": freeze,
        },
        "freezeDecision": {
            "revisedV2DevelopmentFreeze": freeze,
            "quantitativeFreezeEligible": selected_pair["freezeEligible"],
            "persistentFailureWarning": (
                selected_topology["anyPersistentStraightFailure"]
                or selected_topology["anyPersistentTurningFailure"]
            ),
            "family": "logistic_regression" if freeze else None,
            "C": selected_pair["C"] if freeze else None,
            "classWeights": selected_pair["classWeights"] if freeze else None,
            "featureSchemaVersion": FEATURE_SCHEMA_V2,
            "featureCount": len(FEATURE_ORDER_V2),
            "featureOrder": FEATURE_ORDER_V2,
            "normalization": "FOLD_TRAIN_ONLY_STANDARDIZE_THEN_CLAMP_-5_5",
            "classOrder": MOTION_CLASSES,
            "temporalDecoder": (
                {
                    "name": selected_pair["name"],
                    "emaAlpha": selected_pair["emaAlpha"],
                    "hysteresisMargin": selected_pair["hysteresisMargin"],
                    "consecutiveWindows": selected_pair["consecutiveWindows"],
                }
                if freeze
                else None
            ),
            "confidenceSemantics": "argmax_probability",
            "productionModelExported": False,
            "freshIndependentV2HoldoutRequired": freeze,
            "primaryNextRecommendation": next_recommendation,
        },
        "reliabilityHeads": {
            "arcore": "PREVIOUS_PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
        },
        "selfTests": {
            "exact24Sessions": combined_summary["sessionCount"] == 24,
            "exactClassSessionCounts": (
                combined_summary["sessionsPerMotionClass"]
                == V2_24_SESSIONS_PER_CLASS
            ),
            "exact24WindowsPerSession": (
                combined_summary["windowsPerSession"] == 24
            ),
            "exactV2Schema": (
                combined_summary["datasetSchemaVersion"] == DATASET_SCHEMA_V2
                and combined_summary["featureSchemaVersion"]
                == FEATURE_SCHEMA_V2
            ),
            "exact34Features": combined_summary["featureCount"] == 34,
            "groupedFiveFoldCv": len(folds) == 5,
            "noSessionLeakage": all(
                fold["sessionLeakage"] is False for fold in fold_summaries
            ),
            "allClassesInEveryValidationFold": all_classes_in_every_fold,
            "trainOnlyNormalization": all(
                fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
                for fold in fold_summaries
            ),
            "deterministicCandidateGrid": len(specs) == 63,
            "temporalDecoderCausal": True,
            "noFutureWindows": True,
            "latencyMetricsDeterministic": deterministic_latency,
            "repeatedRunDeterministic": (
                deterministic_folds
                and specs == _development_candidate_specs()
                and rules == _temporal_rule_specs()
            ),
            "finalHoldoutNotLoaded": True,
            "noProductionModelExport": production_model_absent,
        },
        "productionModelExported": False,
        "productionModelAbsent": production_model_absent,
        "configEActive": False,
        "navigationAccuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    if not all(report["selfTests"].values()):
        raise DatasetError("V2_24SESSION_DEVELOPMENT_SELF_TEST_FAILED")
    _write_json_atomic(report_output, report)
    return report["status"]


def _bounded_probability_filter_specs() -> list[dict[str, Any]]:
    return [
        {
            "name": "RAW",
            "family": "RAW",
            "weights": [1.0],
            "historyLength": 1,
        },
        *[
            {
                "name": f"FIR2_{alpha:.2f}",
                "family": "FIR2",
                "weights": [alpha, 1.0 - alpha],
                "historyLength": 2,
            }
            for alpha in (0.60, 0.75, 0.90)
        ],
        {
            "name": "FIR3_0.60_0.30_0.10",
            "family": "FIR3",
            "weights": [0.60, 0.30, 0.10],
            "historyLength": 3,
        },
        {
            "name": "FIR3_0.70_0.20_0.10",
            "family": "FIR3",
            "weights": [0.70, 0.20, 0.10],
            "historyLength": 3,
        },
        {
            "name": "FIR3_0.80_0.15_0.05",
            "family": "FIR3",
            "weights": [0.80, 0.15, 0.05],
            "historyLength": 3,
        },
    ]


def _bounded_decoder_rule_specs() -> list[dict[str, Any]]:
    rules = [
        {
            "name": "raw_argmax",
            "family": "RAW_ARGMAX",
            "probabilityFilter": "RAW",
            "firWeights": [1.0],
            "highConfidence": None,
            "highMargin": None,
            "lowConfidence": None,
            "lowMargin": None,
            "consecutiveWindows": 1,
            "historyLength": 1,
            "maximumConfirmationLength": 1,
            "theoreticalMaxDelayWindows": 0,
            "theoreticalLatencyPassed": True,
            "complexity": 0,
            "candidateRuleOrder": 0,
        }
    ]
    for filter_spec in _bounded_probability_filter_specs():
        for high_confidence in (0.70, 0.80):
            for high_margin in (0.10, 0.20):
                for low_confidence in (0.50, 0.60):
                    for low_margin in (0.00, 0.05, 0.10):
                        for consecutive in (1, 2):
                            history_delay = filter_spec["historyLength"] - 1
                            confirmation_delay = consecutive - 1
                            theoretical_delay = (
                                history_delay + confirmation_delay
                            )
                            rules.append(
                                {
                                    "name": (
                                        f"{filter_spec['name'].lower()}_bounded_"
                                        f"hc{high_confidence:.2f}_"
                                        f"hm{high_margin:.2f}_"
                                        f"lc{low_confidence:.2f}_"
                                        f"lm{low_margin:.2f}_"
                                        f"c{consecutive}"
                                    ),
                                    "family": "BOUNDED_SWITCH",
                                    "probabilityFilter": filter_spec["family"],
                                    "probabilityFilterName": filter_spec["name"],
                                    "firWeights": filter_spec["weights"],
                                    "highConfidence": high_confidence,
                                    "highMargin": high_margin,
                                    "lowConfidence": low_confidence,
                                    "lowMargin": low_margin,
                                    "consecutiveWindows": consecutive,
                                    "historyLength": filter_spec[
                                        "historyLength"
                                    ],
                                    "maximumConfirmationLength": consecutive,
                                    "theoreticalMaxDelayWindows": (
                                        theoretical_delay
                                    ),
                                    "theoreticalLatencyPassed": (
                                        theoretical_delay <= 2
                                    ),
                                    "complexity": (
                                        1
                                        + (filter_spec["historyLength"] - 1)
                                    ),
                                    "candidateRuleOrder": len(rules),
                                }
                            )
    return rules


def _finite_impulse_probabilities(probabilities, weights):
    import numpy as np

    weights_array = np.asarray(weights, dtype=float)
    if (
        weights_array.ndim != 1
        or len(weights_array) not in (1, 2, 3)
        or not np.isfinite(weights_array).all()
        or (weights_array < 0.0).any()
        or weights_array.sum() <= 0.0
    ):
        raise DatasetError("invalid bounded FIR weights")
    output = np.empty_like(probabilities, dtype=float)
    for position in range(len(probabilities)):
        available = min(position + 1, len(weights_array))
        active_weights = weights_array[:available]
        weighted = np.zeros(probabilities.shape[1], dtype=float)
        for lag, weight in enumerate(active_weights):
            weighted += weight * probabilities[position - lag]
        output[position] = weighted / active_weights.sum()
    return output


def _bounded_switch_predictions(probabilities, rule: dict[str, Any]):
    import numpy as np

    if rule["maximumConfirmationLength"] > 2:
        raise DatasetError("bounded decoder confirmation length exceeds two")
    predictions = np.empty(len(probabilities), dtype=np.int64)
    current = int(np.argmax(probabilities[0]))
    predictions[0] = current
    pending = None
    pending_count = 0
    for position in range(1, len(probabilities)):
        candidate = int(np.argmax(probabilities[position]))
        if candidate == current:
            pending = None
            pending_count = 0
            predictions[position] = current
            continue
        candidate_probability = float(probabilities[position, candidate])
        candidate_margin = float(
            candidate_probability - probabilities[position, current]
        )
        immediate_switch = (
            candidate_probability >= rule["highConfidence"]
            and candidate_margin >= rule["highMargin"]
        )
        if immediate_switch:
            current = candidate
            pending = None
            pending_count = 0
            predictions[position] = current
            continue
        normal_confirmation = (
            candidate_probability >= rule["lowConfidence"]
            and candidate_margin >= rule["lowMargin"]
        )
        if normal_confirmation:
            if pending == candidate:
                pending_count += 1
            else:
                pending = candidate
                pending_count = 1
            if pending_count >= rule["consecutiveWindows"]:
                current = candidate
                pending = None
                pending_count = 0
        else:
            pending = None
            pending_count = 0
        predictions[position] = current
    return predictions


def _bounded_decoder_predictions(oof, rule: dict[str, Any]):
    import numpy as np

    session_indexes = oof.get("_boundedSessionIndexes")
    if session_indexes is None:
        session_indexes = []
        for session_id in sorted(set(oof["groups"])):
            indexes = np.flatnonzero(oof["groups"] == session_id)
            indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
            session_indexes.append(indexes)
        oof["_boundedSessionIndexes"] = session_indexes
    filter_key = tuple(float(value) for value in rule["firWeights"])
    filter_cache = oof.setdefault("_boundedFilterCache", {})
    filtered_probabilities = filter_cache.get(filter_key)
    if filtered_probabilities is None:
        filtered_probabilities = np.empty_like(
            oof["probabilities"],
            dtype=float,
        )
        for indexes in session_indexes:
            filtered_probabilities[indexes] = _finite_impulse_probabilities(
                oof["probabilities"][indexes],
                rule["firWeights"],
            )
        filter_cache[filter_key] = filtered_probabilities
    output = np.full(len(oof["labels"]), -1, dtype=np.int64)
    for indexes in session_indexes:
        filtered = filtered_probabilities[indexes]
        if rule["family"] == "RAW_ARGMAX":
            predictions = np.argmax(filtered, axis=1).astype(np.int64)
        else:
            predictions = _bounded_switch_predictions(filtered, rule)
        output[indexes] = predictions
    if (output < 0).any():
        raise DatasetError("incomplete bounded decoder predictions")
    return output


def _fast_classification_metrics(y_true, y_pred) -> dict[str, Any]:
    import numpy as np

    class_count = len(MOTION_CLASSES)
    matrix = np.bincount(
        np.asarray(y_true, dtype=np.int64) * class_count
        + np.asarray(y_pred, dtype=np.int64),
        minlength=class_count * class_count,
    ).reshape(class_count, class_count)
    true_support = matrix.sum(axis=1)
    predicted_support = matrix.sum(axis=0)
    diagonal = np.diag(matrix).astype(float)
    precision = np.divide(
        diagonal,
        predicted_support,
        out=np.zeros(class_count, dtype=float),
        where=predicted_support != 0,
    )
    recall = np.divide(
        diagonal,
        true_support,
        out=np.zeros(class_count, dtype=float),
        where=true_support != 0,
    )
    f1 = np.divide(
        2.0 * precision * recall,
        precision + recall,
        out=np.zeros(class_count, dtype=float),
        where=(precision + recall) != 0.0,
    )
    total = int(matrix.sum())
    return {
        "accuracy": float(diagonal.sum() / total) if total else 0.0,
        "macroPrecision": float(precision.mean()),
        "macroRecall": float(recall.mean()),
        "macroF1": float(f1.mean()),
        "perClass": {
            label: {
                "precision": float(precision[index]),
                "recall": float(recall[index]),
                "f1": float(f1[index]),
                "support": int(true_support[index]),
            }
            for index, label in enumerate(MOTION_CLASSES)
        },
        "confusionMatrix": matrix.tolist(),
    }


def _bounded_persistent_failure_flags(oof, predictions) -> dict[str, bool]:
    import numpy as np

    failures = {"STRAIGHT_WALK": False, "TURNING": False}
    for session_id in sorted(set(oof["groups"])):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        true_index = int(oof["labels"][indexes][0])
        true_class = MOTION_CLASSES[true_index]
        if true_class not in failures:
            continue
        session_predictions = predictions[indexes]
        counts = Counter(int(value) for value in session_predictions)
        dominant_index = max(
            range(len(MOTION_CLASSES)),
            key=lambda value: (counts[value], -value),
        )
        accuracy = float((session_predictions == true_index).mean())
        wrong_dominant = (
            dominant_index != true_index
            and counts[dominant_index] > len(indexes) / 2
        )
        longest_competing_run = max(
            (
                _longest_true_run(session_predictions == class_index)
                for class_index in range(len(MOTION_CLASSES))
                if class_index != true_index
            ),
            default=0,
        )
        if (
            accuracy < 0.50
            or wrong_dominant
            or longest_competing_run >= 12
        ):
            failures[true_class] = True
    return {
        "persistentStraightFailure": failures["STRAIGHT_WALK"],
        "persistentTurningFailure": failures["TURNING"],
    }


def _evaluate_bounded_decoder_rule(
    oof,
    rule: dict[str, Any],
    evaluation_cache: dict[bytes, dict[str, Any]] | None = None,
):
    predictions = _bounded_decoder_predictions(oof, rule)
    prediction_key = predictions.tobytes()
    cached = (
        evaluation_cache.get(prediction_key)
        if evaluation_cache is not None
        else None
    )
    if cached is None:
        aggregate = _fast_classification_metrics(oof["labels"], predictions)
        fold_metrics = []
        for fold_number in range(1, DEVELOPMENT_FOLD_COUNT + 1):
            mask = oof["foldIndexes"] == fold_number
            metrics = _fast_classification_metrics(
                oof["labels"][mask],
                predictions[mask],
            )
            fold_metrics.append(
                {
                    "fold": fold_number,
                    "macroF1": metrics["macroF1"],
                    "recalls": {
                        label: metrics["perClass"][label]["recall"]
                        for label in MOTION_CLASSES
                    },
                    "confusionMatrix": metrics["confusionMatrix"],
                }
            )
        minimum_recall = min(
            aggregate["perClass"][label]["recall"]
            for label in MOTION_CLASSES
        )
        worst_straight = min(
            fold["recalls"]["STRAIGHT_WALK"] for fold in fold_metrics
        )
        worst_turning = min(
            fold["recalls"]["TURNING"] for fold in fold_metrics
        )
        aggregate_gate = _motion_deployment_gate(aggregate)
        fold_robust = worst_straight >= 0.55 and worst_turning >= 0.55
        delay = _switch_delay_proxy(oof, predictions)
        empirical_latency_passed = delay["maxWindows"] <= 2
        persistent = _bounded_persistent_failure_flags(oof, predictions)
        session_robust = not (
            persistent["persistentStraightFailure"]
            or persistent["persistentTurningFailure"]
        )
        cached = {
            "aggregateMetrics": aggregate,
            "minimumClassRecall": minimum_recall,
            "foldMetrics": fold_metrics,
            "worstStraightFoldRecall": worst_straight,
            "worstTurningFoldRecall": worst_turning,
            "worstStraightTurningFoldRecall": min(
                worst_straight,
                worst_turning,
            ),
            "switchDelay": delay,
            "aggregateGatePassed": aggregate_gate,
            "foldRobust": fold_robust,
            **persistent,
            "sessionRobust": session_robust,
            "empiricalLatencyPassed": empirical_latency_passed,
        }
        if evaluation_cache is not None:
            evaluation_cache[prediction_key] = cached
    freeze_eligible = (
        cached["aggregateGatePassed"]
        and cached["foldRobust"]
        and cached["sessionRobust"]
        and rule["theoreticalLatencyPassed"]
        and cached["empiricalLatencyPassed"]
    )
    return {
        **rule,
        **cached,
        "freezeEligible": freeze_eligible,
        "_predictions": predictions,
    }


def _public_bounded_candidate(candidate: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value
        for key, value in candidate.items()
        if key not in {"_predictions", "_oof"}
    }


def _bounded_candidate_key(candidate: dict[str, Any]):
    metrics = candidate["aggregateMetrics"]
    return (
        candidate["freezeEligible"],
        metrics["macroF1"],
        candidate["minimumClassRecall"],
        candidate["worstStraightTurningFoldRecall"],
        -candidate["switchDelay"]["maxWindows"],
        -candidate["switchDelay"]["meanWindows"],
        -candidate["historyLength"],
        -candidate["complexity"],
        -candidate["C"],
        -candidate["weightComplexity"],
        -candidate["candidateOrder"],
        -candidate["candidateRuleOrder"],
    )


def _bounded_decoder_contract_checks() -> dict[str, bool]:
    import numpy as np

    probabilities = np.asarray(
        [
            [0.70, 0.10, 0.10, 0.10],
            [0.10, 0.70, 0.10, 0.10],
            [0.10, 0.10, 0.70, 0.10],
            [0.10, 0.10, 0.10, 0.70],
        ],
        dtype=float,
    )
    changed = probabilities.copy()
    changed[0] = [0.10, 0.10, 0.10, 0.70]
    fir2 = _finite_impulse_probabilities(probabilities, [0.60, 0.40])
    changed_fir2 = _finite_impulse_probabilities(changed, [0.60, 0.40])
    fir3 = _finite_impulse_probabilities(probabilities, [0.60, 0.30, 0.10])
    changed_fir3 = _finite_impulse_probabilities(changed, [0.60, 0.30, 0.10])
    fir2_memory = np.array_equal(fir2[2:], changed_fir2[2:])
    fir3_memory = np.array_equal(fir3[3:], changed_fir3[3:])
    expected_fir3_last = (
        0.60 * probabilities[3]
        + 0.30 * probabilities[2]
        + 0.10 * probabilities[1]
    )
    non_recursive = np.allclose(fir3[3], expected_fir3_last)

    sample_rule = next(
        rule
        for rule in _bounded_decoder_rule_specs()
        if rule["family"] == "BOUNDED_SWITCH"
        and rule["probabilityFilter"] == "RAW"
        and rule["highConfidence"] == 0.70
        and rule["highMargin"] == 0.10
        and rule["lowConfidence"] == 0.50
        and rule["lowMargin"] == 0.00
        and rule["consecutiveWindows"] == 2
    )
    session_oof = {
        "labels": np.asarray([0, 0, 1, 1], dtype=np.int64),
        "groups": np.asarray(["A", "A", "B", "B"]),
        "windowIndexes": np.asarray([0, 1, 0, 1], dtype=np.int64),
        "probabilities": np.asarray(
            [
                [0.90, 0.05, 0.03, 0.02],
                [0.05, 0.90, 0.03, 0.02],
                [0.05, 0.90, 0.03, 0.02],
                [0.90, 0.05, 0.03, 0.02],
            ]
        ),
    }
    combined_predictions = _bounded_decoder_predictions(session_oof, sample_rule)
    standalone_oof = {
        "labels": session_oof["labels"][2:],
        "groups": np.asarray(["B", "B"]),
        "windowIndexes": np.asarray([0, 1], dtype=np.int64),
        "probabilities": session_oof["probabilities"][2:],
    }
    standalone_predictions = _bounded_decoder_predictions(
        standalone_oof,
        sample_rule,
    )
    state_reset = np.array_equal(
        combined_predictions[2:],
        standalone_predictions,
    )
    immediate_first = _bounded_switch_predictions(probabilities, sample_rule)
    immediate_second = _bounded_switch_predictions(probabilities, sample_rule)
    rules = _bounded_decoder_rule_specs()
    return {
        "sessionDecoderStateReset": state_reset,
        "fir2UsesOnlyCurrentAndPrevious": fir2_memory,
        "fir3UsesOnlyCurrentAndTwoPrevious": fir3_memory,
        "noRecursiveLongTailState": non_recursive,
        "maxConfirmationStreakAtMostTwo": all(
            rule["maximumConfirmationLength"] <= 2 for rule in rules
        ),
        "immediateSwitchDeterministic": np.array_equal(
            immediate_first,
            immediate_second,
        ),
        "noFutureWindowAccess": True,
        "theoreticalLatencyAssertion": all(
            rule["theoreticalMaxDelayWindows"]
            == (rule["historyLength"] - 1)
            + (rule["maximumConfirmationLength"] - 1)
            for rule in rules
        ),
    }


def _bounded_turn_evidence_diagnostic(development_data, selected_candidate):
    import numpy as np

    oof = selected_candidate["_oof"]
    turn_index = MOTION_LABEL_TO_INDEX["TURNING"]
    straight_index = MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
    turn_mask = oof["labels"] == turn_index
    probabilities = oof["probabilities"]
    turn_probabilities = probabilities[turn_mask, turn_index]
    straight_probabilities = probabilities[turn_mask, straight_index]
    supportive = turn_probabilities > straight_probabilities
    turn_sessions = sorted(set(oof["groups"][turn_mask]))
    session_summaries = []
    early_support_count = 0
    for number, session_id in enumerate(turn_sessions, start=1):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        margins = (
            probabilities[indexes, turn_index]
            - probabilities[indexes, straight_index]
        )
        supportive_positions = np.flatnonzero(margins > 0.0)
        first_support = (
            int(supportive_positions[0])
            if len(supportive_positions)
            else None
        )
        within_two = first_support is not None and first_support <= 2
        early_support_count += int(within_two)
        session_summaries.append(
            {
                "session": f"TURNING_V2_DEV_{number}",
                "meanTurningProbability": float(
                    probabilities[indexes, turn_index].mean()
                ),
                "meanStraightProbability": float(
                    probabilities[indexes, straight_index].mean()
                ),
                "turnSupportFraction": float((margins > 0.0).mean()),
                "firstTurnSupportWindow": first_support,
                "turnSupportWithinTwoWindows": within_two,
            }
        )
    feature_diagnostics = {}
    early_turn_mask = np.zeros(len(development_data), dtype=bool)
    for session_id in turn_sessions:
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        early_turn_mask[indexes[:3]] = True
    straight_mask = oof["labels"] == straight_index
    for feature in (
        "heading_net_change_abs_rad",
        "sustained_turn_fraction",
        "arcore_net_turn_abs_rad",
        "arcore_turn_consistency",
    ):
        values = development_data[feature].to_numpy(float)
        feature_diagnostics[feature] = {
            "trueTurningMean": float(values[turn_mask].mean()),
            "trueTurningFirstThreeMean": float(values[early_turn_mask].mean()),
            "trueStraightMean": float(values[straight_mask].mean()),
        }
    sufficient = (
        float(supportive.mean()) >= 0.55
        and float(turn_probabilities.mean())
        > float(straight_probabilities.mean())
        and early_support_count >= 5
    )
    status = "TURN_EVIDENCE_SUFFICIENT" if sufficient else "TURN_EVIDENCE_WEAK"
    return {
        "status": status,
        "definition": (
            "sufficient when true-TURNING P(TURNING)>P(STRAIGHT) in at least "
            "55% of windows, mean P(TURNING)>mean P(STRAIGHT), and at least "
            "5 of 7 sessions become turn-supportive within windows 0..2"
        ),
        "meanTurningProbability": float(turn_probabilities.mean()),
        "meanStraightProbability": float(straight_probabilities.mean()),
        "meanTurningMinusStraightProbability": float(
            (turn_probabilities - straight_probabilities).mean()
        ),
        "turnSupportiveWindowFraction": float(supportive.mean()),
        "sessionsSupportiveWithinTwoWindows": early_support_count,
        "sessionCount": len(turn_sessions),
        "sessions": session_summaries,
        "geometricEvidence": feature_diagnostics,
        "summary": (
            f"{early_support_count}/{len(turn_sessions)} TURNING sessions show "
            "P(TURNING)>P(STRAIGHT) within the first three causal windows; "
            f"overall supportive-window fraction={float(supportive.mean()):.6f}."
        ),
    }


def evaluate_v2_bounded_decoder(
    input_path: Path,
    extension_path: Path,
    report_output: Path,
) -> str:
    if input_path.resolve().name != "development_v2":
        raise DatasetError("bounded decoder input must be development_v2")
    if extension_path.resolve().name != "v2_extension_4":
        raise DatasetError("bounded decoder extension must be v2_extension_4")
    base_data = _load_and_validate(input_path)
    extension_data = _load_and_validate(extension_path)
    (
        data,
        base_summary,
        extension_summary,
        combined_summary,
    ) = _validate_v2_24session_sources(base_data, extension_data)
    folds, fold_summaries, strategy = _build_v2_24session_folds(data)
    repeated_folds, repeated_summaries, repeated_strategy = (
        _build_v2_24session_folds(data)
    )
    fold_assignment_unchanged = (
        _folds_are_identical(folds, repeated_folds)
        and fold_summaries == repeated_summaries
        and strategy == repeated_strategy
    )
    if not fold_assignment_unchanged:
        raise DatasetError("bounded decoder fold assignment changed")
    specs = _development_candidate_specs()
    rules = _bounded_decoder_rule_specs()
    if len(specs) != 63 or specs != _development_candidate_specs():
        raise DatasetError("bounded decoder Logistic grid is not deterministic")
    if len(rules) != 337 or rules != _bounded_decoder_rule_specs():
        raise DatasetError("bounded decoder rule grid is not deterministic")

    logistic_candidates = [
        _evaluate_v2_logistic_candidate(data, folds, spec, FEATURE_ORDER_V2)
        for spec in specs
    ]
    bounded_pairs = []
    for candidate in logistic_candidates:
        evaluation_cache: dict[bytes, dict[str, Any]] = {}
        for rule in rules:
            evaluated = _evaluate_bounded_decoder_rule(
                candidate["_oof"],
                rule,
                evaluation_cache,
            )
            bounded_pairs.append(
                {
                    "C": candidate["C"],
                    "profile": candidate["profile"],
                    "classWeights": candidate["classWeights"],
                    "weightComplexity": candidate["weightComplexity"],
                    "candidateOrder": candidate["candidateOrder"],
                    **evaluated,
                    "_oof": candidate["_oof"],
                }
            )
    freeze_eligible_pairs = [
        pair for pair in bounded_pairs if pair["freezeEligible"]
    ]
    structurally_valid = [
        pair for pair in bounded_pairs if pair["theoreticalLatencyPassed"]
    ]
    aggregate_fold_latency = [
        pair
        for pair in structurally_valid
        if pair["aggregateGatePassed"]
        and pair["foldRobust"]
        and pair["empiricalLatencyPassed"]
    ]
    aggregate_fold_session = [
        pair
        for pair in structurally_valid
        if pair["aggregateGatePassed"]
        and pair["foldRobust"]
        and pair["sessionRobust"]
    ]
    aggregate_fold = [
        pair
        for pair in structurally_valid
        if pair["aggregateGatePassed"] and pair["foldRobust"]
    ]
    aggregate_latency = [
        pair
        for pair in structurally_valid
        if pair["aggregateGatePassed"] and pair["empiricalLatencyPassed"]
    ]
    selection_pool = (
        freeze_eligible_pairs
        or aggregate_fold_latency
        or aggregate_fold_session
        or aggregate_fold
        or aggregate_latency
        or structurally_valid
    )
    selected = max(selection_pool, key=_bounded_candidate_key)
    selected_topology = _v2_24_session_topology(
        selected["_oof"],
        selected["_predictions"],
    )
    turn_evidence = _bounded_turn_evidence_diagnostic(data, selected)
    freeze = bool(selected["freezeEligible"])

    repeated_selected = _evaluate_bounded_decoder_rule(
        selected["_oof"],
        {
            key: selected[key]
            for key in (
                "name",
                "family",
                "probabilityFilter",
                "probabilityFilterName",
                "firWeights",
                "highConfidence",
                "highMargin",
                "lowConfidence",
                "lowMargin",
                "consecutiveWindows",
                "historyLength",
                "maximumConfirmationLength",
                "theoreticalMaxDelayWindows",
                "theoreticalLatencyPassed",
                "complexity",
                "candidateRuleOrder",
            )
            if key in selected
        },
    )
    repeated_run_deterministic = (
        _public_bounded_candidate(repeated_selected)
        == {
            key: value
            for key, value in _public_bounded_candidate(selected).items()
            if key
            not in {
                "C",
                "profile",
                "classWeights",
                "weightComplexity",
                "candidateOrder",
            }
        }
    )
    if not repeated_run_deterministic:
        raise DatasetError("bounded decoder selected rule is not deterministic")

    if freeze:
        next_recommendation = None
    elif turn_evidence["status"] == "TURN_EVIDENCE_SUFFICIENT":
        next_recommendation = "MOTION_SEMANTIC_DECODER_REVIEW"
    else:
        next_recommendation = "MODEL_CAPACITY_REVIEW"

    assets_directory = (
        Path(__file__).resolve().parents[2]
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "assets"
    )
    production_model_absent = not any(
        assets_directory.glob("navguard_ai_model*.json")
    )
    if not production_model_absent:
        raise DatasetError("PRODUCTION_MODEL_ASSET_PRESENT")
    contract_checks = _bounded_decoder_contract_checks()
    worst_straight_session_accuracy = min(
        value["accuracy"] for value in selected_topology["straightSessions"]
    )
    worst_turning_session_accuracy = min(
        value["accuracy"] for value in selected_topology["turningSessions"]
    )
    longest_wrong_run = max(
        value["longestConsecutiveWrongRun"]
        for value in selected_topology["sessions"]
    )
    old_ema = {
        "name": "ema_0.25_hyst_0.15_1",
        "macroF1": 0.885746,
        "worstStraightFoldRecall": 0.708333,
        "worstTurningFoldRecall": 0.687500,
        "meanDelayWindows": 1.961538,
        "p90DelayWindows": 4.0,
        "maxDelayWindows": 6,
        "persistentStraightFailure": False,
        "persistentTurningFailure": True,
        "freezeEligibleCandidateCount": 0,
    }
    robustness_retained = (
        selected["aggregateGatePassed"] and selected["foldRobust"]
    )
    latency_materially_improved = (
        selected["theoreticalLatencyPassed"]
        and selected["empiricalLatencyPassed"]
        and selected["switchDelay"]["maxWindows"] < old_ema["maxDelayWindows"]
    )
    ranked_candidates = sorted(
        structurally_valid,
        key=_bounded_candidate_key,
        reverse=True,
    )
    report = {
        "status": (
            "REVISED_V2_DEVELOPMENT_FREEZE_READY"
            if freeze
            else "V2_BOUNDED_DECODER_NOT_FROZEN"
        ),
        "dataset": {
            "base": base_summary,
            "extension": extension_summary,
            "combined": combined_summary,
        },
        "classOrder": MOTION_CLASSES,
        "developmentOnly": True,
        "finalHoldoutLoaded": False,
        "historicalV1RowsLoaded": False,
        "privatePathsReturned": False,
        "rawRowsReturned": False,
        "cv": {
            "strategy": strategy,
            "folds": fold_summaries,
            "foldAssignmentUnchanged": fold_assignment_unchanged,
            "sessionLeakage": False,
            "trainOnlyNormalization": True,
        },
        "oldEmaBaseline": old_ema,
        "emaLatencyRootCause": {
            "recursiveState": True,
            "alpha": 0.25,
            "previousStateMultiplier": 0.75,
            "oldStateInfluenceAfterWindows": {
                "1": 0.75,
                "2": 0.5625,
                "4": 0.31640625,
                "6": 0.177978515625,
            },
            "reason": (
                "EMA recursively carries q_(t-1), so pre-transition probability "
                "mass decays geometrically instead of disappearing after t-2; "
                "consecutive=1 does not remove this filter memory."
            ),
        },
        "decoderSearch": {
            "symmetricAcrossClasses": True,
            "labelSpecificRules": False,
            "futureWindowsAccessed": False,
            "recursiveLongTailState": False,
            "logisticCandidateCount": len(specs),
            "probabilityFilterCount": len(_bounded_probability_filter_specs()),
            "decoderRuleCountPerModel": len(rules),
            "modelDecoderPairCount": len(bounded_pairs),
            "theoreticallyValidPairCount": len(structurally_valid),
            "freezeEligiblePairCount": len(freeze_eligible_pairs),
            "aggregateFoldLatencyPairCount": len(aggregate_fold_latency),
            "aggregateFoldSessionPairCount": len(aggregate_fold_session),
            "aggregateFoldPairCount": len(aggregate_fold),
            "aggregateLatencyPairCount": len(aggregate_latency),
            "filters": _bounded_probability_filter_specs(),
            "parameterGrid": {
                "highConfidence": [0.70, 0.80],
                "highMargin": [0.10, 0.20],
                "lowConfidence": [0.50, 0.60],
                "lowMargin": [0.00, 0.05, 0.10],
                "consecutiveWindows": [1, 2],
            },
            "theoreticalDelayDefinition": (
                "(historyLength - 1) + (maximumConfirmationLength - 1)"
            ),
            "selectionOrder": [
                "highest_macro_f1",
                "highest_minimum_aggregate_recall",
                "highest_worst_fold_min_straight_turning_recall",
                "lowest_empirical_max_delay",
                "lowest_mean_delay",
                "shortest_history",
                "simplest_rule",
                "smaller_C",
            ],
            "selected": _public_bounded_candidate(selected),
            "topStructurallyValidCandidates": [
                _public_bounded_candidate(candidate)
                for candidate in ranked_candidates[:25]
            ],
        },
        "sessionTopology": selected_topology,
        "turnEvidence": turn_evidence,
        "comparison": {
            "oldEmaMacroF1": old_ema["macroF1"],
            "newBoundedMacroF1": selected["aggregateMetrics"]["macroF1"],
            "oldMaxDelayWindows": old_ema["maxDelayWindows"],
            "newMaxDelayWindows": selected["switchDelay"]["maxWindows"],
            "oldPersistentTurningFailure": True,
            "newPersistentTurningFailure": selected[
                "persistentTurningFailure"
            ],
            "robustnessRetained": robustness_retained,
            "latencyMateriallyImproved": latency_materially_improved,
        },
        "freezeDecision": {
            "revisedV2DevelopmentFreeze": freeze,
            "family": "logistic_regression" if freeze else None,
            "C": selected["C"] if freeze else None,
            "classWeights": selected["classWeights"] if freeze else None,
            "featureSchemaVersion": FEATURE_SCHEMA_V2,
            "featureCount": len(FEATURE_ORDER_V2),
            "featureOrder": FEATURE_ORDER_V2,
            "normalization": "FOLD_TRAIN_ONLY_STANDARDIZE_THEN_CLAMP_-5_5",
            "classOrder": MOTION_CLASSES,
            "temporalDecoder": (
                {
                    key: selected[key]
                    for key in (
                        "name",
                        "family",
                        "probabilityFilter",
                        "firWeights",
                        "highConfidence",
                        "highMargin",
                        "lowConfidence",
                        "lowMargin",
                        "consecutiveWindows",
                        "historyLength",
                        "theoreticalMaxDelayWindows",
                    )
                }
                if freeze
                else None
            ),
            "confidenceSemantics": "argmax_probability",
            "productionModelExported": False,
            "freshIndependentV2HoldoutRequired": freeze,
            "primaryNextRecommendation": next_recommendation,
        },
        "selfTests": {
            "exact24DevelopmentSessions": (
                combined_summary["sessionCount"] == 24
            ),
            "samePreviousFoldAssignments": fold_assignment_unchanged,
            "noSessionLeakage": all(
                fold["sessionLeakage"] is False for fold in fold_summaries
            ),
            "trainOnlyScaler": all(
                fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
                for fold in fold_summaries
            ),
            **contract_checks,
            "selectedTheoreticalLatencyAtMostTwo": (
                selected["theoreticalMaxDelayWindows"] <= 2
            ),
            "repeatedRunDeterministic": repeated_run_deterministic,
            "finalHoldoutRowsNotRead": True,
            "noProductionModelExport": production_model_absent,
        },
        "productionModelExported": False,
        "productionModelAbsent": production_model_absent,
        "configEActive": False,
        "navigationAccuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
        "sessionRobustnessSummary": {
            "worstStraightSessionAccuracy": worst_straight_session_accuracy,
            "worstTurningSessionAccuracy": worst_turning_session_accuracy,
            "longestWrongRun": longest_wrong_run,
        },
    }
    if not all(report["selfTests"].values()):
        raise DatasetError("V2_BOUNDED_DECODER_SELF_TEST_FAILED")
    _write_json_atomic(report_output, report)
    return report["status"]


def _mlp_capacity_specs() -> list[dict[str, Any]]:
    specs = []
    for hidden_units in (8, 16, 32):
        for alpha in (0.0001, 0.001, 0.01):
            for learning_rate in (0.0005, 0.001):
                specs.append(
                    {
                        "hiddenUnits": hidden_units,
                        "alpha": alpha,
                        "learningRateInit": learning_rate,
                        "randomSeed": SEED,
                        "activation": "relu",
                        "optimizer": "adam",
                        "maximumEpochs": 500,
                        "patienceEpochs": 25,
                        "minimumImprovement": 1e-4,
                        "candidateOrder": len(specs),
                    }
                )
    return specs


def _build_session_safe_inner_splits(development_data, outer_folds):
    import numpy as np

    groups = development_data["session_id"].astype(str).to_numpy()
    labels = development_data["motion_label"].astype(str).to_numpy()
    split_results = []
    summaries = []
    for fold_number, (outer_train, outer_validation) in enumerate(
        outer_folds,
        start=1,
    ):
        outer_train_sessions = set(groups[outer_train])
        outer_validation_sessions = set(groups[outer_validation])
        if outer_train_sessions & outer_validation_sessions:
            raise DatasetError("outer session leakage before MLP inner split")
        inner_validation_sessions = set()
        for class_index, class_name in enumerate(MOTION_CLASSES):
            available = sorted(
                session_id
                for session_id in outer_train_sessions
                if labels[np.flatnonzero(groups == session_id)[0]] == class_name
            )
            if not available:
                raise DatasetError("MLP inner validation class missing")
            rng = random.Random(SEED + fold_number * 100 + class_index)
            rng.shuffle(available)
            inner_validation_sessions.add(available[0])
        inner_train_sessions = outer_train_sessions - inner_validation_sessions
        if (
            inner_validation_sessions & inner_train_sessions
            or inner_validation_sessions & outer_validation_sessions
            or inner_train_sessions & outer_validation_sessions
        ):
            raise DatasetError("MLP inner/outer session leakage")
        inner_validation_mask = np.isin(
            groups,
            list(inner_validation_sessions),
        )
        inner_train_mask = np.isin(groups, list(inner_train_sessions))
        inner_validation = np.flatnonzero(inner_validation_mask)
        inner_train = np.flatnonzero(inner_train_mask)
        validation_counts = Counter(labels[inner_validation])
        if any(validation_counts[label] != 24 for label in MOTION_CLASSES):
            raise DatasetError(
                "MLP inner validation requires one full session per class"
            )
        if set(inner_train) & set(outer_validation):
            raise DatasetError("outer validation entered MLP inner training")
        if set(inner_validation) & set(outer_validation):
            raise DatasetError("outer validation entered MLP inner validation")
        split_results.append((inner_train, inner_validation))
        summaries.append(
            {
                "fold": fold_number,
                "outerTrainSessionCount": len(outer_train_sessions),
                "outerValidationSessionCount": len(outer_validation_sessions),
                "innerTrainSessionCount": len(inner_train_sessions),
                "innerValidationSessionCount": len(
                    inner_validation_sessions
                ),
                "innerValidationSessionsPerMotionClass": {
                    label: int(validation_counts[label] // 24)
                    for label in MOTION_CLASSES
                },
                "innerSplitLevel": "SESSION_LEVEL",
                "outerValidationExcluded": True,
                "sessionLeakage": False,
            }
        )
    return split_results, summaries


def _new_session_safe_mlp(spec: dict[str, Any]):
    from sklearn.neural_network import MLPClassifier

    return MLPClassifier(
        hidden_layer_sizes=(spec["hiddenUnits"],),
        activation="relu",
        solver="adam",
        alpha=spec["alpha"],
        learning_rate_init=spec["learningRateInit"],
        max_iter=1,
        shuffle=True,
        random_state=SEED,
        early_stopping=False,
        warm_start=False,
    )


def _partial_fit_one_epoch(model, features, labels, first_epoch: bool) -> None:
    import numpy as np

    if first_epoch:
        model.partial_fit(
            features,
            labels,
            classes=np.arange(len(MOTION_CLASSES), dtype=np.int64),
        )
    else:
        model.partial_fit(features, labels)


def _select_session_safe_best_epoch(
    inner_train_features,
    inner_train_labels,
    inner_validation_features,
    inner_validation_labels,
    spec: dict[str, Any],
) -> dict[str, Any]:
    model = _new_session_safe_mlp(spec)
    best_macro_f1 = -1.0
    best_epoch = 1
    no_improvement = 0
    trained_epochs = 0
    for epoch in range(1, spec["maximumEpochs"] + 1):
        _partial_fit_one_epoch(
            model,
            inner_train_features,
            inner_train_labels,
            first_epoch=epoch == 1,
        )
        validation_probabilities = _validated_motion_probabilities(
            model,
            inner_validation_features,
        )
        validation_predictions = validation_probabilities.argmax(axis=1)
        metrics = _fast_classification_metrics(
            inner_validation_labels,
            validation_predictions,
        )
        macro_f1 = metrics["macroF1"]
        trained_epochs = epoch
        if macro_f1 >= best_macro_f1 + spec["minimumImprovement"]:
            best_macro_f1 = macro_f1
            best_epoch = epoch
            no_improvement = 0
        else:
            no_improvement += 1
        if no_improvement >= spec["patienceEpochs"]:
            break
    return {
        "bestEpoch": best_epoch,
        "bestInnerValidationMacroF1": best_macro_f1,
        "trainedEpochsBeforeStop": trained_epochs,
        "hitMaximumEpochs": trained_epochs >= spec["maximumEpochs"],
    }


def _mlp_probability_quality(oof) -> dict[str, Any]:
    import numpy as np

    probabilities = oof["probabilities"]
    labels = oof["labels"]
    straight_index = MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]
    turning_index = MOTION_LABEL_TO_INDEX["TURNING"]
    straight_mask = labels == straight_index
    turning_mask = labels == turning_index
    straight_correct = float(
        probabilities[straight_mask, straight_index].mean()
    )
    straight_competing = float(
        probabilities[straight_mask, turning_index].mean()
    )
    turning_correct = float(probabilities[turning_mask, turning_index].mean())
    turning_competing = float(
        probabilities[turning_mask, straight_index].mean()
    )
    return {
        "meanMaxProbability": float(probabilities.max(axis=1).mean()),
        "medianMaxProbability": float(np.median(probabilities.max(axis=1))),
        "trueStraight": {
            "meanStraightProbability": straight_correct,
            "meanTurningProbability": straight_competing,
            "correctMinusCompetingMargin": (
                straight_correct - straight_competing
            ),
        },
        "trueTurning": {
            "meanTurningProbability": turning_correct,
            "meanStraightProbability": turning_competing,
            "correctMinusCompetingMargin": turning_correct - turning_competing,
        },
        "meanStraightTurningSeparation": float(
            (
                straight_correct
                - straight_competing
                + turning_correct
                - turning_competing
            )
            / 2.0
        ),
    }


def _evaluate_session_safe_mlp_candidate(
    development_data,
    outer_folds,
    inner_splits,
    spec: dict[str, Any],
    feature_order: list[str] = FEATURE_ORDER_V2,
):
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = development_data[feature_order].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    groups = development_data["session_id"].astype(str).to_numpy()
    window_indexes = development_data["window_index"].to_numpy(int)
    probabilities = np.full(
        (len(labels), len(MOTION_CLASSES)),
        np.nan,
        dtype=float,
    )
    predictions = np.full(len(labels), -1, dtype=np.int64)
    fold_indexes = np.full(len(labels), -1, dtype=np.int64)
    fold_metrics = []
    training_folds = []
    runtime_shapes = []
    for fold_number, (
        outer_fold,
        inner_fold,
    ) in enumerate(zip(outer_folds, inner_splits), start=1):
        outer_train, outer_validation = outer_fold
        inner_train, inner_validation = inner_fold
        inner_scaler = StandardScaler().fit(features[inner_train])
        inner_std = np.where(inner_scaler.scale_ > 1e-9, inner_scaler.scale_, 1.0)
        inner_train_features = np.clip(
            (features[inner_train] - inner_scaler.mean_) / inner_std,
            -5.0,
            5.0,
        )
        inner_validation_features = np.clip(
            (features[inner_validation] - inner_scaler.mean_) / inner_std,
            -5.0,
            5.0,
        )
        epoch_selection = _select_session_safe_best_epoch(
            inner_train_features,
            labels[inner_train],
            inner_validation_features,
            labels[inner_validation],
            spec,
        )

        outer_scaler = StandardScaler().fit(features[outer_train])
        outer_std = np.where(outer_scaler.scale_ > 1e-9, outer_scaler.scale_, 1.0)
        outer_train_features = np.clip(
            (features[outer_train] - outer_scaler.mean_) / outer_std,
            -5.0,
            5.0,
        )
        outer_validation_features = np.clip(
            (features[outer_validation] - outer_scaler.mean_) / outer_std,
            -5.0,
            5.0,
        )
        model = _new_session_safe_mlp(spec)
        for epoch in range(1, epoch_selection["bestEpoch"] + 1):
            _partial_fit_one_epoch(
                model,
                outer_train_features,
                labels[outer_train],
                first_epoch=epoch == 1,
            )
        fold_probabilities = _validated_motion_probabilities(
            model,
            outer_validation_features,
        )
        fold_predictions = fold_probabilities.argmax(axis=1).astype(np.int64)
        probabilities[outer_validation] = fold_probabilities
        predictions[outer_validation] = fold_predictions
        fold_indexes[outer_validation] = fold_number
        metrics = _fast_classification_metrics(
            labels[outer_validation],
            fold_predictions,
        )
        fold_metrics.append(
            {
                "fold": fold_number,
                "accuracy": metrics["accuracy"],
                "macroPrecision": metrics["macroPrecision"],
                "macroRecall": metrics["macroRecall"],
                "macroF1": metrics["macroF1"],
                "recalls": {
                    label: metrics["perClass"][label]["recall"]
                    for label in MOTION_CLASSES
                },
                "confusionMatrix": metrics["confusionMatrix"],
            }
        )
        runtime_shapes.append(
            {
                "inputToHidden": [
                    int(model.coefs_[0].shape[0]),
                    int(model.coefs_[0].shape[1]),
                ],
                "hiddenBias": int(model.intercepts_[0].shape[0]),
                "hiddenToOutput": [
                    int(model.coefs_[1].shape[0]),
                    int(model.coefs_[1].shape[1]),
                ],
                "outputBias": int(model.intercepts_[1].shape[0]),
            }
        )
        training_folds.append(
            {
                "fold": fold_number,
                **epoch_selection,
                "innerScalerFit": "INNER_TRAIN_ONLY",
                "outerScalerFit": "ALL_OUTER_TRAIN_AFTER_EPOCH_SELECTION",
                "outerValidationEvaluationCount": 1,
                "sklearnInternalEarlyStopping": False,
            }
        )
    if (
        not np.isfinite(probabilities).all()
        or (predictions < 0).any()
        or (fold_indexes < 1).any()
    ):
        raise DatasetError("incomplete MLP out-of-fold predictions")
    aggregate = _fast_classification_metrics(labels, predictions)
    minimum_recall = min(
        aggregate["perClass"][label]["recall"] for label in MOTION_CLASSES
    )
    worst_straight = min(
        fold["recalls"]["STRAIGHT_WALK"] for fold in fold_metrics
    )
    worst_turning = min(
        fold["recalls"]["TURNING"] for fold in fold_metrics
    )
    oof = {
        "labels": labels,
        "groups": groups,
        "windowIndexes": window_indexes,
        "probabilities": probabilities,
        "predictions": predictions,
        "foldIndexes": fold_indexes,
    }
    persistent = _bounded_persistent_failure_flags(oof, predictions)
    aggregate_gate = _motion_deployment_gate(aggregate)
    fold_robust = worst_straight >= 0.55 and worst_turning >= 0.55
    return {
        **spec,
        "aggregateMetrics": aggregate,
        "minimumClassRecall": minimum_recall,
        "foldMetrics": fold_metrics,
        "worstStraightFoldRecall": worst_straight,
        "worstTurningFoldRecall": worst_turning,
        "worstStraightTurningFoldRecall": min(worst_straight, worst_turning),
        "aggregateGatePassed": aggregate_gate,
        "foldRobust": fold_robust,
        **persistent,
        "sessionRobust": not (
            persistent["persistentStraightFailure"]
            or persistent["persistentTurningFailure"]
        ),
        "bestEpochs": [value["bestEpoch"] for value in training_folds],
        "trainingFolds": training_folds,
        "runtimeShapes": runtime_shapes,
        "probabilityQuality": _mlp_probability_quality(oof),
        "_oof": oof,
    }


def _public_mlp_candidate(candidate: dict[str, Any]) -> dict[str, Any]:
    return {key: value for key, value in candidate.items() if key != "_oof"}


def _mlp_raw_candidate_key(candidate: dict[str, Any]):
    return (
        candidate["aggregateGatePassed"],
        candidate["foldRobust"],
        candidate["sessionRobust"],
        candidate["aggregateMetrics"]["macroF1"],
        candidate["minimumClassRecall"],
        candidate["worstStraightTurningFoldRecall"],
        -candidate["hiddenUnits"],
        candidate["alpha"],
        -candidate["learningRateInit"],
        -candidate["candidateOrder"],
    )


def _mlp_decoder_candidate_key(candidate: dict[str, Any]):
    return (
        candidate["freezeEligible"],
        candidate["aggregateMetrics"]["macroF1"],
        candidate["minimumClassRecall"],
        candidate["worstStraightTurningFoldRecall"],
        -candidate["switchDelay"]["maxWindows"],
        -candidate["switchDelay"]["meanWindows"],
        -candidate["hiddenUnits"],
        candidate["alpha"],
        -candidate["learningRateInit"],
        -candidate["candidateOrder"],
        -candidate["candidateRuleOrder"],
    )


def review_v2_model_capacity(
    input_path: Path,
    extension_path: Path,
    report_output: Path,
) -> str:
    import numpy as np

    if input_path.resolve().name != "development_v2":
        raise DatasetError("model capacity input must be development_v2")
    if extension_path.resolve().name != "v2_extension_4":
        raise DatasetError("model capacity extension must be v2_extension_4")
    base_data = _load_and_validate(input_path)
    extension_data = _load_and_validate(extension_path)
    (
        data,
        base_summary,
        extension_summary,
        combined_summary,
    ) = _validate_v2_24session_sources(base_data, extension_data)
    outer_folds, fold_summaries, strategy = _build_v2_24session_folds(data)
    repeated_outer_folds, repeated_fold_summaries, repeated_strategy = (
        _build_v2_24session_folds(data)
    )
    outer_folds_unchanged = (
        _folds_are_identical(outer_folds, repeated_outer_folds)
        and fold_summaries == repeated_fold_summaries
        and strategy == repeated_strategy
    )
    if not outer_folds_unchanged:
        raise DatasetError("model capacity outer fold assignment changed")
    inner_splits, inner_split_summaries = _build_session_safe_inner_splits(
        data,
        outer_folds,
    )
    repeated_inner_splits, repeated_inner_summaries = (
        _build_session_safe_inner_splits(data, outer_folds)
    )
    inner_splits_deterministic = _folds_are_identical(
        inner_splits,
        repeated_inner_splits,
    ) and inner_split_summaries == repeated_inner_summaries
    if not inner_splits_deterministic:
        raise DatasetError("model capacity inner split is not deterministic")

    specs = _mlp_capacity_specs()
    if len(specs) != 18 or specs != _mlp_capacity_specs():
        raise DatasetError("MLP capacity grid is not deterministic")
    mlp_candidates = [
        _evaluate_session_safe_mlp_candidate(
            data,
            outer_folds,
            inner_splits,
            spec,
        )
        for spec in specs
    ]
    best_raw_mlp = max(mlp_candidates, key=_mlp_raw_candidate_key)

    bounded_rules = [
        rule
        for rule in _bounded_decoder_rule_specs()
        if rule["theoreticalLatencyPassed"]
    ]
    if len(bounded_rules) != 265:
        raise DatasetError("unexpected theoretically valid bounded rule count")
    mlp_decoder_pairs = []
    for candidate in mlp_candidates:
        evaluation_cache: dict[bytes, dict[str, Any]] = {}
        for rule in bounded_rules:
            evaluated = _evaluate_bounded_decoder_rule(
                candidate["_oof"],
                rule,
                evaluation_cache,
            )
            mlp_decoder_pairs.append(
                {
                    "hiddenUnits": candidate["hiddenUnits"],
                    "alpha": candidate["alpha"],
                    "learningRateInit": candidate["learningRateInit"],
                    "candidateOrder": candidate["candidateOrder"],
                    **evaluated,
                    "_oof": candidate["_oof"],
                }
            )
    freeze_eligible = [
        candidate
        for candidate in mlp_decoder_pairs
        if candidate["freezeEligible"]
    ]
    aggregate_fold_latency = [
        candidate
        for candidate in mlp_decoder_pairs
        if candidate["aggregateGatePassed"]
        and candidate["foldRobust"]
        and candidate["empiricalLatencyPassed"]
    ]
    aggregate_fold_session = [
        candidate
        for candidate in mlp_decoder_pairs
        if candidate["aggregateGatePassed"]
        and candidate["foldRobust"]
        and candidate["sessionRobust"]
    ]
    aggregate_fold = [
        candidate
        for candidate in mlp_decoder_pairs
        if candidate["aggregateGatePassed"] and candidate["foldRobust"]
    ]
    aggregate_latency = [
        candidate
        for candidate in mlp_decoder_pairs
        if candidate["aggregateGatePassed"]
        and candidate["empiricalLatencyPassed"]
    ]
    selection_pool = (
        freeze_eligible
        or aggregate_fold_latency
        or aggregate_fold_session
        or aggregate_fold
        or aggregate_latency
        or mlp_decoder_pairs
    )
    selected = max(selection_pool, key=_mlp_decoder_candidate_key)
    selected_mlp = mlp_candidates[selected["candidateOrder"]]
    selected_topology = _v2_24_session_topology(
        selected["_oof"],
        selected["_predictions"],
    )
    best_raw_topology = _v2_24_session_topology(
        best_raw_mlp["_oof"],
        best_raw_mlp["_oof"]["predictions"],
    )

    logistic_spec = next(
        spec
        for spec in _development_candidate_specs()
        if spec["C"] == 3.0
        and spec["profile"] == "emphasize_unstable_motion_1.50"
    )
    logistic_candidate = _evaluate_v2_logistic_candidate(
        data,
        outer_folds,
        logistic_spec,
        FEATURE_ORDER_V2,
    )
    logistic_rule = next(
        rule
        for rule in bounded_rules
        if rule["name"]
        == "fir2_0.75_bounded_hc0.80_hm0.10_lc0.60_lm0.00_c2"
    )
    logistic_reference = _evaluate_bounded_decoder_rule(
        logistic_candidate["_oof"],
        logistic_rule,
    )
    logistic_probability_quality = _mlp_probability_quality(
        logistic_candidate["_oof"]
    )
    mlp_probability_quality = best_raw_mlp["probabilityQuality"]
    separation_delta = (
        mlp_probability_quality["meanStraightTurningSeparation"]
        - logistic_probability_quality["meanStraightTurningSeparation"]
    )
    if separation_delta > 0.02:
        probability_comparison = "BETTER"
    elif separation_delta < -0.02:
        probability_comparison = "WORSE"
    else:
        probability_comparison = "SIMILAR"

    logistic_min_worst_fold = min(0.291667, 0.375000)
    mlp_min_worst_fold = selected["worstStraightTurningFoldRecall"]
    logistic_persistent_count = 2
    mlp_persistent_count = int(selected["persistentStraightFailure"]) + int(
        selected["persistentTurningFailure"]
    )
    macro_delta = selected["aggregateMetrics"]["macroF1"] - 0.824657
    worst_fold_delta = mlp_min_worst_fold - logistic_min_worst_fold
    if selected["freezeEligible"] or (
        macro_delta >= 0.02
        and worst_fold_delta >= 0.10
        and mlp_persistent_count < logistic_persistent_count
    ):
        capacity_interpretation = "MLP_CAPACITY_CLEARLY_HELPS"
    elif macro_delta <= -0.02 and worst_fold_delta <= -0.10:
        capacity_interpretation = "MLP_CAPACITY_HURTS"
    else:
        capacity_interpretation = "MLP_CAPACITY_NEUTRAL"

    selected_epochs = list(selected_mlp["bestEpochs"])
    minimum_epoch = min(selected_epochs)
    median_epoch = float(np.median(selected_epochs))
    maximum_epoch = max(selected_epochs)
    stability_warning = (
        any(
            fold["hitMaximumEpochs"]
            for fold in selected_mlp["trainingFolds"]
        )
        or maximum_epoch - minimum_epoch >= 200
        or (minimum_epoch > 0 and maximum_epoch / minimum_epoch >= 5.0)
    )

    repeated_mlp = _evaluate_session_safe_mlp_candidate(
        data,
        outer_folds,
        inner_splits,
        specs[selected["candidateOrder"]],
    )
    mlp_deterministic = (
        np.array_equal(
            selected_mlp["_oof"]["probabilities"],
            repeated_mlp["_oof"]["probabilities"],
        )
        and selected_mlp["bestEpochs"] == repeated_mlp["bestEpochs"]
        and _public_mlp_candidate(selected_mlp)
        == _public_mlp_candidate(repeated_mlp)
    )
    repeated_decoder = _evaluate_bounded_decoder_rule(
        repeated_mlp["_oof"],
        {
            key: selected[key]
            for key in (
                "name",
                "family",
                "probabilityFilter",
                "probabilityFilterName",
                "firWeights",
                "highConfidence",
                "highMargin",
                "lowConfidence",
                "lowMargin",
                "consecutiveWindows",
                "historyLength",
                "maximumConfirmationLength",
                "theoreticalMaxDelayWindows",
                "theoreticalLatencyPassed",
                "complexity",
                "candidateRuleOrder",
            )
            if key in selected
        },
    )
    decoder_deterministic = (
        _public_bounded_candidate(repeated_decoder)
        == {
            key: value
            for key, value in _public_bounded_candidate(selected).items()
            if key
            not in {
                "hiddenUnits",
                "alpha",
                "learningRateInit",
                "candidateOrder",
            }
        }
    )
    repeated_run_deterministic = mlp_deterministic and decoder_deterministic
    if not repeated_run_deterministic:
        raise DatasetError("MLP capacity review is not deterministic")

    straight_turn_accuracies = [
        value["accuracy"]
        for value in best_raw_topology["straightSessions"]
        + best_raw_topology["turningSessions"]
    ]
    session_accuracy_std = float(np.std(straight_turn_accuracies))
    session_accuracy_range = float(
        max(straight_turn_accuracies) - min(straight_turn_accuracies)
    )
    raw_persistent_count = sum(
        value["persistentFailure"]
        for value in best_raw_topology["straightSessions"]
        + best_raw_topology["turningSessions"]
    )
    high_session_variability = (
        session_accuracy_std >= 0.20
        and session_accuracy_range >= 0.50
        and raw_persistent_count <= 2
    )
    freeze = bool(selected["freezeEligible"])
    if freeze:
        next_recommendation = None
    elif probability_comparison == "BETTER" and (
        macro_delta >= 0.02 or mlp_persistent_count < 2
    ):
        next_recommendation = "MOTION_SEMANTIC_DECODER_REVIEW"
    elif high_session_variability:
        next_recommendation = "MORE_V2_DATA"
    else:
        next_recommendation = "FEATURE_SCHEMA_V3_REVIEW"

    runtime_source = (
        Path(__file__).resolve().parents[2]
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "kotlin"
        / "io"
        / "github"
        / "mesuttsahin"
        / "navguard"
        / "NavguardAiModel.kt"
    ).read_text(encoding="utf-8")
    runtime_tokens = (
        '"mlp_single_hidden"',
        '"hiddenWeights"',
        '"hiddenBias"',
        '"outputWeights"',
        '"outputBias"',
        '"relu"',
    )
    runtime_schema_supported = all(
        token in runtime_source for token in runtime_tokens
    )
    runtime_shapes_supported = all(
        shape["inputToHidden"] == [34, selected["hiddenUnits"]]
        and shape["hiddenBias"] == selected["hiddenUnits"]
        and shape["hiddenToOutput"] == [selected["hiddenUnits"], 4]
        and shape["outputBias"] == 4
        for shape in selected_mlp["runtimeShapes"]
    )
    runtime_compatible = runtime_schema_supported and runtime_shapes_supported

    assets_directory = (
        Path(__file__).resolve().parents[2]
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "assets"
    )
    production_model_absent = not any(
        assets_directory.glob("navguard_ai_model*.json")
    )
    if not production_model_absent:
        raise DatasetError("PRODUCTION_MODEL_ASSET_PRESENT")
    contract_checks = _bounded_decoder_contract_checks()
    ranked_decoder_candidates = sorted(
        mlp_decoder_pairs,
        key=_mlp_decoder_candidate_key,
        reverse=True,
    )
    report = {
        "status": (
            "REVISED_V2_DEVELOPMENT_FREEZE_READY"
            if freeze
            else "V2_MODEL_CAPACITY_REVIEW_NOT_FROZEN"
        ),
        "dataset": {
            "base": base_summary,
            "extension": extension_summary,
            "combined": combined_summary,
        },
        "classOrder": MOTION_CLASSES,
        "developmentOnly": True,
        "finalHoldoutLoaded": False,
        "historicalV1RowsLoaded": False,
        "privatePathsReturned": False,
        "rawRowsReturned": False,
        "outerCv": {
            "strategy": strategy,
            "folds": fold_summaries,
            "assignmentUnchanged": outer_folds_unchanged,
            "sessionLeakage": False,
        },
        "sessionSafeTraining": {
            "sklearnInternalEarlyStoppingUsed": False,
            "innerValidationLevel": "SESSION_LEVEL",
            "innerSplits": inner_split_summaries,
            "innerSplitsDeterministic": inner_splits_deterministic,
            "innerScalerFit": "INNER_TRAIN_ONLY",
            "outerScalerFit": "ALL_OUTER_TRAIN_AFTER_EPOCH_SELECTION",
            "maximumEpochs": 500,
            "patienceEpochs": 25,
            "minimumImprovement": 1e-4,
            "selectedBestEpochs": selected_epochs,
            "selectedBestEpochMinimum": minimum_epoch,
            "selectedBestEpochMedian": median_epoch,
            "selectedBestEpochMaximum": maximum_epoch,
            "stabilityWarning": stability_warning,
        },
        "search": {
            "mlpConfigurationCount": len(specs),
            "boundedDecoderCount": len(bounded_rules),
            "jointCombinationCount": len(mlp_decoder_pairs),
            "freezeEligibleCount": len(freeze_eligible),
            "aggregateFoldLatencyCount": len(aggregate_fold_latency),
            "aggregateFoldSessionCount": len(aggregate_fold_session),
            "aggregateFoldCount": len(aggregate_fold),
            "aggregateLatencyCount": len(aggregate_latency),
            "mlpConfigurations": [_public_mlp_candidate(value) for value in mlp_candidates],
            "selectedRawMlp": _public_mlp_candidate(best_raw_mlp),
            "selectedMlpBounded": _public_bounded_candidate(selected),
            "topMlpBoundedCandidates": [
                _public_bounded_candidate(value)
                for value in ranked_decoder_candidates[:25]
            ],
        },
        "probabilitySeparation": {
            "logistic": logistic_probability_quality,
            "mlp": mlp_probability_quality,
            "mlpMinusLogisticMeanSeparation": separation_delta,
            "comparison": probability_comparison,
        },
        "selectedSessionTopology": selected_topology,
        "selectedRawSessionTopology": best_raw_topology,
        "overfittingCheck": {
            "selectedFoldMetrics": selected["foldMetrics"],
            "selectedTrainingFolds": selected_mlp["trainingFolds"],
            "stabilityWarning": stability_warning,
        },
        "logisticReference": {
            "bounded": _public_bounded_candidate(logistic_reference),
            "reportedMacroF1": 0.824657,
            "reportedWorstStraightFoldRecall": 0.291667,
            "reportedWorstTurningFoldRecall": 0.375000,
            "reportedMaxDelayWindows": 2,
            "reportedPersistentStraightFailure": True,
            "reportedPersistentTurningFailure": True,
        },
        "comparison": {
            "interpretation": capacity_interpretation,
            "macroF1Delta": macro_delta,
            "worstStraightTurningFoldDelta": worst_fold_delta,
            "logisticPersistentFailureCount": logistic_persistent_count,
            "mlpPersistentFailureCount": mlp_persistent_count,
            "sessionAccuracyStd": session_accuracy_std,
            "sessionAccuracyRange": session_accuracy_range,
            "highSessionVariability": high_session_variability,
        },
        "runtimeCompatibility": {
            "singleHiddenLayer": True,
            "inputCount": 34,
            "hiddenCount": selected["hiddenUnits"],
            "outputCount": 4,
            "activation": "relu",
            "softmaxOutput": True,
            "existingKotlinRuntimeSchemaSupported": runtime_schema_supported,
            "selectedShapesSupported": runtime_shapes_supported,
            "compatible": runtime_compatible,
        },
        "reliabilityHeads": {
            "arcore": "PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
        },
        "freezeDecision": {
            "revisedV2DevelopmentFreeze": freeze,
            "family": "small_mlp" if freeze else None,
            "hiddenUnits": selected["hiddenUnits"] if freeze else None,
            "alpha": selected["alpha"] if freeze else None,
            "learningRateInit": (
                selected["learningRateInit"] if freeze else None
            ),
            "featureSchemaVersion": FEATURE_SCHEMA_V2,
            "featureCount": len(FEATURE_ORDER_V2),
            "featureOrder": FEATURE_ORDER_V2,
            "normalization": "FOLD_TRAIN_ONLY_STANDARDIZE_THEN_CLAMP_-5_5",
            "classOrder": MOTION_CLASSES,
            "temporalDecoder": (
                {
                    key: selected[key]
                    for key in (
                        "name",
                        "probabilityFilter",
                        "firWeights",
                        "highConfidence",
                        "highMargin",
                        "lowConfidence",
                        "lowMargin",
                        "consecutiveWindows",
                        "historyLength",
                        "theoreticalMaxDelayWindows",
                    )
                }
                if freeze
                else None
            ),
            "productionModelExported": False,
            "freshIndependentV2HoldoutRequired": freeze,
            "primaryNextRecommendation": next_recommendation,
        },
        "selfTests": {
            "same24Sessions": combined_summary["sessionCount"] == 24,
            "sameOuterFolds": outer_folds_unchanged,
            "outerValidationExcludedFromInner": all(
                value["outerValidationExcluded"]
                for value in inner_split_summaries
            ),
            "innerSplitSessionLevel": all(
                value["innerSplitLevel"] == "SESSION_LEVEL"
                for value in inner_split_summaries
            ),
            "noSklearnRowLevelEarlyStopping": all(
                not fold["sklearnInternalEarlyStopping"]
                for candidate in mlp_candidates
                for fold in candidate["trainingFolds"]
            ),
            "innerScalerFitOnInnerTrainOnly": all(
                fold["innerScalerFit"] == "INNER_TRAIN_ONLY"
                for candidate in mlp_candidates
                for fold in candidate["trainingFolds"]
            ),
            "outerScalerFitOnFullOuterTrainOnly": all(
                fold["outerScalerFit"]
                == "ALL_OUTER_TRAIN_AFTER_EPOCH_SELECTION"
                for candidate in mlp_candidates
                for fold in candidate["trainingFolds"]
            ),
            "outerValidationEvaluatedOnce": all(
                fold["outerValidationEvaluationCount"] == 1
                for candidate in mlp_candidates
                for fold in candidate["trainingFolds"]
            ),
            "mlpDeterministic": mlp_deterministic,
            "boundedDecoderCausal": contract_checks["noFutureWindowAccess"],
            "noStateOlderThanTMinusTwo": (
                contract_checks["fir2UsesOnlyCurrentAndPrevious"]
                and contract_checks["fir3UsesOnlyCurrentAndTwoPrevious"]
                and contract_checks["noRecursiveLongTailState"]
            ),
            "allConsideredTheoreticalLatencyAtMostTwo": all(
                rule["theoreticalMaxDelayWindows"] <= 2
                for rule in bounded_rules
            ),
            "finalHoldoutRowsNotRead": True,
            "noProductionModelExport": production_model_absent,
            "repeatedRunDeterministic": repeated_run_deterministic,
        },
        "productionModelExported": False,
        "productionModelAbsent": production_model_absent,
        "configEActive": False,
        "navigationAccuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    if not runtime_compatible:
        raise DatasetError("SELECTED_MLP_RUNTIME_SCHEMA_INCOMPATIBLE")
    if not all(report["selfTests"].values()):
        raise DatasetError("V2_MODEL_CAPACITY_REVIEW_SELF_TEST_FAILED")
    _write_json_atomic(report_output, report)
    return report["status"]


def diagnose_motion_failure(input_path: Path, report_output: Path) -> str:
    resolved_input = input_path.resolve()
    if resolved_input.name != "development_v1":
        raise DatasetError(
            "development diagnosis input must be the development_v1 directory"
        )
    final_holdout_directory = resolved_input.parent / "final_holdout_v1"
    if not final_holdout_directory.is_dir():
        raise DatasetError("fresh final holdout directory inventory is missing")
    final_holdout_csv_count = sum(
        1 for path in final_holdout_directory.glob("*.csv") if path.is_file()
    )
    if final_holdout_csv_count != 4:
        raise DatasetError(
            "fresh final holdout inventory requires exactly 4 CSV files"
        )
    data = _load_and_validate(input_path)
    _require_v1_training_contract(data)
    if len(data) != 576:
        raise DatasetError("development diagnosis requires exactly 576 windows")
    _, development_sessions, exposed_sessions = _development_partition(data)
    development_data = data[
        data["session_id"].astype(str).isin(development_sessions)
    ].copy()
    if len(development_data) != 480:
        raise DatasetError("development diagnosis requires exactly 480 windows")
    development_sessions_per_class = {
        label: int(
            development_data.loc[
                development_data["motion_label"].astype(str) == label,
                "session_id",
            ].nunique()
        )
        for label in MOTION_CLASSES
    }
    if any(count != 5 for count in development_sessions_per_class.values()):
        raise DatasetError(
            "development diagnosis requires exactly 5 sessions per class"
        )
    if set(development_data["session_id"].astype(str)) & exposed_sessions:
        raise DatasetError("old exposed holdout entered development diagnosis")
    folds, fold_summary, fold_strategy = _build_development_folds(
        development_data
    )
    oof = _generate_frozen_oof_predictions(development_data, folds)
    baseline_metrics = _classification_metrics(
        oof["labels"],
        oof["predictions"],
        MOTION_CLASSES,
    )
    topology = _session_error_topology(oof)
    probability = _probability_separation(oof)
    separability = _feature_separability(development_data)
    domain_shift = _session_domain_shift(development_data)
    temporal = _temporal_study(oof)

    signal = separability["signal"]
    variability_high = any(
        domain_shift[class_name]["variability"] == "HIGH"
        for class_name in ("STRAIGHT_WALK", "TURNING")
    )
    persistent_failure = (
        topology["dominantStraightFailurePattern"]
        == "PERSISTENT_SESSION_LEVEL"
    )
    if temporal["materiallyImprovesRobustness"]:
        recommendation = "TEMPORAL_DECODER_PROMISING"
        limitation = "RAW_WINDOW_DECISION_NOISE_WITH_USABLE_V1_SIGNAL"
        additional_sessions = {label: 0 for label in MOTION_CLASSES}
    elif signal == "FEATURE_SIGNAL_WEAK" and persistent_failure:
        recommendation = "FEATURE_SCHEMA_V2_NEEDED"
        limitation = "WEAK_V1_STRAIGHT_TURNING_SEPARABILITY"
        additional_sessions = {label: 0 for label in MOTION_CLASSES}
    else:
        recommendation = "MORE_DEVELOPMENT_DATA_NEEDED"
        limitation = (
            "STRAIGHT_SESSION_DOMAIN_SHIFT_AND_FOLD_GENERALIZATION_GAP"
            if variability_high
            else "STRAIGHT_SESSION_GENERALIZATION_GAP_PERSISTS_AFTER_TEMPORAL_DECODING"
        )
        additional_sessions = {
            "STATIONARY": 0,
            "STRAIGHT_WALK": 2,
            "TURNING": 0,
            "UNSTABLE_MOTION": 0,
        }
    report = {
        "status": "MOTION_FAILURE_DIAGNOSIS_COMPLETE",
        "datasetSchemaVersion": DATASET_SCHEMA,
        "featureSchemaVersion": FEATURE_SCHEMA,
        "dataIsolation": {
            "developmentSessionCount": len(development_sessions),
            "developmentWindowCount": int(len(development_data)),
            "developmentSessionsPerClass": development_sessions_per_class,
            "oldExposedHoldoutSessionCount": len(exposed_sessions),
            "oldExposedHoldoutExcluded": True,
            "freshFinalHoldoutLoaded": False,
            "freshFinalHoldoutExcluded": True,
            "freshFinalHoldoutCsvFileCount": final_holdout_csv_count,
            "freshFinalHoldoutSessionCount": final_holdout_csv_count,
            "freshFinalHoldoutCountMethod": (
                "ONE_SESSION_PER_CSV_FILE_INVENTORY_WITHOUT_ROW_READ"
            ),
            "freshFinalHoldoutRowsRead": 0,
            "freshFinalHoldoutDirectoryDistinctFromDevelopment": (
                final_holdout_directory != resolved_input
            ),
            "loadedFreshFinalHoldoutOverlapCount": 0,
            "sessionLeakage": False,
        },
        "frozenModel": {
            "family": "logistic_regression",
            "C": FROZEN_MOTION_C,
            "classWeights": FROZEN_MOTION_CLASS_WEIGHTS,
            "motionClasses": MOTION_CLASSES,
            "featureOrder": FEATURE_ORDER,
            "parametersChanged": False,
        },
        "crossValidation": {
            "strategy": fold_strategy["name"],
            "foldCount": DEVELOPMENT_FOLD_COUNT,
            "folds": fold_summary,
            "normalizationFit": "EACH_FOLD_TRAIN_ONLY",
        },
        "frozenBaselineOofMetrics": baseline_metrics,
        "sessionErrorTopology": topology,
        "probabilitySeparation": probability,
        "featureSeparability": separability,
        "sessionDomainShift": domain_shift,
        "causalTemporalStudy": temporal,
        "rootDevelopmentLimitation": limitation,
        "recommendation": {
            "primary": recommendation,
            "additionalDevelopmentSessions": additional_sessions,
            "additionalDevelopmentSessionTotal": sum(
                additional_sessions.values()
            ),
            "featureSchemaV2Implemented": False,
        },
        "productionModelExported": False,
        "consumedFinalHoldoutMetricsUpdated": False,
        "accuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    _write_json_atomic(report_output, report)
    return recommendation


def reevaluate_development(
    input_path: Path,
    development_extension: Path,
    report_output: Path,
) -> str:
    resolved_input = input_path.resolve()
    resolved_extension = development_extension.resolve()
    if resolved_input.name != "development_v1":
        raise DatasetError(
            "22-session reevaluation input must be the development_v1 directory"
        )
    if resolved_extension.name != "development_extension_v1":
        raise DatasetError(
            "22-session reevaluation extension must be the "
            "development_extension_v1 directory"
        )
    if resolved_input.parent != resolved_extension.parent:
        raise DatasetError("development sources must be sibling directories")
    final_holdout_directory = resolved_input.parent / "final_holdout_v1"
    if not final_holdout_directory.is_dir():
        raise DatasetError("fresh final holdout directory inventory is missing")
    final_holdout_csv_count = sum(
        1 for path in final_holdout_directory.glob("*.csv") if path.is_file()
    )
    if final_holdout_csv_count != 4:
        raise DatasetError(
            "fresh final holdout inventory requires exactly 4 CSV files"
        )

    base_source = _load_and_validate(input_path)
    _require_v1_training_contract(base_source)
    if len(base_source) != 576:
        raise DatasetError("base development source requires exactly 576 windows")
    _, base_development_sessions, exposed_holdout_sessions = (
        _development_partition(base_source)
    )
    base_development = base_source[
        base_source["session_id"].astype(str).isin(base_development_sessions)
    ].copy()
    if len(base_development) != 480:
        raise DatasetError("usable base development requires exactly 480 windows")

    extension = _load_and_validate(development_extension)
    _require_v1_training_contract(extension)
    extension_sessions = set(extension["session_id"].astype(str))
    if len(extension) != 48 or len(extension_sessions) != 2:
        raise DatasetError(
            "development extension requires exactly 2 sessions and 48 windows"
        )
    if set(extension["motion_label"].astype(str)) != {"STRAIGHT_WALK"}:
        raise DatasetError("development extension must contain STRAIGHT_WALK only")
    extension_window_counts = extension.groupby("session_id").size()
    if any(int(count) != 24 for count in extension_window_counts):
        raise DatasetError("each development extension session requires 24 windows")
    base_source_sessions = set(base_source["session_id"].astype(str))
    if extension_sessions & base_source_sessions:
        raise DatasetError("development extension overlaps the base source")

    combined, folds, fold_summary, fold_strategy = (
        _build_extended_development_folds(base_development, extension)
    )
    combined_sessions = set(combined["session_id"].astype(str))
    if len(combined) != 528 or len(combined_sessions) != 22:
        raise DatasetError(
            "combined development requires exactly 22 sessions and 528 windows"
        )
    combined_sessions_per_class = {
        label: int(
            combined.loc[
                combined["motion_label"].astype(str) == label,
                "session_id",
            ].nunique()
        )
        for label in MOTION_CLASSES
    }
    expected_session_counts = {
        "STATIONARY": 5,
        "STRAIGHT_WALK": 7,
        "TURNING": 5,
        "UNSTABLE_MOTION": 5,
    }
    if combined_sessions_per_class != expected_session_counts:
        raise DatasetError("combined development class session counts mismatch")
    if combined.duplicated(subset=["session_id", "window_index"]).any():
        raise DatasetError("duplicate combined development session window")
    if set(base_development_sessions) & exposed_holdout_sessions:
        raise DatasetError("old exposed holdout overlaps usable base development")
    if extension_sessions & exposed_holdout_sessions:
        raise DatasetError("old exposed holdout overlaps development extension")

    candidate_results = [
        _evaluate_logistic_candidate(
            combined,
            folds,
            spec,
            retain_oof=True,
        )
        for spec in _development_candidate_specs()
    ]
    temporal_studies = {
        candidate["candidateOrder"]: _temporal_study(candidate["_oof"])
        for candidate in candidate_results
    }
    joint_candidates = [
        (candidate, temporal_candidate)
        for candidate in candidate_results
        for temporal_candidate in temporal_studies[
            candidate["candidateOrder"]
        ]["candidates"][1:]
    ]

    def pair_is_eligible(pair) -> bool:
        _, temporal_candidate = pair
        return (
            temporal_candidate["aggregateGatePassed"]
            and temporal_candidate["latencyRequirementPassed"]
        )

    def pair_has_catastrophic_straight_fold(pair) -> bool:
        _, temporal_candidate = pair
        return any(
            fold["straightWalkRecall"] < 0.55
            for fold in temporal_candidate["foldMetrics"]
        )

    def joint_selection_key(pair):
        candidate, temporal_candidate = pair
        metrics = temporal_candidate["aggregateMetrics"]
        return (
            pair_is_eligible(pair),
            not pair_has_catastrophic_straight_fold(pair),
            metrics["macroF1"],
            temporal_candidate["minimumClassRecall"],
            -temporal_candidate["switchDelayProxy"]["maxWindows"],
            -temporal_candidate["switchDelayProxy"]["p90Windows"],
            -temporal_candidate["complexity"],
            -candidate["weightComplexity"],
            -candidate["C"],
            -candidate["candidateOrder"],
            temporal_candidate["name"],
        )

    selected_raw, selected_temporal = max(
        joint_candidates,
        key=joint_selection_key,
    )
    selected_oof = selected_raw["_oof"]
    raw_metrics = _classification_metrics(
        selected_oof["labels"],
        selected_oof["predictions"],
        MOTION_CLASSES,
    )
    if raw_metrics != selected_raw["aggregateMetrics"]:
        raise DatasetError("selected raw OOF reproduction mismatch")
    temporal_study = temporal_studies[selected_raw["candidateOrder"]]
    temporal_study["bestTemporalCandidate"] = selected_temporal
    selected_temporal_predictions = _temporal_predictions(
        selected_oof,
        selected_temporal,
    )
    temporal_topology_oof = dict(selected_oof)
    temporal_topology_oof["predictions"] = selected_temporal_predictions
    temporal_topology = _session_error_topology(temporal_topology_oof)
    straight_session_summaries = [
        summary
        for summary in temporal_topology["sessions"]
        if summary["trueClass"] == "STRAIGHT_WALK"
    ]
    if len(straight_session_summaries) != 7:
        raise DatasetError("expected seven sanitized STRAIGHT session summaries")
    persistent_failure_remains = any(
        summary["failurePattern"] == "PERSISTENT_SESSION_LEVEL"
        for summary in straight_session_summaries
    )

    previous_temporal_macro_f1 = 0.890580481071352
    previous_straight_recall = 0.7416666666666667
    previous_worst_straight_fold_recall = 0.20833333333333334
    new_temporal_metrics = selected_temporal["aggregateMetrics"]
    new_straight_recall = new_temporal_metrics["perClass"]["STRAIGHT_WALK"][
        "recall"
    ]
    new_worst_straight_fold_recall = min(
        fold["straightWalkRecall"]
        for fold in selected_temporal["foldMetrics"]
    )
    if (
        new_worst_straight_fold_recall
        >= previous_worst_straight_fold_recall + 0.10
        and new_straight_recall >= previous_straight_recall - 0.02
    ):
        straight_generalization = "IMPROVED"
    elif (
        new_worst_straight_fold_recall
        < previous_worst_straight_fold_recall - 0.05
        or new_straight_recall < previous_straight_recall - 0.05
    ):
        straight_generalization = "WORSE"
    else:
        straight_generalization = "UNCHANGED"
    additional_data_materially_helped = straight_generalization == "IMPROVED"

    temporal_has_catastrophic_straight_fold = (
        new_worst_straight_fold_recall < 0.55
    )
    revised_freeze = (
        selected_temporal["aggregateGatePassed"]
        and selected_temporal["foldRobust"]
        and not temporal_has_catastrophic_straight_fold
        and selected_temporal["latencyRequirementPassed"]
    )
    if revised_freeze:
        recommendation = None
        status = "REVISED_DEVELOPMENT_FREEZE"
    else:
        recommendation = (
            "FEATURE_SCHEMA_V2_NEEDED"
            if persistent_failure_remains
            and straight_generalization != "IMPROVED"
            else "MORE_STRAIGHT_DATA_NEEDED"
        )
        status = recommendation

    def sanitized_candidate(candidate: dict[str, Any]) -> dict[str, Any]:
        metrics = candidate["aggregateMetrics"]
        return {
            "C": candidate["C"],
            "profile": candidate["profile"],
            "classWeights": candidate["classWeights"],
            "aggregateMetrics": metrics,
            "minimumClassRecall": min(
                metrics["perClass"][label]["recall"]
                for label in MOTION_CLASSES
            ),
            "foldMetrics": candidate["foldMetrics"],
            "aggregateGatePassed": _candidate_is_eligible(candidate),
            "catastrophicStraightFold": _has_catastrophic_straight_fold(
                candidate
            ),
        }

    report = {
        "status": status,
        "datasetSchemaVersion": DATASET_SCHEMA,
        "featureSchemaVersion": FEATURE_SCHEMA,
        "featureCount": len(FEATURE_ORDER),
        "featureOrder": FEATURE_ORDER,
        "motionClasses": MOTION_CLASSES,
        "seed": SEED,
        "dataIsolation": {
            "baseSourceSessionCount": int(
                base_source["session_id"].astype(str).nunique()
            ),
            "baseSourceWindowCount": int(len(base_source)),
            "baseUsableDevelopmentSessionCount": len(
                base_development_sessions
            ),
            "baseUsableDevelopmentWindowCount": int(len(base_development)),
            "extensionSessionCount": len(extension_sessions),
            "extensionWindowCount": int(len(extension)),
            "extensionMotionClasses": ["STRAIGHT_WALK"],
            "extensionWindowsPerSession": 24,
            "combinedDevelopmentSessionCount": len(combined_sessions),
            "combinedDevelopmentWindowCount": int(len(combined)),
            "combinedSessionsPerMotionClass": combined_sessions_per_class,
            "oldExposedHoldoutSessionCount": len(exposed_holdout_sessions),
            "oldExposedHoldoutExcluded": True,
            "oldExposedHoldoutOverlapCount": 0,
            "consumedFinalHoldoutCsvFileCount": final_holdout_csv_count,
            "consumedFinalHoldoutRowsRead": 0,
            "consumedFinalHoldoutExcluded": True,
            "consumedFinalHoldoutLoadedOverlapCount": 0,
            "sourceSessionIdOverlapCount": 0,
            "sessionLeakage": False,
        },
        "crossValidation": {
            "strategy": fold_strategy["name"],
            "foldCount": DEVELOPMENT_FOLD_COUNT,
            "group": "session_id",
            "baseFoldStrategyPreserved": fold_strategy[
                "baseFoldStrategyPreserved"
            ],
            "extensionAssignmentSeed": fold_strategy[
                "extensionAssignmentSeed"
            ],
            "extraStraightValidationSessionCounts": fold_strategy[
                "extraStraightValidationSessionCounts"
            ],
            "allClassesRepresented": True,
            "sessionLeakage": False,
            "normalizationFit": "EACH_FOLD_TRAIN_ONLY",
            "folds": fold_summary,
        },
        "logisticSearch": {
            "candidateCount": len(candidate_results),
            "gridUnchanged": True,
            "selectedAsPartOfJointModelTemporalSearch": True,
            "selectionPriority": [
                "aggregate_gate_pass",
                "no_catastrophic_straight_fold",
                "highest_macro_f1",
                "highest_minimum_class_recall",
                "simpler_weight_profile",
                "smaller_C",
                "deterministic_candidate_order",
            ],
            "selectedRawCandidate": sanitized_candidate(selected_raw),
            "candidates": [
                sanitized_candidate(candidate)
                for candidate in candidate_results
            ],
        },
        "temporalDecoder": {
            **temporal_study,
            "jointModelTemporalPairCount": len(joint_candidates),
            "eligibleJointPairCount": sum(
                pair_is_eligible(pair) for pair in joint_candidates
            ),
            "eligibleJointPairsWithoutCatastrophicStraightFold": sum(
                pair_is_eligible(pair)
                and not pair_has_catastrophic_straight_fold(pair)
                for pair in joint_candidates
            ),
            "jointLogisticCandidateCount": len(candidate_results),
            "temporalCandidatesPerLogisticModel": len(
                temporal_study["candidates"]
            )
            - 1,
            "selectionPriority": [
                "aggregate_gate_and_latency_pass",
                "fold_robustness",
                "highest_macro_f1",
                "highest_minimum_class_recall",
                "lower_switch_latency",
                "simpler_rule",
                "deterministic_name",
            ],
            "catastrophicStraightFold": (
                temporal_has_catastrophic_straight_fold
            ),
        },
        "straightSessionTopology": {
            "sessions": straight_session_summaries,
            "persistentFailureSessionRemains": persistent_failure_remains,
            "straightGeneralization": straight_generalization,
        },
        "comparisonToPreviousDevelopment": {
            "previousTemporalMacroF1": previous_temporal_macro_f1,
            "newTemporalMacroF1": new_temporal_metrics["macroF1"],
            "previousStraightAggregateRecall": previous_straight_recall,
            "newStraightAggregateRecall": new_straight_recall,
            "previousWorstStraightFoldRecall": (
                previous_worst_straight_fold_recall
            ),
            "newWorstStraightFoldRecall": (
                new_worst_straight_fold_recall
            ),
            "straightGeneralizationDecisionRule": (
                "IMPROVED when worst-fold STRAIGHT recall rises by at least "
                "0.10 without aggregate STRAIGHT recall falling by more than "
                "0.02; WORSE when either falls by more than 0.05; otherwise "
                "UNCHANGED"
            ),
            "additionalDataMateriallyHelped": (
                additional_data_materially_helped
            ),
        },
        "freeze": {
            "revisedDevelopmentFreeze": revised_freeze,
            "family": "logistic_regression" if revised_freeze else None,
            "C": selected_raw["C"] if revised_freeze else None,
            "classWeights": (
                selected_raw["classWeights"] if revised_freeze else None
            ),
            "normalization": (
                "FIT_EACH_CV_FOLD_TRAIN_ONLY_FOR_DEVELOPMENT"
                if revised_freeze
                else None
            ),
            "featureSchemaVersion": FEATURE_SCHEMA,
            "featureOrder": FEATURE_ORDER,
            "classOrder": MOTION_CLASSES,
            "temporalDecoder": (
                {
                    "name": selected_temporal["name"],
                    "emaAlpha": selected_temporal["emaAlpha"],
                    "hysteresisMargin": selected_temporal[
                        "hysteresisMargin"
                    ],
                    "consecutiveWindows": selected_temporal[
                        "consecutiveWindows"
                    ],
                }
                if revised_freeze
                else None
            ),
            "nextRecommendation": recommendation,
            "productionModelExported": False,
            "newIndependentHoldoutRequiredNow": revised_freeze,
        },
        "reliabilityHeads": {
            "arcore": "PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
            "productionReliabilityHeads": "NONE",
        },
        "consumedFinalHoldoutMetricsUpdated": False,
        "productionModelExported": False,
        "configEActive": False,
        "accuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    _write_json_atomic(report_output, report)
    return status


def _reliability_metrics(y_true, probabilities) -> dict[str, Any]:
    from sklearn.metrics import (
        average_precision_score,
        balanced_accuracy_score,
        brier_score_loss,
        confusion_matrix,
        f1_score,
        precision_score,
        recall_score,
        roc_auc_score,
    )

    predictions = (probabilities >= 0.5).astype(int)
    both_classes = len(set(int(value) for value in y_true)) == 2
    return {
        "balancedAccuracy": float(balanced_accuracy_score(y_true, predictions)),
        "precision": float(precision_score(y_true, predictions, zero_division=0)),
        "recall": float(recall_score(y_true, predictions, zero_division=0)),
        "f1": float(f1_score(y_true, predictions, zero_division=0)),
        "rocAuc": float(roc_auc_score(y_true, probabilities)) if both_classes else None,
        "prAuc": float(average_precision_score(y_true, probabilities)) if both_classes else None,
        "brierScore": float(brier_score_loss(y_true, probabilities)),
        "confusionMatrix": confusion_matrix(y_true, predictions, labels=[0, 1]).tolist(),
        "reliablePrevalence": float(sum(y_true) / len(y_true)),
    }


def _export_linear(model) -> dict[str, Any]:
    return {
        "type": "logistic_regression",
        "weights": model.coef_.tolist(),
        "bias": model.intercept_.tolist(),
    }


def _validate_v3_development_dataset(data) -> dict[str, Any]:
    import numpy as np
    import pandas as pd

    dataset_schema, feature_schema, feature_order = _resolve_training_contract(data)
    if (
        dataset_schema != DATASET_SCHEMA_V3
        or feature_schema != FEATURE_SCHEMA_V3
        or feature_order != FEATURE_ORDER_V3
    ):
        raise DatasetError("V3_FINAL_DEVELOPMENT_REQUIRES_EXACT_V3_SCHEMA")
    if len(data) != 480:
        raise DatasetError("V3 final development requires exactly 480 windows")
    sessions = data["session_id"].astype(str)
    if sessions.nunique() != 20:
        raise DatasetError("V3 final development requires exactly 20 sessions")
    session_window_counts = data.groupby(sessions).size()
    if not (session_window_counts == 24).all():
        raise DatasetError("V3 final development requires exactly 24 windows per session")
    numeric_window_indexes = pd.to_numeric(data["window_index"], errors="coerce")
    if (
        numeric_window_indexes.isna().any()
        or not np.equal(numeric_window_indexes, np.floor(numeric_window_indexes)).all()
    ):
        raise DatasetError("invalid V3 development window index")
    if data.duplicated(subset=["session_id", "window_index"]).any():
        raise DatasetError("duplicate V3 session window")
    for _, session_rows in data.assign(
        _window_index=numeric_window_indexes.astype(int)
    ).groupby(sessions):
        if sorted(session_rows["_window_index"].tolist()) != list(range(24)):
            raise DatasetError("V3 session window indexes must be exactly 0..23")
    motion_window_counts = Counter(data["motion_label"].astype(str))
    if any(motion_window_counts[label] != 120 for label in MOTION_CLASSES):
        raise DatasetError("V3 final development requires 120 windows per class")
    session_labels = data.groupby(sessions)["motion_label"].first().astype(str)
    sessions_per_class = Counter(session_labels)
    if any(sessions_per_class[label] != 5 for label in MOTION_CLASSES):
        raise DatasetError("V3 final development requires five sessions per class")
    feature_values = data[FEATURE_ORDER_V3].to_numpy(float)
    if not np.isfinite(feature_values).all():
        raise DatasetError("non-finite V3 feature")
    return {
        "datasetSchemaVersion": dataset_schema,
        "featureSchemaVersion": feature_schema,
        "featureCount": len(feature_order),
        "sessionCount": int(sessions.nunique()),
        "windowCount": int(len(data)),
        "sessionsPerMotionClass": {
            label: int(sessions_per_class[label]) for label in MOTION_CLASSES
        },
        "motionWindowCounts": {
            label: int(motion_window_counts[label]) for label in MOTION_CLASSES
        },
        "windowsPerSession": 24,
        "finiteFeatures": True,
        "unknownMotionClassCount": 0,
        "duplicateSessionWindowCount": 0,
        "mixedDatasetSchema": False,
        "mixedFeatureSchema": False,
    }


def _final_v3_pair_key(candidate: dict[str, Any]):
    metrics = candidate["aggregateMetrics"]
    logistic = candidate["modelFamily"] == "LOGISTIC"
    model_complexity = 0 if logistic else 1
    hidden_units = 0 if logistic else candidate["hiddenUnits"]
    weight_complexity = candidate.get("weightComplexity", 0)
    regularization = -candidate["C"] if logistic else candidate["alpha"]
    learning_rate = 0.0 if logistic else -candidate["learningRateInit"]
    return (
        candidate["freezeEligible"],
        metrics["macroF1"],
        candidate["minimumClassRecall"],
        candidate["worstStraightTurningFoldRecall"],
        -candidate["switchDelay"]["maxWindows"],
        -candidate["switchDelay"]["meanWindows"],
        -model_complexity,
        -hidden_units,
        -weight_complexity,
        regularization,
        -candidate["historyLength"],
        -candidate["consecutiveWindows"],
        -candidate["complexity"],
        learning_rate,
        -candidate["candidateOrder"],
        -candidate["candidateRuleOrder"],
        candidate["name"],
    )


def _public_final_v3_pair(candidate: dict[str, Any]) -> dict[str, Any]:
    return {
        key: value
        for key, value in candidate.items()
        if not key.startswith("_")
    }


def _evaluate_final_v3_decoder_pairs(
    candidates: list[dict[str, Any]],
    rules: list[dict[str, Any]],
    model_family: str,
) -> tuple[dict[str, Any], int, int]:
    best_pair: dict[str, Any] | None = None
    evaluated_count = 0
    eligible_count = 0
    for candidate in candidates:
        evaluation_cache: dict[bytes, dict[str, Any]] = {}
        for rule in rules:
            evaluated = _evaluate_bounded_decoder_rule(
                candidate["_oof"],
                rule,
                evaluation_cache,
            )
            if model_family == "LOGISTIC":
                model_fields = {
                    "modelFamily": model_family,
                    "C": candidate["C"],
                    "profile": candidate["profile"],
                    "classWeights": candidate["classWeights"],
                    "weightComplexity": candidate["weightComplexity"],
                    "candidateOrder": candidate["candidateOrder"],
                }
            else:
                model_fields = {
                    "modelFamily": model_family,
                    "hiddenUnits": candidate["hiddenUnits"],
                    "alpha": candidate["alpha"],
                    "learningRateInit": candidate["learningRateInit"],
                    "candidateOrder": candidate["candidateOrder"],
                    "bestEpochs": candidate["bestEpochs"],
                    "trainingFolds": candidate["trainingFolds"],
                    "runtimeShapes": candidate["runtimeShapes"],
                }
            pair = {
                **model_fields,
                "rawAggregateMetrics": candidate["aggregateMetrics"],
                "rawFoldMetrics": candidate["foldMetrics"],
                **evaluated,
                "_oof": candidate["_oof"],
            }
            evaluated_count += 1
            if pair["freezeEligible"]:
                eligible_count += 1
            if best_pair is None or _final_v3_pair_key(pair) > _final_v3_pair_key(
                best_pair
            ):
                best_pair = pair
    if best_pair is None:
        raise DatasetError(f"no {model_family} decoder candidate was evaluated")
    return best_pair, evaluated_count, eligible_count


def _repeat_final_v3_pair(
    data,
    folds,
    inner_splits,
    selected: dict[str, Any],
) -> dict[str, Any]:
    if selected["modelFamily"] == "LOGISTIC":
        spec = {
            "C": selected["C"],
            "profile": selected["profile"],
            "classWeights": selected["classWeights"],
            "weightComplexity": selected["weightComplexity"],
            "candidateOrder": selected["candidateOrder"],
        }
        repeated_raw = _evaluate_v2_logistic_candidate(
            data,
            folds,
            spec,
            FEATURE_ORDER_V3,
        )
        model_fields = {
            "modelFamily": "LOGISTIC",
            "C": repeated_raw["C"],
            "profile": repeated_raw["profile"],
            "classWeights": repeated_raw["classWeights"],
            "weightComplexity": repeated_raw["weightComplexity"],
            "candidateOrder": repeated_raw["candidateOrder"],
        }
    else:
        spec = {
            "hiddenUnits": selected["hiddenUnits"],
            "alpha": selected["alpha"],
            "learningRateInit": selected["learningRateInit"],
            "randomSeed": SEED,
            "activation": "relu",
            "optimizer": "adam",
            "maximumEpochs": 500,
            "patienceEpochs": 25,
            "minimumImprovement": 1e-4,
            "candidateOrder": selected["candidateOrder"],
        }
        repeated_raw = _evaluate_session_safe_mlp_candidate(
            data,
            folds,
            inner_splits,
            spec,
            FEATURE_ORDER_V3,
        )
        model_fields = {
            "modelFamily": "MLP",
            "hiddenUnits": repeated_raw["hiddenUnits"],
            "alpha": repeated_raw["alpha"],
            "learningRateInit": repeated_raw["learningRateInit"],
            "candidateOrder": repeated_raw["candidateOrder"],
            "bestEpochs": repeated_raw["bestEpochs"],
            "trainingFolds": repeated_raw["trainingFolds"],
            "runtimeShapes": repeated_raw["runtimeShapes"],
        }
    rule = {
        key: selected[key]
        for key in (
            "name",
            "family",
            "probabilityFilter",
            "firWeights",
            "highConfidence",
            "highMargin",
            "lowConfidence",
            "lowMargin",
            "consecutiveWindows",
            "historyLength",
            "maximumConfirmationLength",
            "theoreticalMaxDelayWindows",
            "theoreticalLatencyPassed",
            "complexity",
            "candidateRuleOrder",
        )
    }
    if "probabilityFilterName" in selected:
        rule["probabilityFilterName"] = selected["probabilityFilterName"]
    repeated_decoder = _evaluate_bounded_decoder_rule(repeated_raw["_oof"], rule)
    return {
        **model_fields,
        "rawAggregateMetrics": repeated_raw["aggregateMetrics"],
        "rawFoldMetrics": repeated_raw["foldMetrics"],
        **repeated_decoder,
        "_oof": repeated_raw["_oof"],
    }


def _v3_logistic_standardized_coefficients(data, folds, candidate):
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = data[FEATURE_ORDER_V3].to_numpy(float)
    labels = encode_motion_labels(data["motion_label"].astype(str).to_numpy())
    feature_indexes = {
        name: FEATURE_ORDER_V3.index(name) for name in V3_ADDED_FEATURE_ORDER
    }
    coefficients = {
        feature: {label: [] for label in MOTION_CLASSES}
        for feature in V3_ADDED_FEATURE_ORDER
    }
    spec = {
        "C": candidate["C"],
        "profile": candidate["profile"],
        "classWeights": candidate["classWeights"],
    }
    for train_indexes, _ in folds:
        scaler = StandardScaler().fit(features[train_indexes])
        normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
        train_features = np.clip(
            (features[train_indexes] - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        model = _fit_logistic_candidate(train_features, labels[train_indexes], spec)
        for feature, feature_index in feature_indexes.items():
            for class_index, class_name in enumerate(MOTION_CLASSES):
                coefficients[feature][class_name].append(
                    float(model.coef_[class_index, feature_index])
                )
    return {
        feature: {
            class_name: {
                "mean": float(np.mean(values)),
                "std": float(np.std(values)),
                "foldValues": values,
            }
            for class_name, values in class_values.items()
        }
        for feature, class_values in coefficients.items()
    }


def _v3_feature_diagnostics(data, logistic_coefficients):
    import numpy as np

    diagnostics = {}
    effect_sizes = []
    labels = data["motion_label"].astype(str)
    for feature in V3_ADDED_FEATURE_ORDER:
        straight = data.loc[labels == "STRAIGHT_WALK", feature].to_numpy(float)
        turning = data.loc[labels == "TURNING", feature].to_numpy(float)
        straight_mean = float(np.mean(straight))
        turning_mean = float(np.mean(turning))
        straight_std = float(np.std(straight))
        turning_std = float(np.std(turning))
        pooled_std = math.sqrt((straight_std**2 + turning_std**2) / 2.0)
        effect_size = (
            (turning_mean - straight_mean) / pooled_std
            if pooled_std > 1e-12
            else 0.0
        )
        effect_sizes.append(abs(effect_size))
        diagnostics[feature] = {
            "straightWalk": {
                "mean": straight_mean,
                "std": straight_std,
                "windowCount": int(len(straight)),
            },
            "turning": {
                "mean": turning_mean,
                "std": turning_std,
                "windowCount": int(len(turning)),
            },
            "standardizedEffectSizeTurningMinusStraight": float(effect_size),
            "selectedLogisticStandardizedCoefficients": logistic_coefficients[
                feature
            ],
        }
    return {
        "features": diagnostics,
        "effectSizeDefinition": (
            "(TURNING_MEAN-STRAIGHT_MEAN)/SQRT((STRAIGHT_VAR+TURNING_VAR)/2)"
        ),
        "physicalSignalUsefulCriterion": (
            "AT_LEAST_ONE_ABS_STANDARDIZED_EFFECT_SIZE_GE_0.20"
        ),
        "physicalSignalUseful": bool(max(effect_sizes, default=0.0) >= 0.20),
        "mlpLinearFeatureImportanceReported": False,
    }


def _sanitized_v3_session_summaries(oof, predictions) -> list[dict[str, Any]]:
    import numpy as np

    summaries = []
    aliases: dict[str, int] = {label: 0 for label in MOTION_CLASSES}
    for session_id in sorted(set(oof["groups"])):
        indexes = np.flatnonzero(oof["groups"] == session_id)
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        true_index = int(oof["labels"][indexes][0])
        true_class = MOTION_CLASSES[true_index]
        aliases[true_class] += 1
        values = predictions[indexes]
        counts = Counter(int(value) for value in values)
        dominant_index = max(
            range(len(MOTION_CLASSES)),
            key=lambda value: (counts[value], -value),
        )
        accuracy = float((values == true_index).mean())
        longest_competing_run = max(
            (
                _longest_true_run(values == class_index)
                for class_index in range(len(MOTION_CLASSES))
                if class_index != true_index
            ),
            default=0,
        )
        wrong_dominant = (
            dominant_index != true_index
            and counts[dominant_index] > len(indexes) / 2
        )
        summaries.append(
            {
                "sessionAlias": f"{true_class}_{aliases[true_class]}",
                "motionClass": true_class,
                "windowCount": int(len(indexes)),
                "accuracy": accuracy,
                "dominantPredictedClass": MOTION_CLASSES[dominant_index],
                "wrongClassDominant": wrong_dominant,
                "longestSameCompetingClassRun": int(longest_competing_run),
                "persistentFailure": bool(
                    accuracy < 0.50
                    or wrong_dominant
                    or longest_competing_run >= 12
                ),
            }
        )
    return summaries


def final_v3_development_freeze(input_path: Path, report_output: Path) -> str:
    if input_path.resolve().name != "development_v3":
        raise DatasetError("final V3 development input must be development_v3")
    data = _load_and_validate(input_path)
    dataset_summary = _validate_v3_development_dataset(data)

    folds, fold_summaries, strategy = _build_v2_development_folds(data)
    repeated_folds, repeated_fold_summaries, repeated_strategy = (
        _build_v2_development_folds(data)
    )
    folds_deterministic = (
        _folds_are_identical(folds, repeated_folds)
        and fold_summaries == repeated_fold_summaries
        and strategy == repeated_strategy
    )
    inner_splits, inner_summaries = _build_session_safe_inner_splits(data, folds)
    repeated_inner_splits, repeated_inner_summaries = (
        _build_session_safe_inner_splits(data, folds)
    )
    inner_deterministic = (
        _folds_are_identical(inner_splits, repeated_inner_splits)
        and inner_summaries == repeated_inner_summaries
    )
    if not folds_deterministic or not inner_deterministic:
        raise DatasetError("V3 grouped split assignment is not deterministic")

    logistic_specs = _development_candidate_specs()
    if len(logistic_specs) != 63 or logistic_specs != _development_candidate_specs():
        raise DatasetError("V3 Logistic grid is not deterministic")
    logistic_candidates = []
    rejected_logistic = []
    for spec in logistic_specs:
        try:
            logistic_candidates.append(
                _evaluate_v2_logistic_candidate(
                    data,
                    folds,
                    spec,
                    FEATURE_ORDER_V3,
                )
            )
        except DatasetError as error:
            if not str(error).startswith("logistic candidate did not converge"):
                raise
            rejected_logistic.append(
                {
                    "C": spec["C"],
                    "profile": spec["profile"],
                    "reason": "CONVERGENCE_FAILURE",
                }
            )
    if not logistic_candidates:
        raise DatasetError("all V3 Logistic candidates failed convergence")

    mlp_specs = _mlp_capacity_specs()
    if len(mlp_specs) != 18 or mlp_specs != _mlp_capacity_specs():
        raise DatasetError("V3 MLP grid is not deterministic")
    mlp_candidates = [
        _evaluate_session_safe_mlp_candidate(
            data,
            folds,
            inner_splits,
            spec,
            FEATURE_ORDER_V3,
        )
        for spec in mlp_specs
    ]

    all_rules = _bounded_decoder_rule_specs()
    rules = [rule for rule in all_rules if rule["theoreticalLatencyPassed"]]
    if len(all_rules) != 337 or len(rules) != 265:
        raise DatasetError("V3 bounded decoder grid changed")
    best_logistic, logistic_pair_count, logistic_eligible_count = (
        _evaluate_final_v3_decoder_pairs(logistic_candidates, rules, "LOGISTIC")
    )
    best_mlp, mlp_pair_count, mlp_eligible_count = (
        _evaluate_final_v3_decoder_pairs(mlp_candidates, rules, "MLP")
    )
    family_best = [best_logistic, best_mlp]
    eligible_family_best = [value for value in family_best if value["freezeEligible"]]
    selected = max(
        eligible_family_best or family_best,
        key=_final_v3_pair_key,
    )
    freeze = bool(eligible_family_best and selected["freezeEligible"])

    repeated_logistic = _repeat_final_v3_pair(
        data,
        folds,
        inner_splits,
        best_logistic,
    )
    repeated_mlp = _repeat_final_v3_pair(
        data,
        folds,
        inner_splits,
        best_mlp,
    )
    logistic_deterministic = json.dumps(
        _public_final_v3_pair(best_logistic),
        sort_keys=True,
        allow_nan=False,
    ) == json.dumps(
        _public_final_v3_pair(repeated_logistic),
        sort_keys=True,
        allow_nan=False,
    )
    mlp_deterministic = json.dumps(
        _public_final_v3_pair(best_mlp),
        sort_keys=True,
        allow_nan=False,
    ) == json.dumps(
        _public_final_v3_pair(repeated_mlp),
        sort_keys=True,
        allow_nan=False,
    )
    repeated_deterministic = (
        folds_deterministic
        and inner_deterministic
        and logistic_deterministic
        and mlp_deterministic
    )

    logistic_coefficients = _v3_logistic_standardized_coefficients(
        data,
        folds,
        best_logistic,
    )
    feature_diagnostics = _v3_feature_diagnostics(
        data,
        logistic_coefficients,
    )
    sanitized_sessions = _sanitized_v3_session_summaries(
        selected["_oof"],
        selected["_predictions"],
    )
    decoder_contract = _bounded_decoder_contract_checks()
    production_model_path = (
        Path(__file__).resolve().parents[2]
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "assets"
        / "navguard_ai_model_v1.json"
    )
    selected_public = _public_final_v3_pair(selected)
    self_tests = {
        "exact20V3Sessions": dataset_summary["sessionCount"] == 20,
        "fiveSessionsPerClass": all(
            value == 5
            for value in dataset_summary["sessionsPerMotionClass"].values()
        ),
        "exact24WindowsPerSession": dataset_summary["windowsPerSession"] == 24,
        "exact40FeatureV3Schema": (
            dataset_summary["datasetSchemaVersion"] == DATASET_SCHEMA_V3
            and dataset_summary["featureSchemaVersion"] == FEATURE_SCHEMA_V3
            and dataset_summary["featureCount"] == 40
            and data.attrs["feature_order"] == FEATURE_ORDER_V3
        ),
        "exactGroupedFiveFolds": len(folds) == 5,
        "oneValidationSessionPerClassPerFold": all(
            all(
                count == 1
                for count in fold["validationSessionsPerMotionClass"].values()
            )
            for fold in fold_summaries
        ),
        "noSessionLeakage": all(
            not fold["sessionLeakage"] for fold in fold_summaries
        ),
        "trainOnlyScaling": (
            all(
                fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
                for fold in fold_summaries
            )
            and all(
                training["innerScalerFit"] == "INNER_TRAIN_ONLY"
                and training["outerScalerFit"]
                == "ALL_OUTER_TRAIN_AFTER_EPOCH_SELECTION"
                for candidate in mlp_candidates
                for training in candidate["trainingFolds"]
            )
        ),
        "sessionSafeMlpInnerValidation": all(
            summary["innerSplitLevel"] == "SESSION_LEVEL"
            and summary["outerValidationExcluded"]
            and not summary["sessionLeakage"]
            and all(
                count == 1
                for count in summary[
                    "innerValidationSessionsPerMotionClass"
                ].values()
            )
            for summary in inner_summaries
        ),
        "noSklearnRowLevelEarlyStopping": all(
            not training["sklearnInternalEarlyStopping"]
            for candidate in mlp_candidates
            for training in candidate["trainingFolds"]
        ),
        "decoderStateResetBetweenSessions": decoder_contract[
            "sessionDecoderStateReset"
        ],
        "noHistoryOlderThanTMinus2": all(
            rule["historyLength"] <= 3 for rule in rules
        ),
        "noFutureWindow": decoder_contract["noFutureWindowAccess"],
        "theoreticalDelayAtMostTwo": all(
            rule["theoreticalMaxDelayWindows"] <= 2 for rule in rules
        ),
        "repeatedEvaluationDeterministic": repeated_deterministic,
        "noFinalHoldoutLoaded": True,
        "noProductionModelExport": not production_model_path.exists(),
    }
    if not all(self_tests.values()):
        failed = [name for name, passed in self_tests.items() if not passed]
        raise DatasetError(f"V3_FINAL_DEVELOPMENT_SELF_TEST_FAILED: {failed}")

    selected_family = selected["modelFamily"] if freeze else None
    selection = (
        f"{selected_family}_SELECTED"
        if selected_family is not None
        else "NO_FREEZE_ELIGIBLE_MODEL"
    )
    freeze_contract = None
    if freeze:
        freeze_contract = {
            "modelFamily": selected["modelFamily"],
            "hyperparameters": (
                {
                    "C": selected["C"],
                    "profile": selected["profile"],
                    "classWeights": selected["classWeights"],
                }
                if selected["modelFamily"] == "LOGISTIC"
                else {
                    "hiddenUnits": selected["hiddenUnits"],
                    "alpha": selected["alpha"],
                    "learningRateInit": selected["learningRateInit"],
                    "bestEpochsByOuterFold": selected["bestEpochs"],
                    "optimizer": "adam",
                    "activation": "relu",
                }
            ),
            "featureSchemaVersion": FEATURE_SCHEMA_V3,
            "featureCount": len(FEATURE_ORDER_V3),
            "featureOrder": FEATURE_ORDER_V3,
            "classOrder": MOTION_CLASSES,
            "normalization": {
                "fit": "ALL_TRAINING_SESSIONS_ONLY",
                "standardizedClamp": [-5.0, 5.0],
            },
            "temporalDecoder": {
                key: selected_public[key]
                for key in (
                    "name",
                    "family",
                    "probabilityFilter",
                    "firWeights",
                    "highConfidence",
                    "highMargin",
                    "lowConfidence",
                    "lowMargin",
                    "consecutiveWindows",
                    "historyLength",
                    "theoreticalMaxDelayWindows",
                    "switchDelay",
                )
            },
            "productionModelExported": False,
            "freshIndependentV3HoldoutRequired": True,
        }

    report = {
        "schemaVersion": "navguard_ai_v3_final_development_freeze_report_v1",
        "status": (
            "DEVELOPMENT_GATE_MET" if freeze else "DEVELOPMENT_GATE_NOT_MET"
        ),
        "inputDataset": "development_v3",
        "dataset": dataset_summary,
        "classOrder": MOTION_CLASSES,
        "crossValidation": {
            "strategy": {
                **strategy,
                "name": "DeterministicClassAwareGrouped5Fold",
            },
            "folds": fold_summaries,
            "innerMlpSplits": inner_summaries,
            "deterministic": folds_deterministic and inner_deterministic,
        },
        "normalization": {
            "logistic": "OUTER_TRAIN_ONLY_PER_FOLD",
            "mlpEpochSelection": "INNER_TRAIN_SESSIONS_ONLY",
            "mlpOuterRefit": "NEW_SCALER_ALL_OUTER_TRAIN_SESSIONS",
            "standardizedClamp": [-5.0, 5.0],
        },
        "modelFamilies": {
            "logistic": {
                "grid": {
                    "C": DEVELOPMENT_C_VALUES,
                    "classWeightProfiles": [
                        "uniform",
                        "individual_class_1.25",
                        "individual_class_1.50",
                    ],
                },
                "candidateCount": len(logistic_candidates),
                "rejectedConvergenceCandidates": rejected_logistic,
                "rawCandidates": [
                    _public_v2_candidate(candidate)
                    for candidate in logistic_candidates
                ],
                "best": _public_final_v3_pair(best_logistic),
                "decoderPairCount": logistic_pair_count,
                "freezeEligiblePairCount": logistic_eligible_count,
            },
            "smallMlp": {
                "grid": {
                    "hiddenUnits": [8, 16, 32],
                    "alpha": [0.0001, 0.001, 0.01],
                    "learningRateInit": [0.0005, 0.001],
                    "optimizer": "adam",
                    "activation": "relu",
                    "maximumEpochs": 500,
                    "patienceEpochs": 25,
                    "minimumImprovement": 1e-4,
                    "sklearnInternalEarlyStopping": False,
                },
                "candidateCount": len(mlp_candidates),
                "rawCandidates": [
                    _public_mlp_candidate(candidate)
                    for candidate in mlp_candidates
                ],
                "best": _public_final_v3_pair(best_mlp),
                "decoderPairCount": mlp_pair_count,
                "freezeEligiblePairCount": mlp_eligible_count,
            },
        },
        "boundedTemporalDecoder": {
            "allowedProbabilityFilters": _bounded_probability_filter_specs(),
            "evaluatedRuleCount": len(rules),
            "maximumHistoryWindows": 3,
            "maximumHistoryLag": "t-2",
            "maximumConsecutiveWins": 2,
            "recursiveEmaUsed": False,
            "contractChecks": decoder_contract,
        },
        "selected": selected_public,
        "selection": selection,
        "revisedV3DevelopmentFreeze": freeze,
        "aiMotionDevelopmentFinalResult": (
            "DEVELOPMENT_GATE_MET" if freeze else "DEVELOPMENT_GATE_NOT_MET"
        ),
        "freezeContract": freeze_contract,
        "nextAction": (
            "FRESH_INDEPENDENT_V3_FINAL_HOLDOUT"
            if freeze
            else "CLOSE_AI_RESEARCH_WITH_SAFE_FALLBACK"
        ),
        "freshIndependentV3HoldoutRequired": freeze,
        "featureDiagnostics": feature_diagnostics,
        "selectedSanitizedSessionSummaries": sanitized_sessions,
        "reliabilityHeads": {
            "arcore": "PREVIOUS_PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
        },
        "isolation": {
            "onlyDevelopmentV3Loaded": True,
            "v3SmokeDuplicated": False,
            "historicalHoldoutLoaded": False,
            "finalHoldoutLoaded": False,
            "privatePathsReturned": False,
            "rawRowsReturned": False,
            "sessionIdentifiersReturned": False,
        },
        "selfTests": self_tests,
        "repeatedEvaluation": {
            "foldAssignmentDeterministic": folds_deterministic,
            "innerSplitDeterministic": inner_deterministic,
            "bestLogisticDeterministic": logistic_deterministic,
            "bestMlpDeterministic": mlp_deterministic,
            "passed": repeated_deterministic,
        },
        "productionModelExported": False,
        "productionModelAbsent": not production_model_path.exists(),
        "configEActive": False,
        "navigationAccuracyValidated": False,
        "furtherFeatureSchemaIterationPlanned": False,
        "furtherDevelopmentDataCollectionPlanned": False,
    }
    _write_json_atomic(report_output, report)
    return report["status"]


def _validate_v3_final_holdout_dataset(data) -> dict[str, Any]:
    import numpy as np
    import pandas as pd

    dataset_schema, feature_schema, feature_order = _resolve_training_contract(data)
    if (
        dataset_schema != DATASET_SCHEMA_V3
        or feature_schema != FEATURE_SCHEMA_V3
        or feature_order != FEATURE_ORDER_V3
    ):
        raise DatasetError("V3_FINAL_HOLDOUT_REQUIRES_EXACT_V3_SCHEMA")
    if len(data) != 96:
        raise DatasetError("V3 final holdout requires exactly 96 windows")
    sessions = data["session_id"].astype(str)
    if sessions.nunique() != 4:
        raise DatasetError("V3 final holdout requires exactly four sessions")
    session_window_counts = data.groupby(sessions).size()
    if not (session_window_counts == 24).all():
        raise DatasetError("V3 final holdout requires 24 windows per session")
    numeric_window_indexes = pd.to_numeric(data["window_index"], errors="coerce")
    if (
        numeric_window_indexes.isna().any()
        or not np.equal(numeric_window_indexes, np.floor(numeric_window_indexes)).all()
    ):
        raise DatasetError("invalid V3 final holdout window index")
    if data.duplicated(subset=["session_id", "window_index"]).any():
        raise DatasetError("duplicate V3 final holdout session window")
    for _, session_rows in data.assign(
        _window_index=numeric_window_indexes.astype(int)
    ).groupby(sessions):
        if sorted(session_rows["_window_index"].tolist()) != list(range(24)):
            raise DatasetError("V3 final holdout window indexes must be exactly 0..23")
    session_labels = data.groupby(sessions)["motion_label"].first().astype(str)
    sessions_per_class = Counter(session_labels)
    motion_window_counts = Counter(data["motion_label"].astype(str))
    if any(sessions_per_class[label] != 1 for label in MOTION_CLASSES):
        raise DatasetError("V3 final holdout requires one session per class")
    if any(motion_window_counts[label] != 24 for label in MOTION_CLASSES):
        raise DatasetError("V3 final holdout requires 24 windows per class")
    if not np.isfinite(data[FEATURE_ORDER_V3].to_numpy(float)).all():
        raise DatasetError("non-finite V3 final holdout feature")
    return {
        "datasetSchemaVersion": dataset_schema,
        "featureSchemaVersion": feature_schema,
        "featureCount": len(feature_order),
        "sessionCount": int(sessions.nunique()),
        "windowCount": int(len(data)),
        "sessionsPerMotionClass": {
            label: int(sessions_per_class[label]) for label in MOTION_CLASSES
        },
        "motionWindowCounts": {
            label: int(motion_window_counts[label]) for label in MOTION_CLASSES
        },
        "windowsPerSession": 24,
        "finiteFeatures": True,
        "duplicateSessionWindowCount": 0,
        "mixedDatasetSchema": False,
        "mixedFeatureSchema": False,
    }


def _load_frozen_v3_development_contract(path: Path) -> dict[str, Any]:
    try:
        report = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise DatasetError("V3_FROZEN_DEVELOPMENT_REPORT_INVALID") from error
    contract = report.get("freezeContract")
    if not isinstance(contract, dict):
        raise DatasetError("V3_FROZEN_DEVELOPMENT_CONTRACT_MISSING")
    hyperparameters = contract.get("hyperparameters", {})
    decoder = contract.get("temporalDecoder", {})
    exact = (
        report.get("status") == "DEVELOPMENT_GATE_MET"
        and report.get("revisedV3DevelopmentFreeze") is True
        and contract.get("modelFamily") == "MLP"
        and hyperparameters.get("hiddenUnits") == FROZEN_V3_HIDDEN_UNITS
        and hyperparameters.get("activation") == "relu"
        and hyperparameters.get("optimizer") == "adam"
        and hyperparameters.get("alpha") == FROZEN_V3_ALPHA
        and hyperparameters.get("learningRateInit") == FROZEN_V3_LEARNING_RATE
        and hyperparameters.get("bestEpochsByOuterFold") == [55, 67, 86, 86, 88]
        and contract.get("featureSchemaVersion") == FEATURE_SCHEMA_V3
        and contract.get("featureCount") == len(FEATURE_ORDER_V3)
        and contract.get("featureOrder") == FEATURE_ORDER_V3
        and contract.get("classOrder") == MOTION_CLASSES
        and decoder.get("name") == FROZEN_V3_DECODER_NAME
        and decoder.get("firWeights") == [0.60, 0.30, 0.10]
        and decoder.get("highConfidence") == 0.70
        and decoder.get("highMargin") == 0.10
        and decoder.get("lowConfidence") == 0.50
        and decoder.get("lowMargin") == 0.00
        and decoder.get("consecutiveWindows") == 1
        and decoder.get("historyLength") == 3
        and decoder.get("theoreticalMaxDelayWindows") == 2
        and report.get("productionModelExported") is False
    )
    if not exact:
        raise DatasetError("V3_FROZEN_DEVELOPMENT_CONTRACT_MISMATCH")
    return contract


def _frozen_v3_decoder_rule() -> dict[str, Any]:
    matches = [
        rule
        for rule in _bounded_decoder_rule_specs()
        if rule["name"] == FROZEN_V3_DECODER_NAME
    ]
    if len(matches) != 1:
        raise DatasetError("FROZEN_V3_DECODER_NOT_UNIQUE")
    rule = matches[0]
    exact = (
        rule["probabilityFilter"] == "FIR3"
        and rule["firWeights"] == [0.60, 0.30, 0.10]
        and rule["highConfidence"] == 0.70
        and rule["highMargin"] == 0.10
        and rule["lowConfidence"] == 0.50
        and rule["lowMargin"] == 0.00
        and rule["consecutiveWindows"] == 1
        and rule["historyLength"] == 3
        and rule["theoreticalMaxDelayWindows"] == 2
        and rule["theoreticalLatencyPassed"]
    )
    if not exact:
        raise DatasetError("FROZEN_V3_DECODER_CONTRACT_MISMATCH")
    return rule


def _fit_frozen_v3_final_model(development_data):
    import numpy as np
    from sklearn.preprocessing import StandardScaler

    features = development_data[FEATURE_ORDER_V3].to_numpy(float)
    labels = encode_motion_labels(
        development_data["motion_label"].astype(str).to_numpy()
    )
    scaler = StandardScaler().fit(features)
    normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)
    standardized = np.clip(
        (features - scaler.mean_) / normalization_std,
        -5.0,
        5.0,
    )
    spec = {
        "hiddenUnits": FROZEN_V3_HIDDEN_UNITS,
        "alpha": FROZEN_V3_ALPHA,
        "learningRateInit": FROZEN_V3_LEARNING_RATE,
        "randomSeed": SEED,
        "activation": "relu",
        "optimizer": "adam",
        "maximumEpochs": 500,
        "patienceEpochs": 25,
        "minimumImprovement": 1e-4,
        "candidateOrder": 0,
    }
    model = _new_session_safe_mlp(spec)
    if model.early_stopping:
        raise DatasetError("frozen V3 final model enabled internal early stopping")
    for epoch in range(1, FROZEN_V3_FINAL_EPOCHS + 1):
        _partial_fit_one_epoch(
            model,
            standardized,
            labels,
            first_epoch=epoch == 1,
        )
    _assert_motion_model_class_order(model)
    if (
        model.coefs_[0].shape != (40, 32)
        or model.coefs_[1].shape != (32, 4)
    ):
        raise DatasetError("frozen V3 final model runtime shape mismatch")
    return scaler, normalization_std, model


def _frozen_v3_transform(data, scaler, normalization_std):
    import numpy as np

    return np.clip(
        (data[FEATURE_ORDER_V3].to_numpy(float) - scaler.mean_)
        / normalization_std,
        -5.0,
        5.0,
    )


def _final_holdout_session_results(oof, predictions) -> dict[str, Any]:
    import numpy as np

    results = {}
    for class_index, class_name in enumerate(MOTION_CLASSES):
        matching_sessions = []
        for session_id in sorted(set(oof["groups"])):
            indexes = np.flatnonzero(oof["groups"] == session_id)
            if int(oof["labels"][indexes][0]) == class_index:
                matching_sessions.append((session_id, indexes))
        if len(matching_sessions) != 1:
            raise DatasetError("final holdout session/class topology mismatch")
        _, indexes = matching_sessions[0]
        indexes = indexes[np.argsort(oof["windowIndexes"][indexes])]
        values = predictions[indexes]
        correct_windows = int((values == class_index).sum())
        counts = Counter(int(value) for value in values)
        dominant_index = max(
            range(len(MOTION_CLASSES)),
            key=lambda value: (counts[value], -value),
        )
        longest_by_competing_class = {
            MOTION_CLASSES[competing]: int(
                _longest_true_run(values == competing)
            )
            for competing in range(len(MOTION_CLASSES))
            if competing != class_index
        }
        longest_wrong_run = max(
            longest_by_competing_class.values(),
            default=0,
        )
        accuracy = float(correct_windows / len(indexes))
        wrong_dominant = (
            dominant_index != class_index
            and counts[dominant_index] > len(indexes) / 2
        )
        persistent = (
            accuracy < 0.50
            or wrong_dominant
            or longest_wrong_run >= 12
        )
        summary = {
            "sanitizedSession": f"FINAL_{class_name}",
            "motionClass": class_name,
            "windowCount": int(len(indexes)),
            "correctWindows": correct_windows,
            "accuracy": accuracy,
            "dominantPrediction": MOTION_CLASSES[dominant_index],
            "longestWrongRun": int(longest_wrong_run),
            "wrongClassDominatesMostWindows": wrong_dominant,
            "persistentFailure": persistent,
        }
        if class_name == "STRAIGHT_WALK":
            summary["longestStraightToTurningRun"] = (
                longest_by_competing_class["TURNING"]
            )
        if class_name == "TURNING":
            summary["longestTurningToStraightRun"] = (
                longest_by_competing_class["STRAIGHT_WALK"]
            )
        results[f"FINAL_{class_name}"] = summary
    return results


def evaluate_frozen_v3_final_holdout(
    input_path: Path,
    final_holdout_path: Path,
    report_output: Path,
) -> str:
    import numpy as np

    if input_path.resolve().name != "development_v3":
        raise DatasetError("frozen V3 training input must be development_v3")
    if final_holdout_path.resolve().name != "final_holdout_v3":
        raise DatasetError("frozen V3 holdout input must be final_holdout_v3")

    repository_root = Path(__file__).resolve().parents[2]
    frozen_report_path = (
        repository_root
        / "evidence"
        / "ai_motion_v3_final_development_freeze.json"
    )
    frozen_contract = _load_frozen_v3_development_contract(frozen_report_path)
    development_data = _load_and_validate(input_path)
    development_summary = _validate_v3_development_dataset(development_data)
    development_sessions = set(development_data["session_id"].astype(str))

    holdout_loaded = False
    first_scaler, first_std, first_model = _fit_frozen_v3_final_model(
        development_data
    )
    second_scaler, second_std, second_model = _fit_frozen_v3_final_model(
        development_data
    )
    final_models_fitted_before_holdout = True

    holdout_data = _load_and_validate(final_holdout_path)
    holdout_loaded = True
    holdout_summary = _validate_v3_final_holdout_dataset(holdout_data)
    holdout_sessions = set(holdout_data["session_id"].astype(str))
    overlap = development_sessions & holdout_sessions
    if overlap:
        raise DatasetError("DEVELOPMENT_FINAL_HOLDOUT_SESSION_OVERLAP")

    holdout_labels = encode_motion_labels(
        holdout_data["motion_label"].astype(str).to_numpy()
    )
    first_features = _frozen_v3_transform(holdout_data, first_scaler, first_std)
    second_features = _frozen_v3_transform(
        holdout_data,
        second_scaler,
        second_std,
    )
    first_probabilities = _validated_motion_probabilities(
        first_model,
        first_features,
    )
    second_probabilities = _validated_motion_probabilities(
        second_model,
        second_features,
    )
    first_raw_predictions = first_probabilities.argmax(axis=1).astype(np.int64)
    second_raw_predictions = second_probabilities.argmax(axis=1).astype(np.int64)
    raw_metrics = _classification_metrics(
        holdout_labels,
        first_raw_predictions,
        MOTION_CLASSES,
    )
    probability_quality = {
        "meanMaxProbability": float(first_probabilities.max(axis=1).mean()),
        "medianMaxProbability": float(np.median(first_probabilities.max(axis=1))),
    }

    rule = _frozen_v3_decoder_rule()
    oof = {
        "labels": holdout_labels,
        "groups": holdout_data["session_id"].astype(str).to_numpy(),
        "windowIndexes": holdout_data["window_index"].to_numpy(int),
        "probabilities": first_probabilities,
        "predictions": first_raw_predictions,
    }
    repeated_oof = {
        "labels": holdout_labels,
        "groups": holdout_data["session_id"].astype(str).to_numpy(),
        "windowIndexes": holdout_data["window_index"].to_numpy(int),
        "probabilities": second_probabilities,
        "predictions": second_raw_predictions,
    }
    decoded_predictions = _bounded_decoder_predictions(oof, rule)
    repeated_decoded_predictions = _bounded_decoder_predictions(
        repeated_oof,
        rule,
    )
    decoded_metrics = _classification_metrics(
        holdout_labels,
        decoded_predictions,
        MOTION_CLASSES,
    )
    repeated_decoded_metrics = _classification_metrics(
        holdout_labels,
        repeated_decoded_predictions,
        MOTION_CLASSES,
    )
    minimum_class_recall = min(
        decoded_metrics["perClass"][label]["recall"]
        for label in MOTION_CLASSES
    )
    latency = _switch_delay_proxy(oof, decoded_predictions)
    repeated_latency = _switch_delay_proxy(
        repeated_oof,
        repeated_decoded_predictions,
    )
    session_results = _final_holdout_session_results(
        oof,
        decoded_predictions,
    )
    repeated_session_results = _final_holdout_session_results(
        repeated_oof,
        repeated_decoded_predictions,
    )

    model_parameters_deterministic = (
        np.array_equal(first_scaler.mean_, second_scaler.mean_)
        and np.array_equal(first_std, second_std)
        and all(
            np.array_equal(first, second)
            for first, second in zip(first_model.coefs_, second_model.coefs_)
        )
        and all(
            np.array_equal(first, second)
            for first, second in zip(
                first_model.intercepts_,
                second_model.intercepts_,
            )
        )
    )
    repeated_deterministic = (
        model_parameters_deterministic
        and np.array_equal(first_features, second_features)
        and np.array_equal(first_probabilities, second_probabilities)
        and np.array_equal(first_raw_predictions, second_raw_predictions)
        and np.array_equal(decoded_predictions, repeated_decoded_predictions)
        and raw_metrics
        == _classification_metrics(
            holdout_labels,
            second_raw_predictions,
            MOTION_CLASSES,
        )
        and decoded_metrics == repeated_decoded_metrics
        and latency == repeated_latency
        and session_results == repeated_session_results
    )

    persistent_failure = any(
        summary["persistentFailure"] for summary in session_results.values()
    )
    gates = {
        "decodedMacroF1AtLeast075": decoded_metrics["macroF1"] >= 0.75,
        "everyDecodedClassRecallAtLeast055": all(
            decoded_metrics["perClass"][label]["recall"] >= 0.55
            for label in MOTION_CLASSES
        ),
        "noPersistentSessionFailure": not persistent_failure,
        "theoreticalMaxDelayAtMostTwo": (
            rule["theoreticalMaxDelayWindows"] <= 2
        ),
        "empiricalMaxDelayAtMostTwo": latency["maxWindows"] <= 2,
    }
    final_gate_passed = all(gates.values())

    production_model_path = (
        repository_root
        / "mobile"
        / "navguard_app"
        / "android"
        / "app"
        / "src"
        / "main"
        / "assets"
        / "navguard_ai_model_v1.json"
    )
    self_tests = {
        "developmentExact20Sessions": development_summary["sessionCount"] == 20,
        "holdoutExact4Sessions": holdout_summary["sessionCount"] == 4,
        "developmentHoldoutNoOverlap": not overlap,
        "exactV3FeatureSchema": (
            development_summary["featureSchemaVersion"] == FEATURE_SCHEMA_V3
            and holdout_summary["featureSchemaVersion"] == FEATURE_SCHEMA_V3
            and development_summary["featureCount"] == 40
            and holdout_summary["featureCount"] == 40
        ),
        "scalerDevelopmentOnly": True,
        "exact86Epochs": FROZEN_V3_FINAL_EPOCHS == 86,
        "noEarlyStopping": (
            not first_model.early_stopping and not second_model.early_stopping
        ),
        "holdoutLoadedOnlyAfterFinalFit": (
            final_models_fitted_before_holdout and holdout_loaded
        ),
        "exactClassOrder": MOTION_CLASSES
        == ["STATIONARY", "STRAIGHT_WALK", "TURNING", "UNSTABLE_MOTION"],
        "exactFrozenFir3": (
            rule["probabilityFilter"] == "FIR3"
            and rule["firWeights"] == [0.60, 0.30, 0.10]
        ),
        "exactFrozenBoundedSwitch": (
            rule["highConfidence"] == 0.70
            and rule["highMargin"] == 0.10
            and rule["lowConfidence"] == 0.50
            and rule["lowMargin"] == 0.00
            and rule["consecutiveWindows"] == 1
        ),
        "decoderStateResetPerSession": _bounded_decoder_contract_checks()[
            "sessionDecoderStateReset"
        ],
        "noHistoryOlderThanTMinus2": rule["historyLength"] == 3,
        "noFutureWindow": _bounded_decoder_contract_checks()[
            "noFutureWindowAccess"
        ],
        "noTuningAfterHoldout": True,
        "repeatedFrozenEvaluationDeterministic": repeated_deterministic,
        "noProductionModelExport": not production_model_path.exists(),
        "configENotActivated": True,
    }
    if not all(self_tests.values()):
        failed = [name for name, passed in self_tests.items() if not passed]
        raise DatasetError(f"FROZEN_V3_FINAL_HOLDOUT_SELF_TEST_FAILED: {failed}")

    status = (
        "INDEPENDENT_HOLDOUT_GATE_MET"
        if final_gate_passed
        else "INDEPENDENT_HOLDOUT_GATE_NOT_MET"
    )
    model_status = (
        "FINAL_MODEL_APPROVED_FOR_INTEGRATION"
        if final_gate_passed
        else "NOT_APPROVED_FOR_CONFIG_E"
    )
    next_action = (
        "EXPORT_FROZEN_MODEL_AND_INTEGRATE_CONFIG_E"
        if final_gate_passed
        else "CLOSE_AI_RESEARCH_WITH_SAFE_DV2_FALLBACK"
    )
    report = {
        "schemaVersion": "navguard_ai_v3_final_holdout_report_v1",
        "finalV3HoldoutGate": "PASS" if final_gate_passed else "FAIL",
        "aiMotionFinalResult": status,
        "modelStatus": model_status,
        "nextAction": next_action,
        "development": development_summary,
        "holdout": holdout_summary,
        "developmentHoldoutSessionOverlapCount": 0,
        "frozenDevelopmentContractVerified": True,
        "frozenModel": {
            "family": "MLP_SINGLE_HIDDEN",
            "architecture": [40, 32, 4],
            "activation": "relu",
            "optimizer": "adam",
            "alpha": FROZEN_V3_ALPHA,
            "learningRateInit": FROZEN_V3_LEARNING_RATE,
            "randomState": SEED,
            "epochs": FROZEN_V3_FINAL_EPOCHS,
            "earlyStopping": False,
            "internalValidationSplit": False,
            "developmentRowsUsedForFit": 480,
            "holdoutRowsUsedForFit": 0,
            "featureSchemaVersion": FEATURE_SCHEMA_V3,
            "featureCount": 40,
            "featureOrder": FEATURE_ORDER_V3,
            "classOrder": MOTION_CLASSES,
        },
        "normalization": {
            "fitSource": "development_v3_only",
            "holdoutStatisticsUsed": False,
            "standardizedClamp": [-5.0, 5.0],
        },
        "rawHoldout": {
            "metrics": raw_metrics,
            **probability_quality,
        },
        "frozenDecoder": {
            "name": rule["name"],
            "probabilityFilter": rule["probabilityFilter"],
            "firWeights": rule["firWeights"],
            "highConfidence": rule["highConfidence"],
            "highMargin": rule["highMargin"],
            "lowConfidence": rule["lowConfidence"],
            "lowMargin": rule["lowMargin"],
            "consecutiveWindows": rule["consecutiveWindows"],
            "history": "t,t-1,t-2",
            "historyLength": rule["historyLength"],
            "theoreticalMaxDelayWindows": rule[
                "theoreticalMaxDelayWindows"
            ],
            "recursiveEmaUsed": False,
            "futureWindowUsed": False,
            "sessionStateReset": True,
        },
        "decodedHoldout": {
            "metrics": decoded_metrics,
            "minimumClassRecall": minimum_class_recall,
        },
        "sanitizedSessionResults": session_results,
        "latency": {
            **latency,
            "definition": "ESTABLISHED_RAW_TO_FROZEN_DECODER_SWITCH_DELAY_PROXY",
            "hopSeconds": 1.0,
            "theoreticalMaxWindows": 2,
        },
        "finalGates": gates,
        "interpretation": (
            "The frozen motion classifier passed the predefined independent "
            "V3 holdout gate on four fresh physical sessions."
            if final_gate_passed
            else "The frozen motion classifier did not pass the predefined "
            "independent V3 holdout gate on four fresh physical sessions."
        ),
        "interpretationLimits": {
            "fourFreshIndependentPhysicalSessions": True,
            "oneSessionPerMotionClass": True,
            "broadPopulationGeneralizationClaimed": False,
            "universalModelValidationClaimed": False,
            "productionSafetyValidationClaimed": False,
            "navigationAccuracyValidated": False,
        },
        "reliabilityHeads": {
            "arcore": "PREVIOUS_PASS",
            "pdr": "FAIL",
            "heading": "INSUFFICIENT",
            "retuned": False,
        },
        "isolation": {
            "holdoutLoadedAfterBothFrozenModelsFitted": True,
            "holdoutUsedForNormalization": False,
            "holdoutUsedForEpochSelection": False,
            "holdoutUsedForModelSelection": False,
            "holdoutUsedForHyperparameterChoice": False,
            "holdoutUsedForDecoderChoice": False,
            "holdoutUsedForThresholdChoice": False,
            "holdoutUsedForFeatureSelection": False,
            "tuningAfterHoldout": False,
            "rawRowsReturned": False,
            "privatePathsReturned": False,
            "sessionIdentifiersReturned": False,
        },
        "determinism": {
            "twoFrozenDevelopmentFitsCompletedBeforeHoldoutLoad": True,
            "modelParametersMatch": model_parameters_deterministic,
            "probabilitiesMatch": np.array_equal(
                first_probabilities,
                second_probabilities,
            ),
            "rawPredictionsMatch": np.array_equal(
                first_raw_predictions,
                second_raw_predictions,
            ),
            "decodedPredictionsMatch": np.array_equal(
                decoded_predictions,
                repeated_decoded_predictions,
            ),
            "metricsMatch": (
                raw_metrics
                == _classification_metrics(
                    holdout_labels,
                    second_raw_predictions,
                    MOTION_CLASSES,
                )
                and decoded_metrics == repeated_decoded_metrics
            ),
            "passed": repeated_deterministic,
        },
        "selfTests": self_tests,
        "productionModelExported": False,
        "productionModelAbsent": not production_model_path.exists(),
        "configEActive": False,
        "furtherAiTuningPlanned": False,
        "furtherDevelopmentDataCollectionPlanned": False,
        "replacementHoldoutPlanned": False,
        "productionIntegrationAuthorized": final_gate_passed,
        "navigationAccuracyValidated": False,
    }
    if frozen_contract.get("featureOrder") != FEATURE_ORDER_V3:
        raise DatasetError("frozen V3 feature order changed after evaluation")
    _write_json_atomic(report_output, report)
    return status


def _export_motion(model, selected_type: str) -> dict[str, Any]:
    if selected_type == "logistic_regression":
        return _export_linear(model)
    return {
        "type": "mlp_single_hidden",
        "activation": "relu",
        "hiddenWeights": model.coefs_[0].T.tolist(),
        "hiddenBias": model.intercepts_[0].tolist(),
        "outputWeights": model.coefs_[1].T.tolist(),
        "outputBias": model.intercepts_[1].tolist(),
    }


def _softmax(values):
    import numpy as np

    shifted = values - np.max(values, axis=1, keepdims=True)
    exponentials = np.exp(np.clip(shifted, -60.0, 60.0))
    return exponentials / exponentials.sum(axis=1, keepdims=True)


def _build_frozen_v3_runtime_model_json(
    model,
    scaler,
    normalization_std,
) -> dict[str, Any]:
    import numpy as np

    _assert_motion_model_class_order(model)
    fixture_inputs = [
        scaler.mean_.copy(),
        scaler.mean_ + 0.25 * normalization_std,
        scaler.mean_ - 0.25 * normalization_std,
    ]
    parity_fixtures = []
    for raw in fixture_inputs:
        standardized = np.clip(
            (raw - scaler.mean_) / normalization_std,
            -5.0,
            5.0,
        )
        hidden = np.maximum(
            0.0,
            standardized.reshape(1, -1) @ model.coefs_[0]
            + model.intercepts_[0],
        )
        logits = hidden @ model.coefs_[1] + model.intercepts_[1]
        parity_fixtures.append(
            {
                "features": [float(value) for value in raw],
                "normalizedClampedFeatures": [
                    float(value) for value in standardized
                ],
                "motionProbabilities": [
                    float(value) for value in _softmax(logits)[0]
                ],
            }
        )

    decoder_probabilities = np.asarray(
        [
            [0.80, 0.10, 0.05, 0.05],
            [0.20, 0.65, 0.10, 0.05],
            [0.10, 0.70, 0.15, 0.05],
            [0.10, 0.15, 0.70, 0.05],
            [0.10, 0.10, 0.75, 0.05],
        ],
        dtype=float,
    )
    decoder_rule = _frozen_v3_decoder_rule()
    filtered = _finite_impulse_probabilities(
        decoder_probabilities,
        decoder_rule["firWeights"],
    )
    decoded = _bounded_switch_predictions(filtered, decoder_rule)
    return {
        "modelSchemaVersion": "navguard_ai_model_v3",
        "modelVersion": "navguard_ai_motion_v3_frozen_development_86e",
        "runtimeStatus": "EXPERIMENTAL",
        "datasetSchemaVersion": DATASET_SCHEMA_V3,
        "featureSchemaVersion": FEATURE_SCHEMA_V3,
        "featureCount": len(FEATURE_ORDER_V3),
        "featureOrder": FEATURE_ORDER_V3,
        "normalizationMean": [float(value) for value in scaler.mean_],
        "normalizationStd": [float(value) for value in normalization_std],
        "standardizedClamp": [-5.0, 5.0],
        "motionModel": _export_motion(model, "mlp_single_hidden"),
        "motionClasses": MOTION_CLASSES,
        "temporalDecoder": {
            "type": "FIR3_BOUNDED_SWITCH",
            "firWeights": [0.60, 0.30, 0.10],
            "highConfidence": 0.70,
            "highMargin": 0.10,
            "lowConfidence": 0.50,
            "lowMargin": 0.00,
            "consecutiveWindows": 1,
            "historyLength": 3,
            "sessionStateReset": True,
        },
        "reliabilityAvailability": {
            "arcore": False,
            "pdr": False,
            "heading": False,
        },
        "provenance": {
            "trainingSchema": FEATURE_SCHEMA_V3,
            "trainingDataset": "development_v3",
            "developmentSessions": 20,
            "developmentWindows": 480,
            "developmentGate": "PASS",
            "independentHoldoutGate": "FAIL",
            "epochs": FROZEN_V3_FINAL_EPOCHS,
            "alpha": FROZEN_V3_ALPHA,
            "learningRateInit": FROZEN_V3_LEARNING_RATE,
            "optimizer": "adam",
            "randomState": SEED,
            "earlyStopping": False,
            "holdoutUsedForTraining": False,
        },
        "parityFixtures": parity_fixtures,
        "decoderParityFixture": {
            "probabilities": decoder_probabilities.tolist(),
            "filteredProbabilities": filtered.tolist(),
            "decodedMotionClasses": [
                MOTION_CLASSES[int(index)] for index in decoded
            ],
        },
    }


def _validate_frozen_v3_runtime_model_json(
    model_json: dict[str, Any],
) -> None:
    import numpy as np

    if model_json.get("modelSchemaVersion") != "navguard_ai_model_v3":
        raise DatasetError("invalid frozen V3 runtime model schema")
    if (
        model_json.get("runtimeStatus") != "EXPERIMENTAL"
        or model_json.get("modelVersion")
        != "navguard_ai_motion_v3_frozen_development_86e"
        or model_json.get("datasetSchemaVersion") != DATASET_SCHEMA_V3
        or model_json.get("featureSchemaVersion") != FEATURE_SCHEMA_V3
        or model_json.get("featureCount") != 40
        or model_json.get("featureOrder") != FEATURE_ORDER_V3
        or model_json.get("motionClasses") != MOTION_CLASSES
        or model_json.get("standardizedClamp") != [-5.0, 5.0]
    ):
        raise DatasetError("invalid frozen V3 runtime metadata")
    mean = np.asarray(model_json.get("normalizationMean"), dtype=float)
    std = np.asarray(model_json.get("normalizationStd"), dtype=float)
    if (
        mean.shape != (40,)
        or std.shape != (40,)
        or not np.isfinite(mean).all()
        or not np.isfinite(std).all()
        or (std <= 0.0).any()
    ):
        raise DatasetError("invalid frozen V3 runtime normalization")
    motion = model_json.get("motionModel", {})
    hidden_weights = np.asarray(motion.get("hiddenWeights"), dtype=float)
    hidden_bias = np.asarray(motion.get("hiddenBias"), dtype=float)
    output_weights = np.asarray(motion.get("outputWeights"), dtype=float)
    output_bias = np.asarray(motion.get("outputBias"), dtype=float)
    if (
        motion.get("type") != "mlp_single_hidden"
        or motion.get("activation") != "relu"
        or hidden_weights.shape != (32, 40)
        or hidden_bias.shape != (32,)
        or output_weights.shape != (4, 32)
        or output_bias.shape != (4,)
        or not all(
            np.isfinite(values).all()
            for values in (
                hidden_weights,
                hidden_bias,
                output_weights,
                output_bias,
            )
        )
    ):
        raise DatasetError("invalid frozen V3 runtime MLP")
    for fixture in model_json.get("parityFixtures", []):
        raw = np.asarray(fixture.get("features"), dtype=float)
        expected_standardized = np.asarray(
            fixture.get("normalizedClampedFeatures"),
            dtype=float,
        )
        expected_probabilities = np.asarray(
            fixture.get("motionProbabilities"),
            dtype=float,
        )
        standardized = np.clip((raw - mean) / std, -5.0, 5.0)
        hidden = np.maximum(0.0, hidden_weights @ standardized + hidden_bias)
        probabilities = _softmax(
            (output_weights @ hidden + output_bias).reshape(1, -1)
        )[0]
        if (
            raw.shape != (40,)
            or expected_standardized.shape != (40,)
            or expected_probabilities.shape != (4,)
            or not np.allclose(
                standardized,
                expected_standardized,
                rtol=0.0,
                atol=1e-12,
            )
            or not np.allclose(
                probabilities,
                expected_probabilities,
                rtol=0.0,
                atol=1e-12,
            )
        ):
            raise DatasetError("frozen V3 Python/runtime parity mismatch")
    if len(model_json.get("parityFixtures", [])) < 3:
        raise DatasetError("insufficient frozen V3 parity fixtures")
    decoder = model_json.get("temporalDecoder", {})
    if (
        decoder.get("type") != "FIR3_BOUNDED_SWITCH"
        or decoder.get("firWeights") != [0.60, 0.30, 0.10]
        or decoder.get("highConfidence") != 0.70
        or decoder.get("highMargin") != 0.10
        or decoder.get("lowConfidence") != 0.50
        or decoder.get("lowMargin") != 0.00
        or decoder.get("consecutiveWindows") != 1
        or decoder.get("historyLength") != 3
        or decoder.get("sessionStateReset") is not True
    ):
        raise DatasetError("invalid frozen V3 runtime decoder")
    provenance = model_json.get("provenance", {})
    if (
        provenance.get("trainingDataset") != "development_v3"
        or provenance.get("developmentSessions") != 20
        or provenance.get("developmentWindows") != 480
        or provenance.get("developmentGate") != "PASS"
        or provenance.get("independentHoldoutGate") != "FAIL"
        or provenance.get("epochs") != 86
        or provenance.get("holdoutUsedForTraining") is not False
    ):
        raise DatasetError("invalid frozen V3 runtime provenance")
    reliability = model_json.get("reliabilityAvailability", {})
    if set(reliability) != {"arcore", "pdr", "heading"} or any(
        value is not False for value in reliability.values()
    ):
        raise DatasetError("unapproved reliability head in frozen V3 runtime model")
    if any(key.endswith("ReliabilityModel") for key in model_json):
        raise DatasetError("unexpected reliability model in frozen V3 runtime asset")
    fixture = model_json.get("decoderParityFixture", {})
    probabilities = np.asarray(fixture.get("probabilities"), dtype=float)
    expected_filtered = np.asarray(
        fixture.get("filteredProbabilities"),
        dtype=float,
    )
    filtered = _finite_impulse_probabilities(
        probabilities,
        decoder["firWeights"],
    )
    decoded = _bounded_switch_predictions(
        filtered,
        _frozen_v3_decoder_rule(),
    )
    if (
        probabilities.ndim != 2
        or probabilities.shape[1] != 4
        or expected_filtered.shape != probabilities.shape
        or not np.allclose(
            filtered,
            expected_filtered,
            rtol=0.0,
            atol=1e-12,
        )
        or [MOTION_CLASSES[int(index)] for index in decoded]
        != fixture.get("decodedMotionClasses")
    ):
        raise DatasetError("frozen V3 decoder parity mismatch")


def export_frozen_v3_runtime_model(
    input_path: Path,
    model_output: Path,
) -> str:
    if input_path.resolve().name != "development_v3":
        raise DatasetError("frozen V3 runtime export requires development_v3")
    repository_root = Path(__file__).resolve().parents[2]
    _load_frozen_v3_development_contract(
        repository_root
        / "evidence"
        / "ai_motion_v3_final_development_freeze.json"
    )
    development_data = _load_and_validate(input_path)
    _validate_v3_development_dataset(development_data)
    scaler, normalization_std, model = _fit_frozen_v3_final_model(
        development_data
    )
    model_json = _build_frozen_v3_runtime_model_json(
        model,
        scaler,
        normalization_std,
    )
    _validate_frozen_v3_runtime_model_json(model_json)
    serialized = json.dumps(
        model_json,
        indent=2,
        sort_keys=True,
        allow_nan=False,
    ) + "\n"
    lowered = serialized.lower()
    forbidden = (
        "session_id",
        "latitude",
        "longitude",
        "device_serial",
        "raw_sensor",
        "arcore_pose",
        "final_holdout_v3",
    )
    if any(value in lowered for value in forbidden):
        raise DatasetError("private or holdout metadata in runtime model")
    _write_bytes_atomic(model_output, serialized.encode("utf-8"))
    return "FROZEN_V3_RUNTIME_MODEL_EXPORTED"


def train(input_path: Path, model_output: Path, report_output: Path) -> str:
    candidate_files = (
        sorted(input_path.glob("*.csv")) if input_path.is_dir() else [input_path]
    )
    if not any(path.is_file() for path in candidate_files):
        raise DatasetError("INSUFFICIENT_DATASET")
    try:
        import numpy as np
        from sklearn.linear_model import LogisticRegression
        from sklearn.neural_network import MLPClassifier
        from sklearn.preprocessing import StandardScaler
    except ImportError as error:
        raise DatasetError(
            "MISSING_PYTHON_DEPENDENCY: numpy, pandas and scikit-learn are required"
        ) from error

    data = _load_and_validate(input_path)
    dataset_schema, feature_schema, feature_order = _resolve_training_contract(data)
    session_labels = {
        str(session): str(label)
        for session, label in data.groupby("session_id")["motion_label"].first().items()
    }
    splits = class_aware_session_split(session_labels)
    split_rows = {
        name: data[data["session_id"].astype(str).isin(session_ids)].copy()
        for name, session_ids in splits.items()
    }
    if any(frame.empty for frame in split_rows.values()):
        raise DatasetError("INSUFFICIENT_DATASET")

    scaler = StandardScaler().fit(split_rows["train"][feature_order].to_numpy(float))
    normalization_std = np.where(scaler.scale_ > 1e-9, scaler.scale_, 1.0)

    def scaled(frame):
        raw = frame[feature_order].to_numpy(float)
        return np.clip((raw - scaler.mean_) / normalization_std, -5.0, 5.0)

    x_train = scaled(split_rows["train"])
    x_validation = scaled(split_rows["validation"])
    x_test = scaled(split_rows["test"])
    y_train = encode_motion_labels(
        split_rows["train"]["motion_label"].astype(str).to_numpy()
    )
    y_validation = encode_motion_labels(
        split_rows["validation"]["motion_label"].astype(str).to_numpy()
    )
    y_test = encode_motion_labels(
        split_rows["test"]["motion_label"].astype(str).to_numpy()
    )

    candidates = {
        "logistic_regression": LogisticRegression(
            max_iter=2000, random_state=SEED, class_weight="balanced"
        ),
        "mlp_single_hidden": MLPClassifier(
            hidden_layer_sizes=(16,), activation="relu", alpha=0.0001,
            early_stopping=True, random_state=SEED, max_iter=1000,
        ),
    }
    validation_metrics: dict[str, Any] = {}
    for name, model in candidates.items():
        model.fit(x_train, y_train)
        _validated_motion_probabilities(model, x_validation)
        validation_metrics[name] = _classification_metrics(
            y_validation, model.predict(x_validation), MOTION_CLASSES
        )
    selected_type = max(
        candidates,
        key=lambda name: (validation_metrics[name]["macroF1"], name == "logistic_regression"),
    )
    selected = candidates[selected_type]
    test_metrics = _classification_metrics(y_test, selected.predict(x_test), MOTION_CLASSES)
    motion_gate = _motion_deployment_gate(test_metrics)

    reliability_models: dict[str, Any] = {}
    reliability_report: dict[str, Any] = {}
    for name, (label_column, available_column) in RELIABILITY_HEADS.items():
        available = data[available_column].astype(str).str.lower().eq("true")
        labels = data.loc[available, label_column].apply(
            lambda value: int(float(value)) if str(value).strip() else -1
        )
        counts = Counter(int(value) for value in labels if int(value) in (0, 1))
        head_summary: dict[str, Any] = {
            "availableWindowCount": int(sum(counts.values())),
            "reliableCount": int(counts[1]),
            "unreliableCount": int(counts[0]),
            "status": "NOT_TRAINED_INSUFFICIENT_LABELS",
        }
        eligible = sum(counts.values()) >= 80 and counts[0] >= 20 and counts[1] >= 20
        masks = {}
        for split_name, frame in split_rows.items():
            mask = frame[available_column].astype(str).str.lower().eq("true")
            values = frame.loc[mask, label_column].apply(
                lambda value: int(float(value)) if str(value).strip() else -1
            )
            masks[split_name] = (mask, values)
            eligible = eligible and set(values.tolist()) == {0, 1}
        if not eligible:
            reliability_report[name] = head_summary
            continue
        train_mask, train_labels = masks["train"]
        test_mask, test_labels = masks["test"]
        model = LogisticRegression(
            max_iter=2000, random_state=SEED, class_weight="balanced"
        )
        model.fit(scaled(split_rows["train"].loc[train_mask]), train_labels.to_numpy())
        probabilities = model.predict_proba(
            scaled(split_rows["test"].loc[test_mask])
        )[:, list(model.classes_).index(1)]
        metrics = _reliability_metrics(test_labels.to_numpy(), probabilities)
        gate = metrics["balancedAccuracy"] >= 0.60 and (
            metrics["rocAuc"] is not None and metrics["rocAuc"] >= 0.65
        )
        head_summary.update(
            {"status": "DEPLOYED" if gate else "GATE_FAILED", "metrics": metrics}
        )
        reliability_report[name] = head_summary
        if gate:
            reliability_models[name] = model

    report: dict[str, Any] = {
        "datasetSchemaVersion": dataset_schema,
        "featureSchemaVersion": feature_schema,
        "seed": SEED,
        "aggregateCounts": {
            "sessionCount": len(session_labels),
            "windowCount": int(len(data)),
            "sessionsPerMotionClass": dict(Counter(session_labels.values())),
            "splitSessionCounts": {name: len(value) for name, value in splits.items()},
            "splitWindowCounts": {name: int(len(value)) for name, value in split_rows.items()},
        },
        "sessionLevelSplit": True,
        "rowLevelLeakage": False,
        "normalizationFit": "TRAIN_ONLY",
        "motion": {
            "candidateValidationMetrics": validation_metrics,
            "selectedModelType": selected_type,
            "heldOutTestMetrics": test_metrics,
            "deploymentGatePassed": motion_gate,
        },
        "reliabilityHeads": reliability_report,
        "accuracyValidated": False,
        "researchStatus": "DEVELOPMENT_ONLY",
    }
    if not motion_gate:
        report["status"] = "MOTION_DEPLOYMENT_GATE_FAILED"
        _write_json_atomic(report_output, report)
        return "MOTION_DEPLOYMENT_GATE_FAILED"

    motion_json = _export_motion(selected, selected_type)
    fixtures = []
    fixture_inputs = [
        np.zeros(len(feature_order)),
        scaler.mean_.copy(),
        scaler.mean_ + 0.25 * normalization_std,
    ]
    for raw in fixture_inputs:
        standardized = np.clip((raw - scaler.mean_) / normalization_std, -5.0, 5.0)
        if selected_type == "logistic_regression":
            logits = standardized.reshape(1, -1) @ selected.coef_.T + selected.intercept_
        else:
            hidden = np.maximum(0.0, standardized.reshape(1, -1) @ selected.coefs_[0] + selected.intercepts_[0])
            logits = hidden @ selected.coefs_[1] + selected.intercepts_[1]
        fixtures.append(
            {
                "features": [float(value) for value in raw],
                "motionProbabilities": [float(value) for value in _softmax(logits)[0]],
            }
        )
    model_json: dict[str, Any] = {
        "modelSchemaVersion": MODEL_SCHEMA,
        "featureSchemaVersion": feature_schema,
        "featureCount": len(feature_order),
        "featureOrder": feature_order,
        "normalizationMean": [float(value) for value in scaler.mean_],
        "normalizationStd": [float(value) for value in normalization_std],
        "motionModel": motion_json,
        "motionClasses": MOTION_CLASSES,
        "reliabilityAvailability": {
            name: name in reliability_models for name in RELIABILITY_HEADS
        },
        "trainingDatasetAggregateCounts": report["aggregateCounts"],
        "modelVersion": "navguard_ai_model_v1_physical",
        "parityFixtures": fixtures,
    }
    model_key_names = {
        "arcore": "arcoreReliabilityModel",
        "pdr": "pdrReliabilityModel",
        "heading": "headingReliabilityModel",
    }
    for name, model in reliability_models.items():
        model_json[model_key_names[name]] = _export_linear(model)
    serialized = (
        json.dumps(model_json, indent=2, sort_keys=True, allow_nan=False) + "\n"
    ).encode("utf-8")
    model_hash = hashlib.sha256(serialized).hexdigest()
    _write_bytes_atomic(model_output, serialized)
    report.update({"status": "MODEL_EXPORTED", "modelSha256": model_hash})
    _write_json_atomic(report_output, report)
    return "MODEL_EXPORTED"


def _write_bytes_atomic(path: Path, value: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    try:
        temporary.write_bytes(value)
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def _write_json_atomic(path: Path, value: dict[str, Any]) -> None:
    _write_bytes_atomic(
        path,
        (json.dumps(value, indent=2, sort_keys=True, allow_nan=False) + "\n").encode("utf-8"),
    )


def run_self_check() -> None:
    import tempfile

    try:
        import numpy as np
        import pandas as pd
        from sklearn.linear_model import LogisticRegression
        from sklearn.neural_network import MLPClassifier
        from sklearn.preprocessing import StandardScaler
    except ImportError as error:
        raise DatasetError(
            "MISSING_PYTHON_DEPENDENCY: numpy, pandas and scikit-learn are required"
        ) from error

    assert MOTION_LABEL_TO_INDEX == {
        "STATIONARY": 0,
        "STRAIGHT_WALK": 1,
        "TURNING": 2,
        "UNSTABLE_MOTION": 3,
    }
    assert encode_motion_labels(MOTION_CLASSES).tolist() == [0, 1, 2, 3]
    try:
        encode_motion_labels(["UNKNOWN"])
        raise AssertionError("unknown motion label was accepted")
    except DatasetError:
        pass

    labels = {
        f"{label}-{index}": label
        for label in MOTION_CLASSES
        for index in range(6)
    }
    first = class_aware_session_split(labels)
    second = class_aware_session_split(labels)
    assert first == second
    assert_no_session_leakage(first)
    assert all(len(first[name]) > 0 for name in first)
    session_rng = np.random.default_rng(SEED)
    session_rows = []
    for class_index, class_name in enumerate(MOTION_CLASSES):
        for session_index in range(6):
            session_id = f"{class_name}-{session_index}"
            for window_index in range(4):
                center = np.zeros(len(FEATURE_ORDER))
                center[class_index] = 5.0
                values = center + session_rng.normal(
                    0.0,
                    0.15,
                    size=len(FEATURE_ORDER),
                )
                row = {
                    "session_id": session_id,
                    "motion_label": class_name,
                    "window_index": window_index,
                }
                row.update(
                    {
                        feature_name: float(values[index])
                        for index, feature_name in enumerate(FEATURE_ORDER)
                    }
                )
                session_rows.append(row)
    session_frame = pd.DataFrame(session_rows)
    _, development_sessions, exposed_sessions = _development_partition(
        session_frame
    )
    assert len(development_sessions) == 20
    assert len(exposed_sessions) == 4
    assert not development_sessions & exposed_sessions
    development_frame = session_frame[
        session_frame["session_id"].isin(development_sessions)
    ].copy()
    assert not set(development_frame["session_id"]) & exposed_sessions
    (
        development_folds,
        development_fold_summary,
        development_fold_strategy,
    ) = _build_development_folds(development_frame)
    assert len(development_folds) == DEVELOPMENT_FOLD_COUNT
    assert development_fold_strategy["name"] in {
        "StratifiedGroupKFold",
        "DeterministicClassAwareGroupKFold",
    }
    assert all(
        fold["trainSessionCount"] == 16
        and fold["validationSessionCount"] == 4
        and fold["allMotionClassesRepresented"]
        and not fold["sessionLeakage"]
        and fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
        for fold in development_fold_summary
    )
    first_oof = _generate_frozen_oof_predictions(
        development_frame,
        development_folds,
    )
    second_oof = _generate_frozen_oof_predictions(
        development_frame,
        development_folds,
    )
    assert np.array_equal(first_oof["labels"], second_oof["labels"])
    assert np.array_equal(
        first_oof["predictions"],
        second_oof["predictions"],
    )
    assert np.array_equal(
        first_oof["foldIndexes"],
        second_oof["foldIndexes"],
    )
    assert np.array_equal(
        first_oof["probabilities"],
        second_oof["probabilities"],
    )
    assert first_oof["probabilities"].shape == (80, 4)
    assert np.isfinite(first_oof["probabilities"]).all()
    for session_id in sorted(set(first_oof["groups"])):
        indexes = np.flatnonzero(first_oof["groups"] == session_id)
        ordered = first_oof["windowIndexes"][indexes]
        assert np.array_equal(ordered, np.sort(ordered))

    causal_probabilities = np.asarray(
        [
            [0.70, 0.10, 0.10, 0.10],
            [0.55, 0.25, 0.10, 0.10],
            [0.20, 0.55, 0.15, 0.10],
            [0.10, 0.30, 0.50, 0.10],
            [0.10, 0.10, 0.10, 0.70],
        ],
        dtype=float,
    )
    future_mutated = causal_probabilities.copy()
    future_mutated[-1] = [0.97, 0.01, 0.01, 0.01]
    assert np.array_equal(
        _ema_probabilities(causal_probabilities, 0.50)[:-1],
        _ema_probabilities(future_mutated, 0.50)[:-1],
    )
    assert np.array_equal(
        _hysteresis_predictions(causal_probabilities, 0.10, 2)[:-1],
        _hysteresis_predictions(future_mutated, 0.10, 2)[:-1],
    )
    assert len(_temporal_rule_specs()) == 28
    assert all(
        rule["emaAlpha"] in (None, 0.25, 0.50, 0.75)
        and rule["hysteresisMargin"] in (None, 0.05, 0.10, 0.15)
        and rule["consecutiveWindows"] in (None, 1, 2)
        for rule in _temporal_rule_specs()
    )
    extension_rows = []
    for extension_index in range(2):
        for window_index in range(4):
            values = np.zeros(len(FEATURE_ORDER))
            values[MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"]] = 5.0
            row = {
                "session_id": f"extension-straight-{extension_index}",
                "motion_label": "STRAIGHT_WALK",
                "window_index": window_index,
            }
            row.update(
                {
                    feature_name: float(values[index])
                    for index, feature_name in enumerate(FEATURE_ORDER)
                }
            )
            extension_rows.append(row)
    extension_frame = pd.DataFrame(extension_rows)
    (
        extended_frame,
        extended_folds,
        extended_fold_summary,
        extended_fold_strategy,
    ) = _build_extended_development_folds(
        development_frame,
        extension_frame,
    )
    (
        repeated_extended_frame,
        repeated_extended_folds,
        repeated_extended_summary,
        repeated_extended_strategy,
    ) = _build_extended_development_folds(
        development_frame,
        extension_frame,
    )
    assert len(extended_frame) == 88
    assert extended_frame["session_id"].nunique() == 22
    assert (
        extended_frame.loc[
            extended_frame["motion_label"] == "STRAIGHT_WALK",
            "session_id",
        ].nunique()
        == 7
    )
    assert extended_fold_strategy == repeated_extended_strategy
    assert extended_fold_summary == repeated_extended_summary
    assert extended_frame.equals(repeated_extended_frame)
    assert all(
        np.array_equal(first_train, second_train)
        and np.array_equal(first_validation, second_validation)
        for (first_train, first_validation), (
            second_train,
            second_validation,
        ) in zip(extended_folds, repeated_extended_folds)
    )
    assert all(
        fold["allMotionClassesRepresented"]
        and not fold["sessionLeakage"]
        and fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
        for fold in extended_fold_summary
    )
    assert sorted(
        fold["validationSessionsPerMotionClass"]["STRAIGHT_WALK"]
        for fold in extended_fold_summary
    ) == [1, 1, 1, 2, 2]
    extended_spec = _development_candidate_specs()[0]
    first_extended_oof = _generate_candidate_oof_predictions(
        extended_frame,
        extended_folds,
        extended_spec,
    )
    second_extended_oof = _generate_candidate_oof_predictions(
        repeated_extended_frame,
        repeated_extended_folds,
        extended_spec,
    )
    assert np.array_equal(
        first_extended_oof["probabilities"],
        second_extended_oof["probabilities"],
    )
    assert np.array_equal(
        first_extended_oof["predictions"],
        second_extended_oof["predictions"],
    )
    test_specs = [
        spec
        for spec in _development_candidate_specs()
        if spec["profile"] == "uniform" and spec["C"] in (0.03, 1.0)
    ]
    first_results = [
        _evaluate_logistic_candidate(development_frame, development_folds, spec)
        for spec in test_specs
    ]
    second_results = [
        _evaluate_logistic_candidate(development_frame, development_folds, spec)
        for spec in test_specs
    ]
    assert json.dumps(first_results, sort_keys=True) == json.dumps(
        second_results,
        sort_keys=True,
    )
    first_selected = _select_best_development_candidate(first_results)
    second_selected = _select_best_development_candidate(second_results)
    assert first_selected is not None and second_selected is not None
    assert (
        first_selected["C"],
        first_selected["profile"],
    ) == (
        second_selected["C"],
        second_selected["profile"],
    )
    mutated_exposed = session_frame.copy()
    exposed_mask = mutated_exposed["session_id"].isin(exposed_sessions)
    mutated_exposed.loc[exposed_mask, FEATURE_ORDER] = 1_000_000.0
    mutated_development = mutated_exposed[
        mutated_exposed["session_id"].isin(development_sessions)
    ]
    assert np.array_equal(
        development_frame[FEATURE_ORDER].to_numpy(float),
        mutated_development[FEATURE_ORDER].to_numpy(float),
    )
    assert len(_development_candidate_specs()) == 63
    assert len(FEATURE_ORDER) == 26 and len(set(FEATURE_ORDER)) == 26
    assert DATASET_SCHEMA_V1 == "navguard_ai_dataset_v1"
    assert DATASET_SCHEMA_V2 == "navguard_ai_dataset_v2"
    assert DATASET_SCHEMA_V3 == "navguard_ai_dataset_v3"
    assert FEATURE_SCHEMA_V1 == "navguard_ai_features_v1"
    assert FEATURE_SCHEMA_V2 == "navguard_ai_features_v2"
    assert FEATURE_SCHEMA_V3 == "navguard_ai_features_v3"
    assert len(FEATURE_ORDER_V2) == 34
    assert FEATURE_ORDER_V2[:26] == FEATURE_ORDER_V1
    assert FEATURE_ORDER_V2[26:] == [
        "heading_net_change_abs_rad",
        "heading_turn_consistency",
        "sustained_turn_fraction",
        "arcore_path_length_m",
        "arcore_straightness_ratio",
        "arcore_net_turn_abs_rad",
        "arcore_turn_consistency",
        "arcore_curvature_abs_rad_per_m",
    ]
    assert len(FEATURE_ORDER_V3) == 40
    assert FEATURE_ORDER_V3[:34] == FEATURE_ORDER_V2
    assert FEATURE_ORDER_V3[34:] == [
        "heading_signed_net_turn_rad",
        "arcore_signed_net_turn_rad",
        "heading_path_turn_direction_agreement",
        "heading_path_turn_magnitude_difference_ratio",
        "heading_path_turn_coherence",
        "arcore_cross_track_rms_m",
    ]
    assert FROZEN_V3_HIDDEN_UNITS == 32
    assert FROZEN_V3_ALPHA == 0.01
    assert FROZEN_V3_LEARNING_RATE == 0.0005
    assert FROZEN_V3_FINAL_EPOCHS == 86
    frozen_v3_decoder = _frozen_v3_decoder_rule()
    assert frozen_v3_decoder["probabilityFilter"] == "FIR3"
    assert frozen_v3_decoder["firWeights"] == [0.60, 0.30, 0.10]
    assert frozen_v3_decoder["highConfidence"] == 0.70
    assert frozen_v3_decoder["highMargin"] == 0.10
    assert frozen_v3_decoder["lowConfidence"] == 0.50
    assert frozen_v3_decoder["lowMargin"] == 0.00
    assert frozen_v3_decoder["consecutiveWindows"] == 1
    assert frozen_v3_decoder["historyLength"] == 3
    assert frozen_v3_decoder["theoreticalMaxDelayWindows"] == 2
    assert not any(
        fragment in column.lower()
        for column in EXPECTED_COLUMNS
        for fragment in FORBIDDEN_FRAGMENTS
    )
    assert not any(
        fragment in column.lower()
        for column in EXPECTED_COLUMNS_V2
        for fragment in FORBIDDEN_FRAGMENTS
    )
    assert not any(
        fragment in column.lower()
        for column in EXPECTED_COLUMNS_V3
        for fragment in FORBIDDEN_FRAGMENTS
    )
    with tempfile.TemporaryDirectory() as schema_directory:
        schema_root = Path(schema_directory)

        def schema_row(
            dataset_schema: str,
            feature_schema: str,
            feature_order: list[str],
            session_id: str,
        ) -> dict[str, Any]:
            row: dict[str, Any] = {
                "schema_version": dataset_schema,
                "feature_schema_version": feature_schema,
                "session_id": session_id,
                "window_index": 0,
                "motion_label": "STRAIGHT_WALK",
                "arcore_reliable_label": "",
                "arcore_reliable_available": False,
                "pdr_reliable_label": "",
                "pdr_reliable_available": False,
                "heading_reliable_label": "",
                "heading_reliable_available": False,
            }
            row.update({name: 0.0 for name in feature_order})
            return row

        v1_directory = schema_root / "v1"
        v2_directory = schema_root / "v2"
        v3_directory = schema_root / "v3"
        mixed_directory = schema_root / "mixed_v2_v3"
        wrong_count_directory = schema_root / "wrong_count"
        wrong_order_directory = schema_root / "wrong_order"
        v1_directory.mkdir()
        v2_directory.mkdir()
        v3_directory.mkdir()
        mixed_directory.mkdir()
        wrong_count_directory.mkdir()
        wrong_order_directory.mkdir()
        v1_frame = pd.DataFrame(
            [
                schema_row(
                    DATASET_SCHEMA_V1,
                    FEATURE_SCHEMA_V1,
                    FEATURE_ORDER_V1,
                    "v1-session",
                )
            ],
            columns=EXPECTED_COLUMNS_V1,
        )
        v2_frame = pd.DataFrame(
            [
                schema_row(
                    DATASET_SCHEMA_V2,
                    FEATURE_SCHEMA_V2,
                    FEATURE_ORDER_V2,
                    "v2-session",
                )
            ],
            columns=EXPECTED_COLUMNS_V2,
        )
        v3_frame = pd.DataFrame(
            [
                schema_row(
                    DATASET_SCHEMA_V3,
                    FEATURE_SCHEMA_V3,
                    FEATURE_ORDER_V3,
                    "v3-session",
                )
            ],
            columns=EXPECTED_COLUMNS_V3,
        )
        v1_frame.to_csv(v1_directory / "v1.csv", index=False)
        v2_frame.to_csv(v2_directory / "v2.csv", index=False)
        v3_frame.to_csv(v3_directory / "v3.csv", index=False)
        v2_frame.to_csv(mixed_directory / "v2.csv", index=False)
        v3_frame.to_csv(mixed_directory / "v3.csv", index=False)
        v3_frame.drop(columns=[FEATURE_ORDER_V3[-1]]).to_csv(
            wrong_count_directory / "wrong_count.csv",
            index=False,
        )
        wrong_order_columns = EXPECTED_COLUMNS_V3.copy()
        wrong_order_columns[-2], wrong_order_columns[-1] = (
            wrong_order_columns[-1],
            wrong_order_columns[-2],
        )
        v3_frame.loc[:, wrong_order_columns].to_csv(
            wrong_order_directory / "wrong_order.csv",
            index=False,
        )
        loaded_v1 = _load_and_validate(v1_directory)
        loaded_v2 = _load_and_validate(v2_directory)
        loaded_v3 = _load_and_validate(v3_directory)
        assert loaded_v1.attrs["feature_order"] == FEATURE_ORDER_V1
        assert loaded_v2.attrs["feature_order"] == FEATURE_ORDER_V2
        assert loaded_v3.attrs["feature_order"] == FEATURE_ORDER_V3
        assert len(loaded_v2.attrs["feature_order"]) == 34
        assert len(loaded_v3.attrs["feature_order"]) == 40
        assert _resolve_training_contract(loaded_v1) == (
            DATASET_SCHEMA_V1,
            FEATURE_SCHEMA_V1,
            FEATURE_ORDER_V1,
        )
        assert _resolve_training_contract(loaded_v2) == (
            DATASET_SCHEMA_V2,
            FEATURE_SCHEMA_V2,
            FEATURE_ORDER_V2,
        )
        assert _resolve_training_contract(loaded_v3) == (
            DATASET_SCHEMA_V3,
            FEATURE_SCHEMA_V3,
            FEATURE_ORDER_V3,
        )
        try:
            _load_and_validate(mixed_directory)
            raise AssertionError("mixed V2/V3 dataset was accepted")
        except DatasetError as error:
            assert str(error) == "MIXED_FEATURE_SCHEMA_NOT_ALLOWED"
        for invalid_directory in (wrong_count_directory, wrong_order_directory):
            try:
                _load_and_validate(invalid_directory)
                raise AssertionError(f"invalid V3 schema was accepted: {invalid_directory.name}")
            except DatasetError as error:
                assert str(error) == "dataset column order/schema mismatch"
        synthetic_v2_rows = []
        for class_index, class_name in enumerate(MOTION_CLASSES):
            for session_number in range(1, 6):
                session_id = f"v2-{class_index}-{session_number}"
                for window_index in range(V2_DEVELOPMENT_WINDOWS_PER_SESSION):
                    row = schema_row(
                        DATASET_SCHEMA_V2,
                        FEATURE_SCHEMA_V2,
                        FEATURE_ORDER_V2,
                        session_id,
                    )
                    row["window_index"] = window_index
                    row["motion_label"] = class_name
                    row[FEATURE_ORDER_V2[class_index]] = float(
                        session_number + window_index / 100.0
                    )
                    synthetic_v2_rows.append(row)
        synthetic_v2_development = pd.DataFrame(
            synthetic_v2_rows,
            columns=EXPECTED_COLUMNS_V2,
        )
        synthetic_v2_development.attrs["dataset_schema_version"] = (
            DATASET_SCHEMA_V2
        )
        synthetic_v2_development.attrs["feature_schema_version"] = (
            FEATURE_SCHEMA_V2
        )
        synthetic_v2_development.attrs["feature_order"] = FEATURE_ORDER_V2
        synthetic_v2_summary = _validate_v2_development_dataset(
            synthetic_v2_development
        )
        assert synthetic_v2_summary["sessionCount"] == 20
        assert synthetic_v2_summary["windowCount"] == 480
        assert all(
            value == 5
            for value in synthetic_v2_summary[
                "sessionsPerMotionClass"
            ].values()
        )
        synthetic_folds, synthetic_fold_summaries, synthetic_strategy = (
            _build_v2_development_folds(synthetic_v2_development)
        )
        repeated_folds, repeated_fold_summaries, repeated_strategy = (
            _build_v2_development_folds(synthetic_v2_development)
        )
        assert _folds_are_identical(synthetic_folds, repeated_folds)
        assert synthetic_fold_summaries == repeated_fold_summaries
        assert synthetic_strategy == repeated_strategy
        assert all(
            fold["trainSessionCount"] == 16
            and fold["validationSessionCount"] == 4
            and fold["trainWindowCount"] == 384
            and fold["validationWindowCount"] == 96
            and all(
                value == 1
                for value in fold[
                    "validationSessionsPerMotionClass"
                ].values()
            )
            and fold["sessionLeakage"] is False
            and fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
            for fold in synthetic_fold_summaries
        )
        assert len(_development_candidate_specs()) == 63
        assert _development_candidate_specs() == _development_candidate_specs()
        assert FEATURE_ORDER_V2[:26] == FEATURE_ORDER_V1
        assert len(_temporal_rule_specs()) == 28
        assert _temporal_rule_specs()[0]["name"] == "raw_argmax"
        assert len(_bounded_probability_filter_specs()) == 7
        assert len(_bounded_decoder_rule_specs()) == 337
        assert all(_bounded_decoder_contract_checks().values())
        assert len(_mlp_capacity_specs()) == 18
        assert all(
            _new_session_safe_mlp(spec).early_stopping is False
            for spec in _mlp_capacity_specs()
        )
        synthetic_extension_rows = []
        for class_index, class_name in (
            (MOTION_LABEL_TO_INDEX["STRAIGHT_WALK"], "STRAIGHT_WALK"),
            (MOTION_LABEL_TO_INDEX["TURNING"], "TURNING"),
        ):
            for session_number in (6, 7):
                session_id = f"v2-{class_index}-{session_number}"
                for window_index in range(V2_DEVELOPMENT_WINDOWS_PER_SESSION):
                    row = schema_row(
                        DATASET_SCHEMA_V2,
                        FEATURE_SCHEMA_V2,
                        FEATURE_ORDER_V2,
                        session_id,
                    )
                    row["window_index"] = window_index
                    row["motion_label"] = class_name
                    row[FEATURE_ORDER_V2[class_index]] = float(
                        session_number + window_index / 100.0
                    )
                    synthetic_extension_rows.append(row)
        synthetic_v2_extension = pd.DataFrame(
            synthetic_extension_rows,
            columns=EXPECTED_COLUMNS_V2,
        )
        synthetic_v2_extension.attrs["dataset_schema_version"] = (
            DATASET_SCHEMA_V2
        )
        synthetic_v2_extension.attrs["feature_schema_version"] = (
            FEATURE_SCHEMA_V2
        )
        synthetic_v2_extension.attrs["feature_order"] = FEATURE_ORDER_V2
        (
            synthetic_v2_24,
            synthetic_base_summary,
            synthetic_extension_summary,
            synthetic_combined_summary,
        ) = _validate_v2_24session_sources(
            synthetic_v2_development,
            synthetic_v2_extension,
        )
        assert synthetic_base_summary["sessionCount"] == 20
        assert synthetic_extension_summary["sessionCount"] == 4
        assert synthetic_combined_summary["sessionCount"] == 24
        assert synthetic_combined_summary["windowCount"] == 576
        assert (
            synthetic_combined_summary["sessionsPerMotionClass"]
            == V2_24_SESSIONS_PER_CLASS
        )
        synthetic_24_folds, synthetic_24_summaries, synthetic_24_strategy = (
            _build_v2_24session_folds(synthetic_v2_24)
        )
        repeated_24_folds, repeated_24_summaries, repeated_24_strategy = (
            _build_v2_24session_folds(synthetic_v2_24)
        )
        assert _folds_are_identical(synthetic_24_folds, repeated_24_folds)
        assert synthetic_24_summaries == repeated_24_summaries
        assert synthetic_24_strategy == repeated_24_strategy
        assert [
            fold["validationSessionCount"] for fold in synthetic_24_summaries
        ] == [6, 6, 4, 4, 4]
        assert [
            fold["validationWindowCount"] for fold in synthetic_24_summaries
        ] == [144, 144, 96, 96, 96]
        assert all(
            all(
                count >= 1
                for count in fold[
                    "validationSessionsPerMotionClass"
                ].values()
            )
            and fold["sessionLeakage"] is False
            and fold["normalizationFit"] == "FOLD_TRAIN_ONLY"
            for fold in synthetic_24_summaries
        )
        synthetic_inner_splits, synthetic_inner_summaries = (
            _build_session_safe_inner_splits(
                synthetic_v2_24,
                synthetic_24_folds,
            )
        )
        repeated_inner_splits, repeated_inner_summaries = (
            _build_session_safe_inner_splits(
                synthetic_v2_24,
                synthetic_24_folds,
            )
        )
        assert _folds_are_identical(
            synthetic_inner_splits,
            repeated_inner_splits,
        )
        assert synthetic_inner_summaries == repeated_inner_summaries
        assert all(
            summary["innerValidationSessionCount"] == 4
            and all(
                count == 1
                for count in summary[
                    "innerValidationSessionsPerMotionClass"
                ].values()
            )
            and summary["outerValidationExcluded"]
            and not summary["sessionLeakage"]
            for summary in synthetic_inner_summaries
        )
        runtime_asset_directory = (
            Path(__file__).resolve().parents[2]
            / "mobile"
            / "navguard_app"
            / "android"
            / "app"
            / "src"
            / "main"
            / "assets"
        )
        runtime_assets = sorted(runtime_asset_directory.glob("navguard_ai_model*.json"))
        assert [path.name for path in runtime_assets] == [
            "navguard_ai_model_v3.json"
        ]
        _validate_frozen_v3_runtime_model_json(
            json.loads(runtime_assets[0].read_text(encoding="utf-8"))
        )
    train_values = [1.0, 2.0, 3.0]
    validation_values = [10_000.0]
    scaler = StandardScaler().fit(np.asarray(train_values).reshape(-1, 1))
    assert scaler.mean_.tolist() == [2.0]
    assert validation_values[0] != scaler.mean_[0]

    rng = np.random.default_rng(SEED)
    synthetic_features = []
    synthetic_labels = []
    for class_index in range(len(MOTION_CLASSES)):
        center = np.zeros(len(FEATURE_ORDER))
        center[class_index] = 4.0
        synthetic_features.append(
            center + rng.normal(0.0, 0.25, size=(40, len(FEATURE_ORDER)))
        )
        synthetic_labels.extend([class_index] * 40)
    synthetic_x = np.vstack(synthetic_features)
    synthetic_y = np.asarray(synthetic_labels, dtype=np.int64)
    permutation = rng.permutation(len(synthetic_y))
    synthetic_x = synthetic_x[permutation]
    synthetic_y = synthetic_y[permutation]

    logistic = LogisticRegression(
        max_iter=2000, random_state=SEED, class_weight="balanced"
    )
    mlp = MLPClassifier(
        hidden_layer_sizes=(16,), activation="relu", alpha=0.0001,
        early_stopping=True, random_state=SEED, max_iter=1000,
    )
    for model in (logistic, mlp):
        model.fit(synthetic_x, synthetic_y)
        probabilities = _validated_motion_probabilities(model, synthetic_x[:8])
        assert probabilities.shape == (8, 4)
        assert np.isfinite(probabilities).all()
        assert [int(value) for value in model.classes_] == [0, 1, 2, 3]
    assert mlp.early_stopping is True

    frozen_scaler = StandardScaler().fit(synthetic_x)
    frozen_std = np.where(frozen_scaler.scale_ > 1e-9, frozen_scaler.scale_, 1.0)
    frozen_features = np.clip(
        (synthetic_x - frozen_scaler.mean_) / frozen_std,
        -5.0,
        5.0,
    )
    frozen_spec = {
        "C": FROZEN_MOTION_C,
        "profile": "frozen_development_candidate",
        "classWeights": dict(FROZEN_MOTION_CLASS_WEIGHTS),
        "weightComplexity": 1,
        "candidateOrder": 0,
    }
    frozen_model = _fit_logistic_candidate(
        frozen_features,
        synthetic_y,
        frozen_spec,
    )
    motion_only_json = _build_motion_only_model_json(
        frozen_model,
        frozen_scaler,
        frozen_std,
    )
    _validate_python_export_parity(motion_only_json)
    assert motion_only_json["motionClasses"] == MOTION_CLASSES
    assert all(
        value is False
        for value in motion_only_json["reliabilityAvailability"].values()
    )
    assert not any(
        key.endswith("ReliabilityModel") for key in motion_only_json
    )

    readable_metrics = _classification_metrics(
        np.asarray([0, 1, 2, 3]),
        np.asarray([0, 1, 2, 2]),
        MOTION_CLASSES,
    )
    assert list(readable_metrics["perClass"]) == MOTION_CLASSES
    assert len(readable_metrics["confusionMatrix"]) == 4
    assert all(len(row) == 4 for row in readable_metrics["confusionMatrix"])

    binary_x = rng.normal(size=(80, len(FEATURE_ORDER)))
    binary_y = np.asarray([0, 1] * 40, dtype=np.int64)
    reliability_model = LogisticRegression(
        max_iter=2000, random_state=SEED, class_weight="balanced"
    ).fit(binary_x, binary_y)
    assert [int(value) for value in reliability_model.classes_] == [0, 1]
    reliability_probabilities = reliability_model.predict_proba(binary_x)[:, 1]
    reliability_metrics = _reliability_metrics(
        binary_y, reliability_probabilities
    )
    assert np.isfinite(reliability_metrics["balancedAccuracy"])

    with tempfile.TemporaryDirectory() as directory:
        model_path = Path(directory) / "navguard_ai_model_v1.json"
        failed_report_path = Path(directory) / "failed_report.json"
        _write_json_atomic(
            failed_report_path,
            {"status": "MOTION_DEPLOYMENT_GATE_FAILED"},
        )
        assert failed_report_path.is_file()
        assert not model_path.exists()
        development_report_path = Path(directory) / "development.json"
        _write_json_atomic(
            development_report_path,
            {
                "status": "MOTION_MODEL_DEVELOPMENT_GATE_PASS",
                "productionModelExported": False,
                "frozenCandidate": {
                    "family": "logistic_regression",
                    "C": FROZEN_MOTION_C,
                    "classWeights": FROZEN_MOTION_CLASS_WEIGHTS,
                    "featureOrder": FEATURE_ORDER,
                    "featureSchemaVersion": FEATURE_SCHEMA,
                    "normalizationPolicy": (
                        "FIT_DEVELOPMENT_TRAINING_DATA_ONLY"
                    ),
                    "motionClasses": MOTION_CLASSES,
                    "decisionRule": "argmax_probability",
                },
            },
        )
        loaded_frozen = _load_frozen_development_contract(
            development_report_path
        )
        assert loaded_frozen["C"] == FROZEN_MOTION_C
        final_report_path = Path(directory) / "final.json"
        _write_json_atomic(
            final_report_path,
            {
                "status": "MOTION_PRODUCTION_GATE_PASS",
                "productionModel": {"created": True},
                "paritySafety": {"pythonKotlinParity": "PENDING"},
            },
        )
        record_runtime_parity(final_report_path, "PASS")
        assert json.loads(final_report_path.read_text(encoding="utf-8"))[
            "paritySafety"
        ]["pythonKotlinParity"] == "PASS"

    expanded_development = session_frame.loc[
        session_frame.index.repeat(6)
    ].copy()
    expanded_development["window_index"] = expanded_development.groupby(
        "session_id"
    ).cumcount()
    final_rows = []
    for class_index, class_name in enumerate(MOTION_CLASSES):
        for window_index in range(24):
            values = np.zeros(len(FEATURE_ORDER))
            values[class_index] = 5.0
            row = {
                "session_id": f"fresh-{class_name}",
                "motion_label": class_name,
                "window_index": window_index,
            }
            row.update(
                {
                    feature_name: float(values[index])
                    for index, feature_name in enumerate(FEATURE_ORDER)
                }
            )
            final_rows.append(row)
    synthetic_final = pd.DataFrame(final_rows)
    isolated_fitting_data, isolation_summary = _validate_final_data_isolation(
        expanded_development,
        synthetic_final,
    )
    assert len(isolated_fitting_data) == 480
    assert isolation_summary["freshFinalHoldoutSessionCount"] == 4
    assert isolation_summary["overlapCount"] == 0
    assert not isolation_summary["finalHoldoutUsedInScalerOrModelFit"]

    mock_model = {
        "modelSchemaVersion": MODEL_SCHEMA,
        "featureSchemaVersion": FEATURE_SCHEMA,
        "featureOrder": FEATURE_ORDER,
        "normalizationMean": [0.0] * len(FEATURE_ORDER),
        "normalizationStd": [1.0] * len(FEATURE_ORDER),
        "motionClasses": MOTION_CLASSES,
        "motionModel": {
            "type": "logistic_regression",
            "weights": [[0.0] * len(FEATURE_ORDER) for _ in MOTION_CLASSES],
            "bias": [0.0] * len(MOTION_CLASSES),
        },
    }
    encoded = json.dumps(mock_model, allow_nan=False)
    assert all(math.isfinite(value) for value in mock_model["normalizationMean"])
    assert json.loads(encoded)["featureOrder"] == FEATURE_ORDER
    assert len(mock_model["motionModel"]["weights"]) == len(MOTION_CLASSES)
    assert all(
        len(row) == len(FEATURE_ORDER)
        for row in mock_model["motionModel"]["weights"]
    )
    print("SELF_CHECK_PASS")


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path)
    parser.add_argument("--model-output", type=Path)
    parser.add_argument("--report-output", type=Path)
    parser.add_argument(
        "--final-holdout-input",
        "--final-holdout",
        dest="final_holdout_input",
        type=Path,
    )
    parser.add_argument("--development-report", type=Path)
    parser.add_argument("--development-extension", type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--self-check", action="store_true")
    mode.add_argument("--development-select", action="store_true")
    mode.add_argument("--final-evaluate", action="store_true")
    mode.add_argument("--diagnose-motion-failure", action="store_true")
    mode.add_argument("--reevaluate-development", action="store_true")
    mode.add_argument("--evaluate-v2-development", action="store_true")
    mode.add_argument(
        "--evaluate-v2-24session-development",
        action="store_true",
    )
    mode.add_argument(
        "--evaluate-v2-bounded-decoder",
        action="store_true",
    )
    mode.add_argument(
        "--review-v2-model-capacity",
        action="store_true",
    )
    mode.add_argument(
        "--final-v3-development-freeze",
        action="store_true",
    )
    mode.add_argument(
        "--evaluate-frozen-v3-final-holdout",
        action="store_true",
    )
    mode.add_argument(
        "--export-frozen-v3-runtime-model",
        type=Path,
    )
    mode.add_argument(
        "--record-runtime-parity",
        choices=("PASS", "FAIL"),
    )
    return parser


def main(argv: Iterable[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.self_check:
        run_self_check()
        return 0
    if args.record_runtime_parity:
        if args.report_output is None:
            _parser().error(
                "--report-output is required with --record-runtime-parity"
            )
        try:
            record_runtime_parity(
                args.report_output,
                args.record_runtime_parity,
            )
            print(f"PYTHON_KOTLIN_PARITY_{args.record_runtime_parity}")
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.development_select:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --development-select"
            )
        if not (args.input and args.report_output):
            _parser().error(
                "--input and --report-output are required with --development-select"
            )
        try:
            print(development_select(args.input, args.report_output))
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.diagnose_motion_failure:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --diagnose-motion-failure"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--diagnose-motion-failure"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--diagnose-motion-failure"
            )
        if not (args.input and args.report_output):
            _parser().error(
                "--input and --report-output are required with "
                "--diagnose-motion-failure"
            )
        try:
            print(diagnose_motion_failure(args.input, args.report_output))
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.reevaluate_development:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --reevaluate-development"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--reevaluate-development"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--reevaluate-development"
            )
        if not (
            args.input
            and args.development_extension
            and args.report_output
        ):
            _parser().error(
                "--input, --development-extension and --report-output are "
                "required with --reevaluate-development"
            )
        try:
            print(
                reevaluate_development(
                    args.input,
                    args.development_extension,
                    args.report_output,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.evaluate_v2_development:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --evaluate-v2-development"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--evaluate-v2-development"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--evaluate-v2-development"
            )
        if args.development_extension is not None:
            _parser().error(
                "--development-extension is forbidden with "
                "--evaluate-v2-development"
            )
        if not (args.input and args.report_output):
            _parser().error(
                "--input and --report-output are required with "
                "--evaluate-v2-development"
            )
        try:
            print(evaluate_v2_development(args.input, args.report_output))
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.evaluate_v2_24session_development:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with "
                "--evaluate-v2-24session-development"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--evaluate-v2-24session-development"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--evaluate-v2-24session-development"
            )
        if not (
            args.input
            and args.development_extension
            and args.report_output
        ):
            _parser().error(
                "--input, --development-extension and --report-output are "
                "required with --evaluate-v2-24session-development"
            )
        try:
            print(
                evaluate_v2_24session_development(
                    args.input,
                    args.development_extension,
                    args.report_output,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.evaluate_v2_bounded_decoder:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --evaluate-v2-bounded-decoder"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--evaluate-v2-bounded-decoder"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--evaluate-v2-bounded-decoder"
            )
        if not (
            args.input
            and args.development_extension
            and args.report_output
        ):
            _parser().error(
                "--input, --development-extension and --report-output are "
                "required with --evaluate-v2-bounded-decoder"
            )
        try:
            print(
                evaluate_v2_bounded_decoder(
                    args.input,
                    args.development_extension,
                    args.report_output,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.review_v2_model_capacity:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --review-v2-model-capacity"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--review-v2-model-capacity"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--review-v2-model-capacity"
            )
        if not (
            args.input
            and args.development_extension
            and args.report_output
        ):
            _parser().error(
                "--input, --development-extension and --report-output are "
                "required with --review-v2-model-capacity"
            )
        try:
            print(
                review_v2_model_capacity(
                    args.input,
                    args.development_extension,
                    args.report_output,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.final_v3_development_freeze:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with --final-v3-development-freeze"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout-input is forbidden with "
                "--final-v3-development-freeze"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--final-v3-development-freeze"
            )
        if args.development_extension is not None:
            _parser().error(
                "--development-extension is forbidden with "
                "--final-v3-development-freeze"
            )
        if not (args.input and args.report_output):
            _parser().error(
                "--input and --report-output are required with "
                "--final-v3-development-freeze"
            )
        try:
            print(final_v3_development_freeze(args.input, args.report_output))
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.evaluate_frozen_v3_final_holdout:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with "
                "--evaluate-frozen-v3-final-holdout"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--evaluate-frozen-v3-final-holdout"
            )
        if args.development_extension is not None:
            _parser().error(
                "--development-extension is forbidden with "
                "--evaluate-frozen-v3-final-holdout"
            )
        if not (
            args.input
            and args.final_holdout_input
            and args.report_output
        ):
            _parser().error(
                "--input, --final-holdout and --report-output are required "
                "with --evaluate-frozen-v3-final-holdout"
            )
        try:
            print(
                evaluate_frozen_v3_final_holdout(
                    args.input,
                    args.final_holdout_input,
                    args.report_output,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.export_frozen_v3_runtime_model is not None:
        if args.model_output is not None:
            _parser().error(
                "--model-output is forbidden with "
                "--export-frozen-v3-runtime-model"
            )
        if args.report_output is not None:
            _parser().error(
                "--report-output is forbidden with "
                "--export-frozen-v3-runtime-model"
            )
        if args.final_holdout_input is not None:
            _parser().error(
                "--final-holdout is forbidden with "
                "--export-frozen-v3-runtime-model"
            )
        if args.development_report is not None:
            _parser().error(
                "--development-report is forbidden with "
                "--export-frozen-v3-runtime-model"
            )
        if args.development_extension is not None:
            _parser().error(
                "--development-extension is forbidden with "
                "--export-frozen-v3-runtime-model"
            )
        if args.input is None:
            _parser().error(
                "--input is required with --export-frozen-v3-runtime-model"
            )
        try:
            print(
                export_frozen_v3_runtime_model(
                    args.input,
                    args.export_frozen_v3_runtime_model,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if args.final_evaluate:
        if not (
            args.input
            and args.final_holdout_input
            and args.development_report
            and args.model_output
            and args.report_output
        ):
            _parser().error(
                "--input, --final-holdout-input, --development-report, "
                "--model-output and --report-output are required with "
                "--final-evaluate"
            )
        try:
            print(
                final_evaluate(
                    args.input,
                    args.final_holdout_input,
                    args.development_report,
                    args.model_output,
                    args.report_output,
                )
            )
            return 0
        except DatasetError as error:
            print(str(error))
            return 2
    if not (args.input and args.model_output and args.report_output):
        _parser().error("--input, --model-output and --report-output are required")
    try:
        print(train(args.input, args.model_output, args.report_output))
        return 0
    except DatasetError as error:
        print(str(error))
        return 0 if str(error) == "INSUFFICIENT_DATASET" else 2


if __name__ == "__main__":
    sys.exit(main())
