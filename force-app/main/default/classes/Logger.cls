/**
* @author          
* @date            
* @description - Common logger, which extends the basic logging functionality of Force.com
*/

global with sharing class Logger {

    private Log_Opportunity_Linkage__c debugLog;
   
    public Logger() {
        debugLog = new Log_Opportunity_Linkage__c();
    }
    
  
   public void logRequest(QuoteObject reqInput) {
            if (this.debugLog == null) {
                debugLog = new Log_Opportunity_Linkage__c();
            }
            
            if(reqInput != null){
                QuoteObject quoteObj = reqInput; 
                debugLog.name = quoteObj.userQuickLookId + ' : ' + Datetime.now();
                debugLog.Application_Name__c = quoteObj.appName;
                debugLog.Quote_Name_Opportunity_Detail__c  = quoteObj.quoteName;
                debugLog.Quote_Number__c = quoteObj.quoteNumber;
                debugLog.ERP_Order_Number__c = quoteObj.ERPOrderNumber;
                debugLog.MCN__c = quoteObj.MCN;
                debugLog.Quote_Amount__c = quoteObj.quoteAmount;
                debugLog.Quote_Currency__c = quoteObj.quoteCurrency;
                debugLog.Date_Submitted__c = quoteObj.submittedDate;
                debugLog.Last_Modified_Date__c = quoteObj.lastModifiedDate;
                debugLog.Version_Number__c = quoteObj.versionNumber;
                debugLog.Status__c = quoteObj.Status;
                debugLog.Opportunity_Number__c = quoteObj.opportunityNumber;
                debugLog.Account_Country_Code__c  = quoteObj.accountCountryCode;
                debugLog.QuickLook_ID__c = quoteObj.userQuickLookId;    
               
                if(debugLog != null) {
                    insert debugLog; 
                } 
            }
    }
    
    
    public void logResponse(QuoteResponse quoteRes, QuoteObject reqInput) {
        if (this.debugLog == null || this.debugLog.Id == null) {
            debugLog = new Log_Opportunity_Linkage__c();
            
            if(reqInput != null) {
                debugLog.name = reqInput.userQuickLookId + ' : ' + Datetime.now();
            } else {
                debugLog.name = ' :'+ Datetime.now();
            }
            debugLog.Log_Detail__c = String.valueOf(reqInput);     
        }
        
        this.debugLog.Response__c = quoteRes.status;
        if (quoteRes.message != null && quoteRes.message.length() > 255) {   
            this.debugLog.Error_Message__c = quoteRes.message.subString(0, 255);     
        } else {
            this.debugLog.Error_Message__c = quoteRes.message;
        }
        this.debugLog.Output_Quote__c = quoteRes.output;
        upsert debugLog;
   }
   
   
   
     @future
     public static void logSearchCall(String strReq, String strRes) {
         Log_Opportunity_Linkage__c logObj;
         
         try {
             if (!String.isEmpty(strReq)) {
                 logObj = new Log_Opportunity_Linkage__c(); 
                 OppQuoteLinkageController.OppSearchRequest searchReq = (OppQuoteLinkageController.OppSearchRequest) JSON.deserialize(strReq, OppQuoteLinkageController.OppSearchRequest.Class);
                 logObj.name = searchReq.custNumber + ' : ' + Datetime.now();
                 logObj.Application_Name__c = 'Opportunity Search';
                 logObj.MCN__c = searchReq.custNumber;
                 logObj.Quote_Name_Opportunity_Detail__c = 'Opportunity Name:' +  searchReq.oppNameOPR + ':' + searchReq.oppName
                                                            + '\n' +  'Opportunity Number:' + searchReq.oppNumberOPR + ':' + searchReq.oppNumber;
                 logObj.QuickLook_ID__c = searchReq.userQuickLookId;
                 logObj.Account_Country_Code__c  = searchReq.accCountryCode; 
                 //logObj.Log_Detail__c=searchReq.;
             } 
             
             if (!String.isEmpty(strRes)) {
                 OppQuoteLinkageController.OppSearchResponse  searchResp =  (OppQuoteLinkageController.OppSearchResponse) JSON.deserialize(strRes, OppQuoteLinkageController.OppSearchResponse.Class);   
                 if(logObj == NULL) {
                     logObj = new Log_Opportunity_Linkage__c(); 
                     logObj.Name = 'Opp Search' + ':' + Datetime.now();
                     logObj.Log_Detail__c = strReq;
                 }
                 logObj.Response__c = searchResp.status;
                 
                 if (searchResp.message != null && searchResp.message.length() > 255) {   
                    logObj.Error_Message__c = searchResp.message.subString(0, 255);     
                 } else {
                    logObj.Error_Message__c = searchResp.message;
                 }  
             }
             
             if(logObj != null) {
                 insert logObj ; 
             }
         } catch(Exception e) {
             logObj = new Log_Opportunity_Linkage__c(); 
             logObj.Name = 'Opp Search' + ':' + Datetime.now();
             logObj.Log_Detail__c = strReq;
             String errMsg = e.getMessage();
             
             if (errMsg.length() > 255) {   
                logObj.Error_Message__c = errMsg.subString(0, 255);     
             } else {
                logObj.Error_Message__c = errMsg;
             }  
             insert logObj;
         }
         
     }
     
     @future
     public static void logSOUPGetQuotes(String quoteIds) {
         Log_Opportunity_Linkage__c logObj = new Log_Opportunity_Linkage__c();
         logObj.name = 'SOUP GET QUOTE';
         logObj.Application_Name__c = 'SOUP GET QUOTE';
         logObj.Last_Modified_Date__c = Datetime.now();
         logObj.Log_Detail__c = quoteIds; 
         
         insert logObj;
     }
     
     @future
     public static void logProvisioningUpdate(ID id , String QuoteNumber, String ProvisioningStatus , String StatusDetails , Date QuoteStartDate, String response) {
          Log_Opportunity_Linkage__c logObj = new Log_Opportunity_Linkage__c();
          logObj.name = QuoteNumber; 
          logObj.Application_Name__c = 'Provisioing Update';
          logObj.Last_Modified_Date__c = Datetime.now();
          String quotedetail = 'Request:: ID :'+ id +  ',QuoteNumber: ' + QuoteNumber + ' ,ProvisioningStatus: ' + ProvisioningStatus+ ' ,StatusDetails: ' + StatusDetails + ' ,QuoteStartDate: ' + QuoteStartDate;
          
          quotedetail += '\n Response:' + response;
          quotedetail += ', Database Detail :' + [Select Id, Provisioning_Status__c FRom zqu__Quote__c Where Id = :id LIMIT 1].get(0);
          logObj.Log_Detail__c = quotedetail; 
          
          if(response != NULL && response.startsWith('Error')) {
              logObj.Response__c = 'Error';
          } else {
              logObj.Response__c = 'Success';
          }
          
          insert logObj;
     }
   
     public Static void logMessage(String app, String msg, String status) {
         Log_Opportunity_Linkage__c logObj = new Log_Opportunity_Linkage__c();    
         logObj.name = app;
         logObj.Application_Name__c = app;
         logObj.Log_Detail__c = msg;
         logObj.Status__c = status;
         
         insert logObj;
     }
     
}