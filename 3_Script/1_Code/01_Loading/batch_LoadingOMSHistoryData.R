source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOIHistoryData.R")

flog.info("Update History Data", name = reportName)
soiHistoryData <- UpdateSOIHistoryData(dateBegin = NULL, extractLength = 10,
                                       server = serverIP, username = user,
                                       password = password)