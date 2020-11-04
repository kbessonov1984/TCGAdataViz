# TCGAdataViz package


The Cancer Genome Atlas ([TCGA](https://www.cancer.gov/about-nci/organization/ccg/research/structural-genomics/tcga)) is a useful public resource on cancer data. The `TCGAdataViz` package was created to conviniently download, filter and display most patient metadata from TCGA resource using R - a statistical language. 

The package has 3 core functions to: 1) download raw tabular metadata; 2) perform basic filtering 3) perform basic statistics (distributions, t-test, logistic regression) and visualize and report results on the key variables (tumor status, tumor stage, gender).

## Requirements
This package depends on other R packages to read Excel xlsx files, filter and plot data

* readxl
* dplyr
* ggplot2

## Functions
Following functions are part of this package
### getMetaData()
This function downloads raw metadata from TCGA source from the default [url](https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81). Funtion returns a filtered tibble data frame on `tumor_status` field

### getDataViz()
Further filters TCGA metadata dataframe based on user cancer type or patient id inputs and returns a filtered dataframe. The key inputs are `cancer_type` (e.g. ACC, BLCA) and `patients` (patient ids in TCGA-XX-XXX format). Function returns filtered metadata for further analytics 

### getDataAnalytics()
Performs linear regression and a t-test. The t-test performs tests on two cancer groups whereas linear regression model is more flexible. Function outputs significance of association between the inputs.


### Examples
Following example commands showcase package functions

```
#get metadata from TCGA server
metadata <- getMetaData()
#option 1: select and display data based on cancer type
meta4viz <- getDataViz(metadata, cancer_type = c("ACC","BLCA"), phenotype="OS.time")
#option 2: select and display data based on 100 patient ids
meta4viz <- getDataViz(metadata,patients = as.data.frame(metadata)[1:100,1], phenotype="OS.time")
#Get some stats on association significance between OS.time and cancer type a)regression; b) t-test
getDataAnalytics(meta4viz,y_variable_name="OS.time",x_variable_name="type")
getDataAnalytics(meta4viz,y_variable_name="type",x_variable_name="OS.time", analysis_name="t-test")
```