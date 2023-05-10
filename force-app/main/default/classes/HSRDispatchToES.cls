/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex REST class designed to sync work orders with ES system through the middleware.
* URL Mapping: https://osbdev-ha.ncr.com/ext/ea/services/uipath/invoiceDispute
*
* HTTP Verbs Handled:
*
*   POST    -   Insert new dispute in ES
*
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
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class HSRDispatchToES {

    private static final Integer MAX_NUMBER_OF_ATTEMPTS = 2;

    private static final String REQUEST_NAMED_CREDENTIAL = 'callout:SOUP_Hosp_Service_Cloud';
    @TestVisible
    private static final String REQUEST_METHOD_POST = 'POST';
    private static final Integer REQUEST_TIMEOUT = 5000;

    private static Integer remainingCallouts;

    private static Map<String, WorkOrder> workOrderByTransactionId;
    private static Map<String, HSROutboundResult> processResultByWorkOrderId;

    @TestVisible
    private static List<Dispute_Integration_Logs__c> logsToInsert;

    static {
        workOrderByTransactionId = new Map<String, WorkOrder>();
        remainingCallouts = Limits.getLimitCallouts() - 1;
        processResultByWorkOrderId = new Map<String, HSROutboundResult>();
        logsToInsert = new List<Dispute_Integration_Logs__c>();
    }

    @InvocableMethod(Label='Send Dispatch Request' Description='Send Work Order details as an outbound request to ES')
    public static List<HSROutboundResult> dispatchNewRequest(List<String> workOrderIds) {
        // Generate http requests
        List<HttpRequest> requests = generateOutboundRequests(workOrderIds);

        // Send outbound request
        List<HttpRequest> failedRequests;
        Integer attemptNumber = 1;
        Boolean isAvailableCapacity = reserveCapacity(requests.size());
        do {
            failedRequests = attemptSendRequests(attemptNumber, requests);
            attemptNumber++;
            isAvailableCapacity = reserveCapacity(failedRequests.size());
            requests = failedRequests;
        } while (canRetry(failedRequests.size(), isAvailableCapacity, attemptNumber));


        // Commit logs
        if (logsToInsert.size() > 0) {
            commitLogs();
        }
        return processResultByWorkOrderId.values();
    }

    // ---------------- Private methods ----------------

    private static List<HttpRequest> generateOutboundRequests(List<Id> workOrderIds) {
        List<WorkOrder> relatedWorkOrders = HSRSelector.getWorkOrdersById(workOrderIds);

        List<HttpRequest> requests = new List<HttpRequest>();
        for (WorkOrder workOrder : relatedWorkOrders) {
            try {
                String requestBody = HSRUtil.generateWorkOrderMessage(workOrder);
                HttpRequest request = makeRequest(requestBody);

                workOrderByTransactionId.put(request.getHeader('x-transaction-id'), workOrder);
                requests.add(request);
            } catch (Exception err) {
                System.debug('HSRDispatchToES/generateOutboundRequests: ' + HSRUtil.generateExceptionMessage(err));
                captureException(workOrder.Id, err);
                logsToInsert.add(createERPExceptionLog(workOrder?.Case.CaseNumber, null, err.getMessage()));
            }
        }

        return requests;
    }

    private static List<HttpRequest> attemptSendRequests(Integer attemptNumber, List<HttpRequest> requests) {
        List<HttpRequest> failedRequests = new List<HttpRequest>();
        for (HttpRequest request : requests) {
            String transactionId = request.getHeader('x-transaction-id');
            String caseNumber = workOrderByTransactionId.get(transactionId)?.Case?.CaseNumber;
            String workOrderId = workOrderByTransactionId.get(transactionId)?.Id;

            try {
                HttpResponse response = new Http().send(request);

                if (isSuccessful(response)) {
                    captureSuccessfulProcessResult(workOrderId);
                } else {
                    if (isLastAttempt(requests.size(), attemptNumber)) {
                        // Log an error in Dispute Integration Log
                        captureFailedProcessResult(workOrderId, response);
                        logsToInsert.add(HSRUtil.createResponseLog(caseNumber, request, response, response.getStatus()));
                    } else {
                        failedRequests.add(request);
                    }
                }
            } catch (Exception err) {
                System.debug('HSRDispatchToES/attemptSendRequests: ' + HSRUtil.generateExceptionMessage(err));
                captureException(workOrderId, err);
                logsToInsert.add(createERPExceptionLog(caseNumber, request, err.getMessage()));
            }
        }
        return failedRequests;
    }

    @TestVisible
    private static HttpRequest makeRequest(String body) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(REQUEST_NAMED_CREDENTIAL);
        request.setMethod(REQUEST_METHOD_POST);
        request.setTimeout(REQUEST_TIMEOUT);

        String transactionId = new Uuid().getValue();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('cache-control', 'no-cache');
        request.setHeader('x-transaction-id', transactionId);

        request.setBody(body);
        return request;
    }

    /**
     * Create log records using CCADDLogsUtility class
     */
    private static void commitLogs() {
        for (Dispute_Integration_Logs__c log : logsToInsert) {
            HSRUtil.logError(log);
        }
    }

    // ---------------- Util methods ----------------

    private static Boolean reserveCapacity(Integer numberOfRequests) {
        if (remainingCallouts - numberOfRequests > 0) {
            remainingCallouts -= numberOfRequests;
            return true;
        }
        return false;
    }

    private static Boolean isLastAttempt(Integer numberOfRequests, Integer attemptNumber) {
        Boolean hasAvailableCapacity = numberOfRequests <= remainingCallouts;

        return attemptNumber == MAX_NUMBER_OF_ATTEMPTS
                || (attemptNumber < MAX_NUMBER_OF_ATTEMPTS
                && !hasAvailableCapacity);
    }

    private static Boolean isSuccessful(HttpResponse response) {
        String status;
        try {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            status = (String) responseObject.get('Status');
        } catch (Exception err) {
            System.debug('HSRDispatchToES/isSuccessful an error has occurred while processing the response');
            System.debug(HSRUtil.generateExceptionMessage(err));
            return false;
        }
        return (response.getStatusCode() == 200 || response.getStatusCode() == 201) && status.equalsIgnoreCase('Accepted');
    }

    private static Boolean canRetry(Integer numberOfFailedRequests, Boolean isAvailableCapacity, Integer attemptNumber) {
        return numberOfFailedRequests > 0 && isAvailableCapacity && attemptNumber <= MAX_NUMBER_OF_ATTEMPTS;
    }

    private static void captureSuccessfulProcessResult(Id workOrderId) {
        HSROutboundResult successResult = new HSROutboundResult();

        successResult.isSuccess = true;
        successResult.workOrderId = workOrderId;
        processResultByWorkOrderId.put(workOrderId, successResult);
    }


    private static void captureFailedProcessResult(Id workOrderId, HttpResponse response) {
        HSROutboundResult failedResult = new HSROutboundResult();

        failedResult.isSuccess = false;
        failedResult.workOrderId = workOrderId;
        failedResult.errorMessage = getErrorDetails(response);

        processResultByWorkOrderId.put(workOrderId, failedResult);
    }

    private static String getErrorDetails(HttpResponse response) {
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            String FaultDetails;

            try {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                FaultDetails = (String) ((Map<String, Object>) responseObject.get('Fault')).get('FaultDescription');
            } catch (Exception err) {
                System.debug('HSRDispatchToES/isSuccessful an error has occurred while processing the response');
                System.debug(HSRUtil.generateExceptionMessage(err));
                FaultDetails = 'Unknown error';
            }
            return FaultDetails;
        }
        return HSRUtil.generateResponseErrorMessage(response);
    }

    private static void captureException(String workOrderId, Exception err) {
        HSROutboundResult failedResult = new HSROutboundResult();

        failedResult.isSuccess = false;
        failedResult.workOrderId = workOrderId;
        failedResult.errorMessage = HSRUtil.generateExceptionMessage(err);
        processResultByWorkOrderId.put(workOrderId, failedResult);
    }

    public static Dispute_Integration_Logs__c createERPExceptionLog(String caseNumber, HttpRequest request, String errorMessage) {
        String friendlyMessage = String.format(System.Label.HSR_ERP_Callout_Error, new List<String>{
                errorMessage.left(200)
        });
        return HSRUtil.createExceptionLog(caseNumber, request, friendlyMessage, errorMessage);
    }


    // ---------------- Inner classes ----------------

    /**
     * @description Contain an Invocable variable which is used to pass error messages back to the Flow
     */
    public class HSROutboundResult {
        @InvocableVariable(Label='Work Order Id')
        public String workOrderId;

        @InvocableVariable(Label='Is Success' Description='Success flag')
        public Boolean isSuccess;

        @InvocableVariable(Label='Error Message' Description='Returned error messages from the outbound request')
        public String errorMessage;
    }

}