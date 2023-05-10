public with sharing class MDFListViewCmpController 
{
    @AuraEnabled
    public List<SFDC_MDF__c> lstMDFRequest;
    
    @AuraEnabled
    public Integer offst;
    
    @AuraEnabled
    public Integer total;
    
    @AuraEnabled
    public Boolean hasprev;
    
    @AuraEnabled
    public Boolean hasnext;
    
    @AuraEnabled
    public List<MDFDetails> lstMDFDetails;
    
    private static Integer pagesize = 10;
    private static Integer offset;
    
    
    @AuraEnabled
    public String condition = '';
    
    @AuraEnabled
    public static MDFListViewCmpController getMDFRequestController(Boolean next, Boolean prev, Decimal off, String whereCondtion)
    {
        List<MDFDetails> lstMD = new List<MDFDetails>();
        offset = (Integer)off;
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        Integer listlength ;
        if(String.isBlank(whereCondtion))
            listlength = [Select count() from SFDC_MDF__c where name != null];
        else{
            List<String> lstSplitWhereCondtionByLimit = new List<String>();
            lstSplitWhereCondtionByLimit.addAll(whereCondtion.split('Limit'));
            listlength = Database.countQuery('Select count() FROM SFDC_MDF__c' + lstSplitWhereCondtionByLimit[0] );
        }
            
        
        
        System.debug('-----------prev------------'+prev);
        System.debug('-----------next------------'+next);
        System.debug('-----------offset------------'+offset);
        System.debug('-----------whereCondtion------------'+whereCondtion);
        System.debug('-----------listlength------------'+listlength);
        if(next == false && prev==false)
        {
            if(String.isBlank(whereCondtion))
                lstMDF = [Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c LIMIT :pagesize OFFSET :offset];
            else
                lstMDF = Database.query('Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c' + 
                                        whereCondtion + ' OFFSET '+ offset);
        }
        else if(next == true && (offset + pagesize) <= listlength)
        {
            offset = offset + pagesize;
            System.debug('-----------offset + pagesize------------'+offset);
            if(String.isBlank(whereCondtion))
                lstMDF = [Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c LIMIT :pagesize OFFSET :offset];
            else
                lstMDF = Database.query('Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c' + 
                                        whereCondtion + ' OFFSET '+ offset);
            
        }
        else if(prev == true && offset > 0)
        {
            offset = offset - pagesize;
            System.debug('-----------offset - pagesize------------'+offset);
            if(String.isBlank(whereCondtion))
                lstMDF = [Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c LIMIT :pagesize OFFSET :offset];
            else
                lstMDF = Database.query('Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c' + 
                                        whereCondtion + ' OFFSET '+ offset);
            
        }
        
        for(SFDC_MDF__c objFR : lstMDF)
        {
            MDFDetails objMD = new MDFDetails();
            objMD.objFundRequest = objFR ;
            objMD.claimStatus = objFR.R00N30000002DjDcEAK__r.isEmpty() ? '' : objFR.R00N30000002DjDcEAK__r[0].Status__c;
            lstMD.add(objMD);
        }
        MDFListViewCmpController objController = new MDFListViewCmpController();
        objController.lstMDFDetails = lstMD;
        objController.offst = offset;
        objController.condition = whereCondtion;
        objController.hasprev = hasprev(offset);   
        
         System.debug('-----------offset----------'+offset);
        System.debug('----------listlength-----------'+listlength);
        System.debug('----------pagesize-----------'+pagesize);
        
        objController.hasnext = hasnxt(offset,listlength,pagesize);
        
        System.debug('-----------objController.hasprev------------'+objController.hasprev);
        System.debug('-----------objController.hasnext------------'+objController.hasnext);
        System.debug('-----------objController.offst------------'+objController.offst);
        return objController;
    }
    
    
    @AuraEnabled
    public static MDFListViewCmpController deleteMDFRequest(Boolean next, Boolean prev, Decimal off, String mdfId)
    {
        delete new SFDC_MDF__c(Id = mdfId);
        System.debug('==================================' + [Select Id from SFDC_MDF__c where Id=: mdfId]);
        List<MDFDetails> lstMD = new List<MDFDetails>();
        offset = (Integer)off;
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        Integer listlength = [Select count() from SFDC_MDF__c where name != null];
        if(next == false && prev==false)
        {
            lstMDF = [Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c LIMIT :pagesize OFFSET :offset];
        }
        
        for(SFDC_MDF__c objFR : lstMDF)
        {
            MDFDetails objMD = new MDFDetails();
            objMD.objFundRequest = objFR ;
            objMD.claimStatus = objFR.R00N30000002DjDcEAK__r.isEmpty() ? '' : objFR.R00N30000002DjDcEAK__r[0].Status__c;
            lstMD.add(objMD);
        }
        MDFListViewCmpController objController = new MDFListViewCmpController();
        objController.lstMDFDetails = lstMD;
        objController.offst = offset;
        objController.condition = '';
        objController.hasprev = hasprev(offset);   
        objController.hasnext = hasnxt(offset,listlength,pagesize);
        return objController;
    }
    
    @AuraEnabled
    public static MDFListViewCmpController changeViewSelection(Boolean next, Boolean prev, Decimal off, String val)
    {
        String wCondition = '';
        String dt = DateTime.now().format('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        
        if(val == 'Approved')
        {
            wCondition = ' where Status__c = \'Approved\''; 
        }
        else if(val == 'Request Pending for Approvals')
        {
            wCondition = ' where Status__c = \'Submitted for Approval\''; 
        }
        else if(val == 'Rejected')
        {
            wCondition = ' where Status__c = \'Rejected\''; 
        }
        else if(val == 'Created Today')
        {
            wCondition = ' where CreatedDate >=  ' + dt; 
        }
        else if(val == 'Pending')
        {
            wCondition = ' where Status__c = \'Submitted\' or Status__c = \'In Process\'';
        }
        
        Integer listlength ;
        if(String.isBlank(wCondition))
            listlength = [Select count() from SFDC_MDF__c where name != null];
        else
            listlength = Database.countQuery('Select count() FROM SFDC_MDF__c' + wCondition );
        
        if(next == false && prev==false)
            
            wCondition = String.isNotBlank(wCondition) ? wCondition + ' Limit ' + pagesize :  ' Limit ' +pagesize;
        
        List<MDFDetails> lstMD = new List<MDFDetails>();
        offset = (Integer)off;
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        //Integer listlength = [Select count() from SFDC_MDF__c where name != null];
        if(next == false && prev==false)
        {
            lstMDF = Database.query('Select Id, Name, Status__c, Request_ID__c, Activity_Date__c, (SELECT Status__c FROM R00N30000002DjDcEAK__r LIMIT 1) FROM SFDC_MDF__c' + wCondition);
        }
        
        for(SFDC_MDF__c objFR : lstMDF)
        {
            MDFDetails objMD = new MDFDetails();
            objMD.objFundRequest = objFR ;
            objMD.claimStatus = objFR.R00N30000002DjDcEAK__r.isEmpty() ? '' : objFR.R00N30000002DjDcEAK__r[0].Status__c;
            lstMD.add(objMD);
        }
        MDFListViewCmpController objController = new MDFListViewCmpController();
        objController.lstMDFDetails = lstMD;
        objController.offst = offset;
        objController.condition = wCondition;
        objController.hasprev = hasprev(offset);   
        objController.hasnext = hasnxt(offset,listlength,pagesize);
        return objController;
    }
    
    private static Boolean hasprev(Integer off)
    {
        if(off > 0)
            return false;
        return true; 
    }
    
    private static Boolean hasnxt(Integer off, Integer li, Integer ps)
    {
        if(off + ps < li)
            return false;
        return true;
    }  
    
    @AuraEnabled
    public static MDFDetailInfo getMDFDetailInformation(Id recId)
    {
        SFDC_MDF__c objMDF = [Select Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c,
                              Requester_Name__c, Other_Vendors_Represented__c, Activity_Description__c, Total_Estimated_Cost__c,
                              Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c, Number_of_Copies__c, 
                              Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c, Number_of_Calls__c, Number_of_Leads__c,
                              Number_of_Attendees__c, Number_of_Unique_Views__c, Number_of_Emails_Sent__c, Number_of_Contacts__c, 
                              Estimated_Revenue__c, Annual_Sales_Quota__c, Estimated_Open_Emails__c,Is_Record_Locked__c, 
                              Estimated_Cost_per_Copy__c, Estimated_Cost_per_Recipient__c, Estimated_Cost_per_Visitor__c, Estimated_Cost_per_Sale__c,
                              Estimated_Close_Rate__c, Estimated_Cost_per_Lead__c, Estimated_Response_Rate__c, Estimated_Cost_per_Attendees__c,
                              Estimated_Cost_per_View__c, Estimated_Email_Open_Rate__c, Estimated_Bounce_Back_Success_Rate__c, Estimated_ROI__c,
                              Estimated_Cost_to_Revenue__c, Estimated_Sales_Incentive_Rate__c, Approved_Date__c, Estimated_Number_of_Responses__c,
                              Revenue_Generated__c, Number_of_Open_Opportunities__c, Number_of_Net_New_Customers__c, Requester_Name__r.Name,CAM__r.Name,
                              Estimated_New_Leads__c,Estimated_Opportunity__c,Estimated_Existing_Leads__c,Estimated_Interactions__c,Business_Plan__c,
                              (SELECT Id, Name, ContentType,CreatedDate, LastModifiedDate FROM Attachments), 
                              (Select Id,Name,Pre_Approval__c,Claim__c,Pre_Approval_Document_Type__c,Proof_of_Performance_Document_Type__c,Attachment_ID__c FROM Files__r)
                              from SFDC_MDF__c 
                              where Id = : recId];
        
        List<SFDC_MDF_Claim__c> mdfClaimList = [SELECT  Id, Name,Status__c, Actual_Number_of_Copies__c, Actual_Circulation__c, Actual_Number_of_Unique_Site_Visitors__c,
                                                Actual_Number_of_Sales__c, Actual_Number_of_Calls__c, Numbers_of_Leads__c, Actual_Number_of_Attendees__c, 
                                                Actual_Number_of_Unique_Views__c, Actual_Number_of_Emails_Sent__c, Actual_Number_of_Contacts__c, Actual_Revenue__c,
                                                Actual_Annual_Sales_Quota__c, Actual_Open_Emails__c, Actual_Number_of_Responses__c, Number_of_CTA_Click_through__c,
                                                Actual_Sales__c, Actual_Cost_per_Copy__c, Actual_Cost_per_Recipient__c, Actual_Cost_per_Visitor__c, Actual_Cost_per_Sale__c,
                                                Actual_Close_Rate__c, Actual_Cost_per_Lead__c, Actual_Response_Rate__c, Actual_Cost_per_Attendees__c, Actual_Cost_per_View__c,
                                                Actual_Email_Open_Rate__c, Actual_Bounce_Back_Success_Rate__c, Actual_ROI__c, Actual_Cost_to_Revenue__c, 
                                                Actual_Sales_Incentive_Rate__c, Actual_Call_to_Action_Conversion_Rate__c, Actual_Visitor_to_lead_Conversion_Rate__c,
                                                Actual_Percentage_of_Quota_Attained__c, Claim_Submission_Date__c, Approved_Date__c,Transaction_Reference__c,
                                                Actual_New_Leads__c,Actual_Opportunity__c,Actual_Existing_Leads__c,Actual_Interactions__c,
                                                (SELECT Id, Name, ContentType,CreatedDate, LastModifiedDate FROM Attachments),
                                                (Select Id,Name,Pre_Approval__c,Claim__c,Pre_Approval_Document_Type__c,Proof_of_Performance_Document_Type__c,Attachment_ID__c FROM Files__r)
                                                FROM SFDC_MDF_Claim__c 
                                                WHERE Fund_Request__c =: recId];
        
        List<MDF_Expense_Detail__c> mdfExepeseList = [ SELECT Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c 
                                                      FROM MDF_Expense_Detail__c WHERE MDF_Request__c =: recId];
        
        List<File__c> lstFile = new List<File__c>();
        
        if(!objMDF.Files__r.isEmpty())
            lstFile.addAll(objMDF.Files__r);
        
        if(!mdfClaimList.isEmpty() && !mdfClaimList[0].Files__r.isEmpty())
            lstFile.addAll(mdfClaimList[0].Files__r);
        
        MDFDetailInfo objMdfDetailInfo = new MDFDetailInfo();
        objMdfDetailInfo.objMDFRequest = objMDF;
        objMdfDetailInfo.lstMDFExpense = mdfExepeseList;
        objMdfDetailInfo.objMDFClaim = !mdfClaimList.isEmpty() ? mdfClaimList[0] : null;
        objMdfDetailInfo.lstSupportingAttachment = lstFile;
        
        objMdfDetailInfo.lstPreApprovalDoc = new List<String>();
        objMdfDetailInfo.lstProofOfPerformanceDoc  = new List<String>();
        Schema.DescribeFieldResult fieldResult = File__c.Pre_Approval_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        objMdfDetailInfo.lstPreApprovalDoc.add('--None--');    
        for( Schema.PicklistEntry f : ple)
        {
            objMdfDetailInfo.lstPreApprovalDoc.add(f.getValue());
        }   
        
        Schema.DescribeFieldResult fieldResult2 = File__c.Proof_of_Performance_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        objMdfDetailInfo.lstProofOfPerformanceDoc.add('--None--');
        for(Schema.PicklistEntry f : ple2)
        {
            objMdfDetailInfo.lstProofOfPerformanceDoc.add(f.getValue());
        }    
        
        return objMdfDetailInfo;
        
    }
    
    @AuraEnabled
    public static MDFDetailInfo submitMdfRequestForApproval(SFDC_MDF__c objRequest, String comment) 
    {
        String approvalStateMessage = '';
        Savepoint sp = Database.setSavepoint();  
        objRequest.Is_Record_Locked__c = true;
        objRequest.Request_Submission_Date__c = System.now();
        try 
        {
            update objRequest;
            Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments(comment);
            req.setObjectId(objRequest.Id);
            
            // submit the approval request for processing
            Approval.ProcessResult result = Approval.process(req);
            if (result == null || result.isSuccess() != true) 
            {
                Database.rollback(sp);
                approvalStateMessage = 'Please contact your Account Owner for submitting this request.';
            }
        } 
        catch (Exception ex) 
        {
            Database.rollback(sp);
            approvalStateMessage =  'Please contact your Account Owner for submitting this request.';
        }
        
        if(String.isBlank(approvalStateMessage))
            approvalStateMessage = 'Your Request has been submitted';
        
        MDFDetailInfo objInfo = new MDFDetailInfo();
        objInfo.approvalMessage = approvalStateMessage;
        objInfo.objMDFRequest = [Select Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c,
                                 Requester_Name__c, Other_Vendors_Represented__c, Activity_Description__c, Total_Estimated_Cost__c,
                                 Total_NCR_Estimated_Participation__c,Total_Actual_Cost__c,Total_NCR_Approved__c, Number_of_Copies__c, 
                                 Circulation__c, Number_of_Unique_Site_Visitors__c, Number_of_Sales__c, Number_of_Calls__c, Number_of_Leads__c,
                                 Number_of_Attendees__c, Number_of_Unique_Views__c, Number_of_Emails_Sent__c, Number_of_Contacts__c, 
                                 Estimated_Revenue__c, Annual_Sales_Quota__c, Estimated_Open_Emails__c,Is_Record_Locked__c, 
                                 Estimated_Cost_per_Copy__c, Estimated_Cost_per_Recipient__c, Estimated_Cost_per_Visitor__c, Estimated_Cost_per_Sale__c,
                                 Estimated_Close_Rate__c, Estimated_Cost_per_Lead__c, Estimated_Response_Rate__c, Estimated_Cost_per_Attendees__c,
                                 Estimated_Cost_per_View__c, Estimated_Email_Open_Rate__c, Estimated_Bounce_Back_Success_Rate__c, Estimated_ROI__c,
                                 Estimated_Cost_to_Revenue__c, Estimated_Sales_Incentive_Rate__c, Approved_Date__c, Estimated_Number_of_Responses__c,
                                 Revenue_Generated__c, Number_of_Open_Opportunities__c, Number_of_Net_New_Customers__c,
                                 (SELECT Id, Name, ContentType,CreatedDate, LastModifiedDate FROM Attachments), Requester_Name__r.Name,CAM__r.Name,
                                 (Select Id,Name,Pre_Approval__c,Claim__c,Pre_Approval_Document_Type__c,Proof_of_Performance_Document_Type__c,Attachment_ID__c FROM Files__r)
                                 from SFDC_MDF__c where Id = : objRequest.Id];
        return objInfo;
    }
    
    @AuraEnabled
    public static MDFDetailInfo submitMdfClaimForApproval(SFDC_MDF_Claim__c mdfClaim,  String comment) 
    {
        String approvalStateMessage = '';
        Savepoint sp = Database.setSavepoint();
        mdfClaim.Status__c = 'Submitted';
        
        try 
        {
            update mdfClaim;
            Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comment);
            req.setObjectId(mdfClaim.Id);
            Approval.ProcessResult result = Approval.process(req);
            if(result.isSuccess() != true) {
                approvalStateMessage = 'Claim could not submit for Approval. Please contact to System Administrator.';
                Database.rollback(sp);
            }
        } 
        catch (Exception ex) {
            Database.rollback(sp);
            approvalStateMessage =  'Request could not for Approval. Please contact to System Administrator.';
        }
        approvalStateMessage =  'Claim has been submitted successfully.';
        
        MDFDetailInfo objInfo = new MDFDetailInfo();
        objInfo.approvalMessage = approvalStateMessage;
        objInfo.objMDFClaim = [SELECT Id, Name,Status__c, Actual_Number_of_Copies__c, Actual_Circulation__c, Actual_Number_of_Unique_Site_Visitors__c,
                               Actual_Number_of_Sales__c, Actual_Number_of_Calls__c, Numbers_of_Leads__c, Actual_Number_of_Attendees__c, 
                               Actual_Number_of_Unique_Views__c, Actual_Number_of_Emails_Sent__c, Actual_Number_of_Contacts__c, Actual_Revenue__c,
                               Actual_Annual_Sales_Quota__c, Actual_Open_Emails__c, Actual_Number_of_Responses__c, Number_of_CTA_Click_through__c,
                               Actual_Sales__c, Actual_Cost_per_Copy__c, Actual_Cost_per_Recipient__c, Actual_Cost_per_Visitor__c, Actual_Cost_per_Sale__c,
                               Actual_Close_Rate__c, Actual_Cost_per_Lead__c, Actual_Response_Rate__c, Actual_Cost_per_Attendees__c, Actual_Cost_per_View__c,
                               Actual_Email_Open_Rate__c, Actual_Bounce_Back_Success_Rate__c, Actual_ROI__c, Actual_Cost_to_Revenue__c, 
                               Actual_Sales_Incentive_Rate__c, Actual_Call_to_Action_Conversion_Rate__c, Actual_Visitor_to_lead_Conversion_Rate__c,
                               Actual_Percentage_of_Quota_Attained__c, Claim_Submission_Date__c, Approved_Date__c,Transaction_Reference__c,
                               Actual_New_Leads__c,Actual_Opportunity__c,Actual_Existing_Leads__c,Actual_Interactions__c
                               FROM SFDC_MDF_Claim__c 
                               WHERE Id =: mdfClaim.Id ];
        return objInfo;
    }
    
    @AuraEnabled
    public static Id saveChunk(String parentType, String preApprovalType, String description, Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        /*  
check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
next time (in else) we are call the appentTOFile() method
for update the attachment with reamins chunks 
*/  
        if (fileId == '') 
        {
            fileId = saveTheFile(parentType, preApprovalType, description,parentId, fileName, base64Data, contentType);
        } 
        else 
        {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(String parentType, String preApprovalType, String description,Id parentId, String fileName, String base64Data, String contentType) 
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
            File__c objFile = new File__c();
            objFile.Name = fileName ;
            
            objFile.Attachment_ID__c = oAttachment.Id;
            objFile.File_Description__c = description;
            if(parentType == 'Fund Request')
            {
                objFile.Pre_Approval_Document_Type__c = preApprovalType;
                objFile.Fund_Request__c = parentId; 
                objFile.Pre_Approval__c = true;
            }
            if(parentType == 'Fund Claim')
            {
                objFile.Proof_of_Performance_Document_Type__c = preApprovalType;
                objFile.Fund_Claim__c = parentId; 
                objFile.Claim__c = true;
            }
            
            Database.insert(objFile);
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
    
    @AuraEnabled
    public Static List<File__c> preAppFileList(String requestId)
    {
        List<File__c> lstFile =  [SELECT Id, Name, Claim__c, Pre_Approval__c, Pre_Approval_Document_Type__c, Proof_of_Performance_Document_Type__c, Attachment_ID__c, Fund_Claim__c, CP_Is_Cloned__c 
                                  FROM File__c WHERE Fund_Request__c =: requestId AND CP_Is_Cloned__c =: false];
        System.debug('--------------lstFile----------------'+lstFile.size());
        
        return lstFile;
    }
    
    @AuraEnabled
    public Static void updatePreAppFileList(List<File__c> lstFile, String claimId) 
    {
        System.debug('---------------lstFile---------------'+lstFile.size());
        /* 
1. if user want to use Pre Approval Document as Claim document.
a. Create Clone for the Attachment
b. Create Clone for the file record.
*/
        List<File__c> filesToUpdateList = new List<File__c>();
        Set<Id> setAttachmentId = new Set<Id>();
        Map<Id, Attachment> preAprvlFlIdVsClmAttchMap = new Map<Id, Attachment>(); // Pre Approval file and Claim attachment Map 
        Map<Id, File__c> preAprvlFlIdVsClmFlMap = new Map<Id, File__c>(); // Pre Approval file and Claim File Map 
        for(File__c objFile : lstFile)
        {
            setAttachmentId.add(objFile.Attachment_ID__c);
        }
        
        Map<Id, Attachment> mapIdToAttachment = new Map<Id, Attachment>([SELECT Id, Name, Body FROM Attachment WHERE ID IN: setAttachmentId]);
        
        for (File__c file : lstFile) 
        {
            if(file.Claim__c)
            {
               Attachment objExistingAttachment = mapIdToAttachment.get(file.Attachment_ID__c);
                
                if(objExistingAttachment != null) 
                {
                    Attachment newAttchmnt = new Attachment(Name = objExistingAttachment.Name + '-claim', Body = objExistingAttachment.Body, ParentId = claimId);
                    preAprvlFlIdVsClmAttchMap.put(file.Id, newAttchmnt);
                    
                    File__c newFile = new File__c(Name = file.Name + '-claim', Fund_Claim__c = claimId, Claim__c = true);
                    preAprvlFlIdVsClmFlMap.put(file.Id, newFile);
                }
            }
        }
        
        if(!preAprvlFlIdVsClmAttchMap.isEmpty()) {
            Database.SaveResult[] saveResults = Database.Insert(preAprvlFlIdVsClmAttchMap.values());
            
            for(Id fileId : preAprvlFlIdVsClmAttchMap.keySet()) {
           		Attachment attch = preAprvlFlIdVsClmAttchMap.get(fileId); 
                
                if(attch != NULL && attch.Id != NULL) {
                	File__c claimFile =  preAprvlFlIdVsClmFlMap.get(fileId);
                    claimFile.put('Attachment_ID__c', attch.Id); 
                }
            }
            
            if(!preAprvlFlIdVsClmFlMap.isEmpty())  Database.Insert(preAprvlFlIdVsClmFlMap.values());
        }
        
        for (File__c file : lstFile) 
        {
        	File__c claimFile = preAprvlFlIdVsClmFlMap.get(file.Id);
            
            if(claimFile != null && claimFile.Id != null) {
           		file.CP_Is_Cloned__c = true;
                filesToUpdateList.add(file);	    
            }
        }
        if (!filesToUpdateList.isEmpty()) { update filesToUpdateList;}  
        
    }
    @AuraEnabled
    public Static List<File__c> getRefreshedFiles(String requestId, String claimId) 
    {
        List<File__c> lstFile =  new List<File__c>();
        
        if(String.isNotBlank(requestId) && String.isNotBlank(claimId))
        {
            lstFile = [SELECT Id, Name, Claim__c, Pre_Approval__c, Attachment_ID__c, Fund_Claim__c, CP_Is_Cloned__c, Pre_Approval_Document_Type__c, Proof_of_Performance_Document_Type__c 
                       FROM File__c WHERE Fund_Request__c =: requestId or Fund_Claim__c =: claimId];
        }
        else if(String.isNotBlank(requestId) && String.isBlank(claimId))
        {
            lstFile = [SELECT Id, Name, Claim__c, Pre_Approval__c, Attachment_ID__c, Fund_Claim__c, CP_Is_Cloned__c, Pre_Approval_Document_Type__c, Proof_of_Performance_Document_Type__c
                       FROM File__c WHERE Fund_Request__c =: requestId];
        } 
        else if(String.isBlank(requestId) && String.isNotBlank(claimId))
        {
            lstFile = [SELECT Id, Name, Claim__c, Pre_Approval__c, Attachment_ID__c, Fund_Claim__c, CP_Is_Cloned__c,Pre_Approval_Document_Type__c, Proof_of_Performance_Document_Type__c
                       FROM File__c WHERE Fund_Claim__c =: claimId];
        } 
        System.debug('--------------lstFile----------------'+lstFile.size());
        
        return lstFile;
    }
    
    
    @AuraEnabled
    public Static String deletePreApprovalDoc(String fileRecordId, String mdfStatus) 
    {
        try 
        {
            //Find out the stages where user is allowed to delete pre approval doc    
            Set<String> stages; 
            PreApprovalDocCRUDvalidater__c permittedStages = PreApprovalDocCRUDvalidater__c.getInstance(UserInfo.getProfileId());
            
            //if custom setting is available for the current user profile find in what stages he allowe to delete the doc
            if (permittedStages != null) 
            {
                stages = new Set<String>(permittedStages.Stages__c.split(';'));
                //if no stages availabe check for OWD
                if (stages.isEmpty()) 
                {
                    permittedStages = PreApprovalDocCRUDvalidater__c.getInstance();
                    stages = new Set<String>(permittedStages.Stages__c.split(';'));
                }
            } 
            else 
            {
                //if setting is not defined for the loged in user profile use OWD setting
                permittedStages = PreApprovalDocCRUDvalidater__c.getInstance();
                stages = new Set<String>(permittedStages.Stages__c.split(';'));
            }
            
            //If stages is availabel either for the particular profile or OWD, perform required process
            if(stages != null && stages.size() > 0) 
            {
                if(stages.contains(mdfStatus)) 
                {
                    List<File__c> deleteFileList = [SELECT Id FROM File__c WHERE Id =: fileRecordId];
                    if(!deleteFileList.isEmpty()) 
                    {
                        delete deleteFileList;
                        return 'Success';
                    }
                }
            } else {
                return 'You are not allowed to delete document once reqest is '+ mdfStatus;
            }
            
            //If custom setting is not availabel for logedin user profile and OWD
            //OR custom setting is availabe but stages in not defined in any custom setting delete the record
            List<File__c> deleteFileList = [SELECT Id FROM File__c WHERE Id =: fileRecordId];
            if (!deleteFileList.isEmpty()) 
            {
                delete deleteFileList;
                return 'Success';
            }
            return 'You are not allowed to delete document once reqest is '+ mdfStatus;
        } 
        catch(Exception ex) 
        {
            System.debug(ex.getMessage());
            return 'File could not delete. Please contact to System Administrator.';
        }
    }
    
    public static void updateFileProcess(File__c objFile, String fileName, String base64Data, String contentType, String parentType, String fileDocValue) 
    {
        File__c objUpdateFile = new File__c(Id = objFile.Id);
        objUpdateFile.Name = fileName;
        if(parentType == 'Request')
            objUpdateFile.Pre_Approval_Document_Type__c = fileDocValue;
        else if(parentType == 'Claim')  
            objUpdateFile.Proof_of_Performance_Document_Type__c = fileDocValue;
        
        update objUpdateFile;
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment objAttachment = new Attachment(Id = objFile.Attachment_ID__c);
        objAttachment.Name = fileName;
        objAttachment.Body = EncodingUtil.base64Decode(base64Data);
        objAttachment.ContentType = contentType;
        
        Database.UpsertResult  result = Database.upsert(objAttachment);
    }
    
    @AuraEnabled
    public static Id saveEditChunk(File__c objFile, String attachmentId, String fileName, String base64Data, String contentType, String parentType, String fileDocValue) 
    {
        System.debug('----------objFile-----'+ objFile);
        System.debug('--------attachmentId-------'+ attachmentId);
        System.debug('--------fileName-------'+ fileName);
        System.debug('-------contentType--------'+ contentType);
        System.debug('--------parentType-------'+parentType );
        System.debug('---------fileDocValue------'+ fileDocValue);
        if(String.isBlank(attachmentId)) 
        {
            updateFileProcess(objFile, fileName, base64Data, contentType, parentType, fileDocValue);
        } 
        else 
        {
            appendToFile(attachmentId, base64Data);
        }
        System.debug('------------Id.valueOf(objFile.Attachment_Id__c)-------'+Id.valueOf(objFile.Attachment_Id__c));
        return Id.valueOf(objFile.Attachment_Id__c);
    }
    
    @AuraEnabled
    public static void saveActivityResult(SFDC_MDF__c objMDFRequest)
    {
        update objMDFRequest;
    }
    public class MDFDetailInfo
    {
        @AuraEnabled
        public SFDC_MDF__c objMDFRequest;
        
        @AuraEnabled
        public SFDC_MDF_Claim__c objMDFClaim;
        
        @AuraEnabled
        public List<MDF_Expense_Detail__c> lstMDFExpense;
        
        @AuraEnabled
        public List<File__c> lstSupportingAttachment;
        
        @AuraEnabled
        public String approvalMessage;
        
        @AuraEnabled
        public List<String> lstPreApprovalDoc;
        
        @AuraEnabled
        public List<String> lstProofOfPerformanceDoc;
        
    }  
}