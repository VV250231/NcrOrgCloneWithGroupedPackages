global class MarketingConciergeApproval 
{
    webService static String submitForApproval(String recordId, String userId)
  	{
  		String result ='';
        
        List<Attachment> lstMarketingConciergeAttachment = [Select Id from Attachment where ParentId =: recordId];
        
        if(!lstMarketingConciergeAttachment.isEmpty())
        {
           	result = approvalSubmission(recordId, userid);
           	//result = 'Submitted.';
        }  
        else
        {
        	result = 'Please upload the attachment before submit for Approval.';
        }
        return result;
  	}
  	
  	public static String approvalSubmission(String recordId, String UserId)
	{
 		String resultsTr ='';
     	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest ();
     	req1.setComments('Submitting request for approval.');
     	req1.setObjectId(Id.valueOf(recordId));
     	
     	// Submit the approval request for the account
     	try
     	{
         	Approval.ProcessResult result = Approval.process(req1);
         	if(result.isSuccess())
         	{
            	resultStr  = 'Record successfully submitted for Approval';
         	}
     	}
     	catch(Exception e)
 		{
     		if(e.getMessage().containsIgnorecase('This record is currently in an approval process')){
         		resultsTr ='Record already has been submitted for approval. Please contact the Approver'  ;
         	}
         	else{
                  System.debug( 'result=== '+ e.getMessage());
                    resultsTr  =' Record cannot be submitted because of glitch in System. Contact IT support';  
       		}
     	}
     	return resultsTr  ;
 	}
}