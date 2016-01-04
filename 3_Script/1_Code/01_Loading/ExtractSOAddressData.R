ExtractSOAddressData <- function(data,
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
  
  functionName <- "ExtractSOAddressData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    conn <- dbConnect(MySQL(), username = user,
                      password = password, host = server, port = 3306,
                      client.flag = 0)
    
    rowCountQuery <-
      paste0("SELECT COUNT(*) FROM oms_live.ims_sales_order_address address
             WHERE 
             (
             address.updated_at between '", dateBegin, "' and '", dateEnd,"'
             )")
    
    rs <- dbSendQuery(conn, rowCountQuery)
    rowCount <- dbFetch(rs, n=-1)
    rowCount <- rowCount[1,1]
    
    sellerQuery <- 
      paste0("SELECT
                id_sales_order_address,
                address1,
                address2,
                ward,
                company,
                city,
                customer_address_region_name,
                postcode,
                fk_country,
                created_at,
                updated_at,
                fk_customer_address_region,
                po_box
             FROM oms_live.ims_sales_order_address address
             WHERE 
             (
             address.updated_at between '", dateBegin, "' and '", dateEnd,"'
             )
             ORDER BY address.updated_at")
    
    flog.info(paste("Function", functionName, "Data rows: ", rowCount), name = reportName)
    rs <- dbSendQuery(conn, sellerQuery)
    pb <- txtProgressBar(min=0, max=max(rowCount,1), style = 3)
    iProgress <- 0
    setTxtProgressBar(pb, iProgress)
    
    rowFetched <- 0    
    while (rowFetched < rowCount) {
      temp <- dbFetch(rs, n = batchSize)
      rowFetched <- rowFetched + batchSize
      if (is.null(data)) {
        data <- temp
      } else {
        data <- rbind(data,temp)
      }
      
      iProgress <- rowFetched
      setTxtProgressBar(pb, iProgress)
    }
    
    cat("\r\n")
    print(nrow(data))
    dbClearResult(rs)
    rm(temp)
    
    data
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    dbDisconnect(conn)
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}






