/*
####################################################################################################################
# Project Name..........: Lead Ecosystem                                                                                                                        
# File............................:LeadResellerClass.cls                                                             
# Created by................: Yogesh Singh                                                                       
# Created Date...........: 02-26-2021                                                                                  
# Last Modified by......:Kavya Sree                                                                          
# Last Modified Date..: 11-04-2022                                                                                 
# Description...............: Populate reseller on lead object.
Modification History:
Date           Dev. Name          User Story  
11 April 2022    Kavya Sree         #EBA_SF-1936 Remove Partner Managed Lead Error - HOSP
#Description..........:Commented the code from line no 27-29 in order to remove the partner Managed Lead Error.
####################################################################################################################
*/
public class LeadResellerClass {
    public static Boolean isfirst = true;
    public static String ResellerLeadOwnerConfig = System.Label.Reseller_Lead_Owner_Id;
    public static void leadReslrAttachment(List<lead> lRList){
        Set<String> lPCode = new Set<String>();
        Set<String> lCCode = new Set<String>();
        List<Lead> lRNotList = new List<Lead>();
        boolean pMLead= false;
        List<Reseller__c> resList = new List<Reseller__c>();
        for(Lead lRObj: lRList){
            if(lRObj.Country_Code__c =='US'){
                /*if(String.isEmpty(lRObj.PostalCode)){
                    lRObj.addError(system.label.LeadEco3);
                }else{*/
                    lPCode.add(lRObj.PostalCode);
                //}
            }else if(lRObj.Country_Code__c==Null){
                lRObj.addError(system.label.LeadEco4);
            }else{
                lCCode.add(lRObj.Country_Code__c);
            }
        }
        
        // lCCode lPCode check null value lRslrMap check if else 
        Map<String, Reseller__c> lRslrMap = new Map<String, Reseller__c>(); 
        for(Reseller__c rObj :[Select Id,Region__c, Reseller__c, Name, ResellerContactFirstName__c, ResellerContactPhone__c, ToEmail__c, CCEmail__c, ZIPCode__c, CountryName__c, CountryCode__c, ResellerContactLastName__c, NCR_Lead_Owner__c, NCR_Lead_Owner__r.email, NCR_Lead_Owner__r.name FROM Reseller__c where (ZIPCode__c IN :lPCode)  OR (CountryCode__c IN :lCCode)]){
            if(rObj.CountryCode__c.toUpperCase()== 'US' && rObj.ZIPCode__c!=null){
                lRslrMap.put(rObj.ZIPCode__c,rObj);
            }else{
                lRslrMap.put(rObj.ZIPCode__c, rObj);
            }
        }
        if(!lRslrMap.isEmpty()){
            List<Lead> lUpdList = new List<lead>();
            Map<Id,Id> pMapId = new Map<Id,Id>();
            ResellerNotificationSwitchs__c resellerSwitchButton =ResellerNotificationSwitchs__c.getAll().Values();
            LeadOwnerNotificationSwitch__c LeadOwnerNotificationSwitch = LeadOwnerNotificationSwitch__c.getAll().values();
            Set<Reseller__c> lRMapNotfy = new Set<Reseller__c>();
            for(Id pId : ResellerLeadOwnerConfig.split(',')){
                pMapId.put(pId, pId);
            }
            for(Lead lObj :lRList){
                if(lRslrMap.ContainsKey(lObj.PostalCode)){
                    Lead uL = new Lead();
                    ul.Id = lObj.id;
                    ul.Reseller_Region__c = lRslrMap.get(lObj.PostalCode).Region__c;
                    uL.Reseller_email_1__c = lRslrMap.get(lObj.PostalCode).ToEmail__c;
                    if(lRslrMap.get(lObj.PostalCode).ToEmail__c==null){
                        uL.Reseller_email_1__c = lRslrMap.get(lObj.PostalCode).CCEmail__c;
                    }
                    uL.Reseller_office__c = lRslrMap.get(lObj.PostalCode).Reseller__c;
                    uL.Reseller_email_2__c = lRslrMap.get(lObj.PostalCode).CCEmail__c;
                    uL.Reseller_Contact_Phone__c = lRslrMap.get(lObj.PostalCode).ResellerContactPhone__c;
                    uL.Reseller_Contact__c = (lRslrMap.get(lObj.PostalCode).ResellerContactFirstName__c == null ? ' ' : lRslrMap.get(lObj.PostalCode).ResellerContactFirstName__c) + '   ' + (lRslrMap.get(lObj.PostalCode).ResellerContactLastName__c == null ? ' ' : lRslrMap.get(lObj.PostalCode).ResellerContactLastName__c);
                    if(ul.Reseller_email_1__c!=null){
                        if(pMapId.containsKey(userinfo.getProfileId()) && lObj.Status != LeadTriggerVariableClass.pManaged){
                            uL.OwnerId=lRslrMap.get(lObj.PostalCode).NCR_Lead_Owner__c;
                        }
                        if(lObj.Status == LeadTriggerVariableClass.pManaged && resellerSwitchButton.ResellerSwitch__c){
                            lRNotList.add(lObj);
                            pMLead =false;
                        }else if(LeadOwnerNotificationSwitch.Lead_Owner_Swtich__c == true && pMapId.containsKey(userinfo.getProfileId())){
                            lRNotList.add(lObj);
                            pMLead =true;
                        }
                    }else if(lObj.Status == LeadTriggerVariableClass.pManaged){
                        lObj.addError(system.label.LeadEco5);
                    }
                    lUpdList.add(ul);
                }else{
                    if(lObj.Status == LeadTriggerVariableClass.pManaged){
                        lObj.addError(System.label.LeadEco6);
                    }
                }
            }
            if(!lUpdList.isEmpty()){
                update lUpdList;
            }
            if(!lRNotList.isEmpty() && pMLead!=true){
                initiateEmail(lRNotList, lRslrMap);
            }else if(pMLead &&!lRNotList.isEmpty()){
                leadOwnerNotify(lRNotList, lRslrMap);
            }
        }
    }
    public static void initiateEmail(List<Lead> lNtLd, Map<String,Reseller__c> lRMap){
        List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Notify Reseller'];
         
        for(Lead l : lNtLd){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
           message.setTargetObjectId(l.id); 
            message.setToAddresses(new String[] {
                //l.Reseller_email_1__c
                lRMap.get(l.PostalCode).ToEmail__c
                    });
            message.setSenderDisplayName(lRMap.get(l.PostalCode).ncr_lead_owner__r.Name); 
            if(lRMap.get(l.PostalCode).CCEmail__c!=null)
                message.setCcAddresses(lRMap.get(l.PostalCode).CCEmail__c.split(';'));
            message.setReplyTo(lRMap.get(l.PostalCode).ncr_lead_owner__r.email);
            message.setUseSignature(false); 
            message.setBccSender(false);
            message.setTreatTargetObjectAsRecipient(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(l.Id);
            mail.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mail);
    }
    public static void leadOwnerNotify(List<Lead> lNtLd, Map<String,Reseller__c> lRMap){
        //List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>();
        List<NCR_EmailMessage__c> emails = new List<NCR_EmailMessage__c>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Notify Lead Owner - Reseller'];
        
        for(Lead l : lNtLd){
            //Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'LeadOwnerNotification');
            Messaging.SingleEmailMessage rslt = Messaging.renderStoredEmailTemplate(emailTemplate.Id,null, l.Id);
            Set<id> pSId = new Set<ID>();
            for(Id pId : ResellerLeadOwnerConfig.split(',')){
                pSId.add(pId);
            }
            if(pSId.contains(userinfo.getProfileId())){
                /*message.setToAddresses(new String[] {
lRMap.get(l.PostalCode).NCR_Lead_Owner__r.Email
});*/
                ncrEmail.Recipient1__c =lRMap.get(l.PostalCode).NCR_Lead_Owner__r.Email ;  
                
            }else{
                
                if(l.OwnerId !=null){
                    /*message.setToAddresses(new String[] {
l.OwnerID
});*/
                    ncrEmail.Recipient1__c = l.Owner.Email;    
                }
            }
            String htmlBody = rslt.getHtmlBody(); 
            System.debug('htmlBody'+htmlBody);
            ncrEmail.Subject__c = rslt.getSubject();
            ncrEmail.HTML_Body__c = htmlBody;
            emails.add(ncrEmail);
            /*message.setTargetObjectId(l.id); 
message.setSenderDisplayName('Salesforce Admin');
message.setReplyTo('nsc.administration@ncr.com');
message.setUseSignature(false); 
message.setBccSender(false);
message.setTreatTargetObjectAsRecipient(false);
message.setSaveAsActivity(false);
message.setTemplateID(emailTemplate.Id); 
message.setWhatId(l.Id);
mail.add(message);*/
        }
        //Messaging.SendEmailResult[] results = Messaging.sendEmail(mail);
        if(!emails.isEmpty()){
            insert emails;
        }
    }
}