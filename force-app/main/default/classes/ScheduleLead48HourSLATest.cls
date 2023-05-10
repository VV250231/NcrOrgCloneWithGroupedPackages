@isTest
private class ScheduleLead48HourSLATest {
    static testMethod void runLeadSLA() {
          Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
          List<GroupMember> SDLTeamGrp = [select UserOrGroupId,GroupId  from GroupMember where Group.type='Regular' AND Group.DeveloperName='SDL_Team']  ;
           
           
          Lead lead = TestRecordsFactory.createLead();
          User SalesRep = TestRecordsFactory.createUsers(stdProfile.Id, 'LeadTest', 1).get(0);
          NSC_Support_Error_Notification__c supportNotf = new NSC_Support_Error_Notification__c(name = 'NSC Job Failure', ToEmailAddresses__c='leadtest@testorg.com');
          insert supportNotf;
          
          lead.OwnerId = SDLTeamGrp.get(0).UserOrGroupId; // Lead assigned to SDL Team
          update lead;  
          
          lead.OwnerId = SalesRep.Id;   // lead assigned to Sales Rep
          update lead;
          
          
          
          Test.startTest();
            lead.AssignToSalesRepDate__c  = Datetime.now().addHours(-50); 
            update lead;
            List<Lead> leadList = [SELECT Id, AssignToSalesRep__c, AssignToSalesRepDate__c, NotificationForSalesRep__c, IsConverted, Status
                                             FROM Lead];
            System.debug(leadList); 
            Database.executeBatch(new ProcessSalesRep48HourLeadSLA()); 
            String TEST_CRON_EXP = '0 25 * * * ?';
            String jobID = System.schedule('Lead 48 Hour SLA Test', TEST_CRON_EXP, new ScheduleLead48HourSLA());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobID];
        	System.assertEquals(TEST_CRON_EXP, ct.CronExpression);
           
            new ProcessSalesRep48HourLeadSLA().sendErrorNotification('Lead error test');           
          Test.stopTest(); 
   
    }
}