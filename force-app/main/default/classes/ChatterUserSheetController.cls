/**************************************
  Author ...............: Srikanth Bodepudi
  Date Created .........: 8 sept-2014
  Last Modified By .....: Alok Tiwari
  Last Modified Date ...: 30-May-2018
  Description ..........: ChatterUser Sheet Controller Class 
  *****************************************/


global class ChatterUserSheetController implements schedulable { 
 public String Count{get;set;} 
 public void execute(SchedulableContext sc){ 
    
    List <Messaging.SingleEmailMessage> mailArray = new List <Messaging.SingleEmailMessage>();          
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //mail.setSenderDisplayName('POSasaService@ncr.com');
    
    //Removed Srikanth and Hartmut Foth from to addresses and addded Rupesh Arora and Alok Tiwari - 11/07/2016
    //Made configurable - NC_AGILE-1418
    //Use this distribution list to add or remove member
    mail.setToAddresses(new String[] {'CS230318@ncr.com'});
    
    Integer  usrs = [Select count() from User where Usertype =:'CsnOnly' and createddate = LAST_MONTH];
    mail.setReplyTo('adminnsc@ncr.com');
     
    mail.setSubject('Chatter User Count for last month');
    string  strBody = ' Hi, <br /> <br /> The Chatter self-service count for last month :<b> '+  usrs + ' </b>  <b> Users </b>' +'<br />';
            strBody +='  <br />';  
            strBody +='Thank you,<br /><br />';
            strBody +='NSC Admin. <br />';
      strBody +='<a href="mailto:adminnsc@ncr.com"></a> <br /> </font>';
    mail.setHtmlBody(strBody);
   


    mailArray.add(mail);     
    
    try{
    Messaging.sendEmail(mailArray);
    }
    catch(Exception e){
      System.debug('Exception Caught'+e.getMessage());
    }   
}
 }