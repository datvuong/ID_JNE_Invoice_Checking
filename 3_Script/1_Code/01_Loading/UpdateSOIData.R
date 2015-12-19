UpdateSOIData <- function(currentSOIData, upToDate = Sys.Date(), 
                          server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdateSOIData"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractSOIData.R")
    
    hasHistoryData = TRUE
    upToDate <- as.Date(upToDate, format("%Y-%m-%d"))
    
    if (is.null(currentSOIData)) {
      hasHistoryData = FALSE
      curentLastDate = upToDate - 40
    } else {
      curentLastDate <- max(currentSOIData$item_created_at,
                            na.rm = TRUE)
    }
    
    newSOIData <- ExtractSOIData(server = serverIP, username = user, 
                                     password = password,
                                     dateBegin = curentLastDate, dateEnd = upToDate,
                                     batchSize = 25000)
    
    newSOIData %<>%
      mutate(item_created_at = as.POSIXct(item_created_at, "%Y-m-%d %H:%M:%S"))

    if (hasHistoryData) {
      newID <- newSOIData$id_sales_order_item
      currentSOIData %<>%
        filter(!(id_sales_order_item %in% newID))
      
      soiData <- rbind(currentSOIData, newSOIData)
      
    } else {
      soiData <- newSOIData
    }
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    soiData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}