loadEWIData <- function(ewiFolder){
    
    require(dplyr,quietly = TRUE)
    require(tools,quietly = TRUE)
    require(magrittr,quietly = TRUE)
    require(methods, quietly= TRUE)
    
    setClass("myDate")
    setAs("character","myDate", function(from) as.POSIXct(substr(from,1,10), format="%Y-%m-%d"))
    setClass("myInteger")
    setAs("character","myInteger", function(from) as.integer(gsub(',','',from)))
    setClass("myDateTime")
    setAs("character","myDateTime", function(from) as.POSIXct(from, format="%Y-%m-%d %H:%M:%S"))
    
    
    ewiData <- NULL
    for (file in list.files(ewiFolder)){
        if (file_ext(file)=="csv"){
            currentFile <- read.csv(file.path(ewiFolder,file),
                                    col.names = c("SAP_item_ID","order_no","sales_order_item",
                                                  "sc_sales_order_item","SKU","AWB",
                                                  "Shipment_Provider_Name","order_date","seller_name",
                                                  "payment_method","payment_verification_status","payment_verification_date",
                                                  "item_status","shipped_date","delivered_date",
                                                  "delivered_date_input","returned_date","unit_price",
                                                  "paid_price","sc_order_item","item_price_credit",
                                                  "seller_credit","shipping_fee_credit","commission",
                                                  "payment_fee","item_price","commission_credit",
                                                  "return_to_seller_fee","shipping_fee","other_fee",
                                                  "payout","opening_balance","amount_paid_to_seller",
                                                  "time_frame","coupon_money_value","cart_rule_discount",
                                                  "gross_commission_income","VAT_OUT","time_frame_end",
                                                  "seller_id","description","zone",
                                                  "transaction_date","transaction_id"),
                                    colClasses = c("integer","integer","integer",
                                                   "integer","character","character",
                                                   "factor","myDateTime","character",
                                                   "factor","factor","myDateTime",
                                                   "factor","myDateTime","myDateTime",
                                                   "myDateTime","myDateTime","numeric",
                                                   "numeric","integer","numeric",
                                                   "numeric","numeric","numeric",
                                                   "numeric","numeric","numeric",
                                                   "numeric","numeric","numeric",
                                                   "numeric","numeric","numeric",
                                                   "myDateTime","numeric","numeric",
                                                   "numeric","numeric","myDateTime",
                                                   "integer","character","factor",
                                                   "myDateTime","character"))
            
            if (is.null(ewiData))
                ewiData <- currentFile
            else
                ewiData <- rbind_list(ewiData, currentFile)
            
        }
    }
    
    ewiData
}