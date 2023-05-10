@isTest
private class EmailCreatedTimeTriggerTestClass {
    @testSetup
    private static void CustomerFirstResponseTestMethodTest(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();    
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(Subject ='SubTest',Description__c ='Test1',RecordTypeId =CaseRecordTypeId,Eloqua_Form_Submit_Time__c=Datetime.parse('8/29/2019 2:21 AM')));      
       // caseList.add(new Case(Subject ='TestTest',Description__c ='Test',Origin ='Forms',RecordTypeId =CaseRecordTypeId,Eloqua_Form_Submit_Time__c=Datetime.parse('8/29/2019 2:23 AM')));
        insert caseList;
        System.assertNotEquals(caseList, null,'caseList should not be null');
    }
    @isTest
    private static void testEmailMassage(){
        CaseToFeedItemHelper.duration_between_two_date_times(Datetime.parse('8/29/2019 2:21 AM'),Datetime.parse('9/29/2019 2:21 AM'));
       
        CaseToFeedItemHelper.duration_between_two_date_times1(Datetime.parse('8/29/2019 2:20 AM'),Datetime.parse('9/29/2019 2:21 AM'));
        Case caseIdWhenOriginForm = [SELECT id FROM Case Where Subject='SubTest'];
        //List<Case> caseOrigin = [SELECT id FROM Case Where Subject='TestTest'];   
        List<EmailMessage> emailMessageWhenCaseOriginOther = new List<EmailMessage>(); 
        List<EmailMessage> emailMessageWhenCaseOriginForm = new List<EmailMessage>();             
        emailMessageWhenCaseOriginOther.add(new EmailMessage(ParentId = caseIdWhenOriginForm.id,CcAddress ='test@test1.com',FromAddress = 'test@test1.com'));
        //emailMessageWhenCaseOriginForm.add(new EmailMessage(ParentId = caseOrigin[0].id,CcAddress ='test@test1.com',FromAddress = 'test@test1.com'));
        Test.startTest();
        insert emailMessageWhenCaseOriginOther;
        //insert emailMessageWhenCaseOriginForm;
        Test.stopTest();    
           System.assertNotEquals(emailMessageWhenCaseOriginOther, null,'emailMessageWhenCaseOriginOther should not be null');

    }
}