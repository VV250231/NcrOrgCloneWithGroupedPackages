/**************************************************************************************************************************************************************
Test Class was created for the PartnerInformationCon Class

#############################################################################################################################################################
Created By                           Date                              Description
Naman Kumar(nk250337)                11th February 2020                Version 1.0 , which is used for the code coverage of partnerInformationCon

****************************************************************************************************************************************************************/
@isTest
public class PartnerInfromationConTest {
    //This method is setting-up account record
    @TestSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'test'; 
        acc.Master_Customer_Number__c = '1221221';
        acc.Partner_Program_Level__c = 'Silver';
        acc.Dashboard_last_updated_on__c = Date.newInstance(System.today().Year(), System.today().Month(), System.today().Day());
        insert acc;
    }
    //This method is used to fetch the account record for specific account Id 
    @isTest static void fetchPartnerInformation(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Account accRecord = partnerInformationCon.getPartnerInfo(accId);
        System.assert(accRecord != NULL);
        System.assertEquals(accId, accRecord.Id);
    }
    //This method covers the case when the account id is null
    @isTest static void fetchPartnerInformationWhenIdNull(){
        Account newAccount = new Account();
        Account accRecord = partnerInformationCon.getPartnerInfo(newAccount.Id);
        System.assert(accRecord == NULL);
        System.assertEquals(NULL, accRecord);
    }
}