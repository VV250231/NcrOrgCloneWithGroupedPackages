@isTest
private class PRM_AccountControllerTest 
{
    static testMethod void testNCRUPartnerCertifications() 
    {
        Account acc=new Account(Name='Acme Inc');
          system.runAs(TestRecordsFactory.getUser()){ 
        	insert acc;
        }
        
        Certification__c objCert = new Certification__c();
        objCert.Name = 'Test Contact';
        objCert.Curriculum_Number__c = '12345';
        
        insert objCert;
        
        //NCRUPartnerCertifications controller = new NCRUPartnerCertifications(new ApexPages.StandardController(acc));
        
        PRM_AccountController.getAccounts('All Accounts');
        PRM_AccountController.getAccounts('My Accounts');
        PRM_AccountController.getAccountDetail(acc.Id);
        system.assert(PRM_AccountController.getAccountDetail(acc.Id)!= null);
    }
}