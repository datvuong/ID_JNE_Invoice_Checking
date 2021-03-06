ExtractSOIData <- function(soiData,
                           server, username, password, 
                           dateBegin, dateEnd, batchSize = 10000) {
  
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(RMySQL)
    require(logging)
  })
  
  functionName <- "ExtractSOIData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    conn <- dbConnect(MySQL(), username = user,
                      password = password, host = server, port = 3306,
                      client.flag = 0)
    
    rowCountQuery <-
      paste0("SELECT
             COUNT(*)
             FROM 
  oms_live.ims_sales_order_item soi 
             INNER JOIN oms_live.ims_sales_order so ON soi.fk_sales_order = so.id_sales_order 
             INNER JOIN oms_live.ims_sales_order_item_status itemStatus ON soi.fk_sales_order_item_status = itemStatus.id_sales_order_item_status 
             LEFT JOIN screport.sales_order_item scsoi ON soi.id_sales_order_item = scsoi.src_id 
             LEFT JOIN screport.seller seller ON scsoi.fk_seller = seller.id_seller 
             WHERE 
             (
             soi.updated_at between '", dateBegin, "' and '", dateEnd,"'
             )")
    
    rs <- dbSendQuery(conn, rowCountQuery)
    rowCount <- dbFetch(rs, n=-1)
    rowCount <- rowCount[1,1]
    
    sellerQuery <- 
      paste0("SELECT
              so.order_nr,
              soi.id_sales_order_item, 
              soi.bob_id_sales_order_item, 
              soi.created_at item_created_at,
              soi.updated_at item_updated_at,
              if(
                soi.fk_marketplace_merchant is null, 
                'Retail', 'MP'
              ) business_unit, 
              so.payment_method, 
              soi.sku,
              soi.unit_price, 
              soi.paid_price, 
              soi.shipping_fee, 
              soi.shipping_surcharge, 
              itemStatus.name Item_Status, 
              soi.fk_marketplace_merchant,
              so.fk_sales_order_address_shipping
             FROM 
              oms_live.ims_sales_order_item soi 
              INNER JOIN oms_live.ims_sales_order so ON soi.fk_sales_order = so.id_sales_order 
              INNER JOIN oms_live.ims_sales_order_item_status itemStatus ON soi.fk_sales_order_item_status = itemStatus.id_sales_order_item_status 
             WHERE 
              (
                soi.updated_at between '", dateBegin, "' and '", dateEnd,"'
              )
             ORDER BY soi.updated_at")
    
    flog.info(paste("Function", functionName, "Data rows: ", rowCount), name = reportName)
    rs <- dbSendQuery(conn, sellerQuery)
    pb <- txtProgressBar(min=0, max=rowCount, style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    rowFetched <- 0    
    while (rowFetched < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      rowFetched <- rowFetched + batchSize
      if (is.null(soiData)) {
        soiData <- temp
      } else {
        soiData <- rbind(soiData,temp)
      }
      
      iProgress <- rowFetched
      setTxtProgressBar(pb, iProgress)
    }
    
    cat("\r\n")
    print(nrow(soiData))
    dbClearResult(rs)
    rm(temp)
    
    soiData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    dbDisconnect(conn)
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}






