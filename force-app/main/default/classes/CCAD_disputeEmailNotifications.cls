public class CCAD_disputeEmailNotifications {
    
    
    public static  void DisputeCreate_Notifications(List<Case> caseList) {
        Map<Id, Case> caseMap = new Map<Id,case>(); 
        Set<String> disputeAnalystEmails = new Set<String>();
        Map<String, Id> userEmailMap = new Map<String, Id>();
        
         if(caseList != null){
              for(Case CaseObj : [Select id,RecordType.Name,CCAD_Dispute_Nbr__c,Account.Name,Contact.name,CreatedBy.name,toLabel(Dispute_Reason__c),
                                  toLabel(Dispute_Analyst_Name__c),Dispute_Created_By_Name__c,Customer_Contact_Email1__c,
                                  IsClosed, Dispute_Analyst_Email__c,Dispute_Analyst_Phone__c
                                  from Case where Id IN : caseList and RecordType.Name = 'Dispute']){
              if (CaseObj.IsClosed == false  && String.isNotBlank(CaseObj.Customer_Contact_Email1__c)  && String.isNotBlank(CaseObj.Dispute_Analyst_Email__c)
                        && String.isNotBlank(CaseObj.Dispute_Analyst_Name__c) && !CaseObj.Dispute_Analyst_Name__c.equalsIgnoreCase('ASSIGNED TO QUEUE'))
                  
                  if(!caseMap.ContainsKey(CaseObj.id)) {
                      caseMap.put(CaseObj.id,CaseObj);
                      disputeAnalystEmails.add(CaseObj.Dispute_Analyst_Email__c);
                  }
              }
             
             if(!disputeAnalystEmails.isEmpty()) {
                 List<User> userList = [SELECT Id, email FROM USER WHERE email IN :disputeAnalystEmails];
                 
                 for (User u : userList) {
                    userEmailMap.put(u.email, u.Id);     
                 }
             }
           }
        
        
        if(caseList != null){
                   List<OrgWideEmailAddress> donotReplyAddress=[select Id,DisplayName from OrgWideEmailAddress WHERE DisplayName='NCR Global Do Not Reply'];
            
                   List<Messaging.SingleEmailMessage> Mails = new List<Messaging.SingleEmailMessage>();
                   EmailTemplate templateIdForDisputeAnalysts = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'DisputeCreationNotification'];
                   String EmailBodyForCustomers=templateIdForDisputeAnalysts.HtmlValue;
                   for(Case CaseObj :  caseList){
                       if(caseMap.containsKey(CaseObj.id)){
                        List<String> toAddressListTemp = new List<String>();
                        Set<String> ccAddressListTemp = new Set<String>();
                           String targetObjectUserId = null;
                            
                            if(String.isNotBlank(caseMap.get(CaseObj.id).Customer_Contact_Email1__c)){ 
                                toAddressListTemp.add(CaseObj.Customer_Contact_Email1__c);
                                //toAddressListTemp.add('mk111221@ncr.com');
                                //toAddressListTemp.add('sk250842@ncr.com');
                                //toAddressListTemp.add('gr185126@ncr.com');
                            }
                             
                            if(String.isNotBlank(CaseObj.Dispute_Analyst_Email__c)) {
                                targetObjectUserId  = userEmailMap.get(CaseObj.Dispute_Analyst_Email__c);
                                 /*toAddressListTemp.add(CaseObj.Dispute_Analyst_Email__c);
                                 toAddressListTemp.add('mk111221@ncr.com');
                                 toAddressListTemp.add('sk250842@ncr.com');
                                 toAddressListTemp.add('gr185126@ncr.com');*/
                            }
                            
                            system.debug('@@@ :'+toAddressListTemp);
                            if((toAddressListTemp.size()>0 && String.isNotBlank(targetObjectUserId )) || Test.isRunningTest()){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setTargetObjectId(targetObjectUserId);
                                mail.setToAddresses(toAddressListTemp);
                                mail.setOrgWideEmailAddressId(donotReplyAddress[0].Id);  
                                mail.setSubject('NCR Initial Dispute');
                                mail.setSaveAsActivity(false);  
                                
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CreatedBy', String.isNotBlank(caseMap.get(CaseObj.id).Dispute_Created_By_Name__c) ? String.ValueOf(caseMap.get(CaseObj.id).Dispute_Created_By_Name__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#SFCase', String.isNotBlank(CaseObj.CaseNumber) ? String.ValueOf(CaseObj.CaseNumber) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#SFDispute', String.isNotBlank(caseMap.get(CaseObj.id).CCAD_Dispute_Nbr__c) ? String.ValueOf(caseMap.get(CaseObj.id).CCAD_Dispute_Nbr__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerName', String.isNotBlank(caseMap.get(CaseObj.id).Account.Name) ? String.ValueOf(caseMap.get(CaseObj.id).Account.Name) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#MCN', String.isNotBlank(CaseObj.Master_Customer_Nbr__c) ? String.ValueOf(CaseObj.Master_Customer_Nbr__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactName', String.isNotBlank(caseMap.get(CaseObj.id).Contact.name) ? String.ValueOf(caseMap.get(CaseObj.id).Contact.name) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactPhone', String.isNotBlank(CaseObj.Customer_Contact_Phone1__c) ? String.ValueOf(CaseObj.Customer_Contact_Phone1__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactEmail', String.isNotBlank(CaseObj.Customer_Contact_Email1__c) ? String.ValueOf(CaseObj.Customer_Contact_Email1__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DIsputedAmount', CaseObj.Disputed_Amount__c != null ? String.ValueOf(CaseObj.Disputed_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeReasonCode', String.isNotBlank(CaseObj.Dispute_Reason__c) ? String.ValueOf(caseMap.get(CaseObj.id).Dispute_Reason__c) : '');
                                    //EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeDescription', String.isNotBlank(CaseObj.Invoice_Dispute_Description__c) ? String.ValueOf(CaseObj.Invoice_Dispute_Description__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeDetails', String.isNotBlank(CaseObj.Dispute_Details__c) ? String.ValueOf(CaseObj.Dispute_Details__c) : '');
                                    //EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeComments', String.isNotBlank(CaseCommentObj.CommentBody) ? String.ValueOf(CaseCommentObj.CommentBody) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorName', String.isNotBlank(CaseObj.Dispute_Analyst_Name__c) ? String.ValueOf(caseMap.get(CaseObj.id).Dispute_Analyst_Name__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorEmail', String.isNotBlank(CaseObj.Dispute_Analyst_Email__c) ? String.ValueOf(CaseObj.Dispute_Analyst_Email__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorPhone', String.isNotBlank(CaseObj.Dispute_Analyst_Phone__c) ? String.ValueOf(CaseObj.Dispute_Analyst_Phone__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#LineAmount', CaseObj.Line_Amount__c !=null ? String.ValueOf(CaseObj.Line_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#FreightAmount', CaseObj.Freight_Amount__c !=null ? String.ValueOf(CaseObj.Freight_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#TaxAmount', CaseObj.Tax_Amount__c !=null ? String.ValueOf(CaseObj.Tax_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#TotatInvoiceBalance', CaseObj.Total_Invoice_Balance__c !=null ? String.ValueOf(CaseObj.Total_Invoice_Balance__c.setScale(2)) : '');                                                    
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CurrencyCode', CaseObj.Currency_Code__c !=null ? String.ValueOf(CaseObj.Currency_Code__c) : '');                                                    
                                    mail.setHtmlBody(EmailBodyForCustomers); 
                                    Mails.add(mail); 
                                
                            }
                   }
                   
                   system.debug('@@@ :'+Mails);
                   if(Mails.size()>0){
                        if(!Test.isRunningTest()){
                       Messaging.sendEmail(Mails); 
                        }
                   }
                   }   
            }
        
    }
    
    //Email Notifications Case(Dispute) Closure 
    
    public static  void DisputeClosure_Notifications(List<Case> caseList, Map<Id, case> caseOldMap){
        CCAD_Config__mdt ccadCnfg = [SELECT Id,Send_CCAD_emails__c FROM CCAD_Config__mdt WHERE QualifiedApiName = 'Org_Config' LIMIT 1];
     
        if (!ccadCnfg.Send_CCAD_emails__c) {
            return; 
        }
    
        //add all the cases in Trigger
        Map<Id, Case> caseMap = new Map<Id,case>();
        Set<String> caseIdSet = new Set<String>();
       
    
         List<OrgWideEmailAddress> donotReplyAddress=[select Id,DisplayName from OrgWideEmailAddress WHERE DisplayName='NCR Global Do Not Reply'];
        for(case caseObj : caseList){
          if(caseObj.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId()
            && caseObj.IsClosed ==true && caseObj.Status != caseOldMap.get(caseObj.id).Status     
            && String.isNotBlank(CaseObj.Customer_Contact_Email1__c)  && String.isNotBlank(CaseObj.Dispute_Analyst_Email__c)
            && String.isNotBlank(CaseObj.Dispute_Analyst_Name__c) && !CaseObj.Dispute_Analyst_Name__c.equalsIgnoreCase('ASSIGNED TO QUEUE'))
              
            caseIdSet.add(caseObj.Id); 
        }
        
        if(caseIdSet != null && caseIdSet.Size()>0){
              for(Case CaseObj : [Select id,RecordType.Name,Disputed_Amount__c,Dispute_Details__c,Contact.name,Description,Master_Customer_Nbr__c ,
                                  toLabel(Dispute_Reason__c),Customer_Contact_Phone1__c,CaseNumber,
                                  CCAD_Dispute_Nbr__c,Customer_Contact_Email1__c,Dispute_Analyst_Email__c,Account.Name,toLabel(Dispute_Analyst_Name__c),Dispute_Analyst_Phone__c,CreatedBy.name,
                                  Dispute_Created_By_Name__c,Rebill_Amount__c,Total_Credit_Amount__c,toLabel(Dispute_Close_Reason__c),toLabel(Root_Cause__c),Resolution_Notes__c
                                  from Case where Id IN : caseIdSet and RecordType.Name = 'Dispute']){
                                      
                  if(!caseMap.ContainsKey(CaseObj.id)){
                      caseMap.put(CaseObj.id,CaseObj);
                  }
              }
           }
        
       //Fire EMails to Disputes
       
        if(caseMap != null && caseMap.keySet().size()>0){
                   List<Messaging.SingleEmailMessage> Mails = new List<Messaging.SingleEmailMessage>();
                   EmailTemplate templateIdForDisputeAnalysts = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'DisputeClosureNotification'];
                   String EmailBodyForCustomers=templateIdForDisputeAnalysts.HtmlValue;
                   for(Case CaseObj :  caseMap.Values()){
                        List<String> toAddressListTemp = new List<String>();
                        Set<String> ccAddressListTemp = new Set<String>();
                            
                            if(String.isNotBlank(CaseObj.Customer_Contact_Email1__c)){
                                toAddressListTemp.add(caseMap.get(CaseObj.id).Customer_Contact_Email1__c);
                               // toAddressListTemp.add('mk111221@ncr.com');
                               // toAddressListTemp.add('sk250842@ncr.com');
                               // toAddressListTemp.add('gr185126@ncr.com');
                            }
                            
                            if(String.isNotBlank(CaseObj.Dispute_Analyst_Email__c)){
                                 toAddressListTemp.add(caseMap.get(CaseObj.id).Dispute_Analyst_Email__c);
                                 //toAddressListTemp.add('mk111221@ncr.com');
                                 //toAddressListTemp.add('sk250842@ncr.com');
                                 //toAddressListTemp.add('gr185126@ncr.com');
                            }
                            
                            system.debug('@@@ :'+toAddressListTemp);
                            if(toAddressListTemp.size()>0){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setToAddresses(toAddressListTemp);
                                mail.setOrgWideEmailAddressId(donotReplyAddress[0].Id);
                                mail.setSubject('NCR Dispute Resolved');
                               
                                if((caseMap != null) && caseMap.containskey(CaseObj.Id)){
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CreatedBy', String.isNotBlank(CaseObj.Dispute_Created_By_Name__c) ? String.ValueOf(CaseObj.Dispute_Created_By_Name__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#SFCase', String.isNotBlank(CaseObj.CaseNumber) ? String.ValueOf(CaseObj.CaseNumber) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#SFDispute', String.isNotBlank(CaseObj.CCAD_Dispute_Nbr__c) ? String.ValueOf(CaseObj.CCAD_Dispute_Nbr__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerName', String.isNotBlank(CaseObj.Account.Name) ? String.ValueOf(CaseObj.Account.Name) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#MCN', String.isNotBlank(CaseObj.Master_Customer_Nbr__c) ? String.ValueOf(CaseObj.Master_Customer_Nbr__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactName', String.isNotBlank(CaseObj.Contact.name) ? String.ValueOf(CaseObj.Contact.name) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactPhone', String.isNotBlank(CaseObj.Customer_Contact_Phone1__c) ? String.ValueOf(CaseObj.Customer_Contact_Phone1__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactEmail', String.isNotBlank(CaseObj.Customer_Contact_Email1__c) ? String.ValueOf(CaseObj.Customer_Contact_Email1__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DIsputedAmount', CaseObj.Disputed_Amount__c != null ? String.ValueOf(CaseObj.Disputed_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeReasonCode', String.isNotBlank(CaseObj.Dispute_Reason__c) ? String.ValueOf(CaseObj.Dispute_Reason__c) : '');
                                    //EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeDescription', String.isNotBlank(CaseObj.Invoice_Dispute_Description__c) ? String.ValueOf(CaseObj.Invoice_Dispute_Description__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeDetails', String.isNotBlank(CaseObj.Dispute_Details__c) ? String.ValueOf(CaseObj.Dispute_Details__c) : '');
                                    //EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeComments', String.isNotBlank(CaseCommentObj.CommentBody) ? String.ValueOf(CaseCommentObj.CommentBody) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorName', String.isNotBlank(CaseObj.Dispute_Analyst_Name__c) ? String.ValueOf(CaseObj.Dispute_Analyst_Name__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorEmail', String.isNotBlank(CaseObj.Dispute_Analyst_Email__c) ? String.ValueOf(CaseObj.Dispute_Analyst_Email__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorPhone', String.isNotBlank(CaseObj.Dispute_Analyst_Phone__c) ? String.ValueOf(CaseObj.Dispute_Analyst_Phone__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CreditAmount', CaseObj.Total_Credit_Amount__c !=null ? String.ValueOf(CaseObj.Total_Credit_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#RebillAmount', CaseObj.Rebill_Amount__c !=null ? String.ValueOf(CaseObj.Rebill_Amount__c.setScale(2)) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CloseReason', String.isNotBlank(CaseObj.Dispute_Close_Reason__c) ? String.ValueOf(CaseObj.Dispute_Close_Reason__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#RootCause',  String.isNotBlank(CaseObj.Root_Cause__c) ? String.ValueOf(CaseObj.Root_Cause__c) : ''); 
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#Resolution', String.isNotBlank(CaseObj.Resolution_Notes__c) ? String.ValueOf(CaseObj.Resolution_Notes__c) : '');
                                    
                                    mail.setHtmlBody(EmailBodyForCustomers); 
                                    Mails.add(mail); 
                                }
                            }
                   }
                   
                   system.debug('@@@ :'+Mails);
                   if(Mails.size()>0){
                       if(!Test.isRunningTest()){
                           Messaging.sendEmail(Mails); 
                       }
                      
                   }
                   
            }
        
        
        
        
    }

}