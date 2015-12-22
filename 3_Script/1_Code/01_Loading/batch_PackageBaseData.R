source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOITimeStamp.R")
source("3_Script/1_Code/01_Loading/UpdateSOIBaseData.R")
source("3_Script/1_Code/01_Loading/BuildPackageData.R")

load("1_Input/RData/soiData.RData")
load("1_Input/RData/packageData.RData")
load("1_Input/RData/soiHistoryData.RData")

flog.info("Consolidate OMS Data", name = reportName)
soiTimestampData <- UpdateSOITimeStamp(soiHistoryData)
soiBasedData <- UpdateSOIBaseData(soiData, packageData, soiTimestampData)
packageBaseData <- BuildPackageData(soiBasedData)
save(packageBaseData, file = "1_Input/RData/packageBaseData.RData",
     compress = TRUE)