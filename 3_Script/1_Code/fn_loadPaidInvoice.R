loadPaidDeliveryInvoiceData <- function(deliveryInvoiceFile){
    
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
    
    paidDeliveryInvoice <- NULL
    for (file in list.files(deliveryInvoiceFile)){
        if(file_ext(file)=="csv"){
            currentFile <- read.csv2(file.path(deliveryInvoiceFile,file),
                                     quote = '"',
                                     col.names = c("Tracking_number","TGL_ENTRY","Order_Nr",
                                                   "Destination_Code","Qty","Weight",
                                                   "GOOD_Values","Insurance","Amount",
                                                   "Instruction","Service","Status"),
                                     colClasses = c("myTrackingNumber","myDate","myInteger",
                                                    "character","myInteger","myNumeric",
                                                    "myNumeric","myNumeric","myNumeric",
                                                    "character","character","factor"))
            
            currentFile %<>%
                filter(!is.na(Tracking_number) & Tracking_number!='')
            currentFile %<>% mutate(InvoiceFile=file)
            
            if (is.null(paidDeliveryInvoice))
                paidDeliveryInvoice <- currentFile
            else
                paidDeliveryInvoice <- rbind_list(paidDeliveryInvoice,currentFile)
        }
    }
    
    paidDeliveryInvoice
}


loadPaidCODInvoiceData <- function(CODInvoiceFile){
    
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
    
    paidCODInvoice <- NULL
    for (file in list.files(deliveryInvoiceFile)){
        if(file_ext(file)=="csv"){
            currentFile <- read.csv2(file.path(invoiceCODFolder,file),
                                     quote = '"',
                                     col.names = c("Tracking_number","TGL_ENTRY","Order_Nr",
                                                   "Destination_Code","Qty","Weight",
                                                   "GOOD_Values","Management_Fee","Instruction",
                                                   "Service","Status"),
                                     colClasses = c("myTrackingNumber","myDate","myInteger",
                                                    "character","myInteger","myNumeric",
                                                    "myNumeric","myNumeric","myNumeric",
                                                    "character","factor"))
            currentFile %<>%
                filter(!is.na(Tracking_number) & Tracking_number!='')
            currentFile %<>% mutate(InvoiceFile=file)
            
            
            if (is.null(paidCODInvoice))
                paidCODInvoice <- currentFile
            else
                paidCODInvoice <- rbind_list(paidCODInvoice,currentFile)
            
        }
    }
    paidCODInvoice
}