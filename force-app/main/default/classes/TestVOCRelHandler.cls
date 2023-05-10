@isTest
private class TestVOCRelHandler {    
     static testmethod void relTest() {
     	  List<Account> accLst = TestRecordsFactory.createAccounts(5);
          Contact c = TestRecordsFactory.createContact(accLst.get(0));
         
         VOCRelHandler.handleConAccAssoc(c.Id, new Set<String>{accLst.get(1).Master_Customer_Number__c, accLst.get(2).Master_Customer_Number__c, accLst.get(3).Master_Customer_Number__c}, accLst.get(0).Id);
         AccountContactRelation acRel = [SELECT IsActive,IsDirect,Roles FROM AccountContactRelation WHERE AccountId = :accLst.get(2).Id and ContactId=:c.Id];
		 System.assert(acRel != NULL);
   		 System.assertEquals(acRel.Roles, 'MyNCR User');
         
         acRel.IsActive =false;
         update acRel;
         VOCRelHandler.handleConAccAssoc(c.Id, new Set<String>{accLst.get(0).Master_Customer_Number__c, accLst.get(2).Master_Customer_Number__c}, accLst.get(1).Id);
     }
}