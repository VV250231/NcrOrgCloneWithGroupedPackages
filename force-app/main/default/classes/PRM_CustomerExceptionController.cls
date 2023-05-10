public class PRM_CustomerExceptionController {
    
    @AuraEnabled
    public static List<Account_Exception__c> getCustomerException(String selectedView)
    {
        
        List<Account_Exception__c> lstCE;
        
        if(selectedView == 'All')
            lstCE =  [Select Id, Name, Account_Name__c, Additional_Supporting_Information__c, Any_Current_Contract__c, Approver_Comments__c, Channel_Account_Manager__r.Name, Channel_Sales_Leader__c,
                      Channel_Sales_Leader_Name__c, City__c, Country__c, Created_Date__c, Current_Business_Relationship__c, Current_Date_Time__c, Direct_Sales_Leader__c, Customer_Name__r.Name, End_Customer__c, End_Customer_MCN__c,
                      Primary_Contact_Name__c, End_Customer_Region__c, Expected_Close_Date__c, Expected_Start_Date__c, Date_Of_Expiration__c, How_long_has_this_existed__c, MCN__c, Name_the_Products_Provided__c, Opportunity_Value__c,
                      Other__c, GDPR_Compliance_Policy__c, Partner_Account_Name__r.Name, Partner_Contact__r.Name, Postal_Zip_Code__c, Primary_Competitor__c, Primary_Solution__c, Secondary_Competitor__c, Secondary_Solution__c, Date_Of_Signing__c,
                      State_Province_Region__c, Status__c, Street_Address__c, Submission_Approval_Date__c, Trigger_Time_05__c, What_are_your_own_value_added_products__c, Who_are_the_key_contacts__c
                      from Account_Exception__c order by CreatedDate ];
        else{
            String likeKey = '%' + selectedView + '%';
            lstCE =  [Select Id, Name, Account_Name__c, Additional_Supporting_Information__c, Any_Current_Contract__c, Approver_Comments__c, Channel_Account_Manager__r.Name, Channel_Sales_Leader__c,
                      Channel_Sales_Leader_Name__c, City__c, Country__c, Created_Date__c, Current_Business_Relationship__c, Current_Date_Time__c, Direct_Sales_Leader__c, Customer_Name__r.Name, End_Customer__c, End_Customer_MCN__c,
                      Primary_Contact_Name__c, End_Customer_Region__c, Expected_Close_Date__c, Expected_Start_Date__c, Date_Of_Expiration__c, How_long_has_this_existed__c, MCN__c, Name_the_Products_Provided__c, Opportunity_Value__c,
                      Other__c, GDPR_Compliance_Policy__c, Partner_Account_Name__r.Name, Partner_Contact__r.Name, Postal_Zip_Code__c, Primary_Competitor__c, Primary_Solution__c, Secondary_Competitor__c, Secondary_Solution__c, Date_Of_Signing__c,
                      State_Province_Region__c, Status__c, Street_Address__c, Submission_Approval_Date__c, Trigger_Time_05__c, What_are_your_own_value_added_products__c, Who_are_the_key_contacts__c
                      from Account_Exception__c where Status__c like :likeKey order by CreatedDate ];
        }
        return lstCE;
    }
    
    @AuraEnabled
    public static Account_Exception__c getCustomerExceptionDetail(String recId)
    {
        
        
        List<Account_Exception__c> lstCE;
        
        lstCE =  [Select Id, Name, Account_Name__c, Additional_Supporting_Information__c, Any_Current_Contract__c, Approver_Comments__c, Channel_Account_Manager__r.Name, Channel_Sales_Leader__c,
                  Channel_Sales_Leader_Name__c, City__c, Country__c, Created_Date__c, Current_Business_Relationship__c, Current_Date_Time__c, Direct_Sales_Leader__c, Customer_Name__r.Name, End_Customer__c, End_Customer_MCN__c,
                  Primary_Contact_Name__c, End_Customer_Region__c, Expected_Close_Date__c, Expected_Start_Date__c, Date_Of_Expiration__c, How_long_has_this_existed__c, MCN__c, Name_the_Products_Provided__c, Opportunity_Value__c,
                  Other__c, GDPR_Compliance_Policy__c, Partner_Account_Name__r.Name, Partner_Contact__r.Name, Postal_Zip_Code__c, Primary_Competitor__c, Primary_Solution__c, Secondary_Competitor__c, Secondary_Solution__c, Date_Of_Signing__c,
                  State_Province_Region__c, Status__c, Street_Address__c, Submission_Approval_Date__c, Trigger_Time_05__c, What_are_your_own_value_added_products__c, Who_are_the_key_contacts__c
                  from Account_Exception__c where Id =: recId ];
        
        if(!lstCE.isEmpty())
        {
            return lstCE[0];
        }
        
        return null;
    }
    
     @AuraEnabled
    public static List<Attachment> getCEAttachments(String recId)
    {
        return [Select Id, Name from Attachment where ParentId =: recId];
    }
    
    @AuraEnabled
    public static String saveCustomerException(Account_Exception__c objCE, String customerNameId)
    {
        objCE.Customer_Name__c = customerNameId;
        System.debug('-----------------objCE.Customer_Name__c----------------'+objCE.Customer_Name__c);
        System.debug('-----------------objCE----------------'+objCE);
        
        
        Account_Exception__c obj = new Account_Exception__c(Primary_Competitor__c = objCE.Primary_Competitor__c, 
                                                            Opportunity_Value__c = objCE.Opportunity_Value__c,
                                                            Customer_Name__c = objCE.Customer_Name__c, 
                                                            Primary_Contact_Name__c = objCE.Primary_Contact_Name__c, 
                                                            Primary_Solution__c = objCE.Primary_Solution__c, 
                                                            Expected_Close_Date__c = objCE.Expected_Close_Date__c,
                                                            Additional_Supporting_Information__c = objCE.Additional_Supporting_Information__c);
        insert obj;
        
        System.debug('--------------'+obj.Id);
        return obj.Id;
    }
    
    @AuraEnabled
    public static Account_Exception__c  getEditCustomerExceptionDetail(String recId)
    {
        List<Account_Exception__c> lstCE;
        
       /* lstCE =  [Select Id, Name, Customer_Name__cAccount_Name__c, Additional_Supporting_Information__c, Any_Current_Contract__c, Approver_Comments__c, Channel_Account_Manager__r.Name, Channel_Sales_Leader__c,
                  Channel_Sales_Leader_Name__c, City__c, Country__c, Created_Date__c, Current_Business_Relationship__c, Current_Date_Time__c, Direct_Sales_Leader__c, Customer_Name__r.Name, End_Customer__c, End_Customer_MCN__c,
                  Primary_Contact_Name__c, End_Customer_Region__c, Expected_Close_Date__c, Expected_Start_Date__c, Date_Of_Expiration__c, How_long_has_this_existed__c, MCN__c, Name_the_Products_Provided__c, Opportunity_Value__c,
                  Other__c, GDPR_Compliance_Policy__c, Partner_Account_Name__r.Name, Partner_Contact__r.Name, Postal_Zip_Code__c, Primary_Competitor__c, Primary_Solution__c, Secondary_Competitor__c, Secondary_Solution__c, Date_Of_Signing__c,
                  State_Province_Region__c, Status__c, Street_Address__c, Submission_Approval_Date__c, Trigger_Time_05__c, What_are_your_own_value_added_products__c, Who_are_the_key_contacts__c
                  from Account_Exception__c where Id =: recId ];
		*/
        lstCE =  [Select Id, Name, Primary_Competitor__c, Opportunity_Value__c, Customer_Name__c, Primary_Contact_Name__c, Primary_Solution__c, Expected_Close_Date__c, Additional_Supporting_Information__c,
                  Status__c, Customer_Name__r.Name
                  from Account_Exception__c where Id =: recId ];
        
        
        if(!lstCE.isEmpty())
        {
            return lstCE[0];
        }
        
        return null;
    }
    
  
    @AuraEnabled
    public static String saveEditedCustomerException(Account_Exception__c objCE, String customerNameId)
    {
        objCE.Customer_Name__c = customerNameId;
        System.debug('-----------------objCE.Customer_Name__c----------------'+objCE.Customer_Name__c);
        System.debug('-----------------objCE----------------'+objCE);
        
        
        Account_Exception__c obj = new Account_Exception__c(Id = objCE.Id, Primary_Competitor__c = objCE.Primary_Competitor__c, 
                                                            Opportunity_Value__c = objCE.Opportunity_Value__c,
                                                            Customer_Name__c = objCE.Customer_Name__c, 
                                                            Primary_Contact_Name__c = objCE.Primary_Contact_Name__c, 
                                                            Primary_Solution__c = objCE.Primary_Solution__c, 
                                                            Expected_Close_Date__c = objCE.Expected_Close_Date__c,
                                                            Additional_Supporting_Information__c = objCE.Additional_Supporting_Information__c);
        update obj;
        
        System.debug('--------------'+obj.Id);
        return obj.Id;
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) 
    {      
        if (fileId == '') 
        {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } 
        else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) 
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) 
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =: fileId];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;
    }
    
    @AuraEnabled
    public static ProcessResult submitApprovalRequest(String recordId, String comment) 
    {
        List<Attachment> lstAttachment = [Select Id from Attachment where ParentId =: recordId];
        ProcessResult result ;
       
        
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest ();
            req.setComments(comment);
            req.setObjectId(Id.valueOf(recordId));
            
            try 
            {
                Approval.ProcessResult approvalResult = Approval.process(req);
                if(approvalResult.isSuccess()) 
                {
                    result = new ProcessResult('success','Record successfully submitted for Approval');
                } 
                else 
                {
                    result = new ProcessResult('error', String.valueOf(approvalResult.getErrors()));
                }
            }
            catch(Exception e) 
            {
                result =  new ProcessResult('error','Record cannot be submitted because of glitch in System. Contact IT support');
            }

       	return result;
    }
    
     public class ProcessResult {
        @AuraEnabled public String status = '';
        @AuraEnabled public String message = '';
        
        /*public processResult(){} commemted empty block */
        
        public processResult(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
    
    
}