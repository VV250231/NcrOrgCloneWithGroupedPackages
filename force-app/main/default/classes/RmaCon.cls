public class RmaCon {
    
    /* Returns list of record types of RMA */
    @AuraEnabled
    public static List<RecordType> getRmaRecordTypes(){
        List<RecordType> rmaRecTypeLst = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'RMA__c'];
        return rmaRecTypeLst;
    }
    
    @AuraEnabled 
    public static List<RMA__c> getRmaList(){
        List<RMA__c> rmaList = [SELECT Id, Name, Account__c, Account__r.Name, MCN__c, Contact__c, Contact__r.Name, Email__c, Order_Number__c,
                                Product_ID__c, Quantity__c, Reason_for_Return__c, Additional_Comments__c, Status__c, CreatedDate, Request_Submitted_Date__c,NCR_Status_Comments__c
                                FROM RMA__c];
        return rmaList;
    }
    
    /* Save new RMA request */
    @AuraEnabled
    public static DataBaseOperationResult saveRecord(RMA__c rec){
        DataBaseOperationResult res = new DataBaseOperationResult();
        try {
            insert rec;
            res.isSuccess = true;
            res.obj = rec;
        } catch (Exception ex){
            res.isSuccess = false;
            res.message = ex.getMessage();
        }
        return res;
    }
    
    /* Update new RMA request */
    @AuraEnabled
    public static DataBaseOperationResult updateRecord(RMA__c rec){
        DataBaseOperationResult res = new DataBaseOperationResult();
        try {
            update rec;
            res.isSuccess = true;
            res.obj = rec;
        } catch (Exception ex){
            res.isSuccess = false;
            res.message = ex.getMessage();
        }
        return res;
    }
    
    @AuraEnabled
    public static RMA__c getRMAReq(String recId) {
        RMA__c req ;
        List<RMA__c> reqList = [SELECT Id, Name, Account__c,Account__r.Name,MCN__c,Contact__c,Contact__r.Name,Email__c,
                                CreatedDate, Status__c, Quantity__c, Product_ID__c, Order_Number__c,Reason_for_Return__c,Additional_Comments__c,NCR_Status_Comments__c
                                FROM RMA__c WHERE Id =: recId LIMIT 1
                               ];
        if(reqList.size() > 0) {
            req = reqList[0];
        }
        return req;
    }
    
    /* Submits RMA request for approval*/
    @AuraEnabled
    public static approvalProcessResult submitRequest(String recId,  String comment) {
        approvalProcessResult appRes = new approvalProcessResult();
        Savepoint sp = Database.setSavepoint();
        try {
            // Validate attachement. If there is at least one attachement then only allow to submit the request.
            /* Commenting because attachment is not mandatory yet for this type of requests 
List<ContentDocument> attachedDocLst = getFiles(recId);
if(!(attachedDocLst.size() > 0)){
appRes.isSuccess = false;
appRes.message = 'Please attach file before submitting the request.';
return appRes;
}*/
            
            // Submit request for approval.
            Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comment);
            req.setObjectId(recId);
            Approval.ProcessResult result = Approval.process(req);
            if(result.isSuccess() != true) {
                appRes.isSuccess = false;
                appRes.message = 'Request could not submit for Approval. Please contact to System Administrator.';
                system.debug('***'+result.getErrors());
                Database.rollback(sp);
            } else {
                appRes.isSuccess = true;
                appRes.message = 'Record has been submitted successfully.';
            }
        } catch(Exception ex) {
            appRes.isSuccess = false;
            appRes.message = ex.getMessage();
            system.debug('***'+ex.getMessage());
            Database.rollback(sp);
        }
        
        return appRes;
    }
    
    public class approvalProcessResult {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message = '';
    }
    
    @AuraEnabled
    public static List<ContentDocument> getFiles(String recId) {
        List<ContentDocumentLink> conDocLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: recId];
        Set<Id> conDocIds = new Set<Id>();
        for (ContentDocumentLink conDocLink : conDocLinkList) {
            conDocIds.add(conDocLink.ContentDocumentId);
        }
        
        List<ContentDocument> conDocList = [SELECT Id, FileExtension, FileType, ContentSize, Title FROM ContentDocument WHERE Id IN: conDocIds];
        List<ContentVersion> conVersionLst = [SELECT Id, FileExtension, FileType, Title, ContentSize, ContentUrl
                                              FROM ContentVersion WHERE ContentDocumentId IN: conDocIds AND IsLatest = true];
        return conDocList;
        
    }
    
    /*For future user 
    @AuraEnabled
    public static DataBaseOperationResult deleteDemoReq(String recId) {
        DataBaseOperationResult res = new DataBaseOperationResult();
        try {
            List<Demo_Program__c> demoReq = [SELECT Id FROM Demo_Program__c WHERE Id =: recId];
            if(demoReq.size()>0){
                DataBase.DeleteResult result = Database.delete(demoReq[0],true);
                if(result.isSuccess()){
                    res.isSuccess = true;
                    res.message = 'success';
                } else {
                    res.isSuccess = false;
                    res.message = result.getErrors()[0].getMessage();
                }
            }
        } catch(Exception ex){
            res.isSuccess = false;
            res.message = ex.getMessage();
        }
        return res;
    }*/
    
    public class DataBaseOperationResult {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public RMA__c obj;
    }
}