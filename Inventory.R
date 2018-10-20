library(data.table)
library(dplyr)
library(rJava)
library(openxlsx)
library(sqldf)

############################################################################
# Function to report the univariate stats for all the variable in the file #
############################################################################
proc_contents <- function(d) {
  do.call(rbind, lapply( d, function(u)
    data.frame(
      Type      = class(u)[1],
      N         = sum(!is.na(u)),
      Ndistinct = length(unique(u)),
      Nmiss     = sum(is.na(u)),
      Min       = if(is.numeric(u)) min(u, na.rm=TRUE) else NA,
      Mean      = if(is.numeric(u)) mean(u, na.rm=TRUE) else NA,
      Median    = if(is.numeric(u)) median(u, na.rm=TRUE) else NA,
	    Stdev     = if(is.numeric(u)) sd(u, na.rm=TRUE) else NA,
	    P1        = if(is.numeric(u)) quantile(u, prob= .01, na.rm=TRUE) else NA,
	    P25       = if(is.numeric(u)) quantile(u, prob= .25, na.rm=TRUE) else NA,
	    P50       = if(is.numeric(u)) quantile(u, prob= .50, na.rm=TRUE) else NA,
	    P75       = if(is.numeric(u)) quantile(u, prob= .75, na.rm=TRUE) else NA,
	    P99       = if(is.numeric(u)) quantile(u, prob= .99, na.rm=TRUE) else NA,
	    Max       = if(is.numeric(u)) max(u, na.rm=TRUE) else NA
      
    )    
  ) )
  
}

############################################################################
# Function to report the frequency table for all the non numeric variables #
############################################################################

temp_var <- function(d) {
  as.character(filter(setDT(do.call(rbind, lapply( d, function(u)
    data.frame(Type = class(u)[1]))),keep.rownames = TRUE),!(Type %in% c("numeric","integer")))$rn)
}

proc_freq <- function(d) {
  
  varlist <- temp_var(d)
  do.call(rbind, lapply( d[varlist], function(u)
    data.frame(table(u,useNA = "always"))))
    
}


inventory <- function(d,file) {
  freq1 <- proc_freq(d)
  freq1$variable <- row.names(freq1)
  freq1$variable<-gsub("\\..*","",freq1$variable)
  freq1 <- dplyr::rename(freq1,values=u)
  freq1 <- freq1[c(3,1,2)]
  
  contents1 <- proc_contents(d)
  
	wb = createWorkbook()

	addWorksheet(wb, "contents")

	writeDataTable(wb, sheet = "contents", x = contents1,rowNames = TRUE)

	addWorksheet(wb, "Category Pivot")

	writeDataTable(wb, sheet = "Category Pivot", x = freq1,rowNames = FALSE)

	saveWorkbook(wb, file)
  
}
