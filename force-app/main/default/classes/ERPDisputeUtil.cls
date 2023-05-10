public class ERPDisputeUtil implements Queueable {
    public final static String DSP_SUCSS = '1';
    public final static String OPEN_DSP_CODE = '2';
    public final static String INV_NOT_FOUND = '3';
    public final static String INV_MCN_MISMATCH = '4';
    public final static String UNKNOWN_REASON = '5';
    
    public String vaidateDisputeDetailERPCloud(ERPCloudDisputeSyncService.DisputeDetail dsp) {
        String error = '';
        if (dsp != NULL) {
            if(String.isBlank(dsp.MasterCustomerNumber)) {
                error = '5';//'Master Customer Number is missing in Dispute Request';  
            } else if(String.isBlank(dsp.CountryCode)) {
                error = '5';// Country Code is missing in Dispute Request';         
            } else if(dsp.DisputeSource == NULL) {
                error = '5'; //Dispute Source is missing in Dispute Request';                
            } else if ((dsp.AlternateContact == NULL) || (dsp.AlternateContact.Name != NULL && dsp.AlternateContact.Email == NULL) || (dsp.AlternateContact.Name == NULL && dsp.AlternateContact.Email != NULL)) {
                error = '5';//Alternate Contact Name or email missing in Dispute Request';     
            }
        } /*else {

        }*/
        return error;
    }
    //End Yogesh Chnages    
    public Case getCaseDetail(String sfCaseNbr, String disputeRecordTypeId) {
        Case c;
        if (String.isNotBlank(sfCaseNbr)) {
            List<Case> caseList = [SELECT Id, RecordTypeId, AccountId, CaseNumber, CCAD_Dispute_Nbr__c,
                                   Master_Customer_Nbr__c, Dispute_Analyst_Name__c, ownerId,Status,
                                   ContactId, Alternate_Contact__c, Dispute_Created_By_Name__c,Dispute_Updated_By_Name__c                                   
                                   FROM CASE WHERE CaseNumber = :sfCaseNbr and RecordTypeId =:disputeRecordTypeId LIMIT 1 FOR UPDATE];
            
            c = (!caseList.isEmpty()) ? caseList.get(0) : null;
        }
        return c;
    }
    public Dispute_Invoices__c getDisputeDetail(List<String> invoiceLst ) {
    	System.debug('@@@@'+invoiceLst);
        Dispute_Invoices__c caseStatus;
        if (!invoiceLst.isEmpty()) {
            System.debug('@@@@'+invoiceLst);
                List<Dispute_Invoices__c> dispInvList = [SELECT Id,Dispute__r.Status,Dispute__r.CaseNumber, Balance_Due__c,Country_Code__c,Dispute__r.isClosed,Invoice_Number__c,Invoice_Get_Status__c
                                                     FROM Dispute_Invoices__c WHERE  Invoice_Number__c In:invoiceLst and Dispute__r.isClosed = false];
          //  System.debug('@@@@'+[SELECT Id,Dispute__r.Status,Dispute__r.isClosed,Invoice_Number__c FROM Dispute_Invoices__c WHERE Invoice_Number__c IN:invoiceLst and Dispute__r.isClosed = false]);
           
            caseStatus = (!dispInvList.isEmpty()) ? dispInvList.get(0) : null;
        }
       // System.debug('@@@@'+caseStatus.Dispute__r.CaseNumber);
        return caseStatus;
    }
    

   public Map<String, ERPCloudDisputeSyncService.InvRsp> getOpenDspInvs(List<String> invs, String MCN) {
        Map<String, ERPCloudDisputeSyncService.InvRsp> invRspMap = new Map<String, ERPCloudDisputeSyncService.InvRsp>();
        //String S
        if (!invs.isEmpty()) {          
            List<Dispute_Invoices__c> dspInvs = [SELECT Invoice_Number__c,Dispute__r.CCAD_Dispute_Nbr__c, Dispute__r.Master_Customer_Nbr__c FROM Dispute_Invoices__c WHERE Invoice_Number__c In:invs and Dispute__r.isClosed = false];
            
            for(Dispute_Invoices__c i : dspInvs) {               
            	invRspMap.put(i.Invoice_Number__c, new ERPCloudDisputeSyncService.InvRsp(MCN, i.Invoice_Number__c, 
                                                                                       i.Dispute__r.CCAD_Dispute_Nbr__c, OPEN_DSP_CODE));    
            }
	    }
        return invRspMap;
    } 
    
   
    
    public Case getCaseDetailById(String caseId) {
        Case c;
        if (String.isNotBlank(caseId)) {
            List<Case> caseList = [SELECT Id, CaseNumber FROM CASE WHERE Id = :caseId LIMIT 1];
            
            c = (!caseList.isEmpty()) ? caseList.get(0) : null;
        }
        return c;
    }
    
    public Account getAccountDetail(String accMCN) {
        List<Account> accList = new List<Account>();
        
        if (String.isNotBlank(accMCN)) {
            accList = [SELECT Id FROM Account WHERE Master_Customer_Number__c = :accMCN LIMIT 1];   
        }
        return (!accList.isEmpty() ? accList.get(0) : null);
    }
    
    
    public Map<String,Contact> getContactsDetail(Set<String> conEmails) {
        Map<String,Contact> contEmailMap = new Map<String,Contact>();
        
        if (conEmails != NULL && !conEmails.isEmpty()) {            
            for(Contact con : [SELECT Id, Email, Phone FROM Contact WHERE Email IN :conEmails FOR UPDATE]) {
                contEmailMap.put(con.Email.toUpperCase(), con);    
            }
        }
        return contEmailMap;
    }
    
    public String getDisputeCaseRecordTypeId(String recordTypeName) {
        String disputeRecTypeId;
        if (String.isNotBlank(recordTypeName)) {
            List<RecordType> recTypeList = [SELECT Id, DeveloperName, IsActive FROM RecordType WHERE DeveloperName= :recordTypeName AND IsActive = true LIMIT 1];
            disputeRecTypeId = (!recTypeList.isEmpty()) ? recTypeList.get(0).Id : null;
        }
        return disputeRecTypeId;
    }
    
    public Map<String, User> getUsersDetail(Set<String> QLIds) {
        Map<String, User> userMap = new Map<String, User>();
        System.debug('SELECT Id, Quicklook_ID__c,Email,Phone from User where Quicklook_ID__c IN' + QLIds);
        if (QLIds != NULL && !QLIds.isEmpty()) {
            List<User> empList = [SELECT Id, Quicklook_ID__c,Email,Phone from User where Quicklook_ID__c IN :QLIds]; 
            
            for(User u : empList) {
                userMap.put(u.Quicklook_ID__c.toUpperCase(), u);
            }
        }
        return userMap;        
    }
    
    public Map<String, String> getEmpDetail(Set<String> QLIds) {
        Map<String, String> empQLookAndNameMap = new Map<String, String>();
        
        if (QLIds != NULL && !QLIds.isEmpty()) {
            
            for(NCR_Employee_Detail__c emp : [SELECT Quicklook_ID__c,User_Name__c from NCR_Employee_Detail__c where Quicklook_ID__c IN :QLIds]) {
                empQLookAndNameMap.put(emp.Quicklook_ID__c.toUpperCase(), emp.User_Name__c);
            }
        }
        return empQLookAndNameMap;        
    }
    
    public Map<String,Other_Attachments__c> getAllNonSFAttachments(String caseId) {
        Map<String,Other_Attachments__c> attachMap = new Map<String,Other_Attachments__c>();
        List<Other_Attachments__c> otherAttList = [SELECT Id, Attachment_Description__c, Attachment_FULL_URL__c, 
                                                   Attachment_Source__c, Case__c, Unique_URL__c 
                                                   FROM Other_Attachments__c WHERE Case__c = :caseId FOR UPDATE];
        
        for(Other_Attachments__c o : otherAttList) attachMap.put(o.Attachment_FULL_URL__c, o);
        return attachMap;
    }
    
    //@future(callout=true)
    public static void getInvoiceDetailInFuture(List<String> invcNoId, String ctryCode, String sfCaseNo) {
        System.debug('caseId>>' + invcNoId + ',ctryCode>>' + ctryCode);
        /*List<Dispute_Invoices__c> dispInvList = [SELECT Id,Dispute__c,Dispute__r.CaseNumber, Balance_Due__c,Country_Code__c, Currency_Code__c, Customer_Name__c,
Customer_Trx_ID__c, Freight_Amount__c, Invoice_Date__c, Line_Amount__c,
MCN__c, Related_Order__c, PO_Number__c,Invoice_Number__c
FROM Dispute_Invoices__c WHERE Dispute__c = :caseId];

List<Dispute_Invoices__c> updateInvList = new List<Dispute_Invoices__c>();

if(!dispInvList.isEmpty()) {
String caseNumber = dispInvList.get(0).Dispute__r.CaseNumber;
Map<String, Dispute_Invoices__c> dispInvMap = new Map<String, Dispute_Invoices__c>();

for(Dispute_Invoices__c inv : dispInvList) {
dispInvMap.put(inv.Invoice_Number__c, inv);
}

System.debug(dispInvMap.keySet());
System.debug(ctryCode);
integer callCount = 0;  
String error = '';*/
        
        
        // call service from invNbrs set and get Result in a map
        List<OracleCloudToSFService.InvoiceList> rorInvLst = new List<OracleCloudToSFService.InvoiceList>();
        //UserInvoiceAuthanticationOracle_ERPCloud.InvoiceDataDisplayWrapper invResult = getInvoiceDetailFromERP_Oracle(invcNoId, ctryCode,sfCaseNo, rorInvLst);
        
        /* if(invResult.Dispute_Code != NULL && invResult.Dispute_Code == 700) {
if (invResult != NULL && invResult.InvoiceDetail != NULL && !invResult.InvoiceDetail.isEmpty()) {
for (OracleCloudToSFService.topLevelArray erpInv : invResult.InvoiceDetail) {
Dispute_Invoices__c dispInv = dispInvMap.get(erpInv.InvoiceNumber);                            
if (dispInv != NULL) {
populateInvoiceDetail_Oracle(erpInv, dispInv); 
updateInvList.add(dispInv);
}
}    
}
}*/
        //  return invResult;
    }
    
    
    
    public Contact createContact(ERPCloudDisputeSyncService.ContactDetail contDtl, String accId, Boolean isAltContact) {   
        Contact con = new Contact();
        
        if (contDtl != NULL && String.isNotBlank(accId)) {
            
            if (isNCRContact(contDtl.Email)) {
                List<Account> apocAccList = [SELECT Id from Account WHERE Master_Customer_Number__c = 'APOC1111' LIMIT 1];  
                if(apocAccList != NULL && !apocAccList.isEmpty()) {                    
                    accId = apocAccList.get(0).Id;
                    //con.Quicklook_ID__c = contDtl.Email.left(contDtl.Email.lastIndexOf('@') -1); 
                }   
                else {
                    throw new DisputeSyncService.DisputeSyncException('APOC Account not found in Salesforce for Customer/Alternate Contact');   
                }
            } 
            
            con.AccountId = accId; 
            con.Email = contDtl.Email;
            if (String.isNotBlank(contDtl.Phone)) con.Phone = contDtl.Phone;
            
            
            if (String.isNotBlank(contDtl.Name)) {
                List<String> splitNames = contDtl.Name.split('\\s+', 2);
                system.debug('splitNames:'+splitNames);
                if (splitNames != NULL && splitNames.size() > 0) {
                    con.FirstName = splitNames.get(0);  
                    if (splitNames.size() > 1 && String.isNotBlank(splitNames.get(1))) {
                        con.LastName = splitNames.get(1);
                        system.debug('LastName:'+splitNames.get(1));
                    }
                    else {
                        con.LastName = splitNames.get(0); 
                        system.debug('LastName:'+splitNames.get(0)); 
                        con.FirstName = '';   
                    } 
                } 
            }
        }
        return con;
    }
    
    public Boolean isNCRContact(String conEmail) {
        return (conEmail.endsWithIgnoreCase('@NCR.COM'));        
    }
    
    public Matcher matchPattern(String inputStr) {
        String regex ='^\\s*(\\[Comment from .*\\s+-\\s+Created By:\\s+(.+)\\(.+\\)\\][\\r|\\n][\\r|\\n])';
    	return Pattern.compile(regex).matcher(inputStr);    
    }
    
    public String getCaseStatus(String statusCode) {
        String status = '';
        
        if(String.isNotBlank(statusCode)) {
            List<SetDisputeStatusCode__c> dscList = SetDisputeStatusCode__c.getall().values();
            
            for (SetDisputeStatusCode__c dsc : dscList) {
                if (String.valueOf(integer.valueOf(dsc.caseStatusCode__c)) == statusCode) {
                    status = dsc.caseStatus__c;
                    break;
                }
            } 
        }
        return status;
    }
    public static void populateInvoiceDetail_Oracle(OracleCloudToSFService.InvoiceList erpInv, Dispute_Invoices__c dispInv, String sfCaseNo) {
        Map<String, Integer> monthMap = new Map<String, Integer>{'JAN'=>1, 'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP' =>9,'OCT'=>10,'NOV' =>11,'DEC'=>12};
            
            dispInv.Country_Code__c = erpInv.CountryCode;
        dispInv.Customer_Trx_ID__c = erpInv.CustomerTrxID != null ? Decimal.valueOf(erpInv.CustomerTrxID) : NULL;
        dispInv.MCN__c = erpInv.MCN;
        dispInv.Customer_Name__c = erpInv.CustomerName;
        dispInv.Source__c = erpInv.Source;
        dispInv.PO_Number__c = erpInv.PONumber;
        dispInv.Related_Order__c = erpInv.RelatedOrder;
        dispInv.Summary_Invoice__c = erpInv.SummaryInvoice;
        
        /*if(erpInv.InvoiceDate != NULL) {
            List<String> invDateList = erpInv.InvoiceDate.split('-');
            Integer day,month,year;
            
            if(invDateList.size() > 2) { 
                day = String.isNotBlank(invDateList.get(0)) ? Integer.valueOf(invDateList.get(0)) : NULL;                 
                month = (String.isNotBlank(invDateList.get(1)) && monthMap.get(invDateList.get(1)) != NULL) ? monthMap.get(invDateList.get(1)) : NULL;
                year = String.isNotBlank(invDateList.get(2)) ? Integer.valueOf(invDateList.get(2)) : NULL;
                
                if (day != NULL && month != NULL && year != NULL) {
                    dispInv.Invoice_Date__c = Date.newInstance(year, month, day);    
                }
            } 
        }*/
        dispInv.Transaction_Type__c = erpInv.TransactionType;
        dispInv.Currency_Code__c = erpInv.CurrencyCode;
        dispInv.CurrencyIsoCode = erpInv.CurrencyCode;
        dispInv.Original_Balance__c = erpInv.OriginalBalance != null ? erpInv.OriginalBalance : NULL;
        dispInv.Balance_Due__c = erpInv.BalanceDue != null ? erpInv.BalanceDue : NULL; 
        dispInv.Line_Amount__c = erpInv.LineAmount != null ? erpInv.LineAmount : NULL;
        dispInv.Tax_Amount__c = erpInv.TaxAmount != null ? erpInv.TaxAmount : NULL;
        dispInv.Freight_Amount__c = erpInv.FreightAmount != null ? erpInv.FreightAmount : NULL;
        dispInv.Total_Invoice_Amount__c = erpInv.TotalInvoiceAmount != null ? erpInv.TotalInvoiceAmount : NULL;
        dispInv.Invoice_Get_Status__c = erpInv.InvoiceStatus;
        dispInv.Invoice_Number__c = erpInv.InvoiceNumber != null ? erpInv.InvoiceNumber : null;
    }
    public static String getInvoiceDetailFromERP_Oracle(List<String> InvLst, String CtryCode, String dspMCN, ERPCloudDisputeSyncService.ERPDisputeSyncResponse resp, List<OracleCloudToSFService.InvoiceList> scssInvLst) {
        String respMsg = '';
        OracleCloudToSFService ParsedObj= new OracleCloudToSFService(); 
        Map<String,OracleCloudToSFService.InvoiceList> respInvMap = new Map<String,OracleCloudToSFService.InvoiceList>();        
        List<ERPCloudDisputeSyncService.InvRsp> invRspList = new List<ERPCloudDisputeSyncService.InvRsp>();   
        Set<String> mcnDiffInvNbrs = new Set<String>();
        String InvReq = '', invRsp = '', rspSts = '', transId=''; 
        Integer repStatusCode = NULL, callCount = 0, invoiceCount = 0; 
      
        try {
            if(InvLst != null && InvLst.size() > 0  && String.isNotBlank(CtryCode)) {            
                RequestHeaderERPCloud GenerateReqObj = new RequestHeaderERPCloud();
                RequestHeaderERPCloud.RequestHeader reqHdr = new RequestHeaderERPCloud.RequestHeader(); 
                transId = reqHdr.TransactionID='123e4567-e89b-12d3-a456-42665544';
                reqHdr.SourceSystem='NSC';
                reqHdr.Timestamp='2020-06-15T11:56:12.418-04:00';
                reqHdr.TargetSystem='ERP';                
                              
                //GenerateReqObj.MCN=CtryCode; //changed code to use MCN in place for country code
                GenerateReqObj.MCN = dspMCN;
                GenerateReqObj.InvoiceList=  String.join(InvLst, ',');  //var.removeStart(',').trim();            
                RequestHeaderERPCloud ObjectToParse = GenerateReqObj;              
                system.debug('@@@@'+ObjectToParse);
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:ERP_SOUP_Dispute_Invoice');
             //   request.setEndpoint('https://nicdevelopment-ncrmiddlewarecs-ia.integration.ocp.oraclecloud.com:443/ic/api/integration/v1/flows/rest/ERPCSSALESFORCEGETARINVOICESRV/1.0/getInvoiceDetails');  
                request.setMethod('GET');
                request.setTimeout(120000); 
               // String username = 'sa230896';
                //String password = 'aehWu5yxJ68c6b272yQw#2v9yoj!T6';                
                //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
                
               // request.setHeader('Authorization', authorizationHeader);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                request.setBody(RequestHeaderERPCloud.parse(ObjectToParse));
                InvReq = request.getBody();              
                System.debug('@@@@@'+ InvReq);
                
                HttpResponse response = http.send(request);
                invRsp = response.getBody();
               	rspSts = response.getStatus();
                System.debug('@@@@@'+ response);
                system.debug('@@@@@'+ invRsp);              
                System.debug('Kuchnhi');
                
                if (response.getStatusCode() != 200) { //callout exception
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + rspSts);
                    respMsg =  resp.result = rspSts;  
                }  else {                    
                    ParsedObj =  OracleCloudToSFService.parseResponse(invRsp);
                    System.debug('@@@@'+ParsedObj);                

                    for(OracleCloudToSFService.InvoiceList s : ParsedObj.InvoiceList) {
                        if(String.isNotBlank(s.InvoiceNumber)) {
                        	if (String.isNotBlank(s.MCN) && !s.MCN.equalsIgnoreCase(dspMCN)) {                               
                                mcnDiffInvNbrs.add(s.InvoiceNumber);                                  
                            } else {                               
								respInvMap.put(s.InvoiceNumber, s);    
                            }    
                        }
                       
                        /*if(s.MCN !=null){
                            InvoiceDetailMap.Invoices_Count++;
                        }*/
                    }
                    //invoiceCount =InvoiceDetailMap.Invoices_Count;                  
                System.debug('@@@@'+respInvMap);
                    System.debug('@@@@'+InvLst);
                    for(String invNbr : InvLst) {
                        //Boolean isInvErr = false;               
                        if(mcnDiffInvNbrs.contains(invNbr)) {
                            invRspList.add(new ERPCloudDisputeSyncService.InvRsp(dspMCN, invNbr, '0', INV_MCN_MISMATCH));  	    
                        } else {
                            if(respInvMap.containsKey(invNbr) && String.isNotBlank(respInvMap.get(invNbr).MCN)) {
                                scssInvLst.add(respInvMap.get(invNbr));    
                            } else {
                                invRspList.add(new ERPCloudDisputeSyncService.InvRsp(dspMCN, invNbr, '0', INV_NOT_FOUND));     
                            } 
                        } 
                    }
                    resp.InvListResp.Invoice.addAll(invRspList);
                }  
            }
        } catch(Exception e) {           
            respMsg = invRsp = e.getMessage(); 
            resp.result = e.getMessage();
        }
       
        CCADDLogsUtility.insertDisputeLogs(transId, InvReq, invRsp,rspSts, null,null,'SF-ERP Cloud');
        return respMsg;      
    } 
    
    public void execute(QueueableContext context) {
    // Your code here	
    System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
	}
    //End     
    
}