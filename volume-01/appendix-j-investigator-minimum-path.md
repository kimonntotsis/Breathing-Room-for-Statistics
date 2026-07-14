---
number-sections: false
---

# Appendix J: Short read (without R) {.unnumbered}

You do **not** need 21 chapters to review a COPD trial analysis plan or a Methods section. This appendix is the **shortest defensible route** for investigators who will not run R.

Full navigation: [Appendix G](appendix-g-handbook-navigation.md). Role-based welcome: [Welcome](chapters/00-welcome.md). Endpoint router: [Appendix H](appendix-h-clinicians-route.md).

---

## Read this in order

| Step | Read | You can sign off on… |
|------|------|---------------------|
| 1 | [Preface](chapters/00-preface.md) (Who / **Why I wrote this** / without bioinformatics) | Why estimands come first |
| 1b | [Appendix K](appendix-k-in-the-room-stories.md): **one** story that matches your week | Why this handbook exists for your situation |
| 2 | [Ch 1: In this chapter](chapters/01-statistical-thinking.md#in-this-chapter) + pipeline figure | One-sentence estimand |
| 3 | [Ch 2: Outcome routing table](chapters/02-respiratory-data.md#outcome-types-the-master-routing-table) | Continuous vs binary vs count vs time-to-event |
| 4 | [Appendix B](appendix-b-quick-reference.md) | Prespecified primary method |
| 5 | [Ch 4: In this chapter](chapters/04-comparing-groups.md#in-this-chapter): especially [unadjusted vs adjusted](chapters/04-comparing-groups.md#unadjusted-adjusted-and-multiple-endpoints) + figure hygiene pairs | Group comparison + slide traps |
| 6 | [Appendix I](appendix-i-figure-hygiene.md) router | Figure 1 matches estimand |
| 7 | [Ch 12 Case A](chapters/12-case-studies.md#case-study-a-randomised-trial-fev1-comparison) + sign-off checklist | Full trial narrative |
| 8 | [Ch 8: Multiplicity + CONSORT](chapters/08-validation-reporting.md#technique-multiplicity-control) | Primary vs secondary families |

**Capstone figure:** `viz_signoff_checklist.png` in [Ch 12](chapters/12-case-studies.md#investigator-sign-off-checklist).

---

## Add only if your study needs it

| If your endpoint is… | Add when needed | Skip until then |
|----------------------|-------------------|-----------------|
| Adjusted FEV1 / covariates | [Ch 5 in this chapter](chapters/05-linear-models.md#in-this-chapter) | Full regression chapters |
| Exacerbation Y/N or counts | [Ch 6 in this chapter](chapters/06-generalized-linear-models.md#in-this-chapter) | Poisson algebra |
| Repeated visits | [Ch 18 in this chapter](chapters/18-longitudinal-mixed-models.md#in-this-chapter) | Mixed-model R lab |
| Time to exacerbation | [Ch 19 in this chapter](chapters/19-survival-analysis.md#in-this-chapter) | Cox algebra |
| Missing spirometry | [Ch 20 in this chapter](chapters/20-missing-data.md#in-this-chapter) + [Appendix D](appendix-d-missing-data-checklists.md) | MICE code |
| Observational therapy comparison | [Ch 21 in this chapter](chapters/21-causal-inference.md#in-this-chapter) | DAG proofs |
| Proteomics / screen | [Ch 13](chapters/13-differential-analysis-fdr.md#working-without-a-bioinformatics-collaborator) → [Ch 17](chapters/17-integrated-castor-hd.md#in-this-chapter) | Elastic net details |

---

## Explicitly skip (unless your analyst asks)

| Block | Chapters | Why skip on first pass |
|-------|----------|------------------------|
| R setup & scripts | Appendix A, all `## R lab` | Investigator reviews estimand, not code |
| Model-building menus | Ch 7 full chapter | Prespecify in SAP; delegate selection |
| PCA / clustering theory | Ch 10–11 full | Omics only; hypothesis-generating |
| Exercise solutions | Appendix F, `solutions/` | Self-study, not protocol review |
| Causal extensions | Ch 21 alternatives | After associational analysis is clear |
| Integrated omics capstone | Ch 17 | After Ch 13–16 chapter openers |

**Discipline rule:** if the Methods section names a test that is not in your estimand sentence, stop and return to [Ch 1](chapters/01-statistical-thinking.md) step 1.

---

## Messy real data reminder

CASTOR is clean on purpose. Before signing off a **real** registry or multi-site study, read [APATE vignette](APATE_VIGNETTE.md) (Greek *Apate*, deceit: fictional mess, no CSV) and ask which rows apply to your cohort.

---

## Where this path leads

- **Analyst handoff:** [Appendix A](appendix-a-r-setup.md) + outcome chapter R lab
- **Teaching / fellowship:** [Welcome: Fellow path](chapters/00-welcome.md) → Ch 1–12 + [Appendix F](appendix-f-exercises.md)
- **Living handbook status:** [HANDBOOK_STATUS](HANDBOOK_STATUS.md)
