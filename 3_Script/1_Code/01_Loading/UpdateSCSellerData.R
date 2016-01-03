UpdateSCSellerData <- function(server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdateSCSellerData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractSCSellerData.R")
    SCSellerData <- NULL
    
    SCSellerData <- ExtractSCSellerData(SCSellerData,
                              server = serverIP, username = user, 
                              password = password, batchSize = 200000)
    
    save(SCSellerData, file = "1_Input/RData/SCSellerData.RData",
         compress = TRUE)
    
    TRUE
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}