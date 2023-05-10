@isTest
Public Class SaveHeadMap_Test{
    @isTest Public Static Void Mtehod1(){
        
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
         Opp1.StageName='Closed/Booked';
         Opp1.IsQuoteCreatedInOtherSystem__c='YES';
         Opp1.Price_Variance__c='NCR above 5%';
         
         Opp1.Key_Criteria__c='Business Benefits';
         Opp1.You_have_not_selected_any_TS_HWM_or_SW__c='test';
         Opp1.Closed_Booked_Comments__c='Test Comment';
         Opp1.CLM_Sales_Acknowledgment__c=true;
          
               test.StartTest(); 
         OpportunityLineItem oli = TestRecordsFactory.createOpportunityLineItem(Opp1 , TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
         
         
         update Opp1;
        system.assert(Opp1 !=null);
		         
     
          
             Opportunity Opp2 =TestRecordsFactory.createOpportunityWithContact(Con2,Acc);
             Opportunity Opp3 =TestRecordsFactory.createOpportunityWithContact(Con3,Acc);
             Opportunity Opp4 =TestRecordsFactory.createOpportunityWithContact(Con4,Acc);
         test.StopTest();
             
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
         
         
            Attachment attach=new Attachment();       
            attach.Name='HeatMap';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=EbObj.id;
            insert attach;
            
            
         PageReference pageRef = Page.ExecutiveBriefingPDFNEW;
         pageRef.getparameters().put('id', EbObj.id);  
         Test.setCurrentPage(pageRef);
        
        
         Apexpages.StandardController sc = new Apexpages.StandardController(EbObj); 
         SaveHeadMap EBformObj = new SaveHeadMap(sc);
         
         //HeatMapExtension HeatMapExtObjWithOutParam = new HeatMapExtension();
         Apexpages.StandardController sc1 = new Apexpages.StandardController(EbObj); 
         HeatMapExtension  HeatMapExtObj = new HeatMapExtension (sc1);
         
         EBformObj.SaveHirarchyImage();
         EBformObj.strImageBlob='Test Attachment';
         EBformObj.SaveHirarchyImage();         
        
            
    }    
}