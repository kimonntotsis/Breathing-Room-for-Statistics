---
number-sections: false
---

# Preface {.unnumbered}

Respiratory research rests on incompatible data shapes in the same programme: spirometry and symptom scores, exacerbation counts, imaging, biomarker panels, trial endpoints, ICU trajectories, and omics tables with more variables than patients. Textbooks and courses teach methods in isolation. Manuscripts still fail for recurring reasons: the wrong estimand, the wrong outcome family, missingness handled as an afterthought, discovery claims without multiplicity or batch discipline, prediction metrics without calibration. This handbook connects question, method, reporting, and reproducible R on one synthetic cohort so each step is visible in code you can rerun.

## Who this book is for

**Investigators** and **analysts** who need to match a research question to a defensible analysis: especially **early- and mid-career** respiratory researchers, and **senior clinicians** who want statistics and coding to feel **purposeful**, not like a second degree in mathematics or computer science.

You do not need to derive every estimator or write production-grade software. You **do** need to know: what question the method answers, when it fits your data, what to check, what to report, what alternatives exist, and what the result does **not** prove. Investigators can use estimand sections, technique cards, and reporting templates without running R; analysts follow the same workflow with reproducible R on CASTOR.

**CASTOR** is a **COPD-flavoured** synthetic teaching cohort (spirometry, exacerbations, smoking, therapy) so examples stay comparable from Table 1 through survival and omics; the workflow applies across **chronic lung disease (CLD)** and other respiratory settings when the **outcome type and design** match, including asthma trials and mixed pulmonary programmes.

## Why I wrote this

I wrote this handbook because respiratory programmes now stack incompatible data in one grant: spirometry and symptom scores beside proteomics panels with more proteins than patients. Training still often starts with software (“run a t-test”) instead of the estimand. Manuscripts fail for the same preventable reasons: wrong outcome family, missingness as an afterthought, discovery slides beside confirmatory endpoints, prediction metrics without calibration.

I have sat in meetings where a clean volcano plot arrived before anyone wrote the primary estimand, and where a cohort with eight ICU wards was analysed as 400 independent patients. Those are not rare failures of intelligence; they are **gaps in routing**: knowing which technique matches which aim, and what to say when you do not have a bioinformatics group on speed dial.

This book is a **first starting point**: question-first, limits-last, reproducible where it helps understanding. It will not replace a statistician for your pivotal trial, and it will not turn you into a bioinformatician overnight. It should stop you from signing off analyses that are numerically runnable but scientifically beside the point.

**Feasible fiction:** [Appendix K: In the room: short stories](appendix-k-in-the-room-stories.md): six invented situations (mixed columns + wrong tests, random forest without a goal, `lm()` on 0/1, training-set AUC, omics merged with FEV1, prediction quoted as causation) grounded in patterns respiratory journals and methods reviews see repeatedly.

## What you can learn here (without the deep math)

| You want to… | This book helps you… | It does not require… |
|--------------|----------------------|----------------------|
| Pick a method for your endpoint | Route by outcome + design ([Appendix B](appendix-b-quick-reference.md)) | Proving asymptotic theory |
| Adjust for baseline or confounders | Prespecify covariates; read adjusted CIs ([Ch 4–6](chapters/04-comparing-groups.md)) | Mastering every GLM extension |
| Report for CONSORT/STROBE | Templates + intervals, not “NS” ([Ch 8](chapters/08-validation-reporting.md)) | Journal politics |
| Handle a proteomics file someone emailed you | FDR, batch, honest discovery language ([Ch 13–17](chapters/13-differential-analysis-fdr.md)) | Building a genomics pipeline from scratch |
| Run teaching R scripts | Reproduce CASTOR examples ([Appendix A](appendix-a-r-setup.md)) | Becoming a software engineer |
| Say what was **not** proven | Case studies + APATE skepticism ([Ch 12](chapters/12-case-studies.md), [APATE](APATE_VIGNETTE.md)) | |

**R** is a **proof of understanding**, not the job description. Read the argument first; run code when it clarifies.

## Without a dedicated bioinformatics collaborator

Many pulmonary labs now receive high-dimensional tables: Olink exports, RNA count matrices, flow summaries: without embedded bioinformatics support. That is normal, and it is where misuse is most common:

- **Volume intimidation:** 1,000 columns feel “more scientific” than FEV1; the estimand did not change.
- **Tool mismatch:** PCA or k-means run on raw exports with batch columns ignored ([Ch 10–11](chapters/10-dimensionality-reduction.md)).
- **p-value fishing:** nominally significant features without FDR or effect sizes ([Ch 13](chapters/13-differential-analysis-fdr.md)).
- **Confirmatory dressing:** volcano figures beside week-12 FEV1 in one Results section ([Ch 12 Case D](chapters/12-case-studies.md)).
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

Precision and readability are not trade-offs. Each chapter pairs plain language with a formal statement, lists assumptions explicitly, and shows where respiratory studies commonly misstep. Terms are defined in [Appendix C](../appendix-c-glossary.md); use the plain-language column as a lookup, not a memorisation exercise.

## R as a teaching tool

R is used here as a **proof of understanding**, not as a software manual. If you can simulate data, fit a model, check assumptions, and report an estimand in code, you understand the method at a level reading alone rarely reaches.

We use the tidyverse for readability. Where base R is clearer, we use base R.

**New to R?** See [Appendix A](../appendix-a-r-setup.md). You do not need it before Chapter 1 if you are only reading the statistical content.

## What this book is not

- Not a catalogue of every test
- Not a machine-learning hype volume
- Not a substitute for protocol design, ethics approval, or clinical judgment
- Not a copy of existing textbooks with lung disease examples pasted in

## Acknowledgements

This handbook grew from teaching and from reviewing analysis plans where the science was sound but the **routing** was not. Colleagues who stress-tested chapters with [REVIEWER_RUBRIC.md](../REVIEWER_RUBRIC.md) improved the clinical and statistical framing; they will be named in the next tagged edition.

If you use this book in fellowship teaching, trial work, or translational programmes and spot an error: clinical, statistical, or omics: please open an issue or pull request on the [GitHub repository](https://github.com/kimonntotsis/Breathing-Room-for-Statistics). Respiratory research moves quickly; a living handbook depends on readers who push back.

## How to use this handbook

Use it by outcome and design, not by page order. [Appendix B](../appendix-b-quick-reference.md) routes a question to a chapter; [Appendix G](../appendix-g-handbook-navigation.md) lists datasets, files, and topics; [Appendix J](../appendix-j-investigator-minimum-path.md) is the **shortest route**; [Appendix H](../appendix-h-clinicians-route.md) expands endpoint routing without R. In the PDF, appendices appear in **reader-importance order** (G → J → **K** → H → I → B → …); letters stay fixed for citations. The [Welcome](../chapters/00-welcome.md) page summarises the eight parts. Each method chapter follows the same skeleton ([CHAPTER_TEMPLATE.md](../CHAPTER_TEMPLATE.md)): question, technique card, plain and precise interpretation, **Practice read**, caveats, common errors, reporting template, code.

## Circulating for feedback (reviewers) {#circulating-for-feedback-reviewers}

This edition is a **candidate for targeted external review**, not a final sign-off. Please use the **[v1.1.0-review PDF release](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.1.0-review)** and [REVIEW_REQUEST.md](../../REVIEW_REQUEST.md).

**Priority chapters (3–5 hours):** [Ch 4](chapters/04-comparing-groups.md), [Ch 6](chapters/06-generalized-linear-models.md), [Ch 13](chapters/13-differential-analysis-fdr.md), [Ch 18](chapters/18-longitudinal-mixed-models.md), [Ch 20](chapters/20-missing-data.md). Rubric: [REVIEWER_RUBRIC.md](../REVIEWER_RUBRIC.md).

**Please flag:** estimand errors, unsafe defaults, misleading omics claims, or reporting that would fail a grant or journal statistical review — not typos alone. **Out of scope for this pass:** full line edit, wet-lab/FASTQ pipelines, pipeline figure branding.

**Data:** all examples use synthetic CASTOR / CASTOR-HD CSVs. Ch 13 teaching DE loops differ from [Appendix L](../appendix-l-omics-analyst-track.md) Bioconductor pipelines by design; compare both before judging discovery counts.

**Feedback:** GitHub issue with label `review`, or email the author with chapter + section references.

**Signposts in the chapters:** Each part opens with a short **In the room** vignette (a meeting, email, or review moment). Method chapters use a shared skeleton ([CHAPTER_TEMPLATE.md](../CHAPTER_TEMPLATE.md)): but openings vary: some start with a case, not a catalogue. Look for **Practice read** (what would change the decision), **In practice** (sponsor or manuscript reality), **Figure hygiene** ([Appendix I](../appendix-i-figure-hygiene.md)), and **Wrong analysis** panels. You do not need every signpost on first pass; [Appendix J](../appendix-j-investigator-minimum-path.md) lists the shortest route.

## What CASTOR means {#what-castor-means}

**CASTOR** is the analysis sequence used throughout the book: **C**linical question, **A**ssess design and data, **S**elect method, **T**est and fit, **O**utput estimand, **R**eport limits. The letters are unpacked in [Chapter 1](01-statistical-thinking.md) with an eight-step pipeline figure and a method decision tree at the selection step.

**CASTOR** also names a **synthetic COPD-flavoured cohort** (spirometry, exacerbations, smoking, therapy) reused from descriptive tables through omics capstones; **CASTOR-HD** extends the same patients to high-dimensional biology. The workflow is fixed; only the data file changes. Readers working in **chronic lung disease (CLD)** or broader pulmonary research should treat CASTOR as a **method carrier**: keep the estimand, relabel the population in your protocol.

## About the data

All examples use simulated data with realistic structure. This keeps the book fully reproducible. When you apply the methods, replace synthetic datasets with your study data and revisit every assumption.
