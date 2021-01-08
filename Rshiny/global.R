library(shiny)
library(ggplot2)
options(scipen = 999)
# global.R
ex_df <- read.table("example_InferredAncestry.txt", header = TRUE, stringsAsFactors = FALSE)
ex_df$Ancestry[grep(";", ex_df$Ancestry)] <- "Missing"

x.low <- min(ex_df$PC1)
x.high <- max(ex_df$PC1)
y.low <- min(ex_df$PC2)
y.high <- max(ex_df$PC2)

Palette <- c("#1F78B4", "#33A02C", "#E31A1C", "#FF7F00", "#6A3D9A", "#B15928", "#A6CEE3", 
             "#B2DF8A", "#FB9A99", "#FDBF6F", "#CAB2D6", "#FFFF99")
n <- length(unique(ex_df$Ancestry))
cols = Palette[1:n]
