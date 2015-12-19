ExtractPackageData <- function(server, username, password, dateBegin, dateEnd,
                           batchSize = 10000) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(RMySQL)
    require(logging)
  })
  
  functionName <- "ExtractPackageData"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    conn <- dbConnect(MySQL(), username = user,
                      password = password, host = server, port = 3306,
                      client.flag = 0)
    
    rowCountQuery <-
      paste0("SELECT 
  	           COUNT(*)
             FROM oms_live.oms_package_item pkgItem
             INNER JOIN oms_live.oms_package pkg ON pkgItem.fk_package = pkg.id_package 
             INNER JOIN oms_live.oms_package_dispatching pkgDispatch ON pkg.id_package = pkgDispatch.fk_package 
             INNER JOIN oms_live.oms_shipment_provider deliveryCompany ON pkgDispatch.fk_shipment_provider = deliveryCompany.id_shipment_provider
             WHERE 
             (
             pkgDispatch.created_at between '", dateBegin, "' and '", dateEnd,"'
             )")
    
    rs <- dbSendQuery(conn, rowCountQuery)
    rowCount <- dbFetch(rs, n=-1)
    rowCount <- rowCount[1,1]
    
    sellerQuery <- 
      paste0("SELECT 
  	           pkgItem.fk_sales_order_item,
               pkgDispatch.id_package_dispatching,
               pkgDispatch.created_at tracking_created_at,
               pkgDispatch.tracking_number, 
               pkg.package_number, 
               deliveryCompany.shipment_provider_name
               FROM oms_live.oms_package_item pkgItem
               INNER JOIN oms_live.oms_package pkg ON pkgItem.fk_package = pkg.id_package 
               INNER JOIN oms_live.oms_package_dispatching pkgDispatch ON pkg.id_package = pkgDispatch.fk_package 
               INNER JOIN oms_live.oms_shipment_provider deliveryCompany ON pkgDispatch.fk_shipment_provider = deliveryCompany.id_shipment_provider
               WHERE 
               (
               pkgDispatch.created_at between '", dateBegin, "' and '", dateEnd,"'
               )")
    
    print(rowCount)
    rs <- dbSendQuery(conn, sellerQuery)
    pb <- txtProgressBar(min=0, max=rowCount, style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    soiHis <- dbFetch(rs, n = batchSize)
    iProgress <- nrow(soiHis)
    setTxtProgressBar(pb, iProgress)
    while (nrow(soiHis) < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      soiHis <- rbind(soiHis,temp)
      
      iProgress <- nrow(soiHis)
      setTxtProgressBar(pb, iProgress)
    }
    
    cat("\r\n")
    print(nrow(soiHis))
    dbClearResult(rs)
    rm(temp)
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    assign("last.warning", NULL, envir = baseenv())
    soiHis
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    dbDisconnect(conn)
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}