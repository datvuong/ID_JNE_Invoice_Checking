suppressMessages({
  library(dplyr)
  library(tidyr)
  library(magrittr)
  library(lubridate)
  library(tools)
  library(logging)
})

dateReport <- format(Sys.time(), "%Y%m%d%H%M")
basicConfig()
addHandler(writeToFile, logger="IDInvoiceCheck",
           file=file.path("3_Script/2_Log",
                          paste0("OMSLoading_",dateReport,".csv")))
tryCatch({
loginfo("Initial Setup", logger = "IDInvoiceCheck.module")
source("3_Script/1_Code/fn_LoadInvoiceData.R")
source("3_Script/1_Code/fn_GeneratePackageData.R")
source("3_Script/1_Code/fn_LoadOMSData.R")

OMSDataFolder <- file.path("1_Input/OMS_Data")

loginfo("Start Loading OMS Data", logger = "IDInvoiceCheck.module")
OMSData <- LoadOMSData(OMSDataFolder)
cat("\r\n")
loginfo("Done Loading OMS Data", logger = "IDInvoiceCheck.module")

loginfo("Start Summarize Package Data", logger = "IDInvoiceCheck.module")
PackageDataSummarized <- GeneratePackageData(OMSData)
loginfo("Done Package Summary Data", logger = "IDInvoiceCheck.module")

loginfo("Start Saving RData Files", logger = "IDInvoiceCheck.module")
save(OMSData, file = "3_Script/3_RData/OMSData.RData")
save(PackageDataSummarized, file = "3_Script/3_RData/PackageDataSummarized.RData")
loginfo("Done Preparing OMS Data", logger = "IDInvoiceCheck.module")

},error = function(err){
  logerror(err, logger = "IDInvoiceCheck.module")
})



