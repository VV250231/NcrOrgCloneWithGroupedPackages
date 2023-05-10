/*
##################################################################################################
# Class Name............................:ApprovalClass                                                                                                                                 
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
global class ApprovalClass
{ 
  	webService static String submitForApproval(String ids, String userId)
  	{
		String result ='';
        
        Set<String> setAttachmentType = new Set<String>();
        List<Attachment__c> engAttachmentList =[Select Id, Name, Engineers__c, Engineers__r.Type_of_Portal_Access__c, Engineers__r.Status__c,
        											Engineer_Attachment_Type__c From Attachment__c Where Engineers__c =: Id.valueOF(ids)];
        
        Engineers__c eng = [Select id, Type_of_Portal_Access__c, Status__c  from Engineers__c Where id =: Id.valueOF(ids)];
       
     	
        if(eng.Type_of_Portal_Access__c != null && eng.Type_of_Portal_Access__c != '')
        {
           	if(eng.Type_of_Portal_Access__c.containsIgnoreCase('Diagnostic'))
           	{
           		if(eng.Status__c == 'Approved')
           			result ='Portal access has already been approved. You will not be able to re-submit this request for approval.' ; 
           			
           	}
           	else if(eng.Type_of_Portal_Access__c.containsIgnoreCase('Portal Access'))
           	{
           		if(eng.Status__c == 'Created' || eng.Status__c == 'Rejected')
           			result = approvalSubmission(ids,userid);
           			
           		if(eng.Status__c == 'Submitted')
           			result = 'Portal access has already been Submitted. You will not be able to re-submit this request for approval.';
           		if(eng.Status__c == 'Approved' )
           			result = 'Portal access has already been approved. You will not be able to re-submit this request for approval.' ; 
           	}
        }  
        
        return result;
    }
    
    webService static String submitForApprovalDeal(String ids, String userId)
    {
        String result = '';
        result = approvalSubmission(ids,userid);
        sendEmail(ids,userid);
        return  result ;
    }
    
    public static void  sendEmail(String ids, String userid)
    {
 		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

      	//Query Email
      	List<EmailTemplate> emailtemp =[Select id from EmailTemplate Where Name ='Deal Registration Submission Acknwoledge'];

      	//Set list of people who should get the email
      	List<User> userEmail =[Select id ,Name, email from user Where id =:Id.valueOf(userid)];
      	List<String> sendTo = new List<String>();
      	sendTo.add(userEmail[0].email);
      	mail.setToAddresses(sendTo);
    
      	//Set who the email is sent from

		mail.setReplyTo('nonReply@ncr.com');
      	mail.setSenderDisplayName('Non- Reply ');
    
      	// (Optional) Set list of people who should be CC'ed
      	List<String> ccTo = new List<String>();
      	//  Set email contents - you can use variables!
      	mail.setSubject('Channel Partner submission Confirmation Email');
        String body ='<Html><body>' +'Dear ' +userEmail[0].Name  + ', '+'</br></br>';
                      body += ' Thank you for your recent Deal Registration submission.'+'<br/>'+
					'This message is to confirm your submission was received and will be sent to your NCR Account Manager and the Sales Leader for review.'+'<br/>'+
					'After their review you will a receive a message with either an approval for the registered deal or a rejection with a brief explanation why. If rejected and you disagree with this decision, please contact your NCR Account Manager.'+'<br/>'+
					'Thank you again for the Deal Registration submission. '+'<br/><br/><br/>'+
					'Sincerely '+'<br/>'+
					'NCR Channel Program Team'+ '</Html></body>';
                     
      	mail.setHtmlBody(body);
      	Messaging.SingleEmailMessage[] mails= 
      	new List<Messaging.SingleEmailMessage> {mail};
      	Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
    
    
	public static String approvalSubmission(String objectId, String UserId)
	{
 		String resultsTr ='';
     	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest ();
     	req1.setComments('Submitting request for approval.');
     	req1.setObjectId(Id.valueOf(objectId));
     	// Submit on behalf of a specific submitter
     	req1.setSubmitterId(Id.valueOf(userId));
     	// Submit the approval request for the account
     	try
     	{
         	Approval.ProcessResult result =Approval.process(req1);
         	if(result.isSuccess())
         	{
            	resultStr  ='Successfully Submitted for Approval';
         	}
     	}
     	catch(Exception e)
 		{
     		if(e.getMessage().containsIgnorecase('This record is currently in an approval process')){
         		resultsTr ='already has been submitted for approval. Please contact the approver.'  ;
         	}
         	else{
              	System.debug( 'result=== '+ e.getMessage());
            	resultsTr  =' cannot be submitted because of glitch in System. Contact IT support';  
       		}
     	}
     	return resultsTr  ;
 	}
 	
 	/*
 	*
 	*
 	*
 	*/
 	webService static String processDiagnosticsRequest(String objectId, String UserId) {
 		String resultStr = '';
 		List<Attachment__c> engAttachmentList;
 		List<Engineers__c> engList = [Select id, Status__c, Type_of_Portal_Access__c, Diagnostics_Request_Status__c  from Engineers__c Where id =: objectId LIMIT 1];
 		
 		
 		if(engList.size() > 0) {
 			if(engList[0].Diagnostics_Request_Status__c == 'Approved')
 				resultStr  = 'Diagnostics Request has already been approved. You will not be able to re-submit this request for approval.';
 				
 			if(engList[0].Diagnostics_Request_Status__c == 'Submitted') 
 				resultStr  = 'Diagnostics Request has already been submitted. You will not be able to re-submit this request for approval.';
 				
 			if (engList[0].Status__c != 'Approved') 
 				resultStr  = 'Portal Access must be approved to submit Diagnostics Request';
 			
 			if(String.isNotBlank(resultStr))
 				return resultStr;
 				
 			engAttachmentList = [Select Id, Name, Engineers__c, Engineer_Attachment_Type__c From Attachment__c 
 			                     Where Engineers__c =: engList[0].Id AND Engineer_Attachment_Type__c = 'IPP Order Form'];
 			if (engAttachmentList.size() > 0) {
 				// Setting value of 'Request For' field to 'Diagnostics' and 'Diagnostics Request Status' field to 'submitted'.
 				engList[0].Type_of_Portal_Access__c = 'Diagnostics';
 				engList[0].Diagnostics_Request_Status__c = 'Submitted';
 				
 				try {
 					update engList[0];
 				} catch (exception ex) {
 					return resultStr = ex.getMessage();
 				}
 				
 				resultStr = approvalSubmission(objectId,UserId);
 			} else {
 				resultStr = 'Please attach IPP Order Form in attachement to submit Diagnostics Request';
 			}
 		} else {
 			resultStr  = 'Engineer record not found';
 		}
 		
 		return resultStr;
 	}
}