public with sharing class CPQ_Util {
    
    private static final String QUOTE_TYPE_AMENDEMENT = 'Amendment';
    private static final String QUOTE_TYPE_QUOTE = 'Quote';
    // Retrun value if String variable is not null else return empty string.
    public static String safeString(String val) {
        String returnVal = '';
        if (val != null) {
            returnVal = val;
        }
        return returnVal;
    }
    
    // MCN account information
    public static Account getAccount(String masterCustomerNumber) {
        Account act;
        
        if (String.isBlank(masterCustomerNumber)) {
            return null;
        } else {
            List<Account> actLst = [SELECT Id, Name, Master_Customer_Number__c 
                                    FROM Account WHERE Master_Customer_Number__c =: masterCustomerNumber];
            if (!actLst.isEmpty()) {
                act = actLst[0];
            }
        }
        return act;
    }
    
    // Returns bill to site information based on site number.
    public static Account getSite(String siteNumber) {
        Account act;
        
        if (String.isBlank(siteNumber)) {
            return null;
        } else {
            List<Account> actLst = [SELECT Id, Name, Site_Number__c, ParentId 
                                    FROM Account WHERE Site_Number__c =: siteNumber];
            if (!actLst.isEmpty()) {
                act = actLst[0];
            }
        }
        return act;
    }
    
    
    // This method is to capture Interface Log
    public boolean createLog(String transactionID,String status, String interfaceMessage,  String request, 
                             String response,String requestType, qtc_FulfillmentOrder__c  fo,
                             Id quote,Id opp, String interfaceType) {
                                 Interface_Log__c obj=  new Interface_Log__c();
                                 obj.Request__c = request;
                                 obj.Response__c = response;
                                 obj.RequestType__c	 = requestType;
                                 obj.Status__c = status;
                                 obj.Transaction_ID__c = transactionID;
                                 if( fo != null){
                                     
                                     obj.Sequence_Number__c	= fo.qtc_Sequence_Number__c	;
                                     obj.Retry_Attempt__c = fo.Retry_Attempt__c;
                                     obj.Fulfillment_Order__c = fo.id;
                                     
                                 }
                                 obj.Quote__c = quote;
                                 obj.Opportunity__c = opp;
                                 obj.Message__c = interfaceMessage;
                                 obj.Interface_Type__c = interfaceType;
                                 
                                 try{
                                     
                                     Insert obj; 
                                     return true;
                                     
                                 }catch(Exception e){
                                     return false;
                                 }
                                 
                                 
                             } 
    
    public String getRequestJSONAsString(RestRequest request){
        if(request!=null){
            return request.requestBody.toString();
        }else{
            return request.toString();
        }
    }
    
    public String getResponseJSONAsString(RestResponse response){
        return response.responseBody.toString();
    }
    public String getRequestJSONAsString(HttpRequest request){
        if(request!=null){
            return String.valueOf(request.getBody());
        }else{
            return String.valueOf(request);
        }
    }
    
    public String getResponseJSONAsString(HttpResponse response){
        return String.valueOf(response);
    }
    
    public string dateString(Datetime dt) {
        if(dt!=null){
            String myDatetime;
            string day;
            string month;
            string year;
            integer i;
            myDatetime = String.valueOfGmt(dt);
            string[] dttime = myDatetime.split('-');
            year = dttime[0];
            i = Integer.valueOf(dttime[1]);//month
            day = dttime[2].split(' ')[0];
            if(i==1){
                month = 'JAN';
            }else if(i==2){
                month = 'FEB';
            }
            else if(i==3){
                month = 'MAR';
            }
            else if(i==4){
                month = 'APR';
            }
            else if(i==5){
                month = 'MAY';
            }
            else if(i==6){
                month = 'JUN';
            }
            else if(i==7){
                month = 'JUL';
            }
            else if(i==8){
                month = 'AUG';
            }
            else if(i==9){
                month = 'SEP';
            }
            else if(i==10){
                month = 'OCT';
            }
            else if(i==11){
                month = 'NOV';
            }
            else if(i==12){
                month = 'DEC';
            }
            return (day+'-'+month+'-'+year);
        } Else {
            return '';
        }
    }
    
    public static Boolean getQulifiedQuotesForAlert(ID quoteID) {
             
        // Start
        SBQQ__Quote__c quoteRec = getQuotesWithCLMDoc(quoteId);
        if(quoteRec != null){
            return true;
        }else{
            return false;
        }
        
        
    }
    
    public static  SBQQ__Quote__c getQuotesWithCLMDoc(Id qid){   
        
        List<SBQQ__QuoteLine__c> qlines = [Select id,SBQQ__quote__r.qtc_Multi_Site__c,SBQQ__quote__r.qtc_Multi_Site_Type__c,SBQQ__quote__r.SBQQ__Type__c from SBQQ__QuoteLine__c where Revenue_Type__c = 'Payments Processing' and Product_Type__c = 'Sub-Package' and SBQQ__RequiredBy__c = null and SBQQ__Quote__c=:qid ];
        if (qlines.size() == 0 ) {
            SBQQ__Quote__c quote = CPQMSQuoteForAmendmentDocument.getQuoteDetailById(qid);
            if(quote.SBQQ__Type__c == QUOTE_TYPE_QUOTE){
                return [Select Name,(Select Id, Document_Status__c,Document_Type__c From Customer_Documents__r 
                                              Where Document_Type__c = 'AE Order Form'  order by LastModifiedDate desc limit 1 )
                                 From SBQQ__Quote__c where id =: qid];
                
            }else if (quote.SBQQ__Type__c == QUOTE_TYPE_AMENDEMENT){
                return [Select Name,(Select Id, Document_Status__c,Document_Type__c From Customer_Documents__r 
                                              Where Document_Type__c = 'AE Amendment'  order by LastModifiedDate desc limit 1 )
                                 From SBQQ__Quote__c where id =: qid];
            }
            return null;
        }else{
            return null;
        }
        
        
        
    }
    
}