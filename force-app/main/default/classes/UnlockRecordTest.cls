@isTest
public with sharing class UnlockRecordTest {
    
    
    
    @isTest
    public static void CanUnlockRecord () {
        
        //create record
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Data Backup and Recovery Admin']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorvjkhbvjhgejghwefg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          Quicklook_ID__c = '293103',
                          TimeZoneSidKey='America/New_York', UserName='standarduser@testorvjkhbvjhgejghwefg.com');
        insert u;
        
        System.runAs(u) {
            Account testAct1 = new Account();
            testAct1.Name = 'testAccount1';
            insert testAct1;
            
            
            //lock it
            Approval.lock(testAct1.Id);
            
            //call UnlockRecord
            UnlockRecord.Request testReq = new UnlockRecord.Request();
            testReq.recordId = testAct1.Id;
            
            List<UnlockRecord.Request> reqList = new List<UnlockRecord.Request>();
            reqList.add(testReq);
            
            List<UnlockRecord.Response> unlockResponseList = UnlockRecord.Unlock(reqList);
            
            //inspect result
            
            System.assertEquals(unlockResponseList[0].isSuccess,true);
            System.assertEquals(Approval.isLocked(testAct1.Id), false);
            
            
        }
        
        
    }
    
}