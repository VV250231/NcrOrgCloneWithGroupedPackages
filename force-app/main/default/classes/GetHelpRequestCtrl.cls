public with sharing class GetHelpRequestCtrl {
    
    public case cases;
    public String subject{get;set;}
    public Boolean messageflag{get;set;}
    
    public case getcases(){
    List<User> UserObjList = [Select id ,contactId, Contact.name from User where Id =: Userinfo.getuserID()];
       System.debug('UserObjList '+ UserObjList );
       cases = new case();
       If(UserObjList != null && !UserObjList.isempty() )
       {
        System.debug('UserObjList '+ UserObjList[0].contactId );
           cases.contactId = UserObjList[0].contactId;
           
           }
          return cases;
    
    }
    
    
      
    public GetHelpRequestCtrl(ApexPages.StandardController controller) {
       
       String getHelpId= apexpages.currentpage().getparameters().get('prevId');
       If(getHelpId != null && getHelpId !=''){
           messageflag = true;
       }
    }
    
    
    public pageReference saveAndNew(){
        PageReference ref ;
        
       List<Get_help_Configuration__mdt> getHelpConfiguration =[Select id, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c from Get_help_Configuration__mdt Where MasterLabel =:subject ] ;
           If(getHelpConfiguration  != null ){
            
          List<String> sendTo = getHelpConfiguration[0].Email_Send_List__c.split(',');
              
                try{
                    If(cases.priority== null){
                        cases.priority = 'medium';
                    }
                    cases.subject = subject;
                    insert cases;
                    messageflag = true ;
                    ref = new PageReference('/PartnerCentral/500/e?prevId='+cases.Id ) ;
                    updateCaseOwner(cases.id,getHelpConfiguration);
                    SendEmail(cases.id, sendTo );
                   
                 }catch(Exception e){
                   System.debug('Exception Caught'+e.getMessage());
                 }
             } /*Else{
                 
             } commented empty block statement */   
             return ref;
    
    }
    
     public pageReference Submit(){
         PageReference ref ;
        List<Get_help_Configuration__mdt> getHelpConfiguration =[Select id, Test_Email__c,Case_Assigned_User_Name__c,Email_Send_List__c from Get_help_Configuration__mdt Where MasterLabel =:subject ] ;
        If(getHelpConfiguration  != null ){
            List<String> sendTo = getHelpConfiguration[0].Email_Send_List__c.split(',');
          //  try{
                If(cases.priority== null){
                    cases.priority = 'medium';
                }
                cases.subject = subject;
                insert cases;
                ref = new PageReference('/'+cases.Id ) ;
                updateCaseOwner(cases.id, getHelpConfiguration);
               SendEmail(cases.id, sendTo );
                   
           //  }catch(Exception e){
               
           //  }
           } /*Else{
           } commented empty block statement */  
        return ref;
    
    }
    
    
     
    
    public void updateCaseOwner(id CaseId, List<Get_help_Configuration__mdt> getHelpConfiguration){
        String userName = getHelpConfiguration[0].Case_Assigned_User_Name__c +'%';
        List<User> userObj = [Select Id from User Where UserName Like : userName ];
        
        Case c = new Case();
        c.id = CaseID;
        If(Test.isRunningTest()){
           c.ownerId  =Userinfo.getUserId(); 
        }
        Else{
        c.ownerId = userObj[0].Id;
        }    
        update c;
    
    }
    
    public void SendEmail(Id CaseId, List<String> sendTo){
          //get the send To Addresses
          List<OrgWideEmailAddress> emailAddress = new List<OrgWideEmailAddress>();
          emailAddress = [SELECT Id, address FROM OrgWideEmailAddress WHERE address = 'partner.resourcecenter@ncr.com']; 
          
            sendTo.add(UserInfo.getUserEmail());
          
          if (UserInfo.getUserId() != null) {
               List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
                   if (users.size() > 0) {
                      List<Account> accounts = [SELECT Id, Name,OwnerId, Owner.Name,Owner.Email, Master_Customer_Number__c FROM Account WHERE Id =: users[0].AccountId LIMIT 1];
                       if (accounts.size() > 0) {
                          sendTo.add(accounts[0].Owner.Email);
                       }
    
               }
           }
           
            //Locate the contact for creating mail          
           Contact c = [select id, Email from Contact where email <> null limit 1];
           List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
           Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
           msg.setTemplateId( [select id from EmailTemplate where Name ='Get Help Submission Notification'].id );
           msg.setWhatId(CaseId);
           msg.setTargetObjectId(c.id);
           msg.setToAddresses(new List<String>{'partner.resourcecenter@ncr.com'});
           if (emailAddress.size() > 0) {
                msg.setOrgWideEmailAddressId(emailAddress[0].Id);
           }
           lstMsgs.add(msg);

           // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(lstMsgs);
            Database.rollback(sp);

     // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
     // contents to a new SingleEmailMessage. Then send those new messages.
     List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
     for (Messaging.SingleEmailMessage email : lstMsgs) {
         Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
         emailToSend.setToAddresses(sendTo);
         emailToSend.setPlainTextBody(email.getPlainTextBody());
         emailToSend.setHTMLBody(email.getHTMLBody());
         emailToSend.setSubject(email.getSubject());
         if (emailAddress.size() > 0) {
            emailToSend.setOrgWideEmailAddressId(emailAddress[0].Id);
         }
         lstMsgsToSend.add(emailToSend);
         }
         Messaging.sendEmail(lstMsgsToSend);
       
    }

}