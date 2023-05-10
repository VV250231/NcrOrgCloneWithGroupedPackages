public class CreateMDFClaimCmpController 
{
	@AuraEnabled
	public SFDC_MDF__c objMDFRequest;
	
	@AuraEnabled
  	public SFDC_MDF_Claim__c objMDFClaim;
  	
  	@AuraEnabled
  	public List<MDF_Expense_Detail__c> lstExpense ;
  	
  	@AuraEnabled
  	public String activityContact;
  	
  	
  	@AuraEnabled
    public static CreateMDFClaimCmpController getClaimDetails(String requestId) 
    {
    	CreateMDFClaimCmpController objController = new CreateMDFClaimCmpController(); 
    	objController.objMDFClaim = new SFDC_MDF_Claim__c();
    	objController.activityContact = UserInfo.getName();
   		objController.lstExpense = new List<MDF_Expense_Detail__c>();
   		
      	for(SFDC_MDF__c obFD : [SELECT Id, Name,Status__c,CAM__c, Activity_Date__c, Activity_Type__c, End_Date__c, Requester_Name__c, Other_Vendors_Represented__c, 
							              Activity_Description__c, Total_Estimated_Cost__c,Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c,
							              Number_of_Copies__c, Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c, Number_of_Calls__c, Number_of_Leads__c, 
							              Number_of_Attendees__c, Number_of_Unique_Views__c, Number_of_Emails_Sent__c, Number_of_Contacts__c, Estimated_Revenue__c,Estimated_Number_of_Responses__c,
							              Annual_Sales_Quota__c, Estimated_Open_Emails__c , Requester_Name__r.Name,CAM__r.Name,Estimated_New_Leads__c,Estimated_Opportunity__c,Estimated_Existing_Leads__c,Estimated_Interactions__c,Business_Plan__c
          						FROM SFDC_MDF__c WHERE Id =: requestId LIMIT 1])
    	{
    		objController.objMDFRequest = obFD; 
    	}
      	objController.lstExpense.addAll([ SELECT Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c, Fund_Claim__c 
          				 									FROM MDF_Expense_Detail__c  WHERE MDF_Request__c =: requestId]);
          				 									
    	return objController;
    }
    
    @AuraEnabled
    public static String createMDFClaim(SFDC_MDF__c mdfRequest, SFDC_MDF_Claim__c mdfClaim, List<MDF_Expense_Detail__c> lstExpense)
    {
    	mdfClaim.Name = mdfRequest.Name + ' - Claim' ;
	    mdfClaim.Fund_Request__c = mdfRequest.Id;
	    Database.SaveResult insertResult;
	    /* Resolution for the Issue : cannot specify Id in an insert call */
	    if (mdfClaim.Id != null)
	        mdfClaim.Id = null;
	    
	   	insert mdfClaim;
	   System.debug('-------------mdfClaim.id------------------'+mdfClaim.id);
        List<MDF_Expense_Detail__c> lstMDFExp = new List<MDF_Expense_Detail__c>();
	   	for (MDF_Expense_Detail__c mdfExpenseDetail: lstExpense) { 
    		mdfExpenseDetail.Fund_Claim__c = mdfClaim.Id;
    		lstMDFExp.add(mdfExpenseDetail);
      	}
        update lstMDFExp;
      	return mdfRequest.Id;
   }
}