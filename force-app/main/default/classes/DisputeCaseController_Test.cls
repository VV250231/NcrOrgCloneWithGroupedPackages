@isTest
private class DisputeCaseController_Test {
    @testSetup static void prepareData() {
         All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile';
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = NSCCommonInfoUtil.getIdOf('CCAD_Service_Ignored_Profile_Id');
        insert setting;
        // create Account
        Account a = TestRecordsFactory.createAccount();
        // Create AR Record
        Credit_Detail__c cd = new Credit_Detail__c();
        cd.Customer_Balance__c = 3;
        cd.On_Hold__c = 'YES';
        cd.Risk_Level__c = 'GREEN';
        cd.Unique_ID__c = '1234567';
        cd.X1_30_Days_Late__c = 10;
        cd.X361_Days_Late__c = 10;
        cd.X31_60_Days_Late__c = 10;
        cd.X61_90_Days_Late__c = 10;
        cd.X91_180_Days_Late__c = 10;
        cd.Account__c = a.id;
        insert cd;
        // Create Dispute Case
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        Case caseObj = new Case();
        List<Id> caseIdList = new List<Id>();
        List<Case> casedata= new List<Case>();
        caseObj.RecordTypeId = CaseRecordTypeId;
        caseObj.Master_Customer_Nbr__c='TESTMCN00001X';
        caseObj.Country_Code__c='US';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';
        //caseObj.Contactid=cont.id;
        //caseObj.Alternate_Contact__c=cont.id;
        caseObj.AccountId = a.Id;
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        insert caseObj;
    }

    @isTest static void getDisputeCases() {
        Credit_Detail__c cd = [SELECT Id,account__c from Credit_Detail__c WHERE Unique_ID__c = '1234567'];
        for (Case c: DisputeCaseController.getAccountDisputeCases(cd.Id,'CaseNumber','ASC')) {
            system.assert(c.AccountId == cd.Account__c,'Case does not belongs to same account');
        }
    }
}