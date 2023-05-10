@isTest
private class PaymentsApprovalExtControllerTests {
    
    testMethod static void testSubmit() {
        qtc_PaymentsApproval__c payApproval = new qtc_PaymentsApproval__c();
        insert payApproval;
        
        Test.startTest();
        PaymentsApprovalExtController con = new PaymentsApprovalExtController(new ApexPages.StandardController(payApproval));
        con.onSubmit();
        payApproval = [SELECT ApprovalStatus__c FROM qtc_PaymentsApproval__c WHERE Id = :payApproval.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', payApproval.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        qtc_PaymentsApproval__c payApproval = new qtc_PaymentsApproval__c();
        insert payApproval;
        
        Test.startTest();
        PaymentsApprovalExtController con = new PaymentsApprovalExtController(new ApexPages.StandardController(payApproval));
        con.onRecall();
        payApproval = [SELECT ApprovalStatus__c FROM qtc_PaymentsApproval__c WHERE Id = :payApproval.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', payApproval.ApprovalStatus__c);
    }
}