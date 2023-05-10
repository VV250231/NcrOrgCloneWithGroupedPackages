Global class AutoPaySetupReport implements Schedulable {
    public Id salesrepId1{get;set;}

     public String getInstanceURL(){
        return System.URL.getSalesforceBaseURL().toExternalForm();
    }

    public List<SBQQ__Quote__c> getdocList() {      
        List<SBQQ__Quote__c> QuoteList = [SELECT id,Name,SBQQ__Account__r.Name,qtc_Bill_To_Site__r.name, qtc_Bill_To_Site__r.Site_Number__c, SBQQ__Account__r.Master_Customer_Number__c,SBQQ__SalesRep__c,qtc_Legal_Document_Status__c,SBQQ__SalesRep__r.email,SBQQ__SalesRep__r.ManagerId,
                                       (SELECT id,Customer_Signature_Date__c FROM Customer_Documents__r wHERE Document_Status__c = 'Completed' AND
                                        (Document_Type__c ='AE Order Form' OR Document_Type__c = 'AE Amendment') order by Customer_Signature_Date__c DESC limit 1)
                                       FROM SBQQ__Quote__c wHERE AutoPay_Setup__c not in ('True', 'Manual') AND qtc_Legal_Document_Status__c = 'Completed' AND
                                      SBQQ__SalesRep__c =: salesrepId1 AND qtc_Payments_Only_Quote__c = 'No' AND SBQQ__Ordered__c = false];
        return QuoteList;
    }

    global void execute(SchedulableContext sc){
        set<Id> Managerids = new set<Id>();
        Map<id,String> SalesRepsEmailMap = new Map<id,String>();
        Map<id,String> SalesRepsMgrEmailMap = new Map<id,String>();
        map<id,User> mgrUser;
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='CPQ_Quote_with_FO_for_SalesReps'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce.donotreply@ncr.com'];
        
        List<SBQQ__Quote__c> QtList = [SELECT id,SBQQ__SalesRep__c,SBQQ__SalesRep__r.email,SBQQ__SalesRep__r.ManagerId,
                                       (SELECT id,Customer_Signature_Date__c FROM Customer_Documents__r wHERE Document_Status__c = 'Completed' AND
                                        (Document_Type__c ='AE Order Form' OR Document_Type__c = 'AE Amendment') order by Customer_Signature_Date__c DESC limit 1)
                                       FROM SBQQ__Quote__c wHERE AutoPay_Setup__c not in ('True', 'Manual') AND qtc_Legal_Document_Status__c = 'Completed' AND
                                       qtc_Payments_Only_Quote__c = 'No' AND SBQQ__Ordered__c = false];


        for(SBQQ__Quote__c QtL : QtList){
            if(QtL.SBQQ__SalesRep__r.ManagerId != null){
                Managerids.add(QtL.SBQQ__SalesRep__r.ManagerId);
            }
        }
        if(Managerids.size()>0){
            mgrUser = new map<id,User>([Select id,Email from User where id in :Managerids]);
        }
        for(SBQQ__Quote__c QtL1 : QtList){
            if(QtL1.SBQQ__SalesRep__r != null){
                SalesRepsEmailMap.put(QtL1.SBQQ__SalesRep__c,QtL1.SBQQ__SalesRep__r.Email);
            }
            if(QtL1.SBQQ__SalesRep__r.ManagerId != null){
                SalesRepsMgrEmailMap.put(QtL1.SBQQ__SalesRep__c, mgrUser.get(QtL1.SBQQ__SalesRep__r.ManagerId).Email);
            }
        }
        if(SalesRepsEmailMap.size()>0){
            sendEmail(owea,et,SalesRepsEmailMap,SalesRepsMgrEmailMap);
        }
        
    }
   @TestVisible public static void sendEmail(OrgWideEmailAddress[] owea, EmailTemplate et,Map<id,String> SalesReps,Map<id,String> SalesRepsMgr){
       try{
           List<Messaging.SingleEmailMessage> lstMessages = new List<Messaging.SingleEmailMessage>();           
           for(Id salesrepid : SalesReps.keySet()){                
               Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
               message.setSaveAsActivity(false);
               if ( owea.size() > 0 ) {
                   Message.setOrgWideEmailAddressId(owea.get(0).Id);
               }
               message.setTemplateId(et.Id);
               message.setTargetObjectId(salesrepid);
               message.setTreatTargetObjectAsRecipient(false); 
               message.setWhatId(salesrepid);
               if(SalesRepsMgr.get(salesrepid) != null){
                   message.toAddresses = new List<String> {SalesReps.get(salesrepid),SalesRepsMgr.get(salesrepid)};
                       }
               else{
                   message.toAddresses = new List<String> {SalesReps.get(salesrepid)};
                       }
               lstMessages.add(message);
           }
           List<Messaging.SendEmailResult> lstResults = Messaging.sendEmail(lstMessages);
       } 
       catch (Exception ex) {
            system.debug('***'+ex.getLineNumber());
            system.debug('***'+ex.getMessage());
            system.debug('***'+ex.getCause());
            system.debug('***'+ex.getStackTraceString());
       }
   }    
}