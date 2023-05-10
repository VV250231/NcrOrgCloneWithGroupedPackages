@isTest
public with sharing class QSApprovalsListViewControllerTest {
    private static Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();

   @isTest 
   static void QSApprovalsForQUoteControllerTest(){
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account parentAccount;
        Account testAccount;
        System.runAs( Usr ){
            parentAccount = new Account(Name='Parent Account');
            insert parentAccount;

            testAccount = new Account(
                RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
        }
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Type__c='Quote', 
            qtc_Bill_To_Site__c =testAccount.Id,
            Deliver_To_Site__c =testAccount.Id,
            qtc_Ship_To_Account__c =testAccount.Id,
            SBQQ__Account__c = parentAccount.Id
            );
        insert testQuote;
        
        sbaa__Approver__c testApprover = new sbaa__Approver__c(
            name = 'test', 
            sbaa__User__c = userinfo.getUserId());
        
        insert testApprover;
        
        sbaa__ApprovalRule__c testApprovalRule = new sbaa__ApprovalRule__c(
            Name = 'TEST Approval Rule', 
            sbaa__TargetObject__c = 'SBQQ__Quote__c',
            sbaa__ApprovalStep__c = 1, 
            sbaa__Approver__c = testApprover.id);
        
        insert testApprovalRule;
        
        sbaa__Approval__c testApproval = new sbaa__Approval__c(
            sbaa__status__c = 'Requested', 
            sbaa__ApprovalStep__c = 1, 
            sbaa__RecordField__c = 'Quote__c',
            Quote__c = testQuote.id, 
            sbaa__Rule__c = testApprovalRule.id, 
            sbaa__Approver__c = testApprover.id, 
            sbaa__AssignedTo__c = userInfo.getUserId());
        
        insert testApproval; 
        
        Test.startTest();
        
            QSApprovalsListViewController cont = new QSApprovalsListViewController();
            QSApprovalsListViewController.shorting('Name','ASC');
        
        Test.stopTest();

        System.assertEquals(1, cont.approvalList.size(), 'We expect 1 approval to be returned');
        System.assertEquals(testApproval.Id ,cont.approvalList[0].aprvl.Id, 'We expect the Appoval Id to be returned');

   }
}