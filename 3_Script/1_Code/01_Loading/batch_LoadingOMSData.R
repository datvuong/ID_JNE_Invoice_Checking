source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOIData.R")

flog.info("Update SOI Data", name = reportName)
soiData <- UpdateSOIData(dateBegin = NULL, extractLength = 10,
                         server = serverIP,
                         username = user, password = password)

flog.info("Done", name = reportName)


