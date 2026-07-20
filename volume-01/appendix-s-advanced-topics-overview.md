---
number-sections: false
---

# Appendix S: Meta-analysis, Bayesian methods, and adaptive trials {.unnumbered}

> **Orientation appendix, not a methods manual.** Use this to know **when to escalate** to a statistician or specialist text. Core handbook chapters remain frequentist and applied.

---

## Meta-analysis

### When it matters in respiratory research

Systematic reviews and meta-analyses underpin GOLD/GINA-style guidance, biomarker synthesis, and diagnostic test summaries. Investigators often need to **interpret** meta-analyses even when they do not conduct them.

### Core concepts

| Concept | Plain language |
|---------|----------------|
| **Fixed-effect model** | One true effect across studies; heterogeneity ignored |
| **Random-effects model** | Distribution of true effects across studies; wider CI |
| **Heterogeneity (I², τ²)** | How much studies disagree beyond sampling error |
| **Prediction interval** | Expected effect in a **new** study, not just mean effect |
| **Small-study effects** | Asymmetry in funnel plots; publication bias suspicion |
| **Effect measure** | RR, OR, MD in natural units (mL FEV₁), rate ratios — match clinical question |

### Respiratory examples

- RCTs of triple therapy on FEV₁ → **mean difference** (mL) with random effects
- Exacerbation prevention → **rate ratio** or **OR** depending on study reporting
- Diagnostic accuracy of FeNO → **bivariate** or hierarchical SROC (specialist)

### Common wrong analyses

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Meta-analyse *p*-values | Not combinable | Effect sizes + SEs | Study-level estimates |
| Ignore heterogeneity | Overconfident summary | Random effects + I² | τ², prediction interval |
| Mix incompatible estimands | Apples and oranges | Separate meta-analyses | Inclusion criteria |
| One-outlier-driven conclusion | Fragile summary | Leave-one-out sensitivity | Influence diagnostics |

### Further reading

Cochrane Handbook for Systematic Reviews of Interventions [@higgins2022cochrane]; respiratory reviews should prespecify PROSPERO registration and GRADE certainty.

---

## Bayesian methods (applied overview)

### When it matters

Bayesian approaches appear in:

- **Adaptive trials** (interim decisions using posterior probabilities)
- **Historical borrowing** (paediatric or rare ILD extensions)
- **Diagnostic models** with informative priors on prevalence
- **Omics** hierarchical models ( specialist pipelines)

This handbook is predominantly **frequentist**; Bayesian analysis requires explicit priors, computation (Stan, JAGS, brms), and sensitivity to prior choice.

### Core concepts

| Concept | Plain language |
|---------|----------------|
| **Prior** | What you believe before seeing data (can be weak/vague) |
| **Likelihood** | Same as frequentist model for data |
| **Posterior** | Updated belief after data; **credible interval** (not CI) |
| **Prior sensitivity** | Report how conclusions change with reasonable priors |

### When Bayesian may help

- Small *n* with strong external evidence (historical controls)
- Complex hierarchical structures (multi-centre, repeated measures) where MCMC is natural
- Decision problems with explicit loss functions

### When to stay frequentist

- Standard RCT primary analysis with large *n*
- Regulatory submissions without prespecified Bayesian framework
- Teams without MCMC expertise and audit trail requirements

### Reporting template (if Bayesian analysis is used)

> We fitted a [model] with [prior specification] for [parameters]. Posterior median [effect] was … (95% credible interval …). Prior sensitivity analyses used [alternatives]. Computation used [software] with [diagnostics].

---

## Adaptive and platform trials

### When it matters

Respiratory programmes increasingly use:

- **Group-sequential** interim analyses (futility/efficacy)
- **Sample-size re-estimation** (event-driven COPD exacerbation trials)
- **Platform trials** (multiple therapies in one master protocol)
- **Response-adaptive randomisation** (rare; specialist)

### Core concepts

| Concept | Risk if ignored |
|---------|-----------------|
| **Alpha spending** | Inflated type I error across interims |
| **Estimand under adaptation** | Treatment effect not interpretable post-adaptation |
| **Multiplicity across arms** | False positives in platform comparisons |
| **Blinding of adaptation rules** | Operational bias |

### Plain-language rules

1. **Pre-specify** adaptation rules in the protocol before any interim look.
2. **Separate** confirmatory estimand from exploratory biomarker-adaptive substudies.
3. **Involve trial statisticians** for simulation of operating characteristics.
4. Do not borrow adaptive-trial language for **post hoc** subgroup changes.

### Relationship to this handbook

- Fixed-design CASTOR examples (Ch 4–8) remain the default teaching path.
- Intercurrent events and estimands (Ch 1, ICH E9(R1)) become **critical** under adaptation.
- Sample size (Appendix P) must account for interim looks if confirmatory.

### Further reading

FDA adaptive design guidance; Pallmann et al. on adaptive designs in clinical trials [@pallmann2020adaptive].

---

## Escalation checklist

| If your project includes… | Escalate to… |
|----------------------------|--------------|
| Meta-analysis for guideline | Systematic review methodologist |
| Bayesian primary analysis | Trial statistician + regulatory strategy |
| Platform master protocol | Dedicated adaptive trial team |
| IPD meta-analysis | Specialist consortium |

---

## Related handbook material

| Topic | Location |
|-------|----------|
| Sample size / event-driven trials | [Appendix P](appendix-p-sample-size-planning.md) |
| Estimands and intercurrent events | [Chapter 1](chapters/01-statistical-thinking.md) |
| Multiplicity | [Chapter 8](chapters/08-validation-reporting.md) |
| Diagnostic accuracy | [Appendix Q](appendix-q-diagnostic-accuracy.md) |
