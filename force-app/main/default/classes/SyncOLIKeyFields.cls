//Its test class is in Product2TriggerTest
global  class SyncOLIKeyFields implements Database.Batchable<sObject>,Database.Stateful{
    global static boolean RunSyncOli = true;
    public map<Id, Product2> mpChangedProduct = new map<Id, Product2>();
    public Set<Id> subtoNonSubProdList = new Set<Id>(); 
    public Set<Id> nonSubtoSubProdList = new Set<Id>(); 
    global set<Id> OppIds = new Set<Id>();
    
    global SyncOLIKeyFields(map<Id, Product2> mpChangedProduct, Set<Id> subtoNonSubProdList, Set<Id> nonSubtoSubProdList) { 
        this.mpChangedProduct = mpChangedProduct;
        this.subtoNonSubProdList = subtoNonSubProdList;
        this.nonSubtoSubProdList = nonSubtoSubProdList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> allProd2Ids = new Set<Id>(mpChangedProduct.keySet());
        allProd2Ids.addAll(subtoNonSubProdList);
        allProd2Ids.addAll(nonSubtoSubProdList);
        
        return DataBase.getQueryLocator([Select Id,OpportunityId,Is_Subscriptioned__c, Product2Id, Topline_Product_Lkp__c, Topline_Product_Lkp__r.Name, Opportunity.CPQ__c,Product2.Name, Quantity, UnitPrice, TotalPrice, One_Time_Fee__c, 
                                         Monthly_Fee__c,Number_of_Terms__c, Sites__c, Actual_Contract_Value__c, Total_Cost_Value__c, Source__c, IsPackageLine__c, Opportunity.isClosed 
                                         From OpportunityLineItem where Topline_Product_Lkp__c IN :allProd2Ids]);
    }
    global void execute(Database.BatchableContext BC,List<OpportunityLineItem> listOfOLI) {
        Map<Id, OpportunityLineItem> updateOLIMap = new Map<Id, OpportunityLineItem>();
        List <String> errorMsgList=new List <string>();
        set<Id> batchOppIds = new Set<Id>();
        Set<Id> mpchangedProductIds = mpChangedProduct.keySet();
        
        for(OpportunityLineItem OLI : listOfOLI) {
            if (mpchangedProductIds.contains(OLI.Topline_Product_Lkp__c)) {
                OppIds.add(OLI.OpportunityId);
                batchOppIds.add(OLI.OpportunityId);
                updateOLIMap.put(OLI.Id, OLI);  
            }
            
            if(String.isBlank(OLI.Source__c)) { // Non-Package Product
                if (!OLI.Opportunity.CPQ__c && subtoNonSubProdList.contains(OLI.Topline_Product_Lkp__c) && (!OLI.Opportunity.isClosed) && (OLI.Is_Subscriptioned__c == true)) {
                    OLI.One_Time_Fee__c = 0;  OLI.Monthly_Fee__c = 0;  OLI.Actual_Contract_Value__c = 0; OLI.Total_Cost_Value__c = 0;
                    OLI.Number_of_Terms__c = null;    OLI.Sites__c = null;OLI.Is_Subscriptioned__c = false; batchOppIds.add(OLI.OpportunityId);
                    if(!updateOLIMap.containsKey(OLI.Id)) updateOLIMap.put(OLI.Id, OLI);    
                }
                
                else if (!OLI.Opportunity.CPQ__c && nonSubtoSubProdList.contains(OLI.Topline_Product_Lkp__c) && OLI.Is_Subscriptioned__c == false) {
                    OLI.One_Time_Fee__c = 0;
                    OLI.Monthly_Fee__c = OLI.UnitPrice;
                    OLI.Actual_Contract_Value__c = OLI.TotalPrice;
                    OLI.Total_Cost_Value__c = OLI.TotalPrice;
                    OLI.Number_of_Terms__c = 1;
                    OLI.Sites__c = OLI.Quantity;      
                    OLI.Is_Subscriptioned__c = true;
                    
                    batchOppIds.add(OLI.OpportunityId);
                    if(!updateOLIMap.containsKey(OLI.Id)) updateOLIMap.put(OLI.Id, OLI);
                }
            }
        }
        RunSyncOli = false;
        //System.debug('inside batch'+listOfOLI);
        try{
            if(!updateOLIMap.isEmpty()) {
                List<OpportunityLineItem> updateOLIList = updateOLIMap.values(); 
                Database.SaveResult[] srListS=Database.update(updateOLIList, false);
                integer j=0;
                for (Database.SaveResult sr : srListS) {
                    if (!sr.isSuccess()){
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {                           
                            errorMsgList.add('Key field of product change failed for  Opportunity : |'+updateOLIList[j].OpportunityId + '| Product: '+updateOLIList[j].Product2.Name+' Error: '+err.getStatusCode() + ': ' + err.getMessage());
                            
                        }
                    }
                    j++;
                }  
            }  
        }catch(Exception e) { List <String> oppList=new List <string>();
            for(id i:batchOppIds){ oppList.add(i) ;
            }
            sendEmail(oppList,'Exception Occured is:'+e.getMessage()+'<Br/>'+e.getStackTraceString());  
        }
        if(errorMsgList.size()>0){ sendEmail(errorMsgList, 'Please retrigger or resolve issue for each individual Records below:');
        }
        RunSyncOli = true;
    }
    global void finish(Database.BatchableContext BC) {
        
        if(OppIds.size()>0)
            system.enqueueJob(new SyncOli(OppIds));
        system.debug('Batch Processing Finish..');
    }
    public void sendEmail(List<String> bdy, string ex) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.toAddresses = new String[] { 'pb185126@ncr.com','ad250024@ncr.com', 'ak250921@ncr.com', 'NS230220@ncr.com'};
            message.subject =  'Sync OLI issue for Product Change';
        String err='';
        for(String s:bdy){
            err=err+'<br/>'+s;
        }
        message.htmlbody =ex+ '<br/> Following Opportunities have issue, Please take appropriate action:'+err;        
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }
}