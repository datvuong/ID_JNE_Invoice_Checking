.libPaths("D:/Invoice_Automation/R_Library")

options(warn=-1)
library(lubridate)
source("../1_Code/fn_loadRatecards.R")
source("../1_Code/fn_loadInvoiceData.R")
source("../1_Code/fn_loadOMSData.R")
source("../1_Code/fn_loadPaidInvoice.R")


cat("Loading ratecard data...\r\n")
rateCard <- loadRateCards("../../1_Input/Ratecards/JNE_Ratecards.csv")
cat("Loading OMS Data...\r\n")
OMS <- loadOMSData("../../1_Input/OMS_Data/")

PackageData <- select(OMS, order_nr, business_unit, payment_method,
                      unit_price,paid_price, shipping_fee, 
                      shipping_surcharge, Item_Status, RTS_Date,
                      Shipped_Date, Cancelled_Date, Delivered_Date,
                      Tracking_number, shipment_provider_name,
                      Seller_Code, Seller, tax_class,
                      shipping_city, shipping_region)

PackageData %<>%
  mutate(shipping_fee=ifelse(is.na(shipping_fee),0,shipping_fee)) %>%
  mutate(shipping_surcharge=ifelse(is.na(shipping_surcharge),0,shipping_surcharge))

PackageDataSummarized <- PackageData %>% group_by(order_nr,Tracking_number) %>%
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
            Seller=last(Seller),
            tax_class=last(tax_class),
            shipping_city=last(shipping_city),
            shipping_region=last(shipping_region))

options(warn=0)

##### Match Invoice Data with OMS Data #####
cat("Verify Delivery & Insruance invoice data...\r\n")
paidDeliveryInvoiceData <- loadPaidDeliveryInvoiceData("../../1_Input/Paid_Invoice/DELIVERY_INSURANCE")
DeliveryInvoice <- file.path("../../1_Input/Invoice","DELIVERY_INSURANCE")
for (iFile in list.files(DeliveryInvoice)){
  if (file_ext(iFile)=="csv"){
    cat(paste0("--- Processing Invoice File: ",iFile, "\r\n"))
    invoiceData <- loadDeliveryInvoiceData(file.path(DeliveryInvoice,iFile))
    cat(paste0("----- Duplicated Invoice Data: ", sum(duplicated(invoiceData$Tracking_number)),"\r\n"))
    
    TrackingNumber <- unique(OMS$Tracking_number)
    
    InvoiceMapped <- left_join(invoiceData, PackageDataSummarized,
                               by=("Tracking_number"))
    
    OMS_OrderList <- unique(OMS$order_nr)
    
    InvoiceMapped %<>%
      mutate(OrderExisted=ifelse(Order_Nr %in% OMS_OrderList |
                                   !is.na(order_nr),"Existed","Not-Existed"))
    
    
    
    ##### Ratecard Calculation #####
    InvoiceMappedRate <- left_join(InvoiceMapped, rateCard,
                                   by=c("Destination_Code"="Coding"))
    
    paidInvoice <- paidDeliveryInvoiceData$Tracking_number
    paidInvoiceList <- select(paidDeliveryInvoiceData, Tracking_number,InvoiceFile)
    row.names(paidInvoiceList) <- paidInvoiceList$Tracking_number
    
    InvoiceMappedRate %<>%
      mutate(FrieghtCost_Calculate=TARIF * Weight,
             InsuranceFee_Calculate=ifelse(Total_unit_price < 1000000,2500,
                                           0.005*Total_unit_price)) %>%
      mutate(FrieghtCost_Flag=ifelse(FrieghtCost_Calculate==Amount,"Okay","Not-Okay")) %>%
      mutate(InsuranceFee_Flag=ifelse(InsuranceFee_Calculate==Insurance,"Okay","Not-Okay")) %>%
      mutate(Duplication_Flag=ifelse(duplicated(Tracking_number),"Duplicated",
                                     ifelse(Tracking_number %in% paidInvoice,
                                            "Duplicated","Not_Duplicated"))) %>%
      mutate(DuplicationSource=ifelse(duplicated(Tracking_number),"Self_Duplicated",
                                      ifelse(Tracking_number %in% paidInvoice,
                                             paidInvoiceList[Tracking_number,]$InvoiceFile,"")))
    
    InvoiceMappedRate %<>%
      select(1:13,OrderExisted,FrieghtCost_Calculate,InsuranceFee_Calculate,
             FrieghtCost_Flag,InsuranceFee_Flag,
             Duplication_Flag,DuplicationSource,
             order_nr, business_unit, payment_method,
             Total_unit_price,COD_Amount, RTS_Date,
             Shipped_Date, Cancelled_Date, Delivered_Date,
             Tracking_number, shipment_provider_name,
             Seller_Code, Seller, tax_class,
             shipping_city, shipping_region)
    
    fileName <- gsub('\\.csv','',iFile)
    
    ##### Output #####
    write.csv2(InvoiceMappedRate, file.path("../../2_Output/DELIVERY_INSURANCE",paste0(fileName,'_checked.csv')),
               row.names = FALSE)
  }
}

cat("Verify COD invoice data...\r\n")
paidCODInvoiceData <- loadPaidCODInvoiceData("../../1_Input/Paid_Invoice/COD")
CODInvoice <- file.path("../../1_Input/Invoice","COD")
for (iFile in list.files(CODInvoice)){
  if (file_ext(iFile)=="csv"){
    cat(paste0("--- Processing Invoice File: ",iFile,"\r\n"))
    invoiceData <- loadCODInvoiceData(file.path(CODInvoice,iFile))
    cat(paste0("----- Duplicated Invoice Data: ", sum(duplicated(invoiceData$Tracking_number)),"\r\n"))
    
    TrackingNumber <- unique(OMS$Tracking_number)
    
    InvoiceMapped <- left_join(invoiceData, PackageDataSummarized,
                               by=("Tracking_number"))
    
    OMS_OrderList <- unique(OMS$order_nr)
    
    InvoiceMapped %<>%
      mutate(OrderExisted=ifelse(Order_Nr %in% OMS_OrderList,"Existed","Not-Existed"))
    
    paidInvoice <- paidCODInvoiceData$Tracking_number
    paidInvoiceList <- select(paidCODInvoiceData, Tracking_number,InvoiceFile)
    row.names(paidInvoiceList) <- paidInvoiceList$Tracking_number
    
    InvoiceMapped %<>%
      mutate(COD_Fee_Calculated=ifelse(payment_method=="CashOnDelivery" &
                                         !is.na(Delivered_Date),
                                       0.01*COD_Amount,0)) %>%
      mutate(COD_Flag=ifelse(COD_Fee_Calculated>=Management_Fee,
                             "Okay","Not-Okay")) %>%
      mutate(Duplication_Flag=ifelse(duplicated(Tracking_number),"Duplicated",
                                     ifelse(Tracking_number %in% paidInvoice,
                                            "Duplicated",NA))) %>%
      mutate(DuplicationSource=ifelse(duplicated(Tracking_number),"Self_Duplicated",
                                      ifelse(Tracking_number %in% paidInvoice,
                                             paidInvoiceList[Tracking_number,]$InvoiceFile,NA)))
    
    
    InvoiceMapped %<>%
      select(1:13,OrderExisted,COD_Fee_Calculated,COD_Flag,
             Duplication_Flag,DuplicationSource,
             order_nr, business_unit, payment_method,
             Total_unit_price,COD_Amount, RTS_Date,
             Shipped_Date, Cancelled_Date, Delivered_Date,
             Tracking_number, shipment_provider_name,
             Seller_Code, Seller, tax_class,
             shipping_city, shipping_region)
    
    
    ##### Output #####
    write.csv2(InvoiceMapped, file.path("../../2_Output/COD",iFile),
               row.names = FALSE)
  }
}

cat("Done!!! \r\n ")