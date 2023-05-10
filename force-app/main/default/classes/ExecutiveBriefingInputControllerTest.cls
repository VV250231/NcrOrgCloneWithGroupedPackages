@isTest
public class ExecutiveBriefingInputControllerTest {
        
        @isTest static void MethodOne() {
         Account Acc =  TestRecordsFactory.createAccount();
         Contact Con1 =  TestRecordsFactory.createContact(Acc);
         Contact Con2 =  TestRecordsFactory.createContact(Acc);
         Contact Con3 =  TestRecordsFactory.createContact(Acc);
         Contact Con4 =  TestRecordsFactory.createContact(Acc);
         List<Contact> Conlist= new List<Contact>();
         Conlist.add(Con1 );
         Conlist.add(Con2 );
         Conlist.add(Con3 );
         Conlist.add(Con4 );
         
         Opportunity Opp1 =TestRecordsFactory.createOpportunityWithContact(Con1,Acc);
         System.assertEquals(Opp1.Name, 'OppQuote Linkage Opportunity','Opportunity is null'); 
         test.startTest();
         Opportunity Opp2 =TestRecordsFactory.createOpportunityWithContact(Con2,Acc);
         Opportunity Opp3 =TestRecordsFactory.createOpportunityWithContact(Con3,Acc);
         Opportunity Opp4 =TestRecordsFactory.createOpportunityWithContact(Con4,Acc);
         test.stopTest();
         
         
         
        PageReference pageRef = Page.ExecutigBriefingInput;
        pageRef.getparameters().put('id', Acc.id);  
        Test.setCurrentPage(pageRef);
         

         // Put Id into the current page Parameters
         //ApexPages.currentPage().getParameters().put('id',Acc.Id);
         

         Executive_Briefing__c EbObj = new Executive_Briefing__c();
         //EbObj.Name='TestCoverage EB';
         EbObj.Account_Manager_Sales_Leader__c=Acc.id;
         EbObj.Customer_Attendee1__c=Con1.id;
         EbObj.Customer_Attendee_2__c=Con2.id;
         EbObj.Customer_Attendee_3__c=Con3.id;
         EbObj.Customer_Attendee_4__c=Con4.id;
         EbObj.Customer_Attendee_5__c=Con1.id;
         EbObj.Name__c=Acc.id;
         EbObj.Opportunity_1__c=Opp1.Id;
         EbObj.Opportunity_2__c=Opp2.Id;
         EbObj.Opportunity_3__c=Opp3.Id;
         EbObj.Opportunity_4__c=Opp4.Id;
         EbObj.NCR_Attendee_1__c=userinfo.getuserid();
         EbObj.NCR_Attendee_2__c=userinfo.getuserid();
         EbObj.NCR_Attendee_3__c=userinfo.getuserid();
         EbObj.NCR_Attendee_4__c=userinfo.getuserid();
         insert EbObj;
         ExecutiveBriefingInputController EbClassObj= new ExecutiveBriefingInputController();
         Apexpages.StandardController sc = new Apexpages.StandardController(Acc); 
         ExecutiveBriefingInputController EBformObj = new ExecutiveBriefingInputController(sc);
         
         EBformObj .AddMore();
         EBformObj .getContactName();
         EBformObj .ContactDetail();
         EBformObj .retrieveTitle1();
         EBformObj .retrieveTitle2();
         EBformObj .retrieveTitle3();
         EBformObj .retrieveTitle4();
         EBformObj .PreparelistCustomerAttendee(EbObj,Conlist);
         EBformObj.strImageBlob='test Attchment';
         EBformObj.UpdateCustomerAttendee(EbObj.id); 
         
        }
        
        @isTest static void MethodTwo() {
            
            Account Acc =  TestRecordsFactory.createAccount();
         Contact Con1 =  TestRecordsFactory.createContact(Acc);
         Contact Con2 =  TestRecordsFactory.createContact(Acc);
         Contact Con3 =  TestRecordsFactory.createContact(Acc);
         Contact Con4 =  TestRecordsFactory.createContact(Acc);
         List<Contact> Conlist= new List<Contact>();
         Conlist.add(Con1 );
         Conlist.add(Con2 );
         Conlist.add(Con3 );
         Conlist.add(Con4 );
         
         Opportunity Opp1 =TestRecordsFactory.createOpportunityWithContact(Con1,Acc);
         System.assertNotEquals(Opp1, null,'Opportunity is null'); 
         test.StartTest();
         Opportunity Opp2 =TestRecordsFactory.createOpportunityWithContact(Con2,Acc);
         Opportunity Opp3 =TestRecordsFactory.createOpportunityWithContact(Con3,Acc);
         Opportunity Opp4 =TestRecordsFactory.createOpportunityWithContact(Con4,Acc);
         
          test.StopTest();
         
         
       
         

         // Put Id into the current page Parameters
         //ApexPages.currentPage().getParameters().put('id',Acc.Id);
         

         Executive_Briefing__c EbObj = new Executive_Briefing__c();
         //EbObj.Name='TestCoverage EB';
         EbObj.Name__c=Acc.id;
         EbObj.Account_Manager_Sales_Leader__c=Acc.id;
         EbObj.Customer_Attendee1__c=Con1.id;
         EbObj.Customer_Attendee_2__c=Con2.id;
         EbObj.Customer_Attendee_3__c=Con3.id;
         EbObj.Customer_Attendee_4__c=Con4.id;
         EbObj.Customer_Attendee_5__c=Con1.id;
         EbObj.Name__c=Acc.id;
         EbObj.Opportunity_1__c=Opp1.Id;
         EbObj.Opportunity_2__c=Opp2.Id;
         EbObj.Opportunity_3__c=Opp3.Id;
         EbObj.Opportunity_4__c=Opp4.Id;
         EbObj.NCR_Attendee_1__c=userinfo.getuserid();
         EbObj.NCR_Attendee_2__c=userinfo.getuserid();
         EbObj.NCR_Attendee_3__c=userinfo.getuserid();
         EbObj.NCR_Attendee_4__c=userinfo.getuserid();
         insert EbObj;
         
         
        PageReference pageRef = Page.ExecutigBriefingInput;
        System.assertNotEquals(pageRef, null,'pageRef is null'); 
        pageRef.getparameters().put('id',EbObj.Id);  
        Test.setCurrentPage(pageRef);
         
         
         ExecutiveBriefingInputController EbClassObj= new ExecutiveBriefingInputController();
         System.assertNotEquals(EbObj.id, null,'Executive Briefing is null');
         Apexpages.StandardController sc = new Apexpages.StandardController(EbObj); 
         System.assertNotEquals(sc, null,'StandardController is null'); 
         ExecutiveBriefingInputController EBformObj = new ExecutiveBriefingInputController(sc);
         
         EBformObj .AddMore();
         EBformObj .getContactName();
         EBformObj .ContactDetail();
         EBformObj .retrieveTitle1();
         EBformObj .retrieveTitle2();
         EBformObj .retrieveTitle3();
         EBformObj .retrieveTitle4();
         EBformObj .PreparelistCustomerAttendee(EbObj,Conlist);
         EBformObj.strImageBlob='test Attchment';
         EBformObj.UpdateCustomerAttendee(EbObj.id); 
         EBformObj.saveExecBrfng();
         EBformObj.SaveHirarchy();
         EBformObj.save();
        
 
        }
        
        
}