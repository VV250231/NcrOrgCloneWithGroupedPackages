public class CDMLogger {
    
    @future
    public static void logCustomerHierachySync(String req, String res) {
        CDM_Log__c log = new CDM_Log__c(Request_Message__c = req, Response_Message__c = res);
        
        if (String.isNotBlank(req)) {
            CDMService.CustomerHierarchyRequest cstHRReq = (CDMService.CustomerHierarchyRequest) JSON.deserialize(req, CDMService.CustomerHierarchyRequest.Class);  
           
            if(cstHRReq != NULL) {
                log.CDM_Action__c = cstHRReq.CDMActionType;
                
               if ((cstHRReq.Customer != null) && (cstHRReq.CDMActionType == CDMService.CDMAction.CustomerCreate.name() 
                    || cstHRReq.CDMActionType == CDMService.CDMAction.CustomerUpdate.name())) {
                    
                   log.Entity_Type__c = 'Customer';
                   log.Entity_Number__c = cstHRReq.Customer.CustomerNumber;   
                     
               } else if((cstHRReq.Customer != null) && (cstHRReq.Customer.Account != null) 
                        && (cstHRReq.CDMActionType == CDMService.CDMAction.AccountCreate.name() || cstHRReq.CDMActionType == CDMService.CDMAction.AccountUpdate.name())) {
                  
                  log.Entity_Type__c = 'Account';
                  log.Entity_Number__c = cstHRReq.Customer.Account.AccountNumber;
               }
            }                    
        } 
        
        if(String.isNotBlank(res)) {
            CDMService.CustomerHierarchyResponse cstHRRes = (CDMService.CustomerHierarchyResponse) JSON.deserialize(res, CDMService.CustomerHierarchyResponse.Class);
            if(cstHRRes != NULL) {log.Response_Status__c = cstHRRes.status;}  
        }
        insert log;
    }
    
    
    @future
    public static void logCustomerMergeSync(String req, String res) {
        CDM_Log__c log = new CDM_Log__c(Request_Message__c = req, Response_Message__c = res, CDM_Action__c = 'EntityMerge');
        
        if(String.isNotBlank(req)) {    
            CDMService.CustomerMergeRequest cstMrgReq = (CDMService.CustomerMergeRequest) JSON.deserialize(req, CDMService.CustomerMergeRequest.Class); 

            if(cstMrgReq != NULL && cstMrgReq.MergePartyDetail != NULL) {
                
                if(cstMrgReq.MergePartyDetail.masterParty != NULL && String.isNotBlank(cstMrgReq.MergePartyDetail.masterParty.PartyNumber)) {
                    log.Entity_Number__c = cstMrgReq.MergePartyDetail.masterParty.PartyNumber;
                } 
                
                if(cstMrgReq.MergePartyDetail.victimParties != NULL && cstMrgReq.MergePartyDetail.victimParties.size() > 0) {
                    String vctmPrtyNbrs = '';
                    
                    for(CDMService.MergePartyWrapper party : cstMrgReq.MergePartyDetail.victimParties) {
                        
                        if(String.isNotBlank(party.PartyNumber)) {
                            vctmPrtyNbrs += party.PartyNumber + ',';
                            log.Victim_Entity_Numbers__c = vctmPrtyNbrs;
                        }
                    }
                    
                    if(String.isNotBlank(vctmPrtyNbrs) && vctmPrtyNbrs.length() > 0) {
                        vctmPrtyNbrs = vctmPrtyNbrs.subString(0, vctmPrtyNbrs.length() -1); 
                    }
                }   
            }
        }
        
        if(String.isNotBlank(res)) {
            CDMService.CustomerMergeResponse cstMrgRes = (CDMService.CustomerMergeResponse ) JSON.deserialize(res, CDMService.CustomerMergeResponse.Class);
            if(cstMrgRes != NULL) {log.Response_Status__c = cstMrgRes.status; }  
        }
        
        insert log;
    }
    
    
}