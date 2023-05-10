public with sharing class CP_ClaimExt {
    
  public SFDC_MDF_Claim__c mdfClaim {get;set;}
  public SFDC_MDF__c mdfRequest {get;set;}
  public List<MDF_Expense_Detail__c> mdfExepeseList {get;set;}
  private User logedinUser ;
  public String fileName {get;set;}
  public Blob fileBody {get;set;}
  public File__c file {get;set;}
  public Boolean error {get;set;}
    
  public CP_claimExt(ApexPages.standardController sc) {
    
    error               = false;
    mdfClaim            = new SFDC_MDF_Claim__c();
    file                = new File__c();   
    String mdfRequestId = ApexPages.currentPage().getParameters().get('mdfReqId');
  
    // Find MDF Request record.
    List<SFDC_MDF__c> mdfRequestList;

    if (! String.isBlank(mdfRequestId)) {
      mdfRequestList = [
          SELECT 
              Id, Name,Status__c,CAM__c, Activity_Date__c, Activity_Type__c, End_Date__c, Requester_Name__c, Other_Vendors_Represented__c, 
              Activity_Description__c, Total_Estimated_Cost__c,Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c,
              Number_of_Copies__c, Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c, Number_of_Calls__c, Number_of_Leads__c, 
              Number_of_Attendees__c, Number_of_Unique_Views__c, Number_of_Emails_Sent__c, Number_of_Contacts__c, Estimated_Revenue__c,
              Annual_Sales_Quota__c, Estimated_Open_Emails__c 
          FROM SFDC_MDF__c 
          WHERE Id =: mdfRequestId LIMIT 1
      ] ;
    }

    if (mdfRequestList.size() > 0) {
      mdfRequest = mdfRequestList[0];
    } else {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'MDF Request not found'));
      error = true;
      return ;
    }

    // Find MDF Expense List associated with MDF Request
    if (mdfRequest != null && mdfRequest.id != null) {    
      mdfExepeseList = [ 
          SELECT 
              Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c, 
              Fund_Claim__c 
          FROM MDF_Expense_Detail__c 
          WHERE MDF_Request__c =: mdfRequest.id
      ];
    }
    
  }
        
  /*
   * Save Actul values for MDF Activitis
   */
  public void saveExpenseDetail() {
    upsert mdfExepeseList ;
  }
        
  
  //Find Logen In user detail
  public User getLogedInUser(){
    if (logedInUser == null){
        
        logedInUser  = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
        return logedInUser;
    } else {   
      return logedInUser;
    }
  }
    
  /*
   * Create a claim Record and Redirect user to MDF Request view.
   * 
   */
  public PageReference processClaimRequest() {
    System.Savepoint sp = Database.setSavepoint();
    try {
      //insert claim record
      Database.SaveResult claimInsertResult = insertClaimRecord(mdfRequest);
        
      if (claimInsertResult == null || !claimInsertResult.isSuccess()) {
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Claim Can not be created.'));
        Database.rollback(sp); 
        return null;
      }
      
      // Update Claim Id in all MDF Expnese Records associated with MDF request.
      Id claimId = claimInsertResult.getId();
      for (MDF_Expense_Detail__c mdfExpenseDetail: mdfExepeseList) { 
        //if(mdfExpenseDetail.NCR_Approved__c==null ||mdfExpenseDetail.NCR_Approved__c<=0){
            //mdfExpenseDetail.NCR_Approved__c=mdfExpenseDetail.Actual_Cost__c;    
        //}           
        mdfExpenseDetail.Fund_Claim__c = claimId;
      }
    
      upsert mdfExepeseList ;
        
    } catch (Exception ex) { 
      Database.rollback(sp);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Claim Can not be created.'+ ex.getMessage()));
      return null;
    }
    
    PageReference pageRef = Page.mdfRequestView;
    pageRef.getParameters().put('id', mdfRequest.Id);
    pageRef.getParameters().put('message', 'Claim Request is created. Please submit for approval.');  
    return pageRef;
 
  }
    
  public DataBase.SaveResult insertClaimRecord(SFDC_MDF__c mdfRequest) {
    
    mdfClaim.Name = mdfRequest.Name + ' - Claim' ;
    mdfClaim.Fund_Request__c = mdfRequest.Id;
    Database.SaveResult insertResult;
    /* Resolution for the Issue : cannot specify Id in an insert call */
    if (mdfClaim.Id != null)
        mdfClaim.Id = null;
    
    try {
      insertResult = DataBase.insert(mdfClaim);
    } Catch(Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
      return null;
    }
    
    return insertResult ;
  }
     
}