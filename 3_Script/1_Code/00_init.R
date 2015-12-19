dateReport <- format(Sys.time(), "%Y%m%d%H%M")

suppressMessages({
  library(dplyr)
  library(tidyr)
  library(magrittr)
  library(lubridate)
  library(logging)
})

reportName <- paste0("IDInvoiceCheck")
consoleLog <- paste0("IDInvoiceCheck", ".Console")

addHandler(writeToFile, logger=reportName,
           file=file.path("3_Script/2_Log",
                          paste0("ID_InvoiceChecking",dateReport,".csv")))
addHandler(writeToConsole , logger=consoleLog)