/*This test class is used to test the class "MDFViewExt" for code coverage */
@isTest 
public class MDFViewExtTest{
/*This method is used to Test the class for code coverage - testMDFViewExtMethodsCorrectMDFRequest */
    static testMethod void testMDFViewExtMethodsCorrectMDFRequest() {   
         try{
             //Create MDF Request and expense details
             SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
             system.assert(mdfExpenseDetails!=null);
             
             //Create MDF Claim record
             SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
             
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.currentPage().getParameters().put('ID', mdfReq.Id);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             
             //Test Get MdfRequest
             ApexPages.currentPage().getParameters().put('Id',mdfReq.id);
             mdfViewExt.getMdfRequest(); 
             mdfViewExt.showActivityResultsPopup();
             mdfViewExt.closeActivityResultsPopup();
             mdfViewExt.saveActivityResult();
             //Test Get MDFClaim
             mdfViewExt.getMdfClaim(); 
             
             //Test Other methods
             mdfViewExt.addExpenseDetail();
             mdfViewExt.saveExpenseDetail();
             mdfViewExt.redirectToEditPage();
             mdfViewExt.redirectToClaimPage();
             mdfViewExt.getItems();
             mdfViewExt.getSubActivity();
             mdfViewExt.setSubActivity('Test');
             mdfViewExt.getLogedInUser(); 
             mdfViewExt.saveMdfRequest();
             mdfViewExt.redirectToClone();
             mdfViewExt.redirectToMDFListPage();
             
             //Create attachment for MDF Request
            Attachment attachment = new Attachment();
            attachment.body       = Blob.valueOf('Test');
            attachment.name       = 'TestFile';
            attachment.parentId   = mdfReq.Id; 
            insert attachment;  
                               
            //Create File for MDF Request
            File__c file = new File__c();
            file.Name = 'TestFile';
            file.put('Fund_Request__c',mdfReq.id); 
            file.put('Attachment_ID__c',attachment.Id); 
            insert file;
                          
            //Create attachment for MDF Request
            Attachment attachment1 = new Attachment();
            attachment1.body       = Blob.valueOf('Test');
            attachment1.name       = 'TestFile';
            attachment1.parentId   = mdfCliam.Id; 
            insert attachment1;  
                        
            //Create File for MDF Request
            File__c file1 = new File__c();
            file1.Name = 'TestFile';
            file1.put('Fund_Claim__c',mdfCliam.id); 
            file1.put('Attachment_ID__c',attachment1.Id); 
            insert file1; 
            List<FileListUtil.AttachmentWrapper> a=  mdfViewExt.files;             
             
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    } 
    /*This method is used to Test the class for code coverage - testMDFViewExtSaveMdfRequestWithAccount */
    static testMethod void testMDFViewExtSaveMdfRequestWithAccount() {   
         try{
            //Create account users 
            /*User userWithConAndAcc= PrepareMDFTestDataUtil.userWithContactAndAccount('22'); 
            if(userWithConAndAcc!=null) { 
                User u = [SELECT Id,ManagerId,accountId, Contact.Account.OwnerId FROM User WHERE id =:userWithConAndAcc.id Limit 1]; 
                System.runAs(u) { */
                         //Create MDF Request and expense details
                         SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             
                         MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
                         system.assert(mdfExpenseDetails!=null);
                         //Create MDF Claim record
                         SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id); 
                         
                         //Set page and Create MDFViewExt class object
                         PageReference pageRef = Page.mdfRequestView;
                         Test.setCurrentPage(pageRef);
                         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
                         ApexPages.currentPage().getParameters().put('message','TestMessage');
                         ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
                         MDFViewExt mdfViewExt= new MDFViewExt(sc);
                         
                         //Test saveMdfRequest
                         ApexPages.currentPage().getParameters().put('Id',mdfReq.id); 
                         mdfViewExt.saveMdfRequest();  
                         
                    /*}
             }*/
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    } 
    /*This method is used to Test the class for code coverage - "Negative test for incorrect Id OF getMdfRequest(),mdfExepeseList" */
    static testMethod void testForIncorrectIDOfMDFRequest() {  
         try{
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             
             
             //Test getMdfRequest()
             ApexPages.currentPage().getParameters().put('Id','tst12345');
             
             SFDC_MDF__c mdf= mdfViewExt.getMdfRequest();
             system.assert(mdf.id!=null);
             //mdfViewExt.getmdfExepeseList();
             
             //Test submitMdfClaim()
             mdfViewExt.submitMdfClaim();
             mdfViewExt.submitMdfClaim();
             
        }catch(Exception e){
           
            System.debug(e.getMessage());
        } 
    }   
    /*This method is used to Test the class for code coverage - "Negative test for Blank Id of getMdfRequest()" */
    static testMethod void testForBlankIdGetMdfRequest() {   
         try{
             //Create MDF Request and expense details
             SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
              system.assert(mdfExpenseDetails!=null);
             //Create MDF Claim record
             SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
             
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             
             //Test getMdfRequest()
             ApexPages.currentPage().getParameters().put('Id',null);
             mdfViewExt.getMdfRequest();
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }   
    
    /*This method is used to Test the class for code coverage - "Negative test for MDFRequest" */
    static testMethod void testForNotNullOfMDFRequest() {   
         try{
             //Create MDF Request and expense details
             SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
             
             //Create MDF Claim record
             SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
          
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             mdfViewExt.setMdfRequest(mdfReq);  //Test setMdfRequest()
             //mdfViewExt.getMdfRequest();
             SFDC_MDF__c mdf= mdfViewExt.getMdfRequest();
             system.assert(mdf!=null);//Test getMdfRequest()
             mdfViewExt.submitMdfRequest();//Test submitMdfRequest()
             
             //Test "Set and get MDFClaim" and submitMdfClaim()
             mdfViewExt.setMdfClaim(mdfCliam);
             mdfViewExt.getMdfClaim();
             mdfViewExt.submitMdfClaim(); 
             //Test deleteExpenseDetail()
             ApexPages.currentPage().getParameters().put('rowIndex','1');
             mdfViewExt.deleteExpenseDetail();  
        }catch(Exception e){
            
            System.debug(e.getMessage());
        } 
    } 
    
     /*This method is used to Test the class for code coverage - "Negative test for DeleteMDFRequest" */
    static testMethod void testDeleteMDFRequest() {   
         try{
             //Create MDF Request and expense details
             SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
              system.assert(mdfExpenseDetails!=null);
             //Create MDF Claim record
             SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
          
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             mdfViewExt.setMdfRequest(mdfReq);  //Test setMdfRequest()
             
            //Test "Set  MDFClaim" 
             mdfViewExt.setMdfClaim(mdfCliam);  
             
             //Test deleteMDFRequest()
             mdfViewExt.deleteMDFRequest();   
             
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    } 
     
   /*This method is used to Test the class for code coverage - "testDeletePreApprovalDoc" */
    static testMethod void testDeletePreApprovalDoc() {   
         try{
             //Create MDF Request and expense details
             SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
             
             //Create MDF Claim record
             SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
          
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             mdfViewExt.setMdfRequest(mdfReq);  //Test setMdfRequest() 
             mdfViewExt.setMdfClaim(mdfCliam);  //Test "Set  MDFClaim"            
             
            
            //Create Attachment
            Attachment attachment = new Attachment();
            attachment.body       =  Blob.valueOf('Test');
            attachment.name       = 'TestFile';
            attachment.parentId   = mdfReq.Id;
            insert attachment; 
             
            //Create File 
            File__c file= new File__c();
            file.Name = 'TestFile' ;
            file.put('Fund_Request__c',mdfReq.Id); 
            file.put('Attachment_ID__c',attachment.Id);
            insert file; 
             system.assert(file.id!=null);
             
             //Test deletePreApprovalDoc()
             ApexPages.currentPage().getParameters().put('fileRecId',file.id);
             mdfViewExt.deletePreApprovalDoc();
             
             //Insert Stages and deletePreApprovalDoc
             insert new PreApprovalDocCRUDvalidater__c(SetupOwnerId=UserInfo.getOrganizationId(), Stages__c='Request Created;Level 2 Review');
             mdfViewExt.deletePreApprovalDoc();             
             
             
        }catch(Exception e){
            
            System.debug(e.getMessage());
            
        } 
    } 
  static testMethod void testMDFViewExtSaveMdfRequestWithAccount2() {   
        // try{
            //Create account users 
            //User userWithConAndAcc= PrepareMDFTestDataUtil.userWithContactAndAccount('22'); 
            //if(userWithConAndAcc!=null) { 
                User u = [SELECT Id,ManagerId,accountId, Contact.Account.OwnerId FROM User WHERE profile.name = 'IPT Partner Community Login User' AND isActive = true AND AccountId!=null Limit 1]; 
				system.assert(u.AccountId!=null);
                System.runAs(u) {
                         //Create MDF Request and expense details
                         SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
                         mdfReq.Account__c = null;
                    mdfReq.End_Date__c = System.today();
                    mdfReq.Status__c = 'Approved';
                    update mdfReq;
                
                         MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
                         
                         //Create MDF Claim record
                         SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id); 
                         
                         //Set page and Create MDFViewExt class object
                         PageReference pageRef = Page.mdfRequestView;
                         Test.setCurrentPage(pageRef);
                         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
                         ApexPages.currentPage().getParameters().put('message','TestMessage');
                         ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
                     ApexPages.currentPage().getParameters().put('Id',mdfReq.id);
                         MDFViewExt mdfViewExt= new MDFViewExt(sc);
                    	 system.assert(mdfViewExt!=null);
                         
                         //Test saveMdfRequest
                         
                         mdfViewExt.saveMdfRequest();
                   // mdfViewExt.submitMdfClaim();
             mdfViewExt.getMdfRequest(); 
             mdfViewExt.showActivityResultsPopup();
                    
                    
                         
                }
            // }
       // }
      /*catch(Exception e){
            System.debug(e.getMessage());
        } */
    } 
    static testMethod void testDeletePreApprovalDoc2() {   
         try{
             //Create MDF Request and expense details
             SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
             MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
             
             //Create MDF Claim record
             SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
          
             //Set page and Create MDFViewExt class object
             PageReference pageRef = Page.mdfRequestView;
             Test.setCurrentPage(pageRef);
             ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
             ApexPages.currentPage().getParameters().put('message','TestMessage');
             ApexPages.currentPage().getHeaders().put('Referer', 'CP_newClaim');
             MDFViewExt mdfViewExt= new MDFViewExt(sc);
             mdfViewExt.setMdfRequest(mdfReq);  //Test setMdfRequest() 
             mdfViewExt.setMdfClaim(mdfCliam);  //Test "Set  MDFClaim"            
             
            
            //Create Attachment
            Attachment attachment = new Attachment();
            attachment.body       =  Blob.valueOf('Test');
            attachment.name       = 'TestFile';
            attachment.parentId   = mdfReq.Id;
            insert attachment; 
             
            //Create File 
            File__c file= new File__c();
            file.Name = 'TestFile' ;
            file.put('Fund_Request__c',mdfReq.Id); 
            file.put('Attachment_ID__c',attachment.Id);
            insert file;  
             system.assert(file.id!=null);
             
             //Test deletePreApprovalDoc()
             ApexPages.currentPage().getParameters().put('fileRecId',file.id);
             mdfViewExt.deletePreApprovalDoc();
             
             //Insert Stages and deletePreApprovalDoc
            insert new PreApprovalDocCRUDvalidater__c(SetupOwnerId=UserInfo.getOrganizationId(), Stages__c='');
             mdfViewExt.deletePreApprovalDoc();             
             
             
        }catch(Exception e){
           
            System.debug(e.getMessage());
        } 
    } 
   
}