# Chapter 11 solutions

## E11.1
Clustering uses only marker/feature similarity; no outcome label guides group formation. **Supervised contrast:** logistic regression predicting 12-month exacerbation from smoking and FEV1 (Ch 6/9) uses the outcome to fit coefficients.

## E11.2
**k-means:** fast, needs *k* upfront; sensitive to outliers. **Hierarchical:** dendrogram visualisation; irreversible merges; costly for huge *n*. **PAM:** robust medoids; slower; good when prototype patients matter.

## E11.3
The ladder runs from exploratory clusters → internal stability → external replication → prognostic outcomes → treatment response in an RCT. Use “endotype” in a title only when rungs 4–5 are credibly addressed (prognostic and ideally treatment-linked validation).

## E11.4
Batch reflects **how/when/where samples were processed**, not biology. If clusters track batch, apparent “subgroups” may be laboratory artefacts. Biological interpretation is unsafe until batch is modelled or corrected.

## Applied

```r
source("R/examples/ch11_clustering.R")
```

**Silhouette / stability:** read printed `Mean silhouette by k` and `Bootstrap item stability` lines.

**Shootout:** high adjusted Rand index for `k-means vs processing_batch` is the main red flag; moderate agreement between algorithms is expected.

**Results paragraph:** use §11.13 template with your numeric values. Do **not** call clusters endotypes.

**Teaching note:** `true_phenotype` alignment is for learning only; real studies lack ground truth.
