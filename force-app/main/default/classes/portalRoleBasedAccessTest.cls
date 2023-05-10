@isTest
public class portalRoleBasedAccessTest {
	public static testMethod void testUserContactLinking() {
        
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User u2 = new User();
        u2.Username = 'sysAdmin@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = adminProfile.Id;
        u2.Alias = 'admin123';
        u2.Email = 'sm245977@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUser';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        insert u2;
        
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
        insert act;
        
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'sm245987@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='IPT Partner Community Login User' Limit 1];
        User u1 = new User();
        u1.ContactId = con.Id;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        insert u1;
        
        system.runas(u2) {
        Test.startTest();
            List<user> userListToUpdate = new List<user>();
            for(User u : [SELECT Id, IsActive, IsPortalEnabled FROM User WHERE Id =: u1.Id]) {
                u.IsActive = false;
                u.IsPortalEnabled = false;
                userListToUpdate.add(u);
            }
            update userListToUpdate;
            userListToUpdate[0].IsActive = false;
            update userListToUpdate[0];
            userListToUpdate[0].IsActive = true;
            update userListToUpdate[0];
        Test.stopTest();
        }
    }
}