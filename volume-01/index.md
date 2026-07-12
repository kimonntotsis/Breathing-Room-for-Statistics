---
number-sections: false
---

# Welcome {.unnumbered}

You may have opened this book with a concrete problem in mind. That is how it is meant to be used.

## Choose your hat

Pick the row that matches your job. You do not need to read the whole volume.

| Your role | Start here | Read for your job | Skip unless needed |
|-----------|------------|-------------------|-------------------|
| **Pulmonologist / trial investigator** | [Preface](chapters/00-preface.md) → [Ch 1–2](chapters/01-statistical-thinking.md) → [Appendix B](appendix-b-quick-reference.md) | [Ch 3–4](chapters/03-descriptive-analysis.md), [Ch 8](chapters/08-validation-reporting.md), [Case A](chapters/12-case-studies.md) | Omics (Ch 13–17), causal (Ch 21) |
| **Translational biologist** | [Ch 1–2](chapters/01-statistical-thinking.md) → [Appendix B §1b](appendix-b-quick-reference.md) | [Ch 13–15](chapters/13-differential-analysis-fdr.md), [Ch 17](chapters/17-integrated-castor-hd.md), [Cases C–D](chapters/12-case-studies.md) | Survival (Ch 19) until you need it |
| **Analyst (R)** | [Appendix A](appendix-a-r-setup.md) → [Ch 3](chapters/03-descriptive-analysis.md) → [Appendix B](appendix-b-quick-reference.md) | Outcome chapter + [Ch 8](chapters/08-validation-reporting.md); technique cards and R lab | — |
| **Fellow / self-study** | Paths below | Ch 1–12 + [Appendix F](appendix-f-exercises.md) | Parts VI–VIII by project |

**Investigator shortcut:** Chapters with heavy method choice include an **Investigator path (≈20 min)** and a **Method choice at a glance** table (Method | When | Why). For slides and Figure 1, start with [Appendix I](appendix-i-figure-hygiene.md) and [Ch 3: Plot choice by estimand](chapters/03-descriptive-analysis.md#plot-choice-by-estimand).

**Too much book?** Investigators who only review protocols/Methods: [Appendix J (~2 hours)](appendix-j-investigator-minimum-path.md) — explicit skip list.

**Where are you right now?**

- **As an investigator:** drafting a protocol or grant. You need the estimand and primary analysis locked before recruitment. Start with the [Preface](chapters/00-preface.md), then [Chapter 1](chapters/01-statistical-thinking.md) (estimands and CASTOR) and [Chapter 2](chapters/02-respiratory-data.md) (outcome types). When the endpoint is fixed, use [Appendix B](appendix-b-quick-reference.md) to prespecify the method.

- **As an investigator:** reviewing a Methods section or steering slide. You want to know whether the analysis matches the question. Read [Appendix H](appendix-h-clinicians-route.md), or jump to the chapter for your endpoint via [Appendix B](appendix-b-quick-reference.md). [Chapter 12, Case A](chapters/12-case-studies.md) shows a full trial narrative in one pass.

- **As an analyst:** running analyses in R. Install once ([Appendix A](appendix-a-r-setup.md)), describe the cohort ([Chapter 3](chapters/03-descriptive-analysis.md)), then open the chapter that matches your outcome. [METHOD_MAP](METHOD_MAP.md) helps when two methods look plausible.

- **Teaching or self-study.** Work through Ch 1–12 with [Appendix F](appendix-f-exercises.md); add Ch 13–17 for omics blocks or Ch 18–21 for longitudinal and causal material.

## Suggested reading paths

These are linear routes through the same CASTOR cohort. Technique chapters stay reference-first; the **narrative spine** is [Chapter 12](chapters/12-case-studies.md) (Cases A–E).

| Path | Chapters (in order) | Capstone in Ch 12 |
|------|---------------------|-------------------|
| **Investigator** | [Preface](chapters/00-preface.md) → [Ch 1–2](chapters/01-statistical-thinking.md) → [Ch 3–4](chapters/03-descriptive-analysis.md) → [Ch 8](chapters/08-validation-reporting.md) | [Case A](chapters/12-case-studies.md) (RCT FEV1); add [Case E](chapters/12-case-studies.md) if visits or survival matter |
| **Analyst** | [Ch 1–2](chapters/01-statistical-thinking.md) → [Ch 3](chapters/03-descriptive-analysis.md) → outcome chapter via [Appendix B](appendix-b-quick-reference.md) → [Ch 5–7](chapters/05-linear-models.md) or [Ch 6](chapters/06-generalized-linear-models.md) as needed | [Cases A & B](chapters/12-case-studies.md); [Ch 18–19](chapters/18-longitudinal-mixed-models.md) + Case E for repeated measures |
| **Omics / discovery** | [Ch 1–2](chapters/01-statistical-thinking.md) → [Ch 10–11](chapters/10-dimensionality-reduction.md) → [Ch 13–16](chapters/13-differential-analysis-fdr.md) → [Ch 17](chapters/17-integrated-castor-hd.md) | [Cases C & D](chapters/12-case-studies.md) before or after Part VI |

Full path tables and file lists: [Appendix G](appendix-g-handbook-navigation.md) (appendices appear in **reader-importance order** in the PDF: G → J → H → I → B → …; letters stay fixed for citations).

**What holds the volume together**

Every example uses the same synthetic patients (**CASTOR**, a COPD-oriented teaching cohort; omics extensions in **CASTOR-HD**), so a Table 1 in [Chapter 3](chapters/03-descriptive-analysis.md) reappears in regression, survival, and discovery chapters. **APATE** ([vignette](APATE_VIGNETTE.md)) is prose-only: Greek *Apate* (deceit) names the fictional messy registry that contrasts with clean CASTOR — no CSV. R code is there to reproduce each step; you can read the argument without running it. The workflow (question first, limits last) is spelled out in [Chapter 1](chapters/01-statistical-thinking.md).

**How the eight parts fit**

| If your question is about… | Start in… |
|----------------------------|-----------|
| What to estimate, and what data you have | Part I (Ch 1–2) |
| Table 1, group comparisons | Part II (Ch 3–4) |
| Adjusted associations (FEV1, yes/no, counts) | Part III (Ch 5–7) |
| CONSORT/STROBE/TRIPOD, prediction metrics | Part IV (Ch 8–9) |
| PCA, clustering, worked case studies | Part V (Ch 10–12) |
| Proteomics, RNA, flow, antibody screens | Part VI (Ch 13–16) |
| Integrated omics pipeline | Part VII (Ch 17) |
| Repeated visits, survival, missing data, confounding | Part VIII (Ch 18–21) |

Full chapter list, topic index, datasets, and R commands: [Appendix G](appendix-g-handbook-navigation.md).
