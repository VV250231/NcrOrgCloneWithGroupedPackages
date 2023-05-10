@istest(SeeAllData=true)
public class MDFListViewCmpControllerTest 
{
    public static testmethod void testMDFDetails() 
    {
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
            
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
            
            lstMDFClaim.add(mdfClaim);
        }
        insert  lstMDFClaim;
        
        MDFListViewCmpController.getMDFRequestController(false, false, 0, '');
        MDFListViewCmpController.getMDFRequestController(true, false, 5, '');
        MDFListViewCmpController.getMDFRequestController(false, true, 15, ''); 
        
        string oldString;// String.escapeSingleQuotes('Approved');
        MDFListViewCmpController.getMDFRequestController(false, false, 0,null);
        //MDFListViewCmpController.getMDFRequestController(false, false, 0, ' where Status__c =:'+oldString);
        //MDFListViewCmpController.getMDFRequestController(false, false, 0, ' where Status__c =:'+oldString); 
           
        Test.startTest();
        MDFListViewCmpController.deleteMDFRequest(false, false, 20, lstMDF[21].Id);
        
        MDFListViewCmpController.getMDFDetailInformation(lstMDF[0].Id);
        MDFListViewCmpController.submitMdfRequestForApproval(lstMDF[0], 'Test');
      
        Test.stopTest();
    }
    
    public static testmethod void testMDFDetails2() 
    {
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
            
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
            
            lstMDFClaim.add(mdfClaim);
        }
        insert lstMDFClaim;
        
        Test.startTest();
        MDFListViewCmpController.submitMdfClaimForApproval(lstMDFClaim[0], 'Test');
        Test.stopTest();       
    }
    
    public static testmethod void testMDFDetails3() 
    {
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
            
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
            
            lstMDFClaim.add(mdfClaim);
        }
        insert lstMDFClaim;
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Approved');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Request Pending for Approvals');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Rejected');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Created Today');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Pending');
        MDFListViewCmpController.changeViewSelection(false, false, 5, '');
        MDFListViewCmpController.saveActivityResult(lstMDF[0]);
        
        MDFListViewCmpController.saveChunk('Fund Request', 'Test', 'Test', lstMDF[0].Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        MDFListViewCmpController.saveChunk('Fund Claim', 'Test', 'Test', lstMDFClaim[0].Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = lstMDF[0].Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        
        Test.startTest();
        MDFListViewCmpController.saveChunk('Fund Request', 'Test', 'Test', lstMDF[0].Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
        
        File__c objFile = new File__c();
        objFile.Name = 'Test';
        objFile.CP_Is_Cloned__c = false;
        objFile.Fund_Request__c = lstMDF[0].Id;
        objFile.Attachment_ID__c = oAttachment.Id;
        insert objFile;
        
        MDFListViewCmpController.preAppFileList(lstMDF[0].Id);
        
        File__c objFile2 = new File__c();
        objFile2.Name = 'Test';
        objFile2.CP_Is_Cloned__c = false;
        objFile2.Fund_Request__c = lstMDF[0].Id;
        objFile2.Attachment_ID__c = oAttachment.Id;
        objFile2.Claim__c = true;
        insert objFile2;
        MDFListViewCmpController.updatePreAppFileList(new List<File__c> {objFile2}, lstMDFClaim[0].Id);
        MDFListViewCmpController.getRefreshedFiles(null, lstMDFClaim[0].Id);
        MDFListViewCmpController.getRefreshedFiles(lstMDF[0].Id, null);
        MDFListViewCmpController.getRefreshedFiles(lstMDF[0].Id, lstMDFClaim[0].Id);
        Test.stopTest();
    }
    
    public static testmethod void testMDFDetails4() { {
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
            
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
            
            lstMDFClaim.add(mdfClaim);
        }
        insert lstMDFClaim;
        
        MDFListViewCmpController.getMDFRequestController(false, false, 0, '');
        MDFListViewCmpController.getMDFRequestController(true, false, 5, '');
        MDFListViewCmpController.getMDFRequestController(false, true, 15, ''); 
        
        MDFListViewCmpController.getMDFRequestController(false, false, 0, ' where Status__c = \'Approved\'');
        MDFListViewCmpController.getMDFRequestController(true, false, 5, ' where Status__c = \'Approved\'');
        MDFListViewCmpController.getMDFRequestController(false, true, 15, ' where Status__c = \'Approved\''); 
        Test.startTest();
        MDFListViewCmpController.deleteMDFRequest(false, false, 20, lstMDF[21].Id);
        
        MDFListViewCmpController.getMDFDetailInformation(lstMDF[0].Id);
        MDFListViewCmpController.submitMdfRequestForApproval(lstMDF[0], 'Test');
        MDFListViewCmpController.deletePreApprovalDoc('Test','Approved');
       //MDFListViewCmpController.saveActivityResult('mdfReq');
        Test.stopTest();
    }
                                                     
  }
   /* public static testmethod void testMDFDetails6() 
    {
        string Agenda;
        string Agenda1;
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
            
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
            
            lstMDFClaim.add(mdfClaim);
        }
        insert lstMDFClaim;
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Approved');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Request Pending for Approvals');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Rejected');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Created Today');
        MDFListViewCmpController.changeViewSelection(false, false, 5, 'Pending');
        MDFListViewCmpController.changeViewSelection(false, false, 5, '');
        MDFListViewCmpController.saveActivityResult(lstMDF[0]);
        
        MDFListViewCmpController.saveChunk('Fund Request', 'Test', 'Test', lstMDF[0].Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        MDFListViewCmpController.saveChunk('Fund Claim', 'Test', 'Test', lstMDFClaim[0].Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = lstMDF[0].Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        
                 

        
        Test.startTest();
 File__c objFile = new File__c();
        objFile.Name = 'Test4';
        objFile.CP_Is_Cloned__c = false;
        objFile.Fund_Request__c = lstMDF[0].Id;
        objFile.Attachment_ID__c = oAttachment.Id;
        objFile.Proof_of_Performance_Document_Type__c = 'Agenda';

        insert objFile;
        
        MDFListViewCmpController.preAppFileList(lstMDF[0].Id);
       
        File__c objFile2 = new File__c();
        objFile2.Name = 'Test8';
        objFile2.CP_Is_Cloned__c = false;
        objFile2.Fund_Request__c = lstMDF[0].Id;
        objFile2.Attachment_ID__c = oAttachment.Id;
        objFile2.Claim__c = true;
        objFile2.Proof_of_Performance_Document_Type__c = Agenda1;

        insert objFile2;
       
     MDFListViewCmpController.saveEditChunk(objFile2, '0060g0000111MB0AAM', 'Test5',EncodingUtil.urlDecode('Testing5', 'UTF-8'), 'txt', 'Fund Request', Agenda);
      // MDFListViewCmpController.updateFileProcess(objFile2, 'testing',EncodingUtil.urlDecode('Testing8', 'UTF-8'), 'txt', 'Request', Agenda );

       
        MDFListViewCmpController.updatePreAppFileList(new List<File__c> {objFile2}, lstMDFClaim[0].Id);
        MDFListViewCmpController.getRefreshedFiles(null, lstMDFClaim[0].Id);
        MDFListViewCmpController.getRefreshedFiles(lstMDF[0].Id, null);
        MDFListViewCmpController.getRefreshedFiles(lstMDF[0].Id, lstMDFClaim[0].Id);
        Test.stopTest();
    }*/
    
   public static testmethod void testMDFDetails8() 
   { string Agenda;
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
       Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = lstMDF[0].Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
       
         File__c objFile = new File__c();
        objFile.Name = 'Test';
        objFile.CP_Is_Cloned__c = false;
        objFile.Fund_Request__c = lstMDF[0].Id;
        objFile.Attachment_ID__c = oAttachment.Id;
       objFile.Proof_of_Performance_Document_Type__c = 'Request';
       objFile.Pre_Approval_Document_Type__c = 'Agenda';
       
        insert objFile;
Test.startTest();
 MDFListViewCmpController.updateFileProcess(objFile, 'testing',EncodingUtil.urlDecode('Testing8', 'UTF-8'), 'txt', 'Request', Agenda );
 Test.stopTest();
   }


}