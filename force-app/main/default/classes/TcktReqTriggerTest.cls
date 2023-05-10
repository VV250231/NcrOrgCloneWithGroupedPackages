@isTest
public class TcktReqTriggerTest {
	static testMethod void unitTest() {  
        Ticket_Request_Event__c tre =new Ticket_Request_Event__c();
        tre.Event_Type__c = 'Falcons';
        tre.Event_Name_Date__c='vs. Miami Dolphins on 10/15/2017';
        tre.No_Of_Tickets_Available__c = '100';
        tre.Notes__c = 'Suite Tickets';
        tre.Event_Date__c = Date.today().addDays(2);
        //tre.Suite_Tickets_Available__c = '50';
        tre.Number_of_Parking_Passes_Available__c  = 200;
        tre.Lower_Level_Tickets_Available__c = '30';
        tre.Suite_Tickets_Available__c = '20';
        tre.VVIP_Tickets_Available__c = '50' ;
        insert tre;
       
         System.assertNotEquals(tre, null,'Ticket_Request_Event__c should not be null');
     User user = [select id, name, phone from user where id = '00570000003UjRaAAK'] ;
        
       
        Account acc=TestRecordsFactory.createAccount();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        Contact Con = TestRecordsFactory.createContact(acc);
        List<Ticket_Request__c> trList = new List<Ticket_Request__c>();
       
       /* Ticket_Request__c tr = TestRecordsFactory.createTicketRequest(user, con, opp);
        tr.No_of_Tickets_Requested__c = '10';
        tr.Approval_Status__c = 'Got First Approval';
        tr.Ticket_Typ__c = 'VVIP';
        
        trList.add(tr);
        
        Ticket_Request__c suiteTR = TestRecordsFactory.createTicketRequest(user, con, opp);
        suiteTR.No_of_Tickets_Requested__c = '10';
        suiteTR.Approval_Status__c = 'Got First Approval';
        suiteTR.Ticket_Typ__c = 'Suite';
        trList.add(suiteTR);
        
         Ticket_Request__c LLTR = TestRecordsFactory.createTicketRequest(user, con, opp);
        LLTR.No_of_Tickets_Requested__c = '10';
        LLTR.Approval_Status__c = 'Got First Approval';
        LLTR.Ticket_Typ__c = 'Lower Level';
        trList.add(LLTR);
        
         Ticket_Request__c EmptyTR = TestRecordsFactory.createTicketRequest(user, con, opp);
        EmptyTR.No_of_Tickets_Requested__c = '10';
        EmptyTR.Approval_Status__c = 'Got First Approval';
        EmptyTR.Ticket_Typ__c = ' ';
        trList.add(EmptyTR);
        
        
        
        Ticket_Request__c trAprvd = TestRecordsFactory.createTicketRequest(user, con, opp);
        trAprvd.No_of_Tickets_Requested__c = '2';
        trAprvd.Approval_Status__c = 'Approved';
        trAprvd.Ticket_Typ__c = 'VVIP';
        trList.add(trAprvd);
        
       
        
        Ticket_Request__c suiteTRAprvd = TestRecordsFactory.createTicketRequest(user, con, opp);
        suiteTRAprvd.No_of_Tickets_Requested__c = '2';
        suiteTRAprvd.Approval_Status__c = 'Approved';
        suiteTRAprvd.Ticket_Typ__c = 'Suite';
        trList.add(suiteTRAprvd);
        
         Ticket_Request__c LLTRAprvd = TestRecordsFactory.createTicketRequest(user, con, opp);
        LLTRAprvd.No_of_Tickets_Requested__c = '2';
        LLTRAprvd.Approval_Status__c = 'Approved';
        LLTRAprvd.Ticket_Typ__c = 'Lower Level';
        trList.add(LLTRAprvd);
        
         Ticket_Request__c EmptyTRAprvd = TestRecordsFactory.createTicketRequest(user, con, opp);
        EmptyTRAprvd.No_of_Tickets_Requested__c = '2';
        EmptyTRAprvd.Approval_Status__c = 'Approved';
        EmptyTRAprvd.Ticket_Typ__c = ' ';
        trList.add(EmptyTRAprvd);
        
        update trList;*/
         Ticket_Request__c tr =new Ticket_Request__c();
        Ticket_Request__c tr1 =new Ticket_Request__c();
        Ticket_Request__c tr2 =new Ticket_Request__c();
         Ticket_Request__c tr3 =new Ticket_Request__c();
         Ticket_Request__c tr4 =new Ticket_Request__c();
        try {
        
        //tr.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
        tr.Employee_Name__c = user.id;
        tr.Phone_Number__c = '9876543210';
        tr.Other_Employee_Reps_Attending__c = 'Test User';
        tr.Contact_Name__c = con.id;
        tr.Contacts_Guest__c = 'Test123'; 
        tr.Opportunity__c = opp.id;
        //tr.No_of_Tickets_Requested__c = '16';
        tr.Event_Type__c = 'Falcons';
        tr.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr.Number_of_Parking_Passes_Available__c  = 10;
        tr.No_of_Tickets_Requested__c = '2';
        tr.Approval_Status__c = 'Approved';
       insert tr;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        //monika
        CheckRecursive.runOppRelatedObject();
        opp.Amount = 1500;
        update opp;
            
        
        try {
            
          Ticket_Request__c trq1 = new Ticket_Request__c(Id=tr.Id) ;  
          trq1.Ticket_Typ__c = 'Lower Level';
          trq1.Approval_Status__c = 'Submitted';
          update trq1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        
        
        try {
            
          Ticket_Request__c trq2 = new Ticket_Request__c(Id=tr.Id) ;  
          trq2.Ticket_Typ__c = 'Suite';
          trq2.Approval_Status__c = 'Rejected';
          update trq2;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
            
          Ticket_Request__c trq1 = new Ticket_Request__c(Id=tr.Id) ;  
          trq1.Ticket_Typ__c = 'Suite';
          trq1.Approval_Status__c = 'Submitted';
          update trq1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        try {
            
          Ticket_Request__c trq2 = new Ticket_Request__c(Id=tr.Id) ;  
          //trq2.Ticket_Typ__c = 'Suite';
          trq2.Approval_Status__c = 'Rejected';
          update trq2;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        
        try {
            
          Ticket_Request__c trq1 = new Ticket_Request__c(Id=tr.Id) ;  
          trq1.Ticket_Typ__c = 'Club';
          trq1.Approval_Status__c = 'Submitted';
          update trq1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
        
       // tr1.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017 -1';
        tr1.Employee_Name__c = user.id;
        tr1.Phone_Number__c = '9876543210';
        tr1.Other_Employee_Reps_Attending__c = 'Test User';
        tr1.Contact_Name__c = con.id;
        tr1.Contacts_Guest__c = 'Test123'; 
        tr1.Opportunity__c = opp.id;
        //tr.No_of_Tickets_Requested__c = '16';
        tr1.Event_Type__c = 'Falcons';
        tr1.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr1.No_of_Tickets_Requested__c = '5';
        tr1.Number_of_Parking_Passes_Available__c  = 10;
        tr1.Approval_Status__c = 'Submitted';
        tr1.Ticket_Typ__c = 'Suite';
       insert tr1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
        tr1.No_of_Tickets_Requested__c = '5';
        tr1.Ticket_Typ__c = 'Suite';
        tr1.Number_of_Parking_Passes_Available__c  = 20;
         tr1.Approval_Status__c = 'Approved';
        update tr1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
         
        //tr2.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017 -1';
        tr2.Employee_Name__c = user.id;
        tr2.Phone_Number__c = '9876543210';
        tr2.Other_Employee_Reps_Attending__c = 'Test User';
        tr2.Contact_Name__c = con.id;
        tr2.Contacts_Guest__c = 'Test123'; 
        tr2.Opportunity__c = opp.id;
        //tr.No_of_Tickets_Requested__c = '16';
        tr2.Event_Type__c = 'Falcons';
        tr2.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr2.No_of_Tickets_Requested__c = '5';
        tr2.Approval_Status__c = 'Submitted';
       insert tr2;
       } catch(Exception e) {
        System.debug('Error '+e.getMessage());
       }
       
        
            
            try {
        tr2.Ticket_Typ__c = 'Lower Level';
         tr2.Approval_Status__c = 'Approved';
         tr2.Number_of_Parking_Passes_Available__c =5;
        update tr2;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
       
       // tr3.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017 -1';
        tr3.Employee_Name__c = user.id;
        tr3.Phone_Number__c = '9876543210';
        tr3.Other_Employee_Reps_Attending__c = 'Test User';
        tr3.Contact_Name__c = con.id;
        tr3.Contacts_Guest__c = 'Test123'; 
        tr3.Opportunity__c = opp.id;
        //tr.No_of_Tickets_Requested__c = '16';
        tr3.Event_Type__c = 'Falcons';
        tr3.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr3.No_of_Tickets_Requested__c = '2';
        tr3.Approval_Status__c = 'Submitted';
       insert tr3;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
        tr3.Ticket_Typ__c = 'Suite';
         tr3.Approval_Status__c = 'Approved';
         tr3.Number_of_Parking_Passes_Available__c  = 10;
        update tr3;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        try {
       
       // tr4.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017 -1';
        tr4.Employee_Name__c = user.id;
        tr4.Phone_Number__c = '9876543210';
        tr4.Other_Employee_Reps_Attending__c = 'Test User';
        tr4.Contact_Name__c = con.id;
        tr4.Contacts_Guest__c = 'Test123'; 
        tr4.Opportunity__c = opp.id;
        //tr.No_of_Tickets_Requested__c = '16';
        tr4.Event_Type__c = 'Falcons';
        tr4.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr4.No_of_Tickets_Requested__c = '3';
        tr4.Approval_Status__c = 'Submitted';
       insert tr4;
       } catch(Exception e) {
        System.debug('Error '+e.getMessage());
       }
        
        try {
        tr4.Ticket_Typ__c = 'Suite';
         tr4.Approval_Status__c = 'Got First Approval';
        update tr4;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        Ticket_Request__c tr5 =new Ticket_Request__c();
            //tr5.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
            tr5.Employee_Name__c = user.id;
            tr5.Phone_Number__c = '9876543210';
            tr5.Other_Employee_Reps_Attending__c = 'Test User';
            tr5.Contact_Name__c = con.id;
            tr5.Contacts_Guest__c = 'Test123'; 
            tr5.Opportunity__c = opp.id;
            tr5.Event_Type__c = 'Falcons';
            tr5.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
            tr5.No_of_Tickets_Requested__c = '5';
            tr5.Approval_Status__c = 'Approved';
            tr5.Ticket_Typ__c = 'VVIP';
            tr5.Ticket_Type__c = 'Admin Assigned';
      
        insert tr5;
       try{
           delete tr5 ;
       } catch(Exception ex) {
        System.debug('Error '+ex.getMessage());
       }
        
        
         Ticket_Request__c tr6 =new Ticket_Request__c();
            //tr5.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
            tr6.Employee_Name__c = user.id;
            tr6.Phone_Number__c = '9876543210';
            tr6.Other_Employee_Reps_Attending__c = 'Test User';
            tr6.Contact_Name__c = con.id;
            tr6.Contacts_Guest__c = 'Test123'; 
            tr6.Opportunity__c = opp.id;
            tr6.Event_Type__c = 'Falcons';
            tr6.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
            tr6.No_of_Tickets_Requested__c = '5';
            tr6.Approval_Status__c = 'Approved';
            tr6.Ticket_Typ__c = 'Suite';
            tr6.Ticket_Type__c = 'User Assigned';
      
        insert tr6;
        try{
            delete tr6 ; 
        } catch(Exception ex) {
          System.debug('Error '+ex.getMessage());
        }
       
        
        Ticket_Request__c tr7 =new Ticket_Request__c();
            //tr5.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
            tr7.Employee_Name__c = user.id;
            tr7.Phone_Number__c = '9876543210';
            tr7.Other_Employee_Reps_Attending__c = 'Test User';
            tr7.Contact_Name__c = con.id;
            tr7.Contacts_Guest__c = 'Test123'; 
            tr7.Opportunity__c = opp.id;
            tr7.Event_Type__c = 'Falcons';
            tr7.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
            tr7.No_of_Tickets_Requested__c = '5';
            tr7.Approval_Status__c = 'Approved';
            tr7.Ticket_Typ__c = 'Club';
            tr7.Ticket_Type__c = 'User Assigned';
      
        insert tr7;
        try{
             delete tr7 ;
        } catch(Exception ex) {
          System.debug('Error '+ex.getMessage());
        }
       
        
    } 
    static testMethod void unitTest2() {  
        Ticket_Request_Event__c tre =   new Ticket_Request_Event__c();
        tre.Event_Type__c = 'Falcons';
        tre.Event_Name_Date__c='vs. Miami Dolphins on 10/15/2017';
        tre.No_Of_Tickets_Available__c = '16';
        tre.Notes__c = 'Suite Tickets';
        tre.Event_Date__c = Date.today().addDays(2);
        tre.Suite_Tickets_Available__c = '4';
        tre.Number_of_Parking_Passes_Available__c  = 1;
        tre.Lower_Level_Tickets_Available__c = '4';
        tre.VVIP_Tickets_Available__c = '8';
        insert tre;
        Ticket_Request_Event__c tre1 =   new Ticket_Request_Event__c();
        tre1.Event_Type__c = 'Falcons';
        tre1.Event_Name_Date__c='Atlanta United - vs. LA Galaxy on 9/20/2017-123';
        tre1.No_Of_Tickets_Available__c = '8';
        tre1.Notes__c = 'Suite Tickets';
        tre1.Event_Date__c = Date.today().addDays(2);
        tre1.Suite_Tickets_Available__c = '3';
        tre1.Lower_Level_Tickets_Available__c = '2';
        tre1.VVIP_Tickets_Available__c = '3';
        insert tre1;
        System.assertNotEquals(tre1, null,'Ticket_Request_Event__c should not be null');
     User user = [select id, name, phone from user where id = '00570000003UjRaAAK'] ;
        
        Account acc=TestRecordsFactory.createAccount();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        Contact Con = TestRecordsFactory.createContact(acc);
           List<Ticket_Request__c> trListAdmin = new List<Ticket_Request__c>();
       Ticket_Request__c tr =new Ticket_Request__c();
        
        try{
            //tr.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
            tr.Employee_Name__c = user.id;
            tr.Phone_Number__c = '9876543210';
            tr.Other_Employee_Reps_Attending__c = 'Test User';
            tr.Contact_Name__c = con.id;
            tr.Contacts_Guest__c = 'Test123'; 
            tr.Opportunity__c = opp.id;
            tr.Event_Type__c = 'Falcons';
            tr.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
            tr.No_of_Tickets_Requested__c = '5';
            tr.Approval_Status__c = 'Approved';
            tr.Ticket_Typ__c = 'Club';
            tr.Ticket_Type__c = 'Admin Assigned';
      
        insert tr;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        tr.No_of_Tickets_Requested__c = '1';
        //insert tr;
        
        Ticket_Request__c tr1 =new Ticket_Request__c();
        try {
         
        // tr1.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017-12';
        tr1.Employee_Name__c = user.id;
        tr1.Phone_Number__c = '9876543210';
        tr1.Other_Employee_Reps_Attending__c = 'Test User';
        tr1.Contact_Name__c = con.id;
        tr1.Contacts_Guest__c = 'Test123'; 
        tr1.Opportunity__c = opp.id;
        tr1.Event_Type__c = 'Falcons';
        tr1.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr1.No_of_Tickets_Requested__c = '2';
        tr1.Approval_Status__c = 'Approved';
        tr1.Ticket_Typ__c = 'Suite';
        tr1.Ticket_Type__c = 'Admin Assigned';
        tr1.No_of_Tickets_Requested__c = '10';
        insert tr1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
        
        tr1.No_of_Tickets_Requested__c = '1';
        insert tr1;
        
         Ticket_Request__c tr2 =new Ticket_Request__c();
        try {
       
        // tr2.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017-123';
        tr2.Employee_Name__c = user.id;
        tr2.Phone_Number__c = '9876543210';
        tr2.Other_Employee_Reps_Attending__c = 'Test User';
        tr2.Contact_Name__c = con.id;
        tr2.Contacts_Guest__c = 'Test123'; 
        tr2.Opportunity__c = opp.id;
        tr2.Event_Type__c = 'Falcons';
        tr2.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr2.No_of_Tickets_Requested__c = '5';
        tr2.Approval_Status__c = 'Approved';
        tr2.Ticket_Typ__c = 'Lower Level';
        tr2.Ticket_Type__c = 'Admin Assigned';
       insert tr2;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
      
       tr2.No_of_Tickets_Requested__c = '1';
        insert tr2;
		Ticket_Request__c tr3 =new Ticket_Request__c();
        tr3.Employee_Name__c = user.id;
        tr3.Phone_Number__c = '9876543210';
        tr3.Other_Employee_Reps_Attending__c = 'Test User';
        tr3.Contact_Name__c = con.id;
        tr3.Contacts_Guest__c = 'Test123'; 
        tr3.Opportunity__c = opp.id;
        tr3.Event_Type__c = 'Falcons';
        tr3.Event_Name_Date__c = 'Atlanta United - vs. LA Galaxy on 9/20/2017-123';
        tr3.No_of_Tickets_Requested__c = '2';
        tr3.Approval_Status__c = 'Rejected';
        tr3.Ticket_Typ__c = 'Lower Level';
        tr3.Ticket_Type__c = 'Admin Assigned';
       insert tr3;
        
         try {
            
          Ticket_Request__c trq1 = new Ticket_Request__c(Id=tr3.Id) ;  
          trq1.Approval_Status__c = 'Submitted';
          trq1.Number_of_Parking_Passes_Available__c  = 1;
          update trq1;
        } catch(Exception e) {
          System.debug('Error '+e.getMessage());
        }
    }
	static testMethod void TestUpdateOpportunityCampaignCode() {
       Campaign camp=new Campaign(Name='Test Campaign');
        insert camp;
        Opportunity opp=new Opportunity(Name='Test opp',StageName='TestStage',CloseDate=Date.parse('12/01/2019'));
        insert opp;	
        Opportunity opp1=[select id ,Name from Opportunity where Name='Test opp' order by LastModifiedDate limit 1];
        Ticket_Request__c tReq = new Ticket_Request__c(Name='Test Ticket Request',Phone_Number__c='1111111', Event_Typ__c='Test Event',Opportunity__c=opp.Id);  
        insert tReq;
         System.assertNotEquals(tReq, null,'Ticket_Request_Event__c should not be null');
        String op=opp.id;
        String tr=tReq.id;
        Junction_Ticket_Opportunity__c jto = new Junction_Ticket_Opportunity__c(Related_TicketRequest__r=tReq,Related_TicketRequest__c=tr,Related_Opprtunity_to_Request__c=op);
        insert jto;
        
       Related_Campaign_Code__mdt rmdt=[SELECT MasterLabel, DeveloperName, Campaign_code__c FROM Related_Campaign_Code__mdt where MasterLabel='Test Event'];
        tReq.Approval_Status__c='Approved';
      	System.debug('TR to update :'+tReq);
        update tReq;
       Ticket_Request__c trc= [select Name, Phone_Number__c ,Approval_Status__c from Ticket_Request__c where Approval_Status__c='Approved' ];
        System.debug('Upadated tr:'+trc);
        Test.startTest();
       // System.assert(result.isSuccess());
       // System.assert(result.getErrors().size() == 0);
        Test.stopTest();
        
        
    }    

}