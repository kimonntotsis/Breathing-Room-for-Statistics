---
number-sections: false
---

# Welcome {.unnumbered}

You opened this book with a concrete problem. Good — that is how it is meant to work.

Imagine a Tuesday steering meeting. Dr Elena Rivera presents interim CASTOR trial data: 400 adults with COPD, randomised to a new inhaled regimen or standard care, primary endpoint mean FEV₁ at week 12. A forest plot snippet is on slide 3. Someone asks, *“Can we call this a win?”* The statistician, Mei Lin, asks a different question first: *“What exactly are we estimating — and for whom?”*

That exchange is the whole handbook in miniature. **Question first. Method second. Software last. Limits always.**

---

## What this book is

**Breathing Room for Statistics** is a respiratory methods handbook with reproducible R on a single synthetic cohort (**CASTOR**). You can read it without running code; you can run every teaching script if you install R once (Appendix A).

It is **not** a linear statistics textbook from page 1 to page 800. It is a **story with reference chapters**: one trial programme, one analyst–investigator partnership, methods introduced when the plot needs them.

---

## How to read it

**If you want the narrative spine** — read in order:

**Preface** → **Chapter 1** → **Chapter 2** → **Chapter 3** → **Chapter 4** → branch by your endpoint.

That path follows CASTOR from protocol argument to Table 1 to the primary comparison. Chapter 12 replays the same arcs as capstone cases.

**If you already know your endpoint** — open Appendix B, find your outcome type, jump to that chapter. Read the **opening scene** anyway; it tells you what mistake the chapter exists to prevent.

**If you are an investigator who will never run R** — Appendix J is the short read. Return here when you want the full estimand language in Chapter 1.

**If you are lost** — Appendix G lists every file. Use it once, then go back to the chapters.

---

## The CASTOR cast

| Name | Role in the story |
|------|-------------------|
| **Dr Elena Rivera** | PI; owns the protocol and the steering slide deck |
| **Mei Lin** | Analyst; pushes estimands before test names |
| **CASTOR** | Synthetic COPD-oriented trial data (`data/*.csv`) |
| **CASTOR-HD** | Omics substudy on the same patients (Part VI) |
| **APATE** | Prose-only messy registry — what CASTOR deliberately hides (POLLUX / APATE vignette) |

Teaching names **CASTOR** (clean cohort) and **APATE** / **POLLUX** (messy reality) are explained in Chapter 1 and RECURRING_COHORT.

---

## Where to go next

| You are… | Open next |
|----------|-----------|
| New to the book | [Preface](chapters/00-preface.md) |
| Ready to think before analysing | [Chapter 1](chapters/01-statistical-thinking.md) |
| Installing R | Appendix A (Handbook resources) |
| Choosing a test today | Appendix B (Handbook resources) |

## Related chapters

| Chapter | When to open it |
|---------|------------------|
| [Chapter 1: Statistical thinking](chapters/01-statistical-thinking.md) | Estimand language and CASTOR workflow |
| [Chapter 12: Case studies](chapters/12-case-studies.md) | Capstone narratives after the core path |

## Handbook resources

| Resource | When to use it |
|----------|----------------|
| [Appendix A: R setup](appendix-a-r-setup.md) | Install R, Posit Desktop, and run teaching scripts |
| [Appendix B: Quick reference](appendix-b-quick-reference.md) | Choose a test or model by outcome and design |
| [Appendix G: Handbook navigation](appendix-g-handbook-navigation.md) | Full file, dataset, and topic index |
| [Appendix J: Investigator minimum path](appendix-j-investigator-minimum-path.md) | Shortest read for investigators who will not run R |
| [RECURRING_COHORT](RECURRING_COHORT.md) | CASTOR dataset glossary and narrative spine |
| [POLLUX / APATE vignette](POLLUX_VIGNETTE.md) | Prose-only messy registry — what CASTOR deliberately hides |
