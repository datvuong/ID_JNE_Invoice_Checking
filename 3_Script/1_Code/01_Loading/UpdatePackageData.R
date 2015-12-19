UpdatePackageData <- function(currentData, upToDate = Sys.Date(), 
                          server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdatepackageData"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractPackageData.R")
    
    hasHistoryData = TRUE
    upToDate <- as.Date(upToDate, format("%Y-%m-%d"))
    
    if (is.null(currentData)) {
      hasHistoryData = FALSE
      curentLastDate = upToDate - 40
    } else {
      curentLastDate <- max(currentData$tracking_created_at,
                            na.rm = TRUE)
    }
    
    newPackageData <- ExtractPackageData(server = serverIP, username = user, 
                                 password = password,
                                 dateBegin = curentLastDate, dateEnd = upToDate,
                                 batchSize = 25000)
    
    
    if (hasHistoryData) {
      newID <- newPackageData$id_package_dispatching
      currentData %<>%
        filter(!(id_package_dispatching %in% newID))
      
      packageData <- rbind(currentData, newPackageData)
      
    } else {
      packageData <- newPackageData
    }
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    packageData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}