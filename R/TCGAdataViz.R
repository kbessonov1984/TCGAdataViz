#' A function to download patient metadata from TCGA API and filter patients based on tumor_status field
#' @param url as url to the data provided by the TCGA project
#' @return returns raw metadata downlaoded from TCGA resource
#' @export

getMetaData <- function(url="https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81"){
  download.file(url, destfile = "tmp.xlsx", mode="wb")
  data = readxl::read_excel(path="tmp.xlsx", sheet= 1)[-1]
  filteredPatientsIdx = which(is.na(data[,"tumor_status"])  |
                              data[,"tumor_status"] == "[Discrepancy]" |
                              data[,"tumor_status"] == "[Not Available]")
  return(data[-filteredPatientsIdx,])
}

#' TCGA metadata filtering and visualization by a boxplot binned by a cancer type.
#' Filtering is done based on patient ids or cancer typer
#' @param metadata metadata tibble downladed from getMetaData()
#' @param cancer_type  a list of cancer types to filter metadata on
#' @param patients list of TCGA patient ids in TCGA-XX-XXX format to filter metadata on
#' @param metadata_col optional name of the column as an extra dimension for comparison
#' @param metadata_levels optional list of categories to filter metadata_col on
#' @param phenotype name of the phenotype column to extract data from (the y axis of the boxplot)
#' @return filtered_meta
#' @export
getDataViz <- function(metadata,
                       cancer_type=NULL,
                       patients=c(),
                       metadata_col=NULL,
                       metadata_levels = c(),
                       phenotype = NULL
                       ){

  if(!is.null(cancer_type) && length(patients) > 0){
    stop("\'cancer_typer\' and \'patients\' can not be BOTH defined. Filter data on a single input parameter.Aborting ...")
  }

  if(!is.null(cancer_type)){
    filtered_meta = metadata %>% filter(type == cancer_type)
  }else if(length(patients)>0){
    cat("Filter by patients")
    filtered_meta  = metadata %>% filter(bcr_patient_barcode %in% patients)
  }else{
    stop("\'cancer_typer\' and \'patients\' input paramters are not defined. Please define either of them. Aborting ...")
  }

  #make a box plot on selected patients as a function of cancer type
  if(is.null(metadata_col)){
    p <- ggplot(data=filtered_meta  , aes_string(x="type", y=phenotype))
    p + geom_boxplot(aes(fill = type))+theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))
  }else{
    p <- ggplot(data=filtered_meta , aes_string(x=metadata_col, y=phenotype))
    p + geom_boxplot(aes(fill = type))+theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))
  }

  return(filtered_meta)
}

#' TCGA metadata statistical significance tests (regression and t-test) to compare patient variables in cancer groups
#' @param metadata as filtered or unfiltered tibble from getMetaData() or from getDataViz()
#' @param x_variable_name independent variable of the model (continuous or categorical)
#' @param y_variable_name dependent variable of the model (continuous or categorical)
#' @param analysis_name name of analysis (linear regression or a t-test)
#' @export
getDataAnalytics <- function(metadata,
                             x_variable_name,
                             y_variable_name,
                             analysis_name="regression"
                             ){
  cancer_types = names(table(metadata["type"]))
  if(analysis_name == "regression"){
    lm_fit=lm(as.formula(paste(y_variable_name, "~",x_variable_name)), data=metadata)
    summary(lm_fit)
  }else if(analysis_name =="t-test" &&  length(cancer_types) == 2){
   group1 =  metadata %>% filter(type == cancer_types[1]) %>% pull(x_variable_name)
   group2 =  metadata %>% filter(type == cancer_types[2]) %>% pull(x_variable_name)
   t.test(group1,group2)
  }else{
    stop("Analysis not defined or check spelling")
  }

}

