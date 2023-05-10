@isTest
public class ExecBriefingControllerTest {
    static testMethod void unitTest() {  
     List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Executive_Briefing__c' ];
        ExecBriefingController.getListViews();
        Account acc = TestRecordsFactory.createAccount();
        Executive_Briefing__c exb = TestRecordsFactory.createEXB(acc.id);
        system.assert(exb.id!=null);
        ExecBriefingController.getReqFields(acc.id);
        ExecBriefingController.getLabelofEXBFields();
        ExecBriefingController.getUserProfile(acc.id);
    }
}