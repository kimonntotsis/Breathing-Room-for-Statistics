# Chapter 4 — Exercises: Comparing Groups

## Conceptual

**E4.1** A researcher compares post-bronchodilator FEV1 in arm A with pre-bronchodilator FEV1 in arm B using a Welch t-test. What is wrong?

**E4.2** State the estimand in plain language and formally for: *"Does triple therapy reduce the proportion with ≥1 severe exacerbation versus ICS alone?"*

**E4.3** When is an odds ratio a poor approximation to a risk ratio?

**E4.4** Explain why testing five secondary lung-function endpoints at α = 0.05 each is problematic.

**E4.5** A paired t-test and Wilcoxon signed-rank test disagree (one p < 0.05, one p > 0.05). What should you report?

---

## Applied (use book data)

**E4.6** Using `data/spirometry.csv`, compare mean FEV1 between `group` levels with Welch t-test. Report mean difference and 95% CI.

**E4.7** Repeat E4.6 with Mann–Whitney. Do conclusions align?

**E4.8** Compute Cohen's d for the comparison in E4.6.

**E4.9** Using `diagnosis` (3 levels), run one-way ANOVA on FEV1. If significant, apply Tukey HSD.

**E4.10** Using `data/exacerbation.csv`, build a 2×2 table of `smoking` vs `exacerbation_12m`. Run Fisher's exact test.

**E4.11** Using `data/bronchodilator_paired.csv`, test whether mean FEV1 change after bronchodilator is greater than zero (paired t-test).

**E4.12** Write a four-sentence results paragraph for E4.6 suitable for a clinical journal (estimate, CI, n, clinical context).

---

## Extension

**E4.13** Simulate 100 datasets where there is truly no FEV1 difference between groups (n = 50 per arm). How often does Welch t give p < 0.05? Relate to Type I error.

**E4.14** Look up an MCID for FEV1 in COPD or asthma. Is the CI from E4.6 compatible with a clinically important effect?

---

[Solutions](../solutions/ch04_solutions.md)
