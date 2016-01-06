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
    
    wb <- loadWorkbook("1_Input/RPX/02_Ratecards/RPX Master posatl Code-Lazada 8-9-15.xlsx")  
    rateCard <- readWorksheet(object = wb, sheet = 1)
    
    rateCardRev <- rateCard %>%
      select(PROPINSI, KOTA.KABUPATEN, KECAMATAN, RATE.KG) %>%
      mutate(PROPINSI = gsub("[^a-zA-Z0-9]", "", toupper(PROPINSI))) %>%
      mutate(KOTA.KABUPATEN = gsub("[^a-zA-Z0-9]", "", toupper(KOTA.KABUPATEN))) %>%
      mutate(KECAMATAN = gsub("[^a-zA-Z0-9]", "", toupper(KECAMATAN))) %>%
      mutate(PROPINSI = gsub("^(KAB|KOTA)", "", toupper(PROPINSI))) %>%
      mutate(KOTA.KABUPATEN = gsub("^(KAB|KOTA)", "", toupper(KOTA.KABUPATEN))) %>%
      mutate(KECAMATAN = gsub("^(KAB|KOTA)", "", toupper(KECAMATAN))) %>%
      mutate(PROPINSI = gsub("(KAB|KOTA)$", "", toupper(PROPINSI))) %>%
      mutate(KOTA.KABUPATEN = gsub("(KAB|KOTA)$", "", toupper(KOTA.KABUPATEN))) %>%
      mutate(KECAMATAN = gsub("(KAB|KOTA)$", "", toupper(KECAMATAN))) %>%
      mutate(mappingCode = paste0(PROPINSI, KOTA.KABUPATEN, KECAMATAN)) %>%
      arrange(mappingCode, desc(RATE.KG)) %>%
      filter(!duplicated(mappingCode)) %>%
      select(-c(mappingCode))
    
    mergedOMSDataRev <- mergedOMSData %>%
      mutate(level_2_name = gsub("[^a-zA-Z0-9]", "", toupper(level_2_name))) %>%
      mutate(level_3_name = gsub("[^a-zA-Z0-9]", "", toupper(level_3_name))) %>%
      mutate(level_4_name = gsub("[^a-zA-Z0-9]", "", toupper(level_4_name))) %>%
      mutate(level_4_name = gsub("ANYERANYAR", "ANYAR", level_4_name)) %>%
      mutate(level_4_name = gsub("KOTOVIITUJUH", "KOTOVII", level_4_name)) %>%
      mutate(level_4_name = gsub("POSOUTARA", "POSO", level_4_name))
    
    mappedRateCard <- left_join(mergedOMSDataRev, 
                                rateCardRev,
                                by = c("level_2_name" = "PROPINSI",
                                       "level_3_name" = "KOTA.KABUPATEN",
                                       "level_4_name" = "KECAMATAN"))
    
    mappedRateCard %<>%
      mutate(RateCardMappedFlag = ifelse(is.na(RATE.KG), "NOT_OKAY","OKAY"))
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste("Function", functionName, "ended"), name = reportName)
  })
  
  output
}