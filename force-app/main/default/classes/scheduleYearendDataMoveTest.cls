//as250738
@istest
private class scheduleYearendDataMoveTest {
   
    static testmethod void test() {
        scheduleYearendDataMove a = new scheduleYearendDataMove();
        a.execute(null);
        Account acc = TestRecordsFactory.createAccount();
        system.assert(acc!=null);      
        Test.startTest();
            Database.executeBatch(new YearendDataMove()); 
        Test.stopTest();
    }
}