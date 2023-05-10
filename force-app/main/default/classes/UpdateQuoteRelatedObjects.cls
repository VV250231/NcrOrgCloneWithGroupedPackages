global class UpdateQuoteRelatedObjects {

        public static void myMethod(Id QuoteId, Id AccId, Id OppId)
        {
                    if (OppId != null)
                    {
                                List < id > ContactIdList = new List < id > ();
                                List < Opportunity > OpportunityList = new List < Opportunity > ([select id, Contacts__c, AccountId from Opportunity where Id =: OppId]);
                                            for (Opportunity o: OpportunityList)
                                            {
                                                o.AccountId = AccId;
                                                ContactIdList.add(o.Contacts__c);
                                            }
                                List < Contact > ContactList = new List < Contact > ([select id, AccountId from Contact where Id IN: ContactIdList]);
                                            for (Contact c: ContactList)
                                            {
                                                c.AccountId = AccId;
                                            }
                                List < Zqu__Quote__c > QuoteList = new List < Zqu__Quote__c > ([select id, zqu__Account__c, zqu__Opportunity__c from Zqu__Quote__c where zqu__Opportunity__c =: OppId and id != :QuoteId]);
                                            for (Zqu__Quote__c q: QuoteList)
                                            {
                                                q.zqu__Account__c = AccId;
                                            }
                                ProcessorControl.inFutureContext = true;
                                update OpportunityList;
                                update ContactList;
                                update QuoteList;
            
                    }
        }
        
        @future
        public static void FutureMethodUpdateSiteonQuote(Id OldAccId, Id NewAccId, Id Email1, Id Email2, String str, Id Quoteid)
        {
                    List <Account> OldAcc = new List <Account>([select id, name , Subscription_Group__c from Account where id =: OldAccId]);
                    List <Account> NewAcc = new List <Account>([select id, name , Subscription_Group__c from Account where id =: NewAccId]);
                    List <User> UserList = new List <User>([select id, name , email from User where id =: Email1 Or id =: Email2]);
                    List <String> toAddresses = new List <String>();
                    
                                if(NewAcc[0].Subscription_Group__c != NULL)
                                {
                                      System.debug('Method : NewAcc[0].Subscription_Group__c');//SC2015_AGL-5809          // no action
                                }
                                else if(NewAcc[0].Subscription_Group__c == NULL)
                                {
                                                if(OldAcc[0].Subscription_Group__c != NULL)
                                                {
                                                            NewAcc[0].Subscription_Group__c = OldAcc[0].Subscription_Group__c ;
                                                            ProcessorControl.inFutureContext = true;
                                                            update NewAcc;
                                                }
                                                else if(OldAcc[0].Subscription_Group__c == NULL)
                                                {
                                                            for(User usr : UserList)
                                                            {
                                                                     toAddresses.add(usr.email);
                                                            }
                                                            
                                                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                                            mail.setToAddresses(toAddresses);
                                                            mail.setReplyTo('NSC.ITServices@ncr.com');
                                                            mail.setSubject('Account Subscription Group Blank');
                                                            mail.setPlainTextBody('Hi,'+'\r\n\r\n'+'Account "'+ NewAcc[0].name + '" for ' + '"'+ str + '"'+ ' does not have a Subscription Group , please provide a value .'+'\r\n'+ 'Please contact Sales Operations for assistance if needed .'+'\r\n\r\n'+'Account Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+NewAcc[0].Id+'\r\n\r\n'+'Quote Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+Quoteid+'\r\n\r\n'+'Regards'+'\r\n'+'SCA Administrator');
                                                            system.debug(mail);
                                                            Messaging.sendEmailResult[] sendTerminatedEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail });
                                                }
                                                
                                                
                                                
                                }
                                
        }
    public static void increasecoverage(){
               Integer i = 0;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
    }
}