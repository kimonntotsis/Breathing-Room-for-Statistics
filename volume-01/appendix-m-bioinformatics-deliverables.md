---
number-sections: false
---

# Appendix M: What your bioinformatics core should deliver {.unnumbered}

> Checklist for investigators receiving an omics export from a core facility, CRO, or collaborator. The handbook starts analysis at **count matrices**; this appendix bridges wet-lab → files without teaching RNA extraction in the lab.

## Minimum deliverable package

| Item | Required columns / fields | Red flag if missing |
|------|---------------------------|---------------------|
| **Sample metadata** | `sample_id`, `group`, `batch`/`run`/`plate`, `library_size` (RNA) | No batch column; IDs don't match count matrix |
| **Count matrix (RNA)** | Genes × samples or samples × genes (document which); integer counts | TPM-only with no raw counts; rounded decimals |
| **Proteomics matrix** | Protein ID, abundance, LOD flag | Only fold-change table, no per-sample values |
| **Normalization statement** | Method named (DESeq2 size factors, TMM, Olink NPX, …) | "Normalized" with no method |
| **Feature annotation** | Gene symbol or protein name map | Only internal IDs |
| **QC report** | Mapping rates, library complexity, PCA by batch | Volcano PDF only |

## RNA-seq: from extraction to counts (what to ask for)

You do not need to run STAR yourself, but your DAP should name who owns each step:

1. **Extraction & library prep**, documented kit/protocol version
2. **Sequencing**: read length, depth per sample, spike-ins if any
3. **QC**. FastQC/MultiQC summary; failed lanes excluded?
4. **Alignment / quantification**, tool + reference genome build (e.g. GRCh38)
5. **Count matrix**, **un-normalized integer counts** for DE (DESeq2/edgeR)
6. **Metadata join**, sample IDs in matrix == metadata table

**Accept for DE:** `counts.csv` + `colData.csv` 
**Do not accept as sole DE input:** TPM-only matrix (use for exploration; re-request counts)

## Proteomics (Olink-like / targeted panels)

| Question | Why |
|----------|-----|
| LOD handling documented? | Below-detection ≠ zero abundance |
| Plate/batch in metadata? | Ch [14](chapters/14-batch-effects.md) |
| Imputation rule stated? | KNN/median imputation can fabricate group differences |

## Before you spend on pathway analysis

- DE table with **effect size + FDR**, not p-values alone ([Ch 13](chapters/13-differential-analysis-fdr.md))
- Batch sensitivity complete ([Ch 14](chapters/14-batch-effects.md))
- Gene IDs map to pathway database build date

Analyst track: [Appendix L](appendix-l-omics-analyst-track.md) (`fgsea` on DESeq2 ranks).

## Sign-off sentence for Methods

> *Counts were provided by [core] using [tool] against [reference]; integer counts were analysed with DESeq2 v[X] with batch as a covariate and BH-FDR across [N] genes. Normalization for DE used DESeq2 size factors; TPM was used only for exploratory plots.*

## Related

- [Appendix L: Analyst track](appendix-l-omics-analyst-track.md)
- [Appendix N: Bulk vs single-cell](appendix-n-bulk-vs-singlecell.md)
- [HIGH_DIM_REPORTING_TEMPLATES](HIGH_DIM_REPORTING_TEMPLATES.md)
