/********************
* Class Name: CPQCLMQuoteExpirationService
* Description: This class resposible to send documents to cancelled at CLM upon quote expiration in CPQ
* Created By: Pankaj Pandey
* Created Date: 16-AUG-2022
* 
* Srno       Date            Description
* 1       16-AUG-2022     	SFCPQBLG-1174
* 
* *******************************************/
public class CPQCLMQuoteExpirationService implements Schedulable {
    private Boolean forApexTest = false;
    public CPQCLMQuoteExpirationService(Boolean forApexTest){
        this.forApexTest=forApexTest;
    }
    public void execute(SchedulableContext SC){
        try{
            //database.executebatch(new Cpq_UpdtOppStgOnDocExpire());
        	Cpq_UpdtOppStgOnDocExpire c = new Cpq_UpdtOppStgOnDocExpire();
        	database.executebatch(c,10);
        }catch(Exception ex){
             System.debug('Inside exception while running Cpq_UpdtOppStgOnDocExpire() batch job : '+ ex);
        } 
        
     	try{
            
            sendRequestToCLM(this.forApexTest);
            
        }catch(Exception ex){
            System.debug('Inside exception while running sendRequestToCLM() batch job : '+ ex);
        }  
      
    }
    @future (callout=true)
    public static void sendRequestToCLM(Boolean forApexTest){
        HttpRequest req;
        HttpResponse res;
        String trId;
        String errorMsg;
        String sts;
         String params = '<Params>';
        String docLink = null;
        String clmDocKey = null;
        CPQ_Util util = new CPQ_Util();
                      
                
        try {
            List<CUSTOMER_DOCUMENT__C> qualifiedDoc = null;
            if(forApexTest){
                qualifiedDoc = [SELECT ID, DOCUMENT_ID__C, DOCUMENT_LINK__C, DOCUMENT_STATUS__C, 
             	DOCUMENT_VERSION__C, NAME, QUOTE__C,QUOTE__R.NAME,DOCUMENT_TYPE__C   FROM 
             	CUSTOMER_DOCUMENT__C WHERE DOCUMENT_TYPE__C  IN 
            	 ('AE Order Form','AE Amendment','AE Shipment/Order Authorization') 
             	AND DOCUMENT_LINK__C != NULL AND Document_Status__c NOT IN ('Canceled','Signature Cancelled','Completed','Failed','Rejected','Void') LIMIT 1] ; 
            }else{
                 qualifiedDoc = [SELECT ID, DOCUMENT_ID__C, DOCUMENT_LINK__C, DOCUMENT_STATUS__C, 
                 DOCUMENT_VERSION__C, NAME, QUOTE__C,QUOTE__R.NAME,DOCUMENT_TYPE__C   FROM 
                 CUSTOMER_DOCUMENT__C WHERE DOCUMENT_TYPE__C  IN 
                 ('AE Order Form','AE Amendment','AE Shipment/Order Authorization') 
                 AND DOCUMENT_LINK__C != NULL AND Document_Status__c NOT IN ('Canceled','Signature Cancelled','Completed','Failed','Rejected','Void')
                 AND QUOTE__C IN (SELECT id from SBQQ__Quote__c  where SBQQ__Status__c='Expired') LIMIT 50] ;
            }
            
            if(qualifiedDoc.size() > 0){
                
                Root rootJSON = new Root();
                rootJSON.RequestHeader = new RequestHeader();
                rootJSON.CLMWorkflowReq = new CLMWorkflowReq();
                rootJSON.CLMWorkflowReq.WorkflowDocuments = new workflowDocuments();
                rootJSON.CLMWorkflowReq.WorkflowDocuments.Items = new List<String>();
                trId = new Uuid().getValue();
                
                rootJSON.RequestHeader.TransactionID = trId;
                rootJSON.RequestHeader.TransactionType = 'SyncExpiry';
                rootJSON.RequestHeader.TargetSystem = 'CLM'; 
                rootJSON.RequestHeader.SourceSystem = 'NSC-CPQ';
                rootJSON.RequestHeader.Timestamp = String.valueOf(DateTime.now());
                rootJSON.CLMWorkflowReq.Name = 'CPQ Expired Quote';
                rootJSON.CLMWorkflowReq.StartDate = String.valueOf(DateTime.now());
                rootJSON.CLMWorkflowReq.EndDate = String.valueOf(DateTime.now());
                rootJSON.CLMWorkflowReq.Status = '';
                rootJSON.CLMWorkflowReq.Info = '';
                for(CUSTOMER_DOCUMENT__C doc : qualifiedDoc) {
                    docLink = doc.document_link__c;
                    clmDocKey = docLink.substringAfter('&Id=');
                    params = params + '<EQ>' + doc.quote__r.name + ',' + clmDocKey + ',' + doc.id + '</EQ>';
                }
                params = params + '</Params>';
                rootJSON.CLMWorkflowReq.Params = params;
                            
                Http http = new Http();
                req = new HttpRequest();
                req.setEndpoint('callout:Soup_QuoteExpired');
                req.setMethod('POST');
                req.setTimeout(120000); 
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setBody(JSON.serialize(rootJSON));
                System.debug('Request>>>>>>'+rootJSON);
                res = http.send(req);
                System.debug('Response from CLM' + res);
                if(res.getStatusCode()==404 || res.getStatusCode()==500){
                    if(res.getStatus()=='Not Found'){
                        errorMsg = 'some problem at SOUP end.';
                    }else{
                        errorMsg = 'some problem at SOUP Or CLM end. ' + res+'.';
                    } 
                    sts ='FAILURE';
                } else if(String.isEmpty(res.getBody())){
                    errorMsg = res+'.';
                    sts ='FAILURE';
                } else {
                    JSONParser prs = JSON.createParser(res.getBody());           
                    while (prs.nextToken() != null) {
                        if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'TransactionStatus')) {
                            prs.nextToken();
                            sts = prs.getText();
                        }
                        
                    }
                }
             util.createLog(trId,sts,errorMsg, util.getRequestJSONAsString(req), util.getResponseJSONAsString(res),'Outbound', null,null, null, 'CLM Quote Expire');    
            }
        } catch(Exception ex) {
            errorMsg = ex.getMessage()+'.';
            sts ='FAILURE';
           util.createLog(trId,sts,errorMsg, util.getRequestJSONAsString(req), util.getResponseJSONAsString(res),'Outbound', null,null, null, 'CLM Quote Expire');
        }
        
    }
    
    public class CLMWorkflowReq{
        public String Name;
        public String StartDate;
        public String EndDate;
        public String Status;
        public String Info;
        public String Params;
        public WorkflowDocuments WorkflowDocuments;
    }
    
    public class RequestHeader{
        
        public String TransactionType;
        public String TargetSystem;
        public String SourceSystem;
        public String Timestamp;
        public String TransactionID;
    }
    
    public class Root{
        
        public RequestHeader RequestHeader;
        public CLMWorkflowReq CLMWorkflowReq;
    }
    
    public class WorkflowDocuments{
        public List<String> Items;
    }
}