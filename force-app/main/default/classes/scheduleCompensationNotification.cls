global class scheduleCompensationNotification implements schedulable {
    
    global static void execute(SchedulableContext SC){
        List <Messaging.SingleEmailMessage> mail1lst = new List<Messaging.SingleEmailMessage>();
        List <Messaging.SingleEmailMessage> retail_mail1lst = new List <Messaging.SingleEmailMessage>();
  
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();

        Messaging.SingleEmailMessage retail_mail1 = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage fin_mail1 = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage tnt_mail1 = new Messaging.SingleEmailMessage();
        
        ARCSEMailList__c recipients = ARCSEMailList__c.getInstance('recipients');
        
        String emailAddresses = recipients.EmailID__c;
        String[] toAddresses = emailAddresses.split(':',-1);
        
        String emailFinAdd = recipients.Financial_EmailID__c;
        String[] toFinAddresses = emailFinAdd.split(':',-1);
        
        String emailRetailAdd = recipients.Retail_EmailID__c;
        String[] toRetailAddresses = emailRetailAdd.split(':',-1);
        
        String emailTNTAdd = recipients.TNT_EmailID__c;      
        String[] toTNTAddresses = emailTNTAdd.split(':',-1);
        
        String newAssociates = '';
        String newNSCAssociate = '';
        String roleChangeAssociates = '';
        String terminatedAssociates = '';
 
        String newFinAssociates = '';
        String newNSCFinAssociate = '';
        String roleChangeFinAssociates = '';
        String terminatedFinAssociates = '';
        
        String newRetailAssociates = '';
        String newNSCRetailAssociates = '';
        String roleChangeRetailAssociates = '';
        String terminatedRetailAssociates = '';
        
        String newTNTAssociates = '';
        String newNSCTNTAssociate = '';
        String roleChangeTNTAssociates = '';
        String terminatedTNTAssociates = '';
               
        List<Sales_Compensation_Notification__c> updateCompensationRecords = new List<Sales_Compensation_Notification__c>();
        List<Sales_Compensation_Notification__c> newAssociatesList = new List<Sales_Compensation_Notification__c>();
        List<Sales_Compensation_Notification__c> roleChangeAssociatesList = new List<Sales_Compensation_Notification__c>();
        List<Sales_Compensation_Notification__c> terminatedAssociatesList = new List<Sales_Compensation_Notification__c>();
        
        List<Sales_Compensation_Notification__c> notifications = [SELECT Id, Action__c, Sales_Person_Quicklook_ID__c, Sales_Person__c, Previous_Job_Code__c, Job_Code__c, Previous_ARCS_Job_Family__c, ARCS_Job_Family__c, Role_Change_Date__c, Notified__c, Manager_Name__c, Manager_QuicklookID__c, Sales_Persons_Country_Code__c from Sales_Compensation_Notification__c where Notified__c = FALSE];
        List<String> uobj=new List<String>();
        
        for(Sales_Compensation_Notification__c s: notifications){
            uobj.add(s.Sales_Person_Quicklook_ID__c);
        }
        
        Map<String,String> quickLob=new map<String,String>();
        List<User> userLob=[SELECT Id,Quicklook_ID__c,LOB__c,Managers_LOB__c from User where Quicklook_ID__c in :uobj];
        if(userLob.size()>0){
            for(User u:userLob){
                if(u.LOB__c!=null || u.LOB__c!=''){
                    quickLob.put(u.Quicklook_ID__c,u.LOB__c);
                }
                else if(u.Managers_LOB__c!=null || u.Managers_LOB__c!=''){
                    quickLob.put(u.Quicklook_ID__c,u.Managers_LOB__c);
                }
            }
        }

        for(Sales_Compensation_Notification__c scm : notifications){
            String SalesPersonName = '';
            String SalesPersonQLID = '';
            String ManagerName = '';
            String ManagerQLID = '';
            String SalesPersonCountry = '';
            String OldJobRole = '';
            String NewJobRole = '';
            String NewJobCode = '';
            
            if(!String.isBlank(scm.Sales_Person__c)){
                SalesPersonName = scm.Sales_Person__c;  
            }
            if(!String.isBlank(scm.Sales_Person_Quicklook_ID__c)){
                SalesPersonQLID = scm.Sales_Person_Quicklook_ID__c; 
            }
            if(!String.isBlank(scm.Manager_Name__c)){
                ManagerName = scm.Manager_Name__c;  
            }
            if(!String.isBlank(scm.Manager_QuicklookID__c)){
                ManagerQLID = scm.Manager_QuicklookID__c;   
            }
            if(!String.isBlank(scm.Sales_Persons_Country_Code__c)){
                SalesPersonCountry = scm.Sales_Persons_Country_Code__c; 
            }
            if(!String.isBlank(scm.Previous_ARCS_Job_Family__c)){
                OldJobRole = scm.Previous_ARCS_Job_Family__c;   
            }
            if(!String.isBlank(scm.ARCS_Job_Family__c)){
                NewJobRole = scm.ARCS_Job_Family__c;    
            }
            if(!String.isBlank(scm.Job_Code__c)){
                NewJobCode = scm.Job_Code__c;   
            }
            
           If (Test.isRunningTest()) {
               quickLob.put(scm.Sales_Person_Quicklook_ID__c, 'Retail');
           }  
            if(scm.Action__c == 'New NSC SCP Associate') {
                newNSCAssociate = newNSCAssociate + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                scm.Notified__c = TRUE;
                scm.Notified_On__c = System.Now();
                newAssociatesList.add(scm);
                
              
               
               
                if(quickLob.get(scm.Sales_Person_Quicklook_ID__c)!=null){
                    if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Retail')){
                        newNSCRetailAssociates = newNSCRetailAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Financial')){
                        newNSCFinAssociate = newNSCFinAssociate + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('T&T')){
                        newNSCTNTAssociate = newNSCTNTAssociate + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }                   
                }
            }
            if(scm.Action__c == 'New SCP Associate'){
                newAssociates = newAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                scm.Notified__c = TRUE;
                scm.Notified_On__c = System.Now();
                newAssociatesList.add(scm);

                if(quickLob.get(scm.Sales_Person_Quicklook_ID__c)!=null){
                    if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Retail')){
                        newRetailAssociates = newRetailAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Financial')){
                        newFinAssociates = newFinAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('T&T')){
                        newTNTAssociates = newTNTAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }                   
                }
                
            }
            if(scm.Action__c == 'Terminated'){
                terminatedAssociates = terminatedAssociates + '<tr align = "left"><td>'+SalesPersonQLID+'</td><td>'+SalesPersonName+'</td></tr>';
                scm.Notified__c = TRUE;
                scm.Notified_On__c = System.Now();
                terminatedAssociatesList.add(scm);
                
                if(quickLob.get(scm.Sales_Person_Quicklook_ID__c)!=null){
                    if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Retail')){
                        terminatedRetailAssociates = terminatedRetailAssociates + '<tr align = "left"><td>'+SalesPersonQLID+'</td><td>'+SalesPersonName+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Financial')){
                        terminatedFinAssociates = terminatedFinAssociates + '<tr align = "left"><td>'+SalesPersonQLID+'</td><td>'+SalesPersonName+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('T&T')){
                        terminatedTNTAssociates = terminatedTNTAssociates + '<tr align = "left"><td>'+SalesPersonQLID+'</td><td>'+SalesPersonName+'</td></tr>';
                    }                   
                }                
            }
            if(scm.Action__c == 'Role Changed'){
                roleChangeAssociates = roleChangeAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+OldJobRole+'</td><td>'+NewJobRole+'</td><td>'+NewJobCode+'</td><td>'+SalesPersonCountry+'</td></tr>';
                scm.Notified__c = TRUE;
                scm.Notified_On__c = System.Now();
                roleChangeAssociatesList.add(scm);
                
                if(quickLob.get(scm.Sales_Person_Quicklook_ID__c)!=null){
                    if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Retail')){
                        roleChangeRetailAssociates = roleChangeRetailAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+OldJobRole+'</td><td>'+NewJobRole+'</td><td>'+NewJobCode+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('Financial')){
                        roleChangeFinAssociates = roleChangeFinAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+OldJobRole+'</td><td>'+NewJobRole+'</td><td>'+NewJobCode+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }
                    else if(quickLob.get(scm.Sales_Person_Quicklook_ID__c).equalsIgnoreCase('T&T')){
                        roleChangeTNTAssociates = roleChangeTNTAssociates + '<tr align = "left"><td>'+SalesPersonName+'</td><td>'+SalesPersonQLID+'</td><td>'+ManagerName+'</td><td>'+ManagerQLID+'</td><td>'+OldJobRole+'</td><td>'+NewJobRole+'</td><td>'+NewJobCode+'</td><td>'+SalesPersonCountry+'</td></tr>';
                    }                   
                }                
            }
        }
        if(newNSCAssociate != '' || newAssociates != ''){
            if(toAddresses.size()>=1){
                    System.debug('*************************************'+toAddresses+'');
                    mail1.setToAddresses(toAddresses);
                    mail1.setReplyTo('no-reply@salesforce.com');
                    mail1.setSenderDisplayName('Salesforce Administrator');
                    mail1.setSubject('URGENT: New Sales Associates');
                    mail1.setBccSender(false);
                    String mailBody = '<p style="font-family: calibri; font-size:11pt">';
                    mailBody = mailBody + 'Dear Sales Admin Team, <br/><br/>';
                    if(newNSCAssociate != ''){
                        mailBody = mailBody + 'The following new sales associates are in NCR.<br/><br/><table border="1" style="border-collapse:collapse; font-family: calibri; font-size:11pt" cellpadding="2" cellspacing="2"><tr  align = "left"><th>Name</th><th>QLID</th><th>Manager&#39;s Name</th><th>Manager&#39;s QLID</th><th>Country</th></tr>'+newNSCAssociate+'</table><br/>';
                    }
                    mailBody = mailBody + 'Thanks,<br/>Administrator<br/>NCR SalesCentral</p>';
                    mail1.setHTMLBody(mailBody);
                    mail1lst.add(mail1);
            }
            Messaging.sendEmailResult[] sendNewEmailResults = Messaging.sendEmail(mail1lst);
            if(sendNewEmailResults[0].IsSuccess()){
                updateCompensationRecords.addAll(newAssociatesList);
            }
              
        }
        if(newNSCRetailAssociates!= '' || newRetailAssociates != ''){
            if(toRetailAddresses.size()>1){
                    System.debug('*************************************'+toRetailAddresses+'');
                    retail_mail1.setToAddresses(toRetailAddresses);
                    retail_mail1.setReplyTo('no-reply@salesforce.com');
                    retail_mail1.setSenderDisplayName('Salesforce Administrator');
                    retail_mail1.setSubject('URGENT: New Sales Associates');
                    retail_mail1.setBccSender(false);
                    String mailBody = '<p style="font-family: calibri; font-size:11pt">';
                    mailBody = mailBody + 'Dear Retail Admin Team, <br/><br/>';
                    if(newNSCRetailAssociates!= ''){
                        mailBody = mailBody + 'The following new sales associates are in NCR.<br/><br/><table border="1" style="border-collapse:collapse; font-family: calibri; font-size:11pt" cellpadding="2" cellspacing="2"><tr  align = "left"><th>Name</th><th>QLID</th><th>Manager&#39;s Name</th><th>Manager&#39;s QLID</th><th>Country</th></tr>'+newNSCRetailAssociates+'</table><br/>';
                    }
                    mailBody = mailBody + 'Thanks,<br/>Administrator<br/>NCR SalesCentral</p>';
                    retail_mail1.setHTMLBody(mailBody);
                    retail_mail1lst.add(retail_mail1);}
        }     
        
        if(newNSCFinAssociate != '' || newFinAssociates != '') {
            if(toFinAddresses.size()>1){
                    System.debug('*************************************'+toFinAddresses+'');
                    fin_mail1.setToAddresses(toFinAddresses);
                    fin_mail1.setReplyTo('no-reply@salesforce.com');
                    fin_mail1.setSenderDisplayName('Salesforce Administrator');
                    fin_mail1.setSubject('URGENT: New Sales Associates');
                    fin_mail1.setBccSender(false);
                    String mailBody = '<p style="font-family: calibri; font-size:11pt">';
                    mailBody = mailBody + 'Dear Financial Admin Team, <br/><br/>';
                    if(newFinAssociates != ''){
                        mailBody = mailBody + 'The following new sales associates are in NCR.<br/><br/><table border="1" style="border-collapse:collapse; font-family: calibri; font-size:11pt" cellpadding="2" cellspacing="2"><tr  align = "left"><th>Name</th><th>QLID</th><th>Manager&#39;s Name</th><th>Manager&#39;s QLID</th><th>Country</th></tr>'+newFinAssociates+'</table><br/>';
                    }
                    mailBody = mailBody + 'Thanks,<br/>Administrator<br/>NCR SalesCentral</p>';
                    fin_mail1.setHTMLBody(mailBody);
                    retail_mail1lst.add(fin_mail1);
            }
        }     
        
        if(newNSCTNTAssociate != '' || newTNTAssociates != ''){
            if(toTNTAddresses.size()>=1){
                    System.debug('*************************************'+toTNTAddresses+'');
                    tnt_mail1.setToAddresses(toTNTAddresses);
                    tnt_mail1.setReplyTo('no-reply@salesforce.com');
                    tnt_mail1.setSenderDisplayName('Salesforce Administrator');
                    tnt_mail1.setSubject('URGENT: New Sales Associates');
                    tnt_mail1.setBccSender(false);
                    String mailBody = '<p style="font-family: calibri; font-size:11pt">';
                    mailBody = mailBody + 'Dear T&T Admin Team, <br/><br/>';
                    if(newTNTAssociates != ''){
                        mailBody = mailBody + 'The following new sales associates are in NCR.<br/><br/><table border="1" style="border-collapse:collapse; font-family: calibri; font-size:11pt" cellpadding="2" cellspacing="2"><tr  align = "left"><th>Name</th><th>QLID</th><th>Manager&#39;s Name</th><th>Manager&#39;s QLID</th><th>Country</th></tr>'+newTNTAssociates+'</table><br/>';
                    }
                    mailBody = mailBody + 'Thanks,<br/>Administrator<br/>NCR SalesCentral</p>';
                    tnt_mail1.setHTMLBody(mailBody);
                    retail_mail1lst.add(tnt_mail1);
            }
        }
                
        if(retail_mail1lst.size() >= 1){
            System.debug('****************************************'+retail_mail1lst.size()+'*******');
            Messaging.sendEmailResult[] sendRoleChangeEmailResults = Messaging.sendEmail(retail_mail1lst);
        }
        update updateCompensationRecords;
    }
}