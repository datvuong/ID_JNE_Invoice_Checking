loadPaidDeliveryInvoiceData <- function(deliveryInvoiceFile){
  
  require(dplyr,quietly = TRUE)
  require(tools,quietly = TRUE)
  require(magrittr,quietly = TRUE)
  require(methods, quietly= TRUE)
  
  setClass("myDate")
  setAs("character","myDate", function(from) as.POSIXct(substr(from,1,10), format="%Y-%m-%d"))
  setClass("myInteger")
  setAs("character","myInteger", function(from) as.integer(gsub(',','.',
                                                                gsub('\\.','',
                                                                     gsub('[^0-9,\\.]','',from)))))
  setClass("myNumeric")
  setAs("character","myNumeric", function(from) as.numeric(gsub(',','.',
                                                                gsub('\\.','',
                                                                     gsub('[^0-9,\\.]','',from)))))
  setClass("myTrackingNumber")
  setAs("character","myTrackingNumber", function(from) gsub('^0','',from))
  
  paidDeliveryInvoice <- data.frame(tracking_number=character(),
                               TGL_ENTRY=as.POSIXct(character()),
                               Order_Nr=integer(),
                               Destination_Code=character(),
                               Qty=integer(),
                               Weight=numeric(),
                               GOOD_Values=numeric(),
                               Insurance=numeric(),
                               Amount=numeric(),
                               Instruction=character(),
                               Service=character(),
                               Status=character(),
                               InvoiceFile=character())
  
  for (file in list.files(deliveryInvoiceFile)){
    if(file_ext(file)=="csv"){
      currentFile <- read.csv2(file.path(deliveryInvoiceFile,file),
                               quote = '"',
                               col.names = c("tracking_number","TGL_ENTRY","Order_Nr",
                                             "Destination_Code","Qty","Weight",
                                             "GOOD_Values","Insurance","Amount",
                                             "Instruction","Service","Status"),
                               colClasses = c("myTrackingNumber","myDate","myNumeric",
                                              "character","myNumeric","myNumeric",
                                              "myNumeric","myNumeric","myNumeric",
                                              "character","character","character"))
      
      currentFile %<>%
        filter(!is.na(tracking_number) & tracking_number!='')
      currentFile %<>% mutate(InvoiceFile=file)
      
      if (is.null(paidDeliveryInvoice))
        paidDeliveryInvoice <- currentFile
      else
        paidDeliveryInvoice <- rbind_list(paidDeliveryInvoice,currentFile)
    }
  }
  
  paidDeliveryInvoice
}


loadPaidCODInvoiceData <- function(invoiceCODFolder){
  
  require(dplyr,quietly = TRUE)
  require(tools,quietly = TRUE)
  require(magrittr,quietly = TRUE)
  require(methods, quietly= TRUE)
  
  setClass("myDate")
  setAs("character","myDate", function(from) as.POSIXct(substr(from,1,10), format="%Y-%m-%d"))
  setClass("myInteger")
  setAs("character","myInteger", function(from) as.integer(gsub(',','.',
                                                                gsub('\\.','',
                                                                     gsub('[^0-9,\\.]','',from)))))
  setClass("myNumeric")
  setAs("character","myNumeric", function(from) as.numeric(gsub(',','.',
                                                                gsub('\\.','',
                                                                     gsub('[^0-9,\\.]','',from)))))
  setClass("myTrackingNumber")
  setAs("character","myTrackingNumber", function(from) gsub('^0','',from))
  
  paidCODInvoice <- data.frame(tracking_number=character(),
                               TGL_ENTRY=as.POSIXct(character()),
                               Order_Nr=integer(),
                               Destination_Code=character(),
                               Qty=integer(),
                               Weight=numeric(),
                               GOOD_Values=numeric(),
                               Management_Fee=numeric(),
                               Instruction=character(),
                               Service=character(),
                               Status=character(),
                               InvoiceFile=character())
  
  for (file in list.files(invoiceCODFolder)){
    if(file_ext(file)=="csv"){
      currentFile <- read.csv2(file.path(invoiceCODFolder,file),
                               quote = '"',
                               col.names = c("tracking_number","TGL_ENTRY","Order_Nr",
                                             "Destination_Code","Qty","Weight",
                                             "GOOD_Values","Management_Fee","Instruction",
                                             "Service","Status"),
                               colClasses = c("myTrackingNumber","myDate","myNumeric",
                                              "character","myNumeric","myNumeric",
                                              "myNumeric","myNumeric","character",
                                              "character","factor"))
      currentFile %<>%
        filter(!is.na(tracking_number) & tracking_number!='')
      currentFile %<>% mutate(InvoiceFile=file)
      
      
      if (is.null(paidCODInvoice))
        paidCODInvoice <- currentFile
      else
        paidCODInvoice <- rbind_list(paidCODInvoice,currentFile)
      
    }
  }
  paidCODInvoice
}