public class PRM_DealRegistrationDashboardCont {
    @AuraEnabled
    public static list <Deal_Registration__c> getDealRegistration(String recId)
    {
        String strIndustryName = [Select Id, Partner_Industry__c from Deal_Registration__c where Id =: recId].Partner_Industry__c;
    	system.debug('====Calling Method');
       	List <Deal_Registration__c> dealRegistrationList = new List<Deal_Registration__c>();
          
       	if(String.isNotBlank(strIndustryName))
           dealRegistrationList = [SELECT Id, Name, Deal_Name__c,Partner_Industry__c, Account_Name_formula__c,Partner_Submission_Date__c,End_Customer_Company_Name__c, Status__c 
                                   FROM Deal_Registration__c where Partner_Industry__c =: strIndustryName and Id !=: recId];
        system.debug('==Deal Registration List=='+dealRegistrationList);
        return dealRegistrationList;        
    }
}