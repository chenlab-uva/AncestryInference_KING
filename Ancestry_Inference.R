rm(list=ls(all=TRUE))

library(e1071)
options(scipen = 999)

args = commandArgs(TRUE)
if( length(args) != 3 ) stop("please provide two arguments (PC file, reference population file and prefix)")
pcfile <- args[1]
popref <- args[2]
prefix <- args[3]

pc <- read.table(pcfile, header = TRUE)
phe <- read.table(popref, header = TRUE, stringsAsFactors = FALSE)
refID <- pc[pc$AFF==1,c("FID","IID")]
popID <- phe[,c("FID","IID")]

if (nrow(refID)!=nrow(popID)) stop ("Please keep the same order for Samples from Reference file and  Pop reference file")
if (all(refID!=popID)) stop ("Please keep the same order for Samples from Reference file and  Pop reference file")
Population <- c(as.character(phe$Population), rep(NA, (nrow(pc) - nrow(phe))))

dat <- cbind(pc, Population)
dat$fold <- 0
set.seed(123)
dat$fold[!is.na(dat$Population)] <- sample(1:5, sum(!is.na(dat$Population)), replace = T)
numpc <- length(grep("PC", colnames(pc)))
numpc <- ifelse(numpc >= 10, 10, numpc)
svm.mod <- as.formula(paste0("Population~", paste0("PC", 1:numpc, collapse = "+")))
best.set <- c(-2, 0)
step.mat <- cbind(c(3,3), c(2,2), c(1,1))
para.one <- function(x) {
  fold.index <- para[x, "fold"]
  mod.svm <- svm(svm.mod, data = dat[dat$fold != fold.index, ], kernel = "radial", 
                 gamma = 10^para[x, "gamma"], cost = 10^para[x, "cost"], fitted = F)
  pred.svm <- predict(mod.svm, newdata = dat[dat$fold == fold.index, ])
  return(sum(pred.svm == dat[dat$fold == fold.index, "Population"]))}
for (i in 1:2) {
  index <- dat$fold != 0
  best.count <- 0
  para.list <- NULL
  for (j in 2:ncol(step.mat)) {
    val1 <- best.set - step.mat[, j - 1]
    val2 <- best.set + step.mat[, j - 1]
    gamma.init <- seq(val1[1], val2[1], by = step.mat[1, j])
    cost.init <- seq(val1[2], val2[2], by = step.mat[2, j])
    para.set <- cbind(gamma = gamma.init, cost = rep(cost.init, each = length(gamma.init)))
    para.all <- paste0(para.set[, 1], "_", para.set[, 2])
    para.set <- para.set[!para.all %in% para.list, ]
    para.list <- para.all
    para = cbind(fold = rep(1:5, nrow(para.set)), gamma = rep(para.set[, "gamma"], 5), cost = rep(para.set[, "cost"], 5), count = NA)
    para <- as.data.frame(para)
    if (require("doParallel", quietly = TRUE)) {
      registerDoParallel(cores = 96)
      results <- foreach(para.index = 1:nrow(para), .combine = c) %dopar% {
        para.one(para.index)}
    } else {
      results <- sapply(1:nrow(para), para.one)}
    para[, "count"] <- unlist(results)
    results <- aggregate(count ~ cost + gamma, para, sum)
    results <- results[order(results$cost, results$gamma), ]
    best.para <- results[which.max(results$count), ]
    if (max(results$count) > best.count) {
      best.set <- unlist(best.para[, c("gamma", "cost")])
      best.count <- max(results$count)}
  }
  mod_svm <- svm(formula = svm.mod, data = dat[index, ], kernel = "radial", gamma = 10^best.set[1], 
                 cost = 10^best.set[2], probability = T, fitted = T)
  pred_svm <- predict(mod_svm, newdata = dat[, paste0("PC", 1:numpc)], probability = T)
  suspi_pop <- index & pred_svm != dat$Population
  if (sum(suspi_pop) == 0) {
    break
  } else {
    dat$fold[suspi_pop] <- 0
    set.seed(123)
    dat$fold[dat$fold != 0] <- sample(1:5, sum(dat$fold != 0), replace = T)
    step.mat <- step.mat[, -1]
  }
}
class.prob <- attr(pred_svm, "probabilities")
print(paste("Prepare the summary file, starts at", date()))
anc.sum <- function(v) {
  v.whichmax <- which.max(v)
  v2.whichmax <- which.max(v[-v.whichmax])
  v.2ndwhichmax <- v2.whichmax + (v2.whichmax>=v.whichmax)
  c(v.whichmax, v[v.whichmax], v.2ndwhichmax, v[v.2ndwhichmax])
}
valid <- dat[,"AFF"]==2
class.prob.valid <- class.prob[valid,]
maxed <- apply(class.prob.valid, 1, anc.sum)
popcount <- ncol(class.prob)
popnames <- colnames(class.prob)
Ancestry.1 <- popnames[maxed[1,]]
pred_class <- Ancestry.1
Pr.1 <- maxed[2,]
for(i in 1:length(Pr.1)) if(Pr.1[i]<=0.65){
  x <- sort(class.prob.valid[i,], decreasing=TRUE)
  temp <- (1:popcount)[cumsum(x)>0.65][1]
  pred_class[i] <- paste(names(x)[1:temp], collapse=";")}
pred.out <- cbind(dat[valid, c("FID", "IID", "PC1", "PC2")], Ancestry.1, round(Pr.1,4),popnames[maxed[3,]], round(maxed[4,],4), pred_class)
colnames(pred.out) <- c("FID", "IID", "PC1", "PC2", "Anc_1st", "Pr_1st", "Anc_2nd",  "Pr_2nd", "Ancestry")
print(paste("summary file is ready ", date()))
write.table(pred.out, paste0(prefix, "_InferredAncestry.txt"), sep = "\t", quote = FALSE, row.names = FALSE)
print(paste("Results are saved to", paste0(prefix, "_InferredAncestry.txt"), date()))
print(paste("Generate plots", date()))
pred.out$Ancestry <- as.character(pred.out$Ancestry)
pred.out$Ancestry[grep(";", pred.out$Ancestry)] <- "Missing"
Palette <- c("#1F78B4", "#33A02C", "#E31A1C", "#FF7F00", "#6A3D9A", "#B15928", "#A6CEE3", 
             "#B2DF8A", "#FB9A99", "#FDBF6F", "#CAB2D6", "#FFFF99", "#999999")
train.phe <- dat[dat$AFF == 1, ]
train.groups <- unique(train.phe$Population)
pred.colors <- rep(Palette[13], nrow(pred.out))
for (i in 1:length(train.groups)) {
  pred.colors[pred.out$Ancestry == train.groups[i]] <- Palette[i]
}
train.colors <- rep(0, nrow(train.phe))
for (i in 1:length(train.groups)) {
  train.colors[train.phe$Population == train.groups[i]] <- Palette[i]
}
x.adjust <- (max(train.phe$PC1, pred.out$PC1) - min(train.phe$PC1, pred.out$PC1))/10
x.low <- min(train.phe$PC1, pred.out$PC1) - x.adjust
x.high <- max(train.phe$PC1, pred.out$PC1) + x.adjust
y.adjust <- (max(train.phe$PC2, pred.out$PC2) - min(train.phe$PC2, pred.out$PC2))/10
y.low <- min(train.phe$PC2, pred.out$PC2) - y.adjust
y.high <- max(train.phe$PC2, pred.out$PC2) + y.adjust
png(paste0(prefix, "_ancestryplot.png"), width=854, height=480)
ncols <- min(3, ceiling(length(unique(pred.out$Ancestry))/2))
if ("Missing" %in% unique(pred.out$Ancestry)) {
  legend.group <- c(sort(unique(pred.out$Ancestry)[unique(pred.out$Ancestry) != "Missing"]), "Missing")
  all.color <- unique(pred.colors)[order(unique(pred.out$Ancestry))]
  legend.color <- c(all.color[!all.color %in% c("#999999")], "#999999")
} else {
  legend.group <- sort(unique(pred.out$Ancestry))
  legend.color <- unique(pred.colors)[order(unique(pred.out$Ancestry))]
}
if (!require(ggplot2, quietly = TRUE)) {
  par(mfrow = c(2, ncols))
  for (i in legend.group) {
    subdata <- subset(pred.out, Ancestry == i)
    plot(subdata$PC1, subdata$PC2, col = unique(pred.colors)[unique(pred.out$Ancestry) == i], 
         xlim = c(x.low, x.high), ylim = c(y.low, y.high), xlab = "PC1", ylab = "PC2", 
         main = paste0(i, " (N=", nrow(subdata), ")"))
  }
} else {
  labels <- sapply(legend.group, function(x) paste0(x, " (N=", sum(pred.out$Ancestry == x), ")"))
  p <- ggplot(pred.out, aes(x = PC1, y = PC2, colour = factor(Ancestry, levels = legend.group))) + 
    scale_color_manual(values = legend.color) + theme(legend.position = "none")
  p <- p + geom_point() + xlim(x.low, x.high) + ylim(y.low, y.high) + 
    facet_wrap(~factor(Ancestry, levels = legend.group, labels = labels), ncol = min(3, ncols))
  print(p)
}
dev.off()
rm(list=ls(all=TRUE))
