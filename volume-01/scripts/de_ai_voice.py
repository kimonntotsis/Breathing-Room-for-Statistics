#!/usr/bin/env python3
"""Reduce em-dash density and common AI-voice labels in reader-facing markdown."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

GLOBS = [
    "chapters/*.md",
    "parts/*.md",
    "appendix-*.md",
    "index.md",
]

# Longest first — specific em-dash patterns before generic fallback
EM_REPLACEMENTS = [
    (" — and for whom?", ", and for whom?"),
    (" — and ", ", and "),
    (" — or ", ", or "),
    (" — not ", "; not "),
    (" — until ", " until "),
    (" — read ", ": read "),
    (" — follow ", "; follow "),
    (" — pre/", ": pre/"),
    (" — is ", ": is "),
    (" — nonparametric", ": nonparametric"),
    (" — complements ", "; complements "),
    (" — illustrate ", "; illustrate "),
    (" — label ", "; label "),
    (" — route ", "; route "),
    (" — counts ", "; counts "),
    (" — they ", "; they "),
    (" — wrong ", "; wrong "),
    (" — report ", "; report "),
    (" — does ", "; does "),
    (" — clearer ", "; clearer "),
    (" — MCID", "; MCID"),
    (" — shuffle ", "; shuffle "),
    (" — Welch ", "; Welch "),
    (" — **paired**", ": use **paired**"),
    (" — *p*", "; *p*"),
    (" — hypothesis ", ": hypothesis "),
    (" — without ", ", without "),
    (" — without assuming ", ", without assuming "),
    (" — interim ", ": interim "),
    (" — ANCOVA", ": ANCOVA"),
    (" — claim ", "; claim "),
    (" — adjust", "; adjust"),
    (" — use ", "; use "),
    (" — FEV", ", FEV"),  # list continuation
    ("Good — that", "Good. That"),
    ("repeat; wrong", "repeat: wrong"),
    ("sections — read", "sections: read"),
    ("Reference sections — read", "Reference sections: read"),
    ("database lock — not", "database lock, not"),
    ("covariates — route", "covariates; route"),
    ("package — route", "package; route"),
    ("work — and", "work, and"),
    ("fight.", "fight."),  # no-op anchor
    ("vocabulary for that fight.", "vocabulary for that fight."),
    (" — compare ", "; compare "),
    (" — interval ", "; interval "),
    (" — prespecify ", "; prespecify "),
    (" — similar ", "; similar "),
    (" — positiv", ", positiv"),  # positivity
    (" — and what ", ", and what "),
    (" — per-feature ", ": per-feature "),
    (" — triage", ", triage"),
    (" — each walked", ", each walked"),
    (" — not the full", "; not the full"),
    (" — not a causal", "; not a causal"),
    (" — not a ", "; not a "),
    (" — not proof", "; not proof"),
    (" — not the ", "; not the "),
    (" — not an ", "; not an "),
    (" — not enough", "; not enough"),
    (" — not ", "; not "),
]

PRACTICE_READ = re.compile(
    r"\*\*Practice read(?: \([^)]+\))?:\*\*\s*",
    re.IGNORECASE,
)

THIS_CHAPTER_IS = {
    "This chapter is the reference for that conversation — and for every other group comparison in respiratory work.":
        "Use this chapter for that steering conversation and for other group comparisons in respiratory work.",
    "This chapter is sign-off discipline: reporting frameworks, intervals, multiplicity, and honest language.":
        "Sign-off discipline: reporting frameworks, intervals, multiplicity, and honest language.",
    "This chapter is the omics discovery workflow: per-feature models, FDR, volcano plots as **triage**, and language that separates discovery from the week-12 FEV₁ primary.":
        "The omics discovery workflow: per-feature models, FDR, volcano plots as **triage**, and language that separates discovery from the week-12 FEV₁ primary.",
    "This chapter is where you evaluate discrimination **and** calibration, and where you refuse causal language for a risk score.":
        "Evaluate discrimination **and** calibration here, and refuse causal language for a risk score.",
    "This chapter is **five manuscripts at different stages** — interim deck, journal submission, sponsor omics thread — each walked through estimand, analysis path, Results template, and explicit **does not prove**.":
        "Five manuscripts at different stages (interim deck, journal submission, sponsor omics thread), each with estimand, analysis path, Results template, and explicit **does not prove**.",
    "This chapter is that meeting. You classify outcome type, unit of analysis, and design **before** any test name.":
        "Classify outcome type, unit of analysis, and design **before** any test name.",
    "This chapter is the vocabulary for that fight.":
        "The vocabulary for that batch-versus-biology fight.",
    "Respiratory endpoints are often binary or count-shaped. This chapter is where CASTOR's exacerbation variables get the model family they deserve — and where you learn why a Gaussian test on 0/1 is a silent failure.":
        "Respiratory endpoints are often binary or count-shaped. CASTOR's exacerbation variables get the model family they deserve here, including why a Gaussian test on 0/1 is a silent failure.",
}

TIER_LABELS = [
    (re.compile(r"\(Tier A\)", re.I), ""),
    (re.compile(r"\(Tier B\)", re.I), ""),
    (re.compile(r"\(Tier C\)", re.I), ""),
    (re.compile(r"## Other clustering methods \(Tier B\)", re.I), "## Other clustering methods"),
    (re.compile(r"## Technique: Discrimination and calibration \(Tier A\)", re.I), "## Technique: Discrimination and calibration"),
    (re.compile(r"## Permutation tests and sample size \(Tier C\)", re.I), "## Permutation tests and sample size"),
]

CONSULT_STAT = re.compile(
    r"> \*\*Consult a statistician when:\*\* (.+?) This chapter is \*\*(.+?)\*\* — not (.+?)\.",
    re.DOTALL,
)

# Orphan sentences after removing **Practice read:** / **Plain language:**
FRAGMENT_FIXES = {
    "after accounting for age, sex, and height, smokers have lower average FEV1 by about 0.39 L.":
        "After adjustment for age, sex, and height, smokers have lower average FEV1 by about 0.39 L.",
    "is ~0.4 L meaningful given MCID (~0.1 L in many COPD contexts)?":
        "Check whether ~0.4 L is meaningful given MCID (~0.1 L in many COPD contexts).",
    "the FEV1 gap between smokers and non-smokers may be larger in older patients.":
        "The FEV1 gap between smokers and non-smokers may be larger in older patients.",
    "mean difference 0.09 L (95% CI −0.04 to 0.21); does the interval exclude, straddle, or include the prespecified MCID (~0.10 L in many COPD trials)?":
        "For CASTOR, mean difference 0.09 L (95% CI −0.04 to 0.21): does the interval exclude, straddle, or include the prespecified MCID (~0.10 L in many COPD trials)?",
    "mean change ~0.25 L; compare to MCID for bronchodilator response":
        "Mean change ~0.25 L: compare to MCID for bronchodilator response",
    "is the exacerbation rate different in smokers?":
        "For smoking × exacerbation, is the rate different in smokers?",
    "would a sponsor infer “clear separation” from the wrong panel alone?":
        "Would a sponsor infer “clear separation” from the wrong panel alone?",
    "not statistically significant; CI includes values that may or may not matter clinically;":
        "The result was not statistically significant; the CI includes values that may or may not matter clinically;",
    "mean difference 0.09 L (95% CI −0.04 to 0.21), the interval includes no effect":
        "For CASTOR, mean difference 0.09 L (95% CI −0.04 to 0.21). The interval includes no effect",
    "repeated FEV1 on the same patients is **not** the same as two independent groups of people.":
        "Repeated FEV1 on the same patients is **not** the same as two independent groups of people.",
    "colour points by **batch** before phenotype.":
        "Colour points by **batch** before phenotype.",
    "clustering is hypothesis-generating.":
        "Clustering is hypothesis-generating.",
    "adjust for factors that could distort the smoking–exacerbation link.":
        "Adjust for factors that could distort the smoking–exacerbation link.",
    "smoking multiplies the odds of exacerbation by exp(β), holding other variables fixed.":
        "Smoking multiplies the odds of exacerbation by exp(β), holding other variables fixed.",
    "prior exacerbations are among the strongest predictors, consistent with clinic.":
        "Prior exacerbations are among the strongest predictors, consistent with clinic.",
    "smokers have RR × exp(β) times the risk of exacerbation, adjusted.":
        "Smokers have RR × exp(β) times the risk of exacerbation, adjusted.",
    "each unit increase in ICS adherence is associated with lower expected exacerbation counts when rate ratio < 1.":
        "Each unit increase in ICS adherence is associated with lower expected exacerbation counts when rate ratio < 1.",
    "would you rank “strongest predictor” from the wrong panel?":
        "Would you rank “strongest predictor” from the wrong panel?",
    "high AUC alone does not tell a pulmonologist whether “20% risk” means 20% or 5%.":
        "High AUC alone does not tell a pulmonologist whether “20% risk” means 20% or 5%.",
    "is the modelled gap at 52 weeks clinically meaningful (MCID ~0.1 L in many COPD contexts)?":
        "Ask whether the modelled gap at 52 weeks is clinically meaningful (MCID ~0.1 L in many COPD contexts).",
    "if the right panel were your only slide, would you still sign off the primary analysis?":
        "If the right panel were your only slide, would you still sign off the primary analysis?",
    "if arms differ sharply on baseline FEV₁ or smoking, an unadjusted week-12 comparison is harder to defend,":
        "If arms differ sharply on baseline FEV₁ or smoking, an unadjusted week-12 comparison is harder to defend,",
    "mild tail deviation is common in spirometry.":
        "Mild tail deviation is common in spirometry.",
    "if sicker patients are missing spirometry, \"complete-case FEV1\" may describe **healthier** subsets,":
        "If sicker patients are missing spirometry, \"complete-case FEV1\" may describe **healthier** subsets,",
    "if analysed *n* drops mainly in severe obstruction, complete-case regression is not a neutral default.":
        "If analysed *n* drops mainly in severe obstruction, complete-case regression is not a neutral default.",
    "we can attempt to separate biology from lab process because both patient types were measured under multiple conditions.":
        "We can attempt to separate biology from lab process because both patient types were measured under multiple conditions.",
    "if disease status and lab day are inseparable, the analysis cannot tell you whether the signal is biology or processing.":
        "If disease status and lab day are inseparable, the analysis cannot tell you whether the signal is biology or processing.",
    "if batch drives the main variation, a \"biomarker panel\" is probably not real.":
        "If batch drives the main variation, a \"biomarker panel\" is probably not real.",
    "reasonable only if both groups were measured across batches, if batch == group, report non-identifiability instead of forcing ComBat.":
        "Adjustment is reasonable only if both groups were measured across batches; if batch == group, report non-identifiability instead of forcing ComBat.",
    "read off event-free probability at 6 and 12 months; compare arms visually before trusting a single *p*-value.":
        "Read off event-free probability at 6 and 12 months; compare arms visually before trusting a single *p*-value.",
    "treating censored patients as “no event” inflates the wrong bar; KM keeps them on the risk set until censoring.":
        "Treating censored patients as “no event” inflates the wrong bar; KM keeps them on the risk set until censoring.",
    "ask for **cumulative incidence curves** by arm, not only hazard ratios, when death rates differ [@harrell2015rms].":
        "Ask for **cumulative incidence curves** by arm, not only hazard ratios, when death rates differ [@harrell2015rms].",
    "one paragraph per modality; separate “discovery” from “confirmed binding.”":
        "Write one paragraph per modality; separate “discovery” from “confirmed binding.”",
    "integrated omics slides often show only the volcano.":
        "Integrated omics slides often show only the volcano.",
    "tiers are like \"high / medium / low confidence shortlist\" - more honest than pretending rank #7 is meaningfully better than rank #9.":
        "Tiers are like \"high / medium / low confidence shortlist\": more honest than pretending rank #7 is meaningfully better than rank #9.",
}


def fallback_em_dashes(text: str) -> str:
    """Replace remaining spaced em dashes heuristically."""

    def repl(m: re.Match[str]) -> str:
        after = m.group(1)
        if after[0] in "*`\"'(" or after[0].islower():
            return ", " + after
        if after.startswith("**") or after[0].isupper():
            return ". " + after
        return ": " + after

    return re.sub(r" — (\S)", repl, text)


def de_ai(text: str) -> str:
    for old, new in EM_REPLACEMENTS:
        text = text.replace(old, new)
    text = fallback_em_dashes(text)
    text = PRACTICE_READ.sub("", text)
    for old, new in THIS_CHAPTER_IS.items():
        text = text.replace(old, new)
    for pat, rep in TIER_LABELS:
        text = re.sub(pat, rep, text)

    # Drop stacked Plain / Precise language labels (editorial template residue)
    text = re.sub(r"\*\*Plain language:\*\*\s*", "", text)
    text = re.sub(
        r"\*\*Precise language:\*\*\s*",
        "Formally: ",
        text,
    )

    # Consult-a-statistician blocks: drop trailing "This chapter is..." sentence
    text = re.sub(
        r"(> \*\*Consult a statistician when:\*\* [^\n]+)\. This chapter is [^\n]+\.",
        r"\1.",
        text,
    )

    # Vary remaining "This chapter is" openers
    text = text.replace(
        "This chapter is the reference for that conversation, and for every other group comparison in respiratory work.",
        "Use this chapter for that steering conversation and for other group comparisons.",
    )
    text = text.replace(
        "This chapter is where CASTOR's exacerbation variables get the model family they deserve, and where you learn why a Gaussian test on 0/1 is a silent failure.",
        "CASTOR's exacerbation variables get the right model family here, including why `lm()` on 0/1 fails quietly.",
    )
    text = text.replace(
        "This chapter is **five manuscripts at different stages**:",
        "You get **five manuscripts at different stages**:",
    )

    for old, new in FRAGMENT_FIXES.items():
        text = text.replace(old, new)

    # Collapse double spaces (not in code fences)
    lines = []
    in_fence = False
    for line in text.splitlines():
        if line.strip().startswith("```"):
            in_fence = not in_fence
            lines.append(line)
            continue
        if not in_fence:
            line = re.sub(r"  +", " ", line)
            line = re.sub(r" ,", ",", line)
            line = re.sub(r" ;", ";", line)
        lines.append(line)
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def main() -> None:
    changed = 0
    for pattern in GLOBS:
        for path in sorted(ROOT.glob(pattern)):
            if "scripts" in path.parts:
                continue
            original = path.read_text(encoding="utf-8")
            updated = de_ai(original)
            if updated != original:
                path.write_text(updated, encoding="utf-8")
                n = original.count("—") - updated.count("—")
                print(f"{path.relative_to(ROOT)}: em dashes removed ~{max(n, 0)}")
                changed += 1
    print(f"Updated {changed} files.")


if __name__ == "__main__":
    main()
