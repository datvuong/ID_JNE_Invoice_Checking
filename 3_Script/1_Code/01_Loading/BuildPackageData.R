BuildPackageData <- function(soiBasedData) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(futile.logger)
  })
  
  functionName <- "BuildPackageData"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    GetUniqueList <- function(list) {
      uniqueList <- unique(list)
      uniqueList
    }
    
    PackageData <- soiBasedData %>%
      filter(!is.na(tracking_number)) %>%
      group_by(tracking_number) %>%
      mutate(itemsCount = n_distinct(id_sales_order_item)) %>%
      mutate(paidPrice = sum(paid_price)) %>%
      mutate(shippingFee = sum(shipping_fee)) %>%
      mutate(shippingSurcharge = sum(shipping_surcharge)) %>%
      mutate(skus = paste(GetUniqueList(sku), collapse = "/")) %>%
      mutate(skus_names = paste(GetUniqueList(product_name), collapse = "/")) %>%
      mutate(actualWeight = sum(package_weight)) %>%
      mutate(volumetricDimension = sum((package_length * package_width * package_height))) %>%
      mutate(missingActualWeight = any(is.na(actualWeight))) %>%
      mutate(missingVolumetricDimension = any(is.na(volumetricDimension))) %>%
      mutate(Seller_Code = paste(GetUniqueList(Seller_Code), collapse = "/")) %>%
      mutate(Seller = paste(GetUniqueList(Seller), collapse = "/"))
    
    PackageData %<>%
      select(order_nr, tracking_number, package_number, itemsCount,
             paidPrice, shippingFee, shippingSurcharge,
             skus, skus_names, actualWeight, missingActualWeight,
             volumetricDimension, missingVolumetricDimension,
             shipment_provider_name, payment_method, 
             Seller_Code, Seller, tax_class, RTS_Date, 
             Shipped_Date, Cancelled_Date, Delivered_Date) %>%
      filter(!duplicated(tracking_number))
    
    PackageData
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}