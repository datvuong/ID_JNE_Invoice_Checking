source("3_Script/1_Code/00_init.R")

tryCatch({
  
  flog.info("Initial Setup", name = "IDInvoiceCheck")
  
  source("3_Script/1_Code/01_Loading/Load_Invoice_Data.R")
  source("3_Script/1_Code/fn_loadRatecards.R")
  
  load("1_Input/RData/packageBaseData.RData")
  invoiceData <- LoadInvoiceData("1_Input/JNE/01_Invoice/")
  rateCard <- loadRateCards("1_Input/JNE/02_Ratecards/JNE_Ratecards.csv")
  paidInvoiceData <- LoadInvoiceData("1_Input/JNE/03_Paid_Invoice/")
  
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
    paidInvoice <- paidDeliveryInvoiceData$tracking_number
    paidInvoiceList <- select(paidInvoiceData, tracking_number,InvoiceFile)
    row.names(paidInvoiceList) <- paidInvoiceList$tracking_number
  }
  
  mergedOMSData <- left_join(mergedOMSData, rateCard,
                             by=c("destination_branch"="Coding"))
  
  mergedOMSData %<>%
    replace_na(list(shippingFee = 0, shippingSurcharge = 0))
  mergedOMSData %<>%
    mutate(FrieghtCost_Calculate=TARIF * package_chargeable_weight,
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
  
  finalData <- mergedOMSData %>%
    select(`3pl_name`, package_pickup_date, package_pod_date,
           invoice_number, tracking_number, package_number,
           order_nr, skus, skus_names, Seller,
           package_chargeable_weight, carrying_fee,
           redelivery_fee, rejection_fee, cod_fee,
           special_area_fee, special_handling_fee,
           insurance_fee, vat, origin_branch, destination_branch,
           rawFile, totalPaidPrice = paidPrice,
           shippingFee, shippingSurcharge, actualWeight,
           volumetricDimension, payment_method, 
           Seller_Code, tax_class, RTS_Date, Shipped_Date,
           Delivered_Date, FrieghtCost_Flag, InsuranceFee_Flag,
           COD_Flag, Duplication_Flag, DuplicationSource)
  
  invoiceFiles <- unique(finalData$rawFile)
  for (iFile in invoiceFiles) {
    fileName <- gsub(".xls.*$", "_checked.csv", iFile)
    fileData <-  as.data.frame(finalData %>% filter(rawFile == iFile))
    write.csv2(fileData, file.path("2_Output/JNE", fileName),
               row.names = FALSE)
  }
  
  
  #   
  #   
  #   ##### Match Invoice Data with OMS Data #####
  #   paidDeliveryInvoiceData <- loadPaidDeliveryInvoiceData("1_Input/Paid_Invoice/DELIVERY_INSURANCE")
  #   loginfo("Start Verify Delivery & Insruance invoices data...", logger = "IDInvoiceCheck.Log")
  #   DeliveryInvoice <- file.path("1_Input/Invoice","DELIVERY_INSURANCE")
  #   filesCount <- sum(grepl("\\.csv",list.files(DeliveryInvoice)))
  #   pb <- txtProgressBar(min=0,max=filesCount, style = 3)
  #   iProgress <- 0
  #   setTxtProgressBar(pb, iProgress)
  #   for (iFile in list.files(DeliveryInvoice)){
  #     if (file_ext(iFile)=="csv"){
  #       
  #       fileName <- gsub('\\.csv','',iFile)
  #       
  #       ##### Output #####
  #       write.csv2(InvoiceMappedRate, file.path("2_Output/DELIVERY_INSURANCE",paste0(fileName,'_checked.csv')),
  #                  row.names = FALSE)
  #       
  #       loginfo(paste0("--- Done Processing Invoice File: ",iFile), logger = "IDInvoiceCheck")
  #       iProgress <- iProgress + 1
  #       setTxtProgressBar(pb, iProgress)
  #     }
  #   }
  #   cat("\r\n")
  #   loginfo("Start Verify COD invoices data...", logger = "IDInvoiceCheck.Log")
  #   paidCODInvoiceData <- loadPaidCODInvoiceData("1_Input/Paid_Invoice/COD")
  #   CODInvoice <- file.path("1_Input/Invoice","COD")
  #   filesCount <- sum(grepl("\\.csv",list.files(CODInvoice)))
  #   pb <- txtProgressBar(min=0,max=filesCount, style = 3)
  #   iProgress <- 0
  #   setTxtProgressBar(pb, iProgress)
  #   for (iFile in list.files(CODInvoice)){
  #     if (file_ext(iFile)=="csv"){
  #       loginfo(paste0("--- Start Processing Invoice File: ",iFile), logger = "IDInvoiceCheck")
  #       invoiceData <- loadCODInvoiceData(file.path(CODInvoice,iFile))
  #       #cat(paste0("----- Duplicated Invoice Data: ", sum(duplicated(invoiceData$tracking_number)),"\r\n"))
  #       
  #       invoiceTracking <- unique(invoiceData$tracking_number)
  #       PackageDataToMapped <- filter(PackageDataSummarized,
  #                                     tracking_number %in% invoiceTracking)
  #       
  #       InvoiceMapped <- left_join(invoiceData, PackageDataToMapped,
  #                                  by=("tracking_number"))
  #       
  #       OMS_OrderList <- unique(OMSData$order_nr)
  #       
  #       InvoiceMapped %<>%
  #         mutate(OrderExisted=ifelse(!is.na(order_nr) |
  #                                      Order_Nr %in% OMS_OrderList,"Existed","Not-Existed"))
  #       
  #       paidInvoice <- paidCODInvoiceData$tracking_number
  #       paidInvoiceList <- select(paidCODInvoiceData, tracking_number,InvoiceFile)
  #       row.names(paidInvoiceList) <- paidInvoiceList$tracking_number
  #       
  #       InvoiceMapped %<>%
  #         mutate(COD_Fee_Calculated=ifelse(payment_method=="CashOnDelivery" &
  #                                            !is.na(Delivered_Date),
  #                                          0.01 * COD_Amount,0)) %>%
  #         mutate(COD_Flag=ifelse(COD_Fee_Calculated >= Management_Fee,
  #                                "Okay", "Not-Okay")) %>%
  #         mutate(Duplication_Flag=ifelse(duplicated(tracking_number),"Duplicated",
  #                                        ifelse(tracking_number %in% paidInvoice,
  #                                               "Duplicated","Not_Duplicated"))) %>%
  #         mutate(DuplicationSource=ifelse(duplicated(tracking_number),"Self_Duplicated",
  #                                         ifelse(tracking_number %in% paidInvoice,
  #                                                paidInvoiceList[tracking_number,]$InvoiceFile,"Not_Duplicated")))
  #       
  #       InvoiceMapped %<>%
  #         mutate(Order_Nr = ifelse(is.na(Order_Nr) & !is.na(order_nr),
  #                                  order_nr, Order_Nr))
  #       InvoiceMapped %<>%
  #         select(tracking_number, TGL_ENTRY, Order_Nr,
  #                Destination_Code, Qty, Weight,
  #                GOOD_Values, Management_Fee, Instruction, 
  #                Service, Status, OrderExisted,
  #                COD_Fee_Calculated, COD_Flag,
  #                Duplication_Flag, DuplicationSource,
  #                order_nr, business_unit, payment_method,
  #                Total_unit_price,COD_Amount, RTS_Date,
  #                Shipped_Date, Cancelled_Date, Delivered_Date,
  #                tracking_number, shipment_provider_name,
  #                Seller_Code, tax_class,
  #                shipping_city, shipping_region)
  #       
  #       ##### Output #####
  #       write.csv2(InvoiceMapped, file.path("2_Output/COD",iFile),
  #                  row.names = FALSE)
  #       loginfo(paste0("--- Done Processing Invoice File: ",iFile), logger = "IDInvoiceCheck")
  #       iProgress <- iProgress + 1
  #       setTxtProgressBar(pb, iProgress)
  #     }
  #   }
  #   cat("\r\n")
  #   loginfo(paste0("--- Done!!!"), logger = "IDInvoiceCheck.Log")
  #   loginfo(paste0(warnings()), logger = "IDInvoiceCheck")
},error = function(err){
  flog.error(err, logger = "IDInvoiceCheck")
  flog.error("PLease send 3_Script/Log folder to Regional OPS BI for additional support",
             logger = "IDInvoiceCheck.Log")
})

