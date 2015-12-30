UpdateSOIData <- function(dateBegin = NULL, extractLength = 10,
                          server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdateSOIData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractSOIData.R")
    
    if (file.exists("1_Input/RData/soiData.RData")) {
      load("1_Input/RData/soiData.RData")
    } else {
      soiData <- NULL
    }
    
    if (is.null(dateBegin)) {
      if (is.null(soiData)) {
        dateBegin <- Sys.Date() - 190
      } else {
        soiData %<>%
          mutate(item_updated_at = as.POSIXct(item_updated_at, "%Y-m-%d %H:%M:%S"))
        
        dateBegin <- max(soiData$item_updated_at)
      }
    }
    dateBegin <- as.Date(dateBegin, format = "%Y-%m-%d")
    dateEnd <- min(dateBegin + extractLength, Sys.Date())
    
    flog.info(paste("Function", functionName, "Update Data Up to", dateEnd), name = reportName)
    
    soiData <- ExtractSOIData(soiData,
                              server = serverIP, username = user, 
                              password = password,
                              dateBegin = dateBegin, dateEnd = dateEnd,
                              batchSize = 200000)
    
    soiData %<>%
      mutate(item_created_at = as.POSIXct(item_created_at, "%Y-m-%d %H:%M:%S"),
             item_updated_at = as.POSIXct(item_updated_at, "%Y-m-%d %H:%M:%S"))
    
    latestUpdatedTime <- as.Date(max(soiData$item_updated_at))
    soiData %<>%
      filter(item_updated_at >= as.POSIXct(latestUpdatedTime - 190))
    
    soiData %<>%
      arrange(desc(item_updated_at)) %>%
      filter(!duplicated(id_sales_order_item))
    
    save(soiData, file = "1_Input/RData/soiData.RData",
         compress = TRUE)
    
    soiData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}