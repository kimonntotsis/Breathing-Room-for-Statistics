# Part VIII: Longitudinal, survival, and causal inference {.unnumbered}

These chapters complete the single-volume handbook: data structures that break independence assumptions in Ch 4–7, plus principled handling of missing data and confounding.

**Read this if:** patients contribute **multiple visits**, follow-up ends at **censoring**, **dropout** is common, or you are tempted to use causal language in observational COPD cohorts.

**Skip this if:** your analysis is a single cross-sectional comparison with complete data (→ [Part II](part-02-describe-compare.md)). Read **Ch 20** if missingness exceeds ~5%.

## In the room: the extension analysis plan

The same trial now has four visits per patient and a separate cohort with time to first exacerbation. The first draft proposes a week-52 *t*-test and a logistic “any exacerbation” model. **Part VIII** keeps trajectories (Ch 18), timing and censoring (Ch 19), missing visits (Ch 20), causal language (Ch 21), and mechanism questions through FEV1 % (Ch 22) aligned with what the protocol can support.

> **Consult a statistician when:** your SAP includes random slopes, competing risks, MNAR sensitivity, IPW with extreme weights, or mediation claims for regulatory or policy decisions. These chapters teach **routing and limits**; not a substitute for pivotal-trial statistical leadership.

## Bridge from Part VI (omics)

High-dimensional discovery (Parts V–VI) treats each feature as a hypothesis. **Part VIII** returns to **patient-level** correlation structures: repeated FEV₁ visits break independence (Ch 18), time-to-event censoring breaks complete-data logic (Ch 19), missing visits may be informative (Ch 20), and observational registries invite causal language you may not be able to support (Ch 21–22).

## Bridge from missing data to causal inference (Ch 20 → 21)

Missing-data methods estimate quantities under **missingness assumptions**. Causal methods estimate **intervention contrasts** under **exchangeability assumptions**. They overlap when dropout is informative, but imputing a mediator does not replace a target-trial design.

## Bridge from IPW to mediation (Ch 21 → 22)

IPW and regression adjustment target **total or direct associations** of exposure on outcome. Mediation asks how much of an association is **consistent with a measured pathway**. Adjusting a mediator to estimate a direct effect is not the same workflow as IPW for confounding—prespecify the estimand before opening either chapter.
