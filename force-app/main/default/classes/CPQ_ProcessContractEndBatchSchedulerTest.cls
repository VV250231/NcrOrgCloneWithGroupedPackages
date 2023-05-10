@isTest
public with sharing class CPQ_ProcessContractEndBatchSchedulerTest {
    @isTest public static void myTestMethod() {        
        test.starttest();
        CPQ_ProcessContractEndBatchScheduler testSche = new CPQ_ProcessContractEndBatchScheduler ();   
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );        
        test.stopTest();
   }
}