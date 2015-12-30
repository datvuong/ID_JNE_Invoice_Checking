ExtractSKUData <- function(server, username, password, 
                           batchSize = 200000) {
  
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(RMySQL)
    require(logging)
  })
  
  functionName <- "ExtractskuData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    conn <- dbConnect(MySQL(), username = user,
                      password = password, host = server, port = 3306,
                      client.flag = 0)
    
    rowCountQuery <-
      paste0("SELECT
              COUNT(*)
             FROM bob_live.catalog_simple bobsku
             INNER JOIN bob_live.catalog_config skuConfig ON bobsku.fk_catalog_config = skuConfig.id_catalog_config")
    
    rs <- dbSendQuery(conn, rowCountQuery)
    rowCount <- dbFetch(rs, n=-1)
    rowCount <- rowCount[1,1]
    
    sellerQuery <- 
      paste0("SELECT
                bobsku.sku,
                skuConfig.name product_name,
                skuConfig.package_length, 
                skuConfig.package_width, 
                skuConfig.package_height, 
                skuConfig.package_weight
            FROM bob_live.catalog_simple bobsku
            INNER JOIN bob_live.catalog_config skuConfig ON 
             bobsku.fk_catalog_config = skuConfig.id_catalog_config")
    
    flog.info(paste("Function", functionName, "Data rows: ", rowCount), name = reportName)
    rs <- dbSendQuery(conn, sellerQuery)
    pb <- txtProgressBar(min=0, max=rowCount, style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    skuData <- NULL
    rowFetched <- 0    
    while (rowFetched < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      rowFetched <- rowFetched + batchSize
      if (is.null(skuData)) {
        skuData <- temp
      } else {
        skuData <- rbind(skuData,temp)
      }
      
      iProgress <- rowFetched
      setTxtProgressBar(pb, iProgress)
    }
    
    cat("\r\n")
    print(nrow(skuData))
    dbClearResult(rs)
    rm(temp)
    
    skuData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    dbDisconnect(conn)
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}






