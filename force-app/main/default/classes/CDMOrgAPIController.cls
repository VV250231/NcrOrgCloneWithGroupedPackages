public class CDMOrgAPIController implements Queueable, Database.AllowsCallouts {
    
    final String HTTP_SUCCESS_STATUS = 'OK', CDM_SUCCESS_STATUS = 'Success';
    final Integer HTTP_SUCCESS_STATUS_CODE = 200, BATCH_SIZE = 2;
    //SOUP_Endpoint__c CDMcrd;
    
    integer strtIdx,endIdx,rtryCount;
    List<Account> cdmUpdateAccts = new List<Account>();
    List<CDM_Log__c> logLst = new List<CDM_Log__c>();
    Map<String, String> acctUpdateErrs = new Map<String, String>(); 
    
    public CDMOrgAPIController(List<Account> cdmUpdateAccts) {
        this.cdmUpdateAccts  = cdmUpdateAccts;
        this.strtIdx = 0;
        this.endIdx = (this.strtIdx + BATCH_SIZE <= cdmUpdateAccts.size()) ? (this.strtIdx + BATCH_SIZE) : cdmUpdateAccts.size(); 
        this.rtryCount = 0; 
    }
    
    public CDMOrgAPIController(List<Account> cdmUpdateAccts, Map<String, String> acctUpdateErrs, List<CDM_Log__c> logLst, integer strtIdx, integer retryCount) {
       system.debug('--------'+cdmUpdateAccts);
        this.cdmUpdateAccts  = cdmUpdateAccts;
        this.acctUpdateErrs = acctUpdateErrs;
        this.strtIdx = strtIdx;
        this.logLst = logLst;
        this.endIdx = (this.strtIdx + BATCH_SIZE <= cdmUpdateAccts.size()) ? (this.strtIdx + BATCH_SIZE) : cdmUpdateAccts.size();
        this.rtryCount = retryCount;
    }
    
    public void execute(QueueableContext qc) { 
        
        if (!cdmUpdateAccts.isEmpty() && strtIdx < endIdx) { 
            try {
                //CDMcrd = SOUP_Endpoint__c.getInstance('CDM');
                
               // if(!IsCorrectEndpntForCurrEnv(CDMcrd.Endpoint_URL__c)) 
                 //   throw new EndpointException('Incorrect endpoint found for CDM Owner Sync in this environment. Please update Custom Setting - SOUP_Endpoint__c with record name "CDM" and try again.');
                
                Set<Id> userIds = new Set<Id>(); 
                for(integer i=strtIdx; i < endIdx; i++) {
                    userIds.add(cdmUpdateAccts[i].OwnerId);    
                }
                
                if(!userIds.isEmpty()) {
                    Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Quicklook_ID__c FROM User WHERE Id IN :userIds]);
                    Set<String> empQLIds = new Set<String>();
                    
                    for(User u : ownerMap.values()) {
                        empQLIds.add(u.Quicklook_ID__c.toUpperCase());   
                    }
                    
                    for(NCR_Employee_Detail__c emp : [SELECT Id, Quicklook_ID__c FROM NCR_Employee_Detail__c WHERE Quicklook_ID__c IN :empQLIds]) {
                        empQLIds.remove(emp.Quicklook_ID__c.toUpperCase());
                    }
                    
                    for(integer i = strtIdx; i < endIdx; i++) {
                        Account acc = cdmUpdateAccts[i];        
                        String ownerQLId = ownerMap.get(acc.OwnerId).Quicklook_ID__c;
                        
                        // if owner not blank and owner quicklook exist in NCR_Employee_Detail__c object
                        if((ownerQLId != NULL) && (!empQLIds.contains(ownerQLId.toUpperCase()))) {
                            updateAccountOwnerInCDM(acc, ownerQLId, rtryCount);  
                        }
                    } 
                }  
                
            } catch(Exception e) {
                String errMsg = e.getMessage(); 
                System.debug('Exception::' + errMsg ); 
                
                for(integer i = strtIdx; i < endIdx; i++) {
                    acctUpdateErrs.put(cdmUpdateAccts[i].Id, errMsg); 
                    logLst.add(genCDMlog(cdmUpdateAccts[i].Master_Customer_Number__c,NULL, errMsg,'FAILURE')) ;
                }
            }
        }
        
        if(cdmUpdateAccts.size() > endIdx) {
            if (acctUpdateErrs.get(cdmUpdateAccts[endIdx].Id) != null)  
                CDMUtil.addWait(1000); // wait for one second if last callout has error
            System.enqueueJob(new CDMOrgAPIController(cdmUpdateAccts, acctUpdateErrs, logLst, endIdx, rtryCount));    
        } else {
            System.debug(acctUpdateErrs);
            System.debug(rtryCount);
            
            if (acctUpdateErrs != null && acctUpdateErrs.size() > 0 && rtryCount < 3) { 
                rtryCount = rtryCount + 1; 
                retryAccountSync(acctUpdateErrs.keySet(), rtryCount);
            }     
            else {
                    // create logs 
                    if (logLst != NULL && logLst.size() > 0) {
                        insert logLst;
                    }
                    // send error email to support team
                    if (acctUpdateErrs != null && acctUpdateErrs.size() > 0) {
                        System.debug(acctUpdateErrs);
                        String msgSbj = 'Error in Updating Account Owner in CDM';
                        String msgbdy = '';
                        for(String strMCN : acctUpdateErrs.keySet()) {
                            msgbdy += 'Account Id-' + strMCN + ' : '+ acctUpdateErrs.get(strMCN) + ',';
                        }
                        CDMUtil.notifySupportTeam(msgSbj, msgbdy);
                    }
            }
            
        }
        
    }
    
    
    public void retryAccountSync(Set<String> errAccIds, Integer rtryCount) {
        List<Account> rtryAccLst = new List<Account>();
                    
        Map<Id, Account> inpAcctMap  = new Map<Id, Account>(cdmUpdateAccts);   
        
        for (String accId : errAccIds) {
            rtryAccLst.add(inpAcctMap.get(accId));   
        }   
        if(!Test.isRunningTest()) {
            CDMUtil.addWait(1000);  
            System.enqueueJob(new CDMOrgAPIController(rtryAccLst, new Map<String, String>(), logLst, 0, rtryCount));     
        }
    }
    
    //@future(callout = true)
    public void updateAccountOwnerInCDM(Account acc, String owrQLId, Integer rtryCount) {
        HttpRequest req;
        HttpResponse resp;
        CDM_Log__c cdmLog;
       
        try {
            //String CDMReq = generateRequestBody(new Uuid().getValue(), 'NSC', Datetime.now().format(), 'CDM', acc.Master_Customer_Number__c, owrQLId,acc.DI_Customer__c );
            String CDMReq = generateJSONRequestBody(new Uuid().getValue(), 'NSC', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', 'EST'), 'CDM', acc.Master_Customer_Number__c, owrQLId,acc.DI_Customer__c);
            System.debug(CDMReq);
            Http http = new Http();
            req = new HttpRequest();
            req.setEndpoint('callout:SOUP_CDM'); 
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(CDMReq);
            req.setTimeout(50000);
            //================================
            
          //  Blob hdrVal = Blob.valueOf(CDMcrd.Username__c + ':' + CDMcrd.Password__c);
           // String authHdr = 'BASIC ' + EncodingUtil.base64Encode(hdrVal);
           // req.setHeader('Authorization', authHdr);
            //==================================
            
            resp = http.send(req);
            System.debug(resp.getStatus());
            
            if (resp.getStatus() == HTTP_SUCCESS_STATUS && resp.getStatusCode() == HTTP_SUCCESS_STATUS_CODE) {
                System.debug(resp.getBody());
                //String respStr = parseXMLResponse(resp.getBody()); 
                String respStr = parseJSONResponse(resp.getBody()); 
                
                // if CDM update failed with fault, get error message 
                if(respStr == CDM_SUCCESS_STATUS) {  
                    System.debug('Account Owner successfully updated in CDM');  
                    cdmLog = genCDMlog(acc.Master_Customer_Number__c, req.getBody(), resp.getBody(),'SUCCESS');
                } else {
                    if(rtryCount == 3) cdmLog = genCDMlog(acc.Master_Customer_Number__c, req.getBody(), resp.getBody(),'FAILURE');
                    acctUpdateErrs.put(acc.Id, respStr);
                }
                
            } else {
                String errorMsg = resp.getBody();
                if(rtryCount == 3) cdmLog = genCDMlog(acc.Master_Customer_Number__c, req.getBody(), resp.getBody(),'FAILURE');
                acctUpdateErrs.put(acc.Id, errorMsg);
            }
        } catch(Exception e) {
            System.debug('Exception in updating Account owner in CDM ::' + e.getMessage());
            acctUpdateErrs.put(acc.Id, e.getMessage());
            if(rtryCount == 3) cdmLog = genCDMlog(acc.Master_Customer_Number__c, req.getBody(), e.getMessage(),'FAILURE');
        } finally {
            if(cdmLog != NULL) logLst.add(cdmLog);
        }     
    }
    
    public String generateJSONRequestBody(String txnID, String srcSys, String tmstp, String trgtSys, String accMCN, String accOwrQLID,String DiNbr) {
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('UpdateOrganizationReqABM');
        jsGen.writeStartObject();
        
        jsGen.writeFieldName('RequestHeader');
        jsGen.writeStartObject();
        jsGen.writeStringField('TransactionID',txnID);
        jsGen.writeStringField('SourceSystem',srcSys);
        jsGen.writeStringField('Timestamp',tmstp);
        jsGen.writeStringField('TargetSystem',trgtSys);        
        jsGen.writeEndObject();

        jsGen.writeFieldName('UpdateOrganizationRequest');
        jsGen.writeStartObject();
        jsGen.writeFieldName('OrganizationParty');
        jsGen.writeStartObject();
        jsGen.writeStringField('PartyNumber', accMCN);
        jsGen.writeStringField('PartyType', 'ORGANIZATION');

        jsGen.writeFieldName('OrganizationProfile');
        jsGen.writeStartArray();
        jsGen.writeStartObject();
        jsGen.writeStringField('NCRAccountManager_c', accOwrQLID);
        if(String.isNotBlank(DiNbr)) jsGen.writeStringField('DINumber_c', DiNbr);
        jsGen.writeStringField('SourceSystemName_c', 'NSC');
        jsGen.writeEndObject();
        jsGen.writeEndArray();        
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        return jsGen.getAsString(); 
    }
    
    
    public String generateRequestBody(String txnID, String srcSys, String tmstp, String trgtSys, String accMCN, String accOwrQLID,string DiNbr) {
       system.debug('--'+DiNbr);
       String CDMReq = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.ncr.com/SOUP/Service/CDM/Organization/V1" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/1.0">';
       if(DiNbr == NULL){
            CDMReq = CDMReq +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
            '<v1:CDMUpdateOrganizationReqABMMsg>' +
            '<v1:UpdateOrganizationReqABM>' +
            '<ns:RequestHeader>' +
            '<ns:TransactionID>' + txnID + '</ns:TransactionID>' + 
            '<ns:SourceSystem>' + srcSys + '</ns:SourceSystem>' + 
            '<ns:Timestamp>'+ tmstp +'</ns:Timestamp>' + 
            '<ns:TargetSystem>' + trgtSys + '</ns:TargetSystem>' + 
            '</ns:RequestHeader>' + 
            '<v1:UpdateOrganizationRequest>' + 
            '<v1:OrganizationParty>' + 
            '<v1:PartyNumber>' + accMCN + '</v1:PartyNumber>' + 
            '<v1:PartyType>ORGANIZATION</v1:PartyType>' + 
            '<v1:OrganizationProfile>' + 
            '<v1:NCRAccountManager_c>' + accOwrQLID + '</v1:NCRAccountManager_c>' + 
           
            '</v1:OrganizationProfile>                            ' + 
            '</v1:OrganizationParty>' + 
            '</v1:UpdateOrganizationRequest>' + 
            '</v1:UpdateOrganizationReqABM>' + 
            '</v1:CDMUpdateOrganizationReqABMMsg>' + 
            '</soapenv:Body>' + 
            '</soapenv:Envelope>';
        
       }
       else{
            CDMReq = CDMReq  +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
            '<v1:CDMUpdateOrganizationReqABMMsg>' +
            '<v1:UpdateOrganizationReqABM>' +
            '<ns:RequestHeader>' +
            '<ns:TransactionID>' + txnID + '</ns:TransactionID>' + 
            '<ns:SourceSystem>' + srcSys + '</ns:SourceSystem>' + 
            '<ns:Timestamp>'+ tmstp +'</ns:Timestamp>' + 
            '<ns:TargetSystem>' + trgtSys + '</ns:TargetSystem>' + 
            '</ns:RequestHeader>' + 
            '<v1:UpdateOrganizationRequest>' + 
            '<v1:OrganizationParty>' + 
            '<v1:PartyNumber>' + accMCN + '</v1:PartyNumber>' + 
            '<v1:PartyType>ORGANIZATION</v1:PartyType>' + 
            '<v1:OrganizationProfile>' + 
            '<v1:NCRAccountManager_c>' + accOwrQLID + '</v1:NCRAccountManager_c>' + 
            '<v1:DINumber_c>' + DiNbr + '</v1:DINumber_c>' + 
            '</v1:OrganizationProfile>                            ' + 
            '</v1:OrganizationParty>' + 
            '</v1:UpdateOrganizationRequest>' + 
            '</v1:UpdateOrganizationReqABM>' + 
            '</v1:CDMUpdateOrganizationReqABMMsg>' + 
            '</soapenv:Body>' + 
            '</soapenv:Envelope>';
        }
        return CDMReq;
    }
    
    public String parseJSONResponse(String jsonRsp) {
        Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(jsonRsp);
        String respStatus = '';
        
        if (respObj.get('UpdateOrganizationRespABM') != NULL) {
            Map<String, Object> updateOrgRspABM = (Map<String, Object>) respObj.get('UpdateOrganizationRespABM'); 
            Map<String, Object> respHdr = (Map<String, Object>) updateOrgRspABM.get('ResponseHeader');
            respStatus = (String) respHdr.get('Status');
            System.debug('resp status>>' + respStatus);
            if (respStatus != CDM_SUCCESS_STATUS) respStatus = 'Unknown exception occured';
        } else {
            if(respObj.get('Fault') != null || (respObj.get('Status') != NULL && respObj.get('Status') == 'ERROR')) {
                Map<String, Object> faultDtl = (Map<String, Object>)respObj.get('Fault');
                
                if (faultDtl != NULL) {
                    respStatus = 'faultCode=' + (String)faultDtl.get('faultCode') + '&fault Description=' + faultDtl.get('faultDescription');
                } else {
                    respStatus = 'Unknown exception occured';   
                }
            }  
        }
        return respStatus;     
    }
    
    public String parseXMLResponse(String xmlRsp) {
        DOM.Document doc=new DOM.Document();
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String CDMOrgNS = 'http://xmlns.ncr.com/SOUP/Service/CDM/Organization/V1';
        String CDMCommonNS  = 'http://xmlns.ncr.com/SOUP/Common/1.0';
        
        doc.load(xmlRsp);
        DOM.XmlNode SOAPBody = doc.getRootElement().getChildElement('Body', soapNS);
        DOM.XmlNode cdmRespHdr = SOAPBody.getChildElement('CDMUpdateOrganizationRespABMMsg', CDMOrgNS).getChildElement('UpdateOrganizationRespABM', CDMOrgNS);
        String respSts = cdmRespHdr.getChildElement('ResponseHeader', CDMCommonNS).getChildElement('Status', CDMCommonNS).getText();                     
        String updateTimeStamp = cdmRespHdr.getChildElement('ResponseHeader', CDMCommonNS).getChildElement('Timestamp', CDMCommonNS).getText();                     
        
        if (respSts != CDM_SUCCESS_STATUS) {
            // get and parse fault message from CDM 
            respSts = 'Unknown SOUP fault';
        } else {
            System.debug('Account Owner successfully updated in CDM');  
        }
        return respSts;     
    }
    
    public String parseErrorResponse(String errRsp) {
        String errMsg = '';
        
        try {
        DOM.Document doc=new DOM.Document();
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String CDMOrgNS = 'http://xmlns.ncr.com/SOUP/Service/CDM/Organization/V1';
        String CDMCommonNS  = 'http://xmlns.ncr.com/SOUP/Common/1.0';
        
        doc.load(errRsp);
        DOM.XmlNode SOAPBody = doc.getRootElement().getChildElement('Body', soapNS).getChildElement('Fault', soapNS);
        String fltCode = SOAPBody.getChildElement('faultcode', null).getText();
        String fltDesc = SOAPBody.getChildElement('faultstring', null).getText();
        
        //send error response email to NSC team
        /*System.debug('faultCode >>>>' + fltCode );
        System.debug('fault Description >>>>' + fltDesc);*/
        errMsg = 'faultCode=' + fltCode + '&fault Description=' + fltDesc;
        } catch(Exception e) {
            return errRsp;
        }
        return errMsg;
    }
      
 /*   public boolean IsCorrectEndpntForCurrEnv(string endpnt) {
        String currUrl = System.URL.getSalesforceBaseUrl().getHost(); 
        Boolean isSFProd = currUrl.contains('ncr.my.salesforce.com');
        Boolean isCDMProd = !endpnt.contains('osbdev-ha.') && !endpnt.contains('osbcert-ha.') && !endpnt.contains('test.sb.')
                             && !endpnt.contains('certification-') && !endpnt.contains('development-');
        
        return (isSFProd  && isCDMProd  || !isSFProd && !isCDMProd  || Test.isRunningTest());
        
    }*/
    
    public CDM_Log__c genCDMlog(String MCN,String reqMsg, String resMsg, String respSts) {
        CDM_Log__c cdmLog = new CDM_Log__c(CDM_Action__c = 'Account Owner Update', Entity_Type__c = 'Account', Response_Status__c = respSts,
                                            Entity_Number__c = MCN, Request_Message__c= reqMsg, Response_Message__c = resMsg);
        
        return cdmLog;
    }
    
    
    
    public class EndpointException extends Exception{}
}