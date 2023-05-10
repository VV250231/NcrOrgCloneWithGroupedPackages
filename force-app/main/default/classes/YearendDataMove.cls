global class YearendDataMove implements Database.Batchable<sObject>{
     string Site= 'Site';
String query = 'select id,A360_Solution_Revenue_YTD__c,A360_Solution_Revenue_YTD_1__c,A360_Solution_Revenue_YTD_2__c,A360_Solution_Revenue_YTD_3__c,A360_Solution_Orders_YTD__c,A360_Solution_Orders_YTD_1__c,A360_Solution_Orders_YTD_2__c,A360_Solution_Orders_YTD_3__c,A360_CMS_Revenue_YTD__c,A360_CMS_Revenue_YTD_1__c,A360_CMS_Revenue_YTD_2__c,A360_CMS_Revenue_YTD_3__c,A360_Annuity_Revenue__c,A360_Annuity_Revenue_YTD_1__c,A360_Annuity_Revenue_YTD_2__c,A360_Annuity_Revenue_YTD_3__c,A360_Current_File_Value__c,A360_File_Value_YTD_1__c,A360_File_Value_YTD_2__c,A360_File_Value_YTD_3__c from Account where Account.Recordtype.Name <>: Site';

global Database.querylocator start(Database.BatchableContext BC){
            String[] toAddresses ;
            toAddresses = new String[] {'NI230017@ncr.com','ad250024@ncr.com','pb185126@ncr.com'}; 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setReplyTo('no-reply@salesforce.com');
    mail.setSenderDisplayName('Salesforce Administrator');    
    mail.setSubject('Account360 year End Change Batch class Execution started');
    mail.setHtmlBody('<p style="font-family: calibri; font-size:11pt">'+ 'Dear User' +'<br/><br/>Batch class YearendDataMove execution has started.'+'<br/><br/>Thanks,<br/>Administrator<br/>NCR SalesCentral</p> ');
    system.debug(mail);
    Messaging.sendEmailResult[] sendTerminatedEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail });

            return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Account> accns = new List<Account>();

   for(sObject s : scope){
   
   Account a = new Account();
   a=(Account)s;
   a.A360_Solution_Revenue_YTD_3__c=a.A360_Solution_Revenue_YTD_2__c;
   a.A360_Solution_Revenue_YTD_2__c=a.A360_Solution_Revenue_YTD_1__c;
   a.A360_Solution_Revenue_YTD_1__c=a.A360_Solution_Revenue_YTD__c;
   a.A360_Solution_Revenue_YTD__c=null;
   
   
   a.A360_Solution_Orders_YTD_3__c=a.A360_Solution_Orders_YTD_2__c;
   a.A360_Solution_Orders_YTD_2__c= a.A360_Solution_Orders_YTD_1__c;
    a.A360_Solution_Orders_YTD_1__c=   a.A360_Solution_Orders_YTD__c;
       a.A360_Solution_Orders_YTD__c=null;

  
   
   a.A360_CMS_Revenue_YTD_3__c=   a.A360_CMS_Revenue_YTD_2__c;
      a.A360_CMS_Revenue_YTD_2__c=a.A360_CMS_Revenue_YTD_1__c;
      a.A360_CMS_Revenue_YTD_1__c=a.A360_CMS_Revenue_YTD__c;
      a.A360_CMS_Revenue_YTD__c=null;
   
   
   
   
   
   
a.A360_Annuity_Revenue_YTD_3__c=a.A360_Annuity_Revenue_YTD_2__c;
a.A360_Annuity_Revenue_YTD_2__c=a.A360_Annuity_Revenue_YTD_1__c;
a.A360_Annuity_Revenue_YTD_1__c=a.A360_Annuity_Revenue__c;
a.A360_Annuity_Revenue__c=null;
   
   
   
   a.A360_File_Value_YTD_3__c=a.A360_File_Value_YTD_2__c;
   a.A360_File_Value_YTD_2__c= a.A360_File_Value_YTD_1__c;
    a.A360_File_Value_YTD_1__c=a.A360_Current_File_Value__c;
    a.A360_Current_File_Value__c=null;
   accns.add(a);
            }
  

update accns;
}
    

global void finish(Database.BatchableContext BC){
    String[] toAddresses ;
    toAddresses = new String[] {'NI230017@ncr.com','ad250024@ncr.com','pb185126@ncr.com'}; 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setReplyTo('no-reply@salesforce.com');
    mail.setSenderDisplayName('Salesforce Administrator');    
    mail.setSubject('Account360 year End Change Batch class Execution completed');
    mail.setHtmlBody('<p style="font-family: calibri; font-size:11pt">'+ 'Dear User' +'<br/><br/>Batch class YearendDataMove execution has completed.'+'<br/><br/>Thanks,<br/>Administrator<br/>NCR SalesCentral</p> ');
    system.debug(mail);
    Messaging.sendEmailResult[] sendTerminatedEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail });

system.debug('done');
}
}