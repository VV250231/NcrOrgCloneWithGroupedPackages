@isTest
public class GetApprovalStatusTest {
  
    public static testMethod void testMethod1(){
        Ticket_Request_Event__c tre =new Ticket_Request_Event__c();
        date myDate = date.newInstance(2021, 3, 21);
        
        tre.Event_Date__c= myDate;
        tre.Event_Name_Date__c='vs. Miami Dolphins on 3/21/2021';
        tre.No_Of_Tickets_Available__c = '20';
        tre.Event_Type__c = 'Test event';
        tre.Lower_Level_Tickets_Available__c = '10';
        tre.Suite_Tickets_Available__c='10';
        tre.Ticket_Type__c='Club';
        
        tre.Number_of_Parking_Passes_Available__c=10;
        tre.Notes__c = 'Suite Tickets';
        tre.Event_Date__c = Date.today().addDays(2);
        
        insert tre;
       
    
        Account acc=TestRecordsFactory.createAccount();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        Contact Con = TestRecordsFactory.createContact(acc);
        
       Ticket_Request__c tr =new Ticket_Request__c();
        tr.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
        //tr.Employee_Name__c = user.id;
        tr.Phone_Number__c = '9876543210';
        tr.Other_Employee_Reps_Attending__c = 'Test User';
        tr.Contact_Name__c = con.id;
        tr.Contacts_Guest__c = 'Test123'; 
        tr.Opportunity__c = opp.id;
        tr.Event_Type__c = 'Falcons';
        tr.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr.No_of_Tickets_Requested__c = '2';
        tr.Approval_Status__c = 'Pending';
        tr.Ticket_Typ__c = 'VVIP';

       insert tr;
        Boolean b = GetApprovalStatus.getStatus(tr.id);
        System.assert(b);
        GetApprovalStatus.setControlModal(tr.id);
        //Submit Quote for Approval
        //Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        //app.setObjectId(tr.id);
        //Approval.ProcessResult result = Approval.process(app);
        Test.StartTest();
         GetApprovalStatus.SendForApproval(tr.id,'test send approval');
        Test.StopTest();
 
       
    }
}