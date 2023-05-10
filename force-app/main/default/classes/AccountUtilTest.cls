@isTest
private class AccountUtilTest {
    public static testMethod void testUpdate() {
        list<Account> acclist=new list<Account>();
        set<string> recordTypeSet=new set<string>();
        
        Account a;
        List<RecordType> recordTypelst=[Select Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Account' AND Name in('customer','Partner')];  
        
        for(RecordType rt :recordTypelst) {
            recordTypeSet.add(rt.Id);    
        }
             
        Account a1 = new Account(name='TestAccount1',RecordTypeId=recordTypelst[0].Id,Account_Country_Code__c='BM');
        system.runAs(TestRecordsFactory.getUser()){
          insert a1;  
        }
        
        Account a2 = new Account(name='TestAccount2',RecordTypeId=recordTypelst[0].Id,Account_Country_Code__c='BM');
        acclist.add(a2);
        
        for(integer i=1;i<=150;i++)
        {
            a=new account(name='testacc',RecordTypeId=recordTypelst[0].id,Account_Country_Code__c='BM');
            acclist.add(a);
        }        
        system.runAs(TestRecordsFactory.getUser()){
             insert acclist;            
        }   
        
        new AccountUtil().populateAccwithMCN(a1, recordTypeSet);
        Account acc1 = new AccountUtil().populateAccwithMCN(a2, recordTypeSet);
        system.assertNotEquals(acc1.id, null);
         
    }
}