# Handbook status and edition notes

**Title:** *Breathing Room for Statistics*
**Author:** Kimon Ntotsis
**Format:** Open handbook (Quarto book + GitHub repository)
**Primary audience:** Respiratory investigators and analysts

---

## Edition status

| Item | Status |
|------|--------|
| **Release (feedback)** | **v1.1.0-review** (2026-07-15): [GitHub release](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.1.0-review) with PDF |
| **Prior release** | v1.0.0 (2026-06-28) |
| **Volume** | Single volume (Ch 0–22 + appendices A–N; PDF order G → J → K → H → I → B → A → C → D → F → L → M → N) |
| **PDF build** | 415 pages, 89 figure labels (Jul 2026 verify) |
| **Data** | Synthetic CASTOR / CASTOR-HD (`data/*.csv`) |
| **PDF build** | `./build-handbook-pdf.sh`; CI verifies figure markdown + page/figure counts ([`.github/workflows/handbook-pdf.yml`](../.github/workflows/handbook-pdf.yml)) |
| **Peer review** | **Open for targeted read:** [REVIEW_REQUEST.md](../REVIEW_REQUEST.md), [REVIEWER_RUBRIC](REVIEWER_RUBRIC.md) |
| **Living document** | Chapters and figures update with the repository; cite a **release tag** for fixed editions |

This is a **living handbook**: prefer tagged releases for citations in grants and protocols. See [Preface: Cite this book](chapters/00-preface.md#cite-this-book) and [Preface: Circulating for feedback](chapters/00-preface.md#circulating-for-feedback-reviewers).

---

## What is stable

- CASTOR workflow (Clinical → Assess → Select → Test → Output → Report limits)
- Chapter template (technique cards, wrong analysis, reporting)
- In this chapter sections and method choice tables (Ch 1–22 where applicable)
- Figure hygiene pairs (`viz_pair_*.png`, Appendix I)
- Reproducible R entry: `source("R/00_setup.R")`
- Handbook figure theme (`R/viz_handbook.R`)

---

## Known teaching simplifications

Documented in [APATE_VIGNETTE](APATE_VIGNETTE.md) and Ch 13 callouts:

- Clean visit schedules and low missingness in core CASTOR tables
- Synthetic omics with intentional batch structure for teaching
- Ch 13 per-feature `lm` / `glm.nb` loops vs production DESeq2/limma in [Appendix L](appendix-l-omics-analyst-track.md)
- No real patient identifiers or site-level confidential data
- No wet-lab RNA extraction or FASTQ pipelines (deliverables in [Appendix M](appendix-m-bioinformatics-deliverables.md))

---

## Suggested citation

**APA 7 (handbook):** Ntotsis, K. (2026). *Breathing room for statistics: A statistical handbook for respiratory research: from trials to omics and prediction* [Open handbook]. GitHub. `https://github.com/kimonntotsis/Breathing-Room-for-Statistics`

**Feedback edition pin:** `https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.1.0-review`

---

## Build and figures

```bash
./build-handbook-pdf.sh
python3 volume-01/scripts/verify_figure_markdown.py
pip install pypdf && python3 volume-01/scripts/verify_pdf_build.py
```

```r
source("R/00_setup.R")
source("R/examples/generate_figures.R") # includes viz pairs
source("R/run_all_examples.R")
```

Figure index: [FIGURE_INDEX](FIGURE_INDEX.md).

---

## Feedback

Open a GitHub issue with label **`review`** for targeted feedback (see [REVIEW_REQUEST.md](../REVIEW_REQUEST.md)). For errata and figure requests, open a general issue on the repository.
