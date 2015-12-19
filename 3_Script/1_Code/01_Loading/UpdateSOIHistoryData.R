UpdateSOIHistoryData <- function(currentData, upToDate = Sys.Date(), 
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
    
    hasHistoryData = TRUE
    upToDate <- as.Date(upToDate, format("%Y-%m-%d"))
    
    if (is.null(currentData)) {
      hasHistoryData = FALSE
      curentLastDate = upToDate - 40
    } else {
      curentLastDate <- max(currentData$created_at,
                            na.rm = TRUE)
    }
    
    newHistoryData <- ExtractSOIHistory(server = serverIP, username = user, 
                                         password = password,
                                         dateBegin = curentLastDate, dateEnd = upToDate,
                                         batchSize = 25000)
    
    newHistoryData %<>%
      mutate(created_at = as.POSIXct(created_at, "%Y-m-%d %H:%M:%S"))
    
    if (hasHistoryData) {
      newID <- newHistoryData$id_sales_order_item_status_history
      currentData %<>%
        filter(!(id_sales_order_item_status_history %in% newID))
      
      historyData <- rbind(currentData, newHistoryData)
      
    } else {
      historyData <- newHistoryData
    }
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    historyData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}