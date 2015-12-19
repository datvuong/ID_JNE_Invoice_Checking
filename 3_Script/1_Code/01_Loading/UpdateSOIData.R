UpdateSOIData <- function(dateBegin = NULL, 
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
    
    if (file.exists("1_Input/RData/soiData.RData")) {
      load("1_Input/RData/soiData.RData")
    } else {
      soiData <- NULL
    }
    
    if (is.null(dateBegin)) {
      if (is.null(soiData)) {
        dateBegin <- Sys.Date() - 40
      } else {
        soiData %<>%
          mutate(item_updated_at = as.POSIXct(item_updated_at, "%Y-m-%d %H:%M:%S"))
        
        dateBegin <- max(soiData$item_updated_at)
      }
    }
    dateBegin <- as.Date(dateBegin, format = "%Y-%m-%d")
    dateEnd <- min(dateBegin + 10, Sys.Date())
    
    loginfo(paste("Function", functionName, "Update Data Up to", dateEnd), logger = consoleLog)
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
      filter(item_updated_at >= (latestUpdatedTime - 190))
    
    soiData %<>%
      arrange(desc(item_updated_at)) %>%
      filter(!duplicated(id_sales_order_item))
    
    save(soiData, file = "1_Input/RData/soiData.RData",
         compress = TRUE)
    
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