global class profileTrackerBatchClass implements Database.Batchable<sObject>,Database.Stateful{
    Public List<String> profileNames= new List<String>(); 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Name,PermissionsCustomizeApplication,PermissionsModifyAllData from Profile';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Profile> profileList) {
        List<profiletracker__c> profs =new List<profiletracker__c>();
        Map<id,profiletracker__c> profileMapId = new Map<Id, profiletracker__c>();
        Map<id,Profile> profilesToUpdate = new Map<Id, Profile>();
        
        for(profiletracker__c profileObj : [Select ProfileId__c,IsCustomizeAppSelected__c from profiletracker__c]){
            profileMapId.put(profileObj.ProfileId__c,profileObj);
        }
        for(Profile pl : profileList)
        {        
            if(!profileMapId.containsKey(pl.id)){
                system.debug('Line number 16');
                profiletracker__c prof = new profiletracker__c();
                prof.ProfileId__c= pl.id;
                prof.Profile_Name__c= pl.Name;
                prof.IsCustomizeAppSelected__c=pl.PermissionsCustomizeApplication;
                profs.add(prof);
            }
            
            else if(profileMapId.containsKey(pl.id) && (profileMapId.get(pl.id).IsCustomizeAppSelected__c !=pl.PermissionsCustomizeApplication)){
                
                profilesToUpdate.put(pl.id,pl); 
                profileNames.add(pl.Name);
            }
            
        }
        if(profilesToUpdate !=null){
            for(profiletracker__c proObj : [select id,IsCustomizeAppSelected__c from profiletracker__c where ProfileId__c=: profilesToUpdate.keySet()]){
                profiletracker__c prof = new profiletracker__c();
                prof.id=proObj.id;
                prof.IsCustomizeAppSelected__c=proObj.IsCustomizeAppSelected__c ? false:true;
                profs.add(prof);
            }
        }
        system.debug('Line number 32'+profs);
        upsert profs;
        
    }   
    global void finish(Database.BatchableContext BC){ 
        // X profile received access to the ‘Customize Application’ permission by X user is sent to the IDC, NSC team and the IT support team.
        Map<String,SetupAuditTrail> data= new Map<String,SetupAuditTrail>();
        Datetime d = datetime.now().addhours(-4);
       // if(profileNames !=null && profileNames.size() >0){
            AsyncApexJob a = [SELECT Id,CreatedDate, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob WHERE Id =:BC.getJobId()]; // 5 PM
            // find today's logs
            List<SetupAuditTrail> listAudits = [SELECT Id, Action,DelegateUser,CreatedBy.Name,CreatedDate, Display,Section FROM SetupAuditTrail
                                                where createdDate > :d order by CreatedDate desc];
            system.debug('@@: '+listAudits);
            
            for(SetupAuditTrail stp: listAudits){
                if(stp.Display.contains('administrative permission Customize Application')){
                   data.put(stp.id,stp); 
                }
            } 
       
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.addAll((Label.ProfileTrackerNotificationUsers).split(','));
            mail.setToAddresses(sendTo);
            mail.setReplyTo('at250303@ncr.com');
            mail.setSenderDisplayName('NSC Adminisration');
            mail.setSubject('Customize Application Pemission Changed');
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'Customize_Application_Pemission_Changed'];
            String htmlBody = emailTemplate.HtmlValue;    
            String emailBody='';
            integer n=1;
            for(String key : data.keySet())  
            {  
                emailBody +=n+'.'+' '+data.get(key).Display+' by <b>'+data.get(key).CreatedBy.Name+'</b> on <b>'+data.get(key).CreatedDate+'</b><br/><br/>';
                n++;
            }
        	 htmlBody = htmlBody.replace('#EmailBody', emailBody);
        
            mail.setHtmlBody(htmlBody);
             if(profileNames !=null && profileNames.size() >0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}