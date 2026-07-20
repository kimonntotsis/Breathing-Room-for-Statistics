---
number-sections: false
---

# Preface {.unnumbered}

Respiratory research rests on incompatible data shapes in the same programme: spirometry and symptom scores, exacerbation counts, imaging, biomarker panels, trial endpoints, ICU trajectories, and omics tables with more variables than patients. Textbooks and courses teach methods in isolation. Manuscripts still fail for recurring reasons: the wrong estimand, the wrong outcome family, missingness handled as an afterthought, discovery claims without multiplicity or batch discipline, prediction metrics without calibration. This handbook connects question, method, reporting, and reproducible R on one synthetic cohort so each step is visible in code you can rerun.

## Who this book is for

**Investigators** and **analysts** who need to match a research question to a defensible analysis: especially **early- and mid-career** respiratory researchers, and **senior clinicians** who want statistics and coding to feel **purposeful**, not like a second degree in mathematics or computer science.

You do not need to derive every estimator or write production-grade software. You **do** need to know: what question the method answers, when it fits your data, what to check, what to report, what alternatives exist, and what the result does **not** prove. Investigators can use opening scenes, worked examples, and reporting templates without running R; analysts follow the same workflow with reproducible R on CASTOR.

**CASTOR** is a **COPD-flavoured** synthetic teaching cohort (spirometry, exacerbations, smoking, therapy) so examples stay comparable from Table 1 through survival and omics; the workflow applies across **chronic lung disease (CLD)** and other respiratory settings when the **outcome type and design** match, including asthma trials and mixed pulmonary programmes.

## Why I wrote this

I wrote this handbook because respiratory programmes now stack incompatible data in one grant: spirometry and symptom scores beside proteomics panels with more proteins than patients. Training still often starts with software (“run a t-test”) instead of the estimand. Manuscripts fail for the same preventable reasons: wrong outcome family, missingness as an afterthought, discovery slides beside confirmatory endpoints, prediction metrics without calibration.

I have sat in meetings where a clean volcano plot arrived before anyone wrote the primary estimand, and where a cohort with eight ICU wards was analysed as 400 independent patients. Those are not rare failures of intelligence; they are **gaps in routing**: knowing which technique matches which aim, and what to say when you do not have a bioinformatics group on speed dial.

This book is a **first starting point**: question-first, limits-last, reproducible where it helps understanding. It will not replace a statistician for your pivotal trial, and it will not turn you into a bioinformatician overnight. It should stop you from signing off analyses that are numerically runnable but scientifically beside the point.

**Feasible fiction:** Appendix K: six invented situations (mixed columns + wrong tests, random forest without a goal, `lm()` on 0/1, training-set AUC, omics merged with FEV1, prediction quoted as causation) grounded in patterns respiratory journals and methods reviews see repeatedly.

## What you can learn here (without the deep math)

| You want to… | This book helps you… | It does not require… |
|--------------|----------------------|----------------------|
| Pick a method for your endpoint | Route by outcome + design (Appendix B) | Proving asymptotic theory |
| Adjust for baseline or confounders | Prespecify covariates; read adjusted CIs (Ch 4–6) | Mastering every GLM extension |
| Report for CONSORT/STROBE | Templates + intervals, not “NS” (Ch 8) | Journal politics |
| Handle a proteomics file someone emailed you | FDR, batch, honest discovery language (Ch 13–17) | Building a genomics pipeline from scratch |
| Run teaching R scripts | Reproduce CASTOR examples (Appendix A) | Becoming a software engineer |
| Say what was **not** proven | Case studies + APATE skepticism (Ch 12, APATE vignette) | |

**R** is a **proof of understanding**, not the job description. Read the argument first; run code when it clarifies.

## Without a dedicated bioinformatics collaborator

Many pulmonary labs now receive high-dimensional tables: Olink exports, RNA count matrices, flow summaries: without embedded bioinformatics support. That is normal, and it is where misuse is most common:

- **Volume intimidation:** 1,000 columns feel “more scientific” than FEV1; the estimand did not change.
- **Tool mismatch:** PCA or k-means run on raw exports with batch columns ignored (Ch 10–11).
- **p-value fishing:** nominally significant features without FDR or effect sizes (Ch 13).
- **Confirmatory dressing:** volcano figures beside week-12 FEV1 in one Results section (Ch 12 Case D).
- **Outsourced black boxes:** a vendor PDF with no batch table, no *n*, no missingness rule.

**What you can do without a bioinformatics team:** classify the data type, ask for batch and plate metadata, prespecify discovery vs clinical endpoints, demand effect size + q-value + sensitivity, and use [Part VI](parts/part-06-highdim-biology.md) as a **review checklist** before funding validation. When analysis must be outsourced, this handbook gives you vocabulary to **review** deliverables, not just admire heatmaps.

**When to escalate:** sample swap suspicion, single-cell pipelines, bespoke imputation at scale, or a registrational trial SAP: bring a statistician or bioinformatician; use this book to make that collaboration efficient.

## Cite this book {#cite-this-book}

**APA (7th ed.)**

> Ntotsis, K. (2026). *Breathing room for statistics: A statistical handbook for respiratory research: from trials to omics and prediction* [Open handbook]. *With reproducible R examples.* Retrieved June 28, 2026, from https://github.com/kimonntotsis/Breathing-Room-for-Statistics

**Source (chapters, appendices, R code, data):** [github.com/kimonntotsis/Breathing-Room-for-Statistics](https://github.com/kimonntotsis/Breathing-Room-for-Statistics)

**In-text:** (Ntotsis, 2026)

For a fixed edition, cite a tagged release URL rather than the default branch. Edition and living-document notes: [HANDBOOK_STATUS](../HANDBOOK_STATUS.md).

## Why question-first?

Most training still runs software-first: a test is chosen, then justified. The result can be numerically correct and scientifically beside the point. Every chapter here assumes the reverse order. State what would change in practice if you knew the answer; name the estimand and the population it targets; describe the data you actually have (design, visits, missingness, confounding); only then select a method and prespecify what would falsify your conclusion.

## Accessibility and validity

Precision and readability are not trade-offs. Each chapter opens with a clinical scene, states the estimand in plain language, lists assumptions where they matter, and shows where respiratory studies commonly misstep. Terms are defined in Appendix C; use the glossary as a lookup, not a memorisation exercise.

## R as a teaching tool

R is used here as a **proof of understanding**, not as a software manual. If you can simulate data, fit a model, check assumptions, and report an estimand in code, you understand the method at a level reading alone rarely reaches.

We use the tidyverse for readability. Where base R is clearer, we use base R.

**New to R?** See Appendix A. You do not need it before Chapter 1 if you are only reading the statistical content.

## What this book is not

- Not a catalogue of every test
- Not a machine-learning hype volume
- Not a substitute for protocol design, ethics approval, or clinical judgment
- Not a copy of existing textbooks with lung disease examples pasted in

## Acknowledgements

This handbook grew from teaching and from reviewing analysis plans where the science was sound but the **routing** was not. Colleagues who stress-tested chapters with [REVIEWER_RUBRIC.md](../REVIEWER_RUBRIC.md) improved the clinical and statistical framing; they will be named in the next tagged edition.

If you use this book in fellowship teaching, trial work, or translational programmes and spot an error: clinical, statistical, or omics: please open an issue or pull request on the [GitHub repository](https://github.com/kimonntotsis/Breathing-Room-for-Statistics). Respiratory research moves quickly; a living handbook depends on readers who push back.

## How to use this handbook

Use it by outcome and design, not by page order. Appendix B routes a question to a chapter; Appendix G lists datasets, files, and topics; **Appendix J** is the **shortest investigator path** (six sections before your next steering meeting, also on the Welcome page); Appendix H expands endpoint routing without R. In the PDF, appendices appear in **reader-importance order** (G → J → **K** → H → I → B → …); letters stay fixed for citations. Each method chapter follows [CHAPTER_TEMPLATE](CHAPTER_TEMPLATE.md): opening scene, tiered technique prose, one clinical check-in sentence, Quick reference at the end, and **Related chapters / Handbook resources** for lookup.

## Circulating for feedback (reviewers) {#circulating-for-feedback-reviewers}

This edition is a **candidate for targeted external review**, not a final sign-off. Please use the **[v1.1.0-review PDF release](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.1.0-review)** and [REVIEW_REQUEST.md](../../REVIEW_REQUEST.md).

**Priority chapters (3–5 hours):** Ch 4, Ch 6, Ch 13, Ch 18, Ch 20. Rubric: [REVIEWER_RUBRIC.md](../REVIEWER_RUBRIC.md).

**Please flag:** estimand errors, unsafe defaults, misleading omics claims, or reporting that would fail a grant or journal statistical review; not typos alone. **Out of scope for this pass:** full line edit, wet-lab/FASTQ pipelines, pipeline figure branding.

**Data:** all examples use synthetic CASTOR / CASTOR-HD CSVs. Ch 13 teaching DE loops differ from Appendix L Bioconductor pipelines by design; compare both before judging discovery counts.

**Feedback:** GitHub issue with label `review`, or email the author with chapter + section references.

**Signposts in the chapters:** Each part opens with a short **In the room** vignette (a meeting, email, or review moment). Method chapters vary in depth; major methods get a full worked example, supporting methods are shorter prose. Look for **Figure hygiene** (Appendix I) and wrong-analysis catalogs. You do not need every section on first pass; Appendix J lists the shortest route.

## What CASTOR means {#what-castor-means}

**CASTOR** is the analysis sequence used throughout the book: **C**linical question, **A**ssess design and data, **S**elect method, **T**est and fit, **O**utput estimand, **R**eport limits. The letters are unpacked in Chapter 1 with an eight-step pipeline figure and a method decision tree at the selection step.

**CASTOR** also names a **linked teaching universe** of synthetic COPD-flavoured datasets (spirometry, exacerbations, smoking, therapy) reused from descriptive tables through omics capstones. Files share clinical themes and variable names but **different patient IDs and sample sizes** by design; **CASTOR-HD** extends the same *narrative* to high-dimensional biology rather than one strictly patient-linked multi-omic cohort. The workflow is fixed; only the data file changes. Readers working in **chronic lung disease (CLD)** or broader pulmonary research should treat CASTOR as a **method carrier**: keep the estimand, relabel the population in your protocol.

## About the data

All examples use simulated data with realistic structure. This keeps the book fully reproducible. When you apply the methods, replace synthetic datasets with your study data and revisit every assumption.

## Scope and deliberate limits

This volume prioritises **applied method choice and interpretation** for respiratory researchers. It does **not** aim to be a complete trial-statistics or advanced-causal textbook. Topics treated briefly or as appendices include: formal ICH E9(R1) intercurrent-event implementation, cluster-randomised trials (partial: Appendix O), **recurrent-event models** (Ch 6, 19), **diagnostic accuracy** ([Appendix Q](../appendix-q-diagnostic-accuracy.md)), **Bland–Altman agreement** (Ch 3), **meta-analysis / Bayesian / adaptive trials** ([Appendix S](../appendix-s-advanced-topics-overview.md)), multi-state and joint longitudinal–survival models, and imaging statistics. **External validation**, **wrong-analysis catalogues** ([Appendix R](../appendix-r-wrong-analysis-catalog.md)), and sample-size planning ([Appendix P](../appendix-p-sample-size-planning.md)) are developed in the chapters cited. See [`archive/docs/BOOK_OUTLINE.md`](../archive/docs/BOOK_OUTLINE.md) for further extensions.

## Related chapters

| Chapter | When to open it |
|---------|------------------|
| [Chapter 1: Statistical thinking](01-statistical-thinking.md) | Estimand, PICO, CASTOR workflow |
| [Chapter 4: Comparing groups](04-comparing-groups.md) | Welch *t*, proportions, group comparisons |
| [Chapter 6: GLMs](06-generalized-linear-models.md) | Logistic, Poisson, count and binary outcomes |
| [Chapter 8: Validation & reporting](08-validation-reporting.md) | CONSORT, CIs, limits, calibration |
| [Chapter 10: Dimensionality reduction](10-dimensionality-reduction.md) | PCA, exploration, p ≫ n |
| [Chapter 12: Case studies](12-case-studies.md) | Integrated CASTOR narratives A–E |
| [Chapter 13: Differential analysis & FDR](13-differential-analysis-fdr.md) | Omics discovery, BH-FDR |
| [Chapter 18: Longitudinal mixed models](18-longitudinal-mixed-models.md) | Repeated FEV₁, slopes, clustering |
| [Chapter 20: Missing data](20-missing-data.md) | MAR/MNAR, MICE, sensitivity analyses |
| [Welcome](00-welcome.md) | Book entry point, CASTOR cast, reading paths |

## Handbook resources

| Resource | When to use it |
|----------|----------------|
| [Appendix A: R setup](../appendix-a-r-setup.md) | Install R, Posit Desktop, and run teaching scripts |
| [Appendix B: Quick reference](../appendix-b-quick-reference.md) | Choose a test or model by outcome and design |
| [Appendix C: Glossary](../appendix-c-glossary.md) | Look up statistical and respiratory terms |
| [Appendix G: Handbook navigation](../appendix-g-handbook-navigation.md) | Full file, dataset, and topic index |
| [Appendix H: Clinicians' route](../appendix-h-clinicians-route.md) | Endpoint routing without running R |
| [Appendix I: Figure hygiene](../appendix-i-figure-hygiene.md) | Right vs wrong plot pairs for slides and papers |
| [Appendix J: Investigator minimum path](../appendix-j-investigator-minimum-path.md) | Shortest read for investigators who will not run R |
| [Appendix K: In the room, short stories](../appendix-k-in-the-room-stories.md) | Extended vignettes of common analysis mistakes |
| [Appendix L: Omics analyst track](../appendix-l-omics-analyst-track.md) | Production DESeq2, limma-voom, fgsea, and ComBat pipelines |
| [APATE vignette](../APATE_VIGNETTE.md) | Prose-only messy registry checklist (no CSV) |
| [CHAPTER_TEMPLATE](../CHAPTER_TEMPLATE.md) | Editorial skeleton for method chapters |
