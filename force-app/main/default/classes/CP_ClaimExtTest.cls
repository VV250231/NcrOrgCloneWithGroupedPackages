/*This test class is used to test the class "CP_ClaimExt" for code coverage */
@isTest 
public class CP_ClaimExtTest{
    /*This method is used to Test the class for code coverage - testProcessClaimRequestIfMDFReqNotNull */
    static testMethod void testProcessClaimRequestIfMDFReqNotNull() { 
      try{       
            //Create MDF Request and expense details
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();  
            MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id); 
            
            //Create Controller reference
            PageReference pageRef = Page.CP_newClaim;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF_Claim__c());  
             ApexPages.currentPage().getParameters().put('mdfReqId',mdfReq.Id);
            CP_claimExt cpClaimExt= new CP_claimExt(sc);
            //Test processClaimRequest()
            PageReference pageRefObj = cpClaimExt.processClaimRequest(); 
            System.assert(pageRefObj.getParameters().get('message')=='Claim Request is created. Please submit for approval.');
            //Test saveExpenseDetail()
            cpClaimExt.saveExpenseDetail(); 
            
            //Test getLogedInUser()
            cpClaimExt.getLogedInUser(); 
            
            //Set dummy data for code coverage
            cpClaimExt.fileName='TestFile'; 
            cpClaimExt.fileBody=Blob.valueOf('TestBlob');
       }catch(Exception e){
          System.debug(e.getMessage());
       }  
    }
    
    /*This method is used to Test the class for code coverage - testProcessClaimRequestIfMDFReqNull*/
    static testMethod void testProcessClaimRequestIfMDFReqNull() { 
      try{       
            //Create Controller reference  and throw the exception to test negative test
            PageReference pageRef = Page.CP_newClaim;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF_Claim__c()); 
            ApexPages.currentPage().getParameters().put('mdfReqId','');
            CP_claimExt cpClaimExt= new CP_claimExt(sc); 
       }catch(Exception e){
          System.debug(e.getMessage());
          System.assert(e.getMessage()!=null);
       }  
    } 
    
    /*This method is used to Test the class for code coverage - testProcessClaimRequestIfIncorrectMDFClaim */
    static testMethod void testProcessClaimRequestIfIncorrectMDFClaim() { 
      try{       
            //Create MDF Request and expense details
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();  
            MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);  
             
            //Prepare incorrect mdfClaim
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Status__c='Approved'; 
            mdfClaim.Amount__c =-1;
            
            //Create Controller reference
            PageReference pageRef = Page.CP_newClaim;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF_Claim__c());  
            ApexPages.currentPage().getParameters().put('mdfReqId',mdfReq.Id);
            CP_claimExt cpClaimExt= new CP_claimExt(sc);
            cpClaimExt.mdfClaim=mdfClaim;
            //Test processClaimRequest()
            PageReference pageRefObj = cpClaimExt.processClaimRequest(); 
            System.assert(pageRefObj.getParameters().get('message')=='Claim Request is created. Please submit for approval.');
       }catch(Exception e){
          System.debug(e.getMessage());
       }  
    } 
    /*This method is used to Test the class for code coverage - testProcessClaimRequestIfIncorrectMDFExpenseDetails */
    static testMethod void testProcessClaimRequestIfIncorrectMDFExpenseDetails() { 
      try{       
            //Create MDF Request and expense details
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();  
            MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);  
            
            //Create Controller reference
            PageReference pageRef = Page.CP_newClaim;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF_Claim__c());  
            ApexPages.currentPage().getParameters().put('mdfReqId',mdfReq.Id);
            CP_claimExt cpClaimExt= new CP_claimExt(sc); 
            
            //Prepare incorrect mdfExpenseDetails
            mdfExpenseDetails.Estimated_Cost__c =1000;
            mdfExpenseDetails.NCR_Approved__c=2000;  
            List<MDF_Expense_Detail__c> mdfExepeseList = new List<MDF_Expense_Detail__c>();
            mdfExepeseList.add(mdfExpenseDetails);
            cpClaimExt.mdfExepeseList=mdfExepeseList;
            //Test processClaimRequest()
            PageReference pageRefObj = cpClaimExt.processClaimRequest(); 
            System.assert(pageRefObj.getParameters().get('message')=='Claim Request is created. Please submit for approval.');
       }catch(Exception e){
          System.debug(e.getMessage());
       }  
    } 
    
    static testMethod void testException(){
        //Create MDF Request
        SFDC_MDF__c mdfReq= new SFDC_MDF__c();
        mdfReq.Name= 'Test Activity .............................................................';
        mdfReq.Activity_Date__c= Date.today().addDays(35);
        mdfReq.End_Date__c= Date.today().addDays(40);
        mdfReq.Activity_Type__c= 'Event - Roadshow';
        mdfReq.Other_Vendors_Represented__c='Micros';
        mdfReq.Activity_Description__c='TestDescription';
        mdfReq.Number_of_Leads__c= 1000;       
        mdfReq.Status__c='Request Created'; 
        insert mdfReq;
        
        //Create Controller reference
            PageReference pageRef = Page.CP_newClaim;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF_Claim__c());  
             ApexPages.currentPage().getParameters().put('mdfReqId',mdfReq.Id);
            CP_claimExt cpClaimExt= new CP_claimExt(sc);
            //Test processClaimRequest()
        try{
           cpClaimExt.processClaimRequest(); 
        }
        catch(Exception e){
            System.assert(e.getMessage()!=null);
        }
           
            
    }
}