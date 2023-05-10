@isTest

public class Controller_CAP_Approval_Process_Test {
    public static testMethod void PrimaryTest(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            CAP_Form__c c = new CAP_Form__c();
            c.VP_Submitter_Reports_To__c = '';
            c.Primary_NCR_Account_Executive__c = '';
            c.Industry__c = 'Retail';
            c.Customer_Name__c = '';
            c.Customer_Temperature__c ='';
            c.Country__c = 'AE';
            c.Is_there_a_Partner_Involved__c  = 'Yes';
            c.Project_Description__c = '';
            c.Products_Involved__c = '';
            c.Anticipated_Project_Start_Date__c = system.today();
            c.Current_Revenue_Impact__c = 1;
            c.Future_Revenue_Impact__c = 1;
            c.Financial_Of_Business__c = 1;
            
            insert c;
            system.assertEquals(1, c.Current_Revenue_Impact__c);
            
            Controller_CAP_Approval_Process.LoadCasedetails(c.id);
        }
        
        
    }
    /* ####################################################################################### */    
    
    public static testMethod void SubmissionTest(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            CAP_Form__c c = new CAP_Form__c();
            c.VP_Submitter_Reports_To__c = '';
            c.Primary_NCR_Account_Executive__c = '';
            c.Industry__c = 'Retail';
            c.Customer_Name__c = '';
            c.Customer_Temperature__c ='';
            c.Country__c = 'AE';
            c.Is_there_a_Partner_Involved__c  = 'Yes';
            c.Project_Description__c = '';
            c.Products_Involved__c = '';
            c.Anticipated_Project_Start_Date__c = system.today();
            c.Current_Revenue_Impact__c = 1;
            c.Future_Revenue_Impact__c = 1;
            c.Financial_Of_Business__c = 1;
            
            insert c;
            system.assert(c.id!=null);
            // Controller_CAP_Approval_Process.LoadCasedetails(c.id);
            
            Controller_CAP_Approval_Process.submitforapprovals(c.id);
            // generateapprove(c.id);
            Controller_CAP_Approval_Process.LoadCasedetails(c.id);
        }
    }
    
    /* ####################################################################################### */    
    
    public static testMethod void ApprovalCAPTest(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            CAP_Form__c c = new CAP_Form__c();
            c.VP_Submitter_Reports_To__c = '';
            c.Primary_NCR_Account_Executive__c = '';
            c.Industry__c = 'Retail';
            c.Customer_Name__c = '';
            c.Customer_Temperature__c ='';
            c.Country__c = 'AE';
            c.Is_there_a_Partner_Involved__c  = 'Yes';
            c.Project_Description__c = '';
            c.Products_Involved__c = '';
            c.Anticipated_Project_Start_Date__c = system.today();
            c.Current_Revenue_Impact__c = 1;
            c.Future_Revenue_Impact__c = 1;
            c.Financial_Of_Business__c = 1;
            
            insert c;
            // Controller_CAP_Approval_Process.LoadCasedetails(c.id);
            
            c.ApprovalRequestfront__c = 'Submitted';
            update c;
            // Controller_CAP_Approval_Process.submitforapprovals(c.id);
            // generateapprove(c.id);
            
            Controller_CAP_Approval_Process.approvecapss(c.id);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approved CAP');
            req.setAction('Approve');
            system.debug('###################req details:::'+req);
            // req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
            Id workItemId = getWorkItemId(c.id); 
            system.debug('###################workItemId details:::'+workItemId);
            if(workItemId == null)
            {
                c.addError('Error Occured in update');
            }
            
            else
            {
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
            }
            
            List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
            system.assert(groupMembers.size()!=null);

            //RecordType r =[Select id from recordtype where developername ='Partner'];
            Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Account a = new Account(      
                Account_Country_Code__c = 'EG',
                Active_Account__c = true,  
                Area__c= 'NORTHERN EUROPE',
                Master_Customer_Number__c = '1631Test',
                Name = 'Unit Test ' + System.now(),
                RecordTypeId = r,
                RoR_Update_Date_Time__c = System.now(),
                Industry = 'RETAIL:CHANNEL',
                /*CAP_Watch__c = 'CAP',*/
                account_region__c='INDIA'
            );
            system.runAs(TestRecordsFactory.getUser()) {
        	insert a;
        }
            
           // insert a;
            Contact con = new Contact();
            con.Accountid = a.id;
            con.LastName = 'test1';
            con.Email = 'test1@test.com';
            if(a.Subscription_Group__c == 'Digital Insight') {
                con.Additional_Relationships__c = 'Digital Insight';
            }
            insert con;

            Controller_CAP_Approval_Process.LoadCasedetails(c.id);
            
            
        }
    }
    
    /* ####################################################################################### */    
    
    public static testMethod void ApprovalCustTest(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            CAP_Form__c c = new CAP_Form__c();
            c.VP_Submitter_Reports_To__c = '';
            c.Primary_NCR_Account_Executive__c = '';
            c.Industry__c = 'Retail';
            c.Customer_Name__c = '';
            c.Customer_Temperature__c ='';
            c.Country__c = 'AE';
            c.Is_there_a_Partner_Involved__c  = 'Yes';
            c.Project_Description__c = '';
            c.Products_Involved__c = '';
            c.Anticipated_Project_Start_Date__c = system.today();
            c.Current_Revenue_Impact__c = 1;
            c.Future_Revenue_Impact__c = 1;
            c.Financial_Of_Business__c = 1;
            
            insert c;
            // Controller_CAP_Approval_Process.LoadCasedetails(c.id);
            
            c.ApprovalRequestfront__c = 'Submitted';
            update c;
            // Controller_CAP_Approval_Process.submitforapprovals(c.id);
            // generateapprove(c.id);
            Controller_CAP_Approval_Process.approvecustomerassurancess(c.id);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approved Customer Assurance');
            req.setAction('Approve');
            // req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
            Id workItemId = getWorkItemId(c.id); 
            
            if(workItemId == null)
            {
                c.addError('Error Occured in update');
            }
            else
            {
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
            }
            List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
            system.assert(groupMembers.size()!=null);
            //RecordType r =[Select id from recordtype where developername ='Partner'];
            Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Account a = new Account(      
                Account_Country_Code__c = 'EG',
                Active_Account__c = true,  
                Area__c= 'NORTHERN EUROPE',
                Master_Customer_Number__c = '1631Test',
                Name = 'Unit Test ' + System.now(),
                RecordTypeId = r,//'0127000000014kqAAA',
                RoR_Update_Date_Time__c = System.now(),
                Industry = 'RETAIL:CHANNEL',
                CAP_Watch__c = 'CAP',
                account_region__c='INDIA'
            );
            system.runAs(TestRecordsFactory.getUser()) {
        	insert a;
        }
           // insert a;
            Contact con = new Contact();
            con.Accountid = a.id;
            con.LastName = 'test1';
            con.Email = 'test1@test.com';
            if(a.Subscription_Group__c == 'Digital Insight') {
                con.Additional_Relationships__c = 'Digital Insight';
            }
            insert con;
            Controller_CAP_Approval_Process.LoadCasedetails(c.id);
        }
    }
    
    /* ####################################################################################### */    
    
    public static testMethod void ApprovalRejectTest(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            CAP_Form__c c = new CAP_Form__c();
            c.VP_Submitter_Reports_To__c = '';
            c.Primary_NCR_Account_Executive__c = '';
            c.Industry__c = 'Retail';
            c.Customer_Name__c = '';
            c.Customer_Temperature__c ='';
            c.Country__c = 'AE';
            c.Is_there_a_Partner_Involved__c  = 'Yes';
            c.Project_Description__c = '';
            c.Products_Involved__c = '';
            c.Anticipated_Project_Start_Date__c = system.today();
            c.Current_Revenue_Impact__c = 1;
            c.Future_Revenue_Impact__c = 1;
            c.Financial_Of_Business__c = 1;
            
            insert c;
            // Controller_CAP_Approval_Process.LoadCasedetails(c.id);
            system.assert(c.id!=null);
            c.ApprovalRequestfront__c = 'Submitted';
            update c;
            Controller_CAP_Approval_Process.rejectss(c.id);
            // generateapprove(c.id);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Request is Rejected');
            req.setAction('Reject');
            // req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
            Id workItemId = getWorkItemId(c.id); 
            
            if(workItemId == null)
            {
                c.addError('Error Occured in update');
            }
            else
            {
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
            }
            Controller_CAP_Approval_Process.LoadCasedetails(c.id);
        }
    }
    
    /* ####################################################################################### */    
    public static Id getWorkItemId(Id targetObjectId){            
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id 
                                                 From   ProcessInstanceWorkitem p
                                                 Where  p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
            system.debug('workItem.Id'+retVal);
        }
        return retVal;
        
    }
    /* ####################################################################################### */    
    
    public static void generateapprove(ID PSFRID)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(PSFRID);
        Approval.ProcessResult result = Approval.process(req);
    }
    /* ######################################################################################## */
     /* ####################################################################################### */    
    
    public static testMethod void triggertest(){
        CAP_Form__c c = new CAP_Form__c();
        c.VP_Submitter_Reports_To__c = '';
        c.Primary_NCR_Account_Executive__c = '';
        c.Industry__c = 'Retail';
        c.Customer_Name__c = '';
        c.Customer_Temperature__c ='';
        c.Country__c = 'AE';
        c.Is_there_a_Partner_Involved__c  = 'Yes';
        c.Project_Description__c = '';
        c.Products_Involved__c = '';
        c.Anticipated_Project_Start_Date__c = system.today();
        c.Current_Revenue_Impact__c = 1;
        c.Future_Revenue_Impact__c = 1;
        c.Financial_Of_Business__c = 1;
        
        insert c;
        // Controller_CAP_Approval_Process.LoadCasedetails(c.id);
        
        c.ApprovalRequestfront__c = 'Submitted';
        update c;
        system.assert(c.id!=null);
    }
    /* ##################################################################################3   */
      
    public static testMethod void ApprovalWatchList(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            CAP_Form__c c = new CAP_Form__c();
            c.VP_Submitter_Reports_To__c = '';
            c.Primary_NCR_Account_Executive__c = '';
            c.Industry__c = 'Retail';
            c.Customer_Name__c = '';
            c.Customer_Temperature__c ='';
            c.Country__c = 'AE';
            c.Is_there_a_Partner_Involved__c  = 'Yes';
            c.Project_Description__c = '';
            c.Products_Involved__c = '';
            c.Anticipated_Project_Start_Date__c = system.today();
            c.Current_Revenue_Impact__c = 1;
            c.Future_Revenue_Impact__c = 1;
            c.Financial_Of_Business__c = 1;
            
            insert c;
            System.assertEquals('AE',c.Country__c );
            // Controller_CAP_Approval_Process.LoadCasedetails(c.id);
            
            c.ApprovalRequestfront__c = 'Submitted';
            update c;
            // Controller_CAP_Approval_Process.submitforapprovals(c.id);
            // generateapprove(c.id);
            
            Controller_CAP_Approval_Process.approvecapss(c.id);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approve Request for Watchlist');
            req.setAction('Approve');
            system.debug('###################req details:::'+req);
            // req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
            Id workItemId = getWorkItemId(c.id); 
            system.debug('###################workItemId details:::'+workItemId);
            if(workItemId == null)
            {
                c.addError('Error Occured in update');
            }
            else
            {
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
            }
            
            List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'CAP_Approvers' ];
            
            //RecordType r =[Select id from recordtype where developername ='Partner'];
			Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Account a = new Account(      
                Account_Country_Code__c = 'EG',
                Active_Account__c = true,  
                Area__c= 'NORTHERN EUROPE',
                Master_Customer_Number__c = '1631Test',
                Name = 'Unit Test ' + System.now(),
                RecordTypeId = r,//'0127000000014kqAAA',
                RoR_Update_Date_Time__c = System.now(),
                Industry = 'RETAIL:CHANNEL',
                CAP_Watch__c = 'CAP',
                account_region__c='INDIA'
            );
            system.runAs(TestRecordsFactory.getUser()) {
        	insert a;
        }
            //insert a;
            Contact con = new Contact();
            con.Accountid = a.id;
            con.LastName = 'test1';
            con.Email = 'test1@test.com';
            if(a.Subscription_Group__c == 'Digital Insight') {
                con.Additional_Relationships__c = 'Digital Insight';
            }
            insert con;
            System.assertEquals('test1@test.com',con.Email );

            Boolean t = Controller_CAP_Approval_Process.approveWatchlist(c.id);
            
            
        }
    }
    
    
}