@isTest
public class UpdateAccOwnerForMerge_Test { 
     static testMethod void runTest() {
     	List<Account> accLst = TestRecordsFactory.createAccounts(2);
        Account acc = accLst.get(1);
        acc.ownerId = Userinfo.getUserId(); 
        update acc;
        
        Test.startTest();
         UpdateAccOwnerForMerge.MergeWrapper mw = new UpdateAccOwnerForMerge.MergeWrapper();
         mw.vctmMCN = accLst.get(0).Master_Customer_Number__c;
         mw.srcMCN = accLst.get(1).Master_Customer_Number__c;
         
         List<UpdateAccOwnerForMerge.MergeWrapper> mwLst = new List<UpdateAccOwnerForMerge.MergeWrapper>{mw};            
         Database.executeBatch(new UpdateAccOwnerForMerge(mwLst), 1);        	
        Test.stopTest();
         
     }
}