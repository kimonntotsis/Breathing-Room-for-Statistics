# Archive

Local-only material kept for reference. **Not used** by `build-handbook-pdf.sh`, CI, or the published PDF.

| Folder | Contents |
|--------|----------|
| `scripts/` | One-off editorial / migration Python scripts |
| `scripts/legacy/` | Earlier batch passes (from `volume-01/scripts/archive/`) |
| `r-examples/` | Design-time R for pipeline / decision-tree / cover explorations |
| `figures/fallbacks/` | R-generated PNG fallbacks (handbook uses illustrated masters in `volume-01/figures/`) |
| `figures/pipeline-options/` | AI + ggplot design iterations (~86 MB) |
| `figures/cover-explorations/` | Cover art drafts and upscale experiments |
| `docs/` | Author planning notes (`BOOK_OUTLINE.md`) |
| `data/` | Regenerated `.RData` caches (CSVs in `data/` are the reader-facing exports) |
| `drafts/` | Root-level cover drafts |

**Regenerate fallbacks or design options** (optional, local only):

```r
source("archive/r-examples/draw_pipeline_options.R")
source("archive/r-examples/draw_decision_tree_options.R")
```

Active build scripts stay in `volume-01/scripts/` (`prepare_cover_assets.py`, `verify_*.py`).
