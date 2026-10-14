# CRLM R 代码发布包

本发布包包含冻结稿件对应的 R 分析流程、5 张主图脚本、补充图及敏感性分析脚本。它提供两种不同用途，请先按目标选择；**复现论文图片不需要从头重跑全部分析**。

| 目标 | 工作流程 | 所需输入 | 输出 |
|---|---|---|---|
| 根据冻结结果复现论文图片 | A | 本代码包、最终冻结结果包，以及 Figure 1 所需的主流程重跑输出 | 图片文件及各图对应的源数据审计表 |
| 根据 GEO 输入重新运行分析 | B | 本代码包及所需的外部 GEO 文件 | 重新生成的分析表、中间缓存和审计结果 |

流程 A 使用稿件冻结时的结果复现图片；流程 B 会重新计算分析结果。重跑结果不会自动替换冻结表格、图片或正文数值；若要替换，必须先完成结果核对。

## 流程 A：使用冻结结果复现论文图片

### 所需目录

1. 解压后的代码发布目录（即本目录）。
2. 最终冻结结果包，包含 `tables/` 和 `Figure2_source_data_addendum_20260912/`。
3. 主流程重跑结果目录，包含 `results/tables/`。Figure 1 从此处读取发现队列表格；部分补充脚本还需要其中的缓存。Figure 2–5 主要读取冻结结果包。
4. 一个独立且可写的图片输出目录。

如果所需冻结结果和重跑产物均已存在，复现图片不需要原始 GEO 矩阵。补充图可能另需输入；运行前请查看下文“补充与敏感性分析”及各脚本的文件检查。

### 配置路径

运行前显式设置路径。绘图流程使用 `config.R` 读取以下变量：

```r
Sys.setenv(
  CRLM_CODE_RELEASE_ROOT = "<本代码包解压目录>",
  CRLM_RESULTS_ROOT      = "<主流程重跑结果目录>",
  CRLM_FREEZE_DIR        = "<最终冻结结果包目录>",
  CRLM_OUTPUT_ROOT       = "<新的可写图片输出目录>"
)

source(file.path(Sys.getenv("CRLM_CODE_RELEASE_ROOT"), "config.R"))
```

`CRLM_RESULTS_ROOT` 下应有 `results/tables/`；`CRLM_FREEZE_DIR` 下应有最终 `tables/` 和 Figure 2 源数据补充目录。请将 `CRLM_OUTPUT_ROOT` 设在两个输入目录之外，避免覆盖冻结源数据。`CRLM_PRIMARY_RERUN_ROOT` 默认等于 `CRLM_RESULTS_ROOT`；只有补充分析输入另存他处时才需单独设置。

### 生成 5 张主图

配置路径后，在 R 或 RStudio 中运行：

```r
source(file.path(CRLM_CODE_RELEASE_ROOT, "scripts/figures/Figure1_CRLM_P1_actual.R"))
source(file.path(CRLM_CODE_RELEASE_ROOT, "scripts/figures/Figure2_external_scRNA_portability_v7.R"))
source(file.path(CRLM_CODE_RELEASE_ROOT, "scripts/figures/Figure3_CRLM_composition_activity.R"))
source(file.path(CRLM_CODE_RELEASE_ROOT, "scripts/figures/Figure4_CRLM_cross_state_SPP1.R"))
source(file.path(CRLM_CODE_RELEASE_ROOT, "scripts/figures/Figure5_spatial_organization_R.R"))
```

| 图片 | 脚本 | 主要输入 |
|---|---|---|
| Figure 1 | `scripts/figures/Figure1_CRLM_P1_actual.R` | 主流程重跑表格及冻结结果 |
| Figure 2 | `scripts/figures/Figure2_external_scRNA_portability_v7.R` | 冻结结果包及 Figure 2 源数据补充目录 |
| Figure 3 | `scripts/figures/Figure3_CRLM_composition_activity.R` | 冻结结果包 |
| Figure 4 | `scripts/figures/Figure4_CRLM_cross_state_SPP1.R` | 冻结结果包 |
| Figure 5 | `scripts/figures/Figure5_spatial_organization_R.R` | 冻结空间源数据补充目录 |

这些脚本只负责绘图：读取已有源表，不重新拟合科学模型。图文件及每图对应的源数据审计表写入 `CRLM_OUTPUT_ROOT`。如果缺少所需输入，脚本会报告具体缺失路径并停止，不会静默替换为其他文件。

## 流程 B：从 GEO 输入重跑分析

只有在需要重新计算分析时才使用此流程。本代码包不含 FASTQ 文件或 GEO 原始矩阵。

### 配置重跑路径

分析主流程使用另一组路径变量，与上面的绘图路径变量不同：

| 变量 | 用途 | 默认路径 |
|---|---|---|
| `CRLM_RERUN_DIR` | 重跑项目根目录 | 主流程脚本所在目录 |
| `CRLM_OUTPUT_DIR` | 新的分析输出目录 | `<CRLM_RERUN_DIR>/outputs/<流程版本>` |
| `CRLM_RAW_DIR` | 存放各 GEO 数据集目录的父目录 | `<CRLM_RERUN_DIR>/data/GEO_raw` |
| `CRLM_GSE178318_DIR` | GSE178318 输入目录 | `<CRLM_RAW_DIR>/GSE178318` |
| `CRLM_GSE245552_DIR` … `CRLM_GSE168933_DIR` | 可选的各数据集路径覆盖 | `CRLM_RAW_DIR` 下相应目录 |

示例：

```r
Sys.setenv(
  CRLM_CODE_RELEASE_ROOT = "<本代码包解压目录>",
  CRLM_RERUN_DIR = "<项目/输入根目录>",
  CRLM_OUTPUT_DIR = "<新的分析输出目录>",
  CRLM_RAW_DIR = "<包含 GEO 数据集子目录的目录>"
)

source(file.path(CRLM_CODE_RELEASE_ROOT,
                 "scripts/analysis/CRLM_methodologically_upgraded_rerun_v1.R"))
run_stage(0)  # 仅检查输入和路径，不执行分析阶段
```

GSE168933 映射阶段还需要一份基于该研究参考标签预先整理的冻结参考标记基因表；流程不会根据 P1 自行推断该映射。Stage 0 会检查必需输入和路径；开始分析前应先补齐报告中的缺失文件。

预检通过后，请按照主流程脚本末尾记载的推荐顺序逐阶段运行：

| 阶段 | 分析内容 |
|---|---|
| 0 | 仅预检输入和路径 |
| 1–2 | 发现队列导入、质控及按文库进行双细胞检测 |
| 3–5 | 全局图谱、谱系细分与状态注释、患者汇总及 NMF 输入矩阵 |
| 6–8 | 多随机种子 NMF、秩/稳定性选择、P1 对应审计与冻结 |
| 9–11 | 外部单细胞投影及方向一致性评估 |
| 12–13 | 空间投影/残差化、全局 Moran 指数和局部 High–High 统计 |
| 14、14b–18 | 补充稳健性、复杂度、匹配随机集、非恶性肝脏、空间及最终审计；按需运行 |

Stage 6（rank 4–8 的重复全矩阵 NMF 拟合）计算量最大，并支持检查点续跑。脚本被载入时不会自动运行所有阶段。不要盲目一次性启动全部阶段：后续审计可能需要额外输入，应仅在确实需要相应结果时运行。

## 补充与敏感性分析

- `scripts/analysis/CRLM_figure4A_state_specific_lmm.R` 基于冻结的 patient × tissue × state 汇总表，使用 `lmerTest`、`emmeans`、Satterthwaite 推断及 BH 校正，复现预设的状态特异性 LM−PT 对比。该脚本写入新表，不修改冻结结果。
- `scripts/sensitivity/CRLM_5gene_SPP1TAM_sensitivity.R` 是替代性的五基因比较分支，需要主流程重跑结果、冻结结果和 GSE245552 原始输入；它不会取代冻结的八基因比较结果或主图数据。
- `scripts/supplementary/build_supplementary_table_S13.R` 将已完成的五基因敏感性分析汇总格式化为补充表 S13。
- NMF 迭代深度脚本复现预设的 1,000 次及 rank-6 下 2,000 次迭代敏感性审计，不覆盖主分析 NMF 拟合。
- 补充图 S1–S6 位于 `scripts/supplementary/`。部分脚本除冻结结果包外还需要重跑缓存；运行前请查看脚本中的输入文件检查。

冻结的 SPP1 比较残差分析纳入 164 个完整的 patient × tissue × state 汇总单元。对每种比较指标，在汇总单元层拟合 `P1_full ~ comparator + state`；tissue 作为 LM–PT 对比标签保留，不作为残差协变量。残差在患者和状态内配对，并在患者层汇总。发布结果使用百分位数 bootstrap 区间（10,000 次患者重抽样的第 2.5 和 97.5 百分位数）及 10,000 次患者层 Monte Carlo 符号翻转；经验 P 值采用加一校正。

## 来源与命名

代码包包含 `code_release_manifest.csv`、流程与参数冻结记录、session 信息及 `CRLM_CODE_RELEASE_SCHEMA_MAP.csv`。部分冻结 CSV 列保留历史名称（如 `SPP1_TAM_published_2025`）以维持既有 SHA256 记录；面向读者的术语为“基于文献的 SPP1-TAM 标记评分”，映射见 schema map。未经重新生成并审核清单，不要重命名冻结源文件。

R 包版本和 session 信息保存在 `provenance/`。原始 GEO 数据及其他外部输入不包含在本代码包中。冻结输入和来源信息见 `provenance/FREEZE_README.txt`。
