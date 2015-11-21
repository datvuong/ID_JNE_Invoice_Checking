GeneratePackageData <- function(OMSData) {
  
  PackageData <- select(OMSData, order_nr, business_unit, payment_method,
                        unit_price,paid_price, shipping_fee, 
                        shipping_surcharge, Item_Status, RTS_Date,
                        Shipped_Date, Cancelled_Date, Delivered_Date,
                        tracking_number, shipment_provider_name,
                        Seller_Code, tax_class,
                        shipping_city, shipping_region)
  
  PackageData %<>%
    mutate(shipping_fee=ifelse(is.na(shipping_fee),0,shipping_fee)) %>%
    mutate(shipping_surcharge=ifelse(is.na(shipping_surcharge),0,shipping_surcharge))
  
  PackageDataSummarized <- PackageData %>% group_by(order_nr,tracking_number) %>%
    summarize(RTS_Date=last(RTS_Date),
              Shipped_Date=last(Shipped_Date),
              Cancelled_Date=last(Cancelled_Date),
              Delivered_Date=last(Delivered_Date),
              Total_unit_price=sum(unit_price),
              payment_method=last(payment_method),
              business_unit=last(business_unit),
              COD_Amount=sum(paid_price)+sum(shipping_fee)+sum(shipping_surcharge),
              shipment_provider_name=last(shipment_provider_name),
              Seller_Code=last(Seller_Code),
              tax_class=last(tax_class),
              shipping_city=last(shipping_city),
              shipping_region=last(shipping_region))
  PackageDataSummarized %<>%  ungroup()
  
  PackageDataSummarized
}