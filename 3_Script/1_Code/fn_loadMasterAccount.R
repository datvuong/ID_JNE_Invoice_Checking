loadMasterAccount <- function(masterAccountFile){
    
    require(dplyr,quietly = TRUE)
    require(tools,quietly = TRUE)
    require(magrittr,quietly = TRUE)
    require(methods, quietly= TRUE)
    
    setClass("myDate")
    setAs("character","myDate", function(from) as.POSIXct(substr(from,1,10), format="%Y-%m-%d"))
    
    
    masterAccount <- read.csv(masterAccountFile,
                              sep = ',', quote = '',
                              col.names = c("SC_Shortcode","Merchant","JNE_MP_Activation",
                                            "COD","Pick_up_by_LEX","Start_JNE_MP_Date",
                                            "Off_JNE_MP_Date"),
                              colClasses = c("character","character","factor",
                                             "factor","factor","myDate",
                                             "myDate"))
    
    masterAccount
}