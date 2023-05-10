public with sharing class MDFEditExt
{
    public SFDC_MDF_Claim__c mdfClaim {get;set;}
    public MDF_Expense_Detail__c expenseDetailList {get;set;}
    public SFDC_MDF__c mdfRequest {get;set;}
    public List<MDF_Expense_Detail__c> mdfExepeseList {get;set;}
    public List<MDF_Expense_Detail__c> medfExpenseDelList{get;set;}
    private User logedinUser ;
    
         
    public MDFEditExt(ApexPages.standardController sc)
    {
        
        medfExpenseDelList = new List<MDF_Expense_Detail__c>();
        
        String mdfRequestId = ApexPages.currentPage().getParameters().get('Id');
        List<SFDC_MDF__c> mdfRequestList = new List<SFDC_MDF__c>();
        
        
        
        //If MDF Request Id is availabe in url take user to edit the record else to allow him to create a new page.
        if(! String.isBlank(mdfRequestId))
        {
            mdfRequestList = [SELECT Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, 
                              Activity_Type__c, End_Date__c, Requester_Name__c, Other_Vendors_Represented__c, Activity_Description__c,
                              Total_Estimated_Cost__c,Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c,
                              Number_of_Copies__c, Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c, 
                              Number_of_Calls__c, Number_of_Leads__c, Number_of_Attendees__c, Number_of_Unique_Views__c,
                              Number_of_Emails_Sent__c, Number_of_Contacts__c, Estimated_Revenue__c,
                              Annual_Sales_Quota__c, Estimated_Open_Emails__c,Is_Record_Locked__c,
                              Estimated_Cost_per_Copy__c, Estimated_Cost_per_Recipient__c, Estimated_Cost_per_Visitor__c, Estimated_Cost_per_Sale__c,
                              Estimated_Close_Rate__c, Estimated_Cost_per_Lead__c, Estimated_Response_Rate__c, Estimated_Cost_per_Attendees__c,
                              Estimated_Cost_per_View__c, Estimated_Email_Open_Rate__c, Estimated_Bounce_Back_Success_Rate__c, Estimated_ROI__c,
                              Estimated_Cost_to_Revenue__c, Estimated_Sales_Incentive_Rate__c, Approved_Date__c, Estimated_Number_of_Responses__c
                              FROM SFDC_MDF__c WHERE Id =: mdfRequestId LIMIT 1] ;
        }
        
        if(mdfRequestList.size() > 0)
        {
            mdfRequest = mdfRequestList[0];
        }
        else
        {
            mdfRequest = new SFDC_MDF__c ();
        }
        
        // Find MDF expense details
        if(mdfRequest != null && mdfRequest.id != null){
            
            mdfExepeseList = [SELECT Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c FROM MDF_Expense_Detail__c WHERE MDF_Request__c =: mdfRequest.id];
            
            //Find Claims for the request
            List<SFDC_MDF_Claim__c> mdfClaimList =[SELECT Id, Name,Status__c, Actual_Number_of_Copies__c, Actual_Circulation__c, Actual_Number_of_Unique_Site_Visitors__c,
                                                   Actual_Number_of_Sales__c, Actual_Number_of_Calls__c, Numbers_of_Leads__c, Actual_Number_of_Attendees__c, 
                                                   Actual_Number_of_Unique_Views__c, Actual_Number_of_Emails_Sent__c, Actual_Number_of_Contacts__c, Actual_Revenue__c,
                                                   Actual_Annual_Sales_Quota__c, Actual_Open_Emails__c, Actual_Number_of_Responses__c, Number_of_CTA_Click_through__c,
                                                   Actual_Sales__c, Actual_Cost_per_Copy__c, Actual_Cost_per_Recipient__c, Actual_Cost_per_Visitor__c, Actual_Cost_per_Sale__c,
                                                   Actual_Close_Rate__c, Actual_Cost_per_Lead__c, Actual_Response_Rate__c, Actual_Cost_per_Attendees__c,
                                                   Actual_Cost_per_View__c, Actual_Email_Open_Rate__c, Actual_Bounce_Back_Success_Rate__c, Actual_ROI__c,
                                                   Actual_Cost_to_Revenue__c, Actual_Sales_Incentive_Rate__c, Actual_Call_to_Action_Conversion_Rate__c,
                                                   Actual_Visitor_to_lead_Conversion_Rate__c, Actual_Percentage_of_Quota_Attained__c, Claim_Submission_Date__c, Approved_Date__c
                                                   FROM SFDC_MDF_Claim__c WHERE Fund_Request__c =: mdfRequest.Id
                                                  ];
    
            if (mdfClaimList.size() > 0) {
              mdfClaim = mdfClaimList[0];
            }
        }
        else
        {
            mdfExepeseList = new List<MDF_Expense_Detail__c>();
            mdfExepeseList.add(new MDF_Expense_Detail__c());
        }

        
    }
    
    //If user cancel the editing redirect him/her to detail page
    public PageReference cancel(){
        
        PageReference pr = Page.mdfRequestView;
        pr.getParameters().put('id',mdfRequest.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    // Add a new expense item in to list but to save item in to database user need to click on save buttion.
    public void addExpenseDetail()
    {
        mdfExepeseList.add(new MDF_Expense_Detail__c());
    }
    
    //Delete expense item from list
    Integer rowIndex;
    public void deleteExpenseDetail()
    {
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        MDF_Expense_Detail__c del = mdfExepeseList.remove(rowIndex);
        
        if(del.Id != null)
        {
            medfExpenseDelList.add(del);
        }
        
        try{
            if(medfExpenseDelList.size() > 0){
                delete medfExpenseDelList;
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Error,'Expense Detail can not be delete'));
            
        }
    }
    
    
    //Upsert Expense Detail
    public void saveExpenseDetail()
    {
        upsert mdfExepeseList ;
    }
    

    //Loged in user information
    public User getLogedInUser(){
        if(logedInUser == null){
            
            logedInUser  = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
            return logedInUser;
        }else{
        
            return logedInUser;
        }
    }
    
    public PageReference saveMdfRequest()
    {
        Savepoint sp ;
        User u = getLogedInUser();
        
        try{
            
            // Create a savepoint while appear error saving expense detail 
            sp = Database.setSavepoint();

            upsert mdfRequest;
            
        }catch(Exception ex){
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null ;

        }
        
        try{
            
            for(MDF_Expense_Detail__c mdfExpenseDetail: mdfExepeseList){
                
                mdfExpenseDetail.MDF_Request__c = mdfRequest.Id ;
            }
            upsert mdfExepeseList ;
            
        }catch(Exception ex){
        
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }
        
        // Update Claim if claim is created for the MDF Request
        try {
          if (mdfClaim != null) {
            update mdfClaim;
          }
        } catch (Exception ex) {
            
          Database.rollback(sp);
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
          return null;
        }
        
        PageReference pageRef = new PageReference('/apex/mdfRequestView?id='+mdfRequest.Id);
        
        return pageRef;

        
    }
    
    
}