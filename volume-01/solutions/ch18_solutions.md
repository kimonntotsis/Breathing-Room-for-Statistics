# Chapter 18 Solutions

**E18.1** Visits from the same patient are correlated; treating them as independent inflates precision.

**E18.2** Each patient has their own baseline FEV1 level (random intercept) around which visits vary.

**E18.3** It ignores correlated visits and baseline trajectory information; SEs may be too small if visits are stacked as independent rows.

**E18.4** Positive interaction means intervention is associated with a **less negative** (or more positive) slope than standard care, i.e. slower decline or greater improvement per week.

**E18.5** GEE targets the **population-averaged** (marginal) effect; mixed models with random effects are typically **conditional** (subject-specific).

**Applied** In the teaching run, `weeks:groupintervention` ≈ +0.00035 L/week. Week-52 contrast from the mixed model ≈ **+0.040 L** (`lmer_week52_contrast` in `ch18_sensitivity_mixed_vs_fixed.csv`), similar to the week-52-only `lm` (~0.047 L). Pseudo-replication arises when **all visits are stacked** in ordinary `lm()`, not from a single-visit model alone.
