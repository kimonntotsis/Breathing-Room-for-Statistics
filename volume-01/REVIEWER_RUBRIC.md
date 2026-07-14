# Reviewer rubric: Breathing Room for Statistics

Use this form for a **one-pass** clinical or biostatistical review of a single chapter. Priority chapters: **4, 6, 13, 18, 20** (highest traffic for inference, GLMs, omics, longitudinal, missing data).

**Reviewer:** ___________________
**Role:** [ ] Investigator [ ] Analyst [ ] Omics analyst
**Chapter:** ___________________
**Date:** ___________________

---

## 1. Clinical relevance (1–5)

| Score | Meaning |
|------:|---------|
| 1 | Examples feel generic; wrong estimands for respiratory practice |
| 3 | Mostly correct; a few protocol/spirometry gaps |
| 5 | Estimands, endpoints, and caveats match real trials/cohorts |

**Comments (estimands, MCID, BD timing, exacerbation definitions, omics claims):**

---

## 2. Statistical correctness (1–5)

| Score | Meaning |
|------:|---------|
| 1 | Wrong default method or misleading interpretation |
| 3 | Sound defaults; advanced corners flagged honestly |
| 5 | Would sign off as departmental teaching material |

**Comments (assumptions, multiplicity, missing data, batch, clustering):**

---

## 3. Plain vs precise language (1–5)

Is the **practice read** accurate? Is the **precise language** fair (not overclaiming causation)?

**Comments:**

---

## 4. Wrong-analysis panels

List any **common mistake missing** from the chapter:

---

## 5. Reporting templates

Could a reader **copy Methods/Results** with minimal edits? What is missing?

---

## 6. R and reproducibility

Did you run `source("R/examples/chXX_*.R")`? Any path, package, or teaching-data issues?

---

## 7. Overall recommendation

[ ] Approve for teaching use
[ ] Approve with minor edits (list below)
[ ] Major revision needed

**Required edits:**

1.
2.
3.

---

## Chapter-specific prompts

### Chapter 4: Comparing groups

- Is Welch *t* the right default for parallel-group FEV1?
- Are pre/post bronchodilator pairing errors covered?
- Is multiplicity on secondary lung-function endpoints mentioned?
- Is route to Ch 6 clear for count/binary outcomes?

### Chapter 6: GLMs

- OR vs RR when exacerbations are common?
- Poisson vs NB and person-time offset?
- EPV / sparse events / Firth?
- Observational smoking language?

### Chapter 13: DE + FDR

- Is BH FDR explained for budget holders?
- Batch-before-biology emphasised?
- LOD vs NA distinguished?
- Global RNA shift in CASTOR-HD flagged as teaching artefact?

### Chapter 18: Mixed models

- Week-52 *t*-test vs slope estimand?
- Random intercept as minimum?
- Interaction = differential decline?
- Dropout / MAR pointer to Ch 20?

### Chapter 20: Missing data

- Structural missingness (sputum subgroup)?
- Complete-case vs MI sensitivity?
- MICE as production default when MAR plausible?
- Leakage in prediction (Ch 9)?

---

## Consolidated review log (editors)

| Ch | Clinical reviewer | Date | Biostat reviewer | Date | Status |
|----|-------------------|------|------------------|------|--------|
| 4 | | | | | Internal pass v1 |
| 6 | | | | | Internal pass v1 |
| 13 | | | | | Internal pass v1 |
| 18 | | | | | Internal pass v1 |
| 20 | | | | | Internal pass v1 |

*Record named reviewers and dates when sign-off is complete.*
