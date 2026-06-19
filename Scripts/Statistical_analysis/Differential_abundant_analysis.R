rm(list = ls())
setwd("/home/jaume/Desktop/Project/R")

library(DESeq2)
library(dplyr)


counts <- read.csv("gene_counts.csv", row.names = 1, check.names = FALSE)
metadata <- read.csv("metadata.csv", row.names = 1)

counts <- counts[, rownames(metadata)]

# Analysis

dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = metadata,
                              design = ~ Condition)

keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

dds$Condition <- relevel(dds$Condition, ref = "Healthy")
dds <- DESeq(dds)

res_UC_Healthy <- results(dds, contrast=c("Condition", "Ulcerative_colitis", "Healthy"))
res_Chron_Healthy <- results(dds, contrast=c("Condition", "Chron", "Healthy"))

summary(res_UC_Healthy)
summary(res_Chron_Healthy)

res_ordered_UC <- res_UC_Healthy[order(res_UC_Healthy$padj), ]
res_ordered_Chron <- res_Chron_Healthy[order(res_Chron_Healthy$padj), ]

write.csv(as.data.frame(res_ordered_Chron), file="results_dif_analysis_Chron.csv")
write.csv(as.data.frame(res_ordered_UC), file="results_dif_analysis_UC.csv")


# ------------------------------------------------------------------------------------------

res_UC_df <- as.data.frame(res_UC_Healthy)

UC_up <- res_UC_df %>% filter(padj < 0.05 & log2FoldChange > 1)
UC_down <- res_UC_df %>% filter(padj < 0.05 & log2FoldChange < -1)

print(paste("Genes UP in UC:", nrow(UC_up)))
print(paste("Genes DOWN in UC:", nrow(UC_down)))


res_Chron_df <- as.data.frame(res_Chron_Healthy)

Chron_up <- res_Chron_df %>% filter(padj < 0.05 & log2FoldChange > 1)
Chron_down <- res_Chron_df %>% filter(padj < 0.05 & log2FoldChange < -1)

print(paste("Genes UP in UC:", nrow(Chron_up)))
print(paste("Genes DOWN in UC:", nrow(Chron_down)))

write.csv(as.data.frame(Chron_up), file="Chron_up.csv")
write.csv(as.data.frame(Chron_down), file="Chron_down.csv")

write.csv(as.data.frame(UC_up), file="UC_up.csv")
write.csv(as.data.frame(UC_down), file="UC_down.csv")
