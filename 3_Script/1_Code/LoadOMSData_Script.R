suppressMessages({
  library(dplyr)
  library(tidyr)
  library(magrittr)
  library(lubridate)
  library(tools)
  library(logging)
})

dateReport <- format(Sys.time(), "%Y%m%d%H%M")
addHandler(writeToFile, logger="IDInvoiceCheck",
           file=file.path("3_Script/2_Log",
                          paste0("OMSLoading_",dateReport,".csv")))
addHandler(writeToConsole , logger="IDInvoiceCheck.Log")
tryCatch({
loginfo("Initial Setup", logger = "IDInvoiceCheck.Log")
source("3_Script/1_Code/fn_LoadInvoiceData.R")
source("3_Script/1_Code/fn_GeneratePackageData.R")
source("3_Script/1_Code/fn_LoadOMSData.R")

OMSDataFolder <- file.path("1_Input/OMS_Data")

loginfo("Start Loading OMS Data", logger = "IDInvoiceCheck.Log")
OMSData <- LoadOMSData(OMSDataFolder)
cat("\r\n")
loginfo("Done Loading OMS Data", logger = "IDInvoiceCheck.Log")

loginfo("Start Summarize Package Data", logger = "IDInvoiceCheck.Log")
PackageDataSummarized <- GeneratePackageData(OMSData)
loginfo("Done Package Summary Data", logger = "IDInvoiceCheck.Log")

loginfo("Start Saving RData Files", logger = "IDInvoiceCheck.Log")
save(OMSData, file = "3_Script/3_RData/OMSData.RData")
save(PackageDataSummarized, file = "3_Script/3_RData/PackageDataSummarized.RData")
loginfo("Done Preparing OMS Data", logger = "IDInvoiceCheck.Log")

},error = function(err){
  logerror(err, logger = "IDInvoiceCheck")
  logerror("PLease send 3_Script/Log folder to Regional OPS BI for additional support",
           logger = "IDInvoiceCheck.Log")
  
})



