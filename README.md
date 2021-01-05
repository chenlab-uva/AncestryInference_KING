# Ancestry-Inference

This repository is for ancestry inference.
Here we implement a support-vector-machine(SVM)-based method to identify the most likely ancestral group(s) for an individual by leveraging known ancestry in a reference dataset (e.g., the 1000 Genomes Project data).


# File format
PC file: FID IID PC1 PC2 ... PC10

Popref file: FID IID Population

# Quickstart

Download KING from http://people.virginia.edu/~wc9c/KING/Download.htm


Get PCs from KING PCA projection 
```{bash}
king -b reference,studydata --pca --projection --popref example_popref.txt --rplot
king -b reference,studydata --pca --projection --rplot --pngplot
```

Run R code for ancestry inference with PC file (examplepc.txt) and popref file (example_popref.txt).
```{bash}
Rscript Ancestry_Inference.R examplepc.txt example_popref.txt example
```
