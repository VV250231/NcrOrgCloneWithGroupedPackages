public class UserInvoiceAuthanticationOracle_ERPCloud {
    
    @AuraEnabled
    public static List<String> validateUserEnteredInvoices(String userInputData){
        List<String> CommaSepratedList= new List<String>();
        
        if(String.isNotBlank(userInputData)){
            if(CommaSepratedList.size()==0){                
                return CommaSepratedList=ConvertCSVToStringCollection.executeFromApex(userInputData);
            }
        }        
        return CommaSepratedList;  
    }
    
  
    //@InvocableMethod(label='Invoice List' description='Returns the list of invoice return from ERP.' category='ERP to SOUP Integration')
    @AuraEnabled
    public static InvoiceOracleDisplayWrapper authanticateUserEnteredInvoice(List<String> InvoiceList , String MCN){        
        OracleCloudToSFService ParsedObj= new OracleCloudToSFService();  
        InvoiceOracleDisplayWrapper InvoiceDetailMap = new InvoiceOracleDisplayWrapper();
        String invReq ='',invRsp ='',rspSts='', transId='';
        
        try{
        System.debug('@@@@Int'+InvoiceList+''+MCN);
        if(InvoiceList != null && InvoiceList.size()>0  && String.isNotBlank(MCN)){
            
            List<Dispute_Invoices__c> OpenDispute = new List<Dispute_Invoices__c> ();
            List<String> InvoceSet = new List<String>(); 
            InvoceSet.addAll(InvoiceList);
            System.debug('@@@@'+InvoceSet);
            for(Dispute_Invoices__c DisputeObj : [Select id,Dispute__r.Status,Dispute__r.CaseNumber,Invoice_Number__c from Dispute_Invoices__c  where Invoice_Number__c in : InvoceSet and Dispute__r.isClosed = false]){
                OpenDispute.add(DisputeObj);
            }
            
            if(OpenDispute.size() > 0){
                
                InvoiceDetailMap.ErrorCode=500;
                InvoiceDetailMap.displayMsg='You already have dispute(s) open with the invoice(s), please remove these invoices and click next';
                
                for(Dispute_Invoices__c DisputeCaseObj : OpenDispute){
                    InvoiceDetailMap.DisputeDetails.add(DisputeCaseObj);
                }
                //return InvoiceDetailMap;
            } 
            
            else{
               // SOUP_Endpoint__c SoupInvoice = SOUP_Endpoint__c.getInstance('CCAD Invoice Rest');
              //  System.debug('@@@@Int'+SoupInvoice);
               // if(String.isNotBlank(SoupInvoice.Id)){
                    RequestHeaderERPCloud GenerateRequestObj = new RequestHeaderERPCloud();
                    RequestHeaderERPCloud.RequestHeader headerRequest = new RequestHeaderERPCloud.RequestHeader(); 
                    //headerRequest.TransactionID='123e4567-e89b-12d3-a456-42665544';
                    //headerRequest.TransactionID=UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(8)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(4)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(4)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(4)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(8);
                    headerRequest.TransactionID =  transId = new Uuid().getValue(); 
                    headerRequest.SourceSystem='NSC';
                    headerRequest.Timestamp=String.valueOf(DateTime.now());
                    headerRequest.TargetSystem='ERP';
                    List<String> invNo = new List<String>();
                    // GenerateRequestObj.RequestHeader=headerRequest; 
                    RequestHeaderERPCloud invoiceObj = new RequestHeaderERPCloud();
                    String var='';    
                    for(String invoiceNo : InvoceSet){
                        // System.debug('@@@@'+invoiceObj.InvoiceList.add(invoiceNo));
                        if(String.isNotBlank(invoiceNo)){
                            invNo.add(invoiceNo);
                            //RequestHeaderERPCloud.Invoice invoiceObj = new RequestHeaderERPCloud.Invoice();
                            //invoiceObj.InvoiceList.add(invoiceNo);
                            //  invoiceObj.noInvoiceList =invoiceNo.trim();
                            invoiceObj.MCN=MCN; 
                            //invoices.Invoice.add(invoiceObj);
                        }
                        var+=','+invoiceNo;
                    }  
                    if(String.isNotBlank(var)){
                        invoiceObj.InvoiceList=var.removeStart(',');
                        if(var.contains('/')){
                            invoiceObj.InvoiceList = var.replace('/', ',');
                            invoiceObj.InvoiceList=invoiceObj.InvoiceList .removeStart(',');
                        }
                    }
                    System.debug('@@@@'+var.trim());
                    //System.debug('@@@@'+ invoiceObj.noInvoiceList);
                    System.debug('@@@@'+ invNo.toString().trim());
                    System.debug('@@@@Int'+invoiceObj);
                    RequestHeaderERPCloud invoicesObj = new RequestHeaderERPCloud();
                    invoicesObj=invoiceObj;
                    
                    GenerateRequestObj = invoicesObj;
                    RequestHeaderERPCloud ObjectToParse = new RequestHeaderERPCloud();
                    ObjectToParse=GenerateRequestObj;
                    
                    system.debug('@@@@'+ObjectToParse);
                    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('callout:ERP_SOUP_Dispute_Invoice');
                  // request.setEndpoint('https://nicdevelopment-ncrmiddlewarecs-ia.integration.ocp.oraclecloud.com/ic/api/integration/v1/flows/rest/ERPCSSALESFORCEGETARINVOICESRV/1.0/getInvoiceDetails');
                    //request.setEndpoint('https://nicdevelopment-ncrmiddlewarecs-ia.integration.ocp.oraclecloud.com:443/ic/api/integration/v1/flows/rest/ERPCSSALESFORCEGETARINVOICESRV/1.0/getInvoiceDetails');
                  //  request.setEndpoint('https://nicstest-ncrmiddlewarecs-ia.integration.ocp.oraclecloud.com/ic/api/integration/v1/flows/rest/ERPCSSALESFORCEGETARINVOICESRV/1.0/getInvoiceDetails');
                    request.setMethod('POST');
                    request.setTimeout(120000); 
                  	 //String username = 'SA231189';//'sa231184';
                    //String password = 'g^2@TXbA&6)E[F;;[qQ0&Qy0Q7)l#q';//'rXkEvKTQSfPt@Ru7Yjwe4nJsVAMpD6'; 
                 //String username = 'SD250590';//'sa231184';
                   // String password = 'Xkr12D*20000';//'rXkEvKTQSfPt@Ru7Yjwe4nJsVAMpD6'; 
                    
                   //Blob headerValue = Blob.valueOf(username + ':' + password);
                   //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    
                    //request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept', 'application/json');
                    request.setBody(RequestHeaderERPCloud.parse(ObjectToParse));
                    invReq = request.getBody();
                    // request.setBody('{"InvoiceList":"10","CountryCode":"US"}');
                    System.debug('@@@@@'+RequestHeaderERPCloud.parse(ObjectToParse));
                    
                    HttpResponse response = http.send(request);
                    system.debug('@@@@@'+response.getBody());
                    System.debug('@@@@@'+response.getStatusCode());
                    System.debug('@@@@@'+response);
                    System.debug('@@@@@'+response.getStatusCode());
                    invRsp = response.getBody();
                    rspSts = response.getStatus();
                    
                   if (response.getStatusCode() != 200){
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        /*InvoiceDetailMap.ErrorCode= response.getStatusCode();
                        InvoiceDetailMap.displayMsg=response.getStatus();
                        return InvoiceDetailMap;*/
                        InvoiceDetailMap.ErrorCode= 1001;
                        InvoiceDetailMap.displayMsg='Service Unavailable, please contact System Administrator.';
                    } 
                    
                    else {
                        
                        ParsedObj =   OracleCloudToSFService.parseResponse(response.getBody());
                        System.debug('@@@@'+JSON.deserializeUntyped(response.getBody()));
                        // Map<String,String> newMapObj = Map<String,String>JSON.deserializeUntyped(response.getBody());
                        Set<String> McnSet = new Set<String>();
                        for(OracleCloudToSFService.InvoiceList s : ParsedObj.InvoiceList){
                            System.debug('@@@@'+s.MCN);
                            McnSet.add(s.MCN);
                            InvoiceDetailMap.InvoiceDetail.add(s);
                        }
                        //return response.getBody(); 
                        if(McnSet.contains(null)  && McnSet.size() == 1){
                            InvoiceDetailMap.ErrorCode = 400;
                            InvoiceDetailMap.displayMsg='Combination of MCN and invoice(s) is invalid, remove them and try again.';
                        }
                        
                        else if(McnSet.size()>1 &&  McnSet.contains(null)){
                            InvoiceDetailMap.ErrorCode = 600;
                            InvoiceDetailMap.displayMsg='Entered invoice(s) is/are related to more than one customers and Invalid Invoices, please enter all the invoices related to only one customer at a time.';
                        }
                        
                        else if(McnSet.size()>1){
                            InvoiceDetailMap.ErrorCode = 800;
                            InvoiceDetailMap.displayMsg='Entered invoice(s) is/are related to more than one customers, please enter all the invoices related to only one customer at a time.';
                        }
                        
                    } 
                   
              /*  }
                
                else{
                    
                    InvoiceDetailMap.ErrorCode= 900;
                    InvoiceDetailMap.displayMsg='credential / EndPoint Issue at salesforce End.';
                   
                    
                }*/
                
                
            }
            
        }
           }

catch(Exception e){
System.debug(e.getMessage());
 System.debug(e.getStackTraceString());
InvoiceDetailMap.ErrorCode= 900;
InvoiceDetailMap.displayMsg= 'Service Unavailable, please contact System Administrator';
    
//return InvoiceDetailMap;
}
        
        CCADDLogsUtility.insertDisputeLogs(transId, invReq, invRsp,rspSts, null, null, 'SF-ERPCloud Invoice flow');
        return InvoiceDetailMap;  
    }
    
    
    public Class InvoiceDataDisplayWrapper{
        
        @AuraEnabled
        Public String result;
        @AuraEnabled
        Public Integer Dispute_code;
        @AuraEnabled
        Public Integer Invoices_Count;
        Public InvoiceDataDisplayWrapper(){
            result='';
            Dispute_code=900;
            Invoices_Count =0;
        }
        
    }
    public Class InvoiceOracleDisplayWrapper {  
        
        @AuraEnabled
        Public String displayMsg;
        
        @AuraEnabled
        Public List<OracleCloudToSFService.InvoiceList> InvoiceDetail;
        
        @AuraEnabled
        Public List<Dispute_Invoices__c> DisputeDetails;
        @AuraEnabled
        Public Integer ErrorCode;
        Public InvoiceOracleDisplayWrapper(){
            InvoiceDetail =  new List<OracleCloudToSFService.InvoiceList>();
            DisputeDetails = new List<Dispute_Invoices__c>();
            displayMsg='';
            ErrorCode=700;
        }
        
    }
    
    @AuraEnabled 
    public static List<DisputeAnalystController.PicklistWrapperClass> getCountryNameWithCode(){
        return DisputeAnalystController.getPicklistValues('Case', 'Country_Name__c');
    }
    
}