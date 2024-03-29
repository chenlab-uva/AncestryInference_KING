# Ancestry-Inference

This repository is for ancestry inference.
Here we implement a support-vector-machine(SVM)-based method to identify the most likely ancestral group(s) for an individual by leveraging known ancestry in a reference dataset (e.g., the 1000 Genomes Project data).

## Referece
We prepared three reference datasets. <br/>
- KGRef: cleaned 1000 genome with five super population groups (AFR,EUR, EAS, SAS and AMR). <br/>
- KGeurref: cleaned EUR samples from 1000 genome. They are NEUR, SEUR and FIN. <br/>
- HGDP_AsianRef: cleaned asian samples from HGDP. They are Central_South_Asia, Est_Asia and Middle_Est. <br/>

Related files are saved at https://www.dropbox.com/sh/fanfst7lyc1kn9u/AAAPyJhwiYdHc8H-31I-xbZua?dl=0 <br/>
After clicking the DropBox link, please click the Download button at the top right corner to download files. <br/>
Use unzip to unzip Reference.zip file.
```{bash}
unzip Refernece.zip
```
Then use unxz to unzip xzipped files.
For example  <br/>
```{bash}
unxz KGeurref.bed.xz
```


## File format
PC file: a text file with header line. It requires the following columns: FID, IID, AFF, PC1, PC2, PC3,...,PC10. <br/>
- FID: Family ID <br/> 
- IID: Within-family ID <br/>
- AFF code ('1' = Reference Sample, '2' = Studay Sample) <br/>
- PC: PCs inforamtion. Study samples will be projected to the reference PC space. <br/>

Example PCs file from KING. FA, MO and SEX columns are not required for the analysis.
```{bash}
FID IID FA MO SEX AFF PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9 PC10
HG00096 HG00096 0 0 0 1 0.0110 -0.0271 0.0098 0.0198 -0.0017 -0.0097 -0.0003 0.0010 0.0031 -0.0152
HG00097 HG00097 0 0 0 1 0.0107 -0.0275 0.0090 0.0189 -0.0008 -0.0097 -0.0012 -0.0014 -0.0024 -0.0245
HG00099 HG00099 0 0 0 1 0.0111 -0.0276 0.0102 0.0183 -0.0025 -0.0151 0.0014 0.0079 -0.0090 -0.0121
```

Popref file: a text file with header line. It would contain three columns. They are FID, IID and Population. Users need to creat this file before the analysis.
```{bash}
FID IID Population
HG00096 HG00096 EUR
HG00097 HG00097 EUR
HG00099 HG00099 EUR
```

## Quickstart

Download KING from https://www.kingrelatedness.com/Download.shtml


Get PCs from KING PCA projection. The affection status (6th column) in study fam file need to be 2. The referecen's affection status is 1 or missing. Nothing is required if the reference is KGref.

```{bash}
king -b KGref,studydata --pca --projection --prefix example
```

Run R code for ancestry inference. Three arguments are required. They are PC file(examplepc.txt), popref file(example_popref.txt) and prefix(example).
Package 'e1071' is required. Package 'ggplot2' and package 'doParallel' are optional.
```{bash}
Rscript Ancestry_Inference.R examplepc.txt example_popref.txt example
```

Also, we can run ancestry inference in KING from binary file with one command line.
```{bash}
king -b KGref,studydata --pca --projection --pngplot
```

## European only inference 
Keep European samples only.
Get PCs from KING PCA projection.
```{bash}
king -b KGeurref,EurStudy --pca --projection --prefix EurStudy
```
Run R code the get the ancestry inference results. Three arguments are required. They are pc file, popref file and prefixname. Please keep the order.
```{bash}
Rscript Ancestry_Inference.R EurStudypc.txt KGeurref_popref.txt prefixname
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
<img src="https://github.com/chenlab-uva/AncestryInference_KING/blob/main/output/example_ancestryplot.png" width="854" height="480">


## Interactive plots for ancestry inference results.
Run the following R code in R to get interactive plots. Package 'shiny' and 'ggplot2' are required. Related R files are saved at Rshiny folder. <br/> 
Please upload a text file with ancestry information. Three columns are required. They are PC1, PC2 and Ancestry.

```{bash}
library(shiny)
runGitHub("AncestryInference_KING", "chenlab-uva", ref = "main", subdir = "Rshiny")
```
We will see study samples' PC1 and PC2 information after we upload the *InferredAncestry txt file.
<img src="https://github.com/chenlab-uva/AncestryInference_KING/blob/main/output/viewAncestry_1.png" width="854" height="480">

The second plot (interactive plot) only show samples from the choosen ancestry group.
<img src="https://github.com/chenlab-uva/AncestryInference_KING/blob/main/output/viewAncestry_2.png" width="854" height="480">

Detailed information will be listed if we are clicking the dots from the interactive plot.
<img src="https://github.com/chenlab-uva/AncestryInference_KING/blob/main/output/viewAncestry_3.png" width="854" height="480">

Also, we can type a family ID that we are interested in and see samples' detailed information.
<img src="https://github.com/chenlab-uva/AncestryInference_KING/blob/main/output/viewAncestry_4.png" width="854" height="480">



## Reference
Manichaikul A, Mychaleckyj JC, Rich SS, Daly K, Sale M, Chen WM (2010) Robust relationship inference in genome-wide association studies. Bioinformatics 26(22):2867-2873

