public with sharing class NewMDFRequestCmpController 
{
    
    @AuraEnabled
    public static CloneMDFDetail getCloneMDFDetail(String mdfRecordId)
    {
        CloneMDFDetail objCloneMDFDetail= new CloneMDFDetail();
        
        List<SFDC_MDF__c> mdfRequestList = [Select Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c,
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
                                            Estimated_New_Leads__c,Estimated_Opportunity__c,Estimated_Existing_Leads__c,Estimated_Interactions__c,Business_Plan__c
                                            FROM SFDC_MDF__c WHERE Id =: mdfRecordId LIMIT 1];
        
        if(mdfRequestList.size() > 0) 
        {
            // clone MDF Request
            objCloneMDFDetail.currentActivityName = mdfRequestList[0].Name;
            SFDC_MDF__c mdfRequest = mdfRequestList[0].clone(false,true);
            mdfRequest.Status__c = 'Request Created';
            mdfRequest.name = '';
            mdfRequest.Request_Submission_Date__c=null;
            mdfRequest.Approved_Date__c = null;
            
            
            objCloneMDFDetail.objCloneMDFRequest = mdfRequest;
            
            // clone expense table
            for(MDF_Expense_Detail__c objExpense : [SELECT Actvity__c, Estimated_Cost__c, MDF_Request__c 
                                                    FROM MDF_Expense_Detail__c WHERE MDF_Request__c =: mdfRecordId])
            {   
                objCloneMDFDetail.lstCloneExepeseList.add(objExpense.clone(false,true));
            }
        }
        
        objCloneMDFDetail.activityContact = UserInfo.getName();
        
        Schema.DescribeFieldResult fieldResult = SFDC_MDF__c.Activity_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            objCloneMDFDetail.activityOptions.add(f.getValue());
        }   
        
        Schema.DescribeFieldResult fieldResult2 = SFDC_MDF__c.Other_Vendors_Represented__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple2)
        {
            objCloneMDFDetail.vendors.add(f.getValue());
        }    
        
        return objCloneMDFDetail;
    }
    
    @AuraEnabled
    public static CloneMDFDetail getEditMDFDetail(String mdfRecordId)
    {
        CloneMDFDetail objEditMDFDetail= new CloneMDFDetail();
        
        List<SFDC_MDF__c> mdfRequestList = [Select Id, Name,CAM__c,Request_Submission_Date__c,Status__c, Activity_Date__c, Activity_Type__c, End_Date__c,
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
                                            Estimated_New_Leads__c,Estimated_Opportunity__c,Estimated_Existing_Leads__c,Estimated_Interactions__c,Business_Plan__c
                                            FROM SFDC_MDF__c WHERE Id =: mdfRecordId LIMIT 1];
        
        if(mdfRequestList.size() > 0) 
        {
            objEditMDFDetail.objCloneMDFRequest = mdfRequestList[0];
            
            // clone expense table
            for(MDF_Expense_Detail__c objExpense : [SELECT Actvity__c, Estimated_Cost__c, NCR_Estimated_Participation__c, Actual_Cost__c, NCR_Approved__c 
                                                    FROM MDF_Expense_Detail__c WHERE MDF_Request__c =: mdfRecordId])
            {   
                objEditMDFDetail.lstCloneExepeseList.add(objExpense);
            }
        }
        
        objEditMDFDetail.activityContact = UserInfo.getName();
        
        Schema.DescribeFieldResult fieldResult = SFDC_MDF__c.Activity_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            objEditMDFDetail.activityOptions.add(f.getValue());
        }   
        
        Schema.DescribeFieldResult fieldResult2 = SFDC_MDF__c.Other_Vendors_Represented__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple2)
        {
            objEditMDFDetail.vendors.add(f.getValue());
        }    
        
        return objEditMDFDetail;
    }
    
    @AuraEnabled
    public static String saveEditMDFDetail(List<MDF_Expense_Detail__c> lstExpense, SFDC_MDF__c objRequest, String strActivity, String strVendors, List<String> lstExpenseIdForDelete)
    {
        objRequest.Activity_Type__c = strActivity;
        objRequest.Other_Vendors_Represented__c = strVendors;
        update objRequest;
        System.debug('--------lstExpenseIdForDelete-----------------'+lstExpenseIdForDelete);
        List<MDF_Expense_Detail__c> deleteExpDtls = new List<MDF_Expense_Detail__c>();
        if(lstExpenseIdForDelete != null && !lstExpenseIdForDelete.isEmpty())
        {
            for(String strExpId : lstExpenseIdForDelete)
            {
                if(String.isNotBlank(strExpId))
                {
                    System.debug('--------strExpId-----------------'+strExpId);
                    MDF_Expense_Detail__c objExpense = new MDF_Expense_Detail__c(Id = strExpId);
                    deleteExpDtls.add(objExpense);
                    //delete objExpense; //commented to avoid DML statement in loop
                }
            }
        }
        
        if (!deleteExpDtls.isEmpty()) {
            delete deleteExpDtls;
        }
        
        List<MDF_Expense_Detail__c> lstUpsertExpense = new List<MDF_Expense_Detail__c>();
        for(MDF_Expense_Detail__c objED : lstExpense)
        {
            objED.MDF_Request__c = objRequest.Id;
            lstUpsertExpense.add(objED);
        }
        
        if(!lstUpsertExpense.isEmpty())
            upsert lstUpsertExpense;
        System.debug('--------objRequest.Id-------------------'+objRequest.Id);
        return objRequest.Id;
    }
    
    @AuraEnabled
    public static String saveCloneMDFDetail( List<MDF_Expense_Detail__c> lstExpense,SFDC_MDF__c objRequest,String strActivity, String strVendors)
    {
        System.debug('--------objRequest.Id-------------------');
        objRequest.Activity_Type__c = strActivity;
        objRequest.Other_Vendors_Represented__c = strVendors;
        objRequest.Is_Record_Locked__c = false;
        objRequest.Requester_Name__c = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        insert objRequest;
        
        List<MDF_Expense_Detail__c> lstInsertExpense = new List<MDF_Expense_Detail__c>();
        /*List<MDF_Expense_Detail__c> lstExpense,*/
        for(MDF_Expense_Detail__c objED : lstExpense)
        {
            objED.MDF_Request__c = objRequest.Id;
            lstInsertExpense.add(objED);
        }
        
        if(!lstInsertExpense.isEmpty())
            insert lstInsertExpense;
        
        System.debug('--------objRequest.Id-------------------'+objRequest.Id);
        return objRequest.Id;
        //return 'Hello success';
    }
    
    @AuraEnabled
    public static String saveMDFDetail(List<MDF_Expense_Detail__c> lstExpense, SFDC_MDF__c objRequest, String strActivity, String strVendors)
    {
        System.debug('--------lstExpense-------------------'+lstExpense);
        System.debug('--------objRequest-------------------'+objRequest);
        System.debug('--------strActivity-------------------'+strActivity);
        System.debug('--------strVendors-------------------'+strVendors);
        objRequest.Activity_Type__c = strActivity;
        objRequest.Other_Vendors_Represented__c = strVendors;
        objRequest.Requester_Name__c = [SELECT Id,ContactId,AccountId,FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        insert objRequest;
        
        List<MDF_Expense_Detail__c> lstInsertExpense = new List<MDF_Expense_Detail__c>();
        for(MDF_Expense_Detail__c objED : lstExpense)
        {
            objED.MDF_Request__c = objRequest.Id;
            lstInsertExpense.add(objED);
        }
        
        if(!lstInsertExpense.isEmpty())
            insert lstInsertExpense;
        
        System.debug('--------objRequest.Id-------------------'+objRequest.Id);
        return objRequest.Id;
    }
    
    @AuraEnabled
    public static PicklistDetail getActivitiesAndVendors()
    {
        PicklistDetail objPicklistDetail = new PicklistDetail();
        objPicklistDetail.activityContact = UserInfo.getName();
        
        Schema.DescribeFieldResult fieldResult = SFDC_MDF__c.Activity_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            objPicklistDetail.activityOptions.add(f.getValue());
        }   
        
        Schema.DescribeFieldResult fieldResult2 = SFDC_MDF__c.Other_Vendors_Represented__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple2)
        {
            objPicklistDetail.vendors.add(f.getValue());
        }    
        
        return objPicklistDetail;   
    }
    
    public class PicklistDetail
    {
        @AuraEnabled
        public List<String> activityOptions;
        
        @AuraEnabled
        public List<String> vendors;
        
        @AuraEnabled
        public String activityContact;
        
        
        public PicklistDetail()
        {
            activityOptions = new List<String>();
            activityOptions.add('---None---');
            vendors = new List<String>();
        }
    }
    
    public class CloneMDFDetail
    {
        @AuraEnabled
        public SFDC_MDF__c objCloneMDFRequest;
        
        @AuraEnabled
        public List<MDF_Expense_Detail__c> lstCloneExepeseList;
        
        @AuraEnabled
        public List<String> activityOptions;
        
        @AuraEnabled
        public List<String> vendors;
        
        @AuraEnabled
        public String activityContact;
        
        @AuraEnabled
        public String currentActivityName;
        
        public CloneMDFDetail()
        {
            objCloneMDFRequest = new SFDC_MDF__c();
            activityOptions = new List<String>();
            vendors = new List<String>();
            lstCloneExepeseList = new List<MDF_Expense_Detail__c>();
        }
    }
}