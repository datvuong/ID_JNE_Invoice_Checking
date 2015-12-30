UpdateSOIHistoryData <- function(dateBegin = NULL, extractLength = 10,
                                 server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(futile.logger)
  })
  
  functionName <- "UpdateSOIHistoryData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractSOIHistory.R")
    
    if (file.exists("1_Input/RData/soiHistoryData.RData")) {
      load("1_Input/RData/soiHistoryData.RData")
    } else {
      soiHistoryData <- NULL
    }
    
    if (is.null(dateBegin)) {
      if (is.null(soiHistoryData)) {
        dateBegin <- Sys.Date() - 190
      } else {
        soiHistoryData %<>%
          mutate(created_at = as.POSIXct(created_at, "%Y-m-%d %H:%M:%S"))
        
        dateBegin <- max(soiHistoryData$created_at)
      }
    }
    
    dateBegin <- as.Date(dateBegin, format = "%Y-%m-%d")
    dateEnd <- min(dateBegin + extractLength, Sys.Date())
    
    flog.info(paste("Function", functionName, "Update Data", dateBegin, " => ", dateEnd), name = reportName)
    soiHistoryData <- ExtractSOIHistory(soiHistoryData,
                                        server = serverIP, username = user, 
                                        password = password,
                                        dateBegin = dateBegin, dateEnd = dateEnd,
                                        batchSize = 400000)
    
    soiHistoryData %<>%
      mutate(created_at = as.POSIXct(created_at, "%Y-m-%d %H:%M:%S"),
             updated_at = as.POSIXct(updated_at, "%Y-m-%d %H:%M:%S"))
    
    soiHistoryData %<>%
      arrange(desc(created_at)) %>%
      filter(!duplicated(id_sales_order_item_status_history))
    
    latestUpdatedTime <- as.Date(max(soiHistoryData$created_at))
    soiHistoryData %<>%
      filter(created_at >= as.POSIXct(latestUpdatedTime - 190))
    
    save(soiHistoryData, file = "1_Input/RData/soiHistoryData.RData",
         compress = TRUE)
    
    soiHistoryData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
    
    NULL 
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}