// ===========================================================================
// Object: CreateQuoteService
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: REST service to create quote records.  Used for the migration
// of Pivotal quotes into NSC
// ===========================================================================
// Changes: 2017-04-03 Reid Beckett
//           Class created
// ===========================================================================
@RestResource(urlMapping='/CreateQuote/*')
global with sharing class CreateQuoteService 
{
    static Organization org = [select IsSandbox, InstanceName from Organization limit 1];
    static String sandboxName = org.IsSandbox ? UserInfo.getUserName().substringAfterLast('.') : 'PROD';
    static Document logDoc = null;
    static Boolean enableDocumentLogging = org.IsSandbox; //By default we will use document logging in sandboxes
    static Boolean enableSystemLogging = true; //By default we will use system logging
    
    @HttpPost
    global static void createQuote()
    {
        //parse options from headers
        if(RestContext.request.headers.containsKey('Logging')) {
            String loggingHeader = RestContext.request.headers.get('Logging');
            if(loggingHeader != null && loggingHeader.toLowerCase() == 'document') enableDocumentLogging = true;
            if(loggingHeader != null && loggingHeader.toLowerCase() == 'system') enableDocumentLogging = false;
            if(loggingHeader != null && loggingHeader.toLowerCase() == 'none') {
                enableSystemLogging = false;
                enableDocumentLogging = false;
            }
        }
        
        log('CreateQuoteService.createQuote::START');
        
        if(!Test.isRunningTest()) log(RestContext.request.requestBody.toString());
        
        CreateQuoteModel.IncomingJSONBodyWrapper jsonBodyWrapper;

        try {
            jsonBodyWrapper = (CreateQuoteModel.IncomingJSONBodyWrapper)JSON.deserialize(RestContext.request.requestBody.toString(), CreateQuoteModel.IncomingJSONBodyWrapper.class);
        }catch(Exception e) {
            applyErrorResponse('Invalid JSON in request body, failed to parse: ' + e.getMessage());
            return;
        }
        
        Id theQuoteId = null;
        try {
            zqu__Quote__c theQuote = CreateQuoteServiceUtil.createQuote(jsonBodyWrapper);
            theQuoteId = theQuote.Id;
        }catch(CreateQuoteServiceUtil.CreateQuoteException e) {
            if(e.errors == null) applyErrorResponse(e.getMessage());
            else applyErrorResponse(e.errors);
            return;
        }catch(Exception e) {
            applyErrorResponse(e.getMessage());
            return;
        }

        CreateQuoteModel.OutgoingJSONBodyWrapper out = new CreateQuoteModel.OutgoingJSONBodyWrapper();
        out.status = 'OK';
        if(String.isBlank(jsonBodyWrapper.quoteInformation.id)) {
            out.messages = new String[]{ 'Quote created' };
            out.quoteId = theQuoteId;
        }else{
            out.messages = new String[]{ 'Quote updated' };
            out.quoteId = theQuoteId;
        }
        
        try {
            //collect the Zuora PRP ID's
            if(jsonBodyWrapper.ratePlans != null) {
                zqu.zChargeGroup[] chargeGroupsAddList = new zqu.zChargeGroup[]{};
                CreateQuoteServiceUtil.ChargeGroupWrapper[] zcgsForAdd = CreateQuoteServiceUtil.getChargeGroupsForAdd(theQuoteId, jsonBodyWrapper);
                zqu.zChargeGroup[] zcgsForUpdate = CreateQuoteServiceUtil.getChargeGroupsForUpdate(jsonBodyWrapper);
                zqu.zChargeGroup[] chargeGroupsDeleteList = CreateQuoteServiceUtil.getChargeGroupsForDelete(jsonBodyWrapper);
                            
                            
                if(jsonBodyWrapper.quoteInformation.quoteType == 'Amendment') {
                    if(!String.isBlank(jsonBodyWrapper.quoteInformation.id) && !zcgsForUpdate.isEmpty()) {
                        zcgsForUpdate = zqu.zQuoteUtil.updateChargeGroups(zcgsForUpdate);
                    }
                    if(zcgsForAdd != null && !zcgsForAdd.isEmpty()){
                        chargeGroupsAddList = CreateQuoteServiceUtil.addChargeGroups(zcgsForAdd);
                    }
                    
                    if(chargeGroupsDeleteList != null && !chargeGroupsDeleteList.isEmpty()){
                        chargeGroupsDeleteList = zqu.zQuoteUtil.deleteChargeGroups(chargeGroupsDeleteList);
                    }
                }else{
                    if(zcgsForAdd != null && !zcgsForAdd.isEmpty()){
                        chargeGroupsAddList = CreateQuoteServiceUtil.addChargeGroups(zcgsForAdd);
                    }
                }
                
                if(jsonBodyWrapper.quoteInformation.quoteType == 'New Renewal' || (jsonBodyWrapper.quoteInformation.quoteType == 'Amendment' &&
                    !String.isBlank(jsonBodyWrapper.quoteInformation.id))) 
                {
                    //create Map of QRP ID => subscriptionRatePlanId
                    Map<Id, String> subscriptionRatePlanIdsByQRPID = new Map<Id, String>();
                    integer i = 0;
                    for(zqu.zChargeGroup zcg : chargeGroupsAddList) {
                        if(!String.isBlank(zcg.groupID)) {
                            CreateQuoteServiceUtil.ChargeGroupWrapper cgw = zcgsForAdd.get(i);
                            if(cgw != null && cgw.subscriptionRatePlanId != null) {
                                subscriptionRatePlanIdsByQRPID.put(zcg.groupID, cgw.subscriptionRatePlanId);
                            }
                        }
                        i++;
                    }
    
                    System.enqueueJob(new CreateQuotePostQueueable(theQuoteId, jsonBodyWrapper, subscriptionRatePlanIdsByQRPID));
                }else if(jsonBodyWrapper.quoteInformation.quoteType == 'Default'){
                    DIQuoteUtil.createQuoteProducts(new Set<Id> { theQuoteId });
                    CreateQuoteServiceUtil.updateQuoteProductTPVs(theQuoteId, jsonBodyWrapper);
                }
            }
    
            applyResponse(200, JSON.serializePretty(out));
    
        }catch(Exception e) {
            out.status = 'error';
            out.messages.add(e.getMessage() + '\n' + e.getStackTraceString());
            //TODO: delete the quote if created
            applyResponse(500, JSON.serializePretty(out));
        }
    }

    private static void applyErrorResponse(String e) {
        applyErrorResponse(new String[]{ e });
    }

    private static void applyErrorResponse(String[] errors) {
        CreateQuoteModel.OutgoingJSONBodyWrapper b = new CreateQuoteModel.OutgoingJSONBodyWrapper();
        b.status = 'error';
        b.messages = errors;
        applyResponse(500, JSON.serializePretty(b));
    }

    private static void applyResponse(Integer statusCode, String body)
    {
        RestContext.response.statusCode = statusCode;
        RestContext.response.headers.put('Content-Type', 'application/json');
        log('statusCode:'+statusCode);
        log(body);
        RestContext.response.responseBody = Blob.valueOf(body);
        log('CreateQuoteService.createQuote::END');
        flushLog();
    }
    
    private static void log(Object logObj) {
        log(String.valueOf(logObj));
    }
    
    private static void log(String logMessage) {
        if(enableDocumentLogging) {
            if(logDoc == null) {
                String title = 'CreateQuoteService-' + UserInfo.getUsername() + '-' + DateTime.now().format('yyyy/MM/dd HH:mm:ss');
                logDoc = new Document(FolderId = UserInfo.getUserId(), ContentType='text/plain', Name = title, Body = Blob.valueOf(''));
            }
            String docBody = logDoc.Body.toString(); 
            docBody += '\n' + DateTime.now().format('yyyy/MM/dd HH:mm:ss') + ' ' + (org.InstanceName + '|' + sandboxName + ' ' + logMessage);
            logDoc.Body = Blob.valueOf(docBody);
        }
        
        if(enableSystemLogging) system.debug(org.InstanceName + '|' + sandboxName + ' ' + logMessage);
    }

    private static void flushLog() {
        if(logDoc != null) upsert logDoc;
    }

}