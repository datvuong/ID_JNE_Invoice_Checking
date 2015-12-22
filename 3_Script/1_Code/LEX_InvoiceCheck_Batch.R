source("3_Script/1_Code/00_init.R")

tryCatch({
  
  flog.info("Initial Setup", name = reportName)
  
  source("3_Script/1_Code/01_Loading/Load_Invoice_Data.R")
  
  load("1_Input/RData/packageBaseData.RData")
  invoiceData <- LoadInvoiceData("1_Input/LEX/01_Invoice")
  
  mergedOMSData <- left_join(invoiceData,
                             packageBaseData,
                             by = "tracking_number")
  rm(packageBaseData)
  gc()
  mergedOMSData %<>%
    mutate(package_number = ifelse(is.na(package_number.y), package_number.x,
                                   package_number.y)) %>%
    select(-c(package_number.x, package_number.y))
  
  flog.info("Writing Result to csv format!!!", name = reportName)
  
  invoiceFiles <- unique(mergedOMSData$rawFile)
  for (iFile in invoiceFiles) {
    fileName <- gsub(".xls.*$", "_checked.csv", iFile)
    fileData <-  as.data.frame(mergedOMSData %>% filter(rawFile == iFile))
    write.csv2(fileData, file.path("2_Output/LEX", fileName),
               row.names = FALSE)
  }
  
  flog.info("Done", name = reportName)
 
},error = function(err){
  flog.error(err, name = reportName)
  flog.error("PLease send 3_Script/Log folder to Regional OPS BI for additional support",
             name = reportName)
})
