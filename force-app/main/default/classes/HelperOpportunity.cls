/*
##################################################################################################                                                                  
# File..................: HelperOpportunity.cls                                                        
# Version...............: 36.0 
# Created by............: Puneet Bhatia                                                                 
# Created Date..........: 25-02-2016                                                                               
# Last Modified by......: Puneet Bhatia 
# Last Modified Date....: 25-02-2016
# Description...........: This helper class has generic and resusable methods for opportunity object.
Modification History
Version     Story No.     ModifiedBy      Date        Description
1.1        NC_AGILE-895  Nagendra Singh  18-9-2017   Auto-populate Decision Maker Contact on Renewal Opportunity
##################################################################################################
*/
public with sharing class HelperOpportunity {

    public static void insertContactRoleFromOpportunity(List<Opportunity> oppList){
        String defaultContactRole = 'Primary Buyer';
        List<OpportunityContactRole> oppConRoleInsertList = new List<OpportunityContactRole>();
        
        if(oppList!= null && (!oppList.isEmpty())) {
            for(Opportunity opp : oppList) {
                if(opp.Contacts__c != null) {
                    OpportunityContactRole oppConRole = new OpportunityContactRole();
                    oppConRole.OpportunityId = opp.Id;
                    oppConRole.ContactId = opp.Contacts__c;
                    oppConRole.Role = defaultContactRole; 
                    oppConRole.IsPrimary = true;
                    oppConRoleInsertList.add(oppConRole);  
                }
            }    
        }
        insert oppConRoleInsertList;  
    }
    
    
    public static void updateContactRoleFromOpportunity(List<Opportunity> oppList) {
        String defaultContactRole = 'Primary Buyer';
       
        List<OpportunityContactRole> oppConRoleUpsertList = new List<OpportunityContactRole>();

        Map<Id, Id> OppConIdSet = new Map<Id, Id>();
        Map<Id, Map<Id, Boolean>> oppPrimaryConMap = new Map<Id, Map<Id, Boolean>>();
        Map<Id, Boolean> contactMap;
        
        if(oppList!= null && (!oppList.isEmpty())) {
            for(Opportunity opp : oppList) {
                if(opp.Contacts__c != null) {
                    OppConIdSet.put(opp.Id, opp.Contacts__c);
                }
            }
        }
        
      
        if(!OppConIdSet.isEmpty()) {
            for(OpportunityContactRole contactRole :[SELECT OpportunityId, ContactId, Role, IsPrimary FROM OpportunityContactRole WHERE ContactId IN :OppConIdSet.values() 
                                                        AND OpportunityId IN :OppConIdSet.keySet()]) {
                
                if(OppConIdSet.containsKey(contactRole.OpportunityId)) {
                    Id contactId = OppConIdSet.get(contactRole.OpportunityId);
                    
                    if(contactId  ==  contactRole.ContactId) {
                        OppConIdSet.remove(contactRole.OpportunityId); 
                        
                        if(!contactRole.IsPrimary) {
                        
                            //update contact to primary 
                            contactRole.IsPrimary = true;
                            oppConRoleUpsertList.add(contactRole);     
                        } 
                    } else {
                    
                         //insert contact role
                        OpportunityContactRole oppConRole = new OpportunityContactRole();
                        oppConRole.OpportunityId = contactRole.OpportunityId;
                        oppConRole.ContactId = contactId;
                        oppConRole.Role = defaultContactRole; 
                        oppConRole.IsPrimary = true;
                        oppConRoleUpsertList.add(oppConRole); 
                        OppConIdSet.remove(contactRole.OpportunityId);
                    }
                }                                          
            }
        }
        
        for(Id oppId :OppConIdSet.keySet()) {
             Id contactId  = OppConIdSet.get(oppId);
             OpportunityContactRole oppConRole = new OpportunityContactRole();
             oppConRole.OpportunityId = oppId;
             oppConRole.ContactId = contactId;
             oppConRole.Role = defaultContactRole; 
             oppConRole.IsPrimary = true;
             oppConRoleUpsertList.add(oppConRole); 
        }
        
        if(!oppConRoleUpsertList.isEmpty()) { upsert oppConRoleUpsertList; }
        
    
    }
    //Start V1.1
    public static void insertContactRoleDecisionMaker(List<Opportunity> oppList){
        set<id> SetOfAccId= new Set<Id>();
        map<id,id> mpAccIdToConId = new map<id,id>();
        for(Opportunity opp: oppList){
            if(opp.AccountId !=null){
                SetOfAccId.add(opp.AccountId);
            }
        }
        List<Account> lstAccount = [Select Id,(Select Id,AccountId,Active_Contact__c, Decision_Maker__c from Contacts) from Account where id In:SetOfAccId limit 50000];
        for(Account acc:lstAccount){
            for(Contact con: acc.Contacts){
                if(con.Decision_Maker__c !=null && con.Decision_Maker__c !='' 
                   && con.Decision_Maker__c == 'Decision Maker' && con.Active_Contact__c){
                    if(!mpAccIdToConId.containskey(con.AccountId))
                       mpAccIdToConId.put(con.AccountId,con.Id);
                }
            }
            
        }
        String defaultContactRole = 'Decision Maker';
        List<OpportunityContactRole> oppConRoleInsertList = new List<OpportunityContactRole>();
        
        if(oppList!= null && (!oppList.isEmpty())) {
            for(Opportunity opp : oppList) {
                if(mpAccIdToConId.containskey(opp.AccountId)){
                    OpportunityContactRole oppConRole = new OpportunityContactRole();
                    oppConRole.OpportunityId = opp.Id;
                    oppConRole.ContactId = mpAccIdToConId.get(opp.AccountId);
                    oppConRole.Role = defaultContactRole; 
                    oppConRole.IsPrimary = false;
                    oppConRoleInsertList.add(oppConRole);
                }
                      
            }    
        }
        insert oppConRoleInsertList;  
    }
    //EndV1.1
    
}