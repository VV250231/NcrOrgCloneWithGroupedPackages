/****************************************************************************************************
* Author        :   Santosh Jha  
* Date          :   08-08-2021
* Description   :   This REST service will add comment and attachements to existing dispute and send response to MyNCR
*************************************************************************************************/


@RestResource(urlMapping='/invoiceDispute/updateCommentAndAttachment')
global with sharing class updateCommentAndAttachmentService {
    
    @HttpPut
    global static DisputeResponse UpdateDispute()
    {

        String requestBody;
        string strStatus;
        string sfCaseNbr;
        String dspRtId;
        string strDescription;
        string crtByUserId;
        String submtrName;
        integer Invoicecount;
        DisputeResponse dspResp = new DisputeResponse();
        DisputeResponseHeader cc = new DisputeResponseHeader();
        RequestHeader rh = new RequestHeader();
        cls_InvoiceDisputeResponse cidr = new cls_InvoiceDisputeResponse(); 
        DisputeUtil dspUtil = new DisputeUtil();

        //case c = [SELECT Id FROM case where CaseNumber =: d.DisputeID and RecordTypeId =: dspRtId LIMIT 1];
        //Case dspCase = dspUtil.getCaseDetail(d.DisputeID, '238687', dspRtId); // Check existing Dispute Case
        
        try {
            if (DisputeUtil.getDspROR() != 'SF') throw new DisputeException(Label.MyNCR_DspSrvUnavl);
            
            RestRequest caseRequest = RestContext.request;
            requestBody = caseRequest.requestBody.toString();
            MainHeader mh = (MainHeader) JSON.deserialize(requestBody, MainHeader.class);
            
            InvoiceDisputeRequest idr = mh.InvoiceDisputeRequest;
            rh = mh.RequestHeader;
            Dispute d = idr.Dispute;
            sfCaseNbr = d.DisputeID;
            crtByUserId = d.CreatedBy;
            submtrName = d.SubmitterName;
            dspRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.RT_Case_Dispute).getRecordTypeId();
  
            Case c;
            if (String.isNotBlank(sfCaseNbr)) {
                List<Case> caseList = [SELECT Id FROM CASE WHERE CCAD_Dispute_Nbr__c = :sfCaseNbr and RecordTypeId =:dspRtId LIMIT 1];                           
                c = (!caseList.isEmpty()) ? caseList.get(0) : NULL;
            }
            if(c <> NULL )
            {
                string uId;
                Boolean isPublicComment = false;
                //List<user> userList = [SELECT Id FROM user WHERE Quicklook_ID__c = :strUserId LIMIT 1];                           
                //uId = (!userList.isEmpty()) ? userList.get(0).id : '00570000003i3u3AAA';
                String crtdByUsr = ''; 
                if(String.isNotBlank(crtByUserId)) {
                    if(crtByUserId.equalsIgnoreCase('MyNCR')) {
                   		crtdByUsr =  '(External)';  
                        isPublicComment = true;
                    } else {
                    	crtdByUsr =  '(' + crtByUserId + ')';             
                    }
                }
                String cmntPrfx = String.format(Label.CmntCrtdByPrfx, new List<String>{'MyNCR',submtrName,crtdByUsr}) + '\n\n';               
                insertCaseComment(cmntPrfx + d.Comment, isPublicComment, c.id,uId);
                
                if (d.Attachment<> Null)
                {SaveAttachments(d.Attachment, c.id, dspUtil);}
                
                AggregateResult groupedResults= [select count(id) invoicecount from Dispute_Invoices__c  where Dispute__r.CCAD_Dispute_Nbr__c=: sfCaseNbr];
                Invoicecount = (integer)groupedResults.get('invoicecount');
                
                strStatus = 'SUCCESS';  
                strDescription = 'Comment Saved';
                
            }
            else 
            {
                strStatus = 'FAILURE';   
                strDescription = 'Existing Case not found';
            }
            
        }
        catch(Exception e) {
            strStatus = 'FAILURE';   
            strDescription = e.getMessage();
            system.debug('debugggggg:::'+ e.getMessage());
        }
        
        cc.TransactionID = rh.TransactionID;
        cc.Timestamp =  Datetime.now().format();
        cc.Status = strStatus;
        dspResp.ResponseHeader =cc;
        
        cls_Dispute cd = new cls_Dispute();
        cd.Result = strDescription;
        cd.DisputeID = sfCaseNbr;
        cd.InvoiceCount = Invoicecount;
        cidr.Dispute = cd;
        dspResp.InvoiceDisputeResponse = cidr;
        
        //genDispIntgLog(requestBody, JSON.serialize(dspResp), strStatus, 'MYNCR-SF', sfCaseNbr);
        CCADDLogsUtility.insertDisputeLogs(rh.TransactionID,requestBody,JSON.serialize(dspResp),strStatus,sfCaseNbr,'UpdateCommentAndAttachment_MYNCR-SF');
        return dspResp;
        
    }
    
    static void SaveAttachments(List<Attachment> AttachmentList, String caseId, DisputeUtil dspUtil) {
        List<Other_Attachments__c> newOtherAttchList = new List<Other_Attachments__c>();
        Map<String,Other_Attachments__c> existAttachMap = new Map<String,Other_Attachments__c>();
        Set<String> attachURLs = new Set<String>();
        
        existAttachMap = dspUtil.getAllNonSFAttachments(caseId);
        
        if(AttachmentList.size()> 0) {
            Set<String> updateURLs = new Set<String>();
            
            for(Attachment att: AttachmentList)  {
                if(att.Source != 'NSC') {
                    if(!attachURLs.contains(att.URL)) {
                        attachURLs.add(att.URL);
                        Other_Attachments__c otherAttach = new Other_Attachments__c(Case__c = caseId, Attachment_Source__c = att.Source, Attachment_Description__c = att.Description, 
                                                                                    Attachment_FULL_URL__c = att.URL);
                        
                        if(existAttachMap.containsKey(att.URL)) {
                            otherAttach.Id = existAttachMap.get(att.URL).Id; 
                            newOtherAttchList.add(otherAttach);                                                                                      
                            existAttachMap.remove(att.URL);  
                        } else {
                            newOtherAttchList.add(otherAttach);
                        }
                    }
                }
            }
        }
        
        
        if(!newOtherAttchList.isEmpty()) upsert newOtherAttchList;
        if(!existAttachMap.isEmpty()) delete existAttachMap.values();
    }
    
    static void insertCaseComment(String strComment, Boolean isPublic, String caseId, string userId) {
        if(String.isNotBlank(strComment)) {
            CaseComment comment = new CaseComment(ParentId = caseId, isPublished = isPublic, CommentBody = strComment);
            insert comment;
        }
    }
    
    
    /*static void genDispIntgLog(String reqMsg, String respMsg, String status, String requestType, String caseNumber) {
        Dispute_integration_logs__c dil= new Dispute_integration_logs__c();
        dil.Request__c=reqMsg;
        dil.Response__c=respMsg;
        dil.Status__c=status;
        dil.RequestType__c=requestType;        
        //dil.caseNumber__c=caseNumber;  
        dil.CCAD_Dispute_Nbr__c = caseNumber; 
        insert dil;
    }*/
    
    
    //************************
    global class MainHeader {
        public RequestHeader RequestHeader;
        public InvoiceDisputeRequest InvoiceDisputeRequest;
    }
    global class InvoiceDisputeRequest {
        public Dispute Dispute;
    }
    global class RequestHeader {
        public String TransactionID;
        public String Timestamp;
        public String SourceSystem;
        public String TargetSystem;
    }
    global class Dispute {
        public String DisputeID;
        public String CreatedBy;
        public String SubmitterName;
        public String Comment;
        public List<Attachment> Attachment;
    }
    global class Attachment {
        public String Source;
        public String Description;
        public String URL;
    }
    
    
    //*********************
    Global class DisputeResponse{
        public DisputeResponseHeader ResponseHeader;
        public cls_InvoiceDisputeResponse InvoiceDisputeResponse;
    }
   
    Global class cls_InvoiceDisputeResponse {
        public cls_Dispute Dispute;
    }
    Global class cls_Dispute {
        public String Result;   //Comment Saved
        public String DisputeID;    //14773
        public integer InvoiceCount;    //123
    }
    
    global class DisputeException extends Exception {}
}