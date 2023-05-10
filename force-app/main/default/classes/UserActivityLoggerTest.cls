@isTest
public class UserActivityLoggerTest {
    
    testMethod static void Test1()
    {
        Test.startTest();
        UserActivityLogger.logUserActivityWithFuture('tabTest');
        UserActivityLogger.logUserActivityWithFuture('tabTest');
        UserActivityLogger.logUserActivityWithFuture('tabTest');
        
        UserActivityLogger.logSesmicActivity('Account');
        UserActivityLogger.logSesmicActivity('Account');
        UserActivityLogger.logUserActivity('Account');
        UserActivityLogger.updateCount();
        system.assert(UserActivityLogger.updateCount()==null);
        
        
        
        Test.stopTest();
        
    }
}