/****************************************************************************************************************
*   ClassName :   cpq_CustDocToOppSyncTrigger
*   Description :   
*   Author      :   
*   Version     :   50
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1697     4 Jan 2022      Varsha Pal               Added the criteria to check the amendment order form when autopay setup is changed to true or manual
                                                         before auto closing the CPQ opportunity
Stroy No#          Date             DevName              Description
EBA_SF-1812      15 Jan 2022       Varsha Pal            Add the logic to make the code handling as bulk instead of single record at a time
****************************************************************************************************************/
trigger cpq_CustDocToOppSyncTrigger on Customer_Document__c (after insert, after update) {
    public List<String> qIds=new List<String>();
    Boolean  ContainsAEOF= false;
    Boolean  ContainsAEMF= false;
    set<id> AccountIds= new set<id>(); 
    List<SBQQ__Quote__c> qList=new List<SBQQ__Quote__c>();
    
    if(Trigger.isAfter){
       Map<Id, Id> AEOF_QtAccMap = new  Map<Id, Id>();
        Set<Id> AEMA_AccIds = new Set<Id>();
        Set<Id> finalQtIds = new Set<Id>();
        
        for(Customer_Document__c cd : Trigger.New) {
            if(String.isNotBlank(cd.Document_Type__c) && cd.Document_Status__c == 'Completed') {             
                if (cd.Document_Type__c == 'AE Order Form' && cd.Quote__c != NULL && cd.Account__c != NULL) {
                    AEOF_QtAccMap.put(cd.Quote__c, cd.Account__c);      
                }
                /*EBA_SF-1697 */
                else if (cd.Document_Type__c == 'AE Amendment' && cd.Quote__c != NULL) {
                    finalQtIds.add(cd.Quote__c);      
                }
                /*EBA_SF-1697 */
                else if(cd.Document_Type__c == 'AE Master Agreement' && cd.Account__c != NULL) {
                    AEMA_AccIds.add(cd.Account__c);  
                }
            }    
        }
        
        for (String qtId : AEOF_QtAccMap.keySet()) {
            if(AEMA_AccIds.contains(AEOF_QtAccMap.get(qtid))) {
                // remove quoteId from quote acc Map if quoteId found, if not found query AEMA customer document by AccountId
                AEOF_QtAccMap.remove(qtid); 
                finalQtIds.add(qtId);
            }        
        }
        
        if(!AEMA_AccIds.isEmpty() || !AEOF_QtAccMap.isEmpty()) {
          
            List<Customer_Document__c> cdList = [SELECT Id, Quote__c, Account__c, Document_Type__c, Document_Status__c,PO_Number__c  FROM Customer_Document__c 
                                                    WHERE Document_Status__c = 'Completed' 
                                                    AND ((Account__c IN :AEMA_AccIds AND Document_Type__c = 'AE Order Form' AND Quote__c NOT IN :finalQtIds)
                                                    OR (Account__c IN :AEOF_QtAccMap.values() AND Document_Type__c = 'AE Master Agreement'))];                                               
            for(Customer_Document__c cd : cdList) {
                if (cd.Account__c != NULL) {
                    if (cd.Document_Type__c == 'AE Master Agreement') {
                        AEMA_AccIds.add(cd.Account__c);
                    } else if (cd.Document_Type__c == 'AE Order Form' && cd.Quote__c != NULL) {
                        AEOF_QtAccMap.put(cd.Quote__c, cd.Account__c);    
                    } 
                }
            }
        }
        
        for (String qtId : AEOF_QtAccMap.keySet()) {
            if(AEMA_AccIds.contains(AEOF_QtAccMap.get(qtid))) {
                // remove quoteId from quote acc Map if quoteId found, if not found query AEMA customer document by AccountId
                finalQtIds.add(qtId);
            }        
        }
        
        if (!finalQtIds.isEmpty()) {
            List<SBQQ__Quote__c> qList=new List<SBQQ__Quote__c>();
            qList = [Select id,SBQQ__Primary__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                         qtc_Requested_Delivery_Date__c,SBQQ__Account__c,qtc_PO_Number__c from SBQQ__Quote__c where Id in :finalQtIds];
                
            if(!System.isFuture() && !System.isBatch() && !qList.isEmpty()){
                System.enqueueJob(new cpq_QteToOppSync((List<SBQQ__Quote__c>)qList, 'CD'));   
            }     
        }
        if(Trigger.IsUpdate){
            /*if(String.isNotBlank(Trigger.New[0].Document_Status__c) && Trigger.New[0].Document_Status__c == 'Sent for Signature' && String.isNotBlank(Trigger.New[0].Quote__c)){
                
            }*/
            /* commented for EBA_SF-1812
            if(Trigger.New[0].Document_Type__c == 'AE Order Form' && Trigger.Old[0].Document_Status__c != Trigger.New[0].Document_Status__c && Trigger.New[0].Document_Status__c == 'Sent for Signature'){
                GenerateLegalDocumentService.newUser(Trigger.New[0].Quote__c);
            }*/
            //new code added for EBA_SF-1812 - Bulk handling
            for(Customer_Document__c cd : Trigger.New){
                if(cd.Document_Type__c == 'AE Order Form'  && cd.Document_Status__c != Trigger.oldMap.get(cd.id).Document_Status__c && cd.Document_Status__c == 'Sent for Signature'){
                    GenerateLegalDocumentService.newUser(cd.Quote__c);
                }
            }
            // EBA_SF-1812 ended*******************************
            
        }
        
        // below lines added by cpq team (Dharmendra)
        CPQCustomerDocTriggerHandler triggerHandler = new CPQCustomerDocTriggerHandler(Trigger.new);
        triggerHandler.updateLegalDocStatus();
    }  
}