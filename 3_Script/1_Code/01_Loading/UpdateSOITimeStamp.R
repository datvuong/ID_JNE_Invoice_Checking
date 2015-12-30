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
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
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
      mutate(rts = as.POSIXct(ifelse(is.na(rts_wh), rts_ds, rts_wh),
                              origin = "1970-01-01 UTC")) %>%
      select(-c(rts_wh, rts_ds))
    
    soiTimestampData
    
  }, error = function(err) {
    flog.info(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste(functionName, "ended"), name = reportName)
  })
  
  output
}
