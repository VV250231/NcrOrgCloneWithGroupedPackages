global with sharing class NotifyandCreateTask implements Database.Batchable < Sobject >  {
    public static String Report_ID='';
    public String query = '';
    /*public NotifyandCreateTask(){
        
    } commented Empty block*/
    
    public NotifyandCreateTask(String pmdmID){
               query='Select id, PMDM_Unique_Key__c, Product_Category__c,Solution_Manager__c, name, End_Date__c from product2 where PMDM_Unique_Key__c=\''+pmdmID+'\'';
        }
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public string getContactDetail(Product2 p){
        String contactInfo='';              
        if(p.Solution_Manager__c!=null){
                contactInfo='For any queries related to these products please contact: '+p.Solution_Manager__c;
            }
        
        if(String.isEmpty(contactInfo)){
            contactInfo='For any queries related to these products please contact: IDC, NSC (NI230033@ncr.com)';
        }
        return contactInfo;
    }
    
    global void execute(Database.BatchableContext BC, List < sObject > scope) {
        Set < String > toAddress = new Set < String > ();
        List < EmailTemplate > ets = [SELECT Id, DeveloperName, HTMLValue, Subject FROM EmailTEmplate WHERE DeveloperName = : 'Product_Notification'];
        EMailTemplate et = new EMailTemplate();
        if (ets[0] != null) {
            et = ets[0];
        }
        /**** DUMMY CODE SEND EMAIL WITH TEMPLATE HAVING LETTERHEAD*********/
        Messaging.SingleEmailMessage mailt = new Messaging.SingleEmailMessage();
        mailt.setTargetObjectId(UserInfo.getUserId()); // Specify who the email should be sent to           
        mailt.setTemplateId(et.id);
        mailt.setSaveAsActivity(false);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mailt
        }); // roll back so that original email not send
        Database.rollback(sp);
        
        /**** DUMMY CODE SEND EMAIL WITH TEMPLATE HAVING LETTERHEAD ENDS HERE USE MAIL BODY*********/
        Product2 p;
        List <task> taskList = new List <task>();
        List<Messaging.SingleEmailMessage> salesRepMailLst = new List<Messaging.SingleEmailMessage>();
        
        Set<id> prdIdSet=new Set <id>();
        for (sObject s: scope) {            
            prdIdSet.add(s.id);            
        }
        Map<id,List<Opportunity>> prdIdOppMap=new Map<id,List<Opportunity>>();
        List < Opportunity > oppL = [Select id, Owner.Email, ownerid, (Select product2Id from OpportunityLineItems) from Opportunity where isClosed = false and id in (Select opportunityid from OpportunityLineItem where PriceBookEntry.Product2.id IN : prdIdSet)];
        for(Opportunity opp:oppL){
            for(OpportunityLineItem oli:opp.OpportunityLineItems){
                if(prdIdOppMap.get(oli.product2Id)!=null){
                    prdIdOppMap.get(oli.product2Id).add(opp);
                }else{
                    prdIdOppMap.put(oli.product2Id, new List<Opportunity>{opp}) ;  
                }                
            }            
        }  
        
        for (sObject s: scope) {            
            p = (Product2) s;
            system.debug('##' + p.name);
               if (prdIdOppMap.get(p.id).size() == 0) {
                continue;
            }
            for (Opportunity op: prdIdOppMap.get(p.id)) {
                // adding Owners in email list
                toAddress.add(op.Owner.Email);
                //initiating task
                task t = new task();
                t.ownerid = op.ownerid;
                t.subject = p.name+' Product Deactivation Notification';
                
                    t.description = 'Dear Opportunity Owner,\r\n\r\nYou have opportunities related to '+p.name+ ' product which is scheduled to be deactivated on '+p.End_Date__c+' . Please take necessary action.\r\n\r\nThanks\r\nNSC Admin';                
                               
                t.activitydate = system.today();
                taskList.add(t);
            }
            system.debug(toAddress);
            String[] toAddressArray = new String[toAddress.size()];
            Integer i = 0;
            for (String eml: toAddress) {
                toAddressArray[i] = eml; 
                i++;
            }
            Messaging.SingleEmailMessage salesRepMail = new Messaging.SingleEmailMessage();
            salesRepMail.setUseSignature(false);
            SalesRepMail.setSaveAsActivity(false);
            salesRepMail.setToAddresses(toAddressArray);
            salesRepMail.setReplyTo('ad250024@ncr.com');
            salesRepMail.setSubject(et.Subject);
            String mailMessage = mailt.getHTMLBody();
            mailMessage = mailMessage.replaceAll('Product#Name', '' + p.name);
            mailMessage = mailMessage.replace('End#Date#replace', p.End_Date__c.format('MM/dd/YYYY'));
            DeactivatedProductReport__c dpr= DeactivatedProductReport__c.getValues('DeactivatedProductReportId');
            Report_ID= dpr.ReportId__c;
            mailMessage = mailMessage.replace('#url', System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Report_ID+'?pv0='+p.PMDM_Unique_Key__c);
            mailMessage = mailMessage.replace('#contact', getContactDetail(p));
            
            salesRepMail.setHtmlBody(mailMessage);
            salesRepMailLst.add(salesRepMail);
        }
        
        if(!salesRepMailLst.isEmpty())  Messaging.sendEmail(salesRepMailLst);
        if(!taskList.isEmpty()) insert taskList;


    }
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));
    }
}