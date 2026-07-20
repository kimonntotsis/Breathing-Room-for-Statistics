---
number-sections: false
---

# Edition and reproducibility {.unnumbered}

This PDF was built from the handbook repository. **Do not cite page numbers alone**; cite the git commit below or a tagged release.

{{< include ../BUILD_METADATA.md >}}

## How to reproduce

1. Clone the repository and checkout the commit above.
2. Open the project in Posit Desktop (or R in the repo root).
3. Run `renv::restore()` (see [Appendix A](../appendix-a-r-setup.md)).
4. Regenerate outputs: `source("R/run_all_examples.R"); run_all_examples(include_omics = FALSE)`.
5. Build: `./build-handbook-pdf.sh`.

Continuous integration runs core R examples before building the PDF (`.github/workflows/handbook-pdf.yml`).

## Accessibility (PDF/UA-2)

This edition targets **PDF/UA-2** when built with **TeX Live 2025+** (`./build-handbook-pdf.sh` sets `pdf-standard: ua-2` automatically). Older TeX Live releases still build an untagged PDF with English `lang` metadata and caption-based figure alt text (`volume-01/filters/figure_alt.lua`). Optional validation: `quarto install verapdf`.

**Cover art:** decorative statistical motifs on the cover are illustrative, not CASTOR results.
