loadDeliveryInvoiceData <- function(invoiceDeliveryFile){
    
    require(dplyr,quietly = TRUE)
    require(tools,quietly = TRUE)
    require(magrittr,quietly = TRUE)
    require(methods, quietly= TRUE)
    
    setClass("myDate")
    setAs("character","myDate", function(from) as.POSIXct(substr(from,1,10), format="%Y-%m-%d"))
    setClass("myInteger")
    setAs("character","myInteger", function(from) as.integer(gsub(',','',from)))
    setClass("myNumeric")
    setAs("character","myNumeric", function(from) as.numeric(gsub(',','',from)))
    setClass("myTrackingNumber")
    setAs("character","myTrackingNumber", function(from) gsub('^0','',from))
    
    currentFile <- read.csv2(invoiceDeliveryFile,
                             quote = '"',
                             col.names = c("Tracking_number","TGL_ENTRY","Order_Nr",
                                           "Destination_Code","Qty","Weight",
                                           "GOOD_Values","Insurance","Amount",
                                           "Instruction","Service","Status"),
                             colClasses = c("myTrackingNumber","myDate","myInteger",
                                            "character","myInteger","myNumeric",
                                            "myNumeric","myNumeric","myNumeric",
                                            "character","character","character"))
    
    currentFile %<>%
        filter(!is.na(Tracking_number) & Tracking_number!='')
    currentFile
}

loadCODInvoiceData <- function(invoiceCODFile){
    
    require(dplyr,quietly = TRUE)
    require(tools,quietly = TRUE)
    require(magrittr,quietly = TRUE)
    require(methods, quietly= TRUE)
    
    setClass("myDate")
    setAs("character","myDate", function(from) as.POSIXct(substr(from,1,10), format="%Y-%m-%d"))
    setClass("myInteger")
    setAs("character","myInteger", function(from) as.integer(gsub(',','',from)))
    setClass("myNumeric")
    setAs("character","myNumeric", function(from) as.numeric(gsub(',','',from)))
    setClass("myTrackingNumber")
    setAs("character","myTrackingNumber", function(from) gsub('^0','',from))
    
    currentFile <- read.csv2(invoiceCODFile,
                             quote = '"',
                             col.names = c("Tracking_number","TGL_ENTRY","Order_Nr",
                                           "Destination_Code","Qty","Weight",
                                           "GOOD_Values","Management_Fee","Instruction",
                                           "Service","Status"),
                             colClasses = c("myTrackingNumber","myDate","myInteger",
                                            "character","myInteger","myNumeric",
                                            "myNumeric","myNumeric","myNumeric",
                                            "character","character"))
    currentFile %<>%
        filter(!is.na(Tracking_number) & Tracking_number!='')
    
    
    currentFile
}