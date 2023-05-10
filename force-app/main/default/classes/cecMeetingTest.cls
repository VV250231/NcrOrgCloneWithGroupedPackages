/*############################################################################################################
# Description...........: This test class is for CEC functionality.It covers cECGetPickListValueController,
MultiSelectLookupController,CECMeetingTrigger, CECMeetingTriggerHandler
# Created by......: Sushant, Saurav, Yogesh, Monika 
# Created Date....: Nov 2021.  
# Story Number ......: EBA_SF-1607 , EBA_SF-1606 , EBA_SF-1605 , EBA_SF-1554
##############################################################################################################*/
@isTest
private class cecMeetingTest {
    @isTest static void myTest() {       
        CEC__c cecObj1 = new CEC__c();        
        cecObj1.Experience_Center__c = 'Dundee';
        cecObj1.Name = 'cecTest1';
        cecObj1.Meeting_Purpose__c = 'Customer at Risk';
        cecObj1.Customer_Expectations__c ='test';
        cecObj1.NCR_Expectations__c ='test';
        cecObj1.Ideal_Meeting_Duration__c = '15 Minutes';
        cecObj1.Customer_Time_Zone__c = '(GMT+14:00) Line Is. Time (Pacific/Kiritimati)';
        cecObj1.X1st_Potential_Meeting_Date_Time__c = system.today();
        cecObj1.X2nd_Potential_Meeting_Date_Time__c = system.today();
        cecObj1.Temperature__c = 'Red';
        cecObj1.Bypass_Val__c = true;

        cecObj1.RFP_Affiliation__c= 'No';
        cecObj1.RFP_Name__c= 'Testt';
        cecObj1.RVP_Aware__c= 'Yes';
        cecObj1.NCR_solutions__c='Test';
        cecObj1.Customer_Competitors__c= TestRecordsFactory.createCompetitor().id;
        cecObj1.Name_of_company_for_meeting_materials__c= 'Test';
        cecObj1.Personal_Customer_Considerations__c = 'Test';
        cecObj1.Presenters_already_secured__c= 'Test';
        cecObj1.Special_notes_requests__c= 'Test';
        List<String> ContactIds = new List<String>();
        List<String> UserIds = new List<String>();
        List<String> OppIds = new List<String>();
        List<CEC_Attendees__c> ExtUserList = new List<CEC_Attendees__c>();
        List<CEC_Attendees__c> UserNotInSF = new List<CEC_Attendees__c>();
        List<Account> acc = TestRecordsFactory.createAccounts(1);
        Opportunity opp  = TestRecordsFactory.createSimpleOpportunity(acc[0]);
        ID idOpp = opp.id;
        ID idAcc = acc[0].id;
        
        //Add contact Attendee
        Contact cn = TestRecordsFactory.createContact(acc[0]);
        ContactIds.add(cn.id);
        
       //Add internal Attendee 
        User us = TestRecordsFactory.getUser();
        UserIds.add(us.id);
        
        //Add external Attendee
        CEC_Attendees__c Attnd= new CEC_Attendees__c();
        Attnd.Attendee_Name_External__c='test';
        Attnd.Email__c='test@test.com';
        Attnd.Role__c='test';
        ExtUserList.add(Attnd);
        
        //Add internal Attendee not in SF
        CEC_Attendees__c Att= new CEC_Attendees__c();
        Att.Non_Sf_NCR__c='test not in SF';
        Att.Is_Non_Sf_NCR__c = True;
        Att.Email__c='test@test.com';
        Att.Role__c='test';
        UserNotInSF.add(Att);
        
        //add opportunity to be influenced
        Opportunity op = TestRecordsFactory.createSimpleOpportunity();
        
        //add the some random campaign other then CEC_Visit to the opportunity
        OppIds.add(op.Id);
        OppIds.add(idOpp);     
        
        String str1 = 'Opportunity' ;
        String str2 = opp.id; 
        
        insert new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=cn.id);               
        cECGetPickListValueController controller = new cECGetPickListValueController();
        
        CEC__c cecObj2 = new CEC__c();        
        cecObj2.Experience_Center__c = 'Dundee';
        cecObj2.Name = 'cecTest2';
        cecObj2.Meeting_Purpose__c = 'Customer at Risk';
        cecObj2.Customer_Expectations__c ='test';
        cecObj2.NCR_Expectations__c ='test';
        cecObj2.Ideal_Meeting_Duration__c = '15 Minutes';
        cecObj2.Customer_Time_Zone__c = '(GMT+14:00) Line Is. Time (Pacific/Kiritimati)';
        cecObj2.X1st_Potential_Meeting_Date_Time__c = system.today();
        cecObj2.X2nd_Potential_Meeting_Date_Time__c = system.today();
        cecObj2.Temperature__c = 'Red';
        cecObj2.Bypass_Val__c = true;
        cecObj2.RFP_Affiliation__c= 'Yes';
        cecObj2.RFP_Name__c= 'Test';
 
        cecObj2.RVP_Aware__c= 'Yes';
        cecObj2.NCR_solutions__c='Test';
        cecObj2.Customer_Competitors__c= TestRecordsFactory.createCompetitor().id;
       
        cecObj2.Name_of_company_for_meeting_materials__c= 'Test';
        cecObj2.Personal_Customer_Considerations__c = 'Test';
        cecObj2.Presenters_already_secured__c= 'Test';
        cecObj2.Special_notes_requests__c= 'Test';
      
        
        Test.startTest(); 
        ID cecId1 = cECGetPickListValueController.start(cecObj1,ContactIds,UserIds,UserNotInSF,OppIds,ExtUserList,str1,str2).id;
         System.assert(cecId1 != null,'CEC record not created');
        CEC__c cecObj =[Select id,Meeting_Status__c from CEC__c where id=:cecId1];
                                           
        ID cecId2 = cECGetPickListValueController.start(cecObj2,ContactIds,UserIds,UserNotInSF,OppIds,ExtUserList,str1,str2).id;
        System.assert(cecId2 != null,'CEC record not createdl');
        CEC__c cecOb =[Select id,Meeting_Status__c from CEC__c where id=:cecId2];
                                   

        cecOb.Meeting_Status__c ='Cancelled';
        CECMeetingTriggerHandler.isFlag=true;
        update cecOb; 
        

        cecObj.Meeting_Status__c ='Cancelled';
        CECMeetingTriggerHandler.isFlag=true;
        update cecObj; 
        
        //This line covers the MultiSelectLookupController class
         MultiSelectLookupController.retrieveRecords('Opportunity','Name,Opportunity_Number__c,AccountId','Name,Opportunity_Number__c','Opp',idOpp);
         MultiSelectLookupController.retrieveRecords('User','Id,Name,Email','Name','Monika Ma',idOpp);  
        
        //This line covers the cECGetPickListValueController class
        cECGetPickListValueController.pickListValueDynamically(new cec__c(),'Meeting_Purpose__c');
        Test.stopTest();

        
    }
}