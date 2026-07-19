#!/usr/bin/env python3
"""Fail CI if key handbook numbers drift from committed CSV tables."""
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TAB = ROOT / "volume-01" / "tables"
CH = ROOT / "volume-01" / "chapters"


def read_csv(name: str) -> list[dict[str, str]]:
    with (TAB / name).open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def approx(a: float, b: float, tol: float = 0.02) -> bool:
    return abs(a - b) <= tol


def check_ch14() -> None:
    rows = read_csv("ch14_batch_mini_case_summary.csv")
    a = rows[0]
    assert int(a["discoveries_q05_with_batch"]) == 1, "ch14 with-batch count"
    assert int(a["discoveries_q05_without_batch"]) >= 100, "ch14 without-batch count"
    text = (CH / "14-batch-effects.md").read_text(encoding="utf-8")
    assert "128" in text or str(a["discoveries_q05_without_batch"]) in text, "ch14 prose stale"


def check_ch15() -> None:
    rows = {r["cell_type"]: r for r in read_csv("ch15_flow_effects_by_celltype.csv")}
    mono_q = float(rows["Mono"]["q_value"])
    text = (CH / "15-flow-cytometry.md").read_text(encoding="utf-8")
    assert "0.81" not in text and "0.025" not in text.split("Mono")[1][:200], "ch15 monocyte stale"
    assert approx(mono_q, float(rows["Mono"]["q_value"]), 0.001)


def check_ch16() -> None:
    rows = {r["antigen"]: r for r in read_csv("ch16_screen_ppv_by_antigen.csv")}
    text = (CH / "16-antibody-discovery.md").read_text(encoding="utf-8")
    for ag in ("AgA", "AgB", "AgC"):
        hits = int(rows[ag]["n_hits"])
        assert str(hits) in text, f"ch16 {ag} hits {hits} missing from prose"


def check_ch09() -> None:
    rows = {r["model"]: r for r in read_csv("ch09_model_comparison.csv")}
    rf_auc = float(rows["random_forest"]["auc"])
    text = (CH / "09-prediction-vs-inference.md").read_text(encoding="utf-8")
    assert approx(rf_auc, 0.81, 0.02), "ch09 RF AUC csv"
    assert "0.81" in text, "ch09 RF AUC prose"
    assert "0.75" not in text.split("Random forest")[1][:120], "ch09 RF AUC stale"
    assert "10-fold" not in text.lower(), "ch09 CV fold count stale"
    assert re.search(r"(?:^|[^.])decile plot(?! when)", text, re.I) is None, (
        "ch09 calibration decile wording stale"
    )


def check_ch22() -> None:
    rows = read_csv("ch22_mediation_effects.csv")
    acme = next(r for r in rows if r["effect"].startswith("ACME"))
    text = (CH / "22-mediation-analysis.md").read_text(encoding="utf-8")
    assert "0.018" in acme["display"] and "0.018" in text, "ch22 ACME prose"
    assert "0.017" not in text, "ch22 ACME stale"
    assert "0.000 to 0.048" not in text, "ch22 ACME CI stale"


def check_appendix_o() -> None:
    text = (ROOT / "volume-01" / "appendix-o-ch04-comparison-extensions.md").read_text(
        encoding="utf-8"
    )
    assert "lower bound" in text.lower(), "appendix-o NI lower bound"
    assert "upper bound" not in text.lower(), "appendix-o NI upper bound stale"


def check_ch18() -> None:
    sens = read_csv("ch18_sensitivity_mixed_vs_fixed.csv")
    w52 = float(sens[1]["estimate"])
    text = (CH / "18-longitudinal-mixed-models.md").read_text(encoding="utf-8")
    assert approx(w52, 0.040, 0.01), "ch18 week-52 contrast"
    assert "0.038" not in text, "ch18 negative sign stale"
    assert "different standard error" not in text.lower(), "ch18 pseudo-replication wording stale"


def main() -> int:
    checks = [check_ch09, check_ch14, check_ch15, check_ch16, check_ch18, check_ch22, check_appendix_o]
    failed = []
    for fn in checks:
        try:
            fn()
        except AssertionError as e:
            failed.append(f"{fn.__name__}: {e}")
    if failed:
        print("verify_committed_outputs FAILED:")
        for line in failed:
            print(" -", line)
        return 1
    print(f"OK: {len(checks)} output consistency checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
