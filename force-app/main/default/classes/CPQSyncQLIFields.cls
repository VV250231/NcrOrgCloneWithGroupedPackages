//Its test class is in Product2TriggerTest
/*
ModificationDate			ModifiedBy			Description 				                                                     
28-JUN-2022					Dharmendra			QLI Fields Update when Product2 Interchange and BlendedRate % updated, Only quotes have status one of
												Draft, Inreveiew and Returned only updated.
												SFCPQBLG-669 Manage rates for Headline ACV/TCV calculation at global level
*/
global  class CPQSyncQLIFields implements Database.Batchable<sObject>,Database.Stateful{
    
    public CPQSyncQLIFields(){}
    
    public map<Id, Product2> mpChangedProduct = new map<Id, Product2>();
    
    global CPQSyncQLIFields(map<Id, Product2> mpChangedProduct) { 
        this.mpChangedProduct = mpChangedProduct;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> allProd2Ids = new Set<Id>(mpChangedProduct.keySet());
        
        return DataBase.getQueryLocator([SELECT Id, qtc_Blended_Rate_Percentage__c,	qtc_Interchange_Cost_Percentage__c, SBQQ__Product__c, SBQQ__Quote__c,
                                         SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Product__r.Id, SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Approved', 'Approved - Payments Team')
                                         AND SBQQ__Product__c IN :allProd2Ids]);
    }
    
    global void execute(Database.BatchableContext BC,List<SBQQ__QuoteLine__c> listQLI) {
        Map<Id, SBQQ__QuoteLine__c> uptQLIMap = new Map<Id, SBQQ__QuoteLine__c>();
        List <String> errorMsgList=new List <string>();
        
        for(SBQQ__QuoteLine__c QLI : listQLI) {
            QLI.qtc_Blended_Rate_Percentage__c = mpChangedProduct.get(QLI.SBQQ__Product__r.Id).qtc_Blended_Rate_Percentage__c;
            QLI.qtc_Interchange_Cost_Percentage__c = mpChangedProduct.get(QLI.SBQQ__Product__r.Id).qtc_Interchange_Cost_Percentage__c;
        }
        try{
            SBQQ.TriggerControl.disable();
            Database.SaveResult[] srListS=Database.update(listQLI, false);
            integer j=0;
            for (Database.SaveResult sr : srListS) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                           
                        errorMsgList.add('product change failed for  Quote Line : |'+listQLI[j] + '| Product: '+listQLI[j].SBQQ__Product__r.Name+' Error: '+err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
                j++;
            }  
        }catch(Exception e) { 
            List <String> listQLITemp=new List <string>();
            for(SBQQ__QuoteLine__c i:listQLI){
                listQLITemp.add(i.Id);
            }
            sendEmail(listQLITemp,'Exception Occured is:'+e.getMessage()+'<Br/>'+e.getStackTraceString());  
        } finally {
            SBQQ.TriggerControl.enable(); 
        }
        if(errorMsgList.size()>0){ 
            sendEmail(errorMsgList, 'Please retrigger or resolve issue for each individual Records below:');
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    public void sendEmail(List<String> bdy, string ex) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //To-Do update email, good to take form cusotm setting rather than Hardcoding..
        //ITS, Salesforce Support <NI230017@ncr.com>
        message.toAddresses = new String[] {'NI230017@ncr.com'};
        message.subject =  'Sync QLI issue for Product Change';
        String err='';
        for(String s:bdy){
            err=err+'<br/>'+s;
        }
        message.htmlbody =ex+ '<br/> Following Quote Lines have issue, Please take appropriate action:'+err;        
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
}