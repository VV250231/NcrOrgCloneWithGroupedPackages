/*This test class is used to test the class "MDFListControllerExt" for code coverage */
@isTest

public class MDFListControllerExtTest{
    /*This method is used to Test the class for code coverage - testMDFListControllerForCorrectData */
    static testMethod void testMDFListControllerForCorrectData() { 
      try{       
            //Create MDF Request, Claim and expense details
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
            SFDC_MDF_Claim__c claim = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
            MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id); 
            
            //Create Controller Reference   
            PageReference pageRef = Page.MDFList;           
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfReq);  
            
            //Create StandardSetController
            List<SFDC_MDF__c> mdfReqList = new List<SFDC_MDF__c>();
            mdfReqList.add(mdfReq);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(mdfReqList);
            
            
            MDFListControllerExt mdfListControllerExt= new MDFListControllerExt(ssc);
            //Test getMdfRequestPagination()
            //mdfListControllerExt.getMdfRequestPagination();
            List<MDFListControllerExt.MDFReqWrapper> lt = mdfListControllerExt.getMdfRequestPagination();//EBA_SF-1834
            system.assertNotEquals(lt, null);
            
            //Test redirectToNewMDFRequest()
            ApexPages.currentPage().getParameters().put('sfdc.tabName','test');
            mdfListControllerExt.redirectToNewMDFRequest();
            
            //Reset page and Create Controller Reference    
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(new SFDC_MDF__c()); 
            ApexPages.currentPage().getParameters().put('recordID',mdfReq.id);
            MDFListControllerExt mdfListControllerExt1= new MDFListControllerExt(sc1);
            //Test deleteMDFRequest()
            mdfListControllerExt1.deleteMDFRequest();           
            mdfListControllerExt.doNext();
            mdfListControllerExt.doPrevious();
            mdfListControllerExt.setSortDirection('Name');
            mdfListControllerExt.getSortDirection();
       }catch(Exception e){
          System.debug(e.getMessage());
       }  
    } 
    /*This method is used to Test the class for code coverage - testDeleteNewMDFRequest */
    static testMethod void testDeleteNewMDFRequest() { 
      try{       
            //Create MDF Request
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity';
            mdfReq.Activity_Date__c= Date.today();
            mdfReq.End_Date__c= Date.today().addDays(1);
            mdfReq.Activity_Type__c= 'Event - Roadshow';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;       
            mdfReq.Status__c='Request Created'; //Newly created MDF Request
            insert mdfReq; 
            
            //Create Controller Reference    
            Test.setCurrentPage(Page.MDFList);
            ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(new SFDC_MDF__c()); 
            ApexPages.currentPage().getParameters().put('recordID',mdfReq.id);
            MDFListControllerExt mdfListControllerExt= new MDFListControllerExt(sc1);
            
            //Test deleteMDFRequest()
            //mdfListControllerExt.deleteMDFRequest();  
            PageReference p = mdfListControllerExt.deleteMDFRequest();  
            system.assertNotEquals(p, null);           
            
       }catch(Exception e){
          System.debug(e.getMessage());
       }  
    }
     /*This method is used to Test the class for code coverage - testDeleteApprovedMDFRequest */
    static testMethod void testDeleteApprovedMDFRequest() { 
      try{       
            //Create MDF Request
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity';
            mdfReq.Activity_Date__c= Date.today();
            mdfReq.End_Date__c= Date.today().addDays(1);
            mdfReq.Activity_Type__c= 'Event - Roadshow';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;       
            mdfReq.Status__c='Approved'; //Approved MDF Request
            insert mdfReq; 
            
            //Create Controller Reference
            PageReference pageRef = Page.MDFList;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(new SFDC_MDF__c()); 
            ApexPages.currentPage().getParameters().put('recordID',mdfReq.id);
            MDFListControllerExt mdfListControllerExt= new MDFListControllerExt(sc1);
            //Test deleteMDFRequest()
            //mdfListControllerExt.deleteMDFRequest();
            mdfListControllerExt.deleteMDFRequest();   
            PageReference p = mdfListControllerExt.deleteMDFRequest();   //EBA_SF-1834
            system.assertEquals(p, null, 'As Fund Request status is approved so it will return null');
            
       }catch(Exception e){
          System.debug(e.getMessage());
       }  
    } 
    
    /*This method is used to Test the class for code coverage -testRedirectToNewMDFRequest*/
    static testMethod void testRedirectToNewMDFRequest() {
            //Create Controller Reference
            PageReference pageRef = Page.MDFList;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(new SFDC_MDF__c());  
            MDFListControllerExt mdfListControllerExt= new MDFListControllerExt(sc1); 
            ApexPages.currentPage().getParameters().put('sfdc.tabName','test');
            //Test redirectToNewMDFRequest()
            //mdfListControllerExt.redirectToNewMDFRequest();
            PageReference p = mdfListControllerExt.redirectToNewMDFRequest();
            system.assertNotEquals(p.getParameters(), null);
    } 
    static testMethod void testMDFListControllerForCorrectData1() { 
     try{       
            //Create MDF Request, Claim and expense details
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
            SFDC_MDF_Claim__c claim = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
            MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id); 
            
            //Create Controller Reference   
            PageReference pageRef = Page.MDFList;           
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfReq);  
            
            //Create StandardSetController
            List<SFDC_MDF__c> mdfReqList = new List<SFDC_MDF__c>();
          for(integer i=0; i<25; i++)
          {
              SFDC_MDF__c mdfReq1=PrepareMDFTestDataUtil.prepareMDFRecord();
              mdfReqList.add(mdfReq1);
          }
            
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(mdfReqList);
            
            
            MDFListControllerExt mdfListControllerExt= new MDFListControllerExt(ssc);
            //Test getMdfRequestPagination()
            mdfListControllerExt.getMdfRequestPagination();
            
            //Test redirectToNewMDFRequest()
            ApexPages.currentPage().getParameters().put('sfdc.tabName','test');
            mdfListControllerExt.redirectToNewMDFRequest();
            
            //Reset page and Create Controller Reference    
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(new SFDC_MDF__c()); 
            ApexPages.currentPage().getParameters().put('recordID',mdfReq.id);
            MDFListControllerExt mdfListControllerExt1= new MDFListControllerExt(sc1);
            //Test deleteMDFRequest()
            //mdfListControllerExt1.deleteMDFRequest(); 
            PageReference p =   mdfListControllerExt1.deleteMDFRequest(); 
            system.assertNotEquals(p, null);           
           mdfListControllerExt.doNext();
            mdfListControllerExt.doPrevious();
            mdfListControllerExt.setSortDirection('Name');
           mdfListControllerExt.getSortDirection();
       }catch(Exception e)
       {
          System.debug(e.getMessage());
       }  
    } 
}