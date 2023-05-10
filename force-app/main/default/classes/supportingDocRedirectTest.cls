@isTest
public class supportingDocRedirectTest {

    public static testmethod void testSupportingDocRedirect() {
        // Insert Co-Op Request
        Co_Op__c coOpReq = new Co_Op__c();
        coOpReq.Activity_Name__c = 'Co Op Req';
        coOpReq.Activity_Start_Date__c = System.today();
        coOpReq.Activity_End_Date__c = System.today();
        insert coOpReq;
        
        List<Co_Op__c> coOpList = [Select Id FROM Co_Op__c LIMIT 100];
        PageReference pageRef = Page.co_op_supporting_document;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','id'); 
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([Select Id FROM Co_Op__c LIMIT 100]);
        supportingDocRedirect controller = new supportingDocRedirect(ssc);
        PageReference pr = controller.redirectToNewSupportDoc();
        system.assertNotEquals(pr, null);
    }
}