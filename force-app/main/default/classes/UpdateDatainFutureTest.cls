@isTest
private class UpdateDatainFutureTest {
    static testMethod void runTest(){
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc =new Account();
        Account acc1 =new Account();
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
            acc.Name='Test Enterprise';
            acc.Master_Customer_Number__c = 'Test';
            insert acc;
            acc1.Name='Test Enterprise1';
            acc1.Master_Customer_Number__c = 'Test1';
            acc1.RecordTypeId = customerRecordTypeId;
            acc1.ParentId = acc.id;
            insert acc1;
        }
        UpdateDatainFuture.processRecords(new List<ID>{acc1.Id});
        account accObj = [select Global_Ultimate_Lookup__c from account where id=:acc1.id];
        System.assert(accObj.Global_Ultimate_Lookup__c==null);
    }
}