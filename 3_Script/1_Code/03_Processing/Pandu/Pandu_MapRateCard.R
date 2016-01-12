MapRateCard <- function(mergedOMSData, rateCardFilePath) {
  suppressMessages({
    require(dplyr)
    require(tools)
    require(magrittr)
    require(methods)
    require(futile.logger)
    require(XLConnect)
  })
  
  functionName <- "MapRateCard"
  flog.info(paste("Function", functionName, "started"), name = reportName)
  
  output <- tryCatch({
    
    wb <- loadWorkbook(rateCardFilePath)  
    rateCard <- readWorksheet(object = wb, sheet = 1, colTypes = c(XLC$DATA_TYPE.STRING, XLC$DATA_TYPE.STRING, XLC$DATA_TYPE.STRING,
                                                                   XLC$DATA_TYPE.STRING, XLC$DATA_TYPE.STRING, XLC$DATA_TYPE.STRING,
                                                                   XLC$DATA_TYPE.STRING, XLC$DATA_TYPE.NUMERIC, XLC$DATA_TYPE.NUMERIC,
                                                                   XLC$DATA_TYPE.NUMERIC))
    
    
    
    rateCardRev <- rateCard %>%
      select(Origin,	Destination,	Destination_Desc, Treshold,	Price,	Lead_Time) %>%
      # mutate(Tarif_REG = as.numeric(gsub(",", "", Tarif_REG))) %>%
      # mutate(PROVINSI = gsub("[^a-zA-Z0-9]", "", toupper(PROVINSI))) %>%
      # mutate(KOTA_KABUPATEN = gsub("[^a-zA-Z0-9]", "", toupper(KOTA_KABUPATEN))) %>%
      mutate(Destination_Desc = gsub("[^a-zA-Z0-9]", "", toupper(Destination_Desc))) %>%
#       mutate(PROVINSI = gsub("^(KAB|KOTA)", "", toupper(PROVINSI))) %>%
#       mutate(KOTA_KABUPATEN = gsub("^(KAB|KOTA)", "", toupper(KOTA_KABUPATEN))) %>%
      mutate(Destination_Desc = gsub("^(KAB|KOTA)", "", toupper(Destination_Desc))) %>%
#       mutate(PROVINSI = gsub("(KAB|KOTA)$", "", toupper(PROVINSI))) %>%
#       mutate(KOTA_KABUPATEN = gsub("(KAB|KOTA)$", "", toupper(KOTA_KABUPATEN))) %>%
      mutate(Destination_Desc = gsub("(KAB|KOTA)$", "", toupper(Destination_Desc))) %>%
      mutate(mappingCode = Destination_Desc) %>%
      arrange(mappingCode, desc(Price)) %>%
      filter(!duplicated(mappingCode)) %>%
      select(-c(mappingCode))
    
    mergedOMSDataRev <- mergedOMSData %>%
      mutate(level_2_name = gsub("[^a-zA-Z0-9]", "", toupper(level_2_name))) %>%
      mutate(level_3_name = gsub("[^a-zA-Z0-9]", "", toupper(level_3_name))) %>%
      mutate(level_4_name = gsub("[^a-zA-Z0-9]", "", toupper(level_4_name))) 
#       mutate(level_4_name = gsub("ANYERANYAR", "ANYAR", level_4_name)) %>%
#       mutate(level_4_name = gsub("KOTOVIITUJUH", "KOTOVII", level_4_name)) %>%
#       mutate(level_4_name = gsub("POSOUTARA", "POSO", level_4_name))
    
    mappedRateCard <- left_join(mergedOMSDataRev, 
                                rateCardRev,
                                by = c("level_3_name" = "Destination_Desc"))
    
    mappedRateCard %<>%
      mutate(RateCardMappedFlag = ifelse(is.na(Price), "NOT_OKAY","OKAY"))
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste("Function", functionName, "ended"), name = reportName)
  })
  
  output
}