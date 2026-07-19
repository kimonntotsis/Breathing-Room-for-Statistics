# Published navigation figures (frozen)

These three illustrated assets are **hand-picked and frozen**. R scripts write fallbacks only (`*_r.png`); they **must not** overwrite the files below.

| Published file | Role | Archive master | MD5 |
|----------------|------|----------------|-----|
| `analysis_pipeline.png` | CASTOR 8-step pipeline + handbook routes | `archive/figures/pipeline-options/select-illustrated-luxe-ch22-preview-4096.png` | `a70f3ee844e76468eff4e64b829d0d5d` |
| `viz_plot_router.png` | Plot choice by estimand (prefer vs avoid) | `archive/figures/pipeline-options/select-router-copper.png` | `d00881c1e242c88655a5078d0e064216` |
| `method_decision_tree.png` | Outcome → test → model router | `archive/figures/pipeline-options/select-tree-luxe-routes-modern-4096.png` | `649fe148dd780d59818ea902f5dbc3a4` |

Backup copies: `archive/figures/published-masters/` (same bytes as above).

## R fallbacks (safe to regenerate)

| File | Script |
|------|--------|
| `analysis_pipeline_r.png`, `analysis_pipeline_r_modern.png` | `R/examples/generate_figures.R` |
| `method_decision_tree_r.png` | `R/examples/generate_figures.R` |
| `viz_plot_router_r.png` | `R/examples/generate_viz_pairs.R` |

## Restore if accidentally overwritten

```bash
cp archive/figures/published-masters/analysis_pipeline.png volume-01/figures/
cp archive/figures/published-masters/viz_plot_router.png volume-01/figures/
cp archive/figures/published-masters/method_decision_tree.png volume-01/figures/
```

Design drafts (local only, gitignored): `archive/figures/pipeline-options/` — see `TREE-SELECT.md`, `ROUTER-SELECT.md`, `CH22-PREVIEW.md`.
