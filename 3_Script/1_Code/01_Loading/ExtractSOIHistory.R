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
  
  functionName <- "ExtractsoiHis"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    flog.info(paste("Function", functionName, "Data rows before: ", nrow(soiHistoryData)), name = reportName)
    
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
              WHERE soihis.created_at BETWEEN '", dateBegin,"' AND '", dateEnd,"'
             ORDER BY soihis.created_at")
    
    
    flog.info(paste("Function", functionName, "Data rows: ", rowCount), name = reportName)
    rs <- dbSendQuery(conn, dataQuery)
    pb <- txtProgressBar(min=0, max=rowCount, style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    rowFetched <- 0    
    while (rowFetched < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      rowFetched <- rowFetched + batchSize
      if (is.null(soiHistoryData)) {
        soiHistoryData <- temp
      } else {
        soiHistoryData <- rbind(soiHistoryData,temp)
      }
      
      iProgress <- rowFetched
      setTxtProgressBar(pb, iProgress)
    }
    
    
    cat("\r\n")
    dbClearResult(rs)
    rm(temp)
    
    flog.info(paste("Function", functionName, "Data rows after: ", nrow(soiHistoryData)), name = reportName)
    
    soiHistoryData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
    
    NULL
  }, finally = {
    dbDisconnect(conn)
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}






