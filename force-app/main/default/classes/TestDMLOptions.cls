@isTest
public class TestDMLOptions {

public static testMethod void testEmailNotification(){
    Lead l = new Lead(LastName ='TestLead-91', Company = 'NCR Corp', Industry__c = 'Banking',Country__c='United States', country = 'US', state ='CA', Lead_Stage__c = 'MQL', Run_Rule__c = true, Status = 'Marketing Qualified',LeadType__c = 'Web',LeadSource__c ='Paid - Display',SubIndustry__c ='Networks' );
    insert l; 
    List<String> leadIds = new List<String> ();
    leadIds.add(l.Id);
    DMLOptions.performAssignmentRule(leadIds);
    System.assert(l!=NUll);
    
}
}