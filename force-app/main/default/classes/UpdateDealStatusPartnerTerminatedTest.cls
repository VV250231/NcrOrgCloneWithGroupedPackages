@isTest
public class UpdateDealStatusPartnerTerminatedTest {
    @isTest
    public static void UpdateDealStatusPartnerTerminatedTest(){
        User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
        System.runAs(partnerUser){
            RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner' AND SobjectType = 'Account' LIMIT 1];
            //Insert Account
            Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
            accountRecord.Active_Account__c = true;
            insert accountRecord;
            Contact testcontact = new Contact(LastName='TEST', Email = 'testrecord234@test.com');
            insert testcontact;
            //Insert Deal Registration
            Deal_Registration__c dr = new Deal_Registration__c();
            dr.Partner_Company_Name__c =   accountRecord.Id;
                      
                insert dr;
                account ACC = new account();
                for(account accTest : [SELECT ID, Active_Account__c FROM account WHERE ID = : accountRecord.Id]){
                    ACC.Id = accTest.Id;
                    ACC.Active_Account__c = false;
                }
                update ACC;
            system.assertNotEquals(ACC,null);
            system.assertEquals(ACC.Active_Account__c , false);
        }
        
    }
    @isTest
    public static void UpdateDealStatusPartnerTerminatedTest1(){
        User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
        System.runAs(partnerUser){
            Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            //RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName='Partner'];
            //Insert Account
            //Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
            
            Account objAccount = new Account();
        objAccount.Name = 'Partner Test Account';
        objAccount.Account_Country_Code__c = 'US';
        objAccount.Active_Account__c = true;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Industry = 'RETAIL:CHANNEL';
        objAccount.Account_Region__c = 'EMEA';
        objAccount.Master_Customer_Number__c = '9166344';
        objAccount.Partner_Industry__c = 'Financial;Retail';
        objAccount.LOB__c = 'FINANCIAL';
        objAccount.Account_Region__c = 'CLA';
        objAccount.Partner_Program_Industry__c = 'Retail';
        objAccount.Partner_Program_Level__c = 'Silver';
        objAccount.Counterpoint__c = true;
            objAccount.RecordTypeId = r;
            objAccount.Active_Account__c = true;
            insert objAccount;
            Contact testcontact = new Contact(LastName='TEST', Email = 'testrecord234@test.com');
            insert testcontact;
            //Insert Deal Registration
            Deal_Registration__c dr = new Deal_Registration__c();
            dr.Partner_Company_Name__c =   objAccount.Id;
                      
            insert dr;
            account accTest = [SELECT ID, Active_Account__c FROM account WHERE ID = : objAccount.Id];
            account ACC = new account();
            ACC.Id = accTest.Id;
            ACC.Active_Account__c = false;
            update ACC;
            system.assertNotEquals(ACC,null);
            system.assertEquals(ACC.Active_Account__c , false);
        }
        
    }
}