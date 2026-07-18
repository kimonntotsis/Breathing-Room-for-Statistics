# Chapter template: story-first handbook format

Technique chapters (4–22) teach **one CASTOR story in motion** and **one method family**. Reference tables belong at the **back** of the chapter, not the front.

**Full philosophy:** [EDITORIAL_PRINCIPLES.md](EDITORIAL_PRINCIPLES.md) — Spiegelhalter-style story, Harrell-style cases, Bare Essentials routing, DRY end matter.

---

## Editorial order (required)

| Order | Block | Purpose |
|-------|--------|---------|
| 1 | **Opening scene** | 2–4 paragraphs: meeting, email, or manuscript moment. Named roles (Dr Rivera, Mei). No links in paragraph one. **Advance the CASTOR timeline** — do not replay a prior chapter’s meeting. |
| 2 | **Why this chapter** | 3–5 sentences: one mistake the scene exposes; what the reader can do after. Fold in clinical/biostat nuance here — not a separate four-bullet reference card. |
| 3 | **Body** | Tiered techniques (see below). One wrong-analysis moment per chapter (prose or single table). |
| 4 | **In practice** | **One** sponsor/reviewer reality check per chapter. |
| 5 | **Quick reference** | Single **Method \| When \| Why** table. **No Chapter summary** if this table exists. |
| 6 | **Where we go next** | Two sentences in cast voice; CASTOR timeline moves forward. **No second `**Next:**` in Exercises.** |
| 7 | **Related chapters** | Cross-chapter links with purpose — not in body. |
| 8 | **Handbook resources** | Appendix links with purpose — not in body. |
| 9 | Exercises / Further reading | Bibliography only; no navigation duplicate. |

**Do not put at the front:** At a glance, Also see, In this chapter, Method choice at a glance, Learning objectives, Prerequisites, Clinical and biostatistics notes (as a separate block).

---

## Tiered techniques (replaces seven-block stack for every method)

| Tier | Examples | Include |
|------|----------|---------|
| **A — Major** | Welch *t*, logistic, NB, Cox, mixed model, BH-FDR | Technique card → **one** Practice read → reporting template → R |
| **B — Supporting** | Mann–Whitney, paired *t*, Fisher, bootstrap | 2–4 sentences + R + one common mistake |
| **C — Pointer** | Pooled *t*, one-sample *t* | One line: when / avoid / see Tier A |

**Never stack:** Plain language + Precise language + Dual interpretation + Practice read for the same estimand.

**Wrong analysis:** once per chapter — inline at the decision point **or** a short prose catalog, not both plus per-section tables.

---

## Prose vs tables

| Use a table when… | Use prose when… |
|-------------------|-----------------|
| Reader scans 4+ methods (Quick reference, master router) | One mistake, one Mei/Rivera exchange |
| Methods/Results copy-paste templates | Why a sponsor slide misleads |
| Appendix B / decision tree | Linking scene → technique |

**Humanize:** Prefer a **Practice read** paragraph over technique-card rows. Convert one-line wrong-analysis tables to: *Common mistake: … Instead: …*

---

## Narrative spine

One synthetic trial (**CASTOR**) carries Parts I–V and VIII. **CASTOR-HD** enters in Part VI. Act map: [RECURRING_COHORT.md](RECURRING_COHORT.md#narrative-spine-the-castor-trial).

**Humane tone:** specific situations — not “researchers often…”. Author first-person only in the [Preface](chapters/00-preface.md).

**Capstone (Ch 12):** assumes Ch 1–11 read; cases start at **submission, reviewer, or sponsor** stage — not the same steering scene as Ch 4.

---

## Part openers

Lead with **In the room** (2–4 sentences). Move bullet syllabi to appendix or part Quick reference.

---

## Figure hygiene

One right-vs-wrong pair or router figure per chapter where applicable; link from **Handbook resources**, not every technique section.

---

## Recurring cohort

[CASTOR](RECURRING_COHORT.md) synthetic data; extended stories via **Handbook resources** (Appendix K). Do not re-paste the CASTOR glossary paragraph — point to RECURRING_COHORT once.
