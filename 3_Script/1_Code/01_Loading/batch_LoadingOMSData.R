source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOIData.R")
source("3_Script/1_Code/01_Loading/UpdatePackageData.R")
source("3_Script/1_Code/01_Loading/UpdateSOIHistoryData.R")
source("3_Script/1_Code/01_Loading/UpdateSOITimeStamp.R")
source("3_Script/1_Code/01_Loading/UpdateSOIBaseData.R")
source("3_Script/1_Code/01_Loading/BuildPackageData.R")

flog.info("Update SOI Data", name = reportName)
soiData <- UpdateSOIData(dateBegin = NULL, extractLength = 10,
                         server = serverIP,
                         username = user, password = password)
flog.info("Update Pacakge Data", name = reportName)
packageData <- UpdatePackageData(dateBegin = NULL, extractLength = 10,
                                 server = serverIP, username = user, password = password)
flog.info("Update History Data", name = reportName)
soiHistoryData <- UpdateSOIHistoryData(dateBegin = NULL, extractLength = 10,
                                       server = serverIP, username = user, password = password)

# loginfo("Consolidate OMS Data", logger = consoleLog)
# soiTimestampData <- UpdateSOITimeStamp(soiHistoryData)
# soiBasedData <- UpdateSOIBaseData(soiData, packageData, soiTimestampData)
# packageBaseData <- BuildPackageData(soiBasedData)
# save(packageBaseData, file = "1_Input/RData/packageBaseData.RData",
#      compress = TRUE)
flog.info("Done", name = reportName)
