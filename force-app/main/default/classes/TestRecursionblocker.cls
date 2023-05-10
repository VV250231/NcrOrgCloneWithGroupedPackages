@isTest
private class TestRecursionblocker {
    static testMethod void runTest() {
        Recursionblocker.flag = true;
        system.assertEquals(Recursionblocker.flag , true);
    }
}