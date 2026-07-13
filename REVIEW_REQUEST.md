# External review request

**Handbook:** *Breathing Room for Statistics* (v1.0.0 candidate)  
**Author:** Kimon Ntotsis  
**Repository:** https://github.com/kimonntotsis/Breathing-Room-for-Statistics  
**Rubric:** [REVIEWER_RUBRIC.md](volume-01/REVIEWER_RUBRIC.md)

---

## What we are asking

A **targeted read** (not a full line edit) of five chapters that anchor the handbook’s routing, assumptions, and reporting. We want to know whether an investigator or analyst could **choose and defend** the method after reading, and whether the **wrong-analysis panels** and **Practice read** sections catch common mistakes.

Estimated time: **3–5 hours** total if you skim appendices; **6–8 hours** if you run the R examples.

---

## Priority chapters

| Chapter | Why it matters |
|---------|----------------|
| [Ch 4 — Comparing groups](volume-01/chapters/04-comparing-groups.md) | Core routing: continuous vs binary vs count outcomes |
| [Ch 6 — Generalized linear models](volume-01/chapters/06-generalized-linear-models.md) | Logistic/Poisson interpretation and reporting |
| [Ch 13 — Differential analysis & FDR](volume-01/chapters/13-differential-analysis-fdr.md) | High-dimensional omics without a bioinformatics team |
| [Ch 18 — Longitudinal mixed models](volume-01/chapters/18-longitudinal-mixed-models.md) | Repeated measures and estimands |
| [Ch 20 — Missing data](volume-01/chapters/20-missing-data.md) | MCAR/MAR framing and sensitivity |

**Optional context (30 min):** [Preface](volume-01/chapters/00-preface.md), [Appendix B](volume-01/appendix-b-quick-reference.md), [Appendix I](volume-01/appendix-i-figure-hygiene.md).

---

## How to review

1. Open the chapter in GitHub or the [v1.0.0 PDF release](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.0.0).
2. Use the rubric sections: **estimand clarity**, **assumption honesty**, **wrong-analysis usefulness**, **reporting template**, **code reproducibility**.
3. File feedback as:
   - **GitHub issue** (label `review`), or
   - Email to the author with chapter + section references.

Please flag anything that would mislead a **grant reviewer** or **journal statistical reviewer**, not typos alone.

---

## What we will do with feedback

- **Blockers** (wrong estimand, unsafe default): fix before next patch release.
- **Clarifications**: fold into the living handbook; cite release tag in replies.
- **Acknowledgements:** reviewers who agree may be named in a future Preface update (optional).

Thank you for helping keep respiratory statistics humane and defensible.
