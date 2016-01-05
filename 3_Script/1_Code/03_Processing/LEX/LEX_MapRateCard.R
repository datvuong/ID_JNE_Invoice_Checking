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
    rateCard <- readWorksheet(object = wb, sheet = 1)
    
    rateCardRev <- rateCard %>%
      select(Banten, City_name, District_name,
             Initial.1st.Kg, Next.Kg, Insurance.Charge, COD.Fee) %>%
      mutate(Banten = gsub("[^a-zA-Z0-9]", "", toupper(Banten))) %>%
      mutate(City_name = gsub("[^a-zA-Z0-9]", "", toupper(City_name))) %>%
      mutate(District_name = gsub("[^a-zA-Z0-9]", "", toupper(District_name))) %>%
      mutate(Banten = gsub("^(KAB|KOTA)", "", toupper(Banten))) %>%
      mutate(City_name = gsub("^(KAB|KOTA)", "", toupper(City_name))) %>%
      mutate(District_name = gsub("^(KAB|KOTA)", "", toupper(District_name))) %>%
      mutate(Banten = gsub("(KAB|KOTA)$", "", toupper(Banten))) %>%
      mutate(City_name = gsub("(KAB|KOTA)$", "", toupper(City_name))) %>%
      mutate(District_name = gsub("(KAB|KOTA)$", "", toupper(District_name)))
    rateCardRev <- filter(rateCardRev, !duplicated(rateCardRev))
    
    mergedOMSDataRev <- mergedOMSData %>%
      mutate(level_2_name = gsub("[^a-zA-Z0-9]", "", toupper(level_2_name))) %>%
      mutate(level_3_name = gsub("[^a-zA-Z0-9]", "", toupper(level_3_name))) %>%
      mutate(level_4_name = gsub("[^a-zA-Z0-9]", "", toupper(level_4_name))) %>%
      mutate(level_4_name = gsub("GROGOLPETAMBURAN", "GROGOL", level_4_name)) %>%
      mutate(level_4_name = gsub("CIMEUNYAN", "CIMENYAN", level_4_name)) %>%
      mutate(level_4_name = gsub("MAKASAR", "MAKASSAR", level_4_name)) %>% 
      mutate(level_4_name = gsub("BABAKANCIPARAY", "CIPARAY", level_4_name)) %>%
      mutate(level_4_name = gsub("BUAHBATUMARGACINTA", "MARGACINTA", level_4_name)) %>%
      mutate(level_4_name = gsub("SUKARAMI", "SUKARAME", level_4_name)) %>%
      mutate(level_4_name = gsub("ANTAPANICICADAS", "CICADAS", level_4_name)) %>%
      mutate(level_4_name = gsub("BUNGUSTELUKKABUNG", "BUNGUSTELUKUNG", level_4_name)) %>%
      mutate(level_4_name = gsub("MENGWI", "MENGUWI", level_4_name)) %>%
      mutate(level_4_name = gsub("KLAPANUNGGALKELAPANUNGGAL", "KLAPANUNGGAL", level_4_name)) %>%
      mutate(level_4_name = gsub("BUNGUSTELUKUNG", "BUNGUSTELUKKABUNG", level_4_name)) %>%
      mutate(level_4_name = gsub("BAKAUHENI", "BAKAUHEUNI", level_4_name))
    
    mappedRateCard <- left_join(mergedOMSDataRev, 
                                rateCardRev,
                                by = c("level_2_name" = "Banten",
                                       "level_3_name" = "City_name",
                                       "level_4_name" = "District_name"))
    
    mappedRateCard %<>%
      mutate(RateCardMappedFlag = ifelse(is.na(Initial.1st.Kg), "NOT_OKAY","OKAY"))
    
  }, error = function(err) {
    flog.error(paste(functionName, err, sep = " - "), name = reportName)
  }, finally = {
    flog.info(paste("Function", functionName, "ended"), name = reportName)
  })
  
  output
}