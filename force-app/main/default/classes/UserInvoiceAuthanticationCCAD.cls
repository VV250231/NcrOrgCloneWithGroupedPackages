public class UserInvoiceAuthanticationCCAD {
    
    
    @AuraEnabled
    public static List<String> validateUserEnteredInvoices(String userInputData){
        List<String> CommaSepratedList= new List<String>(); 
        if(String.isNotBlank(userInputData)){
            if(CommaSepratedList.size()==0){
                
                return  CommaSepratedList=ConvertCSVToStringCollection.executeFromApex(userInputData);
            }
            
        }
        
        return CommaSepratedList;  
    }
    
    @AuraEnabled
    public static Object authanticateUserEnteredInvoice(List<String> InvoiceList, String CountryCode) {
        CCAD_Config__mdt cfg = CCAD_Config__mdt.getInstance('Org_Config');    
        Object invDtl;
        if(cfg != NULL) {
            String invSrc = cfg.Invoice_ROR_System__c;
            if (invSrc == 'ERP OnPremise') { 
                invDtl = authanticateInvoiceFrom_ERPOnPrm(InvoiceList, CountryCode);	    
            } else if (invSrc == 'ERP Cloud') {
                invDtl = UserInvoiceAuthanticationOracle_ERPCloud.authanticateUserEnteredInvoice(InvoiceList, CountryCode);    
            }
        }  
        return invDtl;
    }
    
    //@InvocableMethod(label='Invoice List' description='Returns the list of invoice return from ERP.' category='ERP to SOUP Integration')
    @AuraEnabled
    public static InvoiceDataDisplayWrapper authanticateInvoiceFrom_ERPOnPrm(List<String> InvoiceList , String CountryCode){  //authanticateInvoiceFrom_ERPOnPrm
        
        SoupERPResult ParsedObj= new SoupERPResult();  
        InvoiceDataDisplayWrapper InvoiceDetailMap = new InvoiceDataDisplayWrapper();
        String invReq ='',invRsp ='',rspSts='', transId='';
        
        try{
            if(InvoiceList != null && InvoiceList.size()>0  && String.isNotBlank(CountryCode)){
                
                List<Dispute_Invoices__c> OpenDispute = new List<Dispute_Invoices__c> ();
                Set<String> InvoceSet = new Set<String>(); 
                InvoceSet.addAll(InvoiceList);
                
                for(Dispute_Invoices__c DisputeObj : [Select id,Dispute__r.Status,Dispute__r.CaseNumber,Invoice_Number__c from Dispute_Invoices__c  where Invoice_Number__c in : InvoceSet and Dispute__r.isClosed = false]){
                    OpenDispute.add(DisputeObj);
                }
                
                if(OpenDispute.size() > 0){
                    
                    InvoiceDetailMap.ErrorCode=500;
                    InvoiceDetailMap.displayMsg='You already have dispute(s) open with the invoice(s), please remove these invoices and click next';
                    
                    for(Dispute_Invoices__c DisputeCaseObj : OpenDispute){
                        InvoiceDetailMap.DisputeDetails.add(DisputeCaseObj);
                    }
                } 
                
                else{
                    //SOUP_Endpoint__c SoupInvoice = SOUP_Endpoint__c.getInstance('CCAD Invoice Rest');
                    
                    //  if(String.isNotBlank(SoupInvoice.Id)){
                    Generaterequestheader.ERPInvoiceHeaderRequestABM GenerateRequestObj = new Generaterequestheader.ERPInvoiceHeaderRequestABM();
                    Generaterequestheader.RequestHeader headerRequest = new Generaterequestheader.RequestHeader(); 
                    //headerRequest.TransactionID='123e4567-e89b-12d3-a456-42665544';
                    //headerRequest.TransactionID=UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(8)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(4)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(4)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(4)+'-'+UserInvoiceAuthanticationCCAD.GenerateUniqueTransactionId(8);
                    headerRequest.TransactionID = transId = new Uuid().getValue();                         
                    headerRequest.SourceSystem='NSC';
                    headerRequest.Timestamp=String.valueOf(DateTime.now());
                    headerRequest.TargetSystem='ERP';
                    
                    GenerateRequestObj.RequestHeader=headerRequest; 
                    Generaterequestheader.Invoices invoices = new Generaterequestheader.Invoices();
                    for(String invoiceNo : InvoceSet){
                        
                        if(String.isNotBlank(invoiceNo)){
                            Generaterequestheader.Invoice invoiceObj = new Generaterequestheader.Invoice();
                            invoiceObj.InvoiceNumber=invoiceNo.trim();
                            invoiceObj.CountryCode=CountryCode; 
                            invoices.Invoice.add(invoiceObj);
                        }   
                    }  
                    
                    
                    Generaterequestheader.ERPInvoiceHeaderRequest invoicesObj = new Generaterequestheader.ERPInvoiceHeaderRequest();
                    invoicesObj.Invoices=invoices;
                    
                    GenerateRequestObj.ERPInvoiceHeaderRequest = invoicesObj;
                    Generaterequestheader ObjectToParse = new Generaterequestheader();
                    ObjectToParse.ERPInvoiceHeaderRequestABM=GenerateRequestObj;
                    
                    //system.debug(Generaterequestheader.parse(ObjectToParse));
                    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    //request.setEndpoint(SoupInvoice.Endpoint_URL__c);
                    request.setEndpoint('callout:SOUP_CCAD_Invoice_Rest'); // uncomment later
                    request.setMethod('GET');
                    request.setTimeout(120000); 
                   // String username = SoupInvoice.Username__c; // comment start
                    // String password = SoupInvoice.Password__c;
                    
                    // Blob headerValue = Blob.valueOf(username + ':' + password);
                    //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    
                     //request.setHeader('Authorization', authorizationHeader); // comment end
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept', 'application/json');
                    
                    request.setBody(Generaterequestheader.parse(ObjectToParse));
                    invReq = request.getBody();
                    
                    HttpResponse response = http.send(request);
                    invRsp = response.getBody();
                    rspSts = response.getStatus();
                    //system.debug('>>>>>>>'+response.getBody());
                    
                    
                    if (response.getStatusCode() != 200){
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        InvoiceDetailMap.ErrorCode= response.getStatusCode();
                        InvoiceDetailMap.displayMsg=response.getStatus();
                    } 
                    
                    else {                          
                        ParsedObj =   SoupERPResult.parseResponse(response.getBody());
                        
                        Set<String> McnSet = new Set<String>();
                        for(SoupERPResult.Invoice s : ParsedObj.ERPInvoiceHeaderResponseABM.ERPInvoiceHeaderResponse.Invoices.invoice){
                            
                            McnSet.add(s.MCN);
                            InvoiceDetailMap.InvoiceDetail.add(s);
                        }
                        //return response.getBody(); 
                        
                        if(McnSet.contains(null)  && McnSet.size() == 1){
                            InvoiceDetailMap.ErrorCode = 400;
                            InvoiceDetailMap.displayMsg='Combination of country and invoice(s) is invalid, remove them and try again.';
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
                    
                    /* }

else{                    
InvoiceDetailMap.ErrorCode= 900;
InvoiceDetailMap.displayMsg='credential / EndPoint Issue at salesforce End.';                     
}*/
                    
                    
                }
                
            }
        }
        
        catch(Exception e){
            InvoiceDetailMap.ErrorCode= 900;
            InvoiceDetailMap.displayMsg= e.getMessage();
            invRsp = e.getMessage();
        }
        CCADDLogsUtility.insertDisputeLogs(transId, invReq, invRsp,rspSts, null, null, 'SF-ERP Invoice flow');
        return InvoiceDetailMap;  
    }
	
	//changes by Varsha
	@AuraEnabled
    public static String getERPSysType() {
        CCAD_Config__mdt cfg = CCAD_Config__mdt.getInstance('Org_Config');  
        String invSrc;
        if(cfg != NULL) {
        	invSrc = cfg.Invoice_ROR_System__c;
        }  
        return invSrc;
    }    
    
    public Class InvoiceDataDisplayWrapper {        
        @AuraEnabled
        Public String displayMsg;
        
        @AuraEnabled
        Public List<SoupERPResult.Invoice> InvoiceDetail;
        
        @AuraEnabled
        Public List<Dispute_Invoices__c> DisputeDetails;
        
        @AuraEnabled
        Public Integer ErrorCode;
        
        Public InvoiceDataDisplayWrapper(){
            InvoiceDetail =  new List<SoupERPResult.Invoice>();
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