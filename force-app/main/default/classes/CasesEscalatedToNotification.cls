public class CasesEscalatedToNotification {
    public static void casesEscalatedToNotificationInsertCase(List<Case> caseList){
        Set<Id> caseIdsSet = new Set<Id>();
        for(Case caseObj : caseList){
            caseIdsSet.add(caseObj.id);
        }
        System.debug('@@@caseIdsSet'+caseIdsSet);
        if(!caseIdsSet.isEmpty())
            CasesEscalatedToNotificationMainMethod(caseIdsSet);
    }
    public static void casesEscalatedToNotificationUpdateCase(List<Case> caseList, Map<Id, case> caseMap){
        Set<id> caseIdsSet = new Set<id>();
        for(Case caseObj : caseList){
            if(caseObj.DRT_Escalated_To__c != caseMap.get(caseObj.id).DRT_Escalated_To__c){
                caseIdsSet.add(caseMap.get(caseObj.id).id);
                System.debug('@@@'+caseIdsSet);
            }
            // caseIdsSet.add(caseObj.Id);
        }
        if(!caseIdsSet.isEmpty())
            CasesEscalatedToNotificationMainMethod(caseIdsSet);
    }
    public static void CasesEscalatedToNotificationMainMethod(Set<Id> caseIdsSet){
        List<String> emailList = new List<String>();
        List<Case> caseList = new List<Case>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Lead> existingLead = new List<Lead>();
        List<Contact> existingContact = new List<Contact>();
        // For EBA_SF-1266
        List<NCR_EmailMessage__c> mails = new List<NCR_EmailMessage__c>();
        
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        for(Case caseObj : [SELECT id,DRT_Escalated_To__c,Chat_User_Company__c,Chat_User_Country__c,Chat_User_Email__c,Chat_User_First_Name__c,
                            Chat_User_Industry__c,Chat_User_Last_Name__c,Chat_User_Source__c,Chat_User_Type__c,Origin,Owner.Name,
                            Agent_Notes__c,Business_Function__c,Campaign_Code__c,Campaign_End_Date__c,Campaign_Name__c,
                            Campaign_Start_Date__c,Campaign_Status__c,Campaign_Type__c,City__c,OwnerId,RecordTypeId,
                            Zip_Or_Postal_Code__c,State_Province__c,Title__c,Sub_Industry__c,Chat_User_Phone__c,Position__c,
                            Number_of_Locations__c,Years_In_Business__c,Timing__c,Company_Annual_Sales__c,Number_of_Employees__c,Subject,
                            Description,Status,Comments__c,CaseNumber,Category_DRT__c,Description__c,
                            What_can_NCR_help_you_with_today__c,LeadId__r.Name,LeadId__r.Email,LeadId__r.Position__c,
                            LeadId__r.Company,LeadId__r.Phone,Contact.Name,Contact.Email,Contact.Title,Contact.Phone,
                            Account.Name,Account.Master_Customer_Number__c,Account.LOB__c
                            From Case Where Id In: caseIdsSet]){
                                if(caseObj.RecordTypeId == CaseRecordTypeId){
                                    caseMap.put(caseObj.Id, caseObj);                      
                                    //caseList.add(caseObj);                      
                                    emailList.add(caseObj.Chat_User_Email__c);
                                }
                            }
        System.debug('@@@@caseMap'+caseMap);
        
        /* for(Case caseObj : caseMap.values()){
        System.debug('@@@Email'+caseMap.get(caseObj.id).Chat_User_Email__c);
        if(caseMap.get(caseObj.id).Chat_User_Email__c !=null){
        existingLead = [Select id, email ,Name, Position__c, Company, Phone from Lead where email = :caseMap.get(caseObj.id).Chat_User_Email__c LIMIT 1]; 
        existingContact=[Select id,Email,Name, Account.Name,Account.Master_Customer_Number__c,Account.LOB__c, Title, Phone from Contact where Email = :caseMap.get(caseObj.id).Chat_User_Email__c LIMIT 1];
        }
        }
        System.debug('@@@@existingContact'+existingLead);
        System.debug('@@@@existingContact'+existingContact);*/
        for(Case caseObj : caseMap.values()){
            System.debug('@@@Description'+caseMap.get(caseObj.id).Description__c);
            System.debug('@@@@Category'+caseMap.get(caseObj.id).Category_DRT__c);
            if(caseMap.get(caseObj.id).DRT_Escalated_To__c !=null){
                //Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
                ncrEmail.Email_Type__c = 'CasesEscalatedToNotification';
                ncrEmail.Recipient1__c = caseMap.get(caseObj.id).DRT_Escalated_To__c;
                //   message.setToAddresses(sendingTo);         
                //  message.setInReplyTo('NI230017@ncr.com');
                // message.setSenderDisplayName('NSC Admin');
                //message.optOutPolicy = 'FILTER';
                ncrEmail.Subject__c = 'Salesforce Case Escalation -' + caseMap.get(caseObj.id).Subject +'';
                string strBody = 'This case has been escalated to you by the Marketing Digital Response Team.  Please see the case details below and reach out to the new prospect/lead/contact included.<br /><br />';
                strBody += '<html><body style="font-family: Arial; font-size: 9pt;"><tr>';
                strBody += '<table border="2" cellpadding="4" cellspacing="0" style="font-family: Arial; font-size: 9pt;">';
                strBody += '<th><strong:Arial align="Center" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;Case<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial>Case Owner<strong></td>' + '<td><font face="Arial">' + caseMap.get(caseObj.id).Owner.Name + '</font>' + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Case Number<strong></td>' + '<td><font face="Arial">' + caseMap.get(caseObj.id).CaseNumber + '</font>' + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Case Origin<strong></td>' + '<td>' +caseMap.get(caseObj.id).Origin + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Subject<strong></td>' + '<td>' + caseMap.get(caseObj.id).Subject +  '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Description<strong></td>' + '<td>' + caseMap.get(caseObj.id).Description__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Status<strong></td>' + '<td>' +caseMap.get(caseObj.id).Status + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Category<strong></td>' + '<td>' + caseMap.get(caseObj.id).Category_DRT__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Agent Notes<strong></td>' + '<td>' +caseMap.get(caseObj.id).Agent_notes__c + '</td>' + '</tr>';
                strBody += '<th><strong:Arial align="Center">New Prospect<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial>First Name<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_First_Name__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Last Name<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Last_Name__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Email<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Email__c + '</td>' + '</tr>';                
                strBody += '<tr><td><strong:Arial>Phone<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Phone__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Industry<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Industry__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Sub Industry<strong></td>' + '<td>' + caseMap.get(caseObj.id).Sub_Industry__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Company<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Company__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>City<strong></td>' + '<td>' + caseMap.get(caseObj.id).City__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Country<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Country__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Zip Or Postal Code<strong></td>' + '<td>' + caseMap.get(caseObj.id).Zip_Or_Postal_Code__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>State/Province<strong></td>' + '<td>' + caseMap.get(caseObj.id).State_Province__c + '</td>' + '</tr>';
                //  strBody += '<tr><td><strong:Arial>Phone<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Phone__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Lead Type<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Type__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Lead Source<strong></td>' + '<td>' + caseMap.get(caseObj.id).Chat_User_Source__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Title<strong></td>' + '<td>' + caseMap.get(caseObj.id).Title__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Business Function<strong></td>' + '<td>' + caseMap.get(caseObj.id).Business_Function__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Year In Business<strong></td>' + '<td>' + caseMap.get(caseObj.id).Years_In_Business__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Position<strong></td>' + '<td>' + caseMap.get(caseObj.id).Position__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Timing<strong></td>' + '<td>' + caseMap.get(caseObj.id).Timing__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Number of Location<strong></td>' + '<td>' + caseMap.get(caseObj.id).Number_of_Locations__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Number Of Employees<strong></td>' + '<td>' + caseMap.get(caseObj.id).Number_of_Employees__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Company Annual Sales<strong></td>' + '<td>' + caseMap.get(caseObj.id).Company_Annual_Sales__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Campaign Code<strong></td>' + '<td>' + caseMap.get(caseObj.id).Campaign_Code__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Campaign Name<strong></td>' + '<td>' + caseMap.get(caseObj.id).Campaign_Name__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>What Can NCR help you with today?<strong></td>' + '<td>' + caseMap.get(caseObj.id).What_can_NCR_help_you_with_today__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Comments<strong></td>' + '<td>' + caseMap.get(caseObj.id).Comments__c + '</td>' + '</tr>';
                /* strBody += '<th><strong:Arial>Existing Lead<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial align="Center">Lead Name<strong></td>' + '<td>' +(!existingLead.isEmpty() ? existingLead[0].Name : null)  + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Position<strong></td>' + '<td>' + (!existingLead.isEmpty() ? existingLead[0].Position__c : null) + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Company<strong></td>' + '<td>' + (!existingLead.isEmpty() ? existingLead[0].Company : null) + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Phone<strong></td>' + '<td>' + (!existingLead.isEmpty() ? existingLead[0].Phone : null) + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Email<strong></td>' + '<td>' + (!existingLead.isEmpty() ? existingLead[0].Email : null) + '</td>' + '</tr>';
                strBody += '<th><strong:Arial align="Center">Existing Contact<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial>Contact Name<strong></td>' + '<td>' + (!existingContact.isEmpty() ? existingContact[0].Name : null) + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Title<strong></td>' + '<td>' + (!existingContact.isEmpty() ? existingContact[0].Title : null)+ '</td>' + '</tr>';
                //  strBody += '<tr><td><strong:Arial>Company<strong></td>' + '<td>' + existingContact[0].Company + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Phone<strong></td>' + '<td>' + (!existingContact.isEmpty() ? existingContact[0].Phone : null)+ '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Email<strong></td>' + '<td>' + (!existingContact.isEmpty() ? existingContact[0].Email : null) + '</td>' + '</tr>';
                strBody += '<th><strong:Arial>Existing Account<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial align="Center">Account Name<strong></td>' + '<td>' + (!existingContact.isEmpty() ? existingContact[0].Account.Name : null) + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Master Customer Number<strong></td>' + '<td>' + (!existingContact.isEmpty() ? existingContact[0].Account.Master_Customer_Number__c : null) + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>LOB<strong></td>' + '<td>' +(!existingContact.isEmpty() ? existingContact[0].Account.Lob__c : null) + '</td>' + '</tr>';*/
                                // strBody += '<tr><td><strong:Arial>Sub Industry<strong></td>' + '<td>' + l.LeadSource + '</td></tr>' + '</tr>';
                // strBody += '<tr><td><strong:Arial>Lead - Marketing Notes<strong></td>' + '<td>' + l.Lead_Marketing_Notes__c + '</td></tr>' + '</tr>';    
                strBody += '<th><strong:Arial>Existing Lead<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial align="Center">Lead Name<strong></td>' + '<td>' +caseMap.get(caseObj.id).LeadId__r.Name  + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Position<strong></td>' + '<td>' + caseMap.get(caseObj.id).LeadId__r.Position__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Company<strong></td>' + '<td>' + caseMap.get(caseObj.id).LeadId__r.Company + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Phone<strong></td>' + '<td>' + caseMap.get(caseObj.id).LeadId__r.Phone + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Email<strong></td>' + '<td>' + caseMap.get(caseObj.id).LeadId__r.Email + '</td>' + '</tr>';
                strBody += '<th><strong:Arial align="Center">Existing Contact<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial>Contact Name<strong></td>' + '<td>' + caseMap.get(caseObj.id).Contact.Name + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Title<strong></td>' + '<td>' + caseMap.get(caseObj.id).Contact.Title+ '</td>' + '</tr>';
                //  strBody += '<tr><td><strong:Arial>Company<strong></td>' + '<td>' + existingContact[0].Company + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Phone<strong></td>' + '<td>' + caseMap.get(caseObj.id).Contact.Phone+ '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Email<strong></td>' + '<td>' + caseMap.get(caseObj.id).Contact.Email + '</td>' + '</tr>';
                strBody += '<th><strong:Arial>Existing Account<strong>' +'</th>';
                strBody += '<th><strong:Arial align="Center" colspan="2">Information<strong>' +'</th>';
                strBody += '<tr><td><strong:Arial align="Center">Account Name<strong></td>' + '<td>' + caseMap.get(caseObj.id).Account.Name + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>Master Customer Number<strong></td>' + '<td>' + caseMap.get(caseObj.id).Account.Master_Customer_Number__c + '</td>' + '</tr>';
                strBody += '<tr><td><strong:Arial>LOB<strong></td>' + '<td>' + caseMap.get(caseObj.id).Account.Lob__c + '</td>' + '</tr>';
                strBody += '</tr>';
                strBody += '</table>';
                strBody += '</body></html>';
                strBody += '<br/><br/><br> Thank You,<br/>NCR Webmaster<br/>1-800-Call-NCR<br/>NCR.Webmaster@ncr.com';
                
                // message.setHtmlBody(strBody);
                ncrEmail.HTML_Body__c = strBody;
                mails.add(ncrEmail);
                /*Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                System.debug('The email was sent successfully.');
                } else {
                System.debug('The email failed to send: '
                + results[0].errors[0].message);
                }*/
            }
        }
        
        if(mails.size() > 0)
            Insert mails;
        
    }
}