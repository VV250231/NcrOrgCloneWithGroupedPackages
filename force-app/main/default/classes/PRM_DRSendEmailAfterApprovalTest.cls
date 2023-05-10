@isTest
public class PRM_DRSendEmailAfterApprovalTest {
    static testmethod void unitTest(){
        Contact c = new Contact(LastName = 'Test Contact');
        insert c;
        Map<Id,Deal_Registration__c> trigDotOldMap = new Map<Id,Deal_Registration__c>();
        User u = new User();
        //u.ContactId = c.Id;
        u.Quicklook_ID__c = 'ww222222';
        u.Username = 'testing@tes.com';
        u.ProfileId = [Select Id FROM Profile LIMIT 1].Id;
        u.Alias = 'testins';
        u.Email = 'testingthe@domain.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'last';
        u.CommunityNickname = 'testCN';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.FederationIdentifier = 'test';
        insert u;
        
        Deal_Registration__c Newdr = new Deal_Registration__c();
        Newdr.State__c = 'Test';
        Newdr.Country__c = 'Iceland';
        Newdr.State__c = 'State';
        Newdr.City__c = 'Test';
        Newdr.Postal__c = 'Test';
        Newdr.Primary_Contact_Name__c = c.Id;
        Newdr.Primary_Solution__c = 'ACS';
        Newdr.Primary_Competitor__c = 'Test';
        Newdr.Expected_Start_Date__c = system.today() + 1;
        Newdr.Estimated_Close_Date__c = system.today() + 40;
        Newdr.IsApproved__c = true;
        Newdr.Distributor_Channel_Account_Manager__c = u.Id;
        Newdr.Distributor__c = 'LANSWORTH ENTERPRISE SOLUTIONS';
        
        insert Newdr;
      System.assertNotEquals(Newdr, null,'Deal_Registration__c should not be null');

        
        Deal_Registration__c oldDr = new Deal_Registration__c();
        oldDr.State__c = 'Test';
        oldDr.Country__c = 'Iceland';
        oldDr.State__c = 'State';
        oldDr.City__c = 'Test';
        oldDr.Postal__c = 'Test';
        oldDr.Primary_Contact_Name__c = c.Id;
        oldDr.Primary_Solution__c = 'ACS';
        oldDr.Primary_Competitor__c = 'Test';
        oldDr.Expected_Start_Date__c = system.today() + 1;
        oldDr.Estimated_Close_Date__c = system.today() + 40;
        oldDr.IsApproved__c = false;
        
        insert oldDr;
        
        List<Deal_Registration__c> trigDotNew = new List<Deal_Registration__c>();
        trigDotNew.add(Newdr);
        trigDotOldMap.put(oldDr.Id,oldDr);
        test.startTest();
        PRM_DRSendEmailAfterApproval.SendEmails(trigDotOldMap, trigDotNew);
        test.stopTest();
    }
}