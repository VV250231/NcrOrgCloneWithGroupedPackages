public class DisputeUtil {
    
    public String vaidateDisputeDetail(DisputeSyncService.DisputeDetail dsp) {
        String error = '';
        
        if (dsp != NULL) {
            if(String.isBlank(dsp.MasterCustomerNumber)) {
                error = 'Master Customer Number is missing in Dispute Request';  
            } else if(String.isBlank(dsp.CountryCode)) {
                error = 'Country Code is missing in Dispute Request';   
            } else if(String.isBlank(dsp.CCADDisputeNbr)) {
                error = 'CCAD Dispute Number is missing in Dispute Request';       
            } else if(dsp.DisputeSource == NULL) {
                error = 'Dispute Source is missing in Dispute Request';            
            } else if ((dsp.CustomerContact.Name != NULL && dsp.CustomerContact.Email == NULL) || (dsp.CustomerContact.Name == NULL && dsp.CustomerContact.Email != NULL)) {
                error = 'Customer Contact Name or email missing in Dispute Request';     
            } else if ((dsp.AlternateContact.Name != NULL && dsp.AlternateContact.Email == NULL) || (dsp.AlternateContact.Name == NULL && dsp.AlternateContact.Email != NULL)) {
                error = 'Alternate Contact Name or email missing in Dispute Request';     
            }
        } else {
            error = 'Invalid Dispute Creation Request';
        } 
        return error;
    }
    
   
    
    public Case getCaseDetail(String sfCaseNbr, String ccadDispNbr, String disputeRecordTypeId) {
        Case c;
        if (String.isNotBlank(sfCaseNbr) || String.isNotBlank(ccadDispNbr)) {
            List<Case> caseList = [SELECT Id, RecordTypeId, AccountId, CaseNumber, CCAD_Dispute_Nbr__c,
                                   Master_Customer_Nbr__c, Dispute_Analyst_Name__c, ownerId,
                                   ContactId, Alternate_Contact__c, Dispute_Created_By_Name__c,Dispute_Updated_By_Name__c                                   
                                   FROM CASE WHERE CCAD_Dispute_Nbr__c = :ccadDispNbr and RecordTypeId =:disputeRecordTypeId LIMIT 1 FOR UPDATE];
            
            c = (!caseList.isEmpty()) ? caseList.get(0) : null;
        }
        return c;
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
        Account acc;
        
        if (String.isNotBlank(accMCN)) {
            List<Account> accList = [SELECT Id, Name, Master_Customer_Number__c, Account_Country_Code__c FROM Account WHERE Master_Customer_Number__c = :accMCN LIMIT 1]; 
            acc = (!accList.isEmpty()) ? accList.get(0) : null;
        }
        return acc;
    }
    
    public Map<String,Contact> getContactsDetail(Set<String> conEmails) {
        Map<String,Contact> contEmailMap = new Map<String,Contact>();
        
        if (conEmails != NULL && !conEmails.isEmpty()) {
            List<Contact> conList = [SELECT Id, Name, Email, Phone FROM Contact WHERE Email IN :conEmails FOR UPDATE]; 
            
            for(Contact con : conList) {
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
            List<NCR_Employee_Detail__c> empList = [SELECT Id,Quicklook_ID__c,User_Name__c from NCR_Employee_Detail__c where Quicklook_ID__c IN :QLIds]; 
            
            for(NCR_Employee_Detail__c emp : empList) {
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
    
    @future(callout=true)
    public static void getInvoiceDetailInFuture(String caseId, String ctryCode) {
        System.debug('caseId>>' + caseId + ',ctryCode>>' + ctryCode);
        List<Dispute_Invoices__c> dispInvList = [SELECT Id,Dispute__c,Dispute__r.CaseNumber, Balance_Due__c,Country_Code__c, Currency_Code__c, Customer_Name__c,
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
            String error = '';
            
           
            // call service from invNbrs set and get Result in a map
            UserInvoiceAuthanticationCCAD.InvoiceDataDisplayWrapper invResult = getInvoiceDetailFromERP(new List<String>(dispInvMap.keySet()), ctryCode, caseNumber);
            
            if(invResult.ErrorCode != NULL && invResult.ErrorCode == 700) {
                if (invResult != NULL && invResult.InvoiceDetail != NULL && !invResult.InvoiceDetail.isEmpty()) {
                    for (SoupERPResult.Invoice erpInv : invResult.InvoiceDetail) {
                        Dispute_Invoices__c dispInv = dispInvMap.get(erpInv.InvoiceNumber);                            
                        if (dispInv != NULL) {
                            populateInvoiceDetail(erpInv, dispInv); 
                            updateInvList.add(dispInv);
                        }
                    }    
                }
            }
        }
        
       if(!updateInvList.isEmpty()) update updateInvList;
        
    }
    
   public Contact createContact(DisputeSyncService.ContactDetail contDtl, String accId, Boolean isAltContact) {   
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
    
    public Static String getDspROR() {        
    	CCAD_Config__mdt cfg = CCAD_Config__mdt.getInstance('Org_Config');
        return (cfg != NULL ? cfg.Dispute_ROR_System__c : '');     
    }
    
    public static void populateInvoiceDetail(SoupERPResult.Invoice erpInv, Dispute_Invoices__c dispInv) {
        Map<String, Integer> monthMap = new Map<String, Integer>{'JAN'=>1, 'FEB'=>2,'MAR'=>3,'APR'=>4,'MAY'=>5,'JUN'=>6,'JUL'=>7,'AUG'=>8,'SEP' =>9,'OCT'=>10,'NOV' =>11,'DEC'=>12};
        
        dispInv.Country_Code__c = erpInv.CountryCode;
        dispInv.Customer_Trx_ID__c = erpInv.CustomerTrxID != null ? Decimal.valueOf(erpInv.CustomerTrxID) : NULL;
        dispInv.MCN__c = erpInv.MCN;
        dispInv.Customer_Name__c = erpInv.CustomerName;
        dispInv.Source__c = erpInv.Source;
        dispInv.PO_Number__c = erpInv.PONumber;
        dispInv.Related_Order__c = erpInv.RelatedOrder;
        dispInv.Summary_Invoice__c = erpInv.SummaryInvoice;
      
        if(erpInv.InvoiceDate != NULL) {
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
        }
        dispInv.Transaction_Type__c = erpInv.TransactionType;
        dispInv.Currency_Code__c = erpInv.CurrencyCode;
        dispInv.CurrencyIsoCode = erpInv.CurrencyCode;
        dispInv.Original_Balance__c = erpInv.OriginalBalance != null ? Decimal.valueOf(erpInv.OriginalBalance) : NULL;
        dispInv.Balance_Due__c = erpInv.BalanceDue != null ? Decimal.valueOf(erpInv.BalanceDue) : NULL; 
        dispInv.Line_Amount__c = erpInv.LineAmount != null ? Decimal.valueOf(erpInv.LineAmount) : NULL;
        dispInv.Tax_Amount__c = erpInv.TaxAmount != null ? Decimal.valueOf(erpInv.TaxAmount) : NULL;
        dispInv.Freight_Amount__c = erpInv.FreightAmount != null ? Decimal.valueOf(erpInv.FreightAmount) : NULL;
        dispInv.Total_Invoice_Amount__c = erpInv.TotalInvoiceAmount != null ? Decimal.valueOf(erpInv.TotalInvoiceAmount) : NULL;
        dispInv.Invoice_Get_Status__c = erpInv.InvoiceStatus;
    }
    
    
    public static UserInvoiceAuthanticationCCAD.InvoiceDataDisplayWrapper getInvoiceDetailFromERP(List<String> InvoiceList , String CountryCode, String caseNumber) {
        SoupERPResult ParsedObj= new SoupERPResult();  
        UserInvoiceAuthanticationCCAD.InvoiceDataDisplayWrapper InvoiceDetailMap = new UserInvoiceAuthanticationCCAD.InvoiceDataDisplayWrapper();
        String InvRequest = '';
        String invResponse = '';
        String responseStatus = ''; 
        Integer respStatusCode = NULL;
        Integer callCount = 0; 
        
        while(callCount < 3) {
            try {
                if(InvoiceList != null && InvoiceList.size() > 0  && String.isNotBlank(CountryCode)) {            
                    Generaterequestheader.ERPInvoiceHeaderRequestABM GenerateRequestObj = new Generaterequestheader.ERPInvoiceHeaderRequestABM();
                    Generaterequestheader.RequestHeader headerRequest = new Generaterequestheader.RequestHeader(); 
                    headerRequest.TransactionID='123e4567-e89b-12d3-a456-42665544';
                    headerRequest.SourceSystem='NSC';
                    headerRequest.Timestamp='2020-06-15T11:56:12.418-04:00';
                    headerRequest.TargetSystem='ERP';
                    
                    GenerateRequestObj.RequestHeader=headerRequest; 
                    Generaterequestheader.Invoices invoices = new Generaterequestheader.Invoices();
                    for(String invoiceNo : InvoiceList) {
                        
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
                    InvRequest = Generaterequestheader.parse(ObjectToParse);
                    System.debug(InvRequest);
                    
                    SOUP_Endpoint__c SOUPCred = SOUP_Endpoint__c.getInstance('CCAD Invoice Rest');
                      
                      
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                   // request.setEndpoint(SOUPCred.Endpoint_URL__c);
                    request.setEndpoint('callout:SOUP_CCAD_Invoice_Rest');
                    //request.setEndpoint(' https://osbdev-ha.ncr.com/ext/EA/Services/ERP/Invoice/getInvoiceDetails');
                    
                    request.setMethod('GET');
                    request.setTimeout(40000); 
                    //String username = SOUPCred.Username__c;
                    //String password = SOUPCred.Password__c;
                    //Blob headerValue = Blob.valueOf(username + ':' + password); 
                    //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    //request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept', 'application/json');
                    
                    request.setBody(Generaterequestheader.parse(ObjectToParse));
                    
                    HttpResponse response = http.send(request);
                    invResponse = response.getBody();
                    system.debug('>>>>>>'+invResponse);
                    system.debug('response.getStatusCode()'+response.getStatusCode());
                    
                    respStatusCode = response.getStatusCode(); 
                    responseStatus  = response.getStatus();
                    
                    if (response.getStatusCode() != 200) {
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        InvoiceDetailMap.ErrorCode= response.getStatusCode();
                        InvoiceDetailMap.displayMsg=response.getStatus();
                        return InvoiceDetailMap;
                    } else {
                        ParsedObj =   SoupERPResult.parseResponse(response.getBody());
        
                        Set<String> McnSet = new Set<String>();
                        for(SoupERPResult.Invoice s : ParsedObj.ERPInvoiceHeaderResponseABM.ERPInvoiceHeaderResponse.Invoices.invoice) {
                            //InvoiceDetailMap.
                            McnSet.add(s.MCN);
                            InvoiceDetailMap.InvoiceDetail.add(s);
                        }
                    }
                }
            } catch(Exception e) {
                InvoiceDetailMap.ErrorCode = 300; // internal error
                InvoiceDetailMap.displayMsg = e.getMessage();   
                invResponse = e.getMessage();   
            }
            
            if(respStatusCode == 200) {
                break;    
            }
            
            callCount++;
        }
        
        CCADDLogsUtility.insertCCADDLogs(InvRequest, invResponse,responseStatus, caseNumber,null, 'SF-ERP');    
        return InvoiceDetailMap;      
    } 
    
  
    
    
}