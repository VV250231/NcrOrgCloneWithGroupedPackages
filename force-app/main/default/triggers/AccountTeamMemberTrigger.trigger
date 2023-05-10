trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, after update, after delete) {
    
    Set<Id> accId=new Set<Id>();
    Map<Id, Account> accMap = new Map<Id, Account>();
    if(trigger.isinsert){
        
        for(AccountTeamMember atm : trigger.new){      
            if(atm.TeamMemberRole == 'Digital Strategy Manager'){
                accId.add(atm.AccountId);
            }
        }
    }
    if(trigger.isupdate){
        for(AccountTeamMember atm : trigger.new){  
            if(atm.TeamMemberRole!=trigger.oldMap.get(atm.Id).TeamMemberRole && (atm.TeamMemberRole == 'Digital Strategy Manager' || trigger.oldMap.get(atm.Id).TeamMemberRole.equals('Digital Strategy Manager'))){
                accId.add(atm.AccountId);
            }
        }
    }
    if(trigger.isdelete){
        for(AccountTeamMember atm : trigger.old){      
            if(atm.TeamMemberRole == 'Digital Strategy Manager'){
                accId.add(atm.AccountId);
            }
        }
    } 
    If(!accId.isEmpty()){
        List<Account> accList=[Select id, name, Subscription_Group__c, DI_Customer__c, Active_Account__c, Assets_current__c, 
                               BillingCity, BillingCountry, BillingPostalCode, BillingState,BillingStreet, Customer_Satisfaction_Temp_Level__c, 
                               DPV_Interface__c, DPV_Provider__c, DPV_Software__c, DUNS__c, Fax, FDIC__c, FI_Type__c, Master_Customer_Number__c,
                               NCUA__c, ParentId, PEU__c, Phone, Routing_Number__c,Service_Bureau__c,
                               ShippingCity, ShippingPostalCode, ShippingState, ShippingStreet, Tier__c, Time_Zone__c, Website 
                               from Account where id in : accId order by LastModifiedDate];
        If(!accList.isEmpty()){
            new AccountTriggerHandler().syncToServiceNow(accList);
        }  
    }
    
    
}