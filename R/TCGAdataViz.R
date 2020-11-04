#' A function to download patient metadata from TCGA API and filter patients based on tumor_status field
#' @param url
#' @export

url="https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81"

getMetaData <- function(url){
  download.file(url, destfile = "tmp.xlsx", mode="wb")
  data = readxl::read_excel(path="tmp.xlsx", sheet= 1)[-1]
  filteredPatientsIdx = which(is.na(data[,"tumor_status"])  |
                              data[,"tumor_status"] == "[Discrepancy]" |
                              data[,"tumor_status"] == "[Not Available]")
  return(data[-filteredPatientsIdx,])
}


getDataViz <- function(metadata,
                       cancer_type=NULL,
                       patients=NULL,
                       metadata_col="",
                       metadata_levels = c(),
                       phenotype = "",
                       ){

  tmp = metadata %>% filter(type == "ACC" | type == "BLCA")
  p <- ggplot(data=tmp , aes(x=type, y=OS.time))
  p + geom_boxplot(aes(fill = type))
}

#test
metadata = getMetaData(url)
table(metadata[,"tumor_status"])

getDataViz(metadata, phenotype="OS.time")

require(dplyr)
require(ggplot2)
tmp = metadata %>% filter(type == "ACC" | type == "BLCA")
p <- ggplot(data=tmp , aes(x=type, y=OS.time))
p + geom_boxplot(aes(fill = type))
