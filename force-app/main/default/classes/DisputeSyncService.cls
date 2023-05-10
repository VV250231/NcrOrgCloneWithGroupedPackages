global without sharing class DisputeSyncService {
    
    global final static String STATUS_SUCCESS = 'SUCCESS';
    global final static String STATUS_FAILURE = 'FAILURE';
    global final static String STATUS_WARNING = 'WARNING';
    global final static String CASE_DISPUTE_RECORDTYPE = 'Dispute';
    global Enum SourceSystem{MyNCR, CCAD, NSC}
    
    webservice static DisputeSyncResponse SyncDispute(DisputeDetail inputDispute) {
        System.debug(inputDispute);
        DisputeUtil dspUtil = new DisputeUtil();
        DisputeSyncResponse resp = new DisputeSyncResponse(null,null,null);
        Savepoint sp = Database.setSavepoint();
        String caseNbr= null; 
        
        try {
            if(DisputeUtil.getDspROR() != 'CCAD') throw new DisputeSyncException(Label.CCAD_DspSrvUnavl);
            
            String vldtnError = new DisputeUtil().vaidateDisputeDetail(inputDispute);
            Boolean isValidDispute = String.isBlank(vldtnError);
            Boolean isNewCase = false;

            if (isValidDispute) {
                String disputeRecordTypeId = dspUtil.getDisputeCaseRecordTypeId(CASE_DISPUTE_RECORDTYPE);
                
                if (String.isBlank(disputeRecordTypeId)) {
                    throw new DisputeSyncException('Dispute Record Type not found in Salesforce.');
                } 
                
                Case dspCase = dspUtil.getCaseDetail(inputDispute.SFCaseNbr, inputDispute.CCADDisputeNbr, disputeRecordTypeId); // Check existing Dispute Case
                Account disputeAcc; 
                
                // Existing Case not found or change in MCN
                if(dspCase == NULL || dspCase.Master_Customer_Nbr__c != inputDispute.MasterCustomerNumber || dspCase.AccountId == NULL) {
                    disputeAcc = dspUtil.getAccountDetail(inputDispute.MasterCustomerNumber); 
                    
                    if (disputeAcc == NULL) 
                    {
                        throw new DisputeSyncException('Account matching with Dispute Request\'s Master Customer Number not found in Salesforce');
                    }
                } 
                
                // Create new case if not found             
                if(dspCase == NULL) { 
                    isNewCase = true;
                    dspCase = new Case(); 
                    dspCase.RecordTypeId = disputeRecordTypeId;
                    
                } else {
                    caseNbr =  dspCase.CaseNumber;   
                }
                
                // populate Account detail
                if(disputeAcc != NULL) {
                    dspCase.AccountId = disputeAcc.Id;
                    dspCase.Master_Customer_Nbr__c = inputDispute.MasterCustomerNumber;
                } 
                
                // populate Case Contacts
                handleCaseContacts(inputDispute.CustomerContact, inputDispute.AlternateContact, dspCase.AccountId, dspUtil, dspCase);
                
                // populate Case related users
                handleCaseRelatedUsers(inputDispute, dspCase,  dspUtil);
                
                // update case other details   
                dspCase.CCAD_Dispute_Nbr__c = inputDispute.CCADDisputeNbr; 
                dspCase.ERP_Dispute_Nbr__c = inputDispute.ERPDisputeNbr;
                dspCase.Dispute_Reason__c = inputDispute.ReasonCode;
                //dspCase.Dispute_Analyst_Name__c = inputDispute.DisputeAnalyst_QLId;
                dspCase.Dispute_Close_Reason__c = inputDispute.DisputeCloseReasonCode;                    
                dspCase.Hospitality_Reporting_Code__c = (inputDispute.HospitalityReportingCode != NULL && inputDispute.HospitalityReportingCode != '0') ? inputDispute.HospitalityReportingCode : '';
                dspCase.Root_Cause__c  = (inputDispute.RootCauseCode != NULL && inputDispute.RootCauseCode != '0') ? inputDispute.RootCauseCode : '';
                dspCase.Resolution_Notes__c = inputDispute.ResolutionNotes;
                dspCase.Dispute_Details__c = inputDispute.Description;
                dspCase.IsEscalated = inputDispute.Escalated!= NULL ? inputDispute.Escalated : FALSE;
                dspCase.Status = dspUtil.getCaseStatus(inputDispute.Status);
                dspCase.Disputed_Amount__c = inputDispute.DisputedAmount;
                dspCase.CurrencyIsoCode = inputDispute.CurrencyCode;
                dspCase.Currency_Code__c = inputDispute.CurrencyCode;                
                dspCase.Total_Credit_Amount__c = inputDispute.CreditAmount;
                dspCase.Rebill_Amount__c = inputDispute.RebillAmount;
                dspCase.Dispute_Source__c = inputDispute.DisputeSource.Name();
                dspCase.Country_Code__c = inputDispute.CountryCode;
                if(inputDispute.Status=='15'){
          dspCase.Ordering_System__c = inputDispute.OrderingSystem;
                dspCase.Issue_Department__c = inputDispute.IssueDepartment;
                dspCase.Issue_Person__c = inputDispute.IssuePerson;                    
                }

                upsert dspCase;  
                
                if (dspCase.id != NULL) {
                    SaveAttachments(inputDispute.AttachmentList, dspCase.Id, isNewCase, dspUtil);
                    insertCaseComment(inputDispute.CaseComments, inputDispute.isPublicComment, dspCase.id);
                    insertInvoices(inputDispute.InvoiceList, dspCase.id, dspCase.Country_Code__c, isNewCase);
                    
                    resp.status = DisputeSyncService.STATUS_SUCCESS;
                    resp.SFCaseNbr = isNewCase? dspUtil.getCaseDetailById(dspCase.id).CaseNumber : dspCase.CaseNumber;  
                    caseNbr = resp.SFCaseNbr;
                }
                
            } else {
                resp.status = DisputeSyncService.STATUS_FAILURE;
                resp.message = vldtnError;
            }
            
        } catch(Exception e) {
            if(sp != NULL) Database.RollBack(sp);
            resp.status = DisputeSyncService.STATUS_FAILURE;
            resp.message = e.getMessage();    
        } finally {
          
            CCADDLogsUtility.insertCCADDLogs(String.valueOf(inputDispute), String.valueOf(resp), resp.status, caseNbr ,inputDispute.CCADDisputeNbr, 'MyNCR/CCAD-SF');    
        }
        return resp;    
    }   
    
    static void handleCaseContacts(ContactDetail inputCustomerContact, ContactDetail inputAlternateContact, String dspAccId, DisputeUtil dspUtil, Case caseRecord) {
        List<Contact> upsertConList = new List<Contact>(); 
        Set<String> caseContactEmails = new Set<String>();
        Map<String,Contact> contEmailMap;
        Contact customerContact;
        Contact alternateContact;
              
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
        
        if (!upsertConList.isEmpty()) {
            upsert upsertConList;
        } 
        
        if(customerContact != null) caseRecord.ContactId = customerContact.Id;
        if(alternateContact != null) caseRecord.Alternate_Contact__c = alternateContact.Id;  
    }
    
    static void handleCaseRelatedUsers(DisputeDetail inputDispute, Case caseRecord, DisputeUtil dspUtil) {
        // process user lookups
        Set<String> reletedUserQLIds = new Set<String>();
        Set<String> disputeAnalyst_PklstVals = new Set<String>();
       
            
        for(Schema.PicklistEntry ple : Case.Dispute_Analyst_Name__c.getDescribe().getPicklistValues()) {
            if(ple.isActive()) {
                disputeAnalyst_PklstVals.add(ple.getValue().toUpperCase());
            }
        }  
        
        if (String.isNotBlank(inputDispute.DisputeAnalyst_QLId) && disputeAnalyst_PklstVals.contains(inputDispute.DisputeAnalyst_QLId.toUpperCase())) {
            caseRecord.Dispute_Analyst_Name__c = inputDispute.DisputeAnalyst_QLId;  
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
    
    static void SaveAttachments(DisputeAttachment AttachmentList, String caseId, Boolean isNewCase, DisputeUtil dspUtil) {
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
    
    static void insertInvoices(InvoiceData InvoiceList, String caseId, String ctryCode, Boolean isNewCase) {
        List<Dispute_Invoices__c> disputeInvList = new List<Dispute_Invoices__c>();
        Boolean requireInvCallout = false;
        
        if(InvoiceList != NULL && InvoiceList.Invoicedetail != NULL && isNewCase) {
            for(InvoiceDetail inv : InvoiceList.Invoicedetail) {
                Dispute_Invoices__c disInv = new Dispute_Invoices__c(Dispute__c = caseId, Invoice_Number__c = inv.Invoice_Id);  
                disInv.Total_Invoice_Amount__c = String.isNotBlank(inv.Invoice_Amount) ? Decimal.valueOf(inv.Invoice_Amount) : 0;
                disputeInvList.add(disInv);
            } 
        }
        try {
            insert disputeInvList;
        } catch(Exception e) {
            throw e;
        } 
        
        if(isNewCase) {
            requireInvCallout  = true;    
        } else {
            if([SELECT Id,Dispute__c, MCN__c, Related_Order__c, PO_Number__c,Invoice_Number__c
                FROM Dispute_Invoices__c WHERE Dispute__c = :caseId and MCN__c = NULL].size() > 0) {
            
                     requireInvCallout = true;
                }
        }
        // check MCN on Dispute Invoice
        if (requireInvCallout) {
            DisputeUtil.getInvoiceDetailInFuture(caseId, ctryCode);
        }
    }
    
    global class DisputeDetail {
        webService String CustomerName;
        webService String MasterCustomerNumber;
        webService String CountryCode;
        webService ContactDetail CustomerContact;
        webService ContactDetail AlternateContact; 
        webService String DisputeAnalyst_QLId;         
        webService String CCADDisputeNbr;
        webService String ERPDisputeNbr;
        webService String SFCaseNbr; 
        webService String ReasonCode;  
        webService String DisputeCloseReasonCode;     
        webService String HospitalityReportingCode;  
        webService String RootCauseCode;   
        webService String ResolutionNotes;
        webService String Description; 
        webService Boolean Escalated;      
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
    
    global class DisputeSyncResponse {
        webservice String SFCaseNbr;
        webservice String status;
        webservice String message;
         
        global DisputeSyncResponse(String SFCaseNbr, String status, String message) {
            this.SFCaseNbr = SFCaseNbr;
            this.status = status;
            this.message = message;    
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
        webService String Invoice_Amount;
    }
    
    global class DisputeSyncException extends Exception {}
    
}