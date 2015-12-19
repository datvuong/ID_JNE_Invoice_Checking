source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOIData.R")
source("3_Script/1_Code/01_Loading/UpdatePackageData.R")
source("3_Script/1_Code/01_Loading/UpdateSOIHistoryData.R")
source("3_Script/1_Code/01_Loading/UpdateSOITimeStamp.R")
source("3_Script/1_Code/01_Loading/UpdateSOIBaseData.R")
source("3_Script/1_Code/01_Loading/BuildPackageData.R")

if (file.exists("1_Input/RData/soiData.RData")) {
  load("1_Input/RData/soiData.RData")
} else {
  soiData <- NULL
}
if (file.exists("1_Input/RData/packageData.RData")) {
  load("1_Input/RData/packageData.RData")
} else {
  packageData <- NULL
}
if (file.exists("1_Input/RData/soiData.RData")) {
  load("1_Input/RData/soiHistoryData.RData")
} else {
  soiHistoryData <- NULL
}

soiData <- UpdateSOIData(soiData, upToDate = Sys.Date(), 
                         server = serverIP, username = user, password = password)
save(soiData, file = "1_Input/RData/soiData.RData")

packageData <- UpdatePackageData(packageData, upToDate = Sys.Date(), 
                                 server = serverIP, username = user, password = password)
save(packageData, file = "1_Input/RData/packageData.RData")

soiHistoryData <- UpdateSOIHistoryData(soiHistoryData, upToDate = "2015-12-01", 
                                       server = serverIP, username = user, password = password)
save(soiHistoryData, file = "1_Input/RData/soiHistoryData.RData")

soiTimestampData <- UpdateSOITimeStamp(soiHistoryData)

soiBasedData <- UpdateSOIBaseData(soiData, packageData, soiTimestampData)

packageBaseData <- BuildPackageData(soiBasedData)
save(packageData, file = "1_Input/RData/packageBaseData.RData")
