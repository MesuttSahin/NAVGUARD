#!/usr/bin/env python3
"""Privacy-preserving aggregate inspection for NAVGUARD AI session CSVs."""

from __future__ import annotations

import argparse
import csv
import json
import math
import sys
import tempfile
from collections import Counter
from pathlib import Path

from train_navguard_ai import (
    DATASET_CONTRACTS,
    DATASET_SCHEMA_V1,
    DATASET_SCHEMA_V2,
    DATASET_SCHEMA_V3,
    EXPECTED_COLUMNS_V1,
    EXPECTED_COLUMNS_V2,
    EXPECTED_COLUMNS_V3,
    FEATURE_ORDER_V1,
    FEATURE_ORDER_V2,
    FEATURE_ORDER_V3,
    FEATURE_SCHEMA_V1,
    FEATURE_SCHEMA_V2,
    FEATURE_SCHEMA_V3,
    FORBIDDEN_FRAGMENTS,
    METADATA_COLUMNS,
    MOTION_CLASSES,
)


def inspect(input_path: Path) -> dict[str, object]:
    files = sorted(input_path.glob("*.csv")) if input_path.is_dir() else [input_path]
    files = [path for path in files if path.is_file()]
    if not files:
        return {"status": "INSUFFICIENT_DATASET", "sessionCount": 0, "windowCount": 0}
    sessions: set[str] = set()
    labels: Counter[str] = Counter()
    windows = 0
    selected_contract: tuple[str, str] | None = None
    selected_feature_order: list[str] | None = None
    for path in files:
        with path.open("r", encoding="utf-8", newline="") as handle:
            reader = csv.DictReader(handle)
            first_row = next(reader, None)
            if first_row is None:
                raise ValueError("INSUFFICIENT_DATASET")
            contract = (
                first_row.get("schema_version", ""),
                first_row.get("feature_schema_version", ""),
            )
            feature_order = DATASET_CONTRACTS.get(contract)
            if feature_order is None:
                raise ValueError("dataset/feature schema mismatch")
            if selected_contract is not None and contract != selected_contract:
                raise ValueError("MIXED_FEATURE_SCHEMA_NOT_ALLOWED")
            selected_contract = contract
            selected_feature_order = feature_order
            expected_columns = METADATA_COLUMNS + feature_order
            if reader.fieldnames != expected_columns:
                raise ValueError("dataset column order/schema mismatch")
            if any(
                fragment in column.lower()
                for column in reader.fieldnames
                for fragment in FORBIDDEN_FRAGMENTS
            ):
                raise ValueError("forbidden dataset column")
            for row in [first_row, *reader]:
                row_contract = (
                    row["schema_version"],
                    row["feature_schema_version"],
                )
                if row_contract != contract:
                    raise ValueError("MIXED_FEATURE_SCHEMA_NOT_ALLOWED")
                if row["motion_label"] not in MOTION_CLASSES:
                    raise ValueError("unknown motion label")
                if not all(math.isfinite(float(row[name])) for name in feature_order):
                    raise ValueError("non-finite feature")
                sessions.add(row["session_id"])
                labels[row["motion_label"]] += 1
                windows += 1
    if selected_contract is None or selected_feature_order is None:
        return {"status": "INSUFFICIENT_DATASET", "sessionCount": 0, "windowCount": 0}
    return {
        "status": "VALID",
        "datasetSchemaVersion": selected_contract[0],
        "featureSchemaVersion": selected_contract[1],
        "featureCount": len(selected_feature_order),
        "sessionCount": len(sessions),
        "windowCount": windows,
        "motionWindowCounts": {name: labels[name] for name in MOTION_CLASSES},
        "rawRowsReturned": False,
        "privatePathsReturned": False,
    }


def self_check() -> None:
    assert len(EXPECTED_COLUMNS_V1) == 11 + 26
    assert len(EXPECTED_COLUMNS_V2) == 11 + 34
    assert len(EXPECTED_COLUMNS_V3) == 11 + 40
    assert EXPECTED_COLUMNS_V2[: 11 + 26] == EXPECTED_COLUMNS_V1
    assert EXPECTED_COLUMNS_V3[: 11 + 34] == EXPECTED_COLUMNS_V2
    assert DATASET_SCHEMA_V1 == "navguard_ai_dataset_v1"
    assert DATASET_SCHEMA_V2 == "navguard_ai_dataset_v2"
    assert DATASET_SCHEMA_V3 == "navguard_ai_dataset_v3"
    assert FEATURE_SCHEMA_V1 == "navguard_ai_features_v1"
    assert FEATURE_SCHEMA_V2 == "navguard_ai_features_v2"
    assert FEATURE_SCHEMA_V3 == "navguard_ai_features_v3"
    assert FEATURE_ORDER_V2[:26] == FEATURE_ORDER_V1
    assert FEATURE_ORDER_V3[:34] == FEATURE_ORDER_V2
    assert FEATURE_ORDER_V3[34:] == [
        "heading_signed_net_turn_rad",
        "arcore_signed_net_turn_rad",
        "heading_path_turn_direction_agreement",
        "heading_path_turn_magnitude_difference_ratio",
        "heading_path_turn_coherence",
        "arcore_cross_track_rms_m",
    ]
    assert all(name in MOTION_CLASSES for name in MOTION_CLASSES)
    assert not any(
        fragment in column.lower()
        for column in EXPECTED_COLUMNS_V3
        for fragment in FORBIDDEN_FRAGMENTS
    )
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)

        def write_fixture(
            path: Path,
            dataset_schema: str,
            feature_schema: str,
            feature_order: list[str],
        ) -> None:
            row = {
                "schema_version": dataset_schema,
                "feature_schema_version": feature_schema,
                "session_id": path.stem,
                "window_index": "0",
                "motion_label": "STRAIGHT_WALK",
                "arcore_reliable_label": "",
                "arcore_reliable_available": "false",
                "pdr_reliable_label": "",
                "pdr_reliable_available": "false",
                "heading_reliable_label": "",
                "heading_reliable_available": "false",
                **{name: "0.0" for name in feature_order},
            }
            with path.open("w", encoding="utf-8", newline="") as handle:
                writer = csv.DictWriter(
                    handle,
                    fieldnames=METADATA_COLUMNS + feature_order,
                )
                writer.writeheader()
                writer.writerow(row)

        v1 = root / "v1"
        v2 = root / "v2"
        v3 = root / "v3"
        mixed = root / "mixed_v2_v3"
        wrong_count = root / "wrong_count"
        wrong_order = root / "wrong_order"
        v1.mkdir()
        v2.mkdir()
        v3.mkdir()
        mixed.mkdir()
        wrong_count.mkdir()
        wrong_order.mkdir()
        write_fixture(
            v1 / "v1.csv",
            DATASET_SCHEMA_V1,
            FEATURE_SCHEMA_V1,
            FEATURE_ORDER_V1,
        )
        write_fixture(
            v2 / "v2.csv",
            DATASET_SCHEMA_V2,
            FEATURE_SCHEMA_V2,
            FEATURE_ORDER_V2,
        )
        write_fixture(
            v3 / "v3.csv",
            DATASET_SCHEMA_V3,
            FEATURE_SCHEMA_V3,
            FEATURE_ORDER_V3,
        )
        write_fixture(
            mixed / "v2.csv",
            DATASET_SCHEMA_V2,
            FEATURE_SCHEMA_V2,
            FEATURE_ORDER_V2,
        )
        write_fixture(
            mixed / "v3.csv",
            DATASET_SCHEMA_V3,
            FEATURE_SCHEMA_V3,
            FEATURE_ORDER_V3,
        )
        write_fixture(
            wrong_count / "wrong_count.csv",
            DATASET_SCHEMA_V3,
            FEATURE_SCHEMA_V3,
            FEATURE_ORDER_V3[:-1],
        )
        wrong_order_features = FEATURE_ORDER_V3.copy()
        wrong_order_features[-2], wrong_order_features[-1] = (
            wrong_order_features[-1],
            wrong_order_features[-2],
        )
        write_fixture(
            wrong_order / "wrong_order.csv",
            DATASET_SCHEMA_V3,
            FEATURE_SCHEMA_V3,
            wrong_order_features,
        )
        assert inspect(v1)["featureCount"] == 26
        assert inspect(v2)["featureCount"] == 34
        assert inspect(v3)["featureCount"] == 40
        try:
            inspect(mixed)
            raise AssertionError("mixed V2/V3 dataset was accepted")
        except ValueError as error:
            assert str(error) == "MIXED_FEATURE_SCHEMA_NOT_ALLOWED"
        for invalid in (wrong_count, wrong_order):
            try:
                inspect(invalid)
                raise AssertionError(f"invalid V3 schema was accepted: {invalid.name}")
            except ValueError as error:
                assert str(error) == "dataset column order/schema mismatch"
    print("SELF_CHECK_PASS")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path)
    parser.add_argument("--self-check", action="store_true")
    args = parser.parse_args()
    if args.self_check:
        self_check()
        return 0
    if args.input is None:
        parser.error("--input is required")
    try:
        print(json.dumps(inspect(args.input), indent=2, sort_keys=True))
        return 0
    except (OSError, ValueError) as error:
        print(f"DATASET_INVALID: {error}")
        return 2


if __name__ == "__main__":
    sys.exit(main())
