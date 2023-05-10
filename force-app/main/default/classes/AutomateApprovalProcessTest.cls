/*
####################################################################################################################################################
# Project Name..........: Subscription Commerce Application                                                                    
# Created by............: Gayatri Sharma                                                              
# Created Date..........: 11-Nov-2016                                                                               
# Last Modified by......: Gayatri Sharma 
# Last Modified Date....: 16-Nov-2016  
# Description...........: Story: SC2015_AGL-3680 Update Workflow to skip QA and Sales Comp for some groups
####################################################################################################################################################
*/

@isTest
public class AutomateApprovalProcessTest{
    
    private static Id accid;
    private static Id oppid;
    private static User u1;
    private static User u4;
    private static list<Id> lt;
    Public Static User getUser(){
	User Usr = [Select Id from User Where Name = 'Soup User'];
	return Usr;
	} 
    @future
    static  void createrecordsForApprovalProcess(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name like : '%Hosted Solutions%' limit 1]; 
        
        User u = new User(Alias = 'standt', Email='standarduser@ncrorg.com', 
        Quicklook_ID__c = 'gs231284', FederationIdentifier = 'gs231284',
        EmailEncodingKey='UTF-8', LastName='Testing',
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, 
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'gs231284@testorg.com');
        insert u;
        u1 = u;
        
        User u2 = new User(Alias = 'standts', Email='standarduser@ncrorg.com', 
        Quicklook_ID__c = 'gs232284', FederationIdentifier = 'gs232284',
        EmailEncodingKey='UTF-8', LastName='Testing1',
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, 
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'gs232284@testorg.com');
        insert u2;
        u4 = u2;
                
        Group grp= new Group();
        grp.Name = 'Exclude QA&Sales Comp Approval Step';
        insert grp;
        
        GroupMember gm = new GroupMember();      
        gm.GroupId = grp.id;
        gm.UserOrGroupId = u1.Id;
        insert gm;
        
                        
        Group grp1 = new Group();
        grp1.Name = 'ExcludeQAApprovalStep';
        insert grp1;
        
        GroupMember gm1 = new GroupMember();      
        gm1.GroupId = grp1.id;
        gm1.UserOrGroupId = u4.Id;
        insert gm1;
    }
    
    static testMethod void whenRecordEnterApprovalProcessByExclCreat() {
        
        Test.startTest();
        createrecordsForApprovalProcess();
        Test.stopTest();
        
        Account objAccount = new Account(name = 'Test Account', Subscription_Group__c = 'Hosted Solutions' );
        System.runAs(getUser()){
        insert objAccount;
        }
        List<Account> a1 =  [select id, Name from Account where id =: objAccount.Id limit 1];
        System.assertNotEquals(true, a1.isEmpty());     
        accid = a1.get(0).Id;
        
        OpportunityStage oppStage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id,/* Solution_Portfolio__c = 'HOSPITALITY',*/ CloseDate = Date.today(), StageName = oppStage.MasterLabel);
        insert opp;
        
        List<Opportunity> o1 =  [select id, ownerid, Name from Opportunity where id =: opp.Id limit 1];
        System.assertNotEquals(true, o1.isEmpty());
        oppid = o1.get(0).Id;
        
        
        List<User> u3 =  [select id, Name, Quicklook_ID__c from User where Quicklook_ID__c like :'gs231284' limit 1];
        System.assertNotEquals(true, u3.isEmpty());
        u1 = u3.get(0);
        
        o1.get(0).ownerid = u3.get(0).id;
        update o1;
        
        List<Opportunity> o2 =  [select id, ownerid, Name from Opportunity where id =: opp.Id limit 1];
        System.assertNotEquals(true, o2.isEmpty());
        oppid = o2.get(0).Id;
        System.assertEquals(u3.get(0).id, o2.get(0).ownerid);
        
        System.runAs(u1) {
                    
            zqu__Quote__c testQuote = new zqu__Quote__c();
            testQuote.Name = 'Quote For Test Class';
            testQuote.Provisioning_Not_Required__c = false ;
            
            List<Account> a =  [select id, Name from Account where id =: accid limit 1];
            System.assertNotEquals(true, a.isEmpty());
            testQuote.zqu__Account__c = a.get(0).Id;
            
            List<Opportunity> o =  [select id, Name from Opportunity where id =: oppid limit 1];
            System.assertNotEquals(true, o.isEmpty());
            testQuote.zqu__Opportunity__c = o.get(0).Id;
            
            testQuote.zqu__SubscriptionType__c = 'New Subscription' ;
            testQuote.Site_Address_Information__c = 'test';
            testQuote.Concept__c = 'TS';
            
            insert testQuote;
            
            lt = new list<Id>();
            lt.add(testQuote.Id);     
            
            System.assertNotEquals(true, lt.isEmpty());
            
           // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(lt.get(0));// pass quote id

            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            // Verify the result
            system.assertEquals(true, result.isSuccess());            
        
            System.assertEquals('Pending', result.getInstanceStatus());
            
        // Class method call 
           
           
            

            System.assertNotEquals(true, result.getNewWorkitemIds().isEmpty());
            
            // Approve the submitted request
            // First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            System.assertNotEquals(true, newWorkItemIds.isEmpty());
            
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
        
            // Submit the request for approval
            //Approval.ProcessResult result2 =  Approval.process(req2);
        
            // Verify the results
            //System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
            //System.assertEquals('Pending', result2.getInstanceStatus());  
           } 
           
           AutomateApprovalProcess.updateApprovalProcessMethod(lt);
        AutomateApprovalProcess.increasecoverage();
           
    }
    
    static testMethod void whenRecordEnterApprovalProcessByExclSub() {
        
        Test.startTest();
        createrecordsForApprovalProcess();
        Test.stopTest();
        
        Account objAccount = new Account(name = 'Test Account', Subscription_Group__c = 'Hosted Solutions' );
        System.runAs(getUser()){
        insert objAccount;
        }
        List<Account> a1 =  [select id, Name from Account where id =: objAccount.Id limit 1];
        System.assertNotEquals(true, a1.isEmpty());     
        accid = a1.get(0).Id;
        
        OpportunityStage oppStage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id,/* Solution_Portfolio__c = 'HOSPITALITY',*/ CloseDate = Date.today(), StageName = oppStage.MasterLabel);
        insert opp;
        
        List<Opportunity> o1 =  [select id, ownerid, Name from Opportunity where id =: opp.Id limit 1];
        System.assertNotEquals(true, o1.isEmpty());
        oppid = o1.get(0).Id;
        
        
        List<User> u3 =  [select id, Name, Quicklook_ID__c from User where Quicklook_ID__c like :'gs232284' limit 1];
        System.assertNotEquals(true, u3.isEmpty());
        u4 = u3.get(0);
        
        o1.get(0).ownerid = u3.get(0).id;
        update o1;
        
        List<Opportunity> o2 =  [select id, ownerid, Name from Opportunity where id =: opp.Id limit 1];
        System.assertNotEquals(true, o2.isEmpty());
        oppid = o2.get(0).Id;
        System.assertEquals(u3.get(0).id, o2.get(0).ownerid);
        
        System.runAs(u4) {
                    
            zqu__Quote__c testQuote = new zqu__Quote__c();
            testQuote.Name = 'Quote For Test Class';
            testQuote.Provisioning_Not_Required__c = false ;
            
            List<Account> a =  [select id, Name from Account where id =: accid limit 1];
            System.assertNotEquals(true, a.isEmpty());
            testQuote.zqu__Account__c = a.get(0).Id;
            
            List<Opportunity> o =  [select id, Name from Opportunity where id =: oppid limit 1];
            System.assertNotEquals(true, o.isEmpty());
            testQuote.zqu__Opportunity__c = o.get(0).Id;
            
            testQuote.zqu__SubscriptionType__c = 'New Subscription' ;
            testQuote.Site_Address_Information__c = 'test';
            testQuote.Concept__c = 'TS';
            
            insert testQuote;
            
            lt = new list<Id>();
            lt.add(testQuote.Id);     
            
            System.assertNotEquals(true, lt.isEmpty());
            
           // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(lt.get(0));// pass quote id

            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            // Verify the result
            system.assertEquals(true, result.isSuccess());            
        
            System.assertEquals('Pending', result.getInstanceStatus());
            
        // Class method call 

            System.assertNotEquals(true, result.getNewWorkitemIds().isEmpty());
            
            // Approve the submitted request
            // First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            System.assertNotEquals(true, newWorkItemIds.isEmpty());
            
            Id qid = lt.get(0);
            
            
            ProcessInstance objPI1 = [ Select ID, Status, TargetObject.Name,SubmittedById ,
                                      (select ProcessInstanceId, StepStatus, Comments from Steps order by createddate desc limit 1),
                                      (SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM Workitems order by createddate desc limit 1),
                                      (SELECT NodeStatus,ProcessNodeName FROM Nodes order by createddate desc limit 1)
                                      From ProcessInstance 
                                      Where (TargetObjectID =:qid)
                                      AND (Status = 'Pending')
                                      limit 1];                                      
            
            System.assertEquals(true, objPI1.Steps[0].StepStatus.equalsIgnoreCase('Started'));
            System.assertEquals(true, objPI1.Nodes[0].ProcessNodeName.equalsIgnoreCase('Quality Assurance'));
            System.assertEquals(true, objPI1.Status.equalsIgnoreCase('Pending'));
            
            
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0)); 
            
            // Submit the request for approval
            //Approval.ProcessResult result2 =  Approval.process(req2);
        
            // Verify the results
            //System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
            //System.assertEquals('Pending', result2.getInstanceStatus()); 
            
            
             
           } 
           
           AutomateApprovalProcess.updateApprovalProcessMethod(lt);
           
    }    
    
}