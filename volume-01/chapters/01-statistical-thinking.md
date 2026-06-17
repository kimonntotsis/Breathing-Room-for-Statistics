# Chapter 1: Statistical Thinking in Respiratory Research

> **Part I: Foundations**

## At a glance

| | |
|---|---|
| **Focus** | How to think before analysing |
| **Key ideas** | Estimands, design, bias, inference vs prediction |
| **Tools** | PICO, method map, reporting frameworks |
| **Navigation** | [HANDBOOK_GUIDE](../HANDBOOK_GUIDE.md) · [QUICK_REFERENCE](../QUICK_REFERENCE.md) · [METHOD_MAP](../METHOD_MAP.md) · [Decision tree](../figures/method_decision_tree.png) · [REFERENCES](../REFERENCES.md) |
| **Exercises** | [ch01](../exercises/ch01_exercises.md) · [Solutions](../solutions/ch01_solutions.md) |

## Learning objectives

1. Separate clinical, statistical, and data layers of an analysis.
2. Define an **estimand** in plain language and formal terms.
3. Classify respiratory study designs and what each can support.
4. Distinguish **inference** from **prediction** [@shmueli2010predict].
5. Navigate the handbook method map and quick reference.

## Prerequisites

None - start here.

---

## Opening question

A pulmonologist asks: *"Is FEV1 lower in smokers?"*

Before opening R, you need three answers:

1. **Clinical:** What decision changes if we know the answer?  
2. **Statistical:** What exact quantity are we estimating (estimand)?  
3. **Data:** Cross-sectional snapshot or longitudinal trial? Which confounders?

This chapter teaches that order. Methods come in [Chapter 4](04-comparing-groups.md) onward; **thinking** comes first [@harrell2015rms].

> **Handbook rule:** Open [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) only **after** you can write the estimand in one sentence.

---

## Three layers of every analysis

### Technique card

| | |
|---|---|
| **Answers** | Are clinical question, statistical estimand, and data structure aligned? |
| **Clinical layer** | What would change practice or knowledge? |
| **Statistical layer** | What parameter or contrast is estimated? |
| **Data layer** | What was measured, in whom, when, with what missingness? |
| **When to use** | At the start of every project - before software |
| **When NOT to use** | Never skip - even for "simple" t-tests |
| **Does NOT prove** | That a method is correct - only that the question is clear |

### Dual interpretation

**Plain language:** make sure you are answering the question the clinician actually asked.

**Precise language:** the estimand must be well-defined relative to the target population, intervention/exposure, and outcome measure [@celli2015copdresearch].

**Clinician read:** if the statistician analyses post-bronchodilator FEV1 but the trial protocol specifies pre-bronchodilator, the answer may not apply to your decision.

| Layer | Question | Example error |
|-------|----------|---------------|
| Clinical | What decision or knowledge? | Using the wrong endpoint (symptom score when regulatory approval needs exacerbations) |
| Statistical | What estimand/hypothesis? | Testing mean FEV1 when the protocol specifies risk difference |
| Data | What was measured, in whom? | Ignoring missing spirometry or mixed BD protocols |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Open software first; pick "Compare Means" from a menu |
| **Why it fails** | Method follows question, not the reverse |
| **Do instead** | Write estimand → check [QUICK_REFERENCE](../QUICK_REFERENCE.md) → then code |

---

## PICO for respiratory studies

### Technique card

| Element | Question | COPD example |
|---------|----------|--------------|
| **P** Population | Who? | Moderate-severe COPD, GOLD II-III, adults ≥40 |
| **I** Intervention/Exposure | What treatment or factor? | Triple therapy vs dual bronchodilator |
| **C** Comparator | Compared to what? | Standard care, placebo, active control |
| **O** Outcome | What endpoint? | FEV1 at 12 weeks; ≥1 moderate/severe exacerbation in 12 months |

Write PICO **before** choosing software. PICO does not specify the test - it specifies the **target** [@celli2015copdresearch].

### Reporting template

**Methods (study question):**

> We asked whether [intervention] improves [outcome] compared with [comparator] in [population] over [timeframe]. The primary estimand was [one sentence].

---

## Estimands: the target of inference

### Technique card

| | |
|---|---|
| **Definition** | The precise numerical summary the analysis should estimate for a defined population |
| **Examples** | Mean FEV1 difference at 12 weeks (RCT); adjusted odds of exacerbation (cohort); rate ratio per person-year |
| **Report with** | Point estimate, 95% CI, population, timeframe |
| **Does NOT mean** | The p-value; the test statistic; "significance" |

### Worked examples (respiratory)

| Study | Estimand |
|-------|----------|
| COPD RCT | Mean difference in FEV₁ (L) at 12 weeks: intervention − control, ITT population |
| Observational cohort | Adjusted odds ratio for ≥1 exacerbation comparing current smokers to never-smokers, conditional on age and FEV₁ % predicted |
| Bronchodilator test | Mean change in FEV₁ (post − pre) on same visit |
| Prediction model (Ch 9) | 12-month exacerbation risk for a patient with specified covariates - **not** the same as an OR estimand |

### Dual interpretation

**Plain language:** the estimand is the number you would put in the abstract if you could know the truth.

**Precise language:** under the ICH E9(R1) framework, estimands link treatment, population, variable, and intercurrent events - this handbook uses the plain-language version; trials should follow protocol definitions [@schulz2010consort].

**Clinician read:** ask your analyst "what one number answers my question?" If they cannot say, pause.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Report p = 0.06 with no effect size |
| **Do instead** | Report estimand + CI; see [Ch 8](08-validation-reporting.md) |

---

## Study designs: what each can support

| Design | Strength | Limit for causal claims | Vol I methods |
|--------|----------|-------------------------|---------------|
| **RCT** | Randomisation balances confounders | ITT vs per-protocol; non-adherence | Ch 4-8 |
| **Cohort** | Temporal order; incidence | Residual confounding | Ch 5-6 (associations) |
| **Case-control** | Efficient for rare outcomes | OR not RR; selection bias | Ch 6 logistic |
| **Cross-sectional** | Prevalence, description | No temporal order for causation | Ch 3-5 |
| **Clustered** | Real-world multi-centre | Wrong SEs if ignored | Vol II |

Design **limits language**. An adjusted logistic OR from an observational cohort is an **association**, not proof that stopping smoking **causes** fewer exacerbations [@vonelm2007strobe].

Full data-structure detail: [Chapter 2](02-respiratory-data.md).

---

## Type I error, Type II error, and power

| Term | Plain language | Typical setting |
|------|----------------|-----------------|
| **Type I error (α)** | False alarm - declare effect when none | Often α = 0.05 for confirmatory tests |
| **Type II error (β)** | Miss a real effect | Depends on sample size and effect size |
| **Power** | 1 − β; chance to detect effect if true | Target 80-90% at design stage |

Underpowered exacerbation studies produce **wide CIs** compatible with both null and clinically important effects [@harrell2015rms]. A non-significant p-value does **not** prove "no effect" - see [Ch 8 §8.7](08-validation-reporting.md).

### Clinician "so what?"

If a trial has 60 patients and a soft endpoint, a "negative" result may mean **inconclusive**, not **futile**.

---

## Bias: threats to valid inference

| Bias | Respiratory example | Mitigation |
|------|---------------------|------------|
| **Confounding** | Smoking distorts therapy-FEV₁ association | Adjust measured confounders; design (RCT) |
| **Selection** | Sicker patients drop out of follow-up spirometry | Report attrition; sensitivity analyses |
| **Information** | Misclassified exacerbations (patient recall) | Standardised definitions [@hurst2010exacerbation] |
| **Lead-time** | Screening detects mild disease earlier | Survival artefacts - Vol II |
| **Measurement** | Mixed pre/post bronchodilator FEV₁ | Protocol standardisation [@graham2019spirometry] |

### Wrong analysis ⚠

Claim causation from observational adjustment alone → use associational language; cite design limits [@vonelm2007strobe].

---

## Inference vs prediction

| | Inference / explanation | Prediction |
|---|-------------------------|------------|
| **Goal** | Estimate adjusted associations; test hypotheses | Rank or classify new patients |
| **CASTOR example** | Smoking OR for exacerbation (Ch 6) | Exacerbation risk score (Ch 9) |
| **Evaluation** | CI, LRT, prespecified estimand | Calibration, AUC, external validation [@moons2015tripod] |
| **Variable selection** | Prespecified confounders (Ch 7) | CV, LASSO - different rules |

Do not evaluate an explanatory model **only** by AUC [@shmueli2010predict]. Do not treat a high-AUC predictor as proof of causation.

Full treatment: [Chapter 9](09-prediction-vs-inference.md).

---

## Reporting frameworks (overview)

| Guideline | Design | Key reference |
|-----------|--------|---------------|
| **CONSORT** | RCT | [@schulz2010consort] |
| **STROBE** | Observational cohorts, case-control | [@vonelm2007strobe] |
| **TRIPOD** | Prediction model development/validation | [@moons2015tripod] |
| **RECORD** | Routinely collected health data | [@benchimol2015record] |

Checklists improve **transparency**; they do not replace correct analysis [@harrell2015rms]. Details: [Chapter 8](08-validation-reporting.md).

---

## Navigating the method map

This handbook provides three linked tools:

| Tool | Use when |
|------|----------|
| [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) | You know outcome type; need test/model now |
| [METHOD_MAP.md](../METHOD_MAP.md) | Full inventory and decision tree text |
| [figures/method_decision_tree.png](../figures/method_decision_tree.png) | Visual flowchart for teaching or slides |

**Workflow:** estimand → outcome type (Ch 2) → QUICK_REFERENCE → chapter technique card → R script.

---

## Catalog of wrong analyses (thinking chapter)

| Wrong | Right |
|-------|-------|
| Menu-driven statistics | Estimand-first workflow |
| p-value without CI | Estimate + CI + n [@harrell2015rms] |
| "Trend" without prespecified trend test | Pre-specify or label exploratory |
| Causal language from cohort OR | Associational language + limitations |
| Evaluate explanatory model by AUC only | Match metrics to goal [@shmueli2010predict] |
| Skip protocol definitions for exacerbation | Cite definition [@hurst2010exacerbation] |

---

## Alternatives & extensions (how to strengthen the thinking layer)

These are not “more statistics.” They are ways to make the same methods more defensible.

| Need | Add | Where |
|---|---|---|
| Formal causal language | DAGs + identification assumptions | [Ch 21](21-causal-inference.md) |
| Trial estimand precision | ICH E9(R1) estimand framework | Trial protocol work |
| Clinical decision framing | Decision thresholds / net benefit | Ch 9 extensions |
| Reporting discipline | Protocol + checklist alignment | Ch 8 |

**Rule:** choose the smallest extension that solves the real problem (confounding, clustering, time-to-event), rather than adding complexity for its own sake.

---

## R lab: first look at CASTOR

```r
source("R/00_setup.R")
source("R/generate_data.R")
library(tidyverse)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)

# Describe before infer
spirometry %>%
  group_by(group) %>%
  summarise(n = n(), mean_fev1 = mean(fev1), sd_fev1 = sd(fev1), .groups = "drop")

# Estimand: mean FEV1 difference by group - method justified in Ch 4
t.test(fev1 ~ group, data = spirometry, var.equal = FALSE)
```

Always **describe** ([Ch 3](03-descriptive-analysis.md)) before **compare** ([Ch 4](04-comparing-groups.md)).

---

## Chapter summary

- Align clinical, statistical, and data layers before any test.
- Write the **estimand** in one sentence; use PICO to frame the question.
- Design limits causal language; reporting guidelines limit hidden flexibility.
- Use [QUICK_REFERENCE](../QUICK_REFERENCE.md) after the estimand is clear - not before.

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]  
- Shmueli, "To explain or to predict?" [@shmueli2010predict]  
- ATS/ERS COPD research statement [@celli2015copdresearch]

## Exercises · [Solutions](../solutions/ch01_solutions.md)

**Next:** [Chapter 2 - Data in Respiratory Research](02-respiratory-data.md)
