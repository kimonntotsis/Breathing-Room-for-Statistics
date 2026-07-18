# Part VIII: Longitudinal, survival, and causal inference {.unnumbered}

These chapters complete the single-volume handbook: data structures that break independence assumptions in Ch 4–7, plus principled handling of missing data and confounding.

**Read this if:** patients contribute **multiple visits**, follow-up ends at **censoring**, **dropout** is common, or you are tempted to use causal language in observational COPD cohorts.

**Skip this if:** your analysis is a single cross-sectional comparison with complete data (→ [Part II](part-02-describe-compare.md)). Read **Ch 20** if missingness exceeds ~5%.

## In the room: the extension analysis plan

The same trial now has four visits per patient and a separate cohort with time to first exacerbation. The first draft proposes a week-52 *t*-test and a logistic “any exacerbation” model. **Part VIII** keeps trajectories (Ch 18), timing and censoring (Ch 19), missing visits (Ch 20), causal language (Ch 21), and mechanism questions through FEV1 % (Ch 22) aligned with what the protocol can support.

> **Consult a statistician when:** your SAP includes random slopes, competing risks, MNAR sensitivity, IPW with extreme weights, or mediation claims for regulatory or policy decisions. These chapters teach **routing and limits**; not a substitute for pivotal-trial statistical leadership.
