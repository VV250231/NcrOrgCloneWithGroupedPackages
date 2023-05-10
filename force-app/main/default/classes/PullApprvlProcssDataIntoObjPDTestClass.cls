@isTest(SeeAllData=false)
global class PullApprvlProcssDataIntoObjPDTestClass{
    static{
    
       Profile p = [SELECT Id FROM Profile WHERE Name = '54 Hosted Solutions Sales Operations']; 
       User objUser = new User(Quicklook_ID__c = 'zx185042', Alias = 'tstAppr', Email='TestApproval@testorg.com', 
                         EmailEncodingKey='UTF-8', LastName='TestApproval', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = p.Id, 
                         TimeZoneSidKey='America/Los_Angeles', UserName='TestApproval@testorg.com');

      System.runAs(objUser) 
      {
        zqu__Quote__c testQuote = new zqu__Quote__c();
        testQuote.Name          = 'Quote For Test Class';
        testQuote.zqu__Status__c = 'QA Processing Complete' ;
        testQuote.Site_Address_Information__c='site address information';  //SC2015_AGL-5809
        testQuote.Concept__c='TS'; //SC2015_AGL-5809  
        insert testQuote;
        System.assertNotEquals(testQuote.id, null,'Quote is Null');
        if([select count() from ProcessInstance where targetobjectid=:testQuote.id] < 1)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(testQuote.id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
        }
       } 
    }
    
    static testmethod void testCovertheHTProduct()
    {
        Test.startTest();
        Id batchInstanceId = Database.executeBatch(new PullApprvlProcssDataIntoObjProcssDtails()); 
        SchedulepullApprovalProcessDetailsClass obj = new SchedulepullApprovalProcessDetailsClass();
        obj.execute(null);
        Test.stopTest();
    }
}