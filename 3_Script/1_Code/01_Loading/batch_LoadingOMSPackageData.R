source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdatePackageData.R")

flog.info("Update Pacakge Data", name = reportName)
packageData <- UpdatePackageData(dateBegin = NULL, extractLength = 10,
                                 server = serverIP, username = user,
                                 password = password)