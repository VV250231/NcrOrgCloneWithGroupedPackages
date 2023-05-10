@isTest
public class NCRUDashboardControllerTest 
{
	 static testMethod void testNCRUDashboardController() 
     {
     	//Insert Partner Account
        Account act = new Account();
        act.Name = 'Partner Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663446';
         act.Financial_Products_Authorized_to_Resell__c = 'Authentic';
        system.runAs(TestRecordsFactory.getUser()){ 
        	insert act;
        }
         
         
        Certification__c objCert = new Certification__c();
        objCert.Profile__c = 'Test';
        objCert.Solution__c = 'Test';
        objCert.Curriculum_Number__c = 'Test';
        objCert.Required__c = 2;
        objCert.Account__c = act.Id;   
        insert objCert;
         
        Certification__c objCert1 = new Certification__c();
        objCert1.Profile__c = 'Test';
        objCert1.Solution__c = 'Test';
        objCert1.Curriculum_Number__c = 'Test';
        objCert1.Required__c = 2;
        objCert1.Account__c = act.Id;   
        insert objCert1;
        Certification__c objCertification  = [Select Id, Profile__c, Solution__c, Curriculum_Number__c, Required__c, Certification_Key_Combination__c from Certification__c  where Id =: objCert.Id];
       	NCRUDashboardController.getNCRUDetails(act.Id);
        List<Certification__c> certList = NCRUDashboardController.getCertificationDetails(objCertification.Certification_Key_Combination__c, act.Id); 
        System.assert(certList.size()!=0);
         
     }
}