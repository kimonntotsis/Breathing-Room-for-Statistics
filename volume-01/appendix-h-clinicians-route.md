---
number-sections: false
---

# Appendix H: Investigator path (without R) {.unnumbered}

Endpoint router for **investigators** who review protocols, Methods, and Results but do not run R. Full navigation: [Appendix G](appendix-g-handbook-navigation.md). Welcome tour: [Welcome](index.md).

---

## Before any analysis meeting

Read [Chapter 1](chapters/01-statistical-thinking.md) opening sections (estimands, CASTOR workflow). Write one sentence:

> *The primary estimand is … in … population under … condition.*

If the planned analysis does not estimate that sentence, realign before discussing software. Unfamiliar terms: [Appendix C](appendix-c-glossary.md), plain-language column first.

---

## Match your endpoint to a chapter

Use [Appendix B](appendix-b-quick-reference.md) as a one-page router. Typical respiratory endpoints:

| Your endpoint | Primary chapter | What to read there |
|---------------|-----------------|-------------------|
| Baseline Table 1, missingness | [Ch 3](chapters/03-descriptive-analysis.md) | Who is in the study before comparing arms |
| FEV1 or continuous lung function between arms | [Ch 4](chapters/04-comparing-groups.md) | Welch *t*, ANCOVA, MCID, pairing |
| Exacerbation yes/no | [Ch 4](chapters/04-comparing-groups.md), [Ch 6](chapters/06-generalized-linear-models.md) | Proportions vs logistic regression |
| Exacerbation counts / rates | [Ch 6](chapters/06-generalized-linear-models.md) | Poisson/NB, not a *t*-test |
| Symptom scale (mMRC, CAT) | [Ch 6](chapters/06-generalized-linear-models.md) | Ordinal methods, not linear regression on 0–4 |
| Repeated FEV1 visits | [Ch 18](chapters/18-longitudinal-mixed-models.md) | Not a single week-52 *t*-test |
| Time to first exacerbation | [Ch 19](chapters/19-survival-analysis.md) | Censoring; not "no event = cured" |
| Missing spirometry / dropout | [Ch 20](chapters/20-missing-data.md) | Complete-case is a choice, not a default |
| Observational smoking/therapy comparison | [Ch 21](chapters/21-causal-inference.md) | Association ≠ causation |

In each chapter: **Why this chapter** → **Practice read** / plain language → **Wrong analysis** → **Reporting template**.

**One full narrative:** [Chapter 12, Case A](chapters/12-case-studies.md) (randomised trial, FEV1 at 12 weeks).

**Before sign-off:** [Chapter 8](chapters/08-validation-reporting.md) checklists (CONSORT / STROBE / TRIPOD). Non-inferiority needs a prespecified margin ([Ch 4](chapters/04-comparing-groups.md), [Ch 8](chapters/08-validation-reporting.md)).

---

## What to skip unless relevant

| Block | Chapters |
|-------|----------|
| Omics discovery | 13–17 |
| PCA / clustering | 10–11 |
| Integrated CASTOR-HD | 17 |

---

## Three questions before you sign off

1. **Estimand:** What exact difference or rate are we estimating, and in whom?  
2. **Independence:** Are repeated visits, ICU clusters, or crossover visits handled? ([Ch 4](chapters/04-comparing-groups.md), [Ch 18](chapters/18-longitudinal-mixed-models.md))  
3. **Limits:** What does this analysis **not** prove?
