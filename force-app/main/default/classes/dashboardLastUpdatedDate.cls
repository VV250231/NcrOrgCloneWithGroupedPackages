/**************************************************************************************************************************************************************
   Apex Class was created for the Partner Revenue Object
   
   #############################################################################################################################################################
   Created By                           Date                              Description
   Naman Kumar(nk250337)                29th November 2019                Version 1.0 , which populate "Dashboard last updated on" field value on Account Object

****************************************************************************************************************************************************************/

public class dashboardLastUpdatedDate {
    public static void updateDashboardDate(List<Partner_Revenue__c> revList){
        Map<Id, DateTime> accIdModifiedDateMap = new Map<Id, DateTime>();
        String currentYear = Date.Today().Year() + '';
        for(Partner_Revenue__c revRecord :revList){
            if(revRecord != null && revRecord.Year__c == currentYear){
                accIdModifiedDateMap.put(revRecord.Partner_Account__c, revRecord.LastModifiedDate);
            }
        }
        if(!accIdModifiedDateMap.isEmpty())
            setFieldValue(accIdModifiedDateMap);
    }
    public static void setFieldValue(Map<Id, DateTime> accIdModifiedDateMap){
        List<Account> accListToUpdate = new List<Account>();
        for(Account accRec : [SELECT Dashboard_last_updated_on__c FROM Account WHERE Id IN :accIdModifiedDateMap.keySet()]){
            DateTime dt = accIdModifiedDateMap.get(accRec.Id);
            Date lastModifiedDate = date.newinstance(dT.year(), dT.month(), dT.day());
			accRec.Dashboard_last_updated_on__c = lastModifiedDate;
            accListToUpdate.add(accRec);
        }
        update accListToUpdate;
    }
}