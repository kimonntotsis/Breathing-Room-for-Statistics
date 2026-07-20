#!/usr/bin/env python3
"""Replace verbose per-chapter Related chapters / Handbook resources blocks with a compact See also include."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parent.parent
CHAPTERS = VOLUME / "chapters"
INCLUDE = "{{< include ../_includes/chapter-see-also.md >}}"

NEIGHBORS: dict[str, str] = {
    "01-statistical-thinking.md": "Ch [2](chapters/02-respiratory-data.md) (data types) · Ch [4](chapters/04-comparing-groups.md) (comparisons)",
    "02-respiratory-data.md": "Ch [3](chapters/03-descriptive-analysis.md) · Ch [4](chapters/04-comparing-groups.md)",
    "03-descriptive-analysis.md": "Ch [4](chapters/04-comparing-groups.md) · Ch [8](chapters/08-validation-reporting.md) (Table 1 reporting)",
    "04-comparing-groups.md": "Ch [5](chapters/05-linear-models.md) · Ch [6](chapters/06-generalized-linear-models.md) · [Appendix O](../appendix-o-ch04-comparison-extensions.md) (NI, cluster, crossover)",
    "05-linear-models.md": "Ch [4](chapters/04-comparing-groups.md) · Ch [6](chapters/06-generalized-linear-models.md)",
    "06-generalized-linear-models.md": "Ch [5](chapters/05-linear-models.md) · Ch [7](chapters/07-model-building.md)",
    "07-model-building.md": "Ch [6](chapters/06-generalized-linear-models.md) · Ch [8](chapters/08-validation-reporting.md)",
    "08-validation-reporting.md": "Ch [9](chapters/09-prediction-vs-inference.md) · [Appendix O](../appendix-o-ch04-comparison-extensions.md) (NI reporting)",
    "09-prediction-vs-inference.md": "Ch [8](chapters/08-validation-reporting.md) · Ch [17](chapters/17-integrated-castor-hd.md) (nested CV)",
    "10-dimensionality-reduction.md": "Ch [11](chapters/11-clustering.md) · Ch [13](chapters/13-differential-analysis-fdr.md)",
    "11-clustering.md": "Ch [10](chapters/10-dimensionality-reduction.md) · Ch [12](chapters/12-case-studies.md) (Case C)",
    "12-case-studies.md": "Ch [4](chapters/04-comparing-groups.md)–[11](chapters/11-clustering.md) (Cases A–C) · Part VIII for Case E",
    "13-differential-analysis-fdr.md": "Ch [14](chapters/14-batch-effects.md) · [Appendix L](../appendix-l-omics-analyst-track.md)",
    "14-batch-effects.md": "Ch [13](chapters/13-differential-analysis-fdr.md) · Ch [17](chapters/17-integrated-castor-hd.md)",
    "15-flow-cytometry.md": "Ch [16](chapters/16-antibody-discovery.md) · Ch [17](chapters/17-integrated-castor-hd.md)",
    "16-antibody-discovery.md": "Ch [15](chapters/15-flow-cytometry.md) · Ch [17](chapters/17-integrated-castor-hd.md)",
    "17-integrated-castor-hd.md": "Ch [13](chapters/13-differential-analysis-fdr.md)–[16](chapters/16-antibody-discovery.md)",
    "18-longitudinal-mixed-models.md": "Ch [19](chapters/19-survival-analysis.md) · Ch [20](chapters/20-missing-data.md)",
    "19-survival-analysis.md": "Ch [18](chapters/18-longitudinal-mixed-models.md) · Ch [20](chapters/20-missing-data.md)",
    "20-missing-data.md": "Ch [9](chapters/09-prediction-vs-inference.md) (leakage) · Ch [18](chapters/18-longitudinal-mixed-models.md)",
    "21-causal-inference.md": "Ch [22](chapters/22-mediation-analysis.md) · Ch [12](chapters/12-case-studies.md) (Case B)",
    "22-mediation-analysis.md": "Ch [21](chapters/21-causal-inference.md) · Ch [12](chapters/12-case-studies.md)",
}

SECTION_START = re.compile(
    r"^## (Related chapters|Handbook resources)\s*$",
    re.M,
)
SECTION_END = re.compile(
    r"^## (Further reading|Exercises|Where we go next|Quick reference|Alternatives)",
    re.M,
)


def trim_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if INCLUDE in text:
        return False

    # Drop duplicate Related chapters + Handbook resources blocks.
    while True:
        m = SECTION_START.search(text)
        if not m:
            break
        start = m.start()
        rest = text[m.end() :]
        end_m = SECTION_END.search(rest)
        end = m.end() + (end_m.start() if end_m else len(rest))
        text = text[:start] + text[end:]

    text = re.sub(r"\n{4,}", "\n\n\n", text).rstrip() + "\n"

    neighbor = NEIGHBORS.get(path.name, "")
    block = INCLUDE + "\n"
    if neighbor:
        block += f"\n**Near neighbors:** {neighbor}\n"

    # Insert before Further reading, else after Where we go next, else at end.
    for marker in ("## Further reading", "## Exercises", "## Where we go next"):
        idx = text.find(marker)
        if idx != -1:
            if marker == "## Where we go next":
                # place See also after the Where we go next section body
                after = text.find("\n## ", idx + 1)
                if after == -1:
                    text = text.rstrip() + "\n\n" + block
                else:
                    text = text[:after].rstrip() + "\n\n" + block + "\n" + text[after + 1 :]
            else:
                text = text[:idx].rstrip() + "\n\n" + block + "\n" + text[idx:]
            break
    else:
        text = text.rstrip() + "\n\n" + block

    if text != path.read_text(encoding="utf-8"):
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> int:
    changed = []
    for path in sorted(CHAPTERS.glob("*.md")):
        if path.name.startswith("00-"):
            continue
        if trim_file(path):
            changed.append(path.name)
    print(f"Trimmed footers in {len(changed)} chapters:")
    for name in changed:
        print(f"  - {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
