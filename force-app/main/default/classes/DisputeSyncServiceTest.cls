@isTest
private class DisputeSyncServiceTest {
    
    static testMethod void syncDisputeTest() {        
        SOUP_Endpoint__c se = new SOUP_Endpoint__c(name='CCAD Invoice Rest', Username__c='test', Password__c = 'test', Endpoint_URL__c= 'test.ncr.com');
        insert se;
        
        All_profie_config__c obj = new All_profie_config__c();
        obj.Profile_Id__c ='Test';
        obj.Profile_Name__c ='CCAD Service Ignored Profile';
        obj.Name='CCAD Service Ignored Profile';
        insert obj;
        
        SetDisputeStatusCode__c disputeStaus = new SetDisputeStatusCode__c(Name='New',caseStatus__c='New' , caseStatusCode__c = 10);
        insert disputeStaus;
        
        Account acc = TestRecordsFactory.createAccount();
        System.assertEquals(acc.Name, 'Test Acc','Account Name is null');
        //RecordType r =[Select id from recordtype where developername ='Partner']; 
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        System.assertNotEquals(r, null,'RecordType is null');
        System.runAs(TestRecordsFactory.getUser()) {
            Account apocAcc = new Account(      
                Account_Country_Code__c = 'EG',
                Active_Account__c = true,        
                Master_Customer_Number__c = 'APOC1111',
                Name = 'Unit Test ' + System.now(),
                RecordTypeId = r,//'0127000000014kqAAA',
                RoR_Update_Date_Time__c = System.now(),
                Industry = 'RETAIL:CHANNEL',
                account_region__c='INDIA'
            );
            
            insert apocAcc;
        }

        DisputeSyncService.ContactDetail custContact = new DisputeSyncService.ContactDetail();
        custContact.Name = 'Test Contact';
        custContact.Email = 'test@gmail.com';
        custContact.Phone = '121313132424';
        
        DisputeSyncService.ContactDetail altContact = new DisputeSyncService.ContactDetail();
        altContact.Name = 'Test Contact';
        altContact.Email = 'test@ncr.com';
        altContact.Phone = '121313132424';
        
        
        DisputeSyncService.AttachmentDetail attDetail = new DisputeSyncService.AttachmentDetail();
        attDetail.Attachment_FULL_URL = 'test@ncr.com'; 
        attDetail.Attachment_Description = 'test';
        attDetail.Attachment_Source = DisputeSyncService.SourceSystem.CCAD;

               
        DisputeSyncService.DisputeAttachment dispAttach = new DisputeSyncService.DisputeAttachment();
        dispAttach.Attachment = new List<DisputeSyncService.AttachmentDetail>{attDetail};
            
        DisputeSyncService.InvoiceDetail invDetail = new DisputeSyncService.InvoiceDetail();
        invDetail.Invoice_Id = 'INV1234';
        invDetail.Invoice_Amount = '100';
        
        DisputeSyncService.InvoiceData invData = new DisputeSyncService.InvoiceData();
        invData.Invoicedetail = new List<DisputeSyncService.InvoiceDetail>{invDetail};
       
        
        DisputeSyncService.DisputeDetail disputeDetail = new DisputeSyncService.DisputeDetail();
        disputeDetail.CustomerName = acc.Name;
        disputeDetail.MasterCustomerNumber = acc.Master_Customer_Number__c;
        disputeDetail.CountryCode = acc.Account_Country_Code__c;
        disputeDetail.CustomerContact = custContact;
        disputeDetail.AlternateContact =  altContact;
        disputeDetail.DisputeAnalyst_QLId = 'ma185260';     
        disputeDetail.CCADDisputeNbr = '12345';
        disputeDetail.ERPDisputeNbr = '12345';
        disputeDetail.ReasonCode = '374';  
        disputeDetail.Description = 'Test Description';
        disputeDetail.Escalated = false;
        disputeDetail.Status = '10';
        disputeDetail.CreateByUser_QLId = 'test1234'; 
        disputeDetail.UpdatedByUser_QLId = 'test1234'; 
        disputeDetail.DisputedAmount = 100;
        disputeDetail.CurrencyCode = 'USD';
        disputeDetail.CreditAmount = 100;
        disputeDetail.RebillAmount = 100;
        disputeDetail.DisputeSource = DisputeSyncService.SourceSystem.CCAD;
        disputeDetail.CaseComments = 'test';
        disputeDetail.isPublicComment  = false;
        disputeDetail.AttachmentList = dispAttach;
        disputeDetail.InvoiceList = invData;  
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationCCADMockCallOut());     
        System.assertNotEquals(disputeDetail, null,'disputeDetail is null');
       Test.startTest();
        DisputeSyncService.SyncDispute(disputeDetail);
        DisputeSyncService.SyncDispute(disputeDetail);
       Test.stopTest();
    }
    
    
     static testMethod void runTest() {    
        SOUP_Endpoint__c se = new SOUP_Endpoint__c(name='CCAD Invoice Rest', Username__c='test', Password__c = 'test', Endpoint_URL__c= 'test.ncr.com');
        insert se;
    	Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();  
        System.assertNotEquals(DisputeRecordTypeId, null,'Dispute RecordTypeId is null'); 
        All_profie_config__c obj = new All_profie_config__c();
         obj.Profile_Id__c ='Test';
         obj.Profile_Name__c ='CCAD Service Ignored Profile';
         obj.Name='CCAD Service Ignored Profile';
         insert obj;
         SetDisputeStatusCode__c disputeStaus = new SetDisputeStatusCode__c(Name='New',caseStatus__c='New' , caseStatusCode__c = 10);
        insert disputeStaus;
        Case caseObj = new Case();
        caseObj.RecordTypeId = DisputeRecordTypeId;
        caseObj.Master_Customer_Nbr__c='12345';
        caseObj.Country_Code__c='IT';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';  
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        insert caseObj;
         
        Dispute_Invoices__c invOvj= new Dispute_Invoices__c();
        invOvj.Invoice_Number__c= '201820662';
        invOvj.Total_Invoice_Amount__c=1234567;
        invOvj.Customer_Trx_ID__c=1378389;
        invOvj.Dispute__c=caseObj.id;
        insert invOvj;
       
         
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationCCADMockCallOut()); 
        DisputeUtil.getInvoiceDetailInFuture(caseObj.Id, caseObj.Country_Code__c);
        Test.stopTest();
        
         CCADDLogsUtility.insertCCADDLogs('Test', 'Test', 'Test', '1223455', '32324324322222225454566634', 'test');

     }
    
   
    
}