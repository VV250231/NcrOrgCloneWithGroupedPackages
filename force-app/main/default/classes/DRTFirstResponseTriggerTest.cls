@isTest
private class DRTFirstResponseTriggerTest {
    @isTest
    private static void CustomerFirstResponseTestMethod(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();    
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(Subject ='Test1',Description__c ='Test1',RecordTypeId =CaseRecordTypeId,Eloqua_Form_Submit_Time__c=Datetime.parse('8/29/2019 2:21 AM')));      
        caseList.add(new Case(Subject ='Test',Description__c ='Test',Origin ='Forms',RecordTypeId =CaseRecordTypeId,Eloqua_Form_Submit_Time__c=Datetime.parse('8/29/2019 2:21 AM')));
        insert caseList;
        List<Case> caseIdWhenOriginForm = [SELECT id,Origin,CreatedDate,Customer_Response_Time__c,Staff_Response_Time__c,Eloqua_Form_Submit_Time__c FROM Case Where Subject='Test'];
        List<Case> caseOrigin = [SELECT id,Origin,CreatedDate,Customer_Response_Time__c,Staff_Response_Time__c,Eloqua_Form_Submit_Time__c FROM Case Where Subject='Test1'];   
        List<Task> emailMessageWhenCaseOriginOther = new List<Task>(); 
        List<Task> emailMessageWhenCaseOriginForm = new List<Task>();             
        emailMessageWhenCaseOriginOther.add(new Task(WhatID = caseOrigin[0].id));
        emailMessageWhenCaseOriginForm.add(new Task(WhatId = caseIdWhenOriginForm[0].id));
        Test.startTest();
        System.assert(emailMessageWhenCaseOriginForm.size()>0);
        System.assert(emailMessageWhenCaseOriginOther.size()>0);
        insert emailMessageWhenCaseOriginOther;
        insert emailMessageWhenCaseOriginForm;
        Test.stopTest();    
    }

}