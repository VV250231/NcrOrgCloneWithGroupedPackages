/*
*********************************************************
Apex Class Name    : MDFViewExt
Test Class Name    : MDFViewExtTest
Created Date       :  1/22/2016 7:45 AM
@author            : Dev Admin
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
                                                   
*********************************************************
*/public with sharing class MDFViewExt {
    
  	private SFDC_MDF__c mdfRequest;
  	private SFDC_MDF_Claim__c mdfClaim;
  	public List<MDF_Expense_Detail__c> medfExpenseDelList {get;set;}
  	private User logedinUser ;
  	public Boolean isPreApprovalDocAllowToDel {get;set;}
  	public Boolean isClaimDocAllowToDel {get;set;}
  	public Integer numOfPreApprovalDoc {get;set;}
  	public Integer numOfPOPDoc {get;set;}
    
  	private String subActivity;
	public Boolean displayActivityResultsPopup {get;set;}
	public SFDC_MDF__c objMDFforActivityResults {get;set;} 
	public Boolean isDaysNotCompleted {get;set;} 
        
  	public MDFViewExt(ApexPages.standardController sc) {
		displayActivityResultsPopup = false; 
		isDaysNotCompleted = false;
		if(ApexPages.currentPage().getParameters().containsKey('Id') &&  ApexPages.currentPage().getParameters().get('Id') != null)   
		{
			for(SFDC_MDF__c objMDF : [Select Id, Number_of_Open_Opportunities__c, Number_of_Net_New_Customers__c, Revenue_Generated__c, End_Date__c, Status__c  
										from SFDC_MDF__c where Id = : ApexPages.currentPage().getParameters().get('Id')]) 
			{
				objMDFforActivityResults = objMDF;
			} 
		}
		
	    medfExpenseDelList         = new List<MDF_Expense_Detail__c>();
	    isPreApprovalDocAllowToDel = true;
	    isClaimDocAllowToDel       = true;
	    numOfPreApprovalDoc        = 0;
	    numOfPOPDoc                = 0;
	    
	    //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
	   // String message = '' + ApexPages.currentPage().GetParameters().Get('message');
         String message = String.escapeSingleQuotes('' + ApexPages.currentPage().GetParameters().Get('message'));
	    //String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer'); 
	 String pageHeaderReferer = String.escapeSingleQuotes(ApexPages.currentPage().getHeaders().get('Referer'));
	
	    // Use the referrer parameter to only show the message when coming from Page 1
	    if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('CP_newClaim') && message != 'null') {
	      	ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message)); 
		}
	     
	}
  	public void showActivityResultsPopup()
    {
    	displayActivityResultsPopup = false;
    	isDaysNotCompleted = false;
    	if(objMDFforActivityResults.End_Date__c != null && objMDFforActivityResults.Status__c == 'Approved')
    	{
    		Integer noOfDays = System.today().daysBetween(objMDFforActivityResults.End_Date__c);
    		isDaysNotCompleted = noOfDays < 120;
    	}
    	else
    	{
    		isDaysNotCompleted = true;
    	}
    	
    	displayActivityResultsPopup = true;
    }
    
    public void closeActivityResultsPopup() 
    {
        displayActivityResultsPopup = false;
    }
    
    public void saveActivityResult()
    {
    	if(!isDaysNotCompleted)
    		update objMDFforActivityResults;
    	displayActivityResultsPopup = false;
    }
    
   	/* Returns MDF request for Id specified in URL.*/
   	public SFDC_MDF__c getMdfRequest() { 
	    if (mdfRequest != null) {     
	      return mdfRequest;     
	    } else {
	      	//String mdfRequestId = ApexPages.currentPage().getParameters().get('Id');
            String mdfRequestId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id'));
	      	if (! String.isBlank(mdfRequestId)) {
		        List<SFDC_MDF__c> mdfRequestList = [
		            SELECT 
		                Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c,
		                Requester_Name__c, Other_Vendors_Represented__c, Activity_Description__c, Total_Estimated_Cost__c,
		                Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c, Number_of_Copies__c, 
		                Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c, Number_of_Calls__c, Number_of_Leads__c,
		                Number_of_Attendees__c, Number_of_Unique_Views__c, Number_of_Emails_Sent__c, Number_of_Contacts__c, 
		                Estimated_Revenue__c, Annual_Sales_Quota__c, Estimated_Open_Emails__c,Is_Record_Locked__c, 
		                Estimated_Cost_per_Copy__c, Estimated_Cost_per_Recipient__c, Estimated_Cost_per_Visitor__c, Estimated_Cost_per_Sale__c,
		                Estimated_Close_Rate__c, Estimated_Cost_per_Lead__c, Estimated_Response_Rate__c, Estimated_Cost_per_Attendees__c,
		                Estimated_Cost_per_View__c, Estimated_Email_Open_Rate__c, Estimated_Bounce_Back_Success_Rate__c, Estimated_ROI__c,
		                Estimated_Cost_to_Revenue__c, Estimated_Sales_Incentive_Rate__c, Approved_Date__c, Estimated_Number_of_Responses__c
		           FROM SFDC_MDF__c 
		           WHERE Id =: mdfRequestId LIMIT 1
		        ] ;
	                        
		        //Might be wrong record Id is passed in that case we have to show him error.
		        if (mdfRequestList.size() > 0) {
		          mdfRequest = mdfRequestList[0];
		        } else {
		          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Request Not found' ));
		          return null;
		        }
	      	} else {
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Request Not found' ));
		        return null;
	      	}          
		}
    	return mdfRequest;
	}
  
  
  	public void setMdfRequest(SFDC_MDF__c value) {
    	mdfRequest = value;
  	}
  
  	/*@Returns MDF expense List. If no records than return empty list.  */
  	public List<MDF_Expense_Detail__c> mdfExepeseList {
		get {
	     	// Find MDF expense details
	      	if (getMdfRequest() != null ) {
	            
	      		mdfExepeseList = [ SELECT Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c FROM MDF_Expense_Detail__c WHERE MDF_Request__c =: getMdfRequest().id];
	      	} else {
        		mdfExepeseList = new List<MDF_Expense_Detail__c>();
	      	}
      		return mdfExepeseList;
		}
    	set;
  	}
  
  	/*
   	* Return associated claim with MDF Request.
   	*/
  	public SFDC_MDF_Claim__c getMdfClaim() {
    	if (mdfClaim != null) {
      		return mdfClaim;
    	} else {
	      	mdfClaim = null;
	      	if (getMdfRequest() != null ) {
	        	//Find Claims for the request
	        	List<SFDC_MDF_Claim__c> mdfClaimList = [SELECT 
											                Id, Name,Status__c, Actual_Number_of_Copies__c, Actual_Circulation__c, Actual_Number_of_Unique_Site_Visitors__c,
											                Actual_Number_of_Sales__c, Actual_Number_of_Calls__c, Numbers_of_Leads__c, Actual_Number_of_Attendees__c, 
											                Actual_Number_of_Unique_Views__c, Actual_Number_of_Emails_Sent__c, Actual_Number_of_Contacts__c, Actual_Revenue__c,
											                Actual_Annual_Sales_Quota__c, Actual_Open_Emails__c, Actual_Number_of_Responses__c, Number_of_CTA_Click_through__c,
											                Actual_Sales__c, Actual_Cost_per_Copy__c, Actual_Cost_per_Recipient__c, Actual_Cost_per_Visitor__c, Actual_Cost_per_Sale__c,
											                Actual_Close_Rate__c, Actual_Cost_per_Lead__c, Actual_Response_Rate__c, Actual_Cost_per_Attendees__c, Actual_Cost_per_View__c,
											                Actual_Email_Open_Rate__c, Actual_Bounce_Back_Success_Rate__c, Actual_ROI__c, Actual_Cost_to_Revenue__c, 
											                Actual_Sales_Incentive_Rate__c, Actual_Call_to_Action_Conversion_Rate__c, Actual_Visitor_to_lead_Conversion_Rate__c,
											                Actual_Percentage_of_Quota_Attained__c, Claim_Submission_Date__c, Approved_Date__c,Transaction_Reference__c
											            FROM SFDC_MDF_Claim__c 
											            WHERE Fund_Request__c =: getMdfRequest().Id ];
	    
	        	if (mdfClaimList.size() > 0) {
	          		mdfClaim = mdfClaimList[0];
	        	}
      		} 
		}
    	return mdfClaim;
  	}
  
  	// Set Claim
  	public void setMdfClaim(SFDC_MDF_Claim__c value) {
    	mdfClaim = value;
  	}
 
  	/*
	   * Submit MDF Request for approval.
	   *
   	*/
  	public void submitMdfRequest() {
	    Savepoint sp = Database.setSavepoint();  
	    mdfRequest.Is_Record_Locked__c = true;
	    mdfRequest.Request_Submission_Date__c = System.now();
	    try {
      		update mdfRequest;
	      	Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
	      	//req.setProcessDefinitionNameOrId('MDF_Request_Approval_Process');If set to null, submission of a record approval follows standard evaluation; 
	      	//that is, every entry criteria of the process definition in the process order is evaluated and the one that satisfies is picked and submitted.   
	      	req.setComments('Submitted for approval. Please approve.');
	      	req.setObjectId(mdfRequest.Id);
	      	// submit the approval request for processing
	      	Approval.ProcessResult result = Approval.process(req);
	     	if (result == null || result.isSuccess() != true) {
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Request could not submit' ));
		        Database.rollback(sp);
		        return;
	      	}
    	} catch (Exception ex) {
      		Database.rollback(sp);
    	}
    	mdfRequest = null ;
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Your Request is submitted.'));
  	}
  
  	/*
   		* Submit MDF Claim
   	*/ 
   	public void submitMdfClaim() {
     
     	Savepoint sp = Database.setSavepoint();
     	mdfClaim.Status__c = 'Submitted';
     
     	try {
	       	update mdfClaim;
	       	Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
	       	req.setComments('Submitted for approval. Please approve.');
	       	req.setObjectId(mdfClaim.Id);
	       	Approval.ProcessResult result = Approval.process(req);
	       	if (result.isSuccess() != true) {
	         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Claim could not submit' ));
	         Database.rollback(sp);
	         return;
	       	}
     	} catch (Exception ex) {
        	Database.rollback(sp);
     	}
     	mdfClaim = null;
     	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Claim has been submitted successfully.'));
	}
  
  	// Add a new expense item in to list, but to save item in to database user need to click on save buttion.
  	public void addExpenseDetail() {
    	mdfExepeseList.add(new MDF_Expense_Detail__c());
  	}
    
  	public PageReference redirectToEditPage(){
    
	    PageReference pr = Page.mdf_edit_request ;
	    pr.getParameters().put('id', mdfRequest.Id);
	    return pr ;
        
  	}
    
  	public PageReference redirectToClaimPage(){
        
	    PageReference pr = Page.CP_newClaim;
	    pr.getParameters().put('mdfReqId', mdfRequest.Id);
	    return pr ;
  	}
     
    
  	//Delete expense item from list
  	Integer rowIndex;
  	public void deleteExpenseDetail() {
        //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
        rowIndex = Integer.valueOf(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('rowIndex')));
        MDF_Expense_Detail__c del = mdfExepeseList.remove(rowIndex);
        
        if(del.Id != null)
        {
            medfExpenseDelList.add(del);
        }
  	}
    
    
  	//Upsert Expense Detail
  	public void saveExpenseDetail() {
  		upsert mdfExepeseList ;
  	}
    
    
  	public List<SelectOption> getItems() {
	    List<SelectOption> options = new List<SelectOption>();
	    options.add(new SelectOption('Booth Fund','Booth Fund'));
	    options.add(new SelectOption('Email Marketing','Email Marketing'));
	    return options;
  	}
    
  	public String getSubActivity() {
    	return subActivity;
  	}
            
  	public void setSubActivity(String subActivity) {
    	this.subActivity= subActivity;
  	}
    
  	public User getLogedInUser(){
	    if (logedInUser == null) {
	            
	      logedInUser  = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
	      return logedInUser;
	    } else {
	        
	      return logedInUser;
	    }
  	}
    
  	public void saveMdfRequest() {
	    Savepoint sp ;
	    User u = getLogedInUser();
	        
	    try {
            
      		// Create a savepoint while appear error saving expense detail 
	      	sp = Database.setSavepoint();
	            
	      	if (u.accountId != null ) {
	            
		        if (! (mdfRequest.Account__c != null)) {
		          	mdfRequest.Account__c = u.AccountId ;
		        }
	      	} else {
	            
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'You can not make MDF Request because you are not associated with any account' ));
		        return ;
	      	}
	      	upsert mdfRequest;
	            
    	} catch(Exception ex) {
	      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
    	}
        
    	try {
        
	      	for(MDF_Expense_Detail__c mdfExpenseDetail: mdfExepeseList){
	        	mdfExpenseDetail.MDF_Request__c = mdfRequest.Id ;
	      	}
	      	upsert mdfExepeseList ;
            
    	} catch(Exception ex) {
	      	Database.rollback(sp);
	      	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
    	}
  	}
  
  	private Boolean isRecordLocked;
    
  	public PageReference deleteMDFRequest() {
	    if (mdfRequest.status__c != 'Approved') {
	      delete mdfRequest ;   
	    }
      	PageReference pr = Page.MDFList;
      	pr.setRedirect(true);       
      	return pr;
  	}
    
  	//Delete preapproval Doc if MDF request not yet reached to final decision.
	public void deletePreApprovalDoc() {
		try {
	      	system.debug('****');
	      	//Find out the stages where user is allowed to delete pre approval doc    
	      	Set<String> stages; 
	      	PreApprovalDocCRUDvalidater__c permittedStages = PreApprovalDocCRUDvalidater__c.getInstance(UserInfo.getProfileId());
	      	//if custom seeting is availabel for the current user profile find in what stages he allowe to delete the doc
	      	if (permittedStages != null) {
		        stages = new Set<String>(permittedStages.Stages__c.split(';'));
		        //if no stages availabe check for OWD
		        if (stages == null) {
		          permittedStages = PreApprovalDocCRUDvalidater__c.getInstance();
		          stages = new Set<String>(permittedStages.Stages__c.split(';'));
		        }
			} else {
		        //if setting is not defined for the loged in user profile use OWD setting
		        permittedStages = PreApprovalDocCRUDvalidater__c.getInstance();
		        stages = new Set<String>(permittedStages.Stages__c.split(';'));
      		}
            
      		//If stages is availabel either for the particular profile or OWD, perform required process
      		if (stages != null && stages.size() > 0) {
                
	        	if (stages.contains(mdfRequest.status__c)) {
	          		//String recId = ApexPages.currentPage().getParameters().get('fileRecId');
	          		String recId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fileRecId'));
	          		List<File__c> deleteFileList = [SELECT Id FROM File__c WHERE Id =: recId];
	          		if (null != deleteFileList && deleteFileList.size() > 0) {
	            		delete deleteFileList;
	            		return;
	          		}
        		}
	      	} else {
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'You are not allowed to delete document once reqest is '+mdfRequest.Status__c));
		        return ;
	      	}
            
      		//If custom setting is not availabel for logedin user profile and OWD
      		//OR custom setting is availabe but stages in not defined in any custom setting delete the record
      		{
		         //String recId = ApexPages.currentPage().getParameters().get('fileRecId');
		        String recId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fileRecId'));
		        List<File__c> deleteFileList = [SELECT Id FROM File__c WHERE Id =: recId];
		        if (null != deleteFileList && deleteFileList.size() > 0) {
		          delete deleteFileList;
		        }
      		}
    	} catch(Exception ex) {
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
    	}
	}
    
  	public List<FileListUtil.AttachmentWrapper> files {
    	get {
      		FileListUtil fileListUtilObj = FileListUtil.getInstance();
      		//List out all files for desired parents. Like MDF request and Claim Request.
      		List<FileListUtil.AttachmentWrapper> fileList = new List<FileListUtil.AttachmentWrapper>();

      		List<FileListUtil.AttachmentWrapper> tempAttWrapList = fileListUtilObj.createFileList(mdfRequest.Id,'SFDC_MDF__c','Fund_Request__c', 
                                                                                            new String[] {'Id','Name','Pre_Approval__c','Claim__c',
                                                                                            'Pre_Approval_Document_Type__c',
                                                                                            'Proof_of_Performance_Document_Type__c','Attachment_ID__c'}
      
                                                                                          );
     		numOfPreApprovalDoc = tempAttWrapList.size() ; 
      
      		if (tempAttWrapList.size() > 0) {
	        	fileList.addAll(tempAttWrapList);
	      	}
      
      		// List of all Proof of Performance(POP) document and Pre Approval document which also work as POP.
      		if (mdfClaim != null) {
        		tempAttWrapList.clear();
        		tempAttWrapList = fileListUtilObj.createFileList(mdfClaim.Id,'SFDC_MDF_Claim__c','Fund_Claim__c', new String[] {'Id','Name','Pre_Approval__c','Claim__c',
                                                         'Pre_Approval_Document_Type__c','Proof_of_Performance_Document_Type__c','Attachment_ID__c'}
        
                                                     );
		        system.debug('*****'+tempAttWrapList+'***'+mdfClaim.Id);
		        system.debug('-----'+tempAttWrapList.size()) ;
		        numOfPOPDoc = tempAttWrapList.size();
        		if (tempAttWrapList.size() > 0) {
          			fileList.addAll(tempAttWrapList);
        		}
      		}
      		return fileList;  
    	}
    	set;
  	}
    
  	public PageReference redirectToClone() {
	    PageReference pr = Page.mdfnewrequestpage;
	    pr.getParameters().put('id',mdfRequest.Id);
	    pr.getParameters().put('retURL','/apex/mdfRequestView?id='+mdfRequest.Id);
	    return pr;
  	}
  
    /*
    * Method to redirect user on MDF List Page.
    */ 
    public PageReference redirectToMDFListPage() {
         PageReference pagefRef = Page.MDFList;       
         pagefRef.setRedirect(true);   
        return pagefRef;
    }
}