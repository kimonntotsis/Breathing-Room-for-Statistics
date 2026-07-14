# Instructor pack: Breathing Room for Statistics

Materials for course leads and self-study coordinators.

| Resource | Location |
|----------|----------|
| **Exercises (PDF)** | [appendix-f-exercises.md](appendix-f-exercises.md) |
| **Solutions (web/repo)** | [solutions/](solutions/), not in PDF to preserve problem-solving |
| **Reviewer rubric** | [REVIEWER_RUBRIC.md](REVIEWER_RUBRIC.md) |
| **CASTOR data** | `source("R/generate_data.R")` from repo root |
| **All chapter scripts** | `source("R/run_all_examples.R")` |

## Suggested course paths

| Weeks | Content | Labs |
|-------|---------|------|
| 1–2 | Ch 1–3, Appendix B | `ch03_descriptive.R` |
| 3–4 | Ch 4–5 | `ch04_comparing_groups.R`, `ch05_linear_models.R` |
| 5 | Ch 6–7 | `ch06_glm.R`, `ch07_model_building.R` |
| 6 | Ch 8–9 | `ch09_prediction.R` |
| 7–8 | Ch 10–12 capstone | `ch12_case_*.R` |
| Optional block | Ch 13–17 omics | `ch13_*`, `ch14_*`, `ch17_*` + **Appendix L** analyst scripts |
| Optional block | Ch 18–22 | `ch18_*`, `ch19_*`, `ch20_*`, `ch21_*`, `ch22_mediation.R` |

## Assessment ideas

- **Conceptual:** exercises E*.1–E*.5 per chapter (Appendix F).
- **Applied:** run one CASTOR script and write a four-sentence Results paragraph using the chapter reporting template.
- **Critical:** identify one "Wrong analysis" from the chapter that matches a flawed abstract.

## Formal review before teaching

Complete [REVIEWER_RUBRIC.md](REVIEWER_RUBRIC.md) for Chapters **4, 6, 13, 18, 20** with an investigator and an analyst. Those chapters include **Clinical and biostatistics notes** summarising the main checks.

## Package note for Chapter 20

Full multiple imputation demo requires:

```r
install.packages("mice")
source("R/examples/ch20_missing_data.R")
```

Generates `ch20_mice_density.png` and adds MICE pooled coefficients to `volume-01/tables/ch20_smoking_coef_sensitivity.csv`.

## Package note for Chapter 22

Bootstrap natural effects require:

```r
install.packages("mediation")
source("R/examples/ch22_mediation.R")
```

Generates `ch22_mediation_path.png`, `ch22_mediation_effects.png`, `ch22_total_vs_direct_or.png`, and tables under `volume-01/tables/ch22_*.csv`.
