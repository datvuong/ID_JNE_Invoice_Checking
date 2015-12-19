UpdateSOIBaseData <- function(soiData, packageData, soiHistoryData) {
suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "UpdateSOIBaseData"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    soiBasedData <- soiData %>%
      left_join(packageData, by = c("id_sales_order_item" = "fk_sales_order_item")) %>%
      left_join(soiHistoryData, by = c("id_sales_order_item" = "fk_sales_order_item"))
    
    soiBasedData %<>%
      select(order_nr, id_sales_order_item, bob_id_sales_order_item,
             SC_SOI_ID, business_unit, payment_method, sku,
             product_name, unit_price, paid_price, shipping_fee,
             shipping_surcharge, Item_Status, tracking_number, 
             package_number, shipment_provider_name, Seller_Code, Seller,
             tax_class, package_length, package_width, package_height,
             package_weight,
             RTS_Date = rts, 
             Shipped_Date = shipped,
             Cancelled_Date = cancelled,
             Delivered_Date = delivered)
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    soiBasedData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}