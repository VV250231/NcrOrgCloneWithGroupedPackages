@isTest
public with sharing class InvoiceRunTriggerServiceTest {
    static String   INVOICE_BATCH_1     = 'Batch 1',
                    INVOICE_BATCH_2     = 'Batch 2',
                    STATUS_STARTED      = 'Started',
                    STATUS_COMPLETED    = 'Completed';
    @isTest 
    static void afterUpdate_MultipleBatchPositiveTest(){
        Date today = Date.today();
        DateTime startDateTime = Datetime.now();
        blng__InvoiceScheduler__c invoiceScheduler = new blng__InvoiceScheduler__c(
            Name = 'testscheduler1',
            blng__InvoiceBatches__c = INVOICE_BATCH_1,
            blng__InvoiceDate__c = today,
            blng__InvoiceDayOfMonth__c = '1',
            blng__InvoiceDayOfWeek__c = '1',
            qtc_Single_Invoice_Run__c = false,
            blng__StartDateTime__c = startDateTime.addMinutes(1),
            blng__Type__c = 'Once'
        );

        insert invoiceScheduler;

        blng__InvoiceRun__c testInoiceRun = new blng__InvoiceRun__c(
            blng__InvoiceScheduler__c = invoiceScheduler.Id,
            blng__InvoiceDate__c = today,
            blng__StartTime__c = invoiceScheduler.blng__StartDateTime__c,
            blng__TargetDate__c = today.addDays(1),
            blng__Status__c = STATUS_STARTED
        );
        insert testInoiceRun;

        List<blng__InvoiceRun__c> listInvoiceRunBeforeUpdate = [SELECT Id FROM blng__InvoiceRun__c];
        System.assertEquals(1, listInvoiceRunBeforeUpdate.size(), 'we expect 1 invoice runs');
        Test.startTest();
            SBQQ.TriggerControl.disable();
            testInoiceRun.blng__Status__c = STATUS_COMPLETED;
            update testInoiceRun;
            SBQQ.TriggerControl.enable();
        Test.stopTest();
        List<blng__InvoiceRun__c> listInvoiceRunResult = [SELECT Id, blng__Status__c FROM blng__InvoiceRun__c];
        System.debug('### listInvoiceRunResult '+ listInvoiceRunResult);
        System.assertEquals(1, listInvoiceRunResult.size(), 'we expect this number of invoice runs');
        
        List<blng__InvoiceScheduler__c> listInvoiceSchedulerResult = [SELECT Id, blng__StartDateTime__c, blng__InvoiceBatches__c FROM blng__InvoiceScheduler__c];
        System.assertEquals(1, listInvoiceSchedulerResult.size(), 'We expect only 1 Scheduler');
        System.assertEquals(INVOICE_BATCH_2, listInvoiceSchedulerResult[0].blng__InvoiceBatches__c, 'We expect the batch to be updated to batch 2');
        System.assert( listInvoiceSchedulerResult[0].blng__StartDateTime__c > invoiceScheduler.blng__StartDateTime__c , 'We expect the start date time to be updated to a future time');
    }

    @isTest 
    static void afterUpdate_SinglePositiveTest(){
        Date today = Date.today();
        DateTime startDateTime = Datetime.now();
        blng__InvoiceScheduler__c invoiceScheduler = new blng__InvoiceScheduler__c(
            Name = 'testscheduler1',
            blng__InvoiceBatches__c = INVOICE_BATCH_1,
            blng__InvoiceDate__c = today,
            blng__InvoiceDayOfMonth__c = '1',
            blng__InvoiceDayOfWeek__c = '1',
            qtc_Single_Invoice_Run__c = true,
            blng__StartDateTime__c = startDateTime.addMinutes(1),
            blng__Type__c = 'Once'
        );

        insert invoiceScheduler;

        blng__InvoiceRun__c testInoiceRun = new blng__InvoiceRun__c(
            blng__InvoiceScheduler__c = invoiceScheduler.Id,
            blng__InvoiceDate__c = today,
            blng__StartTime__c = invoiceScheduler.blng__StartDateTime__c,
            blng__TargetDate__c = today.addDays(1),
            blng__Status__c = STATUS_STARTED
        );
        insert testInoiceRun;

        List<blng__InvoiceRun__c> listInvoiceRunBeforeUpdate = [SELECT Id FROM blng__InvoiceRun__c];
        System.assertEquals(1, listInvoiceRunBeforeUpdate.size(), 'we expect 1 invoice runs');
        Test.startTest();
            SBQQ.TriggerControl.disable();
            testInoiceRun.blng__Status__c = STATUS_COMPLETED;
            update testInoiceRun;
            SBQQ.TriggerControl.enable();
        Test.stopTest();
        List<blng__InvoiceRun__c> listInvoiceRunResult = [SELECT Id, blng__Status__c FROM blng__InvoiceRun__c];
        System.debug('### listInvoiceRunResult '+ listInvoiceRunResult);
        System.assertEquals(1, listInvoiceRunResult.size(), 'we expect this number of invoice runs');
        
        List<blng__InvoiceScheduler__c> listInvoiceSchedulerResult = [SELECT Id, blng__StartDateTime__c, blng__InvoiceBatches__c FROM blng__InvoiceScheduler__c];
        System.assertEquals(1, listInvoiceSchedulerResult.size(), 'We expect only 1 Scheduler');
        System.assertEquals(INVOICE_BATCH_1, listInvoiceSchedulerResult[0].blng__InvoiceBatches__c, 'We expect the batch to be the same');
        System.assertEquals( invoiceScheduler.blng__StartDateTime__c, listInvoiceSchedulerResult[0].blng__StartDateTime__c , 'We expect the start date time to be the same');
    }
}