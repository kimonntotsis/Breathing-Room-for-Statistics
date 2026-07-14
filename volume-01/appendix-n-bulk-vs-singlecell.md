---
number-sections: false
---

# Appendix N: Bulk RNA vs single-cell — when to escalate {.unnumbered}

> The handbook teaches **bulk** proteomics and RNA-seq on CASTOR-HD plus **participant-level** flow summaries. This appendix sets boundaries so readers know when Ch 13–15 stop and single-cell tooling begins.

## Quick decision table

| Your data | Handbook path | Escalate when |
|-----------|---------------|---------------|
| **Bulk RNA counts** (`rnaseq_counts.csv`) | Ch 13, Appendix L (DESeq2/limma) | Need cell-type resolution |
| **Olink / targeted proteomics** | Ch 13–14 | Need MS1 DIA / spectral library workflows |
| **Flow — participant proportions** | Ch 15 | Need unsupervised cell discovery at scale |
| **Toy per-cell CSV** (`flowcytometry_cells_toy.csv`) | Ch 15 wrong/right demo only | Production scRNA or CyTOF |

## Bulk RNA-seq (what this book covers)

- **Unit:** one expression profile per biosample (sputum, biopsy, blood)
- **DE:** DESeq2 / limma-voom on integer counts ([Appendix L](appendix-l-omics-analyst-track.md))
- **Limit:** cell-type mixing — a DE signal might be driven by **composition** (more neutrophils in cases) not within-cell expression

**Practice read:** bulk DE in severe asthma/COPD often needs **cell proportion covariates** or deconvolution before claiming within-cell regulation.

## Single-cell RNA-seq (out of scope — but here is the routing)

| Step | Typical tools | Handbook analogue |
|------|---------------|-------------------|
| QC & filtering | Seurat, scanpy | Ch 3 missingness mindset |
| Normalization | SCTransform, scran | Ch 13 normalization caveats |
| Clustering | Leiden/Louvain | Ch 11 (stability warnings apply **more**) |
| DE | pseudobulk DESeq2 preferred | Appendix L |
| Annotation | marker panels | Ch 15 population labels |

**Do not:** run t-tests on single cells (pseudo-replication; Ch 15).

## Flow cytometry vs scRNA

| | Flow (Ch 15) | scRNA |
|---|-------------|-------|
| **Scale** | 10–30 markers, millions of cells | 1000–3000 genes, thousands of cells |
| **Summary** | Gated proportions per participant | Clusters + pseudobulk DE |
| **Handbook** | `lm` on participant proportions | Escalate to Seurat/scanpy |

The toy per-cell file in CASTOR-HD exists only to show **why per-cell models inflate n** — not to teach Seurat.

## Integrated CASTOR-HD (Ch 17)

End-to-end capstone uses **bulk** matrices + participant summaries. Multi-omics integration (MOFA+, DIABLO) is listed as future expansion in [BOOK_OUTLINE.md](../BOOK_OUTLINE.md).

## Related chapters

- [Ch 13](chapters/13-differential-analysis-fdr.md) — escalate pointer for FASTQ/single-cell
- [Ch 15](chapters/15-flow-cytometry.md) — unit of analysis
- [Appendix L](appendix-l-omics-analyst-track.md) — bulk RNA pipelines
- [Appendix M](appendix-m-bioinformatics-deliverables.md) — core deliverables
