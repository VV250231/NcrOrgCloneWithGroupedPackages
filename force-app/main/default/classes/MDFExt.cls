public with sharing class MDFExt {
    
  public SFDC_MDF__c mdfRequest {get;set;}
  public List<MDF_Expense_Detail__c> mdfExepeseList {get;set;}
  private User logedinUser;
  private String cancelRetUrl;
  private String existingMdfreqName;
            
  public MDFExt(ApexPages.standardController sc) {
                       
    cancelRetUrl = ApexPages.currentPage().getParameters().get('retURL');

    // If MDF Request Id is availabe in url and record is exist in the database, redirect user to clone the MDF Request.
     
    String mdfRequestId = ApexPages.currentPage().getParameters().get('Id');
        
    List<SFDC_MDF__c> mdfRequestList = [SELECT Id, Name,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c, Requester_Name__c, 
                                         Other_Vendors_Represented__c, Activity_Description__c, Total_Estimated_Cost__c,
                                         Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c, 
                                         Number_of_Copies__c, Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c,
                                         Number_of_Calls__c, Number_of_Leads__c, Number_of_Attendees__c, Number_of_Unique_Views__c,
                                         Number_of_Emails_Sent__c, Number_of_Contacts__c, Estimated_Revenue__c,
                                         Annual_Sales_Quota__c, Estimated_Open_Emails__c
                                         FROM SFDC_MDF__c WHERE Id =: mdfRequestId LIMIT 1
                                        ];
        
    if(mdfRequestList.size() > 0) {
                
      existingMdfreqName = mdfRequestList[0].Name ;
                
      mdfExepeseList = [SELECT Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c 
                        FROM MDF_Expense_Detail__c WHERE MDF_Request__c =: mdfRequestList[0].id
                       ];
                
      // clone MDF Request
      mdfRequest = mdfRequestList[0].clone(false,true);
      mdfRequest.Status__c = 'None';
      mdfRequest.name = '';
                
      // clone expense table
      if (mdfExepeseList.size() > 0) {
  
        List<MDF_Expense_Detail__c> tempList = new List<MDF_Expense_Detail__c>();
        for (MDF_Expense_Detail__c detail : mdfExepeseList) {
          tempList.add(detail.clone(false,true));
        }
  
        mdfExepeseList.clear();
        mdfExepeseList.addAll(tempList);
        tempList = null;
  
      } else {
          // If there is no expense record add a new record.
          mdfExepeseList = new List<MDF_Expense_Detail__c>();
          mdfExepeseList.add(new MDF_Expense_Detail__c());
      }
    
    
    } else {
        // If there is no MDF request found in Data Base create new MDF request.
        mdfRequest = new SFDC_MDF__c ();
        mdfRequest.Requester_Name__c = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        mdfExepeseList = new List<MDF_Expense_Detail__c>();
        mdfExepeseList.add(new MDF_Expense_Detail__c());
    }
                
        
  }
    
    
  // Add a new expense item in to list but to save item in to database user need to click on save button.
  public void addExpenseDetail() {
    
    mdfExepeseList.add(new MDF_Expense_Detail__c());
  }
    
  //Delete expense item from list
  Integer rowIndex;
  public void deleteExpenseDetail() {
    rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
    MDF_Expense_Detail__c del = mdfExepeseList.remove(rowIndex);
  }
    
    
  //Upsert Expense Detail
  public void saveExpenseDetail() {
    upsert mdfExepeseList ;
  }
    

  //get current logen in user information  
  public User getLogedInUser() {
    if (logedInUser == null) {       
      logedInUser  = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
      return logedInUser;
    } else {   
        return logedInUser;
    }
  }
    
  public PageReference saveMdfRequest() {
    String saveResult = saveRequest();
    if (String.isBlank(saveResult)) {
      return null;
    }       
    PageReference pageRef = new PageReference('/apex/mdfRequestView?id='+mdfRequest.Id);      
    return pageRef;
  }
    
  public PageReference saveMdfRequestUploadDoc() {
    String saveResult = saveRequest();
    if (String.isBlank(saveResult)) {
      return null;
    }
    PageReference pageRef = Page.ncr_pre_approval_doc;
    pageRef.getParameters().put('pid',mdfRequest.Id);
    pageRef.getParameters().put('fieldAPI','Fund_Request__c');
    return pageRef;
  }
    
  public String saveRequest() {
    String saveResultStr = null;
    Savepoint sp ;
    User u = getLogedInUser();
        
    try {
      // Create a savepoint
      sp = Database.setSavepoint();
      
      // Save MDF request
      if (u.accountId != null ) {
        if (! (mdfRequest.Account__c != null)) {
          mdfRequest.Account__c = u.AccountId ;
        }
      } else {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'You can not make MDF Request because you are not associated with any account' ));
          return saveResultStr;
      }
      
      if (existingMdfreqName == mdfRequest.Name) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'This activity name already exist.' ));
        return saveResultStr;
      }
      
      upsert mdfRequest;
            
    } catch(Exception ex) {
        String errorMessage = ex.getMessage();
        Integer occurence;
        if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
            errorMessage = errorMessage.mid(occurence, errorMessage.length());
            occurence = errorMessage.lastIndexOf(':');
            errorMessage = errorMessage.mid(0, occurence);
        }
        else {
            errorMessage = ex.getMessage();
        }
    
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        return null;
    }
        
    
    // Save MDF expenses associated with MDF Request
    //try {
      for (MDF_Expense_Detail__c mdfExpenseDetail: mdfExepeseList) {
        mdfExpenseDetail.MDF_Request__c = mdfRequest.Id ;
      }
      upsert mdfExepeseList ;
    //} catch(Exception ex) {
        // If any error occur while saving the Expens Detail roll back everything
        //Database.rollback(sp);
        // don't delete below line.
        //mdfRequest.Id = null;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        //return saveResultStr;
    //}
    
    saveResultStr = 'success';
    
    return saveResultStr;
  }
  
  //Cancel MDF Request creation  
  public pageReference cancelRequest() {
    
    PageReference pageRef = new PageReference(cancelRetUrl) ;
    pageRef.setRedirect(true);
    return pageRef;
  }
  
}