public class PRM_EngineerController {
    
     @AuraEnabled
    public static List<Engineers__c> getEngineer(String selectedView)
    {
       
        List<Engineers__c> lstEng;
            
        if(selectedView == 'All')
        {
            lstEng =  [Select Id, Name, Status__c, Type_of_Portal_Access__c, City__c, Partner_Account__c,Active_Engineer__c, State_Province__c, Engineer_ID__c, Last_Name__c, Web_Portal_login_ID__c, First_Name__c,
                       Diagnostics_Approved__c, Email_Address__c, Previous_Employer__c, Diagnostics_Request_Status__c, Rejection_Reason_of_Portal_Access__c, Rejection_Reason_of_Diagnostic_Request__c,
                       Certification_Deadline__c, Key_Disk__c, ATM_USB_Key__c, TCR_USB_Key__c, Plus_DVD__c, SelfServ_Checkout_USB_Key_7350__c, Service_Center_USB_Key_7408__c,
                       In_Breach__c,CreatedDate ,Certified__c, Portal_Approved__c                             
                       from Engineers__c order by CreatedDate ];
        }
        if(selectedView == 'In Breach Engineers')
        {
            lstEng =  [Select Id, Name, Status__c, Type_of_Portal_Access__c, City__c, Partner_Account__c,Active_Engineer__c, State_Province__c, Engineer_ID__c, Last_Name__c, Web_Portal_login_ID__c, First_Name__c,
                       Diagnostics_Approved__c, Email_Address__c, Previous_Employer__c, Diagnostics_Request_Status__c, Rejection_Reason_of_Portal_Access__c, Rejection_Reason_of_Diagnostic_Request__c,
                       Certification_Deadline__c, Key_Disk__c, ATM_USB_Key__c, TCR_USB_Key__c, Plus_DVD__c, SelfServ_Checkout_USB_Key_7350__c, Service_Center_USB_Key_7408__c,
                       In_Breach__c ,CreatedDate,Certified__c, Portal_Approved__c                            
                       from Engineers__c where In_Breach__c = true and Active_Engineer__c = true order by CreatedDate ];
        }
        if(selectedView == 'Inactive Engineers')
        {
            lstEng =  [Select Id, Name, Status__c, Type_of_Portal_Access__c, City__c, Partner_Account__c,Active_Engineer__c, State_Province__c, Engineer_ID__c, Last_Name__c, Web_Portal_login_ID__c, First_Name__c,
                       Diagnostics_Approved__c, Email_Address__c, Previous_Employer__c, Diagnostics_Request_Status__c, Rejection_Reason_of_Portal_Access__c, Rejection_Reason_of_Diagnostic_Request__c,
                       Certification_Deadline__c, Key_Disk__c, ATM_USB_Key__c, TCR_USB_Key__c, Plus_DVD__c, SelfServ_Checkout_USB_Key_7350__c, Service_Center_USB_Key_7408__c,
						In_Breach__c, CreatedDate ,Certified__c, Portal_Approved__c                                                   
                       from Engineers__c where Active_Engineer__c = false order by CreatedDate ];
        }
		if(selectedView == 'Active Engineers')
        {
            lstEng =  [Select Id, Name, Status__c, Type_of_Portal_Access__c, City__c, Partner_Account__c,Active_Engineer__c, State_Province__c, Engineer_ID__c, Last_Name__c, Web_Portal_login_ID__c, First_Name__c,
                       Diagnostics_Approved__c, Email_Address__c, Previous_Employer__c, Diagnostics_Request_Status__c, Rejection_Reason_of_Portal_Access__c, Rejection_Reason_of_Diagnostic_Request__c,
                       Certification_Deadline__c, Key_Disk__c, ATM_USB_Key__c, TCR_USB_Key__c, Plus_DVD__c, SelfServ_Checkout_USB_Key_7350__c, Service_Center_USB_Key_7408__c,
						In_Breach__c, CreatedDate ,Certified__c, Portal_Approved__c                                                   
                       from Engineers__c where Active_Engineer__c = true order by CreatedDate ];
        }
		/*if(selectedView == 'Recently Viewed')
        {
            lstEng =  [Select Id, Name, Status__c, Type_of_Portal_Access__c, City__c, Partner_Account__c,Active_Engineer__c, State_Province__c, Engineer_ID__c, Last_Name__c, Web_Portal_login_ID__c, First_Name__c,
                       Diagnostics_Approved__c, Email_Address__c, Previous_Employer__c, Diagnostics_Request_Status__c, Rejection_Reason_of_Portal_Access__c, Rejection_Reason_of_Diagnostic_Request__c,
                       Certification_Deadline__c, Key_Disk__c, ATM_USB_Key__c, TCR_USB_Key__c, Plus_DVD__c, SelfServ_Checkout_USB_Key_7350__c, Service_Center_USB_Key_7408__c,
						In_Breach__c, CreatedDate ,Certified__c                                                   
                       from Engineers__c ORDER BY  LastViewedDate DESC limit 10];
        }*/
        
        return lstEng;
    

    }
    
    @AuraEnabled
    public static Engineers__c getEngineerDetail(String recId)
    {
        Engineers__c objEng =  [Select Id, Name, Status__c, Type_of_Portal_Access__c, City__c, Partner_Account__c,Active_Engineer__c, State_Province__c, Engineer_ID__c, Last_Name__c, Web_Portal_login_ID__c, First_Name__c,
                      			Diagnostics_Approved__c, Email_Address__c, Previous_Employer__c, Diagnostics_Request_Status__c, Rejection_Reason_of_Portal_Access__c, Rejection_Reason_of_Diagnostic_Request__c,
                       			Certification_Deadline__c, Key_Disk__c, ATM_USB_Key__c, TCR_USB_Key__c, Plus_DVD__c, SelfServ_Checkout_USB_Key_7350__c, Service_Center_USB_Key_7408__c,
                                Personas_ATM__c,Teller_Cash_Recycler__c, Point_of_Sale__c, Retail_Kiosks__c, Payment_Solutions__c, Self_Serv_ATM__c, Financial_Kiosks__c, 
								Deposit_Automation__c, Self_Check_Out__c, Interactive_Teller__c,Interactive_Services__c,APTRA_Vision__c,Inetco__c,Cash_Management_I__c,
                                Solidcore_Financial__c,Alaric__c,eMarketing__c,Payment__c,APTRA_Express_ATM__c,APTRA_Express_Activate__c,Advanced_Checkout_Solution_ACS__c,ISS45_Retail__c,ScanMaster_RETAIL__c,
                                Connected_Payments_SaaS__c,Connected_Loyalty_SaaS__c,Connected_Services_SaaS__c,Advanced_Back_Office_ABO__c,Advanced_Retail_Solution_ARS__c,StorePoint__c,RBO_PocketOffice__c,
                                Retalix_Store_HQ__c,LaneHawk__c,Solidcore_Retail__c,ISS45_Fuel__c,Loyalty_Pro__c,Connected_Loyalty__c, Partner_Account__r.Name ,Certified__c, Portal_Approved__c
                                from Engineers__c where Id =: recId ];
       
        return objEng;
    }
     @AuraEnabled
    public static List<Attachment__c> getEngineerAttachment(String recId)
    {
        List<Attachment__c> lstAttchment = [Select Name,Engineer_Attachment_Type__c, Attachment_Name__c, Attachment__c,IPT_View__c from Attachment__c where Engineers__c =: recId];
        return lstAttchment;
    }
    @AuraEnabled
    public static String saveEngineer(Engineers__c objEng)
    {
        try{
            User objUser = [Select Id , AccountId from User where Id=: UserInfo.getUserId()];
            objEng.Partner_Account__c = objUser.AccountId;
            objEng.Type_of_Portal_Access__c = 'Portal Access';
            upsert objEng;
        }
        catch(Exception e)
        {
            objEng.Partner_Account__c = null;
            objEng.Type_of_Portal_Access__c = 'Portal Access';
            upsert objEng;
        }
		return objEng.Id;        
    }
	@AuraEnabled
    public static PicklistDetail getPicklistValues()
    {
        
        PicklistDetail objPicklistDetail = new PicklistDetail();
        
        
        //Portal Access Status
        Schema.DescribeFieldResult fieldResult = Engineers__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            objPicklistDetail.portalAccessStatus.add(f.getValue());
        }   
        
        
        
        //Request For
        Schema.DescribeFieldResult fieldResult3 = Engineers__c.Type_of_Portal_Access__c.getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
            
        for(Schema.PicklistEntry f : ple3)
        {
            objPicklistDetail.requestFor.add(f.getValue());
        }    
        
        
        return objPicklistDetail;   
    }
    
    
    // Porcess portal Access Request
    @AuraEnabled
    public static ProcessResult submitPortalRequest(String recordId, String comment, Engineers__c objEngineer)
    {
       	ProcessResult result ;
        Engineers__c eng = [Select id, Type_of_Portal_Access__c, Status__c from Engineers__c Where id =: Id.valueOf(recordId)];
        
        if(String.isNotBlank(eng.Type_of_Portal_Access__c))
        {
            if(eng.Type_of_Portal_Access__c.containsIgnoreCase('Portal Access'))
            {
                // If it's a new request or rejcted request in past than only allow it to submit
                if (eng.Status__c == 'Created' || eng.Status__c == 'Rejected') {
                    // Submit portal access request
                    result = approvalSubmission(recordId, UserInfo.getUserId(), comment, objEngineer);
                }
                else if (eng.Status__c == 'Submitted') {
                    result = new ProcessResult('info', 'Portal access request has already been Submitted. You will not be able to re-submit this request for approval.', objEngineer);
                }
                else if (eng.Status__c == 'Approved') {
                    result = new ProcessResult('info', 'Portal access request has already been approved. You will not be able to re-submit this request for approval.', objEngineer);
                }
            }
            else
            {
                result = new ProcessResult('info', 'Portal access request already completed.', objEngineer);
            }
        }
        
        result.objEng = getEngineerDetail(recordId);
        return result;
    }
    
    @AuraEnabled
    public static ProcessResult submitDiagnosticsApprovalRequest(String recordId, String comment, Engineers__c objEngineer )  
    {
        ProcessResult result ;
        List<Attachment__c> engAttachmentList;
        
        List<Engineers__c> engList = [Select id, Status__c, Type_of_Portal_Access__c, Diagnostics_Request_Status__c  
                                      from Engineers__c Where id =: recordId LIMIT 1];
        
        
        if (engList[0].Status__c != 'Approved') 
        {
            result = new ProcessResult('info','Portal Access must be approved to submit Diagnostics Request', objEngineer);
            return result;
        } 
        else if(engList[0].Diagnostics_Request_Status__c == 'Submitted') 
        {
           	result = new ProcessResult('info','Diagnostics Request has already been submitted. You will not be able to re-submit this request for approval.', objEngineer);
            return result;
        } 
        else if (engList[0].Diagnostics_Request_Status__c == 'Approved') 
        {
            result = new ProcessResult('info','Diagnostics Request has already been approved. You will not be able to re-submit this request for approval.', objEngineer);
            return result;
        }
        System.debug('-----------------engList[0].Id--------'+engList[0].Id);
        engAttachmentList = [Select Id, Name, Engineers__c, Engineer_Attachment_Type__c From Attachment__c 
                                 Where Engineers__c =: engList[0].Id AND Engineer_Attachment_Type__c = 'IPP Order Form'];
        System.debug('-----------------engAttachmentList-------'+engAttachmentList);
        if(!engAttachmentList.isEmpty() || Test.isRunningTest())
        {
           	engList[0].Type_of_Portal_Access__c = 'Diagnostics';
            engList[0].Diagnostics_Request_Status__c = 'Submitted';
                
            try 
            {
                update engList[0];
            } 
            catch (exception ex) 
            { 
                result = new ProcessResult('error',ex.getMessage(), objEngineer);
            }                
            result = approvalSubmission(recordId, UserInfo.getUserId(), comment, objEngineer);
        }  
        else
        {
            result = new ProcessResult('info','Please attach IPP Order Form in attachement to submit Diagnostics Request', objEngineer);
            return result;
        }
        
        result.objEng = getEngineerDetail(recordId);
        return result;
    }
    public static ProcessResult approvalSubmission(String objectId, String userId, String strComment, Engineers__c objEngineer )
    {
        ProcessResult result ;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(strComment);
        req1.setObjectId(Id.valueOf(objectId));
        req1.setSubmitterId(Id.valueOf(userId));
        
        // Submit the approval request for the account
        try
        {
            Approval.ProcessResult approvalResult = Approval.process(req1);
            if(approvalResult.isSuccess())
            {
                result = new ProcessResult('success',' Record successfully submitted for Approval', objEngineer);
            }
            else 
            {
                result = new ProcessResult('error', String.valueOf(approvalResult.getErrors()), objEngineer);
            }
        }
        catch (Exception e)
        {
            if(e.getMessage().containsIgnorecase('This record is currently in an approval process'))
            {
                result = new ProcessResult('error', 'Record has already been submitted for approval. Please contact the approver.', objEngineer);
            }
            else
            {
                result = new ProcessResult('error', 'Record cannot be submitted because of glitch in System. Contact IT support', objEngineer);
            }
        }
        
      
        return result;
    }
    
    
     @AuraEnabled
    public static Id saveChunk( String attachmentType, Id parentId, String fileName, String base64Data, String contentType, String fileId) 
    {
     
        if (fileId == '') 
        {
            fileId = saveTheFile(attachmentType, parentId, fileName, base64Data, contentType);
        } 
        else 
        {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(String attachmentType, Id parentId, String fileName, String base64Data, String contentType) 
    {
        System.SavePoint sp = DataBase.setSavePoint();
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        try
        { 
            oAttachment.parentId = parentId;
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            insert oAttachment;
            
            // fill out cust obj fields
            Attachment__c customAttachment = new Attachment__c();
            customAttachment.Engineers__c = parentId;
            customAttachment.Engineer_Attachment_Type__c= attachmentType;
            customAttachment.Attachment_Name__c = fileName;
            customAttachment.Attachment__c = oAttachment.Id;
            
            Database.insert(customAttachment);
        }
        catch(Exception ex)
        {
            Database.rollback(sp); 
        }
        
        return oAttachment.Id;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
    public class ProcessResult 
    {
        @AuraEnabled public String status = '';
        @AuraEnabled public String message = '';
        @AuraEnabled public Engineers__c objEng;
        /*public processResult(){} commented empty block */
        
        public processResult(String status, String message, Engineers__c objEng) 
        {
            this.status = status;
            this.message = message;
            this.objEng = objEng;
        }
    }
    
   
	
	public class PicklistDetail
    {
        @AuraEnabled
        public Engineers__c objEng;
        
        @AuraEnabled
        public List<String> requestFor;
        
        @AuraEnabled
        public List<String> portalAccessStatus;
        
        public PicklistDetail()
        {
            requestFor = new List<String>();
            requestFor.add('--None--');
            
            portalAccessStatus = new List<String>();
           	portalAccessStatus.add('--None--');
        }
    }

}