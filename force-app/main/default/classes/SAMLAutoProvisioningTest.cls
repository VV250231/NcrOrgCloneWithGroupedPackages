@IsTest
public class SAMLAutoProvisioningTest{

static testMethod void autoProvisionCheck() {
UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile chatterProfile = [SELECT Id FROM Profile WHERE Name = '90 Chatter Free' Limit 1];
        Profile otherProfile = [SELECT Id FROM Profile WHERE Name != '90 Chatter Free' Limit 1];
        User u2 = new User();
        u2.Username = 'sysAdmin###123@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = otherProfile.Id;
        u2.Alias = 'admin123';
        u2.Email = 'sm245977@gmail.com'; 
        u2.EmailEncodingKey = 'UTF-8'; 
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUser';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
    	u2.Quicklook_ID__c = 'admin333';
        u2.FederationIdentifier = 'admin333';
        insert u2;
        
        u2.ProfileId=chatterProfile.id;
        update u2;
    	system.assertEquals( u2.ProfileId,chatterProfile.id);
 }
}