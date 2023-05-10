@isTest(SeeAllData=false)
public class PullApprovalDataOfQuotes_RealTimeTest{
  
    private static list<Id> idLst = new List<Id>();
    static testmethod void testPullData()
    {
        Test.startTest();
       {
        zqu__Quote__c testQuote = new zqu__Quote__c();
        testQuote.Name          = 'Quote For Test Class';
        testQuote.zqu__Status__c = 'QA Processing Complete' ;
        //insert testQuote;
        List<zqu__Quote__c > lstQuote = new List<zqu__Quote__c>();
        lstQuote.add(testQuote);
        insert lstQuote ;
        System.assertNotEquals(lstQuote, null,'Quote is Null');
        
        idLst.add(lstQuote[0].id);
        
        if([select count() from ProcessInstance where targetobjectid=:testQuote.id] < 1)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(lstQuote[0].id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
            
            PullApprovalDataOfQuotes_RealTime.pullData(idLst);
        }
       } 
        Test.stopTest();
    }
}