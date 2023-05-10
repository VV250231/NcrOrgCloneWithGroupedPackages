public class informOpportunityOwner{

public opportunity o = new opportunity();
public user usr = new user();
public user mgr = new user();
public String[] ccAddresses;
public void doSendmail(id i){
    String[] toAddresses ;
    o = [select id , Opportunity_Number__c, owner.email, owner.name,name, account.name, account.owner.email, owner.managerid from opportunity where id =: i];
    usr = [select id , managerid from user where id =: o.ownerid];
    if(usr.managerid <> null)
    {
    mgr = [select id,name, email from user where id=: usr.managerid ];
    }
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    toAddresses = new String[] {o.owner.email}; 
    if(mgr.email<>null)
    { 
    ccAddresses = new String[] {mgr.email, o.account.owner.email}; 
    } else {
    
    ccAddresses = new String[] {o.account.owner.email}; 
    }
    mail.setToAddresses(toAddresses);
    mail.setReplyTo('no-reply@salesforce.com');
    mail.setSenderDisplayName('Salesforce Administrator');    
    mail.setccAddresses(ccAddresses);
    mail.setSubject('Alert: Single Hardware Product Addition to Opportunity: '+o.name+':'+ o.Opportunity_Number__c);
    mail.setBccSender(false);
    mail.setHtmlBody('<p style="font-family: calibri; font-size:11pt">'+ 'Dear '+ o.owner.Name +'<br/><br/>An Opportunity has been created with Hardware toplines only.There is no SW, SWM or PS attached . Details of opportunity are as below:'+ '<br/><br/>Opportunity Name: '+ o.name +'<br/>Opportunity Number: '+o.opportunity_Number__c +'<br/>Customer Name: ' + o.account.name+'<br/><br/>Thanks,<br/>Administrator<br/>NCR SalesCentral</p> ');
    system.debug(mail);
    Messaging.sendEmailResult[] sendTerminatedEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail });
   
    }
}