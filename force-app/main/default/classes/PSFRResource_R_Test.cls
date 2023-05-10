/*
##################################################################################################
# Class Name............................:PSFRResource_R_Test                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5                          
################################################################################################
*/
@isTest
public class PSFRResource_R_Test{
    static testMethod void testMethod1(){
        KeysForSecuredUrls__c cs = new KeysForSecuredUrls__c();
        cs.Name='PSFREncryptionKey';
        cs.CryptoKey__c='8cPkFUCoHb9sa3D7@djdkjdk!%@ncmnc';
        //cs.Other fiels values
        insert cs;
        Account Acc=TestRecordsFactory.createAccount();
        Contact con=TestRecordsFactory.createContact(Acc);
        Opportunity opp=TestRecordsFactory.createSimpleOpportunity(Acc);
        Presales_Funding_Request__c PSFR_Obj=new Presales_Funding_Request__c();
        PSFR_Obj.PFR_Opportunity__c=opp.id;
        PSFR_Obj.PFR_Presales_Category__c ='1-Network Certification';
        PSFR_Obj.PFR_Is_this_Recoverable__c='Yes';
        PSFR_Obj.PFR_Expected_Date__c=system.today();
        PSFR_Obj.PFR_Justification__c='Test Justification';
        PSFR_Obj.PFR_Success_Criteria__c='Test Justification';
        insert PSFR_Obj;
        Resource__c objResource=new Resource__c();
        
        objResource.PSFundingRequest__c=PSFR_Obj.id;
        objResource.PFR_Num_of_days_not_to_exceed__c=20;
        objResource.PFR_BU__c='PS';
        objResource.PFR_Daily_Rate_USD__c=2;
        objResource.PFR_Travel_Cost__c=200;
        objResource.PFR_Task__c='Test';
        insert objResource;
        Presales_Engineer__c res = new Presales_Engineer__c();
        res.Email_ID_1__c = 'test1@gmail.com'; 
        res.Presales_Funding_Request__c = PSFR_Obj.id;
        Test.startTest();
        PageReference myVfPage = Page.PSFR_Site_Page;
        Test.setCurrentPage(myVfPage);
        system.assert(myVfPage!=null);
        System.currentPageReference().getParameters().put('id',PSFR_Obj.id);
        PSFRApexController testController = new PSFRApexController();
        testController.AddResource();
        testController.Submit();
        testController.save();
        testController.cancel();
        testController.EditR();
        testController.Auth_Check();
        testController.Generate_Auth_Token();
        testController.addPS();
        try{
            testController.AddPSTeam();
        }
        Catch(Exception e){
            System.debug('exception occured');
        }
        PSFR_Obj.Approval_Status__c='Sent to PS';
        update PSFR_Obj;
        PageReference myVfPage1 = Page.PSFR_Resource;
        Test.setCurrentPage(myVfPage1);
        String cs1 = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
        Blob cryptoKey = Blob.valueOf(cs1);
        string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(PSFR_Obj.id)));
        string encryptedMasterRecordId = encodedCipherText;//encodingUtil.URLEncode(encodedCipherText,'UTF-8');
       // System.currentPageReference().getParameters().put('id',encryptedMasterRecordId);
        System.currentPageReference().getParameters().put('Plid',encryptedMasterRecordId);
        PSFRResource_R ResourceObj=new PSFRResource_R();
        PSFRApexController PFCOV = new PSFRApexController();
        ResourceObj.rm=objResource;
        
        ResourceObj.WrapperList[0].Reso.PFR_Travel_Cost__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Daily_Rate_USD__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Num_of_days_not_to_exceed__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Travel_Cost__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Task__c='test';
        ResourceObj.addResource();
        // ResourceObj.TestCoverateMethod();
        // PFCOV.TestCoverateMethod();
        ResourceObj.addResource();
        

       ResourceObj.Calcualte();
         //ResourceObj.saveResource();
        try{
            ResourceObj.saveResource();
        }Catch(Exception e){
            System.debug('msg'+e.getMessage());
        }
        ResourceObj.COUNT_FRM_PAGE = 2;
        ResourceObj.removeResource();
        PSFR_Obj.Approval_Status__c='Send to PS';
      
        
        Test.StopTest();
        
    }
    static testMethod void testMethod2(){
         KeysForSecuredUrls__c cs = new KeysForSecuredUrls__c();
        cs.Name='PSFREncryptionKey';
        cs.CryptoKey__c='8cPkFUCoHb9sa3D7@djdkjdk!%@ncmnc';
        //cs.Other fiels values
        insert cs;
        
        Account Acc=TestRecordsFactory.createAccount();
        Contact con=TestRecordsFactory.createContact(Acc);
        Opportunity opp=TestRecordsFactory.createSimpleOpportunity(Acc);
        Presales_Funding_Request__c PSFR_Obj=new Presales_Funding_Request__c();
        PSFR_Obj.PFR_Opportunity__c=opp.id;
        PSFR_Obj.PFR_Presales_Category__c ='1-Network Certification';
        PSFR_Obj.PFR_Is_this_Recoverable__c='Yes';
        PSFR_Obj.PFR_Expected_Date__c=system.today();
        PSFR_Obj.PFR_Justification__c='Test Justification';
        PSFR_Obj.PFR_Success_Criteria__c='Test Justification';
        
        insert PSFR_Obj;
        PSFR_Obj.Approval_Status__c='On Hold';
        update PSFR_Obj;
        Resource__c objResource=new Resource__c();
        
        objResource.PSFundingRequest__c=PSFR_Obj.id;
        objResource.PFR_Num_of_days_not_to_exceed__c=20;
        objResource.PFR_BU__c='PS';
        objResource.PFR_Daily_Rate_USD__c=2;
        objResource.PFR_Travel_Cost__c=200;
        objResource.PFR_Task__c='Test';
        insert objResource;
        
        
        Presales_Engineer__c res = new Presales_Engineer__c();
        res.Email_ID_1__c = 'test1@gmail.com';
        res.Presales_Funding_Request__c = PSFR_Obj.id;
        Test.startTest();
        PageReference myVfPage = Page.PSFR_Site_Page;
        Test.setCurrentPage(myVfPage);
 	    system.assert(myVfPage!=null);
        System.currentPageReference().getParameters().put('id',PSFR_Obj.id);
        PSFRApexController testController = new PSFRApexController();
        testController.AddResource();
        testController.Submit();
        testController.save();
        testController.cancel();
        testController.EditR();
        testController.Auth_Check();
        testController.Generate_Auth_Token();
        testController.addPS();
        Test.StopTest();
    }
    static testMethod void testMethod3(){
         KeysForSecuredUrls__c cs = new KeysForSecuredUrls__c();
        cs.Name='PSFREncryptionKey';
        cs.CryptoKey__c='8cPkFUCoHb9sa3D7@djdkjdk!%@ncmnc';
        //cs.Other fiels values
        insert cs;
        Account Acc=TestRecordsFactory.createAccount();
        Contact con=TestRecordsFactory.createContact(Acc);
        Opportunity opp=TestRecordsFactory.createSimpleOpportunity(Acc);
        Presales_Funding_Request__c PSFR_Obj=new Presales_Funding_Request__c();
        PSFR_Obj.PFR_Opportunity__c=opp.id;
        PSFR_Obj.PFR_Presales_Category__c ='1-Network Certification';
        PSFR_Obj.PFR_Is_this_Recoverable__c='Yes';
        PSFR_Obj.PFR_Expected_Date__c=system.today();
        PSFR_Obj.PFR_Justification__c='Test Justification';
        PSFR_Obj.PFR_Success_Criteria__c='Test Justification';
        
        insert PSFR_Obj;
        PSFR_Obj.Approval_Status__c='On Hold';
        update PSFR_Obj;
        Resource__c objResource=new Resource__c();
        
        objResource.PSFundingRequest__c=PSFR_Obj.id;
        objResource.PFR_Num_of_days_not_to_exceed__c=20;
        objResource.PFR_BU__c='PS';
        objResource.PFR_Daily_Rate_USD__c=2;
        objResource.PFR_Travel_Cost__c=200;
        objResource.PFR_Task__c='Test';
        insert objResource;
        Presales_Engineer__c res = new Presales_Engineer__c();
        res.Email_ID_1__c = 'test1@gmail.com';
        res.Presales_Funding_Request__c = PSFR_Obj.id;
        Test.startTest();
        PageReference myVfPage = Page.PSFR_Site_Page;
        Test.setCurrentPage(myVfPage);
        system.assert(myVfPage!=null);
	    System.currentPageReference().getParameters().put('id',PSFR_Obj.id);
        PSFRApexController testController = new PSFRApexController();
        testcontroller.PS_Token = 'test';
        testController.EditR();
        testController.Auth_Check();
        testController.Generate_Auth_Token();
        testController.addPS();
        Test.StopTest();
    }
    static testMethod void testMethod4(){
         KeysForSecuredUrls__c cs = new KeysForSecuredUrls__c();
        cs.Name='PSFREncryptionKey';
        cs.CryptoKey__c='8cPkFUCoHb9sa3D7@djdkjdk!%@ncmnc';
        //cs.Other fiels values
        insert cs;
        Account Acc=TestRecordsFactory.createAccount();
        Contact con=TestRecordsFactory.createContact(Acc);
        Opportunity opp=TestRecordsFactory.createSimpleOpportunity(Acc);
        Presales_Funding_Request__c PSFR_Obj=new Presales_Funding_Request__c();
        PSFR_Obj.PFR_Opportunity__c=opp.id;
        PSFR_Obj.PFR_Presales_Category__c ='1-Network Certification';
        PSFR_Obj.PFR_Is_this_Recoverable__c='Yes';
        PSFR_Obj.PFR_Expected_Date__c=system.today();
        PSFR_Obj.PFR_Justification__c='Test Justification';
        PSFR_Obj.PFR_Success_Criteria__c='Test Justification';
        
        insert PSFR_Obj;
        Resource__c objResource=new Resource__c();
        
        objResource.PSFundingRequest__c=PSFR_Obj.id;
        objResource.PFR_Num_of_days_not_to_exceed__c=20;
        objResource.PFR_BU__c='PS';
        objResource.PFR_Daily_Rate_USD__c=2;
        objResource.PFR_Travel_Cost__c=200;
        objResource.PFR_Task__c='Test';
        insert objResource;
        Presales_Engineer__c res = new Presales_Engineer__c();
        res.Email_ID_1__c = 'test1@gmail.com';
        res.Presales_Funding_Request__c = PSFR_Obj.id;
        Test.startTest();
        PageReference myVfPage = Page.PSFR_Site_Page;
        Test.setCurrentPage(myVfPage);
        System.currentPageReference().getParameters().put('id',PSFR_Obj.id);
        System.currentPageReference().getParameters().put('Plid',PSFR_Obj.id);
        PSFRApexController testController = new PSFRApexController();
        testcontroller.PS_Token = 'test';
        testController.EditR();
        testController.Auth_Check();
        testController.Generate_Auth_Token();
        testController.addPS();
        PageReference myVfPage1 = Page.PSFR_Resource;
        Test.setCurrentPage(myVfPage1);
        system.assert(myVfPage1!=null);
        
        String cs1 = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
        Blob cryptoKey = Blob.valueOf(cs1);
        string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(PSFR_Obj.id)));
        string encryptedMasterRecordId = encodedCipherText; //encodingUtil.URLEncode(encodedCipherText,'UTF-8');
        System.currentPageReference().getParameters().put('Plid',encryptedMasterRecordId);
        PSFRResource_R ResourceObj=new PSFRResource_R();
        PSFRApexController PFCOV = new PSFRApexController();
        ResourceObj.rm=objResource;
        ResourceObj.WrapperList[0].Reso.PFR_Travel_Cost__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Daily_Rate_USD__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Num_of_days_not_to_exceed__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Travel_Cost__c=200;
        ResourceObj.WrapperList[0].Reso.PFR_Task__c='test';
        ResourceObj.addResource();
        // ResourceObj.TestCoverateMethod();
        // PFCOV.TestCoverateMethod();
        ResourceObj.addResource();
        ResourceObj.Calcualte();
        try{
            ResourceObj.saveResource();
        }Catch(Exception e){
            System.debug('msg'+e.getMessage());
        }
        Test.StopTest();
    }
}