source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOIData.R")
source("3_Script/1_Code/01_Loading/UpdatePackageData.R")
source("3_Script/1_Code/01_Loading/UpdateSOIHistoryData.R")
source("3_Script/1_Code/01_Loading/UpdateSOITimeStamp.R")
source("3_Script/1_Code/01_Loading/UpdateSOIBaseData.R")
source("3_Script/1_Code/01_Loading/BuildPackageData.R")

loginfo("Update SOI Data", logger = consoleLog)
soiData <- UpdateSOIData(dateBegin = NULL, server = serverIP,
                         username = user, password = password)
loginfo("Update Pacakge Data", logger = consoleLog)
packageData <- UpdatePackageData(dateBegin = NULL, server = serverIP,
                                 username = user, password = password)
loginfo("Update History Data", logger = consoleLog)
soiHistoryData <- UpdateSOIHistoryData(dateBegin = NULL,
                                       server = serverIP, username = user, password = password)

loginfo("Consolidate OMS Data", logger = consoleLog)
soiTimestampData <- UpdateSOITimeStamp(soiHistoryData)
soiBasedData <- UpdateSOIBaseData(soiData, packageData, soiTimestampData)
packageBaseData <- BuildPackageData(soiBasedData)
save(packageBaseData, file = "1_Input/RData/packageBaseData.RData",
     compress = TRUE)
loginfo("Done", logger = consoleLog)
