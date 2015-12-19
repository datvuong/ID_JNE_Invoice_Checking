BuildPackageData <- function(soiBasedData) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
  })
  
  functionName <- "BuildPackageData"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    PackageData <- soiBasedData %>%
      filter(!is.na(tracking_number)) %>%
      group_by(tracking_number) %>%
      mutate(itemsCount = n_distinct(id_sales_order_item)) %>%
      mutate(unitPrice = sum(unit_price)) %>%
      mutate(paidPrice = sum(paid_price)) %>%
      mutate(shippingFee = sum(shipping_fee)) %>%
      mutate(shippingSurcharge = sum(shipping_surcharge)) %>%
      mutate(skus = paste(sku, collapse = "/")) %>%
      mutate(skus_names = paste(product_name, collapse = "/")) %>%
      mutate(actualWeight = sum(package_weight)) %>%
      mutate(volumetricDimension = sum((package_length * package_width * package_height))) %>%
      mutate(Seller_Code = paste(Seller_Code, collapse = "/")) %>%
      mutate(Seller = paste(Seller, collapse = "/"))
    
    PackageData %<>%
      select(order_nr, tracking_number, package_number, itemsCount,
             unitPrice, paidPrice, shippingFee, shippingSurcharge,
             skus, skus_names, actualWeight, volumetricDimension, 
             payment_method, Seller_Code, Seller, tax_class,
             RTS_Date, Shipped_Date,
             Cancelled_Date, Delivered_Date) %>%
      filter(!duplicated(tracking_number))
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    PackageData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}