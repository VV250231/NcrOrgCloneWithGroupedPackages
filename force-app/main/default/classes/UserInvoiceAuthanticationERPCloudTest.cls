@isTest
public class UserInvoiceAuthanticationERPCloudTest {
    //Test coverage for RedirectToDisputeCaseController and  UserInvoiceAuthanticationCCAD and LightningFileUploadHandler
    @isTest static  void validateUserEnteredInvoicesDisputeExist(){ 
        
        UserInvoiceAuthanticationCCAD UserInvoiceAuthObj = new UserInvoiceAuthanticationCCAD();
        
        UserInvoiceAuthanticationCCAD.validateUserEnteredInvoices('5000013373');
        UserInvoiceAuthanticationOracle_ERPCloud  UserInvoiceAuthObj1 = new UserInvoiceAuthanticationOracle_ERPCloud();
        UserInvoiceAuthanticationOracle_ERPCloud.validateUserEnteredInvoices('5000013373');
        SOUP_Endpoint__c customSettingObj = new SOUP_Endpoint__c();
        customSettingObj.Name='CCAD Invoice Rest';
        customSettingObj.Endpoint_URL__c='https://osbcert-ha.ncr.com/ext/EA/Services/ERP/Invoice/getInvoiceDetails';
        customSettingObj.Username__c='sa230896';
        customSettingObj.Password__c='aehWu5yxJ68c6b272yQw#2v9yoj!T6';
        insert  customSettingObj;
        
        String RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        
        Account acc =  TestRecordsFactory.createAccount();
        Contact con = TestRecordsFactory.createContact(acc);
        All_profie_config__c obj = new All_profie_config__c();
        obj.Profile_Id__c ='Test';
        obj.Profile_Name__c ='CCAD Service Ignored Profile';
        obj.Name='CCAD Service Ignored Profile';
        insert obj;   
        Case CaseObj = new Case();
        CaseObj.ContactId=con.Id;
        CaseObj.RecordTypeId=RecordTypeId;
        insert CaseObj;
        system.assertEquals(con.Id,CaseObj.ContactId);
        Dispute_Invoices__c invoiceObj = new Dispute_Invoices__c();
        invoiceObj.Invoice_Number__c='5000013373';
        invoiceObj.Dispute__c=CaseObj.id;
        insert invoiceObj;
        
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationERPMockCallOut());     
        List<String> invoiceList = new List<String>();
        invoiceList.add('5000013373'); 
        
        Dispute_Integration_Logs__c DisputeInteLogObj = new Dispute_Integration_Logs__c();
        DisputeInteLogObj.Name ='Request for Reparenting';
        insert DisputeInteLogObj;
        
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=DisputeInteLogObj.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        List<ReparentingOfContentlink.CaseContentLogWrapper> CaseContentWrapObj = new List<ReparentingOfContentlink.CaseContentLogWrapper>();
        ReparentingOfContentlink.CaseContentLogWrapper ContendObj = new ReparentingOfContentlink.CaseContentLogWrapper();
        ContendObj.CaseId = CaseObj.Id;
        ContendObj.RequestLogId = DisputeInteLogObj.Id;
        CaseContentWrapObj.add(ContendObj);
        
        
        
        
        test.startTest();
        UserInvoiceAuthanticationCCAD.authanticateUserEnteredInvoice(invoiceList,'GB');
        UserInvoiceAuthanticationCCAD.authanticateInvoiceFrom_ERPOnPrm(invoiceList,'GB');
        UserInvoiceAuthanticationOracle_ERPCloud.authanticateUserEnteredInvoice(invoiceList,'GB');
        String s1;
        if(UserInvoiceAuthanticationCCAD.getERPSysType()=='ERP Cloud'){
            s1 = '2018-03-30';
        }	else{
         s1 = '30-MAR-2018';
        }
        String s ='[{"BalanceDue":"0","CountryCode":"IT","CurrencyCode":"EUR","CustomerName":"SIMLOU S.R.L.","CustomerTrxID":"1325065184","FreightAmount":"0","InvoiceDate":"'+s1+'","InvoiceNumber":"201820662","InvoiceStatus":"Valid","LineAmount":"1767.5","MCN":"5134171","OriginalBalance":"2156.35","PONumber":" ","QuoteNumber":" ","RelatedOrder":"1066581","Source":"OKS_CONTRACTS","SummaryInvoice":" ","TaxAmount":"388.85","TotalInvoiceAmount":"2156.35","TransactionType":"Invoice-OKS"}]';
        RedirectToDisputeCaseController.ParseDataToDisputeObj(s,CaseObj.Id);
        LightningFileUploadHandler.getFiles(DisputeInteLogObj.Id);
        LightningFileUploadHandler.deleteFiles(DisputeInteLogObj.Id);
        ReparentingOfContentlink.UpdateContentLink(CaseContentWrapObj);
        DisputeAnalystController.getPicklistValues('Case','Dispute_Analyst_Name__c');
        DisputeAnalystController.getPicklistValues('Case','Country_Name__c');
        test.stopTest();
        
    }
    List<DisputeAnalystController.PicklistWrapperClass> getCountryNameWithCode = new List<DisputeAnalystController.PicklistWrapperClass>();
    
    
    @isTest static  void validateUserEnteredInvoices(){ 
        UserInvoiceAuthanticationCCAD UserInvoiceAuthObj = new UserInvoiceAuthanticationCCAD();
        UserInvoiceAuthanticationCCAD.validateUserEnteredInvoices('5000013373');
        UserInvoiceAuthanticationOracle_ERPCloud UserInvoiceAuthObj1 = new UserInvoiceAuthanticationOracle_ERPCloud();
        UserInvoiceAuthanticationOracle_ERPCloud.validateUserEnteredInvoices('5000013373');    
        SOUP_Endpoint__c customSettingObj = new SOUP_Endpoint__c();
        customSettingObj.Name='CCAD Invoice Rest';
        customSettingObj.Endpoint_URL__c='https://osbcert-ha.ncr.com/ext/EA/Services/ERP/Invoice/getInvoiceDetails';
        customSettingObj.Username__c='sa230896';
        customSettingObj.Password__c='aehWu5yxJ68c6b272yQw#2v9yoj!T6';
        insert  customSettingObj;
        Test.setMock(HttpCalloutMock.class, new UserInvoiceAuthanticationERPMockCallOut());     
        List<String> invoiceList = new List<String>();
        invoiceList.add('5000013373'); 
        
        test.startTest();
        UserInvoiceAuthanticationCCAD.authanticateUserEnteredInvoice(invoiceList,'GB');
        UserInvoiceAuthanticationCCAD.authanticateInvoiceFrom_ERPOnPrm(invoiceList,'GB');
        UserInvoiceAuthanticationOracle_ERPCloud.authanticateUserEnteredInvoice(invoiceList,'GB');
        String s ='[{"BalanceDue":"0","CountryCode":"IT","CurrencyCode":"EUR","CustomerName":"SIMLOU S.R.L.","CustomerTrxID":"1325065184","FreightAmount":"0","InvoiceDate":"30-MAR-2018","InvoiceNumber":"201820662","InvoiceStatus":"Valid","LineAmount":"1767.5","MCN":"5134171","OriginalBalance":"2156.35","PONumber":" ","QuoteNumber":" ","RelatedOrder":"1066581","Source":"OKS_CONTRACTS","SummaryInvoice":" ","TaxAmount":"388.85","TotalInvoiceAmount":"2156.35","TransactionType":"Invoice-OKS"}]';
        InvoiceSummeryController.GetInvoiceSummery(s);
        DisputeAnalystController.GetUserDetailUsingQuickLookid('pk185150');
        test.stopTest();
    }
    
    //Test Coverage for DisputeDetailController
    @isTest static  void validateUserEnteredInvoicesTest(){
        List<Dispute_Reason_and_Flwup_Question__mdt> MatadataObj= DisputeDetailController.getDisputeReason();
        DisputeDetailController.getFollowUpAnsAndDetailQuestion(MatadataObj[0].Id);
    }
    
    //Test Coverage for LookupLiteController and customLookUpController
    @isTest static  void LookupLiteControllerTest(){
        
        Account acc =  TestRecordsFactory.createAccount('23456','Financial','India');
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();//0127000000014kqAAA
        Contact con = TestRecordsFactory.createContact(acc);
        LookupLiteController.fetchRecords('Contact','LastName','test');
        LookupLiteController.fetchSelectedRecord('Contact',con.id);
        Contact Altrncon = TestRecordsFactory.createContact(acc);
        LookupLiteController.UpdateContact(con.id,Altrncon.Id,'1234312310','009876656','123456');
        System.runAs(TestRecordsFactory.getUser()){
            Account a = new Account(      
                Account_Country_Code__c = 'EG',
                Active_Account__c = true,        
                Master_Customer_Number__c = 'APOC1111',
                Name = 'Unit Test ' + System.now(),
                RecordTypeId =r  
            );
            insert a;
        }
        
        //Custom LookUpController
        customLookUpController.fetchLookUpValues('test','Contact');
        customLookUpController.getCreatedRecord(con.id,'Contact');
        customLookUpController.checkIfContactExist('Test@ncr.com','Contact','009876656','TestFunction','TestFirstName','TestLastName','23456');
        
        //String DisputeDate = '{"Dispute_ID":0,"Submitter_Name":"Demo Lead1 - 11.9","Submitter_Phone_Num":"123312123","Submitter_Email":"demolead1@test.com","DisputeReason":"374","DisputedAmount":100,"Alternate_Contact_Name":"Stephanie Test Contact","Alternate_Contact_Phone":"123123","Alternate_Contact_Email":"stephcontact@test.com","FollowupQuestion":"Do you have updated contract documentation?","FollowupAnswer":"No","DisputeDetails":"2826383341\n","Dispute_Status":"10","ERP_Dispute_Number":"","Master_Customer_Number":"1631","Country":"US","Currency_Code":"USD","DisputeAnalystName":"ma185260"}';
        String s1;
        if(UserInvoiceAuthanticationCCAD.getERPSysType()=='ERP Cloud'){
            s1 = '2018-03-30';
        }	else{
         s1 = '30-MAR-2018';
        }
        String TableDate ='[{"BalanceDue":"0","CountryCode":"IT","CurrencyCode":"EUR","CustomerName":"SIMLOU S.R.L.","CustomerTrxID":"1325065184","FreightAmount":"0","InvoiceDate":"'+s1+'","InvoiceNumber":"201820662","InvoiceStatus":"Valid","LineAmount":"1767.5","MCN":"5134171","OriginalBalance":"2156.35","PONumber":" ","QuoteNumber":" ","RelatedOrder":"1066581","Source":"OKS_CONTRACTS","SummaryInvoice":" ","TaxAmount":"388.85","TotalInvoiceAmount":"2156.35","TransactionType":"Invoice-OKS"}]';
        //String TableDate = '"[{\"BalanceDue\":\"0\",\"CountryCode\":\"US\",\"CurrencyCode\":\"USD\",\"CustomerName\":\"BANK OF AMERICA OF CHARLOTTE N.C.\",\"CustomerTrxID\":\"1325496862\",\"FreightAmount\":\"0\",\"InvoiceDate\":\"08-MAY-2018\",\"InvoiceNumber\":\"2826383341\",\"InvoiceStatus\":\"Valid\",\"LineAmount\":\"46.55\",\"MCN\":\"1631\",\"OriginalBalance\":\"49.81\",\"PONumber\":\" \",\"QuoteNumber\":\" W\",\"RelatedOrder\":\"1439113\",\"Source\":\"OKS_CONTRACTSINV\",\"SummaryInvoice\":\"S900078415\",\"TaxAmount\":\"3.26\",\"TotalInvoiceAmount\":\"49.81\",\"TransactionType\":\"Invoice-OKS\"}]"';
        
        LookupLiteController.DisputeDataWrapper WrapDataTest = new LookupLiteController.DisputeDataWrapper();
        //WrapDataTest
        WrapDataTest.Dispute_ID='0';
        WrapDataTest.Submitter_Name='test';
        WrapDataTest.Submitter_Phone_Num='12122';
        WrapDataTest.Submitter_Email='test@gmail.com';
        WrapDataTest.DisputeReason='374';
        WrapDataTest.DisputedAmount=100;
        WrapDataTest.Alternate_Contact_Name='Testcon';
        WrapDataTest.Alternate_Contact_Phone='0121';
        WrapDataTest.Alternate_Contact_Email='test@gmail.com';
        WrapDataTest.FollowupQuestion='testQuestion';
        WrapDataTest.FollowupAnswer='test';
        WrapDataTest.DisputeDetails='testing';
        WrapDataTest.Dispute_Status='10';
        WrapDataTest.Master_Customer_Number='12331';
        WrapDataTest.Country='US';
        WrapDataTest.Currency_Code='US';
        WrapDataTest.DisputeAnalystName='tEST nAME';
        
        WrapDataTest.DisputeAnalystPhone='123';
        
        WrapDataTest.DisputeAnalystEmail='Test@gmail.com';
        test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new sendDisputesToCCAD_MockCallOut()); 
        LookupLiteController.CreateDisputeInCCAD(JSON.serialize(WrapDataTest),TableDate); 
        UserInvoiceAuthanticationOracle_ERPCloud.getCountryNameWithCode();
        test.StopTest();   
        
        
        
        
    }
    @isTest static  void LookupLiteControllerTest1(){
        
        Account acc =  TestRecordsFactory.createAccount('23456','Financial','India');
        Contact con = TestRecordsFactory.createContact(acc); 
        customLookUpController.checkIfContactExist('test1@test.com','Contact','009876656','TestFunction','TestFirstName','TestLastName','213456');
        
    }
    
    @isTest static  void LookupLiteControllerTest2(){   
        customLookUpController.checkIfContactExist('test1@test.com','Contact','009876656','TestFunction','TestFirstName','TestLastName','213456');  
    }
    @isTest static  void LookupLiteControllerTest3(){   
        customLookUpController.checkIfContactExist('test1@test.com','Contact','009876656','TestFunction','TestFirstName','TestLastName','');  
    }
    
    //Test Coverage for DisputeCaseFlowComponentController
    @isTest static  void DisputeCaseFlowComponentControllerTest(){  
        DisputeCaseFlowComponentController.getListViews();
        DisputeCaseFlowComponentController.getUserAccessForDispute();
        User u =[Select id from User where User_profile__c='Financial CSM' and isactive=true limit 1];
        System.runAs(u){
            DisputeCaseFlowComponentController.getUserAccessForDispute();
        }
    }
    
}