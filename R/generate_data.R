# Generate synthetic respiratory-style datasets for the book
source("R/00_setup.R")
library(tidyverse)

set.seed(20250616)

n <- 400

# --- Cross-sectional spirometry cohort ---------------------------------------
# FEV1 (L) modelled from age, sex, smoking, height: simplified anthropometric logic

sex <- sample(c("female", "male"), n, replace = TRUE)
smoking <- rbinom(n, 1, prob = 0.35)
age <- round(rnorm(n, mean = 58, sd = 12))
height_cm <- ifelse(sex == "male", rnorm(n, 175, 7), rnorm(n, 162, 6))

fev1 <- 4.2
fev1 <- fev1 - 0.028 * (age - 40)
fev1 <- fev1 + ifelse(sex == "male", 0.55, 0)
fev1 <- fev1 + 0.012 * (height_cm - 170)
fev1 <- fev1 - 0.35 * smoking
fev1 <- fev1 + rnorm(n, 0, 0.35)

fvc <- fev1 + rnorm(n, 0.45, 0.25)
fev1_fvc <- fev1 / fvc

diagnosis <- case_when(
  fev1 < 1.8 ~ "severe_obstruction",
  fev1 < 2.5 ~ "moderate_obstruction",
  TRUE ~ "no_obstruction"
)

group_treatment <- sample(c("standard", "intervention"), n, replace = TRUE)

spirometry <- tibble(
  patient_id = sprintf("P%04d", seq_len(n)),
  age, sex, smoking = as.logical(smoking), height_cm,
  group = group_treatment,
  diagnosis,
  fev1 = round(pmax(fev1, 0.6), 2),
  fvc = round(pmax(fvc, 0.8), 2),
  fev1_fvc = round(pmax(pmin(fev1_fvc, 0.95), 0.35), 2)
)

write_csv(spirometry, file.path(paths$data, "spirometry.csv"))

# --- Exacerbation logistic outcome -------------------------------------------

n_exac <- 350
age_e <- round(rnorm(n_exac, 65, 10))
sex_e <- sample(c("female", "male"), n_exac, TRUE)
smoking_e <- rbinom(n_exac, 1, 0.4)
fev1_pct <- pmax(30, pmin(110, 85 - 8 * smoking_e - 0.25 * (age_e - 60) + rnorm(n_exac, 0, 12)))
therapy <- sample(c("ICS", "ICS_LABA", "triple"), n_exac, TRUE, prob = c(0.3, 0.45, 0.25))
prior_exac <- rpois(n_exac, lambda = ifelse(smoking_e, 1.2, 0.6))

lp <- -1.2 + 0.02 * (60 - age_e) + 0.6 * smoking_e - 0.025 * fev1_pct +
  0.35 * prior_exac + ifelse(therapy == "triple", -0.5, ifelse(therapy == "ICS_LABA", -0.25, 0))
p_exac <- plogis(lp)
exacerbation_12m <- rbinom(n_exac, 1, p_exac)

exacerbation <- tibble(
  patient_id = sprintf("E%04d", seq_len(n_exac)),
  age = age_e, sex = sex_e, smoking = as.logical(smoking_e),
  fev1_percent_predicted = round(fev1_pct, 1),
  therapy, prior_exacerbations = prior_exac,
  exacerbation_12m = as.logical(exacerbation_12m)
)

write_csv(exacerbation, file.path(paths$data, "exacerbation.csv"))

# --- Exacerbation counts (Poisson-style) -------------------------------------

n_count <- 280
lambda <- exp(0.4 + 0.5 * rbinom(n_count, 1, 0.35) - 0.015 * rnorm(n_count, 55, 10))
exac_counts <- tibble(
  patient_id = sprintf("C%04d", seq_len(n_count)),
  smoking = rbinom(n_count, 1, 0.38),
  ics_adherence = pmax(0, pmin(1, rbeta(n_count, 5, 2))),
  exacerbations_12m = rpois(n_count, lambda = lambda),
  person_years = round(runif(n_count, 0.7, 1.0), 2)
)

write_csv(exac_counts, file.path(paths$data, "exacerbation_counts.csv"))

# --- Multi-marker panel for PCA / clustering (synthetic omics-like) ------------

n_omics <- 120
p_markers <- 30
marker_names <- paste0("M", seq_len(p_markers))

# Two latent phenotypes with different marker profiles
phenotype <- sample(c("A", "B"), n_omics, replace = TRUE, prob = c(0.45, 0.55))
processing_batch <- sample(c("SiteA", "SiteB"), n_omics, replace = TRUE, prob = c(0.5, 0.5))
base <- matrix(rnorm(n_omics * p_markers, sd = 0.5), nrow = n_omics)
colnames(base) <- marker_names
load_a <- c(rep(2, 5), rep(0, p_markers - 5))
load_b <- c(rep(0, 5), rep(-1.8, 5), rep(0, p_markers - 10))
batch_shift <- c(rep(0, p_markers - 5), rep(1.2, 5))  # technical batch on M26–M30

for (i in seq_len(n_omics)) {
  if (phenotype[i] == "A") base[i, ] <- base[i, ] + load_a
  else base[i, ] <- base[i, ] + load_b
  if (processing_batch[i] == "SiteB") base[i, ] <- base[i, ] + batch_shift
}

omics <- as_tibble(base)
omics <- bind_cols(
  tibble(
    patient_id = sprintf("O%04d", seq_len(n_omics)),
    true_phenotype = phenotype,
    processing_batch = processing_batch
  ),
  omics
)

write_csv(omics, file.path(paths$data, "marker_panel.csv"))

# --- Paired pre/post bronchodilator spirometry ---------------------------------
n_bd <- 80
fev1_pre <- rnorm(n_bd, mean = 2.1, sd = 0.5)
fev1_post <- fev1_pre + rnorm(n_bd, mean = 0.25, sd = 0.08)  # bronchodilator response
bronchodilator <- tibble(
  patient_id = sprintf("B%04d", seq_len(n_bd)),
  fev1_pre = round(pmax(fev1_pre, 0.5), 2),
  fev1_post = round(pmax(fev1_post, 0.5), 2),
  fev1_change = round(fev1_post - fev1_pre, 2)
)
write_csv(bronchodilator, file.path(paths$data, "bronchodilator_paired.csv"))

# --- RCT with baseline + follow-up FEV1 (ANCOVA) -----------------------------
n_trial <- 200
group_trt <- sample(c("intervention", "standard"), n_trial, replace = TRUE)
fev1_baseline <- rnorm(n_trial, 2.2, 0.45)
fev1_followup <- fev1_baseline + ifelse(group_trt == "intervention", 0.08, 0) +
  rnorm(n_trial, 0, 0.12)
spirometry_trial <- tibble(
  patient_id = sprintf("T%04d", seq_len(n_trial)),
  group = group_trt,
  age = round(rnorm(n_trial, 62, 9)),
  sex = sample(c("female", "male"), n_trial, TRUE),
  fev1_baseline = round(pmax(fev1_baseline, 0.6), 2),
  fev1_followup = round(pmax(fev1_followup, 0.6), 2)
)
write_csv(spirometry_trial, file.path(paths$data, "spirometry_trial.csv"))

# Excess zeros for zero-inflated illustration
n_zi <- 200
smoke_zi <- rbinom(n_zi, 1, 0.4)
structural_zero <- rbinom(n_zi, 1, prob = plogis(-1 + 0.8 * smoke_zi))
counts_zi <- rpois(n_zi, lambda = exp(0.2 + 0.4 * smoke_zi))
counts_zi[structural_zero == 1] <- 0L
exacerbation_zi <- tibble(
  patient_id = sprintf("Z%04d", seq_len(n_zi)),
  smoking = as.logical(smoke_zi),
  exacerbations_12m = counts_zi
)
write_csv(exacerbation_zi, file.path(paths$data, "exacerbation_zero_inflated.csv"))

# --- Longitudinal spirometry (repeated FEV1 visits) ---------------------------
n_long_pat <- 160
long_pat <- tibble(
  patient_id = sprintf("L%04d", seq_len(n_long_pat)),
  group = sample(c("standard", "intervention"), n_long_pat, TRUE),
  age = round(rnorm(n_long_pat, 63, 9)),
  sex = sample(c("female", "male"), n_long_pat, TRUE),
  smoking = rbinom(n_long_pat, 1, 0.32),
  fev1_baseline = round(pmax(rnorm(n_long_pat, 2.1, 0.4), 0.6), 2)
)

visit_weeks <- c(0, 12, 24, 52)
longitudinal_spirometry <- long_pat %>%
  crossing(weeks = visit_weeks) %>%
  mutate(
    decline = -0.002 * weeks,
    trt = ifelse(group == "intervention", 0.06, 0),
    fev1 = fev1_baseline + decline + trt * (weeks > 0) + rnorm(n(), 0, 0.08),
    fev1 = round(pmax(fev1, 0.5), 2)
  ) %>%
  select(patient_id, group, age, sex, smoking, weeks, fev1, fev1_baseline)

write_csv(longitudinal_spirometry, file.path(paths$data, "longitudinal_spirometry.csv"))

# --- Time to first exacerbation (survival) ------------------------------------
n_surv <- 320
smoke_s <- rbinom(n_surv, 1, 0.38)
age_s <- round(rnorm(n_surv, 64, 10))
fev1_pct_s <- pmax(30, pmin(110, 88 - 7 * smoke_s - 0.2 * (age_s - 60) + rnorm(n_surv, 0, 10)))
therapy_s <- sample(c("ICS", "ICS_LABA", "triple"), n_surv, TRUE, prob = c(0.28, 0.42, 0.30))

# Daily hazard scale tuned for teaching: ~40–50 events within 365 d, smoking hazard elevated
hazard <- exp(
  -0.25 + 0.75 * smoke_s - 0.028 * fev1_pct_s +
    ifelse(therapy_s == "triple", -0.55, ifelse(therapy_s == "ICS_LABA", -0.25, 0))
)
time_raw <- rexp(n_surv, rate = hazard / 200)
time_days <- pmin(round(time_raw), 365)
event_exac <- as.integer(time_raw <= 365)

time_to_exacerbation <- tibble(
  patient_id = sprintf("S%04d", seq_len(n_surv)),
  age = age_s,
  sex = sample(c("female", "male"), n_surv, TRUE),
  smoking = as.logical(smoke_s),
  fev1_percent_predicted = round(fev1_pct_s, 1),
  therapy = therapy_s,
  time_days,
  event = event_exac
)

write_csv(time_to_exacerbation, file.path(paths$data, "time_to_exacerbation.csv"))

save(
  spirometry, exacerbation, exac_counts, omics, bronchodilator,
  spirometry_trial, exacerbation_zi, longitudinal_spirometry, time_to_exacerbation,
  file = file.path(paths$data, "book_data.RData")
)

message("Datasets written to ", paths$data)

# ==============================================================================
# High-dimensional synthetic datasets (proteomics, RNA-seq, flow cytometry, antibody)
# These are designed for future "advanced / discovery" chapters in a single-volume book.
# They DO NOT replace CASTOR core datasets above; they extend the universe.
# ==============================================================================

# --- Proteomics (Olink-like): 1k proteins with plate/batch + LOD missingness ----
set.seed(20250617)

n_prot <- 220
p_prot <- 1000
prot_names <- sprintf("Prot_%04d", seq_len(p_prot))

prot_ids <- sprintf("P%04d", seq_len(n_prot))
prot_batch <- sample(c("Batch1", "Batch2"), n_prot, replace = TRUE, prob = c(0.55, 0.45))
prot_plate <- sample(sprintf("Plate%02d", 1:10), n_prot, replace = TRUE)
prot_group <- sample(c("control", "case"), n_prot, replace = TRUE, prob = c(0.5, 0.5))
prot_age <- round(rnorm(n_prot, mean = 62, sd = 9))
prot_sex <- sample(c("female", "male"), n_prot, replace = TRUE)

# latent biology: two pathways and one inflammation axis
z1 <- rnorm(n_prot)
z2 <- rnorm(n_prot)
zinflam <- rnorm(n_prot, mean = ifelse(prot_group == "case", 0.5, 0), sd = 1)

# protein loadings: sparse blocks to create interpretable signal
loading1 <- c(rep(1, 60), rep(0, p_prot - 60))
loading2 <- c(rep(0, 60), rep(1, 60), rep(0, p_prot - 120))
loadingI <- c(rep(0, 120), rep(1, 40), rep(0, p_prot - 160))

X <- matrix(rnorm(n_prot * p_prot, sd = 0.7), nrow = n_prot, ncol = p_prot)
colnames(X) <- prot_names
for (i in seq_len(n_prot)) {
  X[i, ] <- X[i, ] +
    0.9 * z1[i] * loading1 +
    0.8 * z2[i] * loading2 +
    1.2 * zinflam[i] * loadingI
}

# technical effects: plate shift on subset, batch shift on subset
plate_shift_idx <- 850:920
batch_shift_idx <- 930:1000
plate_effect <- as.numeric(as.factor(prot_plate)) / 10
batch_effect <- ifelse(prot_batch == "Batch2", 1, 0)

X[, plate_shift_idx] <- X[, plate_shift_idx] + 0.8 * plate_effect
X[, batch_shift_idx] <- X[, batch_shift_idx] + 0.9 * batch_effect

# Ch 13 teaching hits: prespecified group shift on inflammation panel (not batch-shift block)
teach_de_idx <- match(sprintf("Prot_%04d", 1:18), prot_names)
for (i in seq_len(n_prot)) {
  gshift <- if (prot_group[i] == "case") 0.95 else -0.95
  X[i, teach_de_idx] <- X[i, teach_de_idx] + gshift + stats::rnorm(length(teach_de_idx), 0, 0.1)
}

# Olink-like LOD missingness: lower abundance -> more missing; depends on batch slightly
lod_base <- -0.6
lod_batch <- ifelse(prot_batch == "Batch2", 0.15, 0)
prob_miss <- plogis(lod_base - X + lod_batch)  # higher when X is low
miss <- matrix(runif(n_prot * p_prot), nrow = n_prot) < prob_miss
X[miss] <- NA_real_

proteomics <- bind_cols(
  tibble(
    sample_id = prot_ids,
    group = prot_group,
    age = prot_age,
    sex = prot_sex,
    batch = prot_batch,
    plate = prot_plate
  ),
  as_tibble(X)
)

write_csv(proteomics, file.path(paths$data, "proteomics_olink_like.csv"))

# --- RNA-seq: gene counts with library size + batch + DE block -----------------
n_rna <- 200
g <- 1200

rna_ids <- sprintf("R%04d", seq_len(n_rna))
rna_group <- sample(c("control", "case"), n_rna, replace = TRUE)
rna_batch <- sample(c("Run1", "Run2", "Run3"), n_rna, replace = TRUE, prob = c(0.4, 0.35, 0.25))
library_size <- round(exp(rnorm(n_rna, log(12e6), 0.35))) # ~ millions

base_mu <- rgamma(g, shape = 2, rate = 0.2)  # baseline expression propensity
de_idx <- 1:80
batch_idx <- 900:980

log_fc <- rep(0, g)
log_fc[de_idx] <- rnorm(length(de_idx), mean = 2.2, sd = 0.05)

batch_effect_gene <- rep(0, g)
batch_effect_gene[batch_idx] <- 0.6

is_case <- rna_group == "case"
group_fc_mat <- matrix(0, nrow = n_rna, ncol = g)
group_fc_mat[is_case, ] <- matrix(log_fc, nrow = sum(is_case), ncol = g, byrow = TRUE)

gene_counts <- matrix(0L, nrow = n_rna, ncol = g)
colnames(gene_counts) <- sprintf("Gene_%04d", seq_len(g))
size_param <- 40
for (i in seq_len(n_rna)) {
  batch_bump <- ifelse(rna_batch[i] == "Run3", 1, 0)
  eta <- log(base_mu) + group_fc_mat[i, ] + batch_bump * batch_effect_gene
  mu <- exp(eta)
  raw <- rnbinom(g, size = size_param, mu = pmax(mu, 0.01))
  gene_counts[i, ] <- as.integer(round(raw / sum(raw) * library_size[i]))
}

rnaseq <- bind_cols(
  tibble(
    sample_id = rna_ids,
    group = rna_group,
    batch = rna_batch,
    library_size = library_size
  ),
  as_tibble(gene_counts)
)

write_csv(rnaseq, file.path(paths$data, "rnaseq_counts.csv"))

# --- Flow cytometry: per-cell toy data + per-subject summary -------------------
# We keep the per-cell file intentionally small so it remains usable in R without
# specialized single-cell frameworks, but still illustrates gating vs clustering.

n_flow_subj <- 120
subj_ids <- sprintf("F%04d", seq_len(n_flow_subj))
flow_group <- sample(c("control", "case"), n_flow_subj, TRUE)
flow_batch <- sample(c("Day1", "Day2", "Day3"), n_flow_subj, TRUE, prob = c(0.35, 0.4, 0.25))

# Subject-level "true" immune state
tcell_activation <- rnorm(n_flow_subj, mean = ifelse(flow_group == "case", 0.6, 0), sd = 1)
mono_shift <- rnorm(n_flow_subj, mean = ifelse(flow_group == "case", 0.3, 0), sd = 1)
batch_drift <- ifelse(flow_batch == "Day3", 0.5, 0)

# Per-subject cell-type proportions (simple Dirichlet-like via gamma)
cell_types <- c("CD4_T", "CD8_T", "B", "NK", "Mono")
K <- length(cell_types)
alpha <- matrix(1, nrow = n_flow_subj, ncol = K)
alpha[, 1] <- exp(0.2 + 0.4 * tcell_activation) # CD4
alpha[, 2] <- exp(0.1 + 0.5 * tcell_activation) # CD8
alpha[, 5] <- exp(0.1 + 0.5 * mono_shift)       # Mono
alpha[, ] <- alpha[, ] * exp(batch_drift)

prop_mat <- matrix(NA_real_, nrow = n_flow_subj, ncol = K)
colnames(prop_mat) <- paste0("prop_", cell_types)
for (i in seq_len(n_flow_subj)) {
  draw <- rgamma(K, shape = alpha[i, ], rate = 1)
  prop_mat[i, ] <- draw / sum(draw)
}

# Marker medians by subject (CD3, CD4, CD8, CD19, CD56, CD14) with drift
markers <- c("CD3", "CD4", "CD8", "CD19", "CD56", "CD14")
M <- length(markers)
marker_mat <- matrix(rnorm(n_flow_subj * M, sd = 0.6), nrow = n_flow_subj)
colnames(marker_mat) <- paste0("median_", markers)
marker_mat[, "median_CD3"] <- marker_mat[, "median_CD3"] + 0.6 * tcell_activation + batch_drift
marker_mat[, "median_CD8"] <- marker_mat[, "median_CD8"] + 0.5 * tcell_activation + 0.2 * batch_drift
marker_mat[, "median_CD14"] <- marker_mat[, "median_CD14"] + 0.6 * mono_shift + 0.4 * batch_drift

flow_summary <- bind_cols(
  tibble(sample_id = subj_ids, group = flow_group, batch = flow_batch),
  as_tibble(prop_mat),
  as_tibble(marker_mat)
)
write_csv(flow_summary, file.path(paths$data, "flowcytometry_summary.csv"))

# Per-cell toy dataset (subset of subjects, ~6000 cells)
subj_small <- sample(subj_ids, 30)
cells_per <- sample(120:260, length(subj_small), replace = TRUE)

flow_cells <- map2_dfr(subj_small, cells_per, function(sid, nc) {
  i <- match(sid, subj_ids)
  # cell type assignment from subject proportions
  ct <- sample(cell_types, nc, replace = TRUE, prob = prop_mat[i, ])
  # marker intensities with cell-type signatures + subject immune state + batch drift
  df <- tibble(
    sample_id = sid,
    group = flow_group[i],
    batch = flow_batch[i],
    cell_id = sprintf("%s_C%04d", sid, seq_len(nc)),
    cell_type_true = ct
  )
  # baseline expression
  expr <- matrix(rnorm(nc * M, sd = 0.7), nrow = nc, ncol = M)
  colnames(expr) <- markers
  # signatures
  expr[ct %in% c("CD4_T", "CD8_T"), "CD3"] <- expr[ct %in% c("CD4_T", "CD8_T"), "CD3"] + 2.0
  expr[ct == "CD4_T", "CD4"] <- expr[ct == "CD4_T", "CD4"] + 2.2
  expr[ct == "CD8_T", "CD8"] <- expr[ct == "CD8_T", "CD8"] + 2.2
  expr[ct == "B", "CD19"] <- expr[ct == "B", "CD19"] + 2.4
  expr[ct == "NK", "CD56"] <- expr[ct == "NK", "CD56"] + 2.2
  expr[ct == "Mono", "CD14"] <- expr[ct == "Mono", "CD14"] + 2.3
  # subject state + drift
  expr[, "CD3"] <- expr[, "CD3"] + 0.35 * tcell_activation[i] + batch_drift[i]
  expr[, "CD14"] <- expr[, "CD14"] + 0.35 * mono_shift[i] + 0.4 * batch_drift[i]
  bind_cols(df, as_tibble(expr))
})

write_csv(flow_cells, file.path(paths$data, "flowcytometry_cells_toy.csv"))

# --- Antibody discovery: screening + confirmation + ranking stability ----------
n_clones <- 480
antigens <- c("AgA", "AgB", "AgC")

clone_id <- sprintf("Ab%04d", seq_len(n_clones))
ab_batch <- sample(c("Screen1", "Screen2"), n_clones, TRUE, prob = c(0.55, 0.45))

# True binders by antigen (overlapping sets)
true_binder_A <- sample(clone_id, 55)
true_binder_B <- sample(setdiff(clone_id, true_binder_A), 45)
true_binder_C <- sample(setdiff(clone_id, union(true_binder_A, true_binder_B)), 35)

make_screen <- function(ag) {
  is_true <- case_when(
    ag == "AgA" ~ clone_id %in% true_binder_A,
    ag == "AgB" ~ clone_id %in% true_binder_B,
    TRUE ~ clone_id %in% true_binder_C
  )
  # base signal: true binders higher; batch adds drift; replicate noise
  base <- rnorm(n_clones, mean = ifelse(is_true, 2.2, 0), sd = 0.8)
  base <- base + ifelse(ab_batch == "Screen2", 0.35, 0)
  tibble(
    clone_id = clone_id,
    antigen = ag,
    screen_batch = ab_batch,
    signal_rep1 = base + rnorm(n_clones, 0, 0.35),
    signal_rep2 = base + rnorm(n_clones, 0, 0.35),
    signal_rep3 = base + rnorm(n_clones, 0, 0.35),
    true_binder = is_true
  )
}

ab_screen <- bind_rows(lapply(antigens, make_screen))
ab_screen <- ab_screen |>
  mutate(signal_mean = (signal_rep1 + signal_rep2 + signal_rep3) / 3)

write_csv(ab_screen, file.path(paths$data, "antibody_screen.csv"))

# Confirmation assay (smaller set): pick top-ranked by mean within antigen, add some false positives
confirm <- ab_screen |>
  group_by(antigen) |>
  slice_max(order_by = signal_mean, n = 60, with_ties = FALSE) |>
  ungroup() |>
  select(clone_id, antigen, true_binder) |>
  distinct() |>
  mutate(
    kd_nM = exp(rnorm(n(), mean = ifelse(true_binder, log(8), log(120)), sd = 0.55)),
    confirm_positive = kd_nM < 30
  )

write_csv(confirm, file.path(paths$data, "antibody_confirmation.csv"))

# Save high-dimensional objects as well
save(
  proteomics, rnaseq, flow_summary, flow_cells, ab_screen, confirm,
  file = file.path(paths$data, "book_data_highdim.RData")
)
