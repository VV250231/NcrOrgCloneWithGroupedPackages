/*
##################################################################################################
# Project Name and Request Num..........: NSC Sales Central(Part of NSCI_AGILE-1276)
# File............................:NAMERStatusNotify_Batch.cls                                                        
# Created by................: PANKAJ KASHYAP                                                                   
# Created Date...........: 9/6/2016 9:20 AM                                                                             
# Last Modified by......:  PANKAJ KASHYAP
# Last Modified Date..:    24-08-2016
# Description........:  NSCI_AGILE-1276-Logic is constructed to check Namer_Six_Days_Notification__c field,based on 
                        NamerSentNotificationAfter5Days workflow will send email to lead owner and manager.
                               
################################################################################################
Modification History
Version     Date          Req.No.             Dev Name                 Description
55         19-12-2022                         Monika                   EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
*/



global class NAMERStatusNotify_Batch implements Database.Batchable<sObject>,Database.Stateful{

       
        List<Lead> SendEmail = new list<lead>();
       
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
            
         String query = 'select id,name,Namer_Six_Days_Notification__c,LeadStatusSLA__c,status,ownerid,owner.name,Lead_owner_assigned_date__c from lead where (Namer_Notification_Days__c = 6  and  Namer_Six_Days_Notification__c=false and Namer_Date_Field__c != null)';
         system.debug('start'+Database.getQueryLocator(query)); 
           
         return Database.getQueryLocator(query);
         
        }
      
      // Execute Logic
       global void execute(Database.BatchableContext BC, List<sObject> scope){
           List<lead> AllLead = (List<lead>)scope;
             system.debug('1111111111111');
             for(lead obj : AllLead){
                 
                 if(obj.Status == 'Open' ){
                 
                 obj.Namer_Six_Days_Notification__c=True;
                 system.debug('Execute'+obj.Namer_Six_Days_Notification__c);
                 SendEmail.add(obj); 
                 
                 }  
                 
                                     
             }      
     system.debug('222222222222');
       }
     
         
       global void finish(Database.BatchableContext BC){
            if(SendEmail.Size()>0){
                update SendEmail;
                System.debug('Finish');
            }   
       }
       
    }