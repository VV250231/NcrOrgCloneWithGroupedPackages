/****************************************************************************************************************
*   ClassName :   cpq_NCRPaySitesToOppSyncTrigger
*   Description :   
*   Author      :   
*   Version     :   50
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1697     4 Jan 2021      Varsha Pal               Added the criteria to check the amendment order form when autopay setup is changed to true or manual
                                                         before auto closing the CPQ opportunity
EBA_SF-1591     03-12-2022      Puneet Bhatia	         Added changes to send Payment processing application for onboarding once opportunity gets Closed/Booked.
EBA_SF-1994     04-28-2022      Puneet Bhatia	         Reverted changes for EBA_SF-1591 to send Payment processing application for onboarding once opportunity gets Closed/Booked.
EBA_SF-2042	    05-13-2022      Varsha Pal               Bug: aaSE:For the close/booked the opportuntiy, status of payment site should be approvedandboarded
****************************************************************************************************************/
trigger cpq_NCRPaySitesToOppSyncTrigger on NCR_Payments_Site__c (after insert, after update, after delete) {
    public List<String> qIds=new List<String>();
    public List<String> PmtonyqIds=new List<String>();
    Map<Id, Id> AEOF_qtAccIdMap = new Map<Id, Id>();
    Set<Id> AEMA_AccIds = new Set<Id>();
    public List<String> pqIds=new List<String>();
    
    if(Trigger.isAfter ){
        if(!System.isFuture() && !System.isBatch()) {
            if(Trigger.isInsert || Trigger.isUpdate) {
                for(NCR_Payments_Site__c ps : Trigger.New ){ 
                    if(ps.NCR_Payments_Application_Status__c !=null && ps.Quote__c != null) {
                        if(Trigger.isUpdate){
                           /* if((ps.NCR_Payments_Application_Status__c).containsIgnoreCase('Approve') && ps.NCR_Payments_Application_Status__c!=Trigger.oldMap.get(ps.id).NCR_Payments_Application_Status__c){
                                qIds.add(ps.Quote__c);
                            }*/
                            
                            if(ps.NCR_Payments_Application_Status__c!=Trigger.oldMap.get(ps.id).NCR_Payments_Application_Status__c && (ps.NCR_Payments_Application_Status__c=='ApprovedAndBoarded')){
                                PmtonyqIds.add(ps.Quote__c);
                                 qIds.add(ps.Quote__c);
                            }
                        }  
                        else if(Trigger.isInsert){
                            if(ps.NCR_Payments_Application_Status__c=='ApprovedAndBoarded')
                                qIds.add(ps.Quote__c);
                        }
                    }
                }
            }
            
            if(Trigger.isInsert || Trigger.isUpdate ){
                for(NCR_Payments_Site__c ps : Trigger.New ){
                    if(ps.Quote__c != null){
                        pqIds.add(ps.Quote__c);                    
                    }
                }
            } else if(Trigger.isDelete) {
                for(NCR_Payments_Site__c ps : Trigger.Old ){
                    if(ps.Quote__c != null){
                        pqIds.add(ps.Quote__c);                    
                    }
                }
                
            }
            if(!qIds.isEmpty() && qIds.size() > 0) {
                Map<Id, Id> AEOF_qtAccIdMap = new Map<Id, Id>();
                Set<Id> AEMA_AccIds = new Set<Id>();
                List<Id> AmOF_QIds = new List<Id>();//added to store the amendment quote ids if amendment order form is signed - EBA_SF-1697
                //CLM Documents related to current Quote
                
                List<customer_document__c> QuoteDocs=[Select id,Document_Type__c,Document_Status__c,Quote__c,Account__c from customer_document__c 
                                                 where Quote__c in :qIds AND Document_Status__c='Completed']; // query all the documents which are completed - EBA_SF-1697      
                
                //Accounts related to current Quote
                for(Customer_Document__c cd : QuoteDocs )
                { 
                    //added the AE order form check here as we need to check Master Agreement form as well before marking the opportunity as closed-EBA_SF-1697
                    if(cd.Document_Type__c=='AE Order Form'&&cd.Account__c !=null) {
                    AEOF_qtAccIdMap.put(cd.Quote__c, cd.Account__c);} 
                    //added below if condition to check if the document type is amendment order form if quote is amendment- EBA_SF-1697
                    if(cd.Document_Type__c=='AE Amendment'){
                        AmOF_QIds.add(cd.id);
                    }
                }
                
               //CLM Documents related to above Accounts
                if(!AEOF_qtAccIdMap.isEmpty()) {
                    List<customer_document__c> AccountDocs=[Select id,Document_Type__c,Document_Status__c,Account__c from customer_document__c 
                                                            where Account__c in :AEOF_qtAccIdMap.values() AND Document_Type__c='AE Master Agreement' AND Document_Status__c='Completed'];
                    
                     //Check AE Master Agreement form on Account
                    for(Customer_Document__c acd : AccountDocs ) {
                        AEMA_AccIds.add(acd.Account__c);
                    }
                    
                    if (!AEMA_AccIds.isEmpty()) {
                        qIds.clear(); // clear existing quote Ids
                        for (Id qId : AEOF_qtAccIdMap.keySet()) {
                            if (AEMA_AccIds.contains(AEOF_qtAccIdMap.get(qId))) qIds.add(qId);
                        }
                    }
                    qids.addAll(AmOF_QIds);
                }  
            } 
            // call to cpq payment site handler responsible to update qtc_Status_of_all_Applications__c  
            
           if(pqIds.size()>0){         
              List<SBQQ__Quote__c> qLstMS =new List<SBQQ__Quote__c>();
               List<SBQQ__Quote__c> qLstMultiSite= CPQNCRPaymentSitesTriggerHandler.handleAfterPaymentUpdate(pqIds);
                if (!qLstMultiSite.isEmpty()) {
                   // System.debug('qLstMultiSite'+qLstMultiSite);
                 qLstMS= [Select id,SBQQ__Primary__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                         qtc_Requested_Delivery_Date__c,SBQQ__Account__c from SBQQ__Quote__c where id in :qLstMultiSite and qtc_Multi_Site__c=TRUE];
                System.debug('qLstMS'+qLstMS);
                }
                
                if(!System.isFuture() && !System.isBatch() && !qLstMS.isEmpty()) {
                    System.enqueueJob(new cpq_QteToOppSync(qLstMS, 'NP'));   
                } 
                
            }
            
            if (!qIds.isEmpty()) {
                List<SBQQ__Quote__c> qLst = [Select id,SBQQ__Primary__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                         qtc_Requested_Delivery_Date__c,SBQQ__Account__c from SBQQ__Quote__c where id in :qIds and qtc_Multi_Site__c=FALSE];
                if(!System.isFuture() && !System.isBatch() && !qLst.isEmpty()) {
                    System.enqueueJob(new cpq_QteToOppSync(qLst, 'NP'));   
                }        
            }   
            if (!PmtonyqIds.isEmpty()) {
                List<SBQQ__Quote__c> qLst = [Select id,(Select id,Service_Offer_Category__c from SBQQ__LineItems__r where Service_Offer_Category__c !='Payments Processing' and Service_Offer_Category__c != null),SBQQ__Primary__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                                             qtc_Requested_Delivery_Date__c,SBQQ__Account__c from SBQQ__Quote__c where id in :PmtonyqIds and qtc_Multi_Site__c=FALSE];
                if(!System.isFuture() && !System.isBatch() && !qLst.isEmpty()) {
                    System.enqueueJob(new cpq_QteToOppSync(qLst, 'NPS'));   
                } 
            }
          
        }
         
    }
}