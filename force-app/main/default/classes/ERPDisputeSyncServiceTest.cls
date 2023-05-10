@isTest
public class ERPDisputeSyncServiceTest {
    static testMethod void syncDisputeTest() {        
        SOUP_Endpoint__c se = new SOUP_Endpoint__c(name='CCAD Invoice Rest', Username__c='test', Password__c = 'test', Endpoint_URL__c= 'test.ncr.com');
        insert se;
        
        Account acc = TestRecordsFactory.createAccount();
        //RecordType r =[Select id from recordtype where developername ='Partner']; 
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
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
        List<OracleCloudToSFService.InvoiceList> oraInvLst = new List<OracleCloudToSFService.InvoiceList>();
        OracleCloudToSFService.InvoiceList oraInvObj = new OracleCloudToSFService.InvoiceList();
        oraInvObj.CountryCode='US';
        oraInvObj.InvoiceNumber='asdasdas';
        oraInvObj.MCN=acc.Master_Customer_Number__c;
        oraInvLst.add(oraInvObj);
        Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();  
        All_profie_config__c objall = new All_profie_config__c();
        objall.Name='CCAD Service Ignored Profile';
        objall.Profile_Name__c='Test';
        objall.Profile_Id__c='1234567777';
        insert objall;
        All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile';
        // setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = NSCCommonInfoUtil.getIdOf('CCAD_Service_Ignored_Profile_Id');
        insert setting;
        Case caseObj = new Case();
        caseObj.RecordTypeId = DisputeRecordTypeId;
        caseObj.Master_Customer_Nbr__c='12345';
        caseObj.Country_Code__c='US';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';  
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        insert caseObj;
        
        
        ERPCloudDisputeSyncService.ContactDetail custContact = new ERPCloudDisputeSyncService.ContactDetail();
        custContact.Name = 'Test Contact';
        custContact.Email = 'test@gmail.com';
        custContact.Phone = '121313132424';
        
        ERPCloudDisputeSyncService.ContactDetail altContact = new ERPCloudDisputeSyncService.ContactDetail();
        altContact.Name = 'Test Contact';
        altContact.Email = 'test@ncr.com';
        altContact.Phone = '121313132424';
        
        
        ERPCloudDisputeSyncService.AttachmentDetail attDetail = new ERPCloudDisputeSyncService.AttachmentDetail();
        attDetail.Attachment_FULL_URL = 'test@ncr.com'; 
        attDetail.Attachment_Description = 'test';
        attDetail.Attachment_Source = ERPCloudDisputeSyncService.SourceSystem.CCAD;
        
        
        ERPCloudDisputeSyncService.DisputeAttachment dispAttach = new ERPCloudDisputeSyncService.DisputeAttachment();
        dispAttach.Attachment = new List<ERPCloudDisputeSyncService.AttachmentDetail>{attDetail};
            
            ERPCloudDisputeSyncService.InvoiceDetail invDetail = new ERPCloudDisputeSyncService.InvoiceDetail();
        invDetail.Invoice_Id = 'asdasdas';
        invDetail.Invoice_Amount = 100;
        
        ERPCloudDisputeSyncService.InvoiceData invData = new ERPCloudDisputeSyncService.InvoiceData();
        invData.Invoicedetail = new List<ERPCloudDisputeSyncService.InvoiceDetail>{invDetail};
            
            
            ERPCloudDisputeSyncService.DisputeDetail disputeDetail = new ERPCloudDisputeSyncService.DisputeDetail();
        disputeDetail.CustomerName = acc.Name;
        disputeDetail.MasterCustomerNumber = acc.Master_Customer_Number__c;
        disputeDetail.CountryCode = acc.Account_Country_Code__c;
        disputeDetail.CustomerContact = custContact;
        disputeDetail.AlternateContact =  altContact;
        disputeDetail.DisputeAnalyst_QLId = 'ma185260';     
        //  disputeDetail.CCADDisputeNbr = '12345';
        disputeDetail.ERPDisputeNbr = '12345';
        disputeDetail.ReasonCode = '374';  
        disputeDetail.Description = 'Test Description';
        // disputeDetail.Escalated = false;
        disputeDetail.Status = '10';
        disputeDetail.CreateByUser_QLId = 'test1234'; 
        disputeDetail.UpdatedByUser_QLId = 'test1234'; 
        disputeDetail.DisputedAmount = 100;
        disputeDetail.CurrencyCode = 'USD';
        disputeDetail.CreditAmount = 100;
        disputeDetail.RebillAmount = 100;
        disputeDetail.DisputeSource = ERPCloudDisputeSyncService.SourceSystem.MYNCR;
        disputeDetail.CaseComments = 'test';
        disputeDetail.isPublicComment  = false;
        disputeDetail.AttachmentList = dispAttach;
        disputeDetail.InvoiceList = invData;  
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationERPMockCallOut());     
        ERPDisputeUtil erpObj = new ERPDisputeUtil();
        ERPCloudDisputeSyncService.SyncDispute_ERPCloud(disputeDetail);
        
        Test.startTest();
        ERPCloudDisputeSyncService.SyncDispute_ERPCloud(disputeDetail);
        Test.stopTest();
    }
    
    
    static testMethod void runTest() {    
        SOUP_Endpoint__c se = new SOUP_Endpoint__c(name='CCAD Invoice Rest', Username__c='test', Password__c = 'test', Endpoint_URL__c= 'test.ncr.com');
        insert se;
        Id DisputeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();  
        All_profie_config__c objall = new All_profie_config__c();
        objall.Name='CCAD Service Ignored Profile';
        objall.Profile_Name__c='Test';
        objall.Profile_Id__c='1234567777';
        insert objall;
        All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile';
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = NSCCommonInfoUtil.getIdOf('CCAD_Service_Ignored_Profile_Id');
        insert setting;
        Case caseObj = new Case();
        caseObj.RecordTypeId = DisputeRecordTypeId;
        caseObj.Master_Customer_Nbr__c='12345';
        caseObj.Country_Code__c='US';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';  
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        insert caseObj;
        
        Dispute_Invoices__c invOvj= new Dispute_Invoices__c();
        invOvj.Invoice_Number__c= 'asdasdas';
        invOvj.Total_Invoice_Amount__c=1234567;
        invOvj.Customer_Trx_ID__c=1378389;
        invOvj.Dispute__c=caseObj.id;
        insert invOvj;
        
        SetDisputeStatusCode__c onjsts= new SetDisputeStatusCode__c();
        onjsts.Name ='test';
        insert onjsts;
        Test.startTest();
        ERPDisputeUtil erpObj = new ERPDisputeUtil();
        erpObj.getCaseDetail(caseObj.CaseNumber,DisputeRecordTypeId);
        erpObj.getDisputeDetail(new List<String>{caseObj.Id});
        erpObj.getCaseDetailById(caseObj.Id);
        erpObj.getAccountDetail(caseObj.Master_Customer_Nbr__c);
        erpObj.getContactsDetail(new Set<String>{'ys250288@ncr.com'});
        erpObj.getDisputeCaseRecordTypeId('Dispute');
        erpObj.getUsersDetail(new Set<String>{'ys250288'});
        erpObj.getEmpDetail(new Set<String>{'ys250288'});
        erpObj.getAllNonSFAttachments(caseObj.Id);
        Account acc = TestRecordsFactory.createAccount();
        erpObj.isNCRContact('ys250288@ncr.com');
        erpObj.matchPattern('test');
        ERPCloudDisputeSyncService.ContactDetail custContact = new ERPCloudDisputeSyncService.ContactDetail();
        custContact.Name = 'Test Contact';
        custContact.Email = 'test@gmail.com';
        custContact.Phone = '121313132424';
        erpObj.createContact(custContact,acc.id,true);
        erpObj.getCaseStatus('test');
        erpObj.getOpenDspInvs(new List<String>{'asdasdas'},acc.Master_Customer_Number__c);
        CCAD_Config__mdt objCCAD = new CCAD_Config__mdt();
        objCCAD.Label='Org_Config';
        objCCAD.DeveloperName='Org_Config';
        objCCAD.Dispute_ROR_System__c='SF';
        DisputeUtil.getDspROR();
        List<OracleCloudToSFService.InvoiceList> oraInvLst = new List<OracleCloudToSFService.InvoiceList>();
        OracleCloudToSFService.InvoiceList oraInvObj = new OracleCloudToSFService.InvoiceList();
        oraInvObj.CountryCode='US';
        oraInvObj.InvoiceNumber='asdasdas';
        oraInvObj.MCN=acc.Master_Customer_Number__c;
        oraInvLst.add(oraInvObj);
        ERPDisputeUtil.populateInvoiceDetail_Oracle(oraInvObj, invOvj, caseObj.caseNumber);
        ERPCloudDisputeSyncService.ERPDisputeSyncResponse orbERp = new ERPCloudDisputeSyncService.ERPDisputeSyncResponse('Test','Test','Test',new List<String>{'Test'},'Test',100);
        orbERp.result='Success';
        ERPDisputeUtil.getInvoiceDetailInFuture(new List<String>{caseObj.Id}, caseObj.Country_Code__c,'test');
        ERPDisputeUtil.getInvoiceDetailFromERP_Oracle(new List<String>{'asdasdas'},'US',acc.Master_Customer_Number__c,orbERp,oraInvLst);
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationERPMockCallOut()); 
        
        Test.stopTest();
        CCADDLogsUtility.insertCCADDLogs('Test', 'Test', 'Test', '1223455', '32324324322222225454566634', 'test'); 
    }   
}