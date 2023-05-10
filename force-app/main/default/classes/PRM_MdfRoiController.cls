public with sharing class PRM_MdfRoiController { 
    /* Created By : Ritesh Kumar*/

 
    /* -Method Name : getFundClaimMap. 
    *  -Method parameters : There is no parameter are required to call this method.
    *  -Method Return Type : Method return type is Map where Key Is ID of fund request and Value is Fund claim object. (Map<Id,SFDC_MDF_Claim__c>). 
    *  -Method Description : This method is called By wire service(LWC) and used to dilplay approved Fund Claims.  
    */    
    @AuraEnabled(cacheable=true)
    public static Map<Id,SFDC_MDF_Claim__c> getFundClaimMap(){ 

       // Fund Claim List (fundClaimList) : This list hold all the approved fund claims.
       List<SFDC_MDF_Claim__c> fundClaimList = [SELECT Id, Name, Status__c, Fund_Request__c, Fund_Request__r.Name,Fund_Request__r.Request_ID__c, Fund_Request__r.Status__c ,CreatedDate 
            FROM SFDC_MDF_Claim__c 
            WHERE Status__c = 'Approved' ORDER BY CreatedDate DESC];

       Map<Id,SFDC_MDF_Claim__c> fundClaimMap = new Map<Id,SFDC_MDF_Claim__c>();

       /* Mapping Fund Request to fund claim. we are doing one to one maping because for 
          now we have 1:1 relationship between fund request and fund claim.
       */
       for(SFDC_MDF_Claim__c fundClaimRecord : fundClaimList){
           if(fundClaimRecord.Fund_Request__c != null){
                fundClaimMap.put(fundClaimRecord.Fund_Request__c, fundClaimRecord);
           }
           
       }      

       // Returning Fund claim map.
       return fundClaimMap;
       
    }


    /* -Method Name : mdfDetailRecord.
    *  -Method parameters : One parametes are required. that is fund request id (fundRequestId). 
    *  -Method Return Type : Method return Wrapper Class.  Name of Wrapper Class MDFDetailInformation.
    *  -Method Description : This method is called By imperative method(LWC) and used to dilplay Fund request and there related records.  
    */        
    @AuraEnabled
    public static MDFDetailInformation mdfDetailRecord (String fundRequestId){
        
        /* Get fund reuest on the baese of fund requestId. 
           Fund request record contains all the information realted to fund request  and also get the attachment for the same.
         */
        SFDC_MDF__c fundRequestRecord = [Select Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c,
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
                              where Id = : fundRequestId];

         /* Get fund claim list on the baese of fund requestId. 
           fund Claim Record  contains all the information realted to fund request  and also get the attachment for the same.
         */
       SFDC_MDF_Claim__c fundClaimRecord = [SELECT  Id, Name,Status__c, Actual_Number_of_Copies__c, Actual_Circulation__c, Actual_Number_of_Unique_Site_Visitors__c,
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
                                                WHERE Fund_Request__c =: fundRequestId LIMIT 1];
 
        // Filling the Wrapper class
        List<File__c> fileList = new List<File__c>();
        MDFDetailInformation mdfDetail = new MDFDetailInformation();
 
       if(!fundRequestRecord.Files__r.isEmpty()){
             fileList.addAll(fundRequestRecord.Files__r);
        }
        
        if(fundClaimRecord != null){

            mdfDetail.fundClaim = fundClaimRecord;

            if(!fundClaimRecord.Files__r.isEmpty()){
                fileList.addAll(fundClaimRecord.Files__r);
            }
        }
        
        if(fundRequestRecord != null){
            mdfDetail.fundRequest = fundRequestRecord;
        }

        if(fileList != null){            
            mdfDetail.supportingAttachments = fileList;
        }

        return mdfDetail; 
    }

    /* -Method Name : savePartnerFundROI.
    *  -Method parameters : 4 parametes are required.
                                - fundRequest = Fund request Id
                                - fundClaim = Fund claim Id
                                - currentRevenueEarned = Current Revennue Earned Entered by user.
                                - partnerFundROIId : Partner Fund ROI Id.
    *  -Method Return Type : Method return Partner Fund ROI Object.
    *  -Method Description : This method is called By imperative method(LWC) and used save and updated ROI.  
    */
    @AuraEnabled
    public static Partner_Fund_ROI__c savePartnerFundROI(String fundRequest, String fundClaim, String currentRevenueEarned, String partnerFundROIId){
        System.debug('======= savePartnerFundROI ====');
        Partner_Fund_ROI__c partnerFundROIRecord = new Partner_Fund_ROI__c();

        //checking the Id if id is There we perform Update esle we create new record.
        if(partnerFundROIId != null && partnerFundROIId != 'null' ){
            partnerFundROIRecord.Id = partnerFundROIId;
        }


        if(fundRequest != null ){
            partnerFundROIRecord.Fund_Request__c = fundRequest;
        }

        if(fundClaim != null){
            partnerFundROIRecord.Fund_Claim__c = fundClaim;
        }

        if(currentRevenueEarned != null){
           //partnerFundROIRecord.Current_Revenue_earned__c = Integer.valueOf(currentRevenueEarned);
            partnerFundROIRecord.Current_Revenue_earned__c =Decimal.valueOf(currentRevenueEarned);
        }

        if(partnerFundROIRecord != null){            
            upsert partnerFundROIRecord;
        }

        
        return partnerFundROIRecord;
    }

    /* -Method Name : roiSubmitForApproval.
    *  -Method parameters : Two parametes are required.
                                - idParent = partner Fund ROI ID
                                - comment = User comments.
    *  -Method Return Type : Return typre is  null.
    *  -Method Description : This method is called By imperative method(LWC) and used submint the ROI for approval.  
    */    
    @AuraEnabled
    public static String roiSubmitForApproval(Id idParent , String comment) {
        Savepoint sp = Database.setSavepoint();
        try{        
            Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comment);
            if(idParent != null){
                req.setObjectId(idParent);
            }             
            Approval.ProcessResult result = Approval.process(req);
        } 
        catch (Exception ex) {
            Database.rollback(sp);
        }
        return idParent;
    }

    /* -Method Name : getPartnerFundROI.
    *  -Method parameters :  One parameter are required to call this method.
                                -partnerFundRoiId = Partner Fund ROI Id.
    *  -Method Return Type : Return type is Partner Fund ROI Object. 
    *  -Method Description : This method is called By imperative method(LWC) and used to get Inforamtion about single ROI.  
    */
    @AuraEnabled
    public static Partner_Fund_ROI__c getPartnerFundROI(String partnerFundRoiId){
        Partner_Fund_ROI__c partnerFundRoi = new Partner_Fund_ROI__c();
        if(partnerFundRoiId != '' ){
           partnerFundRoi = [SELECT Name, Fund_Claim__c, Fund_Claim__r.Name, Fund_Request__c,Fund_Request__r.Name, Status__c, Channel_Account_Manager__c, Partner_Contact__c, Current_Revenue_earned__c, Partner_Account__c, CreatedDate, Id 
            FROM Partner_Fund_ROI__c WHERE Id =: partnerFundRoiId] ;
        }        
        return partnerFundRoi;

    }

    /* -Method Name : deleteFundROIWithID.
    *  -Method parameters : There is no parameter are required to call this method.
    *  -Method Return Type : Return type is null. 
    *  -Method Description : This method is called By imperative method(LWC) and used to delete single information.  
    */
    @AuraEnabled
    public static void deleteFundROIWithID(String fundId){
        Partner_Fund_ROI__c partnerFundRoi = new Partner_Fund_ROI__c();
         if(fundId != '' ){
           partnerFundRoi = [SELECT Name, Fund_Claim__c, Fund_Claim__r.Name, Fund_Request__c,Fund_Request__r.Name, Status__c, Channel_Account_Manager__c, Partner_Contact__c, Current_Revenue_earned__c, Partner_Account__c, CreatedDate, Id,OwnerID 
            FROM Partner_Fund_ROI__c WHERE Id =: fundId] ;
        } 

        List<Attachment> attachmentList = [SELECT Body, Id, Description, OwnerId, CreatedById, ParentID FROM Attachment WHERE ParentID =:fundId];
        if(attachmentList.size() > 0){
            Delete attachmentList;
        }

        Delete partnerFundRoi;
    }
    
    /* -Method Name : deleteFundROIList.
    *  -Method parameters : One parameter are required to call this method.
                                -fundId = Partner Fund ROI Id.
    *  -Method Return Type : Return type is null. 
    *  -Method Description : This method is called By imperative method(LWC) and used to delete List of Inforamtion where status is == Drafted.  
    */
    @AuraEnabled
    public static void deleteFundROIList(){
       List<Partner_Fund_ROI__c> partnerFundRoiList = [SELECT Id, Name, Fund_Claim__c, Fund_Claim__r.Name, Fund_Request__c,Fund_Request__r.Name, Status__c, Channel_Account_Manager__c, Partner_Contact__c, Current_Revenue_earned__c, Partner_Account__c, CreatedDate, OwnerID
            FROM Partner_Fund_ROI__c WHERE  Status__c ='Drafted' ];

        if(partnerFundRoiList.size() > 0 ){
            Delete partnerFundRoiList;
        }
        
    }

     public class MDFDetailInformation{

        @AuraEnabled
        public SFDC_MDF__c fundRequest;
        
        @AuraEnabled
        public SFDC_MDF_Claim__c fundClaim;

        @AuraEnabled
        public List<File__c> supportingAttachments;

        @AuraEnabled
        public String submitResultStatus; 

        @AuraEnabled
        public List<Partner_Fund_ROI__c> PartnerFundROIList;
    }
}