@isTest
public class EquipmentSharingTest {
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
    
    private static Contact createContact(Id AccountID,String suffix)
    {
        Contact con = new Contact();
        con.lastName = 'Mahla'+suffix;
        con.Email = 'test'+suffix+'@gmail.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser'+suffix;
        return con;
        
    }
    
    private static User createUser(Id ContactId, String suffix)
    {
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'IPT Partner Community Login User' Limit 1];
        User u1 = new User();
        u1.ContactId = contactId;
        u1.Username = 'wplUserTest'+suffix+'@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test1'+suffix;
        u1.Email = 'sm245987Test'+suffix+'@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty'+suffix;
        u1.CommunityNickname = 'test123451'+suffix;
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser'+suffix;
        return u1;   
    }
    static testMethod void testRequest()
    {
        User Usr = [Select Id from User Where Name = 'Soup User'];
       
        Account acc = createAccount();
            
        System.runAs(Usr){
            insert acc;
        }
        Contact con = createContact(acc.id,'1');
        insert con;
        
        Contact con1 = createContact(acc.id,'2');
        insert con1;
        
        User u = createUser(con.Id,'1');
        insert u;
        
        User u1 = createUser(con1.Id,'2');
        insert u1;
        
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
             System.assertNotEquals(equipment, null,'equipment should not be null');

        }
        
    }
}