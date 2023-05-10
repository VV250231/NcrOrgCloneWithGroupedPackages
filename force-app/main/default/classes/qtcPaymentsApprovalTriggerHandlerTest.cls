@isTest
public with sharing class qtcPaymentsApprovalTriggerHandlerTest {
    static string   APPROVAL_ACTION_SUBMIT = 'Submit',
                    APPROVAL_ACTION_RECALLED = 'Recall',
                    APPROVAL_STATUS_APPROVED = 'Approved',
                    APPROVAL_STATUS_RECALLED = 'Recalled';
    static Integer  BULK_COUNT = 20;

    @isTest
    static void afterUpdate_ApprovalTest(){
        qtc_PaymentsApproval__c testPaymentsApproval = new qtc_PaymentsApproval__c();
        insert testPaymentsApproval;

        Test.startTest();
            testPaymentsApproval.qtc_ApprovalAction__c = APPROVAL_ACTION_SUBMIT;
            update testPaymentsApproval;
        Test.stopTest();

        List<qtc_PaymentsApproval__c> listPaymentsApprovalResults = [SELECT qtc_ApprovalAction__c, ApprovalStatus__c FROM qtc_PaymentsApproval__c];
        System.assertEquals(1, listPaymentsApprovalResults.size(), 'We expect only one payment approval at this time');
        System.assertEquals(APPROVAL_STATUS_APPROVED, listPaymentsApprovalResults[0].ApprovalStatus__c, 'We expect the approval status to update');
        System.assertEquals(null, listPaymentsApprovalResults[0].qtc_ApprovalAction__c, 'We expect the action to be updated to null');
    }

    @isTest
    static void afterUpdate_RecalledTest(){
        qtc_PaymentsApproval__c testPaymentsApproval = new qtc_PaymentsApproval__c();
        insert testPaymentsApproval;

        Test.startTest();
            testPaymentsApproval.qtc_ApprovalAction__c = APPROVAL_ACTION_RECALLED;
            update testPaymentsApproval;
        Test.stopTest();

        List<qtc_PaymentsApproval__c> listPaymentsApprovalResults = [SELECT qtc_ApprovalAction__c, ApprovalStatus__c FROM qtc_PaymentsApproval__c];
        System.assertEquals(1, listPaymentsApprovalResults.size(), 'We expect only one payment approval at this time');
        System.assertEquals(APPROVAL_STATUS_RECALLED, listPaymentsApprovalResults[0].ApprovalStatus__c, 'We expect the approval status to update');
        System.assertEquals(null, listPaymentsApprovalResults[0].qtc_ApprovalAction__c, 'We expect the action to be updated to null');
    }

    @isTest
    static void afterUpdate_BulkTest(){
        List<qtc_PaymentsApproval__c> listPaymentApprovals = new List<qtc_PaymentsApproval__c>();
        for( integer i=0; i< BULK_COUNT; i++){
            listPaymentApprovals.add( new qtc_PaymentsApproval__c());
        }
        insert listPaymentApprovals;

        Test.startTest();
            for( qtc_PaymentsApproval__c thisPaymentApproval : listPaymentApprovals ){
                thisPaymentApproval.qtc_ApprovalAction__c = APPROVAL_ACTION_SUBMIT;

            }
            update listPaymentApprovals;
        Test.stopTest();

        List<qtc_PaymentsApproval__c> listPaymentsApprovalResults = [SELECT qtc_ApprovalAction__c, ApprovalStatus__c FROM qtc_PaymentsApproval__c];
        System.assertEquals(BULK_COUNT, listPaymentsApprovalResults.size(), 'We expect only one payment approval at this time');
    }
}