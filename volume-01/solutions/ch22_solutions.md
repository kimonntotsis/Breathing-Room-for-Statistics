# Chapter 22 Solutions

**E22.1** Total effect includes all paths from smoking to exacerbation (with and without FEV1 %). Direct effect is the smoking effect **not through** measured FEV1 % (mediator adjusted in the outcome model).

**E22.2** They confound exposure–mediator, exposure–outcome, and mediator–outcome relations. Omitting them from either model can bias path coefficients and natural effects.

**E22.3** ACME is the natural **indirect** effect: the portion of the smoking–exacerbation association consistent with the path through FEV1 % predicted. With a logistic outcome, `mediate()` reports ACME on the **probability scale** (average difference in predicted P(exacerbation)), not log-odds.

**E22.4** Proportion mediated divides indirect by total; when total is near zero, small numerator changes produce huge unstable ratios (wide bootstrap intervals in `ch22_mediation_effects.csv`).

**E22.5** FEV1 % and 12-month exacerbation are observed in one snapshot; temporal order and unmeasured severity/inflammation limit causal claims.

**Applied** Total OR ≈ 2.11 vs direct OR ≈ 1.33; ACME ≈ 0.018 (bootstrap CI 0.001 to 0.044); mediator-model smoking coefficient ≈ −8.5 FEV1 % points for smokers vs non-smokers (adjusted). Sample Results sentence: see [Chapter 22 reporting template](chapters/22-mediation-analysis.md#reporting-template).
