ExtractSOIHistory <- function(soiHistoryData,
                              server, username, password, dateBegin, dateEnd,
                              batchSize = 100000) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(RMySQL)
    require(logging)
  })
  
  functionName <- "ExExtractsoiHis"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    conn <- dbConnect(MySQL(), username = username,
                      password = password, host = server, port = 3306,
                      client.flag = 0)
    
    rowCountQuery <-
      paste0("SELECT
      	        COUNT(*)
              FROM oms_live.ims_sales_order_item_status_history soihis
              WHERE soihis.created_at BETWEEN '", dateBegin,"' AND '", dateEnd,"'")
    
    rs <- dbSendQuery(conn, rowCountQuery)
    rowCount <- dbFetch(rs, n=-1)
    rowCount <- rowCount[1,1]
    
    dataQuery <- 
      paste0("SELECT
      	        soihis.*
              FROM oms_live.ims_sales_order_item_status_history soihis
              WHERE soihis.created_at BETWEEN '", dateBegin,"' AND '", dateEnd,"'")
    
    
    print(rowCount)
    rs <- dbSendQuery(conn, dataQuery)
    pb <- txtProgressBar(min=0, max=rowCount, style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    rowFetched <- 0    
    while (rowFetched < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      rowFetched <- rowFetched + nrow(temp)
      if (is.null(soiHistoryData)) {
        soiHistoryData <- temp
      } else {
        soiHistoryData <- rbind(soiHistoryData,temp)
      }
      
      
      save(soiHistoryData, file = "1_Input/RData/soiHistoryData.RData",
           compress = TRUE)
      
      iProgress <- rowFetched
      setTxtProgressBar(pb, iProgress)
    }
    
    
    cat("\r\n")
    dbClearResult(rs)
    rm(temp)
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    assign("last.warning", NULL, envir = baseenv())
    soiHistoryData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    dbDisconnect(conn)
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}






