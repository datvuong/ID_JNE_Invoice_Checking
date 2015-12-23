source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/ExtractSKUData.R")

flog.info("Update Pacakge Data", name = reportName)
skuData <- ExtractSKUData(server = serverIP, username = user,
                          password = password)
save(skuData, file = "1_Input/RData/skuData.RData",
     compress = TRUE)