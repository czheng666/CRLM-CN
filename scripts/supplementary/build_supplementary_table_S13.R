## Build Supplementary Table S13 from the isolated 5-gene sensitivity output.
## This script does not modify any frozen Figure 2 or Supplementary package files.

source(file.path(Sys.getenv("CRLM_CODE_RELEASE_ROOT", unset = getwd()), "config.R"))

options(stringsAsFactors = FALSE)

fivegene_root <- crlm_require_dir(CRLM_5GENE_ROOT, "CRLM_5GENE_ROOT")
source_csv <- file.path(fivegene_root, "tables", "8_vs_5_comparator_summary.csv")
out_dir <- fivegene_root
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(source_csv)) {
  stop("Authoritative 8-vs-5 comparator summary not found: ", source_csv)
}

dat <- read.csv(source_csv, check.names = FALSE, stringsAsFactors = FALSE)
expected <- c(
  "8-gene literature-derived marker score",
  "5-gene macrophage-specific SPP1-TAM score"
)
stopifnot(identical(dat$comparator, expected))
stopifnot(all(dat$discovery_n_cells == 12433L))
stopifnot(all(dat$discovery_spearman_rho >= 0 & dat$discovery_spearman_rho <= 1))
stopifnot(all(dat$residual_n_patients == 13L))
stopifnot(all(dat$residual_n_positive <= dat$residual_n_patients))

display <- data.frame(
  `指标定义` = c(
    "文献整理的 8 基因 SPP1-TAM 标志评分",
    "macrophage-specific 5 基因 SPP1-TAM 评分"
  ),
  `纳入基因` = gsub(";", ", ", dat$genes, fixed = TRUE),
  `评分计算` = c(
    "log1p(CP10K) 表达的非加权均值；冻结比较指标，保持原实现",
    "在 GSE245552 细胞层面对各基因进行 z 标准化后，取非加权均值 z-score"
  ),
  `发现队列中与 P1 的相关性（Spearman ρ；n = 12,433 个细胞）` = sprintf("%.6f", dat$discovery_spearman_rho),
  `残差 LM−PT 差值中位数` = sprintf("%.6f", dat$residual_median_delta),
  `95% CI` = sprintf("%.6f-%.6f", dat$residual_ci_low, dat$residual_ci_high),
  `正向患者数` = sprintf("%d/%d", dat$residual_n_positive, dat$residual_n_patients),
  `Sign-flip P` = sprintf("%.6f", dat$residual_signflip_p_two_sided),
  check.names = FALSE
)

out_csv <- file.path(out_dir, "Supplementary_Table_S13_alternative_SPP1_TAM_marker_definitions.csv")
write.csv(display, out_csv, row.names = FALSE, fileEncoding = "UTF-8")

## Keep exact numeric values and provenance alongside the reader-facing table.
exact_csv <- file.path(out_dir, "Supplementary_Table_S13_exact_source_values.csv")
write.csv(dat, exact_csv, row.names = FALSE, fileEncoding = "UTF-8")

note <- c(
  "补充表S13 采用替代 SPP1-TAM 标志基因定义的敏感性分析。",
  "",
  "8基因行是冻结的原始比较指标，包括 SPP1、PPARG、ADM、MARCO、VEGFA、VCAN、CXCL8 和 ANGPTL4；评分采用 log1p(CP10K) 表达的非加权均值，不进行事后标准化。",
  "5基因行是替代的 macrophage-specific 定义，包括 PLAUR、SLC11A1、BRI3、FBP1 和 C15orf48；每个基因在 GSE245552 细胞层面进行 z 标准化后，取非加权均值 z-score。",
  "发现队列相关性为 12,433 个 GSE178318 发现队列髓系细胞的描述性结果。对每一种 comparator 分别在全部 164 个 patient × tissue × state 单元上拟合 P1_full ~ comparator + conventional myeloid state，随后在状态内进行 primary tumor 与 liver metastasis 配对，并对每位患者的可用状态取均值。",
  "置信区间基于 10,000 次患者 bootstrap；方向性采用 10,000 次双侧患者层 Monte Carlo sign-flip 重采样，并使用 plus-one 经验 P 值校正。表中数值四舍五入至小数点后六位；精确源值保存在 Supplementary_Table_S13_exact_source_values.csv 中。",
  "5基因分支属于替代定义敏感性分析，不替代冻结的 8 基因比较指标。"
)
writeLines(note, file.path(out_dir, "Supplementary_Table_S13_note.txt"), useBytes = TRUE)

cat("Wrote:\n", out_csv, "\n", exact_csv, "\n", sep = "")
cat(paste(capture.output(print(display, row.names = FALSE)), collapse = "\n"), "\n")
