@isTest(seealldata=false)
public class DI_SAML_JIT_HandlerTest {
    Public final String ACCOUNT_SUPPORT_ALIAS = 'accountSupportAlias';
    Public final String CONTACT_LAST_NAME = 'lastName';
    Public final String CONTACT_EMAIL = 'test@example.com';

    @testSetup
    private static void testSetup() {
        Account anAccount = new Account(Name = 'accountSupportAlias', AccountNumber = '123456');
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runas(Usr){
        	insert anAccount;
        }
        Contact aContact = new Contact(
            LastName = 'lastName', 
            Email = 'test@example.com', 
            AccountId = anAccount.Id
            );
        insert aContact;
        system.assertNotEquals(aContact.Email, 'test12345@test.com');
    }

    @isTest 
    private static void createUser_AccountFound_CreateUserForExistingContact() {
         /*Account anAccount = new Account(Name = 'accountSupportAlias', AccountNumber = '123456');
        System.runas(TestRecordsFactory.getUser()){
        insert anAccount;
        }

        Contact aContact = new Contact(
            LastName = 'lastName', 
            Email = 'test@example.com', 
            AccountId = anAccount.Id
            );
        insert aContact;*/
        System.runas(TestRecordsFactory.getUser()){
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '61 DI Community Members' Limit 1];
        final Id samlSsoProviderId = NSCCommonInfoUtil.getIdOf('SSO_Setting');
        final Id communityId = NSCCommonInfoUtil.getIdOf('Portal');
        final Id portalId = NSCCommonInfoUtil.getIdOf('Portal');
        final String federationIdentifier = 'federationIdentifier';
        final Map<String, String> attributes = new Map<String, String> {
            'Contact.LastName' => 'lastName',
            'Contact.FirstName' => 'FirstName',
            'Contact.Email' => 'test@example.com',
            'Account.AccountNumber' => '123456',
             'User.Alias'    => 'userSupportAlias',
             'User.Phone'    => '1234567890',
             'User.Email'    => 'test@gmail.com',
             'User.FirstName'    => 'test FirstName',
             'User.LastName'    => 'test LastName',
             'User.Title'    => 'Mr.',
             'User.Email' => 'test@example.com',
             'User.Street'   => 'Street',
             'User.State'   => 'State',
             'User.City'   => 'Duluth',
             'User.Username' => 'username@test.com',
             'User.Country' => 'US',
             'User.Zip' => '2021345',
             'User.Department' => 'SDS',
             'User.CommunityNickname' => 'testuserasgfdeterbsvcvcfdtefdtevcvyeceiouy',
             'User.IsActive'  => 'true',
             'User.ProfileId' => portalProfile.Id,
             //'User.UserRoleId' => '00E0g000001TF7gEAG',
              'User.Fax'   =>'1234567',
              'User.Extension'   =>'1234567',
              'User.Division'   =>'Retail',
              'User.EmployeeNumber'   =>'ty56789',
              'User.MobilePhone'=>'1234567890',
               'User.AboutMe' =>'Test Class user',
               'User.ReceivesAdminInfoEmails' =>'1',
                'User.ReceivesInfoEmails' =>'1',
                'User.CompanyName' => 'Company name'/*,
             'User.ForecastEnabled' => 'true'*/
        };
        final String assertion = 'assertion';

        Test.startTest();
            DI_SAML_JIT_Handler handler = new DI_SAML_JIT_Handler();
          user newUser=  handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        
        System.debug(newUser);
        
        System.assertEquals(federationIdentifier, newUser.FederationIdentifier);
        // No additional contacts created
        System.assertEquals(1, [SELECT count() FROM Contact]);
        System.assertEquals(newUser.ContactId, [SELECT id FROM Contact][0].id);
        
        Contact con = [SELECT id,email FROM Contact limit 1];
        con.email ='test1@example.com';
        update con;
        
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        String accNumber = attributes.remove('Contact.Email');
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        Test.stopTest();
        }
    }
    @isTest 
    private static void updateUser_AccountFound_UpdateUserForExistingContact() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
       User admin = [Select Id,UserRoleId from User where Alias = 'NSCADMIN'  limit 1];
      system.runAs(TestRecordsFactory.getUser()){
          
        //Create account
       Account portalAccount1 = new Account(name = 'Test Acc',
                                LOB__c = 'FINANCIAL',
                                Master_Customer_Number__c = 'TESTMCMNTY00001X',
                                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                                //OwnerId =  usr.id,
                                Active_Account__c = true, AccountNumber ='12345');
       insert  portalAccount1;
      System.assert(portalAccount1.id!=null);
        //Create contact for the account, which will enable partner portal for account
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'Mahla',
            AccountId = portalAccount1.Id,
            Email = 'testSSO@gmail.com'
        );
        insert contact1; 
		System.assertNotEquals(contact1.FirstName,'Mahla');   
          
        //Create user for the contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '61 DI Community Members' Limit 1];
        
        User user1 = new User(
            Username = 'test123457897978@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test44',
            Email = 'test123457897978@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test123457897978',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            Quicklook_ID__c = 't0t0t0t08888',
            FederationIdentifier = 't0t0t0t0888'
            
        );
        Database.insert(user1); 
        System.assert(USer1.id!=null); 
        system.assertEquals(USer1.Email, 'test123457897978@test.com');
        
            final Id samlSsoProviderId = NSCCommonInfoUtil.getIdOf('SSO_Setting');
            final Id communityId = NSCCommonInfoUtil.getIdOf('Portal');
            final Id portalId = NSCCommonInfoUtil.getIdOf('Portal');
            final String federationIdentifier = 'federationIdentifier';
             Map<String, String> attributes = new Map<String, String> {
                'Contact.LastName' => 'Mahla',
                 'Contact.FirstName'=>'Shiv',
                 'Contact.Email' => contact1.Email,
                'Account.AccountNumber' => portalAccount1.AccountNumber,
                'User.Title'    => 'Mr.',
             'User.Email' => 'test@example.com',
             'User.Street'   => 'Street',
             'User.State'   => 'State',
             'User.City'   => 'Duluth',
             'User.Username' => 'username@test.com',
             'User.Country' => 'US',
             'User.Zip' => '2021345',
             'User.Department' => 'SDS',
             'User.CommunityNickname' => 'testuserasgfdeterbsvcvcfdtefdtevcvyeceiouy',
             'User.IsActive'  => 'true'
             
            };
            final String assertion = 'assertion';
             
            DI_SAML_JIT_Handler handler = new DI_SAML_JIT_Handler(); 
            handler.updateUser(user1.Id,samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion); 
            handler.updateUser(UserInfo.getUserId(),samlSsoProviderId, null, null, federationIdentifier, attributes, assertion);
        }
    }
}