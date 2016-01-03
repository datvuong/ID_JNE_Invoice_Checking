UpdateSOAddressData <- function(dateBegin = NULL, extractLength = 10,
                                server, username, password) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdateSOAddressData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    source("3_Script/1_Code/01_Loading/ExtractSOAddressData.R")
    
    if (file.exists("1_Input/RData/SOAddressData.RData")) {
      load("1_Input/RData/SOAddressData.RData")
    } else {
      SOAddressData <- NULL
    }
    
    if (is.null(dateBegin)) {
      if (is.null(SOAddressData)) {
        dateBegin <- as.Date("2012-03-06")
      } else {
        SOAddressData %<>%
          mutate(updated_at = as.POSIXct(updated_at, "%Y-m-%d %H:%M:%S"))
        
        dateBegin <- max(SOAddressData$updated_at)
      }
    }
    
    dateBegin <- as.Date(dateBegin, format = "%Y-%m-%d")
    dateEnd <- min(dateBegin + extractLength, Sys.Date())
    
    flog.info(paste("Function", functionName, "Update Data", dateBegin, " => ", dateEnd), name = reportName)
    
    SOAddressData <- ExtractSOAddressData(SOAddressData,
                              server = serverIP, username = user, 
                              password = password,
                              dateBegin = dateBegin, dateEnd = dateEnd,
                              batchSize = 200000)
    
    SOAddressData %<>%
      mutate(created_at = as.POSIXct(created_at, "%Y-m-%d %H:%M:%S"),
             updated_at = as.POSIXct(updated_at, "%Y-m-%d %H:%M:%S"))
    
    latestUpdatedTime <- as.Date(max(SOAddressData$updated_at))

    SOAddressData %<>%
      arrange(desc(updated_at)) %>%
      filter(!duplicated(id_sales_order_address))
    
    save(SOAddressData, file = "1_Input/RData/SOAddressData.RData",
         compress = TRUE)
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}