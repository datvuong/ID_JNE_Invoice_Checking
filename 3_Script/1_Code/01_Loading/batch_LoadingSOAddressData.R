source("3_Script/1_Code/00_init.R")
source("1_Input/config.txt")
source("3_Script/1_Code/01_Loading/UpdateSOAddressData.R")


flog.info("Update SCSeller Data", name = reportName)
UpdateSOAddressData(server = serverIP, extractLength = 30,
                   username = user, password = password)

flog.info("Done", name = reportName)


