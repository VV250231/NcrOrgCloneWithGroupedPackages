@isTest
private class SearchControllerTest {
    
     static testMethod void runTest() {
         Account acc= TestRecordsFactory.createAccount();
         SearchController.search('Account', new List<String>{'Name','RecordType.Name'},null);    
         SearchController.search('Account', new List<String>{'Name','RecordType.Name'},'test');    
		 SearchController.getRecentlyCreatedRecord(acc.Id, new List<String>{'Name','RecordType.Name'}, 'Account');  
         Fieldwrapper fw = new Fieldwrapper();
         fw.FieldName = 'test';
         fw.Fieldvalue = 'test';
     }

}