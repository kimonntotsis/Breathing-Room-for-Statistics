# Handbook status and edition notes

**Title:** *Breathing Room for Statistics*  
**Author:** Kimon Ntotsis  
**Format:** Open handbook (Quarto book + GitHub repository)  
**Primary audience:** Respiratory investigators and analysts  

---

## Edition status

| Item | Status |
|------|--------|
| **Release** | **v1.0.0** (2026-06-28) — [GitHub release](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.0.0) with PDF |
| **Volume** | Single volume (Ch 1–21 + appendices A–K; PDF order G → J → **K** → H → I → B → A → C → D → F) |
| **Data** | Synthetic CASTOR / CASTOR-HD (`data/*.csv`) |
| **PDF** | `./build-handbook-pdf.sh`; CI verifies figure markdown + page/figure counts ([`.github/workflows/handbook-pdf.yml`](../.github/workflows/handbook-pdf.yml)) |
| **Peer review** | Targeted external read — [REVIEW_REQUEST.md](../REVIEW_REQUEST.md), [REVIEWER_RUBRIC](REVIEWER_RUBRIC.md) |
| **Living document** | Chapters and figures update with the repository; cite a **release tag** for fixed editions |

This is a **living handbook**: prefer tagged releases for citations in grants and protocols. See [Preface: Cite this book](chapters/00-preface.md#cite-this-book).

---

## What is stable

- CASTOR workflow (Clinical → Assess → Select → Test → Output → Report limits)
- Chapter template (technique cards, wrong analysis, reporting)
- Investigator paths and Method choice tables (Ch 1–21 where applicable)
- Figure hygiene pairs (`viz_pair_*.png`, Appendix I)
- Reproducible R entry: `source("R/00_setup.R")`

---

## Known teaching simplifications

Documented in [APATE_VIGNETTE](APATE_VIGNETTE.md):

- Clean visit schedules and low missingness in core CASTOR tables
- Synthetic omics with intentional batch structure for teaching
- No real patient identifiers or site-level confidential data

---

## Suggested citation

**APA 7 (handbook):** Ntotsis, K. (2026). *Breathing room for statistics: A statistical handbook for respiratory research: from trials to omics and prediction* [Open handbook]. GitHub. `https://github.com/kimonntotsis/Breathing-Room-for-Statistics`

**Release pin:** `https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.0.0`

---

## Build and figures

```bash
./build-handbook-pdf.sh
python3 volume-01/scripts/verify_figure_markdown.py
pip install pypdf && python3 volume-01/scripts/verify_pdf_build.py
```

```r
source("R/00_setup.R")
source("R/examples/generate_figures.R")   # includes viz pairs
```

Figure index: [FIGURE_INDEX](FIGURE_INDEX.md).

---

## Feedback

Open an issue on the repository for errata, unclear estimand examples, or requests for additional wrong/right figure pairs.
