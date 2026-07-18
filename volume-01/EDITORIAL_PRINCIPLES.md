# Editorial principles: soul, flow, and no second copies

This handbook sits between three traditions. Each solves a problem template-heavy stats books get wrong.

| Tradition | Exemplar | What we steal |
|-----------|----------|----------------|
| **Story before symbol** | Spiegelhalter, *The Art of Statistics* | Real decisions (Titanic, serial killers) teach *thinking*; formulas follow questions |
| **Bite-sized + visual** | Altman et al., *Making Sense of Medical Statistics* | Short chapters, one concept, questions at the end — not 40 pages per test |
| **Plain voice, zero jargon wall** | Norman & Streiner, *Biostatistics: The Bare Essentials* | Irreverent clarity; “the software knows the formula” |
| **Case-driven depth** | Harrell, *Regression Modeling Strategies* | Full non-trivial datasets, not toy paragraphs repeated 17 times |
| **Technical clarity** | O’Reilly / IBM quality-tech-info guides | DRY: say it once; active voice; tables for routing, prose for judgment |

**CASTOR** is our Harrell-style through-line; **Mei and Rivera** are our Spiegelhalter narrators; **Appendix B** is our Bare Essentials router — not a fourth copy of every chapter.

---

## The one rule

> **Every block must change what the reader believes or does next.**  
> If it only restates the block above, cut or merge it.

---

## What makes a chapter feel *alive*

1. **Open in a room** — email, steering slide, reviewer line, CRO attachment. Named people. No links in paragraph one.
2. **One mistake per chapter** — the opening scene exposes one failure mode; the body fixes it. Not a catalogue of every test.
3. **Advance the trial timeline** — Ch 4 is interim lock; Ch 12 is manuscript; Ch 13 is sponsor omics email. Never replay the same meeting verbatim.
4. **Mei asks; Rivera decides** — judgment lives in dialogue, not “Researchers often…”
5. **End with motion** — “Where we go next” is two sentences in cast voice, not a link farm.

---

## Tiered technique sections (anti-template)

Not every method deserves the same scaffolding.

| Tier | Methods | Structure |
|------|---------|-----------|
| **A — Major** | Welch *t*, logistic, NB, Cox, mixed model, BH-FDR | Opening beat → estimand sentence → technique card → **one** Practice read → reporting template → R |
| **B — Supporting** | Mann–Whitney, paired *t*, Fisher, bootstrap | 2–4 sentences + R line + one common mistake |
| **C — Pointer** | Pooled *t*, one-sample *t*, minor variants | Single sentence: “Use when… Avoid when… See Tier A.” |

**Never stack:** Plain language + Precise language + Dual interpretation + Practice read for the same estimand. Pick **one** voice paragraph.

**Wrong analysis:** once per chapter — either at the decision point **or** a short prose catalog, not both plus eleven inline tables.

**In practice:** exactly **one** sponsor/reviewer reality check per chapter.

---

## End matter: three blocks, no echo

| Block | Content | Do not duplicate |
|-------|---------|------------------|
| **Quick reference** | Method \| When \| Why table | Chapter summary bullets |
| **Where we go next** | 2 sentences, CASTOR timeline | `**Next:**` at bottom of Exercises |
| **Lookup** | Related chapters + Handbook resources (one table, two column groups or one combined table) | Appendix B repeated in body |

Drop **Chapter summary** when Quick reference already lists methods. Drop verbatim intros (“Open these when…”) — the heading is enough.

---

## Capstone and reference chapters

- **Ch 4, 6, 8–11** are *reference*, not *narrative*. They should read like a well-indexed lab manual with a story **frame**, not seventeen identical forms.
- **Ch 12** assumes prior chapters were read. Cases **advance** the arc (submission, reviewer, sponsor deck) — they do not re-stage Ch 4’s steering committee.
- **Ch 13–17** teach workflow once; production detail lives in Appendix L.

---

## Part openers

Lead with **In the room** (2–4 sentences). Bulleted syllabi belong in Appendix G or the part’s Quick reference — not before the reader meets Mei.

---

## Checklist before merging a section

- [ ] Does this sentence appear elsewhere in the chapter?
- [ ] Does this table repeat a figure or Appendix B row?
- [ ] Can a Mei quote replace a four-row caveats table?
- [ ] Would Spiegelhalter tell this as a story, or a syllabus?
- [ ] Does the CASTOR timeline move forward?

---

## Cross-chapter references (when to link, when not)

**Do not** send readers to another chapter for something they should do **in the same workflow step**:

| Instead of… | Write… |
|-------------|--------|
| “Report CI (Ch 8)” while teaching Welch *t* | “Report mean difference + 95% CI in Results” |
| “See Ch 7” when listing SAP covariates | “Prespecify in the SAP before unblinding” |
| “Ch 4, Ch 8” on one analysis-path row | “Ch 4 + SAP” or name the action |

**Do** link chapters when the reader **changes task or timeline**:

| Link when… | Example |
|------------|---------|
| Outcome family changes | Count exacerbations → Part III GLMs |
| Design changes | One visit → repeated measures (Part VIII) |
| Manuscript stage | Models fit → Part IV sign-off |
| Discovery vs confirmatory | Clinical primary → Part VI omics |

**Where we go next** = one CASTOR story beat (2–4 sentences). Not a bullet list of three chapter numbers.

---

## Implementation map

| Priority | Action | Status |
|----------|--------|--------|
| 1 | Tier A/B/C in `CHAPTER_TEMPLATE.md` | Template updated |
| 2 | Case A → journal submission scene (Ch 12) | Done in pass |
| 3 | Part III, IV, VI narrative-first openers | Done in pass |
| 4 | Trim end-matter boilerplate (`scripts/trim_end_matter.py`) | Script |
| 5 | Ch 4 demote minor techniques to Tier B/C | Done |
| 6 | Merge Clinical/biostat notes into Why this chapter | Done |
| 7 | Single Lookup section at chapter end | Optional next pass |
| 8 | Investigator fast path (Welcome + Appendix J) | Done |
| 9 | Part VIII statistician escalation callouts | Done |
| 10 | Exercise index by estimand (Appendix F) | Done |

See also: [CHAPTER_TEMPLATE.md](CHAPTER_TEMPLATE.md), [RECURRING_COHORT.md](RECURRING_COHORT.md#narrative-spine-the-castor-trial).
