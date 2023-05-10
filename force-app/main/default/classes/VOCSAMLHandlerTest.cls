@isTest
public class VOCSAMLHandlerTest {
    
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
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUsel1r';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        system.assert(u2.id!=null);
        
        //Insert  Account
        Account act = new Account();
        act.Name = 'Partner Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
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
        
        //Insert Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'sm245987@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        
        //Insert User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        User u1 = new User();
        u1.ContactId = con.Id;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.isActive =true;
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'pk18515x';
        
        u1.Quicklook_ID__c='qw221321';
        insert u1;
        system.assert(u1.id!=null);
        
        String FederationIdentifier = 'wplUser';
        Map<String,String> samlAttributes = new Map<String,String>();
        samlAttributes.put('MCN','91663446');
        samlAttributes.put('Contact.LastName','Mahla');
        samlAttributes.put('Contact.Email','sm245987@gmail.com');
        samlAttributes.put('User.Email','sm245987@gmail.com');
        samlAttributes.put('User.Username','wplUser@ncr.com');
        samlAttributes.put('User.ProfileId',portalProfile.Id);
        samlAttributes.put('User.UserType','Partner');
        samlAttributes.put('User.IsActive','True');
        samlAttributes.put('User.Country','India');
        samlAttributes.put('telephoneNumber','7777777777');
        
        
        system.runAs(u2) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
            obj.updateUser(u1.Id,null,null,null,FederationIdentifier,samlAttributes,null);
            
            
        }
        
    }
   
    public static testMethod void multipleContact() {
        
        
        //Insert User
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        system.assert(adminProfile.Id!=null);
        User u2 = new User();
        u2.Username = 'sysAdmin@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = adminProfile.Id;
        u2.Alias = 'admin123';
        u2.Email = 'sm245977@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUserb1';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
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
        
        
        //Insert Contact
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
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Email','sm245987@gmail.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        system.runAs(u2) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
        }
        System.assertEquals(10,samlAttributesNew.size());
    }
    
    public static testMethod void testMethod2() {
        //Insert User
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
        u2.CommunityNickname = 'adminUserj1';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '9868118';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        //insert act;
        
        
        //Insert Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','9868118');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Email','sm245987@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav13');
        samlAttributesNew.put('User.firstname','Yadava12');
        samlAttributesNew.put('User.LocaleSidKey','en_US');
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.Alias','TestUser');
        SamlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        SamlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        
        system.runAs(u2) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            
        }
        System.assertEquals(16,samlAttributesNew.size());
    }
    
     public static testMethod void testMethod3() {
        //Insert User
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
        u2.CommunityNickname = 'adminUserf1';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin33';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Account
        Account act = new Account();
        act.Name = 'Sales Academy Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
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
        //Insert Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        String FederationIdentifierNew = 'wplNewUserY';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Email','sm245987@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav13');
        samlAttributesNew.put('User.firstname','Yadava12');
        samlAttributesNew.put('User.LocaleSidKey','en_US');
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.Alias','TestUser');
        SamlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        SamlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        
        system.runAs(u2) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            
        }
         System.assertEquals(16,samlAttributesNew.size());
    }

     public static testMethod void testMethod4() {
         //Insert Account
        Account act = new Account();
        act.Name = 'NCR Partner Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
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

        //Insert Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
         //Insert Contact
        Contact con1 = new Contact();
        con1.lastName = 'Mahla1';
        con1.Email = 'as2506651@gmail.com';
        con1.AccountId = act.Id;
        con1.Active_Contact__c = true;
        con1.Web_Portal_Login__c = 'wplNewUser1';
        insert con1;
         
         //Insert User
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Banking Customer' Limit 1];
        Profile adminProfile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];  
        User u1 = new User();
        u1.Username = 'sysAdmin1@ncr.com';
        u1.UserRole= role ;
        u1.ProfileId = adminProfile1.Id;
        u1.Alias = 'admin123';
        u1.Email = 'sm2459771@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'systemAdmin';
        u1.CommunityNickname = 'TestxVOC';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'admin333';
        u1.Quicklook_ID__c='pk28515x';
        insert u1;
         
        User u2 = new User();
        u2.Username = 'asysAdmin@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = adminProfile.Id;
        u2.ContactId=con.id;
        u2.Alias = 'admin234';
        u2.Email = 'sm248677@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LastName = 'systAdmin';
        u2.CommunityNickname = 'FirstVOC';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin433';
        u2.Quicklook_ID__c='pk19615x';
        u2.IsActive=false;
        insert u2;
 
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        String FederationIdentifierNew = 'wplNewUser';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','91663446');
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.Email','sm245987@gmail.com');
        samlAttributesNew.put('User.LastName','Yadav13');
        samlAttributesNew.put('User.firstname','Yadava12');
        samlAttributesNew.put('User.LocaleSidKey','en_US');
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.Alias','TestUser');
        SamlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        SamlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');
        
        
        
        system.runAs(u1) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
             obj.updateUser(u2.id,null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            
        }
         System.assertEquals(16,samlAttributesNew.size());
    }
    
     public static testMethod void testMethod5() {
        //Insert User
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
        u2.CommunityNickname = 'adminUserx2';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin33';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
        
        //Insert Account
        Account act = new Account();
        act.Name = 'Sales Academy Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
            System.assertNotEquals(true,actRecordtypes.isEmpty());
        }
        //insert act;
        //Insert Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        String FederationIdentifierNew = 'wplNewUserY';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Email','sm245987@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav13');
        samlAttributesNew.put('User.firstname','Yadava12');
        samlAttributesNew.put('User.LocaleSidKey','en_US');
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.Alias','TestUser');
        SamlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        SamlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');

        system.runAs(u2) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            
        }
    }
     
     public static testMethod void testMethod6() {
        //Insert User
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
        u2.CommunityNickname = 'adminUserz1';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin33';
        u2.Quicklook_ID__c='pk18515x';
        insert u2;
         
       
        //Insert Account
        Account act = new Account();
        act.Name = 'Sales Academy Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Customer' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'FINANCIAL:BANKING';
        act.Master_Customer_Number__c = '9868118';
        // act.ispartner = true;
        act.Partnership_Status__c ='Active';
        System.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
         System.assertNotEquals(true,actRecordtypes.isEmpty());
        //insert act;
        //Insert Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'as250665@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplNewUser';
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Banking Customer%' Limit 1];
        String FederationIdentifierNew = 'wplNewUserY';
        Map<String,String> samlAttributesNew = new Map<String,String>();
        samlAttributesNew.put('MCN','9868118');        
        samlAttributesNew.put('Contact.LastName','Yadav');
        samlAttributesNew.put('Contact.Email','as250665@gmail.com');
        samlAttributesNew.put('User.Email','sm245987@gmail.com');
        samlAttributesNew.put('User.Username','wplNewUser@ncr.com');
        samlAttributesNew.put('User.ProfileId',portalProfile.Id);
        samlAttributesNew.put('User.UserType','Partner');
        samlAttributesNew.put('User.LastName','Yadav13');
        samlAttributesNew.put('User.firstname','Yadava12');
        samlAttributesNew.put('User.LocaleSidKey','en_US');
        samlAttributesNew.put('User.LanguageLocaleKey','en_US');
        samlAttributesNew.put('User.Alias','TestUser');
        SamlAttributesNew.put('User.TimeZoneSidKey','America/Los_Angeles');
        SamlAttributesNew.put('User.EmailEncodingKey','UTF-8');
        samlAttributesNew.put('User.Email','wplNewUser@ncr.com');
        samlAttributesNew.put('User.Country','India');
        samlAttributesNew.put('telephoneNumber','7777777777');

        system.runAs(u2) {
            VOCSAMLHandler obj = new VOCSAMLHandler();
            obj.createUser(null,null,null,FederationIdentifierNew,samlAttributesNew,null);
            
            
        }
    }
    
}