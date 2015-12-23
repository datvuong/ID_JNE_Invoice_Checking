source("3_Script/1_Code/00_init.R")

tryCatch({
  
  flog.info("Initial Setup", name = reportName)
  
  source("3_Script/1_Code/01_Loading/Load_Invoice_Data.R")
  source("3_Script/1_Code/fn_loadRatecards.R")
  
  load("1_Input/RData/packageBaseData.RData")
  invoiceData <- LoadInvoiceData("1_Input/JNE/01_Invoice/")
  rateCard <- loadRateCards("1_Input/JNE/02_Ratecards/JNE_Ratecards.csv")
  paidInvoiceData <- LoadInvoiceData("1_Input/JNE/03_Paid_Invoice/")
  
  gc()
  mergedOMSData <- left_join(invoiceData,
                             packageBaseData,
                             by = "tracking_number")
  rm(packageBaseData)
  gc()
  mergedOMSData %<>%
    mutate(package_number = ifelse(is.na(package_number.y), package_number.x,
                                   package_number.y)) %>%
    select(-c(package_number.x, package_number.y))
  
  
  paidInvoice <- NULL
  paidInvoiceList <- NULL
  
  if (!is.null(paidInvoiceData)) {
    paidInvoice <- paidInvoiceData$tracking_number
    paidInvoiceList <- select(paidInvoiceData, tracking_number, rawFile)
    paidInvoiceList <- paidInvoiceList %>%
      filter(!duplicated(tracking_number))
    row.names(paidInvoiceList) <- paidInvoiceList$tracking_number
  }
  
  mergedOMSData <- left_join(mergedOMSData, rateCard,
                             by=c("destination_branch"="Coding"))
  
  mergedOMSData %<>%
    mutate(volumetricWeight = volumetricDimension / 6000) %>%
    replace_na(list(volumetricWeight = 0, actualWeight = 0)) %>%
    mutate(lazadaWeight = ifelse(volumetricWeight > actualWeight,
                                 volumetricWeight, actualWeight)) %>%
    mutate(lazadaWeight = round(lazadaWeight + 0.49, 0))
  
  mergedOMSData %<>%
    replace_na(list(shippingFee = 0, shippingSurcharge = 0))
  mergedOMSData %<>%
    mutate(FrieghtCostInvoice_Calculate=TARIF * package_chargeable_weight,
           FreightCostLazadaWeight = TARIF * lazadaWeight,
           InsuranceFee_Calculate=ifelse((paidPrice + shippingFee + shippingSurcharge) < 1000000,2500,
                                         0.0025 * (paidPrice + shippingFee + shippingSurcharge))) %>%
    mutate(COD_calculated = ifelse(payment_method == "CashOnDelivery",
                                   0.01 * (paidPrice + shippingFee + shippingSurcharge), 0)) %>%
    mutate(FrieghtCost_Flag=ifelse(carrying_fee - FrieghtCost_Calculate < 1,"Okay","Not-Okay")) %>%
    mutate(InsuranceFee_Flag=ifelse(insurance_fee - InsuranceFee_Calculate < 1,"Okay","Not-Okay")) %>%
    mutate(COD_Flag=ifelse(cod_fee - COD_calculated < 1,"Okay","Not-Okay")) %>%
    mutate(Duplication_Flag=ifelse(duplicated(tracking_number),"Duplicated",
                                   ifelse(tracking_number %in% paidInvoice,
                                          "Duplicated","Not_Duplicated"))) %>%
    mutate(DuplicationSource=ifelse(duplicated(tracking_number),"Self_Duplicated",
                                    ifelse(tracking_number %in% paidInvoice,
                                           paidInvoiceList[tracking_number,]$InvoiceFile,"")))
  
  flog.info("Done Invoice Calculation", name = reportName)
  
  finalData <- mergedOMSData %>%
    select(`3pl_name`, package_pickup_date, package_pod_date,
           invoice_number, tracking_number, package_number,
           order_nr, skus, skus_names, Seller, carrying_fee,
           redelivery_fee, rejection_fee, cod_fee,
           special_area_fee, special_handling_fee,
           insurance_fee, vat, origin_branch, destination_branch,
           rawFile, FrieghtCostInvoice_Calculate, FreightCostLazadaWeight,
           InsuranceFee_Calculate, COD_calculated, totalPaidPrice = paidPrice,
           shippingFee, shippingSurcharge, package_chargeable_weight,
           actualWeight, missingActualWeight,
           volumetricDimension, missingVolumetricDimension,
           shipment_provider_name, payment_method, 
           Seller_Code, tax_class, RTS_Date, Shipped_Date,
           Delivered_Date, FrieghtCost_Flag, InsuranceFee_Flag,
           COD_Flag, Duplication_Flag, DuplicationSource)
  
  flog.info("Writting Output File in CSV Format", name = reportName)
  
  invoiceFiles <- unique(finalData$rawFile)
  for (iFile in invoiceFiles) {
    fileName <- gsub(".xls.*$", "_checked.csv", iFile)
    fileData <-  as.data.frame(finalData %>% filter(rawFile == iFile))
    write.csv2(fileData, file.path("2_Output/JNE", fileName),
               row.names = FALSE)
  }
  
  flog.info("Done", name = reportName)
  
},error = function(err){
  flog.error(err, name = reportName)
  flog.error("PLease send 3_Script/Log folder to Regional OPS BI for additional support",
             name = reportName)
})