@isTest
private class NCRUPartnerCertificationsTest 
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
        objCert.Account__c = acc.Id;
        insert objCert;
        
        NCRUPartnerCertifications controller = new NCRUPartnerCertifications(new ApexPages.StandardController(acc));
        
        List<Certification__c> certificateList= NCRUPartnerCertifications.getNCRUPartnerCertifications(acc.Id);
        System.assert(certificateList.size()==0);
    }
}