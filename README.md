# Ancestry-Inference

This repository is for ancestry inference.
Here we implement a support-vector-machine(SVM)-based method to identify the most likely ancestral group(s) for an individual by leveraging known ancestry in a reference dataset (e.g., the 1000 Genomes Project data).


## File format
PC file: a text file with header line. It would contain the following columns: FID, IID, PC1, PC2, PC3,...,PC10. <br/>
```{bash}
FID IID FA MO SEX AFF PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9 PC10
HG00096 HG00096 0 0 0 1 -0.0095 0.0280 0.0102 -0.0195 0.0022 0.0037 0.0018 0.0082 0.0023 0.0629
HG00097 HG00097 0 0 0 1 -0.0094 0.0280 0.0089 -0.0193 0.0027 0.0096 -0.0011 0.0038 0.0021 0.0182
HG00099 HG00099 0 0 0 1 -0.0097 0.0283 0.0098 -0.0175 0.0037 0.0116 -0.0024 0.0097 -0.0145 0.0608
```

Popref file: a text file with header line. It would contain three columns. They are FID, IID and Population.
```{bash}
FID IID Population
HG00096 HG00096 EUR
HG00097 HG00097 EUR
HG00099 HG00099 EUR
```

## Quickstart

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

Output file <br/>
- example_InferredAncestry.txt
```{bash}
FID	IID	PC1	PC2	Anc_1st	Pr_1st	Anc_2nd	Pr_2nd	Ancestry
1328	NA06984	-0.011	0.0268	EUR	0.9922	AFR	0.0044	EUR
1328	NA06989	-0.0104	0.0276	EUR	0.9955	AFR	0.0021	EUR
1330	NA12335	-0.0109	0.0267	EUR	0.991	AMR	0.0044	EUR
```

- PNG file <br/>
<img src="https://github.com/Zhennan-Z/Ancestry_Inference_PCA_Projection/blob/main/output/example_ancestryplot.png" width="427" height="240">

## Reference
Manichaikul A, Mychaleckyj JC, Rich SS, Daly K, Sale M, Chen WM (2010) Robust relationship inference in genome-wide association studies. Bioinformatics 26(22):2867-2873

