UpdateSOITimeStamp <- function(soiHistoryData) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(logging)
    require(data.table)
  })
  
  functionName <- "UpdateSOITimeStamp"
  loginfo(paste("Function", functionName, "started"), logger = reportName)
  
  output <- tryCatch({
    
    soiTimestampData <- soiHistoryData %>%
      arrange(fk_sales_order_item, desc(created_at)) %>%
      mutate(uniqueKey = paste0(fk_sales_order_item, fk_sales_order_item_status)) %>%
      filter(!duplicated(uniqueKey)) %>%
      select(fk_sales_order_item, fk_sales_order_item_status, created_at) %>%
      spread(fk_sales_order_item_status, created_at)
    soiTimestampData <- data.table(soiTimestampData)
    for (iStatus in c('50', '76', '5', '9', '27')) {
      if (!(iStatus %in% names(soiTimestampData))) {
        soiTimestampData[, (iStatus) := as.POSIXct(NA)]
      }
    }
    soiTimestampData <- tbl_df(soiTimestampData)
    
    soiTimestampData %<>%
      select(fk_sales_order_item, 
             rts_wh = `50`,
             rts_ds = `76`,
             shipped =`5`,
             cancelled = `9`,
             delivered = `27`) %>%
      mutate(rts = ifelse(is.na(rts_wh), rts_ds, rts_wh)) %>%
      select(-c(rts_wh, rts_ds))
    
    for (iWarn in warnings()){
      logwarn(paste(functionName, iWarn), logger = reportName)
    }
    
    soiTimestampData
    
  }, error = function(err) {
    logerror(paste(functionName, err, sep = " - "), logger = consoleLog)
  }, finally = {
    loginfo(paste(functionName, "ended"), logger = reportName)
  })
  
  output
}
