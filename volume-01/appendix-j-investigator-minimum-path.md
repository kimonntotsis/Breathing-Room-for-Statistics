---
number-sections: false
---

# Appendix J: Investigator minimum path (~2 hours) {.unnumbered}

You do **not** need 21 chapters to review a COPD trial analysis plan or a Methods section. This appendix is the **shortest defensible route** for investigators who will not run R.

Full navigation: [Appendix G](appendix-g-handbook-navigation.md). Role-based welcome: [Welcome](chapters/00-welcome.md). Endpoint router: [Appendix H](appendix-h-clinicians-route.md).

---

## Read this (in order, ~90 min)

| Step | Read | Time | You can sign off on… |
|------|------|------|---------------------|
| 1 | [Preface](chapters/00-preface.md) (Who / **Why I wrote this** / without bioinformatics) | 10 min | Why estimands come first |
| 1b | [Appendix K](appendix-k-in-the-room-stories.md) — **one** story that matches your week | 10 min | Why this handbook exists for your situation |
| 2 | [Ch 1: Investigator path](chapters/01-statistical-thinking.md#investigator-path-20-min) + pipeline figure | 20 min | One-sentence estimand |
| 3 | [Ch 2: Outcome routing table](chapters/02-respiratory-data.md#outcome-types-the-master-routing-table) | 15 min | Continuous vs binary vs count vs time-to-event |
| 4 | [Appendix B](appendix-b-quick-reference.md) | 15 min | Prespecified primary method |
| 5 | [Ch 4: Investigator path](chapters/04-comparing-groups.md#investigator-path-20-min) — especially [unadjusted vs adjusted](chapters/04-comparing-groups.md#unadjusted-adjusted-and-multiple-endpoints) + figure hygiene pairs | 20 min | Group comparison + slide traps |
| 6 | [Appendix I](appendix-i-figure-hygiene.md) router | 10 min | Figure 1 matches estimand |
| 7 | [Ch 12 Case A](chapters/12-case-studies.md#case-study-a-randomised-trial-fev1-comparison) + sign-off checklist | 15 min | Full trial narrative |
| 8 | [Ch 8: Multiplicity + CONSORT](chapters/08-validation-reporting.md#technique-multiplicity-control) | 10 min | Primary vs secondary families |

**Capstone figure:** `viz_signoff_checklist.png` in [Ch 12](chapters/12-case-studies.md#investigator-sign-off-checklist).

---

## Add only if your study needs it

| If your endpoint is… | Add (≈20 min each) | Skip until then |
|----------------------|-------------------|-----------------|
| Adjusted FEV1 / covariates | [Ch 5 investigator path](chapters/05-linear-models.md#investigator-path-20-min) | Full regression chapters |
| Exacerbation Y/N or counts | [Ch 6 investigator path](chapters/06-generalized-linear-models.md#investigator-path-20-min) | Poisson algebra |
| Repeated visits | [Ch 18 investigator path](chapters/18-longitudinal-mixed-models.md#investigator-path-20-min) | Mixed-model R lab |
| Time to exacerbation | [Ch 19 investigator path](chapters/19-survival-analysis.md#investigator-path-20-min) | Cox algebra |
| Missing spirometry | [Ch 20 investigator path](chapters/20-missing-data.md#investigator-path-20-min) + [Appendix D](appendix-d-missing-data-checklists.md) | MICE code |
| Observational therapy comparison | [Ch 21 investigator path](chapters/21-causal-inference.md#investigator-path-20-min) | DAG proofs |
| Proteomics / screen | [Ch 13](chapters/13-differential-analysis-fdr.md#working-without-a-bioinformatics-collaborator) → [Ch 17](chapters/17-integrated-castor-hd.md#investigator-path-20-min) | Elastic net details |

---

## Explicitly skip (unless your analyst asks)

| Block | Chapters | Why skip on first pass |
|-------|----------|------------------------|
| R setup & scripts | Appendix A, all `## R lab` | Investigator reviews estimand, not code |
| Model-building menus | Ch 7 full chapter | Prespecify in SAP; delegate selection |
| PCA / clustering theory | Ch 10–11 full | Omics only; hypothesis-generating |
| Exercise solutions | Appendix F, `solutions/` | Self-study, not protocol review |
| Causal extensions | Ch 21 alternatives | After associational analysis is clear |
| Integrated omics capstone | Ch 17 | After Ch 13–16 investigator paths |

**Discipline rule:** if the Methods section names a test that is not in your estimand sentence, stop and return to [Ch 1](chapters/01-statistical-thinking.md) step 1.

---

## Messy real data reminder

CASTOR is clean on purpose. Before signing off a **real** registry or multi-site study, read [APATE vignette](APATE_VIGNETTE.md) (Greek *Apate*, deceit — fictional mess, no CSV) and ask which rows apply to your cohort.

---

## Where this path leads

- **Analyst handoff:** [Appendix A](appendix-a-r-setup.md) + outcome chapter R lab  
- **Teaching / fellowship:** [Welcome: Fellow path](chapters/00-welcome.md) → Ch 1–12 + [Appendix F](appendix-f-exercises.md)
- **Living handbook status:** [HANDBOOK_STATUS](HANDBOOK_STATUS.md)
