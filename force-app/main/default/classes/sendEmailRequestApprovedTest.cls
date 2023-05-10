@isTest
public class sendEmailRequestApprovedTest {
 static testMethod void unitTest() {  
        User user = [select id, name, email from user where id = '00570000003UjRaAAK'] ;
     list<User> lt = sendEmailRequestApproved.getUserEmail();
     system.assertNotEquals(lt, null);
     
      Account acc=TestRecordsFactory.createAccount();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        Contact Con = TestRecordsFactory.createContact(acc);
      Ticket_Request__c tr = TestRecordsFactory.createTicketRequest(user, con, opp);
     sendEmailRequestApproved.getApprovalStats(tr.id);
     List<String> email = new List<String>();
     email.add('xyz@gmail.com');
     sendEmailRequestApproved.sendMailMethod(email, 'You are Invited', 'Test Body', 'abc@gmail.com');
}
}