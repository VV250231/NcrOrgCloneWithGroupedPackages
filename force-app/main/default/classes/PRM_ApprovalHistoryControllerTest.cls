@isTest(seeAlldata =true)
public class PRM_ApprovalHistoryControllerTest 
{
    static
    {
        createAcc();  
        createContact();  
    }
    
    private static void createAcc()
    {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp',Partner_Type__c = 'Distributor'));
        accounts.add(new Account(Name = 'Unit Test LLC',Partner_Type__c = 'Distributor'));
        accounts.add(new Account(Name = 'Parent Company Inc', Partner_Type__c = 'Distributor'));
        System.RunAs(TestRecordsFactory.getUser()){
        insert accounts;
        }
        
    }
    
    private static void createContact()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id);
        insert con;
    }    
        
    private static User createUserandpartnerContact()
    {
        Profile p = [select Name from Profile WHERE name ='Partner Community User'];     
        List<USER> userList = [Select id , name from USER Where ProfileId =:p.id And isActive =true];
        return userList[0];
    }
        
    static testmethod void submitEngineerForApprovalPageApproved()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Engineers__C eng = new Engineers__C();
        eng.First_name__c ='ABC';
        eng.Last_Name__c ='XYZ';
        eng.Active_Engineer__c =true;
        eng.Partner_Account__c = acc.id;
        eng.Email_Address__c ='xyz@ncr.com';
        eng.City__c='noWhere';
        eng.Type_of_Portal_Access__c ='Diagnostics';
        eng.Status__c = 'Approved';
        insert eng;
        
        //Submit the Opportunity for Approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(eng.id);

        // Submit the approval request for the Engineer 
        Approval.ProcessResult result = Approval.process(req1);
                     
        List<ProcessInstance>  allPIList = [Select Id,CompletedDate , 
                                            (Select Id, OriginalActorId, ActorId, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                                            (Select Id, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                                            (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC) 
                                            From ProcessInstance p WHERE TargetObjectId =: eng.Id ORDER BY CreatedDate DESC];      
            
        PRM_ApprovalHistoryController.getApprovalHistory(eng.Id);
         system.assert(PRM_ApprovalHistoryController.getApprovalHistory(eng.Id)!= null);
       
    }
    
     /*static testmethod void submitOpptyForApprovalPageFRejected()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Engineers__C eng = new Engineers__C();
        eng.First_name__c ='ABC';
        eng.Last_Name__c ='XYZ';
        eng.Active_Engineer__c =true;
        eng.Partner_Account__c = acc.id;
        eng.Email_Address__c ='xyz@ncr.com';
        eng.City__c='noWhere';
        eng.Type_of_Portal_Access__c = 'Diagnostics';
        eng.Status__c = 'Approved';
        eng.Diagnostics_Approved__c = false;
        insert eng;
        
        //Submit the Opportunity for Approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(eng.id);

        // Submit the approval request for the Engineer 
        Approval.ProcessResult result = Approval.process(req1);

        PageReference pageRef = Page.ApprovalHistoryPage;
        Test.setCurrentPageReference(pageRef);
        // pageRef.getParameters().put('pid', partner.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(eng);
        ApprovalHistoryPageController fruc = new ApprovalHistoryPageController(sc);
        fruc.getReasonsforRejection();
            
        //Setting the other page 
                     
        List<ProcessInstance>  allPIList = [Select Id,CompletedDate , 
                                                (Select Id, OriginalActorId, ActorId, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                                                (Select Id, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                                                (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName 
                                                    From Nodes ORDER BY CreatedDate DESC) 
                                            From ProcessInstance p WHERE TargetObjectId =: eng.Id ORDER BY CreatedDate DESC];      
            
                         
        PageReference pageRef1 = Page.ApprovalAndRejectPage;
        List<ProcessInstance> pilIst = [Select Id,CompletedDate  From ProcessInstance p WHERE TargetObjectId =: eng.Id ORDER BY CreatedDate DESC];       
        pageRef1.getParameters().put('piwd', allPIList[0].Workitems[0].Id);
        pageRef1.getParameters().put('id', eng.id);
        pageRef1.setRedirect(true);
        Test.setCurrentPageReference(pageRef1);
        
        ApprovalHistoryPageController app = new ApprovalHistoryPageController();
        app.SelectedReason ='Not interested';
        app.renderComment();
        app.rejectEngineerFinal();
    }*/
 
    
    
}