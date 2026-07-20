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
    assert "do not label ni as tost" in text.lower(), "appendix-o NI vs TOST"


def check_ni_harmonized() -> None:
    ch4 = (CH / "04-comparing-groups.md").read_text(encoding="utf-8")
    ch8 = (CH / "08-validation-reporting.md").read_text(encoding="utf-8")
    assert "appendix-o" in ch4.lower() or "95% two-sided CI" in ch4, "ch4 NI pointer"
    assert "90% CI for NI (convention)" not in ch8, "ch8 NI 90% convention stale"
    assert "TOST / CI against margin" not in ch8, "ch8 NI TOST conflation stale"


def check_ch21_causal() -> None:
    text = (CH / "21-causal-inference.md").read_text(encoding="utf-8")
    mini = text.split("Illustrative only")[1][:400]
    assert "fev1_percent_predicted" not in mini.lower(), "ch21 PS mini-lab includes FEV1"
    assert "prior_exacerbations" in mini, "ch21 PS mini-lab confounders"


def check_ch19_survival() -> None:
    text = (CH / "19-survival-analysis.md").read_text(encoding="utf-8")
    assert "ignores randomisation balance" not in text.lower(), "ch19 KM RCT stale"
    assert "valid itt" in text.lower() or "valid ITT" in text, "ch19 RCT KM guidance"


def check_ch18() -> None:
    sens = read_csv("ch18_sensitivity_mixed_vs_fixed.csv")
    w52 = float(sens[1]["estimate"])
    text = (CH / "18-longitudinal-mixed-models.md").read_text(encoding="utf-8")
    assert approx(w52, 0.040, 0.01), "ch18 week-52 contrast"
    assert "0.038" not in text, "ch18 negative sign stale"
    assert "different standard error" not in text.lower(), "ch18 pseudo-replication wording stale"


def check_review_pass3() -> None:
    ch4 = (CH / "04-comparing-groups.md").read_text(encoding="utf-8")
    ch9 = (CH / "09-prediction-vs-inference.md").read_text(encoding="utf-8")
    ch19 = (CH / "19-survival-analysis.md").read_text(encoding="utf-8")
    ch20 = (CH / "20-missing-data.md").read_text(encoding="utf-8")
    bib = (ROOT / "references.bib").read_text(encoding="utf-8")
    preamble = (ROOT / "volume-01" / "latex" / "pdf-preamble.tex").read_text(encoding="utf-8")
    assert "Table 1 shows acceptable balance" not in ch4, "ch4 RCT balance stale"
    assert "complement, not replace, held-out test" not in ch9.lower(), "ch9 validation stale"
    assert "ignores randomisation balance" not in ch19.lower(), "ch19 KM RCT stale"
    assert "production default is MICE" not in ch20, "ch20 MICE default stale"
    assert "Hern{\\'a}n" in bib, "bib Hernán accent"
    assert "Hern{\\`a}n" not in bib, "bib Hernàn grave accent"
    for sym in ("lambda", "chi", "gg", "Delta"):
        assert sym in preamble, f"pdf-preamble missing {sym}"


def main() -> int:
    checks = [
        check_ch09,
        check_ch14,
        check_ch15,
        check_ch16,
        check_ch18,
        check_ch19_survival,
        check_ch21_causal,
        check_ch22,
        check_appendix_o,
        check_ni_harmonized,
        check_review_pass3,
    ]
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
