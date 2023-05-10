/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class that covers Hospitality Service Cloud custom integration logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-05-20
* @modified       2022-05-25
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-05-20
*
* v1.1            ba250204@ncr.com
* 2022-07-15      Switch from "make" to "mock" sObject
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest
public class HSRDispatchToESTest {
    @TestSetup
    static void setup() {
        Automation_Setting__c setting = new Automation_Setting__c(
                Skip_Trigger__c = true,
                Skip_Validation_Rule__c = true,
                Skip_Flow__c = true,
                Skip_Outbound_Integration__c = true
        );
        insert setting;
    }

    @IsTest
    private static void testOutbound_success() {
        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        HSRSelector.mockWorkOrders = new List<WorkOrder>{
                workOrder
        };

        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.WorkOrderCalloutMock_Success());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Test.startTest();
        List<HSRDispatchToES.HSROutboundResult> results = HSRDispatchToES.dispatchNewRequest(new List<String>{
                workOrder.Id
        });

        Test.stopTest();

        System.assertEquals(0, getErrorNumbers());
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].isSuccess);
        System.assertEquals(null, results[0].errorMessage);

    }
    @IsTest
    private static void testOutbound_success_batch() {
        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        WorkOrder workOrder2 = HSRDataFactory.mockWorkOrder(2);
        HSRSelector.mockWorkOrders = new List<WorkOrder>{
                workOrder, workOrder2
        };

        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.WorkOrderCalloutMock_Success());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Test.startTest();
        List<HSRDispatchToES.HSROutboundResult> results = HSRDispatchToES.dispatchNewRequest(new List<String>{
                workOrder.Id, workOrder2.Id
        });

        Test.stopTest();

        System.assertEquals(0, getErrorNumbers());
        System.assertEquals(2, results.size());
        for (HSRDispatchToES.HSROutboundResult result : results) {
            System.assertEquals(true, result.isSuccess);
            System.assertEquals(null, result.errorMessage);
        }
    }

    @IsTest
    private static void testOutbound_missingRequiredFields() {
        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        HSRSelector.mockWorkOrders = new List<WorkOrder>{
                workOrder
        };

        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.WorkOrderCalloutMock_Failed());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Test.startTest();
        List<HSRDispatchToES.HSROutboundResult> results = HSRDispatchToES.dispatchNewRequest(new List<String>{
                workOrder.Id
        });

        Test.stopTest();
        System.assertEquals(1, getErrorNumbers());
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assert(!String.isBlank(results[0].errorMessage));
        System.assert(results[0].errorMessage.containsIgnoreCase('Expected Element'));
    }

    @IsTest
    private static void testOutbound_serverError() {
        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        HSRSelector.mockWorkOrders = new List<WorkOrder>{
                workOrder
        };

        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.WorkOrderCalloutMock_ServerError());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Test.startTest();
        List<HSRDispatchToES.HSROutboundResult> results = HSRDispatchToES.dispatchNewRequest(new List<String>{
                workOrder.Id
        });

        Test.stopTest();
        System.assertEquals(1, getErrorNumbers());
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assert(results[0].errorMessage.containsIgnoreCase('Internal Server Error'));
    }

    @IsTest
    private static void testOutbound_serverError_batch() {
        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        WorkOrder workOrder2 = HSRDataFactory.mockWorkOrder(2);
        HSRSelector.mockWorkOrders = new List<WorkOrder>{
                workOrder, workOrder2
        };

        Test.setMock(HttpCalloutMock.class, new HSRDataFactory.WorkOrderCalloutMock_ServerError());
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Test.startTest();
        List<HSRDispatchToES.HSROutboundResult> results = HSRDispatchToES.dispatchNewRequest(new List<String>{
                workOrder.Id, workOrder2.Id
        });

        Test.stopTest();

        System.assertEquals(2, getErrorNumbers());
        System.assertEquals(2, results.size());
        for (HSRDispatchToES.HSROutboundResult result : results) {
            System.assertEquals(false, result.isSuccess);
            System.assert(result.errorMessage.containsIgnoreCase('Internal Server Error'));
        }
    }

    @IsTest
    private static void testExceptionHandling() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        workOrder.Id = null; // to enforce throwing an error
        HSRSelector.mockWorkOrders = new List<WorkOrder>{
                workOrder
        };

        HSRDispatchToES.dispatchNewRequest(new List<String>{
        });

        System.assertEquals(1, HSRDispatchToES.logsToInsert.size());
    }

    @IsTest
    private static void testUtil_logException_request() {
        Account cdmAccount = HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Enterprise);
        Account siteAccount = HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Site);
        Contact contact = HSRDataFactory.mockContact(1, siteAccount);
        Asset pidAsset = HSRDataFactory.mockAsset(1, cdmAccount, siteAccount, contact, HSRDataFactory.AssetType.PID);
        Case caseRecord = HSRDataFactory.mockCase(1, cdmAccount, siteAccount, pidAsset, contact);

        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        HttpRequest request = HSRDispatchToES.makeRequest('random text');

        Dispute_Integration_Logs__c log = HSRDispatchToES.createERPExceptionLog(caseRecord.CaseNumber, request, 'error message');
        System.assertEquals(caseRecord.CaseNumber, log.caseNumber__c);
        System.assertEquals(request.getHeader('x-transaction-id'), log.Transaction_Id__c);
        System.assertEquals(request.getBody(), log.Request__c);
        System.assert(log.Status__c.containsIgnoreCase('error message'));
    }

    @IsTest
    private static void testUtil_logException_system() {
        Account cdmAccount = HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Enterprise);
        Account siteAccount = HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Site);
        Contact contact = HSRDataFactory.mockContact(1, siteAccount);
        Asset pidAsset = HSRDataFactory.mockAsset(1, cdmAccount, siteAccount, contact, HSRDataFactory.AssetType.PID);
        Case caseRecord = HSRDataFactory.mockCase(1, cdmAccount, siteAccount, pidAsset, contact);

        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Dispute_Integration_Logs__c log = HSRDispatchToES.createERPExceptionLog(caseRecord.CaseNumber, null, 'error message');
        System.assertEquals(caseRecord.CaseNumber, log.caseNumber__c);
        System.assertEquals(null, log.Transaction_Id__c);
        System.assertEquals(null, log.Request__c);
        System.assert(log.Status__c.containsIgnoreCase('error message'));
    }

    @IsTest
    private static void testUtil_generateExceptionMessage() {
        String errorFriendlyMessage;
        Test.startTest();
        try {
            throw new CustomException('error message');
        } catch (Exception err) {
            errorFriendlyMessage = HSRUtil.generateExceptionMessage(err);
        }
        Test.stopTest();

        System.assert(!String.isBlank(errorFriendlyMessage));
        System.assert(errorFriendlyMessage.containsIgnoreCase('error message'));
    }

    @IsTest
    private static void testUtil_generateWOMessage_full() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);

        String requestPayload = HSRUtil.generateWorkOrderMessage(workOrder);

        System.assert(requestPayload.containsIgnoreCase('Caller'));
        System.assert(requestPayload.containsIgnoreCase('Contact'));
        System.assert(requestPayload.containsIgnoreCase('Address'));
    }

    @IsTest
    private static void testUtil_generateWOMessage_partial() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        WorkOrder workOrder = HSRDataFactory.mockWorkOrder(1);
        workOrder.ContactId = null;
        workOrder.Contact = null;
        workOrder.Alt_Work_Site_Flag__c = false;

        String requestPayload = HSRUtil.generateWorkOrderMessage(workOrder);

        System.assert(!requestPayload.containsIgnoreCase('Contact'));
        System.assert(!requestPayload.containsIgnoreCase('Address'));
    }

    @IsTest
    private static void testUtil_canEnqueue_availableBandwidth() {
        HSRUtil.mockCurrentQueueableUsage = 0;
        Boolean canEnqueue = HSRUtil.canEnqueue();
        System.assertEquals(true, canEnqueue);
    }

    @IsTest
    private static void testUtil_canEnqueue_limit() {
        HSRUtil.mockCurrentQueueableUsage = Limits.getLimitQueueableJobs() + 1;
        Boolean canEnqueue = HSRUtil.canEnqueue();
        System.assertEquals(false, canEnqueue);
    }

    @IsTest
    private static void testUtil_makeAccountContactRecords() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        Account mcnAccount = HSRDataFactory.mockAccount(0, HSRDataFactory.AccountType.Customer);
        Contact relatedContact = HSRDataFactory.mockContact(0, mcnAccount);

        List<Account> accounts = new List<Account>{
                mcnAccount,
                HSRDataFactory.mockAccount(1, HSRDataFactory.AccountType.Site),
                HSRDataFactory.mockAccount(2, HSRDataFactory.AccountType.Site)
        };

        Test.startTest();
        List<AccountContactRelation> createdACRs = HSRUtil.makeAccountContactRelations(accounts, relatedContact);
        Test.stopTest();
        System.assertEquals(2, createdACRs.size());
    }

    @IsTest
    private static void testUtil_testDatabase() {
        HSRUtil.skipDatabaseOperations = false;
        List<Account> account = new List<Account>{
                HSRDataFactory.makeCustomerAccount(0)
        };

        HSRUtil.insertList(account, false);
        System.assertEquals(1, HSRTestSelector.getAccounts().size());

        HSRUtil.updateList(account, false);

        HSRUtil.deleteList(account, false);
        System.assertEquals(0, HSRTestSelector.getAccounts().size());
    }

    // -------------------- Util Methods --------------------
    private static Integer getErrorNumbers() {
        return HSRTestSelector.getIntegrationLogs().size();
    }

    // -------------------- Inner Classes --------------------
    private class CustomException extends Exception {
    }
}