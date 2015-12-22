ExtractPackageData <- function(packageData, 
                               server, username, password, dateBegin, dateEnd,
                               batchSize = 200000) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(RMySQL)
    require(futile.logger)
  })
  
  functionName <- "ExtractPackageData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    flog.info(paste("Function", functionName, "Data rows before: ", nrow(packageData)), name = reportName)
    
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
             pkgDispatch.updated_at between '", dateBegin, "' and '", dateEnd,"'
             )")
    
    rs <- dbSendQuery(conn, rowCountQuery)
    rowCount <- dbFetch(rs, n=-1)
    rowCount <- rowCount[1,1]
    
    sellerQuery <- 
      paste0("SELECT 
  	           pkgItem.fk_sales_order_item,
               pkgDispatch.id_package_dispatching,
               pkgDispatch.created_at tracking_created_at,
               pkgDispatch.updated_at tracking_updated_at,
               pkgDispatch.tracking_number, 
               pkg.package_number, 
               deliveryCompany.shipment_provider_name
               FROM oms_live.oms_package_item pkgItem
               INNER JOIN oms_live.oms_package pkg ON pkgItem.fk_package = pkg.id_package 
               INNER JOIN oms_live.oms_package_dispatching pkgDispatch ON pkg.id_package = pkgDispatch.fk_package 
               INNER JOIN oms_live.oms_shipment_provider deliveryCompany ON pkgDispatch.fk_shipment_provider = deliveryCompany.id_shipment_provider
               WHERE 
               (
               pkgDispatch.updated_at between '", dateBegin, "' and '", dateEnd,"'
               )
             ORDER BY pkgDispatch.updated_at")
    
    flog.info(paste("Function", functionName, "Data rows: ", rowCount), name = reportName)
    rs <- dbSendQuery(conn, sellerQuery)
    pb <- txtProgressBar(min=0, max=rowCount, style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    rowFetched <- 0    
    while (rowFetched < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      rowFetched <- rowFetched + batchSize
      if (is.null(packageData)) {
        packageData <- temp
      } else {
        packageData <- rbind(packageData,temp)
      }
      
      iProgress <- rowFetched
      setTxtProgressBar(pb, iProgress)
    }
    
    cat("\r\n")
    dbClearResult(rs)
    rm(temp)
    
    flog.info(paste("Function", functionName, "Data rows after: ", nrow(packageData)), name = reportName)
    
    packageData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, collapse = " - "), name = reportName)
  }, finally = {
    dbDisconnect(conn)
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}