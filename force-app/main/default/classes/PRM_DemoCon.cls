public class PRM_DemoCon {
    
    /* Get List of the Demo Requests */
    @AuraEnabled
    public static List<Demo_Program__c> getFINDemoProgram()
    {
        
        List<Demo_Program__c> lstFDP =  [Select Id,Name, Partner_Contact__r.Name,Partner_Account__r.Name, Country_Code__c,Product_Group_NCR_designation__c,QTY__c,Status__c,Region__c,LT__c,MSRP__c	
                                         from Demo_Program__c order by CreatedDate desc];
        return lstFDP;
    }
    
    /* Get detail of the Demo Request */
    @AuraEnabled
    public static Demo_Program__c getDemoReq(String demoRecordId) {
        Demo_Program__c demoReq ;
        List<Demo_Program__c> demoReqList = [SELECT Id, Name, Partner_Account__c,Partner_Account__r.Name,Partner_Contact__c,Partner_Contact__r.Name,Country__c,
                                             Region__c, CreatedDate, Status__c, QTY__c, Product_Group_NCR_designation__c, Product_Description__c,
                                             MSRP__c, LT__c FROM Demo_Program__c WHERE Id =: demoRecordId LIMIT 1
                                            ];
        if(demoReqList.size() > 0) {
            demoReq = demoReqList[0];
        }
        return demoReq;
    }
    
    // Approval Process for the Demo Request
    @AuraEnabled
    public static approvalProcessResult submitRequest(String recId,  String comment) {
        approvalProcessResult appRes = new approvalProcessResult();
        Savepoint sp = Database.setSavepoint();
        try {
            // Validate attachement. If there is at least one attachement then only allow to submit the request.
            List<ContentDocument> attachedDocLst = getFiles(recId);
            if(!(attachedDocLst.size() > 0)){
                appRes.isSuccess = false;
                appRes.message = 'Please attach file before submitting the request.';
                return appRes;
            }
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
    
    
    // Find file attachment from the file
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
    
    //Deletion of Demo Request -- For future use --
    @AuraEnabled
    public static DataBaseOperation deleteDemoReq(String recId) {
        DataBaseOperation res = new DataBaseOperation();
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
    }
    
    public class DataBaseOperation {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message = '';
    }
    
    public class approvalProcessResult {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message = '';
    }
    
}