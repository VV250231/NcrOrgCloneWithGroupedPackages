trigger PartnerRevenueTrigger on Partner_Revenue__c (before insert, after insert, after update) {
    //This is used to restrict duplicate revenue records of a year on same account.
    // Duplicate Rule was not working when data was duplicate into batch which is bening inserted. that was showring error
    // only in case when duplicate data already exist into the system.
    if (PRM_TriggersController.getTriggersStatus('PartnerRevenueTrigger')) {
        /*
        if(trigger.isInsert && trigger.isBefore){
            Set<String> yearAccountComb = new Set<String>();
            Set<String> duplicateYearAccountComb = new Set<String>();    
            for(Partner_Revenue__c pr : Trigger.New) {
                if(yearAccountComb.contains(String.valueOf(pr.Year__c)+String.valueOf(pr.Partner_Account__c))) {
                    duplicateYearAccountComb.add(String.valueOf(pr.Year__c)+String.valueOf(pr.Partner_Account__c));
                } else {
                    yearAccountComb.add(String.valueOf(pr.Year__c)+String.valueOf(pr.Partner_Account__c));
                }
                
            }
            for(Partner_Revenue__c pr : Trigger.New){
                if(duplicateYearAccountComb.contains(String.valueOf(pr.Year__c)+String.valueOf(pr.Partner_Account__c))) {
                    pr.addError('Record for this year already exist.');
                }   
            }
        }  */
        if(trigger.isAfter){
            if(trigger.isInsert || trigger.isUpdate){
                dashboardLastUpdatedDate.updateDashboardDate(trigger.New);
            }   
        }
    }
}