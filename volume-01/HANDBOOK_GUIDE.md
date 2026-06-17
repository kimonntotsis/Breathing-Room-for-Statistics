# Handbook guide — how to use this book

This volume is designed as a **working handbook**: choose a method, check assumptions, run R, report correctly. You do not need to read cover-to-cover.

---

## Start here (by role)

| If you are… | Start with | Then |
|-------------|------------|------|
| **Clinician / trialist** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) → outcome row | Technique card + Reporting template in that chapter |
| **Analyst new to respiratory data** | [Ch 2](chapters/02-respiratory-data.md) → [Ch 3](chapters/03-descriptive-analysis.md) | [METHOD_MAP.md](METHOD_MAP.md) |
| **Statistician** | [METHOD_MAP.md](METHOD_MAP.md) + [Ch 1 estimands](chapters/01-statistical-thinking.md) | Ch 4–6 technique cards; Ch 8 validation |
| **Teaching a course** | [index.md](index.md) reading order | [exercises/](exercises/) + CASTOR scripts |
| **Writing a paper** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Reporting template in chapter + [Ch 8](chapters/08-validation-reporting.md) checklists |

---

## The five navigation tools

| Tool | Purpose | When to open |
|------|---------|--------------|
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | One-page tables: outcome → test → model | **Before any analysis** |
| **[METHOD_MAP.md](METHOD_MAP.md)** | Full decision tree + technique inventory | Choosing among similar methods |
| **[FIGURE_INDEX.md](FIGURE_INDEX.md)** | All plots and decision figures | Writing / teaching / slides |
| **[GLOSSARY.md](GLOSSARY.md)** | Terms in plain and precise language | Unfamiliar jargon |
| **[REFERENCES.md](REFERENCES.md)** | Curated bibliography by topic | Methods sentences, background reading |

---

## Standard workflow (every analysis)

```
1. Clinical question (one sentence)          → Ch 1
2. Outcome type + design                     → Ch 2, QUICK_REFERENCE
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
3. Dual interpretation (plain / precise / clinician)  
4. Caveats box  
5. Wrong analysis ⚠  
6. Reporting template  
7. R lab + sensitivity  

---

## R setup (once per session)

```r
setwd("/path/to/respiratory-research-methods")  # your clone path
source("R/00_setup.R")
source("R/generate_data.R")
source("R/examples/generate_figures.R")       # all handbook figures
source("R/run_all_examples.R")                # optional: full chapter scripts
```

---

## CASTOR recurring cohort

One synthetic cohort threads Ch 3→12; **CASTOR-HD** extends through Ch 13–17. See [RECURRING_COHORT.md](RECURRING_COHORT.md).

---

| **VII Integrated capstone** | 17 | End-to-end CASTOR-HD + elastic net |
| **VIII Longitudinal & causal** | 18–21 | Repeated measures, survival, missing data, causality |

---

## Extended topics

Longitudinal spirometry, survival, missing data, and causal inference are **[Ch 18–21](chapters/18-longitudinal-mixed-models.md)** in this same volume. Optional deeper material (competing risks, IV, full Bayesian workflows) remains for future expansion — see [BOOK_OUTLINE.md](../BOOK_OUTLINE.md).
