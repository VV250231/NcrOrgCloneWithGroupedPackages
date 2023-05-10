public class MaccChatHandler {
    public static void restrictPickListField(List<case> caseList){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();                       
        Set<id> caseIdsSet =new Set<id>();
        Map<id, case> newCaseMap = new Map<Id, Case>();
       String Lb = Label.MaccChat1;
        //Look for custom label MaccChat1 where lb is written in addError and error msg is Required Field
        for(Case caseObj : caseList){
            newCaseMap.put(caseObj.Id, caseObj);
        }
        for(Case caseObj : newCaseMap.values()){
            if(caseObj.RecordTypeId == CaseRecordTypeId){
                if(caseObj.Issue_Type__c == 'Error in Tool'){  
                    if(caseObj.Was_an_IT_ticket_created_to_report_the_e__c == 'Yes'){
                        if(caseObj.Ticket__c == null){
                            newCaseMap.get(caseObj.Id).Ticket__c.addError(Lb);   
                        }
                    }
                    if(caseObj.Was_there_a_specific_error_message__c == null){
                        newCaseMap.get(caseObj.Id).Was_there_a_specific_error_message__c.addError(Lb);
                    }
                    if(caseObj.Which_page_is_the_user_seeing_error__c == null){
                        newCaseMap.get(caseObj.Id).Which_page_is_the_user_seeing_error__c.addError(Lb);
                    }
                    if(caseObj.Were_you_able_to_replicate_the_error__c == null){
                        newCaseMap.get(caseObj.Id).Were_you_able_to_replicate_the_error__c.addError(Lb);
                        
                    }
                    if(caseObj.Was_an_IT_ticket_created_to_report_the_e__c == null){
                        newCaseMap.get(caseObj.Id).Was_an_IT_ticket_created_to_report_the_e__c.addError(Lb);   
                    }
                }
                if(caseObj.Was_there_a_specific_error_message__c =='Yes'){
                    if(caseObj.Input_The_Error_Message__c == null){
                        newCaseMap.get(caseObj.Id).Input_The_Error_Message__c.addError(system.label.MaccChat2);
                    }
                    //Error msg for custom label MaccChat2
                    //Please input the error message
                }
                
                if(caseObj.Issue_Type__c == 'Knowledge/Training'){
                    if(caseObj.What_type_of_assistance_was_provided__c == null){
                        newCaseMap.get(caseObj.Id).What_type_of_assistance_was_provided__c.addError(Lb);
                    }
                    /*if(caseObj.Which_page_is_the_user_seeing_error__c == null){
                        newCaseMap.get(caseObj.Id).Which_page_is_the_user_seeing_error__c.addError('Required Field');
                    } */ 
                }
                if(caseObj.What_type_of_assistance_was_provided__c == 'Provided Knowledge Article'){
                    caseObj.Was_there_an_existing_knowledge_article__c ='Yes';
                    if(caseObj.Were_you_able_to_resolve_the_the_user_s__c == null){
                        newCaseMap.get(caseObj.Id).Were_you_able_to_resolve_the_the_user_s__c.addError(Lb);
                    }
                   
                }
                if(caseObj.Issue_Type__c == 'Unresolved/Unworkable'){
                    if(caseObj.Please_choose_a_reason__c == null){
                        newCaseMap.get(caseObj.Id).Issue_Type__c.addError(system.label.MaccChat3);
                       newCaseMap.get(caseObj.Id).Please_choose_a_reason__c.addError(Lb);
                    }
                    //Error msg for custom label MaccChat3
                   //Please choose a reason if Issue Type is Unresolved/Unworkable 
                }
            }
        }
    }
    public static void sendEmailNotificationToAgentManager(List<case> caseList){
        Set<Id> caseOwnerIds = new Set<Id>();
        Map<Id,Case> caseMap = new Map<Id, Case>();
        Map<Id, User> userMap = new Map<Id, User>();
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();                       
        for(Case caseObj : caseList){
            caseOwnerIds.add(caseObj.OwnerId);
            caseMap.put(caseObj.Id, caseObj);
        }
        for(User userObj : [SELECT ManagerId,User.Name,Manager.Name,Manager.Email From User Where Id In:caseOwnerIds]){
            userMap.put(userObj.Id, userObj);
        }
          
        for(case caseObj : caseMap.Values()){
            if(caseObj.RecordTypeId == CaseRecordTypeId){
                if(caseObj.Issue_Type__c == 'Error in Tool' && caseObj.Was_an_IT_ticket_created_to_report_the_e__c == 'Yes'
                   && caseObj.Ticket__c != null && caseObj.Status =='Closed'){  
                       Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                       String[] sendingTo = new String[]{userMap.get(caseObj.OwnerId).Manager.Email};
                   //  String[] sendingTo = new String[]{'AA185339@ncr.com'};
                           message.setToAddresses(sendingTo);			
                       //  message.setInReplyTo('NI230017@ncr.com');
                       message.setSenderDisplayName('NSC Admin');
                       message.optOutPolicy = 'FILTER';
                       message.subject = 'MACC Live Chat Cases Notification';            
                       String body;
                       body = 'Hi ' +usermap.get(caseObj.OwnerId).Manager.Name+', <br/><br/>';
                       body += 'Please note that Case # '+caseMap.get(caseObj.Id).CaseNumber+ ' indicated an IT Ticket was necessary and IT Ticket # '+caseMap.get(caseObj.Id).Ticket__c+' was generated. Please review for follow up.<br/><br/>';            
                   //    body +=' <br/><br/>';
                       body += '<br/>Please take necessary action on these Case(s).<br/><br> Thanks,<br/>NCR Corporation';
                       System.debug('Messgae '+message);
                       message.htmlbody = body;
                       
                       Messaging.SingleEmailMessage[] messages = 
                           new List<Messaging.SingleEmailMessage> {message};
                               Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                       if (results[0].success) {
                           System.debug('The email was sent successfully.');
                       } else {
                           System.debug('The email failed to send: '
                                        + results[0].errors[0].message);
                       }
                   }
            }
        }        
    }
}