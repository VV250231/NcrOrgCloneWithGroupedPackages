@isTest(SeeAllData=false)
private class AbortSalesOrderJobsTest {

    static testmethod void runTest() {
        Test.startTest();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('AbortSalesOrderJobs',CRON_EXP, new AbortSalesOrderJobs());
        Test.stopTest();
        system.assertNotEquals(jobId, null);

    }
}