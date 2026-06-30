# Chapter 18 Solutions

**E18.1** Visits from the same patient are correlated; treating them as independent inflates precision.

**E18.2** Each patient has their own baseline FEV1 level (random intercept) around which visits vary.

**E18.3** It ignores correlated visits and baseline trajectory information; SEs may be too small if visits are stacked as independent rows.

**E18.4** Positive interaction means intervention is associated with a **less negative** (or more positive) slope than standard care, i.e. slower decline or greater improvement per week.

**E18.5** GEE targets the **population-averaged** (marginal) effect; mixed models with random effects are typically **conditional** (subject-specific).

**Applied** In the teaching run, `weeks:groupintervention` ≈ +0.00054 L/week. Cross-sectional week-52 and mixed-model level estimates are similar in magnitude; if cross-sectional SE were much smaller with 640 rows, that would signal pseudo-replication.
