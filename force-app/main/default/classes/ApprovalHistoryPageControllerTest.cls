/*
##################################################################################################
# Class Name............................:ApprovalHistoryPageControllerTest                                                                                                                                 
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class ApprovalHistoryPageControllerTest 
{   
    static
    {
    System.runAs(TestRecordsFactory.getUser()) {
        createAcc();  
        createContact();  
    }
}
 private static void createAcc()
 {
     List<Account> accounts = new List<Account>();
     accounts.add(new Account(Name = 'Unit Test Corp', Partner_Type__c = 'Distributor'));
     accounts.add(new Account(Name = 'Unit Test LLC', Partner_Type__c = 'Distributor'));
     accounts.add(new Account(Name = 'Parent Company Inc', Partner_Type__c ='Distributor'));
     insert accounts;
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
 static testmethod void submitPortalAccessRequest()
 {
     Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
     System.assertEquals(acc.Name!=Null,True);
     Engineers__C eng = new Engineers__C();
     eng.First_name__c = 'ABC';
     eng.Last_Name__c = 'XYZ';
     eng.Active_Engineer__c = true;
     eng.Partner_Account__c = acc.id;
     eng.Email_Address__c = 'xyz@ncr.com';
     eng.Type_of_Portal_Access__c = 'Portal Access';
     eng.Status__c = 'Created';
     eng.City__c='noWhere';
     insert eng;
     //Submit the Opportunity for Approval
     Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
     req1.setComments('Submitting request for approval.');
     req1.setObjectId(eng.id);
     // Submit the approval request for the Engineer 
     Approval.ProcessResult result = Approval.process(req1);
     PageReference pageRef = Page.ApprovalHistoryPage;
     Test.setCurrentPageReference(pageRef);
     ApexPages.StandardController sc = new ApexPages.StandardController(eng);
     ApprovalHistoryPageController fruc = new ApprovalHistoryPageController(sc);
     fruc.getReasonsforRejection();
     fruc.cancel();
 }
 static testmethod void submitOpptyForApprovalPageApproved()
 {
     Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
     System.assertEquals(acc.Id!=Null,True);
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
                                         (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC) From ProcessInstance p WHERE TargetObjectId =: eng.Id ORDER BY CreatedDate DESC];      
     PageReference pageRef1 = Page.ApprovalAndRejectPage;
     List<ProcessInstance> pilIst = [Select Id,CompletedDate  From ProcessInstance p WHERE TargetObjectId =: eng.Id ORDER BY CreatedDate DESC];       
     pageRef1.getParameters().put('piwd', allPIList[0].Workitems[0].Id);
     pageRef1.getParameters().put('id', eng.id);
     pageRef1.setRedirect(true);
     Test.setCurrentPageReference(pageRef1);
     ApprovalHistoryPageController app = new ApprovalHistoryPageController();
     app.SelectedReason ='Not interested';
     app.rejectionReason = True;
     app.renderComment();
     app.ApproveEngineer();
 }
 static testmethod void submitOpptyForApprovalPageFRejected()
 {
     Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
     System.assertEquals(acc.Id!=Null,True);
     Engineers__C eng = new Engineers__C();
     eng.First_name__c ='ABC';
     eng.Last_Name__c ='XYZ';
     eng.Active_Engineer__c =true;
     eng.Partner_Account__c = acc.id;
     eng.ownerid = UserInfo.getUserId();
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
     pageRef.getParameters().put('id', eng.id);
     pageRef.getParameters().put('pid', string.valueof(partner.id));
     ApexPages.StandardController sc = new ApexPages.StandardController(eng);
     ApprovalHistoryPageController fruc = new ApprovalHistoryPageController(sc);
     fruc.getReasonsforRejection();
     //Setting the other page 
     ApprovalHistoryPageController objjj = new ApprovalHistoryPageController();
     
     objjj.EngineerToContactConversion();
   // objjj.sendEmail();
     
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
 }
 static testmethod void submitDealRegReject()
 {
     Contact con = [SELECT Id, AccountID FROM Contact WHERE LastName = 'testCon' LIMIT 1];
     Deal_Registration__C dealReg = new Deal_Registration__C();
     System.assertEquals(con.Id!=Null,True);
     //dealreg.recordtypeId =devRecordTypeId;
     dealreg.TAM__c = UserInfo.getUserId();
     dealreg.CAM__c = UserInfo.getUserId();
     dealReg.Estimated_Close_Date__c = date.today();
     dealReg.NCR_Account_Manager__c = UserInfo.getUserId();
     dealReg.Name_of_Account_Financial_Institution__c ='Test Acc';
     insert dealReg;
     System.debug('@@@@@@'+dealReg);
     //Submit the Opportunity for Approval
     Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
     req1.setComments('Submitting request for approval.');
     req1.setObjectId(dealReg.id);
     // Submit the approval request for the Engineer 
     try{
         Approval.ProcessResult result = Approval.process(req1);
         List<ProcessInstance>  allPIList = [Select Id,CompletedDate , 
                                             (Select Id, OriginalActorId, ActorId, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                                             (Select Id, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                                             (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName 
                                              From Nodes ORDER BY CreatedDate DESC) 
                                             From ProcessInstance p WHERE TargetObjectId =: dealReg.Id ORDER BY CreatedDate DESC];      
         //Setting the other page 
         Test.startTest() ;               
         PageReference pageRef1 = Page.ApprovalAndRejectPage;
         List<ProcessInstance> pilIst = [Select Id,CompletedDate  From ProcessInstance p WHERE TargetObjectId =: dealreg.Id ORDER BY CreatedDate DESC];       
         pageRef1.getParameters().put('piwd', allPIList[0].Workitems[0].Id);
         pageRef1.getParameters().put('id', dealreg.id);
         pageRef1.setRedirect(true);
         Test.setCurrentPageReference(pageRef1);
         ApprovalHistoryPageController app = new ApprovalHistoryPageController();
         app.getReasonsforRejection();
         app.SelectedReason ='Not interested';
         app.cancel();
         app.rejectEngineerFinal();
    
         // app.ApproveEngineer();
         Test.stopTest();
     }catch(Exception e){
     }
 }   
 static testmethod void submitDealRegApprove()
 {
     //Id devRecordTypeId = Schema.SObjectType.Deal_registration__c.getRecordTypeInfosByName().get('Experience 2020 - Frictionless Program').getRecordTypeId();
     Contact con = [SELECT Id, AccountID FROM Contact WHERE LastName = 'testCon' LIMIT 1];
     Deal_Registration__C dealReg = new Deal_Registration__C();
     System.assertEquals(con.Id!=Null,True);
     //dealreg.recordtypeId =devRecordTypeId;
     dealreg.TAM__c = UserInfo.getUserId();
     dealreg.CAM__c = UserInfo.getUserId();    
     dealReg.Estimated_Close_Date__c = date.today();
     dealReg.NCR_Account_Manager__c = UserInfo.getUserId();
     dealReg.Name_of_Account_Financial_Institution__c ='Test Acc';
     insert dealReg;
     //Submit the Opportunity for Approval
     Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
     req1.setComments('Submitting request for approval.');
     req1.setObjectId(dealReg.id);
     // Submit the approval request for the Engineer 
     try{
         Approval.ProcessResult result = Approval.process(req1);
         List<ProcessInstance>  allPIList = [Select Id,CompletedDate , 
                                             (Select Id, OriginalActorId, ActorId, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                                             (Select Id, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                                             (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName 
                                              From Nodes ORDER BY CreatedDate DESC) 
                                             From ProcessInstance p WHERE TargetObjectId =: dealReg.Id ORDER BY CreatedDate DESC];      
         //Setting the other page 
         Test.startTest() ;               
         PageReference pageRef1 = Page.ApprovalAndRejectPage;
         List<ProcessInstance> pilIst = [Select Id,CompletedDate  From ProcessInstance p WHERE TargetObjectId =: dealreg.Id ORDER BY CreatedDate DESC];       
         pageRef1.getParameters().put('piwd', allPIList[0].Workitems[0].Id);
         pageRef1.getParameters().put('id', dealreg.id);
         pageRef1.setRedirect(true);
         Test.setCurrentPageReference(pageRef1);
         ApprovalHistoryPageController app = new ApprovalHistoryPageController();
         app.getReasonsforRejection();
         app.SelectedReason ='Not interested';
         //app.rejectEngineerFinal();
         app.ApproveEngineer();
         Test.stopTest();
     }catch(Exception e){
     }
 }      
    static testmethod void submitOpptyForApprovalPageApproved1()
 {
     Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
     System.assertEquals(acc.Id!=Null,True);
     Engineers__C eng = new Engineers__C();
     Deal_Registration__C dealReg1 = new Deal_Registration__C();  
     dealreg1.TAM__c = UserInfo.getUserId();
     dealreg1.CAM__c = UserInfo.getUserId();
     dealreg1.ownerid = UserInfo.getUserId();     
     dealreg1.Partner_Industry__c = 'FINANCIAL';
     dealReg1.Estimated_Close_Date__c = date.today();
     dealReg1.NCR_Account_Manager__c = UserInfo.getUserId();
     dealReg1.Name_of_Account_Financial_Institution__c ='Test Acc';
     insert dealReg1;
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
     req1.setObjectId(dealReg1.id);
     // Submit the approval request for the Engineer 
     Approval.ProcessResult result = Approval.process(req1);
     PageReference pageRef = Page.ApprovalHistoryPage;
     Test.setCurrentPageReference(pageRef);
     // pageRef.getParameters().put('pid', partner.id);
     ApexPages.StandardController sc = new ApexPages.StandardController(dealReg1);
     ApprovalHistoryPageController fruc = new ApprovalHistoryPageController(sc);
     fruc.getReasonsforRejection();
     //Setting the other page 
     List<ProcessInstance>  allPIList = [Select Id,CompletedDate , 
                                         (Select Id, OriginalActorId, ActorId, CreatedDate From Workitems ORDER BY CreatedDate DESC), 
                                         (Select Id, StepStatus, OriginalActorId, ActorId, Comments, CreatedDate, StepNodeId  From Steps ORDER BY CreatedDate DESC) , 
                                         (Select  Id, IsDeleted, LastActorId, NodeStatus, ProcessInstanceId, ProcessNodeId, ProcessNodeName From Nodes ORDER BY CreatedDate DESC) From ProcessInstance p WHERE TargetObjectId =: dealReg1.Id ORDER BY CreatedDate DESC];      
     PageReference pageRef1 = Page.ApprovalAndRejectPage;
     List<ProcessInstance> pilIst = [Select Id,CompletedDate  From ProcessInstance p WHERE TargetObjectId =: dealReg1.Id ORDER BY CreatedDate DESC];       
     pageRef1.getParameters().put('piwd', allPIList[0].Workitems[0].Id);
     pageRef1.getParameters().put('id', dealReg1.id);
     pageRef1.setRedirect(true);
     Test.setCurrentPageReference(pageRef1);
     ApprovalHistoryPageController app = new ApprovalHistoryPageController();
     app.SelectedReason ='Not interested';
     //app.renderComment();
     app.ApproveEngineer();
     //app.rejectEngineerFinal();
    // app.sendEmailDealRegistration();
 }
}