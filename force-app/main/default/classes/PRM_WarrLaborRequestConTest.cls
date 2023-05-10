@isTest
private class PRM_WarrLaborRequestConTest
{
    
     private static Account createAccount(){
       
        Account objAccount = new Account();
        objAccount.Name = 'Partner Test Account';
        objAccount.Account_Country_Code__c = 'US';
        objAccount.Active_Account__c = true;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Industry = 'RETAIL:CHANNEL';
        objAccount.Account_Region__c = 'EMEA';
        objAccount.Master_Customer_Number__c = '91663446';
        objAccount.Partner_Industry__c = 'Financial;Retail';
        objAccount.LOB__c = 'FINANCIAL';
        objAccount.Account_Region__c = 'CLA';
        
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if(actRecordtypes.size() > 0)
            objAccount.RecordTypeId = actRecordtypes[0].Id;
            
        return objAccount;
    }
    
    private static Contact createContact(Id AccountID)
    {
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'test@gmail.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        return con;
    }
    
    private static User createUser(Id ContactId)
    {
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'IPT Partner Community Login User' Limit 1];
        User u1 = new User();
        u1.ContactId = contactId;
        u1.Username = 'wplUserTest@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test1231';
        u1.Email = 'sm245987Test@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test123451';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        return u1;   
    }
    static testMethod void testRequest()
    {
        Account acc = createAccount();
         system.runas(TestRecordsFactory.getUser())
        {
            insert acc; 
        }
        //insert acc;
        
        Contact con = createContact(acc.id);
        insert con;
        
        User u = createUser(con.Id);
         
        system.runAs(u) 
        {
            Equipment_Declaration__c equipment = new Equipment_Declaration__c();
            equipment.Name = '12343';
            
            equipment.Partner_Account__c =  acc.Id;
            equipment.Customer_Name__c = 'TEST Customer';
            equipment.Account__c = acc.Id;
            equipment.Active_Unit__c = false;
            equipment.Class__c = '5885';
            equipment.Class_Type__c = 'Multi Function';
            equipment.Features__c = 'Deposit Auto (Cash)/Recycler BNA';
            equipment.Installation_Address1__c = 'TEST';
            equipment.Installation_City__c = 'TEST';
            equipment.Installation_State_Province__c = 'TEST';
            equipment.Installation_Date_of_New_Unit__c = System.today();
            equipment.Service_Date__c = System.today();
            insert equipment;
             PRM_WarrLaborRequestCon.getEquipmentDetail(equipment.Id);
            PRM_WarrLaborRequestCon.submitWarrLabReq(equipment, 'Testing');
            system.assert(PRM_WarrLaborRequestCon.getEquipmentDetail(equipment.Id)!=null);
        }

    }
}