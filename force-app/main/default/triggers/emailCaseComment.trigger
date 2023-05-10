trigger emailCaseComment on CaseComment (After update, After Insert) 
{
    List<Id> caseIDList = new List<Id>();
    //List<OrgWideEmailAddress> emailAddress = [SELECT Id, address FROM OrgWideEmailAddress WHERE address = 'partner.resourcecenter@ncr.com'];
    
    if(Trigger.new.size() == 1)
    {
        for(CaseComment cc : Trigger.new)
        {
            caseIDList.add(cc.ParentId); 
        }
        List<NCR_EmailMessage__c> emails = new List<NCR_EmailMessage__c>();
        List<Case> caseList = [Select Id, Subject, Category__c, Origin, CC__r.email, CC__c, CreatedById, recordtypeId, RecordType.Name, ContactEmail, Is_Partner_Assist_Team_Case__c from Case where Id IN:caseIDList];
        //Added by Anupam: Stop email notification for Partner Assist Team "CaseList[0].Is_Partner_Assist_Team_Case__c == false"
        if(!caseList.isEmpty() && caseList[0].recordtypeId != null && caseList[0].RecordType.name.containsIgnoreCase('IPT Partner') 
            && CaseList[0].Origin != 'IPT SSO' && !CaseList[0].Is_Partner_Assist_Team_Case__c)
        {
            List<String> ccAddressList = new    List<String>();
            
            List<Get_help_Configuration__mdt> getHelpConfiguration = [Select id, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c 
                                                                            from Get_help_Configuration__mdt 
                                                                            Where MasterLabel =: CaseList[0].Category__c] ;
            if(getHelpConfiguration != null )
            {
                List<String> sendTo = String.isNotBlank(getHelpConfiguration[0].Email_Send_List__c) ? getHelpConfiguration[0].Email_Send_List__c.split(',') : new List<String>();
                NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IPT Case Comment'); 
                if(!sendTo.isEmpty()){
                    ncrEmail.Recipient1__c = sendTo.get(0);
                    if(sendTo.size()>1){
                        ncrEmail.Recipient2__c  = sendTo.get(1);
                    }
                }
                //Get Case Contact Email 
                if(String.isNotBlank(caseList[0].contactEmail)){
                    ncrEmail.Recipient3__c  = caseList[0].contactEmail;
                   // sendTo.add(caseList[0].contactEmail);
                }
                
                List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User where Id =: caseList[0].CreatedById LIMIT 1];
                
                //Get the Partner User Account Owner Email
                if(users.size() > 0) 
                {
                    List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: users[0].AccountId LIMIT 1];
                    if(accounts.size() > 0) {
                        ncrEmail.Recipient4__c  = accounts[0].Owner.Email;
                        //sendTo.add(accounts[0].Owner.Email);
                    }
                }
                
                //Collect Case CC Email.
                if(caseList[0].cc__c != null)
                {
                    ncrEmail.Recipient5__c  = caseList[0].cc__r.email;
                   // ccAddressList.add(caseList[0].cc__r.email);
                }
                
                
                String templateName;
                
                if(caseList[0].Category__c == 'Partner Opportunity')
                {
                    templateName = 'Get Help PO Update';
                }
                else if(caseList[0].Category__c == 'EULA Submission') 
                {
                    templateName = 'Get Help EULA Update';
                }
                else
                {
                    templateName = 'Get Help Update Notification VF';
                }
                EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name =: templateName];  
                //Contact c = [select id, Email from Contact where email Like '%.com%' limit 1];
                Messaging.SingleEmailMessage rslt = Messaging.renderStoredEmailTemplate(et.Id,null, caseList[0].id); 
                //System.debug('rslt'+rslt);
                String htmlBody = rslt.getHtmlBody(); 
                System.debug('htmlBody'+htmlBody);
                ncrEmail.Subject__c = rslt.getSubject();
                ncrEmail.HTML_Body__c = htmlBody;
                emails.add(ncrEmail);
                //Locate the contact for creating mail           
                /*Contact c = [select id, Email from Contact where email Like '%.com%' limit 1];
                List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setTemplateId( [select id from EmailTemplate where Name =: templateName].id );
                msg.setWhatId(caseList[0].id);
                msg.setTargetObjectId(c.id);
                msg.setToAddresses(new List<String>{'partner.resourcecenter@ncr.com'});
                if(emailAddress.size() > 0) 
                {
                    msg.setOrgWideEmailAddressId(emailAddress[0].Id);
                }
                System.debug('----'+ ccAddressList);
                msg.setCCAddresses(ccAddressList);
                lstMsgs.add(msg);
                
                // Send the emails in a transaction, then roll it back
                Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(lstMsgs);
                Database.rollback(sp);
                
                // for each SingleEmailMessage that was just populated by the sendEmail() method, copy its
                // contents to a new SingleEmailMessage. Then send those new messages.
                List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                
                for(Messaging.SingleEmailMessage email : lstMsgs) 
                {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(sendTo);
                    emailToSend.setPlainTextBody(email.getPlainTextBody());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSubject(email.getSubject());
                    
                    if(emailAddress.size() > 0 && caseList[0].Category__c != 'MDF') 
                    {
                        emailToSend.setOrgWideEmailAddressId(emailAddress[0].Id);
                    }
                    lstMsgsToSend.add(emailToSend);
                }*/
                //Messaging.sendEmail(lstMsgsToSend);
            }
        }   
        if(!emails.isEmpty()){
            insert emails;
        }
    }
    
    
    //Case Comment Dispute Case Code
    
    if(Trigger.isAfter ){

        if(Trigger.isUpdate  || Trigger.IsInsert){
        
           Set<String> ParentCaseIdSet =  new Set<String>();
           Map<String,Case>  CaseRecordTypeMap = new  Map<String,Case>();
           CCAD_Config__mdt ccadCnfg = [SELECT Id, Send_CCAD_emails__c FROM CCAD_Config__mdt WHERE QualifiedApiName = 'Org_Config' LIMIT 1]; 
       
           if(Trigger.NewMap.KeySet().Size()>0 && ccadCnfg.Send_CCAD_emails__c){
           
              
               for(CaseComment CaseCommentObj : Trigger.New){
                   
                   if(Trigger.isUpdate){
                       
                        if((String.isNotBlank(CaseCommentObj.ParentId)) && (CaseCommentObj.IsPublished != Trigger.OldMap.get(CaseCommentObj.id).IsPublished) && (CaseCommentObj.IsPublished)){
                          
                               ParentCaseIdSet.add(CaseCommentObj.ParentId);
                          
                        }
                   }
                   
                   
                   else if(Trigger.IsInsert){
                       
                       if((String.isNotBlank(CaseCommentObj.ParentId)) && (CaseCommentObj.IsPublished)){
                          
                               ParentCaseIdSet.add(CaseCommentObj.ParentId);
                          
                        }
                   }
               }   
               
           }
           
           if(ParentCaseIdSet != null && ParentCaseIdSet.Size()>0) {
              for(Case CaseObj : [Select id,RecordType.Name,Disputed_Amount__c,Dispute_Details__c,Contact.name,Description,Master_Customer_Nbr__c,
                                  toLabel(Dispute_Reason__c),Customer_Contact_Phone1__c,CaseNumber,
                                  CCAD_Dispute_Nbr__c,Customer_Contact_Email1__c, Dispute_Analyst_Email__c,IsClosed,
                                  Account.Name,toLabel(Dispute_Analyst_Name__c),Dispute_Analyst_Phone__c
                                  from Case where Id IN : ParentCaseIdSet and RecordType.Name = 'Dispute']){
                  
                  if (CaseObj.IsClosed == false  && String.isNotBlank(CaseObj.Customer_Contact_Email1__c)  && String.isNotBlank(CaseObj.Dispute_Analyst_Email__c)
                        && String.isNotBlank(CaseObj.Dispute_Analyst_Name__c) && !CaseObj.Dispute_Analyst_Name__c.equalsIgnoreCase('ASSIGNED TO QUEUE'))
                  
                      if(!CaseRecordTypeMap .ContainsKey(CaseObj.id)) {
                      
                        CaseRecordTypeMap .put(CaseObj.id,CaseObj);
                      }
              }
           }
           
            if(CaseRecordTypeMap != null && CaseRecordTypeMap.keySet().size()>0){
                   //List<OrgWideEmailAddress> donotReplyAddress=[select Id,DisplayName from OrgWideEmailAddress WHERE DisplayName='NCR Global Do Not Reply'];
                    List<NCR_EmailMessage__c> emailList = new List<NCR_EmailMessage__c>(); 
                //List<Messaging.SingleEmailMessage> Mails = new List<Messaging.SingleEmailMessage>();
                   EmailTemplate templateIdForDisputeAnalysts = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Dispute Update'];
                   String EmailBodyForCustomers=templateIdForDisputeAnalysts.HtmlValue;
                   for(CaseComment CaseCommentObj : Trigger.New){
                        //List<String> toAddressListTemp = new List<String>();
                        //Set<String> ccAddressListTemp = new Set<String>();
                        
                        if((String.isNotBlank(CaseCommentObj.ParentId)) && (CaseRecordTypeMap.ContainsKey(CaseCommentObj.ParentId)) && (CaseRecordTypeMap.get(CaseCommentObj.ParentId) != null)){
                            NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'NCR Dispute Update', Subject__c = templateIdForDisputeAnalysts.subject, title__c=templateIdForDisputeAnalysts.subject); 
                            if(String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Email1__c)){
                                ncrEmail.Recipient1__c = CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Email1__c;
                                //toAddressListTemp.add(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Email1__c);
                                //toAddressListTemp.add('mk111221@ncr.com');
                                //toAddressListTemp.add('sk250842@ncr.com');
                                //toAddressListTemp.add('gr185126@ncr.com');
                            }
                            
                            if(String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Email__c)){
                                 ncrEmail.Recipient2__c = CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Email__c;
                               // toAddressListTemp.add(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Email__c);
                                 //toAddressListTemp.add('mk111221@ncr.com');
                                 //toAddressListTemp.add('sk250842@ncr.com');
                                 //toAddressListTemp.add('gr185126@ncr.com');
                            }
                            //system.debug('@@@ :'+toAddressListTemp);
                            //if(toAddressListTemp.size()>0){
                              //  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                //mail.setOrgWideEmailAddressId(donotReplyAddress[0].Id);
                                //mail.setToAddresses(toAddressListTemp);
                                //mail.setSubject('NCR Dispute Update');
                               
                                if((CaseRecordTypeMap != null) && CaseRecordTypeMap.containskey(CaseCommentObj.ParentId)){
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#SFCase', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).CaseNumber) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).CaseNumber) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#SFDispute', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).CCAD_Dispute_Nbr__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).CCAD_Dispute_Nbr__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerName', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Account.Name) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Account.Name) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#MCN', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Master_Customer_Nbr__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Master_Customer_Nbr__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactName', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Contact.name) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Contact.name) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactPhone', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Phone1__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Phone1__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CustomerContactEmail', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Email1__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Customer_Contact_Email1__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DIsputedAmount', CaseRecordTypeMap.get(CaseCommentObj.ParentId).Disputed_Amount__c != null ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Disputed_Amount__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeReasonCode', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Reason__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Reason__c) : '');
                                    //EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeDescription', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Invoice_Dispute_Description__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Invoice_Dispute_Description__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeDetails', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Details__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Details__c) : '');
                                    
                                    String caseComment = '';  
                                    
                                    Matcher matcher = new ERPDisputeUtil().matchPattern(CaseCommentObj.CommentBody);                    
                                    if(matcher.find()) {
                                        String cmntCrtdByStr = matcher.group(1); 
                                        String cmntSubmitter = matcher.group(2);
                                        
                                        if(String.isNotBlank(cmntCrtdByStr)) {
                                            Integer startIdx = CaseCommentObj.CommentBody.indexOf(cmntCrtdByStr);     
                                            caseComment = CaseCommentObj.CommentBody.subString(startIdx + cmntCrtdByStr.length());    
                                        } 
                                    } 
                                    caseComment =   String.isNotBlank(caseComment) ? caseComment : CaseCommentObj.CommentBody;
								    EmailBodyForCustomers = EmailBodyForCustomers.replace('#DisputeComments', caseComment);

                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorName', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Name__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Name__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorEmail', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Email__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Email__c) : '');
                                    EmailBodyForCustomers = EmailBodyForCustomers.replace('#CollectorPhone', String.isNotBlank(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Phone__c) ? String.ValueOf(CaseRecordTypeMap.get(CaseCommentObj.ParentId).Dispute_Analyst_Phone__c) : '');
                                    //mail.setHtmlBody(EmailBodyForCustomers); 
                                    ncrEmail.HTML_Body__c = EmailBodyForCustomers;
                                    emailList.add(ncrEmail); 
                                }
                                
                               
                            
                        
                   }
                   }
                 //  system.debug('@@@ :'+Mails);
                if(emailList.size()>0){
                    if(!Test.isRunningTest()){
                        insert emailList;
                    }
                }
                   
            }
           
        }  
        
    }
    
    //Update latest Case Comment on Parent Case
    if(Trigger.isAfter && Trigger.isInsert){
        List<Case> caselist= new List<Case>();
        for(CaseComment CaseCommentObj : Trigger.New){
            // && (CaseCommentObj.Parent.RecordTypeId=='0121b0000000XK2AAM')
            if((String.isNotBlank(CaseCommentObj.ParentId))){
                Case updateCommentIdOnCase = new Case();
                updateCommentIdOnCase.id=CaseCommentObj.ParentId ;
                updateCommentIdOnCase.latestCaseCommentId__c= CaseCommentObj.id;
                caselist.add(updateCommentIdOnCase);
            }
        }
        if(caselist !=null && caselist.size() >0)
         update caselist;   
        
        
    }
}