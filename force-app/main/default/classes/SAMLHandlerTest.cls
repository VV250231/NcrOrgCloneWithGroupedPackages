/*
##################################################################################################
# Class Name............................:SAMLHandlerTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class SAMLHandlerTest {
    
    public static testMethod void testSamlHandler() {
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User u2 = new User();
        u2.Username = 'sysAdmin@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = adminProfile.Id;
        u2.Alias = 'admin123';
        u2.Email = 'sm245977@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.firstName ='test';
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUser';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        u2.Quicklook_ID__c='pk18515x';
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
        //    act.ispartner = true;
        act.Partnership_Status__c ='Active';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663446';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        // insert act;
        
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'sm245987@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Hospitality SMB Partner%' Limit 1];
        User u1 = new User();
        u1.ContactId = con.Id;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.isActive =false;
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.FirstName='Test';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'pk18515x';
        
        u1.Quicklook_ID__c='qw221321';
        insert u1;
        
        String FederationIdentifier = 'wplUser';
        Map<String,String> samlAttributes = new Map<String,String>();
        samlAttributes.put('MCN','91663446');
        samlAttributes.put('Contact.LastName','Mahla');
        samlAttributes.put('Contact.Email','sm245987@gmail.com');
        samlAttributes.put('User.Username','wplUser@ncr.com');
        samlAttributes.put('User.ProfileId',portalProfile.Id);
        samlAttributes.put('User.UserType','Partner');
        samlAttributes.put('User.IsActive','True');
        samlAttributes.put('User.Country','India');
        samlAttributes.put('telephoneNumber','7777777777');
        
        
        system.runAs(u2) {
            SAMLHandler obj = new SAMLHandler();
            obj.updateUser(u1.Id,null,null,null,FederationIdentifier,samlAttributes,null);
            
        }
        
    }
    
    
    public static testMethod void multipleContact() {
        
        
        //Insert Partner User
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User u2 = new User();
        u2.Username = 'sysAdmin@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = adminProfile.Id;
        u2.Alias = 'admin123';
        u2.Email = 'sm245977@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.FirstName ='test';
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUser';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663448';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        
        
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        Contact con2 = new Contact();
        con2.lastName = 'Mahla';
        con2.Email = 'as2506s65@gmail.com';
        con2.AccountId = act.Id;
        con2.Active_Contact__c = true;
        con2.Web_Portal_Login__c = 'wplNewUser';
        insert con2;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        system.runAs(u2) {
            SAMLHandler obj = new SAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
        }
    }
    
    
    
    
    public static testMethod void testMethod2() {
        //Insert Partner User
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
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663448';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        //insert act;
        
        
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        samlAttributesNew.put('firstname','Test'); 
        samlAttributesNew.put('User.LocaleSidKey','en_US');   
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        samlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        
        
        system.runAs(u2) {
            SAMLHandler obj = new SAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
        }
    }
    
    public static testMethod void testMethod3() {
        //Insert Partner User
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
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        // act.Master_Customer_Number__c = '91663448';
        act.Master_Customer_Number__c = '91663446';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        //  insert act;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('firstname','Test'); 
        samlAttributesNew.put('User.LastName','Yadav123');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('User.Alias','Tein123');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        system.runAs(u2) {
            SAMLHandler obj = new SAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            SAMLHandler.runningInASandbox();
        }
    }
    public static testMethod void testMethod4() {
        //Insert Partner User
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
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663448';
        //    act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        //  insert act;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        //samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        system.runAs(u2) {
            SAMLHandler obj = new SAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
        }
    }
    static testmethod void testmethod5(){
        
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
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663448';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        // insert act;
        
        
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        system.runAs(u2) {
            //Insert Partner User
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
            User u1 = new User();
            u1.ContactId = con.Id;
            u1.Username = 'wplUser@ncr.com';
            u1.ProfileId = portalProfile.Id;
            u1.Alias = 'test123';
            u1.isActive =true;
            u1.Email = 'sm245987@gmail.com';
            u1.EmailEncodingKey = 'UTF-8';
            u1.LastName = 'McTesty';
            u1.CommunityNickname = 'test12345test12345';
            u1.TimeZoneSidKey = 'America/Los_Angeles';
            u1.LocaleSidKey = 'en_US';
            u1.LanguageLocaleKey = 'en_US';
            u1.FederationIdentifier = 'admin222';
            // u1.Quicklook_ID__c='pk18515x';
            insert u1;
            
            // u1.IsPortalEnabled =false;
            //update u1;
        }
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        samlAttributesNew.put('firstname','Test'); 
        samlAttributesNew.put('User.LocaleSidKey','en_US');   
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        samlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        
        
        system.runAs(u2) {
            try{
                SAMLHandler obj = new SAMLHandler();
                obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            }
            catch(exception e){
                
            }
            
        }
    }
    public static testMethod void testMethod6() {
        //Insert Partner User
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
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Partner Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '91663448';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        //insert act;
        
        
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        samlAttributesNew.put('firstname','Test'); 
        samlAttributesNew.put('User.LocaleSidKey','en_US');   
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        samlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        system.runAs(u2) {
            try{
                SAMLHandler obj = new SAMLHandler();
                obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
                obj.updateUser(u2.id, null, null, null, FederationIdentifierNew, samlAttributesNew, null); 
            }
            catch(Exception e){
                
            }
        }
    }
}