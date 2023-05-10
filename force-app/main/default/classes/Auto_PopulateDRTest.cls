@isTest
public class Auto_PopulateDRTest {
	private static Id createAccount(){
        Account act = new Account();
        act.Name = 'Partner Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'RETAIL:CHANNEL';
        act.Account_Region__c = 'EMEA';
        act.Master_Customer_Number__c = '91663446';
        act.OwnerId =  UserInfo.getUserId();
        System.runas(TestRecordsfactory.getUser()){
        insert act;
        }
    	return act.id;
    }
    
    private static Id createContact()
    {
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'test@gmail.com';
        con.AccountId = createAccount();
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        return con.Id;
        
    }
   
	private static User createUser()
	{
          //Insert Partner User
        Profile SysAdmin = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' Limit 1];
        User seniorManagerUser = new User();
        //seniorManagerUser.ContactId = createContact().id;
        seniorManagerUser.Username = 'seniormanager@ncr.com';
        seniorManagerUser.ProfileId = sysAdmin.Id;
        seniorManagerUser.Alias = 'sm12';
        seniorManagerUser.Email = 'seniormanager@gmail.com';
        seniorManagerUser.EmailEncodingKey = 'UTF-8';
        seniorManagerUser.LastName = 'McTesty';
        seniorManagerUser.CommunityNickname = 'sm12345';
        seniorManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
        seniorManagerUser.LocaleSidKey = 'en_US';
        seniorManagerUser.LanguageLocaleKey = 'en_US';
        seniorManagerUser.FederationIdentifier = 'sm123';
        seniorManagerUser.Quicklook_ID__c ='sm123';
        insert seniorManagerUser;
        
		//Insert Partner User
       	Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        User ManagerUser = new User();
      	//  ManagerUser.ContactId = contactId;
        ManagerUser.Username = 'manager@ncr.com';
        ManagerUser.ProfileId = sysAdmin.Id;
        ManagerUser.Alias = 'm12';
        ManagerUser.ManagerId = seniorManagerUser.id;
        ManagerUser.Email = 'manager@gmail.com';
        ManagerUser.EmailEncodingKey = 'UTF-8';
        ManagerUser.LastName = 'McmTesty';
        ManagerUser.CommunityNickname = 'm123';
        ManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
        ManagerUser.LocaleSidKey = 'en_US';
        ManagerUser.LanguageLocaleKey = 'en_US';
        ManagerUser.FederationIdentifier = 'm123';
        ManagerUser.Quicklook_ID__c ='m123';
        insert ManagerUser;
        
        User u1 = new User();
        u1.ContactId = createContact();
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'm1sss2';
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTestya';
        u1.CommunityNickname = 'saa22';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.ManagerId = ManagerUser.id;
        u1.FederationIdentifier = 'wplUser';
        u1.Quicklook_ID__c ='wplUser';
        return u1;
    }
    
    static testmethod void  testdealRegTrigger(){
        System.runAs(createUser()){
            
            Deal_Registration__c dealreg = new Deal_Registration__c(); 
            insert dealreg;
            System.assert(dealreg.id!=null);
        }
        
    }
    
    
    
}