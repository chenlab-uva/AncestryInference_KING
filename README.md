# Ancestry-Inference

This repository is for ancestry inference.
Here we implement a support-vector-machine(SVM)-based method to identify the most likely ancestral group(s) for an individual by leveraging known ancestry in a reference dataset (e.g., the 1000 Genomes Project data).


## File format
PC file: a text file with header line. It requires the following columns: FID, IID, AFF, PC1, PC2, PC3,...,PC10. <br/>
- FID: Family ID <br/> 
- IID: Within-family ID <br/>
- AFF code ('1' = Reference Sample, '2' = Studay Sample) <br/>
- PC: PCs inforamtion. Study samples will be projected to the reference PC space. <br/>

Example PCs file from KING. FA, MO and SEX columns are not required for the analysis.
```{bash}
FID IID FA MO SEX AFF PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9 PC10
HG00096 HG00096 0 0 0 1 -0.0095 0.0280 0.0102 -0.0195 0.0022 0.0037 0.0018 0.0082 0.0023 0.0629
HG00097 HG00097 0 0 0 1 -0.0094 0.0280 0.0089 -0.0193 0.0027 0.0096 -0.0011 0.0038 0.0021 0.0182
HG00099 HG00099 0 0 0 1 -0.0097 0.0283 0.0098 -0.0175 0.0037 0.0116 -0.0024 0.0097 -0.0145 0.0608
```

Popref file: a text file with header line. It would contain three columns. They are FID, IID and Population. Users need to creat this file before the analysis.
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
king -b reference,studydata --pca --projection --popref example_popref.txt --pngplot
```

Run R code for ancestry inference. Three arguments are PC file(examplepc.txt), popref file(example_popref.txt) and prefix(example)
```{bash}
Rscript Ancestry_Inference.R examplepc.txt example_popref.txt example
```

## Output file 
example_InferredAncestry.txt
```{bash}
FID	IID	PC1	PC2	Anc_1st	Pr_1st	Anc_2nd	Pr_2nd	Ancestry
2427	NA19919	-0.0299	0.0012	AFR	0.9973	AMR	0.0016	AFR
2425	NA19902	-0.0295	0.0008	AFR	0.997	AMR	0.0017	AFR
2484	NA20335	-0.0239	-0.0029	AFR	0.9954	AMR	0.0016	AFR
```

PNG file <br/>
<img src="https://github.com/Zhennan-Z/Ancestry_Inference_PCA_Projection/blob/main/output/example_ancestryplot.png" width="427" height="240">

## Reference
Manichaikul A, Mychaleckyj JC, Rich SS, Daly K, Sale M, Chen WM (2010) Robust relationship inference in genome-wide association studies. Bioinformatics 26(22):2867-2873

