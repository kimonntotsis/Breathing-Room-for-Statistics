# Handbook guide: how to use this book

This volume is designed as a **working handbook** for respiratory researchers who need statistics and R **on purpose** — especially early- and mid-career investigators and seniors learning to review analyses without becoming mathematicians or software engineers. Choose a method, check assumptions, run R when helpful, report correctly. You do not need to read cover-to-cover. New readers: [Preface](chapters/00-preface.md) (including [Why I wrote this](chapters/00-preface.md#why-i-wrote-this)) → [Welcome tour](chapters/00-welcome.md). Full tables and file lists: [Appendix G](appendix-g-handbook-navigation.md).

---

## Reader paths

| If you want to… | Start with | Then |
|-----------------|------------|------|
| **Investigator (read without R)** | [Appendix H](appendix-h-clinicians-route.md) → [Appendix B](appendix-b-quick-reference.md) | Technique card + Reporting template |
| **Analyst (run R)** | [Ch 2](chapters/02-respiratory-data.md) → [Ch 3](chapters/03-descriptive-analysis.md) | [METHOD_MAP.md](METHOD_MAP.md) |
| **Pick among similar methods** | [METHOD_MAP.md](METHOD_MAP.md) + [Ch 1 estimands](chapters/01-statistical-thinking.md) | Ch 4–6 technique cards; Ch 8 validation |
| **Teach or self-study** | [Preface](chapters/00-preface.md) → [Welcome tour](chapters/00-welcome.md) → Core 1–12 | [Exercises](exercises/) + [solutions](solutions/) |
| **Write a manuscript** | [Appendix B](appendix-b-quick-reference.md) | Reporting template in chapter + [Ch 8](chapters/08-validation-reporting.md) checklists |

### Narrative spine (Chapter 12)

For a continuous read on one CASTOR cohort, follow a role path on the [Welcome](chapters/00-welcome.md) page or [Appendix G](appendix-g-handbook-navigation.md), then open the matching case study:

- **Investigator:** Ch 1–2 → 3–4 → 8 → [Case A](chapters/12-case-studies.md) (and Case E if the SAP includes visits or survival)
- **Analyst:** Ch 1–3 → Appendix B → 4–7 → [Cases A & B](chapters/12-case-studies.md)
- **Omics:** Ch 1–2 → 10–11 → 13–17 → [Cases C & D](chapters/12-case-studies.md)

---

## The five navigation tools

| Tool | Purpose | When to open |
|------|---------|--------------|
| **[Appendix B](appendix-b-quick-reference.md)** | One-page tables: outcome → test → model | **Before any analysis** |
| **[METHOD_MAP.md](METHOD_MAP.md)** | Full decision tree + technique inventory | Choosing among similar methods |
| **[FIGURE_INDEX.md](FIGURE_INDEX.md)** | All plots and decision figures | Writing / teaching / slides |
| **[Appendix C](appendix-c-glossary.md)** | Terms in plain and precise language | Unfamiliar jargon |
| **[REFERENCES.md](REFERENCES.md)** | Curated bibliography by topic | Methods sentences, background reading |

---

## Standard workflow (every analysis)

**CASTOR** is the order of work: **C**linical question, **A**ssess design and data, **S**elect method, **T**est and fit, **O**utput estimand, **R**eport limits. Pipeline figure and decision tree: [Chapter 1](chapters/01-statistical-thinking.md) and [Appendix B](appendix-b-quick-reference.md).

```
1. Clinical question (one sentence)          → Ch 1
2. Outcome type + design                     → Ch 2, Appendix B
3. Choose method                             → METHOD_MAP, decision figure
4. Describe sample (Table 1)                 → Ch 3
5. Fit model / test                          → Ch 4–7, R/examples/
6. Diagnostics + sensitivity                 → Ch 7–8
7. Report estimate + CI + limitations        → Ch 8
8. State what was NOT proven                 → Wrong analysis panels
```

Full integration: [Ch 12 case studies](chapters/12-case-studies.md).

---

## Chapter map (full handbook)

| Part | Chapters | Question answered |
|------|----------|-------------------|
| **I Foundations** | 0–2 | How should I think? What data do I have? |
| **II Describe & compare** | 3–4 | What does the sample look like? Are groups different? |
| **III Regression** | 5–7 | What is associated after adjustment? Which predictors? |
| **IV Validate & predict** | 8–9 | How do I report? Can I predict risk? |
| **V Discovery (core)** | 10–12 | Structure in markers? CASTOR case studies |
| **VI High-dimensional biology** | 13–16 | Omics DE, batch, flow, antibody screens |
| **VII Integrated capstone** | 17 | End-to-end CASTOR-HD + elastic net |
| **VIII Longitudinal & causal** | 18–21 | Repeated FEV1, survival, missing data, causality |

Each method in Ch 4–11 and major techniques in Ch 13–21 follows [CHAPTER_TEMPLATE.md](CHAPTER_TEMPLATE.md):

1. Clinical question  
2. Technique card (when to use / when NOT)  
3. Dual interpretation (plain / precise / practice)  
4. Caveats box  
5. Wrong analysis ⚠  
6. Reporting template  
7. R lab + sensitivity  

---

## R setup (once per session)

Install guide: **[Appendix A](appendix-a-r-setup.md)** (in the PDF). Quick start:

```r
setwd("/path/to/Breathing-Room-for-Statistics")  # your clone path; or open as Posit project
source("R/00_setup.R")
source("R/generate_data.R")
source("R/examples/generate_figures.R")       # all handbook figures
source("R/run_all_examples.R")                # optional: full chapter scripts
```

---

## CASTOR recurring cohort

The workflow above applies to every analysis. The **CASTOR cohort** is where you run it: one **COPD-flavoured** synthetic dataset from Ch 3→12 (**CLD** and broader pulmonary work when endpoints match); **CASTOR-HD** extends through Ch 13–17. See [RECURRING_COHORT.md](RECURRING_COHORT.md).

---

## Peer review before you rely on a chapter

Priority chapters for external read: **4, 6, 13, 18, 20**. Use [REVIEWER_RUBRIC.md](REVIEWER_RUBRIC.md) with one investigator and one analyst. [INSTRUCTOR_PACK.md](INSTRUCTOR_PACK.md) suggests a teaching sequence.

---

## Extended topics

Longitudinal spirometry, survival, missing data, and causal inference are **[Ch 18–21](chapters/18-longitudinal-mixed-models.md)** in this same volume. Optional deeper material (competing risks, IV, full Bayesian workflows) remains for future expansion; see [BOOK_OUTLINE.md](../BOOK_OUTLINE.md).
