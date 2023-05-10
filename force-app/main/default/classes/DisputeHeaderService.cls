/*
*********************************************************
Apex Class Name    : DisputeHeaderService
@description       : This webservice will return Disputes Header details for DisputeId, MCNs, InvoiceId and Country Code.
@author            : Puneet Bhatia
Modification Log:
Date             Author               Modification
01-20-2022       Puneet Bhatia        Initial Version
*********************************************************
*/
@RestResource(urlMapping='/invoiceDispute/header')
global with sharing class DisputeHeaderService {
    
    @HttpGet
    global static DisputeResponse getDisputeHeader() {
        String dspId='',mcns,openType,invId,ctryCode,transId='',srcSys='';
        DisputeResponse dspResp = new DisputeResponse();
        DisputeResponseHeader respHdr = new DisputeResponseHeader();
        DisputeListWrapper dspLstWrap = new DisputeListWrapper();
        
        RestRequest request = RestContext.request;    
        Map <String, String> rqHdrs = RestContext.request.headers;
        Map <String, String> rqPrms = RestContext.request.params;
        
        if(rqHdrs != null && !rqHdrs.isEmpty()) {
            transId = rqHdrs.get('x-transaction-id');  
            srcSys = rqHdrs.get('x-source-system'); 
        }
        
        if(rqPrms != null && !rqPrms.isEmpty()) {
            dspId = rqPrms.get('DisputeID');
            mcns = rqPrms.get('MCNs');
            openType = rqPrms.get('OpenType');
            invId = rqPrms.get('InvoiceID');
            ctryCode = rqPrms.get('CountryCode');
        }
        
        try {  
            String vldErr = vldtRqst(transId, dspId, mcns, openType, invId, ctryCode);        
            Boolean isVldReq = String.isBlank(vldErr);        
       
            if(isVldReq) {            
                String dspRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.RT_Case_Dispute).getRecordTypeId();
				integer maxdspRsp = Integer.valueOf(CCAD_Config__mdt.getInstance('Org_Config').GetHeader_Max_Dispute_Count__c);
                String dspQry = 'SELECT RecordTypeId,CCAD_Dispute_Nbr__c,CaseNumber, AccountId, Account.Name,Account.Master_Customer_Number__c, CreatedDate, LastmodifiedDate,ROR_Created_Date__c,'
                                       + 'toLabel(Dispute_Analyst_Name__c),Disputed_Amount__c,Dispute_Details__c, toLabel(Dispute_Reason__c), Status, Currency_Code__c, ' 
                                       + 'Country_Code__c,Dispute_CreatedBy_Qlook__c,Dispute_UpdatedBy_Qlook__c, Dispute_Created_By_Name__c,'
                                       + 'Dispute_Updated_By_Name__c,ERP_Dispute_Nbr__c,ContactId, Contact.Name, Customer_Contact_Email1__c, Customer_Contact_Phone1__c,'
                                       + 'Alternate_Contact__c, Alternate_Contact__r.Name, Alternate_Contact_Email1__c,Alternate_Contact_Phone1__c,'
                                       +'(SELECT Invoice_Number__c FROM Dispute_Invoices__r) FROM Case';
				 String queryFltr = '  WHERE RecordTypeId=:dspRtId';    
                
                if (String.isNotBlank(dspId)) {
                    List<String> dspLst = dspId.split(','); 
                    if(dspLst.size() > 1) throw new DisputeException('More than one Dispute ID not allowed in GetHeader Request');
                    
                    queryFltr += ' AND CCAD_Dispute_Nbr__c =:dspId';       
                } 
                
                if (String.isNotBlank(mcns)) { 
                    List<String> mcnLst = mcns.split(',');                    
                    //if(mcnLst.size() > 1000) throw new DisputeException('More than 1000 MCNs not allowed in GetHeader Request'); 
                    queryFltr += ' AND Account.Master_Customer_Number__c IN :mcnLst';
                    
                    if(String.isNotBlank(ctryCode)) {
                        queryFltr += ' AND Country_Code__c = :ctryCode';           
                    } 
                    
                    if(String.isNotBlank(invId)) {
                        queryFltr += ' AND Id IN (SELECT Dispute__c FROM Dispute_Invoices__c WHERE Invoice_Number__c = :invId)';           
                    } 
                } 
                
                if (String.isNotBlank(openType) && openType.toUpperCase() == 'Y') {
                    queryFltr += ' AND IsClosed=false';    
                }
                
                dspQry += queryFltr  + ' ORDER BY ROR_Created_Date__c LIMIT :maxdspRsp'; /* ' DESC LIMIT :maxdspRsp';*/
                System.debug(dspQry);
                
                
                String cntQry = 'Select count() FROM Case' + queryFltr;
                integer ttlRcrds = Database.countQuery(cntQry);  
                System.debug('totalRecords>>'+ ttlRcrds);
                
               
                
                List<DisputeDetail> dspLst = new List<DisputeDetail>();   
                List<DisputeDetail> revdspLst = new List<DisputeDetail>(); 
                
               for(Case c : Database.query(dspQry)) { 
                    DisputeDetail dsp = new DisputeDetail();     
                    dsp.DisputeID = safeStr(c.CCAD_Dispute_Nbr__c);
                    if (c.AccountId != NULL) {
                        dsp.Master_Customer_Number = safeStr(c.Account.Master_Customer_Number__c);
                        dsp.CustomerName = c.Account.Name;
                    }
                    dsp.Amount = c.Disputed_Amount__c != null ? c.Disputed_Amount__c : 0;
                    dsp.CountryCode = safeStr(c.Country_Code__c);
                    dsp.CurrencyCode = safeStr(c.Currency_Code__c);
                    dsp.ReasonCode = Label.DspRsnPrfx + ' ' + safeStr(c.Dispute_Reason__c);
                    dsp.Description = safeStr(c.Dispute_Details__c);
                    dsp.Status = safeStr(c.Status); 
                    dsp.CreatedOn = (c.ROR_Created_Date__c != NULL && c.ROR_Created_Date__c.Date() < c.CreatedDate.Date()) ? c.ROR_Created_Date__c.formatGMT('MMM dd yyyy hh:mmaa (z)') : c.CreatedDate.formatGMT('MMM dd yyyy hh:mmaa (z)');
                    
      
                    dsp.UpdatedOn = c.LastModifiedDate.formatGMT('MMM dd yyyy hh:mmaa (z)');                 
                    dsp.AssignedTo = safeStr(c.Dispute_Analyst_Name__c);
                    dsp.MyNCRDisputeID = c.CaseNumber;
                    dsp.ERPDisputeID = safeStr(c.ERP_Dispute_Nbr__c);
                    dsp.InvoiceID = '';
                    
                    if(String.isNotBlank(c.Dispute_CreatedBy_Qlook__c) && c.Dispute_CreatedBy_Qlook__c == 'MyNCR') {
                        if(String.isNotBlank(c.ContactId)) dsp.CreatedBy = c.Contact.Name;                        
                    } else {
                         dsp.CreatedBy = safeStr(c.Dispute_Created_By_Name__c) + (String.isNotBlank(c.Dispute_CreatedBy_Qlook__c) ? ' ('+ c.Dispute_CreatedBy_Qlook__c + ')' : '');     
                    }
                    
                    if(String.isNotBlank(c.Dispute_UpdatedBy_Qlook__c) && c.Dispute_UpdatedBy_Qlook__c == 'MyNCR') {
                        if(String.isNotBlank(c.ContactId)) dsp.UpdatedBy = c.Contact.Name;                        
                    } else {
                         dsp.UpdatedBy = safeStr(c.Dispute_Updated_By_Name__c) + (String.isNotBlank(c.Dispute_UpdatedBy_Qlook__c) ? ' ('+  c.Dispute_UpdatedBy_Qlook__c + ')' : '');     
                    }

                   dsp.SubmitterName = String.isNotBlank(c.ContactId) ? c.Contact.Name : ''; 
                   dsp.SubmitterPhoneNum = safeStr(c.Customer_Contact_Phone1__c);
                   dsp.SubmitterEmail = safeStr(c.Customer_Contact_Email1__c);

                   dsp.AlternateContactName = String.isNotBlank(c.Alternate_Contact__c) ? c.Alternate_Contact__r.Name : '';
                   dsp.AlternateContactEmail = safeStr(c.Alternate_Contact_Email1__c); 
                   dsp.AlternateContactPhone = safeStr(c.Alternate_Contact_Phone1__c);  
                    
                    
                    if(!c.Dispute_Invoices__r.isEmpty()) {
                        for (Dispute_Invoices__c inv : c.Dispute_Invoices__r) {
                            if(String.isNotBlank(inv.Invoice_Number__c)) {
                                dsp.InvoiceID += inv.Invoice_Number__c + ','; 
                            }
                        } 
                        if(String.isNotBlank(dsp.InvoiceID)) dsp.InvoiceID = dsp.InvoiceID.removeEnd(',');                                 
                    }
                    
                    dspLst.add(dsp);
                }
                
                for(integer i = dspLst.size()-1; i >= 0; i--){
                    revdspLst.add(dspLst[i]);
                }
                
                dspLstWrap.Dispute = revdspLst;  
                respHdr.Status = 'SUCCESS';                
                if(ttlRcrds > maxdspRsp) dspLstWrap.ResponseDescription = Label.GetHdrRspLimitExcd;     
                
            } else {
                respHdr.Status = 'FAILURE';  
                dspLstWrap.ResponseDescription = vldErr;               
            }
        } catch(Exception e) {
            respHdr.Status = 'FAILURE';  
            dspLstWrap.ResponseDescription = e.getMessage();
        }
        
        respHdr.TransactionID = safeStr(transId);       
        respHdr.Timestamp = Datetime.now().format();
        dspResp.ResponseHeader = respHdr;
        dspResp.InvoiceDisputeResponse = dspLstWrap; 
        
        CCADDLogsUtility.insertDisputeLogs(transId, String.valueOf(rqPrms), JSON.serialize(dspResp), dspResp.ResponseHeader.Status, dspId, 'GetHeader_' + (String.isNotBlank(srcSys) ? srcSys :'Unknown') + '-SF'); 
        return dspResp; 
    }
    
    public static String vldtRqst(String transId, String dspId, String mcns, String openType, String invId, String ctryCode) {
        String err = '';
        
        if(String.isBlank(transId))  {
            err = 'Transacton ID not found in GetHeader Request';    
        } else if (String.isBlank(dspId) && String.isBlank(mcns)) {
            err = 'Dispute ID or Master Customer Number missig in GetHeader Request';    
        } else if (String.isBlank(mcns) && (String.isNotBlank(invId) || String.isNotBlank(ctryCode))) {
            err = 'Master Customer Number missing for Invoice Id and Country Code in GetHeader request';  
        }
        return err;
    }
    
    public static String safeStr(String inStr) {
        return (String.isNotBlank(inStr) ? inStr : '');    
    }
         
    global class DisputeResponse {
        global DisputeResponseHeader ResponseHeader;
        global DisputeListWrapper InvoiceDisputeResponse;   
    }
    
    global class DisputeListWrapper { 
        global String ResponseCode;
        global String ResponseDescription;
        List<DisputeDetail> Dispute;
        
        public DisputeListWrapper() {
            this.ResponseCode = '';
            this.ResponseDescription = '';
        }
    }
    
    global class DisputeDetail  {
        global String DisputeID,
        CountryCode,
        Master_Customer_Number,
        CustomerName,
        CurrencyCode,
        ReasonCode,
        Description,
        Status,        
        CreatedBy,
        CreatedOn,
        UpdatedBy,
        UpdatedOn,        
        AssignedTo,
        MyNCRDisputeID,
        ERPDisputeID,
        AlternateContactName,
        AlternateContactEmail,
        AlternateContactPhone,
        SubmitterName,
        SubmitterPhoneNum,
        SubmitterEmail,        
        InvoiceID;
        global Decimal Amount;
    }
    
    public class DisputeException extends Exception{}

}