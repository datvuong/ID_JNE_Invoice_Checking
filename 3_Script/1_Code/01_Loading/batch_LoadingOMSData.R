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

flog.info("Done", name = reportName)


