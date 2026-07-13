# Chapter template: handbook signature format

Every major technique in Chapters 4–11 and 13–21 uses this **seven-block structure**. Readers always know where to look.

---

## Editorial layer (glue between techniques)

These blocks sit **outside** the technique cards. They do not replace assumptions or reporting templates.

| Block | Where | Purpose |
|-------|--------|---------|
| **Why this chapter** | After prerequisites, before opening question | 3–5 sentences: who needs this, what mistake it prevents |
| **Investigator path (≈20 min)** | After At a glance | Layered read: estimand, method table, Practice read, reporting |
| **Method choice at a glance** | After Investigator path | **Method \| When to use \| Why** — canonical routing for the chapter |
| **Figure hygiene** | Once per chapter (or cross-ref Appendix I) | Right vs wrong plot pair on same CASTOR data; what the wrong panel masks |
| **In practice** | Once per chapter, before first Wrong analysis | Sponsor meeting / manuscript reality check |
| **Before you open R** | Immediately before `## R lab` or `### R lab` | Estimand + unit + file + one sensitivity: then code |
| **Where this chapter leads** | Before Further reading / Exercises | Two sentences linking to the next chapter(s) |

Part intros include an **In the room** vignette (short narrative hook: meeting, email, review). See `parts/part-*.md`. Method chapters may open with a one-paragraph scene before **Why this chapter** — use when it grounds the mistake the chapter prevents.

**Humane tone:** prefer specific situations (steering committee, reviewer line, vendor PDF) over generic “researchers often…” prose. First-person author voice belongs in the [Preface](chapters/00-preface.md), not in every technique card.

---

## Block 1: Clinical question

One sentence an investigator understands.

*Example:* Does mean FEV1 at 12 weeks differ between intervention and standard care?

---

## Block 2: Technique card

| Field | Content |
|-------|---------|
| **Answers** | What estimand/hypothesis? |
| **Outcome type** | Continuous / binary / count / … |
| **Design** | Independent, paired, clustered, RCT, cohort |
| **Data required** | Variables, n, events, follow-up |
| **Assumptions** | What must hold |
| **Effect measure** | Mean diff, OR, RR, rate ratio, AUC, … |
| **R function** | Minimal call |
| **When to use** | Bullet list |
| **When NOT to use** | Bullet list |
| **What this does NOT prove** | Causation, prediction, subtypes, … |

---

## Block 3: Dual interpretation

**Default (Ch 4–8):** **Plain language** + **Precise language** + **Practice read**.

**Ch 10–21:** use a single **Takeaway** line when the technique card already states the estimand; keep **Practice read** for decision-changing interpretation. Drop redundant Plain/Precise pairs that repeat the card verbatim.

**Practice read:** what would change in practice if the estimate were true?

---

## Block 4: Caveats box (respiratory-specific)

Table format:

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| … | … |

Minimum **4 caveats** per major technique.

---

## Block 5: Wrong analysis ⚠

**Common mistake:** what analysts do wrong.

**Why it fails:** statistical or clinical reason.

**Do instead:** correct approach + chapter reference.

---

## Block 6: Reporting template

**Methods sentence** (copy-ready):

> We compared … using … adjusting for … . Two-sided α = 0.05; 95% CIs …

**Results sentence** (copy-ready with placeholders):

> Mean FEV1 was … (SD …) in group A and … in group B (n = …). The difference was … (95% CI … to …; p = …).

**Do not say:** "proved", "no effect", "trend" (unless prespecified), "highly significant".

---

## Block 7: R lab and sensitivity

- **Before you open R** checklist (see editorial layer above)
- Primary code chunk
- One **sensitivity analysis** (nonparametric, Firth, bootstrap, calibration, …)
- Link to `R/examples/chXX_*.R`
- Figure caption: one interpretive sentence after each teaching plot (what to look for, what would worry you)

---

## Recurring cohort

Chapters 4–9 reference the **CASTOR** synthetic COPD cohort (`data/spirometry.csv`, `exacerbation.csv`, etc.) so readers see one workflow evolve. See [RECURRING_COHORT.md](RECURRING_COHORT.md).
