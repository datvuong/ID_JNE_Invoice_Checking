loadRateCards <- function(rateCardFile){
    
    require(dplyr,quietly = TRUE)
    require(tools,quietly = TRUE)
    require(magrittr,quietly = TRUE)
    require(methods, quietly= TRUE)
    
    setClass("myNumeric")
    setAs("character","myNumeric", function(from) as.numeric(gsub(',','',from)))
    
    rateCard <- read.csv2(rateCardFile,
                              quote = '"',
                              col.names = c("Coding","City_District","Region",
                                            "Sub_District","City_Code","TARIF",
                                            "ETD","TARIF_YES","SS_1st_Kilo",
                                            "SS_Next_Kilo"),
                              colClasses = c("character","character","character",
                                             "character","character","myNumeric",
                                             "character","myNumeric","myNumeric",
                                             "myNumeric"))
    
    rateCard
}