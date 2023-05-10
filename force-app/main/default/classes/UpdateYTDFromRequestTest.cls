@isTest
public class UpdateYTDFromRequestTest {
    static testmethod void unitTest1(){
        Account a = PRM_TestRecordsFactory.createPartnerAccount('suffix', new Map<String,String>());
        system.runAs([Select Id from User WHERE Name = 'Soup User' LIMIT 1][0]){
        insert a;
        }
        SFDC_MDF__c fundReq =new SFDC_MDF__c();
        fundReq.Account__c = a.Id;
        fundReq.Total_NCR_Estimated_Participation__c = 9000;
        fundReq.Total_NCR_Approved__c = 9000;
        fundReq.Request_Submission_Date__c = system.today();
        fundReq.Activity_Date__c = system.today();
        fundReq.End_Date__c = system.today();
        test.startTest();
        insert fundReq;
        UpdateYTDFromRequest.SendCurrentPartnerAccount(a.Id);
        UpdateYTDFromRequest.AveragePartnerUse(a.Id);
        system.assertNotEquals(UpdateYTDFromRequest.AveragePartnerUse(a.Id),null);
        test.stopTest();
    }
}