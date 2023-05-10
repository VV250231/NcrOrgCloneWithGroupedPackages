global class Tableau_Scheduler implements schedulable{
    
    global void execute(SchedulableContext t){
        
        string m_tp = 'sk250817@ncr.com' ;
        string m_sub = 'Tableau Script Status : process started ';
        string m_body = '****** Script Generation Started ******' +
            '<br> </br> Date Time Executed : '+ Date.today() ;
        sendemail(m_tp,m_sub,m_body,1); 
        
    }
    public static void sendemail(String mto,string msubject,string mbody,integer t ){
      
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { mto };
            message.subject = msubject;
        message.toaddresses.addall(getMailAddresses('TableauAdmins'));
        message.htmlbody = mbody; 
        
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
        
        if (results[0].success) {
            system.debug('The email was sent successfully.');
         } 
        else {
            system.debug('The email failed to send: '+ results[0].errors[0].message);
        }
        
        if(t==1 && !test.isRunningTest() ){
           Database.executeBatch(new Tableau_Batch_getNewRole());  
        }else if(t==2 && !test.isRunningTest() ){
           Database.executeBatch(new Tableau_Batch_GenRoleID());
        } else if(t==3 && !test.isRunningTest() ){
           Database.executeBatch(new Tableau_Batch_GenScript());
        }
        
    }
    public static List<String> getMailAddresses(string groupname_api){
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: groupname_api];
        for (GroupMember gm : g.groupMembers) 
        {
            mailList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr) 
        {
            mailAddresses.add(u.email);
        } 
        return mailAddresses;
    }

}