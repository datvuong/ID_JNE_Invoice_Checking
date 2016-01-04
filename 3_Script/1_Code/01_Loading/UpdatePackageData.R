UpdatePackageData <- function(dateBegin = NULL, extractLength = 10,
                              server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(futile.logger)
  })
  
  functionName <- "UpdatepackageData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractPackageData.R")
    
    if (file.exists("1_Input/RData/packageData.RData")) {
      load("1_Input/RData/packageData.RData")
    } else {
      packageData <- NULL
    }
    
    if (is.null(dateBegin)) {
      if (is.null(packageData)) {
        dateBegin <- Sys.Date() - 190
      } else {
        packageData %<>%
          mutate(tracking_updated_at = as.POSIXct(tracking_updated_at, "%Y-m-%d %H:%M:%S"))
        
        dateBegin <- max(packageData$tracking_updated_at)
      }
    }
    
    dateBegin <- as.Date(dateBegin, format = "%Y-%m-%d")
    dateEnd <- min(dateBegin + extractLength, Sys.Date())
    
    flog.info(paste("Function", functionName, "Update Data", dateBegin, " => ", dateEnd), name = reportName)
    packageData <- ExtractPackageData(packageData,
                                      server = serverIP, username = user, 
                                      password = password,
                                      dateBegin = dateBegin, dateEnd = dateEnd,
                                      batchSize = 200000)
    
    
    packageData %<>%
      mutate(tracking_created_at = as.POSIXct(tracking_created_at, "%Y-m-%d %H:%M:%S"),
             tracking_updated_at = as.POSIXct(tracking_updated_at, "%Y-m-%d %H:%M:%S"))
    
    packageData %<>%
      arrange(desc(tracking_updated_at)) %>%
      filter(!duplicated(fk_sales_order_item))
    
    latestUpdatedTime <- as.Date(max(packageData$tracking_updated_at))
    packageData %<>%
      filter(tracking_updated_at >= as.POSIXct(latestUpdatedTime - 190))
    
    save(packageData, file = "1_Input/RData/packageData.RData",
         compress = TRUE)
    
    packageData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}