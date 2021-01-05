# Ancestry-Inference

This repository is for ancestry inference.
Here we implement a support-vector-machine(SVM)-based method to identify the most likely ancestral group(s) for an individual by leveraging known ancestry in a reference dataset (e.g., the 1000 Genomes Project data).

## Quickstart

Download KING from http://people.virginia.edu/~wc9c/KING/Download.htm


Get PCs from KING PCA projection 
```{bash}
king -b reference,studydata --pca --projection --popref example_popref.txt --rplot
king -b reference,studydata --pca --projection --rplot --pngplot
```

