@isTest
public class SyncDisputeToERPCld_Test {
    static testMethod void TesDisputeCallout() {
        //Create Dispute Case
        Account acc =  TestRecordsFactory.createAccount();
        Contact con = TestRecordsFactory.createContact(acc);  
        Id RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.RT_Case_Dispute).getRecordTypeId(); 
        Case CaseObj = new Case();
        CaseObj.ContactId=con.Id;
        caseObj.Status='New';
        caseObj.Dispute_Reason__c='Returned Product';
        caseObj.CCAD_Dispute_Nbr__c='1111111111';
        
        insert CaseObj;
       	system.assertEquals(con.Id,CaseObj.ContactId);        
        Dispute_Invoices__c invoiceObj = new Dispute_Invoices__c();
        invoiceObj.Invoice_Number__c='11111111';
        invoiceObj.MCN__c='1016US';
        invoiceObj.Dispute__c=CaseObj.id;
        insert invoiceObj;
        system.assertEquals(con.Id,CaseObj.ContactId);  
        Test.startTest();
        //using Another service class to avoid additional issue as we just need 200 as response
        
        
        SyncDisputeToERPCld.disputeCallout(new Set<Id>{CaseObj.Id},true);
        SyncDisputeToERPCld.disputeCallout(new Set<Id>{CaseObj.Id},false);
        Test.stopTest();
        //Call out as code is blocked from respective method due to Go Live different
    }
    static testMethod void TesDisputeCallout1() {
        //Create Dispute Case
        Account acc =  TestRecordsFactory.createAccount();
        Contact con = TestRecordsFactory.createContact(acc);  
        Id RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.RT_Case_Dispute).getRecordTypeId(); 
        Case CaseObj = new Case();
        CaseObj.ContactId=con.Id;
        caseObj.Status='New';
        caseObj.Dispute_Reason__c='Returned Product';
        caseObj.CCAD_Dispute_Nbr__c='1111111111';
        
        insert CaseObj;
       	system.assertEquals(con.Id,CaseObj.ContactId);        
        Dispute_Invoices__c invoiceObj = new Dispute_Invoices__c();
        invoiceObj.Invoice_Number__c='11111111';
        invoiceObj.MCN__c='1016US';
        invoiceObj.Dispute__c=CaseObj.id;
        insert invoiceObj;
        system.assertEquals(con.Id,CaseObj.ContactId);  
        Test.startTest();
        //using Another service class to avoid additional issue as we just need 200 as response   
        
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationERPMockCallOut());
        SyncDisputeToERPCld.disputeCallout(new Set<Id>{CaseObj.Id},true);
        SyncDisputeToERPCld.disputeCallout(new Set<Id>{CaseObj.Id},false);
        Test.stopTest();
        //Call out as code is blocked from respective method due to Go Live different
    }
}