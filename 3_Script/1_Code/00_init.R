dateReport <- format(Sys.time(), "%Y%m%d")
timeReport <- format(Sys.time(), "%Y%m%d%H%M")
suppressMessages({
  options( java.parameters = "-Xmx8g" ) # Set heap memory for Java upto 4GB
  library(dplyr)
  library(tidyr)
  library(magrittr)
  library(lubridate)
  library(logging)
  library(futile.logger)
  library(XLConnect)
})

reportName <- paste0("IDInvoiceCheck")
warningLog <- paste0("IDInvoiceCheck", "warning")
flog.appender(appender.tee(file.path("3_Script/2_Log",
                                      paste0("ID_InvoiceChecking",dateReport,".csv"))),
              name = reportName)

layout <- layout.format(paste0(timeReport,'|[~l]|[~t]|[~n.~f]|~m'))
flog.layout(layout, name=reportName)
