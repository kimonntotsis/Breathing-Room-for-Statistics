# Chapter 3 — Solutions

## E3.1
Use **median [IQR]** when distribution is skewed, outliers present, or small n with extreme values (e.g. ICU length of stay).

## E3.2
n per arm; age (mean SD or median IQR); sex n (%); smoking n (%); key clinical vars (FEV1, therapy); missingness note; definitions footnote.

## E3.3
Shows individual patient data; reveals bimodality/outliers hidden by summary bars alone.

## Applied

```r
source("R/examples/ch03_descriptive.R")
# Or manually:
library(tidyverse)
s <- read_csv("data/spirometry.csv", show_col_types = FALSE)
s %>% group_by(group) %>%
  summarise(n=n(), age=mean(age), sd_age=sd(age),
            pct_smoke=100*mean(smoking), fev1=mean(fev1), sd_fev1=sd(fev1))
ggplot(s, aes(fev1)) + geom_histogram(bins=25)
ggplot(s, aes(group, fev1)) + geom_boxplot() + geom_jitter(width=0.1, alpha=0.3)
```

## Extension

```r
ggplot(s, aes(sample = fev1)) + stat_qq() + stat_qq_line()
# Mild tail deviation common; large n t-tests often still reasonable for means
```

Figures exported to `volume-01/figures/` by full script.
