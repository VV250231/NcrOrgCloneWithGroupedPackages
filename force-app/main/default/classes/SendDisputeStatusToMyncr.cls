@RestResource(urlMapping='/invoiceDispute/status')
global with sharing class SendDisputeStatusToMyncr {
   
    @HttpGet
    global static DisputeResponse getDisputeHeader() {
       String DisputeID,IsExternalOnly='',transId='',srcSys='';
       DisputeResponse dspResp = new DisputeResponse();
       DisputeResponseHeader respHdr = new DisputeResponseHeader(); 
       DisputeListWrapper dspLstWrap = new DisputeListWrapper();
        
             RestRequest request = RestContext.request;
             Map <String, String> reqHeaders = RestContext.request.headers;
             Map <String, String> reqParams = RestContext.request.params;
             
             system.debug('reqHeaders '+reqHeaders);
        
             if(reqHeaders != null && !reqHeaders.isEmpty()) {
                 
        		 
        		 transId=reqHeaders.get('x-transaction-id');
                
                 srcSys=reqHeaders.get('x-source-system');
               
        	 }
            
            if(reqParams != null && !reqParams.isEmpty()) {
                //DisputeID=reqParams.get('DisputeID');
                DisputeID= reqParams.get('DisputeID');
                system.debug('DisputeID'+DisputeID);
                //IsExternalOnly = RestContext.request.params.get('IsExternalOnly');
                IsExternalOnly= reqParams.get('IsExternalOnly');
            }
            
            String vldErr = vldtRqst(transId, DisputeID);        
            Boolean isVldReq = String.isBlank(vldErr);
           
       try{
            if(isVldReq) {
                String dspRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.RT_Case_Dispute).getRecordTypeId();
                String dspQry='SELECT CommentBody, Parent.Status, Parent.CaseNumber, Parent.CCAD_Dispute_Nbr__c, Parent.DisputeAnalyst__r.Name, CreatedDate, CreatedBy.Name, Parent.Dispute_CreatedBy_Qlook__c, Parent.Contact.Name, Parent.ContactId from caseComment where ';
                if(String.isNotBlank(DisputeID)){
                    dspQry += ' Parent.CCAD_Dispute_Nbr__c = \'' + DisputeID + '\' ';  
                   
                  
                }
                
                if(String.isNotBlank(IsExternalOnly) && IsExternalOnly.toUpperCase() == 'Y'){
                     dspQry += ' AND IsPublished = true ';	
                }
                dspQry +=' Order By CreatedDate Desc';
                
                system.debug('dspQry'+dspQry);
                List<DisputeDetail> dspLst = new List<DisputeDetail>();                
                List<CaseComment> commLst = Database.query(dspQry);
                Integer CmtId=commLst.size();
                
               
                 /*if(cm.CommentBody.startsWith('[Comment from Other System - Created By: ')) {
                        Integer startIdx= cm.CommentBody.indexOf(']\n\n');
                        dsp.Comment = (startIdx != -1) ? cm.CommentBody.subString(startIdx + 3) : cm.CommentBody;	
                        dsp.CreatedBy=cm.CommentBody.substringBetween('[Comment from Other System - Created By: ', '(');
                        if(String.isNotBlank(dsp.CreatedBy)) dsp.CreatedBy = dsp.CreatedBy.trim();
                 }*/  
                for(CaseComment cm : commLst) {
                    //system.debug('cm'+cm.Id);
                    DisputeDetail dsp = new DisputeDetail();
                    dsp.DisputeID=cm.Parent.CCAD_Dispute_Nbr__c;
                    //dsp.ID=cm.Parent.Id;
                    dsp.CreatedDate=cm.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    dsp.Status=cm.Parent.Status;
                    
                    Matcher matcher = new ERPDisputeUtil().matchPattern(cm.CommentBody);                    
                    if(matcher.find()) {
                    	String cmntCrtdByStr = matcher.group(1); 
                        String cmntSubmitter = matcher.group(2);
                        
                        if(String.isNotBlank(cmntCrtdByStr)) {
                        	Integer startIdx = cm.CommentBody.indexOf(cmntCrtdByStr);     
    						dsp.Comment = cm.CommentBody.subString(startIdx + cmntCrtdByStr.length());    
                        }
                        
                        if(String.isNotBlank(cmntSubmitter)) {
                        	 dsp.CreatedBy = cmntSubmitter;    
                        }
                    } else {
                    	dsp.Comment = cm.CommentBody;    
                        dsp.CreatedBy=cm.CreatedBy.Name;
                    }

                    dsp.AssignedTo=cm.Parent.DisputeAnalyst__r.Name;
                  
                    dsp.CommentID=CmtId;
                    
                   /*if(String.isNotBlank(cm.Parent.Dispute_CreatedBy_Qlook__c) && cm.Parent.Dispute_CreatedBy_Qlook__c == 'MyNCR') {
						if(String.isNotBlank(cm.Parent.ContactId)) dsp.CreatedBy = cm.Parent.Contact.Name;                        
                    } else {
                    	 dsp.CreatedBy = cm.Parent.Dispute_CreatedBy_Qlook__c + ' ('+ cm.Parent.Dispute_CreatedBy_Qlook__c + ')';     
                    }*/
                     dspLst.add(dsp); 
                    CmtId = CmtId -1;
                }
                dspLstWrap.Dispute = dspLst; 
                respHdr.Status = 'SUCCESS';
            }
           else{
               respHdr.Status = 'FAILURE';	 
               dspLstWrap.ResponseDescription = vldErr; 
           }
        }
        catch(Exception e){
           respHdr.Status = 'FAILURE';	 
           dspLstWrap.ResponseDescription = e.getMessage();
        }
        
        
        respHdr.TransactionID = String.isNotBlank(transId) ? transId : '';       
        respHdr.Timestamp = Datetime.now().format();
        dspResp.ResponseHeader = respHdr;
        dspResp.InvoiceDisputeResponse = dspLstWrap; 
        
        CCADDLogsUtility.insertDisputeLogs(transId, String.valueOf(reqParams), JSON.serialize(dspResp), dspResp.ResponseHeader.Status, DisputeID, 'GetStatus_' + (String.isNotBlank(srcSys) ? srcSys :'Unknown') + '-SF'); 
    	return dspResp; 
        
    }
    
    
    public static String vldtRqst(String transId, String dspId) {
         String err = '';
         //system.debug('>>>>>>>>>>'+dspId);
        if(String.isBlank(transId))  {
        	err = 'Transacton ID not found in GetStatus Request. ';    
        }
        
        if(String.isBlank(dspId)){
            err=err+'Dispute Id is missing in GetStatus Request. ';
        }
        return err;

    }
    
   
    
   global class DisputeResponse {
    	global DisputeResponseHeader ResponseHeader;
        global DisputeListWrapper InvoiceDisputeResponse;    
    }
    
    global class DisputeListWrapper { 
        global String ResponseCode;
        global String ResponseDescription;
    	List<DisputeDetail> Dispute;    
    }
    
    global class DisputeDetail { 
   		//global String ID;
		global String Comment;
		global Integer CommentID;
		global String Status;
		global String CreatedBy;
		global String CreatedDate;
		global String AssignedTo;
		global String DisputeID;
    }
  
}