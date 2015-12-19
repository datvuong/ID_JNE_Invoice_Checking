UpdateSOIHistoryData <- function(dateBegin = NULL,
                                 server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdateSOIHistoryData"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractSOIHistory.R")
    
    if (file.exists("1_Input/RData/soiHistoryData.RData")) {
      load("1_Input/RData/soiHistoryData.RData")
    } else {
      packageData <- NULL
    }
    
    if (is.null(dateBegin)) {
      if (is.null(soiHistoryData)) {
        dateBegin <- Sys.Date() - 40
      } else {
        soiHistoryData %<>%
          mutate(created_at = as.POSIXct(created_at, "%Y-m-%d %H:%M:%S"))
        
        dateBegin <- max(soiHistoryData$created_at)
      }
    }
    
    dateBegin <- as.Date(dateBegin, format = "%Y-%m-%d")
    dateEnd <- min(dateBegin + 10, Sys.Date())
    
    loginfo(paste("Function", functionName, "Update Data Up to", dateEnd), logger = consoleLog)
    soiHistoryData <- ExtractSOIHistory(soiHistoryData,
                                        server = serverIP, username = user, 
                                        password = password,
                                        dateBegin = dateBegin, dateEnd = dateEnd,
                                        batchSize = 500000)
    
    soiHistoryData %<>%
      mutate(created_at = as.POSIXct(created_at, "%Y-m-%d %H:%M:%S"),
             updated_at = as.POSIXct(updated_at, "%Y-m-%d %H:%M:%S"))
    
    soiHistoryData %<>%
      arrange(desc(created_at)) %>%
      filter(!duplicated(id_sales_order_item_status_history))
    
    latestUpdatedTime <- as.Date(max(soiHistoryData$created_at))
    soiHistoryData %<>%
      filter(created_at >= (latestUpdatedTime - 190))
    
    save(soiHistoryData, file = "1_Input/RData/soiHistoryData.RData",
         compress = TRUE)
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    soiHistoryData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}