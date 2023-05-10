/*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   Integration to create disputes from MyNCR to SF
* Return        :   ERP Cloud
* Description   :   EBA_SF-1411
*************************************************************************************************/

global without sharing class ERPCloudDisputeSyncService {
    global final static String STATUS_SUCCESS = 'Saved';
    global final static String STATUS_FAILURE = 'No Invoice to Dispute';
    global final static String STATUS_WARNING = 'WARNING';
    global final static String CASE_DISPUTE_RECORDTYPE = 'Dispute';
    global Enum SourceSystem{MyNCR, CCAD, NSC}
    webservice static ERPDisputeSyncResponse SyncDispute_ERPCloud(DisputeDetail inputDispute) {
        System.debug('@@@@'+inputDispute);
        List<String> invoiceNoLst = new List<String>(), noOpenDspInvLst = new List<String>();    // This is contains invoice No which sends by MYNCR  
        ERPDisputeUtil dspUtil = new ERPDisputeUtil();     // This class contains all the util method
        ERPDisputeSyncResponse resp = new ERPDisputeSyncResponse(null,null,null,null,null,null); // return response to MyNCR team
        resp.InvListResp = new InvListRsp();
        resp.InvListResp.Invoice = new List<InvRsp>();
        List<OracleCloudToSFService.InvoiceList> scssInvLst = new List<OracleCloudToSFService.InvoiceList>();
        Savepoint sp;
        String caseNbr= null;
        
        try {
            if(DisputeUtil.getDspROR() != 'SF') throw new DisputeSyncException(Label.MyNCR_DspSrvUnavl);
            
            // Validate Missing field by MYNCR request
            Boolean isValidDispute = String.isBlank(dspUtil.vaidateDisputeDetailERPCloud(inputDispute));         
            
            for(InvoiceDetail inv : inputDispute.InvoiceList.Invoicedetail){
                invoiceNoLst.add(inv.Invoice_Id.trim());
                noOpenDspInvLst.add(inv.Invoice_Id.trim());
            }
            
            if (isValidDispute) {               
                //Check if we have any open Dispute against invoices
                Map<String, InvRsp> openDspInvMap = dspUtil.getOpenDspInvs(invoiceNoLst, inputDispute.MasterCustomerNumber);
                if(!openDspInvMap.isEmpty()) {
                    integer count = 0;
                    for(String invNbr : invoiceNoLst) {
                        if(openDspInvMap.containsKey(invNbr)) {
                            noOpenDspInvLst.remove(count); count--;
                        } count++;  
                    }                   
                    resp.InvListResp.Invoice =  openDspInvMap.values();
                }
                
                if (!noOpenDspInvLst.isEmpty()) {
                    String errMsg = ERPDisputeUtil.getInvoiceDetailFromERP_Oracle(noOpenDspInvLst, inputDispute.CountryCode, inputDispute.MasterCustomerNumber, resp, scssInvLst); 
                    
                    if(String.isBlank(errMsg)) {
                        Boolean isNewCase = false;
                        Case dspCase; 
                        sp = Database.setSavepoint();
                        
                        String dsRtypeId = dspUtil.getDisputeCaseRecordTypeId(CASE_DISPUTE_RECORDTYPE);
                        if (String.isBlank(dsRtypeId)) {
                            throw new DisputeSyncException('Dispute Record Type not found in Salesforce.');
                        } 
                        
                        if(String.isNotBlank(inputDispute.Dispute_Id) && inputDispute.Dispute_Id != '0') { //Check existing Dispute Case
                            dspCase = dspUtil.getCaseDetail(inputDispute.Dispute_Id, dsRtypeId); 
                        }
                        Account dspAcc; 
                        // Existing Case not found or change in MCN
                        if(dspCase == NULL || dspCase.Master_Customer_Nbr__c != inputDispute.MasterCustomerNumber || dspCase.AccountId == NULL) {
                            dspAcc = dspUtil.getAccountDetail(inputDispute.MasterCustomerNumber); 
                            
                            if (dspAcc == NULL) {
                                throw new DisputeSyncException('Account matching with Dispute Request\'s Master Customer Number not found in Salesforce');
                            }
                        } 
                        // Create new case if not found             
                        if(dspCase == NULL) { 
                            isNewCase = true;
                            dspCase = new Case(RecordTypeId = dsRtypeId); 
                        } else {
                            caseNbr =  dspCase.CaseNumber;   
                        }
                        
                        // populate Account detail
                        if(dspAcc != NULL) {
                            dspCase.AccountId = dspAcc.Id;
                            dspCase.Master_Customer_Nbr__c = inputDispute.MasterCustomerNumber;
                        } 
                        
                        // populate Case Contacts
                        handleCaseContacts(inputDispute.CustomerContact, inputDispute.AlternateContact, dspCase.AccountId, dspUtil, dspCase);
                        
                        // populate Case related users
                        handleCaseRelatedUsers(inputDispute, dspCase,  dspUtil);
                        
                        // update case other details   
                        // dspCase.CCAD_Dispute_Nbr__c = inputDispute.CCADDisputeNbr; 
                        // dspCase.Dispute_Id = inputDispute.Dispute_Id;
                        dspCase.ERP_Dispute_Nbr__c = inputDispute.ERPDisputeNbr;
                        dspCase.Dispute_Reason__c = inputDispute.ReasonCode;
                        //dspCase.Dispute_Analyst_Name__c = inputDispute.DisputeAnalyst_QLId;
                        dspCase.Dispute_Close_Reason__c = inputDispute.DisputeCloseReasonCode;                    
                        //   dspCase.Hospitality_Reporting_Code__c = (inputDispute.HospitalityReportingCode != NULL && inputDispute.HospitalityReportingCode != '0') ? inputDispute.HospitalityReportingCode : '';
                        dspCase.Root_Cause__c  = (inputDispute.RootCauseCode != NULL && inputDispute.RootCauseCode != '0') ? inputDispute.RootCauseCode : '';
                        dspCase.Resolution_Notes__c = inputDispute.ResolutionNotes;
                        dspCase.Dispute_Details__c = inputDispute.Description;
                        // dspCase.IsEscalated = inputDispute.Escalated!= NULL ? inputDispute.Escalated : FALSE;
                        dspCase.Status = dspUtil.getCaseStatus(inputDispute.Status);
                        dspCase.Disputed_Amount__c = inputDispute.DisputedAmount;
                        dspCase.CurrencyIsoCode = inputDispute.CurrencyCode;
                        dspCase.Currency_Code__c = inputDispute.CurrencyCode;                
                        dspCase.Total_Credit_Amount__c = inputDispute.CreditAmount;
                        dspCase.Rebill_Amount__c = inputDispute.RebillAmount;
                        dspCase.Dispute_Source__c = inputDispute.DisputeSource.Name();
                        dspCase.Country_Code__c = inputDispute.CountryCode;
                        if(inputDispute.Status=='15'){
                            dspCase.Ordering_System__c = inputDispute.OrderingSystem; dspCase.Issue_Department__c = inputDispute.IssueDepartment;
                            dspCase.Issue_Person__c = inputDispute.IssuePerson;                    
                        }
                        
                        upsert dspCase;  
                        
                        if (dspCase.id != NULL) {
                            SaveAttachments(inputDispute.AttachmentList, dspCase.Id, isNewCase, dspUtil);
                            insertCaseComment(inputDispute.CaseComments, inputDispute.isPublicComment, dspCase.id);
                            List<String> dspInvs = insertInvoices(scssInvLst, dspCase.id, dspCase.Country_Code__c, isNewCase);                                  
                            resp.Dispute_ID = isNewCase? dspUtil.getCaseDetailById(dspCase.id).CaseNumber : dspCase.CaseNumber;
                            resp.Invoices_Count=dspInvs.size();
                            resp.InvListResp.Invoice.addAll(genInvResp(dspInvs, inputDispute.MasterCustomerNumber, resp.Dispute_ID, ERPDisputeUtil.DSP_SUCSS));                                   
                            caseNbr = resp.Dispute_ID;
                            
                            /* if(isNewCase) {
try{ 
CaseTriggerHandler caseHndlr = new CaseTriggerHandler(); 
List <Case> c= [Select id, latestCaseCommentId__c, RecordTypeId from Case where id=:dspCase.id];
caseHndlr.Dispute_syncToERPCloud(c, null, true); 
}catch(Exception e){
system.debug('Exception calling ERP Service through RPA');
} 
} */
                        }    
                    } else {
                        resp.result = errMsg;                        
                        resp.InvListResp.Invoice.addAll(genInvResp(noOpenDspInvLst, inputDispute.MasterCustomerNumber, '', ERPDisputeUtil.UNKNOWN_REASON)); 
                    }
                }  
            } else{            
                resp.InvListResp.Invoice = new List<InvRsp>(genInvResp(invoiceNoLst, inputDispute.MasterCustomerNumber, '', ERPDisputeUtil.UNKNOWN_REASON));               
            }
        } catch(Exception e) {
            if(sp != NULL) Database.RollBack(sp);
            resp.result = 'Error :' + e.getMessage(); resp.Dispute_ID = null;
            resp.InvListResp.Invoice = new List<InvRsp>(genInvResp(invoiceNoLst, inputDispute.MasterCustomerNumber, '', ERPDisputeUtil.UNKNOWN_REASON)); 
            System.debug('@@@@E'+e.getMessage());
        } finally {
            if(String.isNotBlank(resp.Dispute_ID)) {
                resp.result = STATUS_SUCCESS;     
            } else {
                resp.Dispute_ID =null;
                resp.Invoices_Count =0; 
                if(String.isBlank(resp.result)) resp.result = STATUS_FAILURE;  
            }            
            CCADDLogsUtility.insertDisputeLogs(inputDispute.TransactionId,  JSON.serialize(inputDispute),  JSON.serialize(resp), resp.result, caseNbr, caseNbr,'CreateDispute_MyNCR-SF');
        }
        return resp;    
    }  
    
    static List<InvRsp> genInvResp(List<String> invL, String MCN, String dspId, String dspCode) {
        List<InvRsp> invRspL = new List<InvRsp>();        
        if(invL != null && invL.size() > 0) {
            for (String inv : invL) {
                invRspL.add(new InvRsp(MCN, inv, dspId, dspCode));  
            }
        }  
        return invRspL;
    }
    
    static void handleCaseContacts(ContactDetail inputCustomerContact, ContactDetail inputAlternateContact, String dspAccId, ERPDisputeUtil dspUtil, Case caseRecord) {
        List<Contact> upsertConList = new List<Contact>(); 
        Set<String> caseContactEmails = new Set<String>();
        Map<String,Contact> contEmailMap;
        Contact customerContact, alternateContact;
        
        if (inputCustomerContact != NULL && String.isNotBlank(inputCustomerContact.Email)) {
            inputCustomerContact.Email = inputCustomerContact.Email.trim();
            caseContactEmails.add(inputCustomerContact.Email);       
        }
        
        if (inputAlternateContact != NULL && String.isNotBlank(inputAlternateContact.Email)) {
            inputAlternateContact.Email = inputAlternateContact.Email.trim();
            caseContactEmails.add(inputAlternateContact.Email); 
        }
        
        if(!caseContactEmails.isEmpty()) {
            contEmailMap = dspUtil.getContactsDetail(caseContactEmails);          
        }
        
        if (inputCustomerContact != NULL && String.isNotBlank(inputCustomerContact.Email)) {
            customerContact = contEmailMap.get(inputCustomerContact.Email.toUpperCase());
            
            if (customerContact == NULL) {
                customerContact = dspUtil.createContact(inputCustomerContact, dspAccId, false);
                upsertConList.add(customerContact);
                
            } else if (String.isNotBlank(inputCustomerContact.Phone) && customerContact.Phone != inputCustomerContact.Phone) {
                customerContact.Phone = inputCustomerContact.Phone;  
                system.debug('Insert Contact from CCAD: '+customerContact);
                upsertConList.add(customerContact);             
            }   
        }
        
        if (inputAlternateContact != NULL  && String.isNotBlank(inputAlternateContact.Email)) {
            alternateContact = contEmailMap.get(inputAlternateContact.Email.toUpperCase());
            
            if (alternateContact == NULL) {
                alternateContact = dspUtil.createContact(inputAlternateContact, dspAccId, true);
                
                if (customerContact != NULL && alternateContact.Email.toUpperCase() != customerContact.Email.toUpperCase()) {
                    upsertConList.add(alternateContact);                   
                } else {
                    alternateContact =  customerContact;
                    
                }
            } else if (String.isNotBlank(inputAlternateContact.Phone) && alternateContact.Phone != inputAlternateContact.Phone) {
                alternateContact.Phone = inputAlternateContact.Phone;  
                
                if (customerContact != NULL &&  alternateContact.Email.toUpperCase() != customerContact.Email.toUpperCase()) {
                    upsertConList.add(alternateContact);     
                } else {
                    alternateContact =  customerContact;
                }
            }  
        }
        
        if (!upsertConList.isEmpty()) upsert upsertConList;
        
        if(customerContact != null) caseRecord.ContactId = customerContact.Id;
        if(alternateContact != null) caseRecord.Alternate_Contact__c = alternateContact.Id;  
    }
    
    
    
    static void handleCaseRelatedUsers(DisputeDetail inputDispute, Case caseRecord, ERPDisputeUtil dspUtil) {
        // process user lookups
        Set<String> reletedUserQLIds = new Set<String>();
        Set<String> dspAnalyst_PklstVals = new Set<String>();
        
        
        if (String.isNotBlank(inputDispute.DisputeAnalyst_QLId)) {
            
            for(Schema.PicklistEntry ple : Case.Dispute_Analyst_Name__c.getDescribe().getPicklistValues()) {
                if(ple.isActive()) {
                    dspAnalyst_PklstVals.add(ple.getValue().toUpperCase());
                }
            }
            caseRecord.Dispute_Analyst_Name__c = dspAnalyst_PklstVals.contains(inputDispute.DisputeAnalyst_QLId.toUpperCase()) ? inputDispute.DisputeAnalyst_QLId :'Assigned to Queue';                                                                     
        } else {
            caseRecord.Dispute_Analyst_Name__c = 'Assigned to Queue';  
        }        
        System.debug(caseRecord.Dispute_Analyst_Name__c);
        
        Set<String> OwneQLIds = new Set<String>{'NSCADMIN'};
            
        if(!caseRecord.Dispute_Analyst_Name__c.contains('Queue')) OwneQLIds.add(inputDispute.DisputeAnalyst_QLId.toUpperCase());
        Map<String, User> matchedUsers = dspUtil.getUsersDetail(OwneQLIds);
        
        if(!caseRecord.Dispute_Analyst_Name__c.contains('Queue') && !matchedUsers.isEmpty() && matchedUsers.containsKey(inputDispute.DisputeAnalyst_QLId.toUpperCase())) {
            User dispAnalystUser = matchedUsers.get(inputDispute.DisputeAnalyst_QLId.toUpperCase());
            System.debug('aaa' + dispAnalystUser);
            caseRecord.Dispute_Analyst_Email__c = dispAnalystUser.Email;
            caseRecord.Dispute_Analyst_Phone__c = dispAnalystUser.Phone; 
            
            if (caseRecord.OwnerId != dispAnalystUser.Id) {
                caseRecord.OwnerId = dispAnalystUser.Id;    
            }    
        } else {
            caseRecord.Dispute_Analyst_Email__c = NULL;
            caseRecord.Dispute_Analyst_Phone__c = NULL;
            
            if (caseRecord.OwnerId == NULL) {
                caseRecord.OwnerId =  matchedUsers.get('NSCADMIN').Id;
            }
        }   
        
        caseRecord.Dispute_CreatedBy_Qlook__c = inputDispute.CreateByUser_QLId;
        caseRecord.Dispute_UpdatedBy_Qlook__c =  inputDispute.UpdatedByUser_QLId; 
        
        if (inputDispute.CreateByUser_QLId != NULL) {
            reletedUserQLIds.add(inputDispute.CreateByUser_QLId);            
        } else {
            caseRecord.Dispute_Created_By_Name__c = NULL;    
        }
        
        if (inputDispute.UpdatedByUser_QLId != NULL) {
            reletedUserQLIds.add(inputDispute.UpdatedByUser_QLId); 
        } else {
            caseRecord.Dispute_Updated_By_Name__c = NULL;       
        }
        
        if (!reletedUserQLIds.isEmpty()) {
            Map<String, String> userDetailMap = dspUtil.getEmpDetail(reletedUserQLIds);
            
            String dispCreatdByUserName = inputDispute.CreateByUser_QLId !=NULL ? userDetailMap.get(inputDispute.CreateByUser_QLId.toUpperCase()) : NULL;
            caseRecord.Dispute_Created_By_Name__c = String.isNotBlank(dispCreatdByUserName) ? dispCreatdByUserName : inputDispute.CreateByUser_QLId;
            
            String dispUpdtdByUserName = inputDispute.UpdatedByUser_QLId != NULL ? userDetailMap.get(inputDispute.UpdatedByUser_QLId.toUpperCase()) : NULL;
            caseRecord.Dispute_Updated_By_Name__c = String.isNotBlank(dispUpdtdByUserName) ? dispUpdtdByUserName : inputDispute.UpdatedByUser_QLId;
        }    
    }
    
    static void SaveAttachments(DisputeAttachment AttachmentList, String caseId, Boolean isNewCase, ERPDisputeUtil dspUtil) {
        List<Other_Attachments__c> newOtherAttchList = new List<Other_Attachments__c>();
        Map<String,Other_Attachments__c> existAttachMap = new Map<String,Other_Attachments__c>();
        Set<String> attachURLs = new Set<String>();
        
        if (isNewCase) {           
            if(AttachmentList != NULL && AttachmentList.Attachment != NULL) {
                for(AttachmentDetail att: AttachmentList.Attachment)  {
                    if(att.Attachment_Source != SourceSystem.NSC) {
                        if(!attachURLs.contains(att.Attachment_FULL_URL)) {
                            attachURLs.add(att.Attachment_FULL_URL);
                            newOtherAttchList.add(new Other_Attachments__c(Case__c = caseId, Attachment_Source__c = att.Attachment_Source.Name(), Attachment_Description__c = att.Attachment_Description, 
                                                                           Attachment_FULL_URL__c = att.Attachment_FULL_URL));
                        }
                        
                    }
                }
            }
        } else {
            existAttachMap = dspUtil.getAllNonSFAttachments(caseId);
            
            if(AttachmentList != NULL && AttachmentList.Attachment != NULL) {
                Set<String> updateURLs = new Set<String>();
                
                for(AttachmentDetail att: AttachmentList.Attachment)  {
                    if(att.Attachment_Source != SourceSystem.NSC) {
                        if(!attachURLs.contains(att.Attachment_FULL_URL)) {
                            attachURLs.add(att.Attachment_FULL_URL);
                            Other_Attachments__c otherAttach = new Other_Attachments__c(Case__c = caseId, Attachment_Source__c = att.Attachment_Source.Name(), Attachment_Description__c = att.Attachment_Description, 
                                                                                        Attachment_FULL_URL__c = att.Attachment_FULL_URL);
                            
                            if(existAttachMap.containsKey(att.Attachment_FULL_URL)) {
                                otherAttach.Id = existAttachMap.get(att.Attachment_FULL_URL).Id; 
                                newOtherAttchList.add(otherAttach);                                                                                      
                                existAttachMap.remove(att.Attachment_FULL_URL);  
                            } else {
                                newOtherAttchList.add(otherAttach);
                            }
                        }
                    }
                }
            }
        }
        
        if(!newOtherAttchList.isEmpty()) upsert newOtherAttchList;
        if(!existAttachMap.isEmpty()) delete existAttachMap.values();
    }
    
    
    static void insertCaseComment(String strComment, Boolean isPublic, String caseId) {
        if(String.isNotBlank(strComment)) {
            CaseComment comment = new CaseComment(ParentId = caseId, isPublished = isPublic, CommentBody = strComment);
            insert comment;
        }
    }
    
    static List<String> insertInvoices(List<OracleCloudToSFService.InvoiceList> scssInvLst, String caseId, String ctryCode, Boolean isNewCase) {
        List<Dispute_Invoices__c> disputeInvList = new List<Dispute_Invoices__c>();
        List<String> retInvLst = new List<String>();
        Boolean requireInvCallout = false;
        if(scssInvLst != null && scssInvLst.size() > 0  && isNewCase) {
            for(OracleCloudToSFService.InvoiceList inv : scssInvLst) {
                Dispute_Invoices__c disInv = new Dispute_Invoices__c(Dispute__c = caseId);  
                ERPDisputeUtil.populateInvoiceDetail_Oracle(inv, disInv, '');
                disputeInvList.add(disInv);
                retInvLst.add(inv.InvoiceNumber); 
            }   
        }
        
        /*if(InvoiceList != NULL && InvoiceList.Invoicedetail != NULL && isNewCase) {
for(InvoiceDetail inv : InvoiceList.Invoicedetail) {
Dispute_Invoices__c disInv = new Dispute_Invoices__c(Dispute__c = caseId, Invoice_Number__c = inv.Invoice_Id);  
disInv.Total_Invoice_Amount__c = inv.Invoice_Amount;
disputeInvList.add(disInv);
} 
}*/
        try {
             TriggerHandlerBase.bypass('CaseTriggerDispatcher');
             insert disputeInvList;
             TriggerHandlerBase.clearBypass('CaseTriggerDispatcher');
        } catch(Exception e) {
            throw e;
        } 
        return retInvLst;
    }
    
    
    
    global class DisputeDetail {
        webService String TransactionId;
        webService String CustomerName;
        webService String Dispute_Id;
        webService String MasterCustomerNumber;
        webService String CountryCode;
        webService ContactDetail CustomerContact;
        webService ContactDetail AlternateContact; 
        webService String DisputeAnalyst_QLId;         
        // webService String CCADDisputeNbr;
        webService String ERPDisputeNbr;
        // webService String SFCaseNbr; 
        webService String ReasonCode;  
        webService String DisputeCloseReasonCode;     
        //  webService String HospitalityReportingCode;  
        webService String RootCauseCode;   
        webService String ResolutionNotes;
        webService String Description; 
        //webService Boolean Escalated;      
        webService String Status;  
        webService String CreateByUser_QLId; 
        webService String UpdatedByUser_QLId; 
        webService Decimal DisputedAmount; 
        webService String CurrencyCode; 
        webService Decimal CreditAmount; 
        webService Decimal RebillAmount; 
        webService SourceSystem DisputeSource;
        webService String CaseComments;  
        webService Boolean isPublicComment;  
        webService DisputeAttachment AttachmentList;
        webService InvoiceData InvoiceList;
        webService String OrderingSystem; 
        webService String IssueDepartment;
        webservice String IssuePerson;  
    }  
    
    global class ERPDisputeSyncResponse {
        webservice String result;
        webservice String Dispute_ID;
        webservice Integer Invoices_Count;
        
        webservice InvListRsp InvListResp;
        global ERPDisputeSyncResponse(String Dispute_ID, String result, String Master_Customer_Number,List<String> Invoice_Id, String Dispute_code, Integer Invoices_Count) {
            this.Dispute_ID = Dispute_ID;
            this.result = result;
            this.Invoices_Count = Invoices_Count;
        }
    }
    
    global class InvListRsp {
        webservice List<InvRsp> Invoice;    
    }
    
    global class InvRsp {
        webService String Master_Customer_Number;    
        webService String Invoice_id;        
        webService String Dispute_ID;    
        webService String Dispute_code; 
        
        public InvRsp(String MCN, String invId, String dspId, String dspCode) {
            Master_Customer_Number = MCN;
            Invoice_id = invId;
            Dispute_ID = dspId;
            Dispute_code = dspCode;
        } 
    }
    
    global class ContactDetail {
        webService String Name;
        webService String Email;
        webService String Phone;
    }
    
    // wrapper for Dispute Analyst
    global class NCRUserDetail {
        webService String Name;
        webService String Email;
        webService String Phone;
        webService String QuickLook;
    }
    
    global class DisputeAttachment {
        webService List<AttachmentDetail> Attachment;  
    }
    
    global class AttachmentDetail {
        webService String Attachment_FULL_URL; 
        webService String Attachment_Description;
        webService SourceSystem Attachment_Source;
    }
    
    global class InvoiceData {
        webService List<InvoiceDetail> Invoicedetail;        
    }
    
    global class InvoiceDetail {
        webService String Invoice_Id;
        webService Decimal Invoice_Amount;
    }
    global class DisputeSyncException extends Exception {}
    
}