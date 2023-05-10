/*
##################################################################################################
# Class Name............................:ValuePrompterController.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public inherited sharing class ValuePrompterController {

    @AuraEnabled 
    public static Value_Prompter__c getOppValuePrompter(Id OppId) { 
       List<Value_Prompter__c> valProList = [SELECT Id,Name, Contact__c, Opportunity__c, Opportunity_Id__c, Business_Issue__c, VPQ_Score__c,  
                                                Anxiety_Question__c, Problem__c, Solution__c, Value__c, Power__c, Plan__c,
                                                Organizational_chart_Completed__c, Access_to_the_Power_Person__c, 
                                                Have_we_developed_an_eVP__c, Validatd_Power_Person_decsion_authority__c,
                                                Power_Person_has_access_to_funds_bdgt__c, Has_the_Business_Value_been_quantified__c,
                                                Has_a_cost_justification_been_completed__c, Do_prospect_agreed_potential_buss_value__c,
                                                Was_any_personal_value_uncovered__c, Understand_personal_value_of_dec_maker__c,
                                                Can_it_be_related_to_Revenue_or_Profit__c, Has_prspect_acknowledged_business_issue__c,
                                                Find_prob_make_this_issue_hard_to_solve__c, identified_prblm_that_only_we_can_solve__c,
                                                Is_prospect_req_any_unique_or_diff_sol__c, Has_Plan_confirmed_with_customer__c,
                                                Has_client_agreed_to_a_completion_date__c, Has_power_person_agreed_on_mutual_plan__c,
                                                Is_this_Plan_with_a_sponsor__c, Are_checkpnts_for_Decision_Maker_review__c, Approval_Process_Status__c,
                                                VisionMatch_Comments__c,Value_Comments__c,Plan_Comments__c,Power_Comments__c 
                                                FROM Value_Prompter__c 
                                                WHERE Opportunity__c = :OppId
                                                LIMIT 1];
       
        return((!valProList.isEmpty()) ? valProList.get(0) : null);  
    }
    
    @AuraEnabled 
    public static Value_Prompter__c saveValuePrompter(Value_Prompter__c valpro, String OppId)  {
        Value_Prompter__c vpClone;
        //System.debug(valpro); 
        
        if(valpro != null) {
            if(valpro.Opportunity__c == null) {
                valpro.Opportunity__c = OppId;  
            }  
            valpro.Opportunity_Id__c = valpro.Opportunity__c;
            
            vpClone = valpro; 
            if(String.isNotBlank(valpro.Id)) {
                vpClone = valpro.clone();                   
            } 
        }
        
        // upsert clone object clear Id
        upsert vpClone Opportunity_Id__c; 
        
        if(String.isNotBlank(vpClone.Id)) { 
            valpro.Id = vpClone.Id;
        }
        return valpro;       
    } 
    
    @AuraEnabled 
    public static String checkValuePrompterAccess(Id OppId, Id vpId) {
        //Set<Id> adminProfileIds = new Set<Id>{'00e700000013gPe', '00e70000000x3eg', '00e70000000sR8U'};
        Boolean valproaccess = false;
        Boolean editbtnaccess = false;
        if (Schema.sObjectType.Value_Prompter__c.isCreateable() && Schema.sObjectType.Value_Prompter__c.isUpdateable()) {
            valproaccess = true;
        }
        
        if(OppId != null)  {
            List<Opportunity> oppList = [SELECT Id, IsClosed From Opportunity WHERE Id = :OppId LIMIT 1];
            if ((!oppList.isEmpty())) {
                if (NSCCommonInfoUtil.getIdSetOf('adminProfileIds').contains(UserInfo.getProfileId())) editbtnaccess = true;
                else if (!oppList.get(0).IsClosed) editbtnaccess = true;
            } 
        }
        return('{"valproaccess":' + valproaccess + ',"editbtnaccess":' + editbtnaccess + '}');
    }
    
    @AuraEnabled 
    public static void emailMeValPrompter(Value_Prompter__c valpro) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        
        mail.setTemplateId([SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'Value_Prompter_Email_VF_Template'].get(0).Id); // email Template Id
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setWhatId(valpro.Id);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('NSC Administration');  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
    }
    
    @AuraEnabled
    public static void submitValPrmForApproval(Id vpId) {
        if (String.isNotBlank(vpId)) {
            List<Value_Prompter__c> vplist = [SELECT Id, Approval_Process_Status__c FROM Value_Prompter__c WHERE Id = :vpId LIMIT 1];
            
            if (!vplist.isEmpty()) {
                String approvalstatus = vplist.get(0).Approval_Process_Status__c;
                //system.debug('approvalstatus'+ approvalstatus);
                if (approvalstatus != 'Submitted') {
                     Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(vpId);
                
                    // Submit the approval request for the account
                    Approval.ProcessResult result = Approval.process(req1);
                    
                    // Verify the result
                    //System.debug(result.isSuccess());         
                }
                else {
                    throw new AuraHandledException('Value Prompter Record is already Submitted for Approval');      
                } 
                
              
            }
            
         
        }
    }
    
    @AuraEnabled
    public static void recallApprovalRequest(Id vpId) {
        if (String.isNotBlank(vpId)) {
            String sanitizedVPId =  String.escapeSingleQuotes(vpId);
            
            List<ProcessInstanceWorkitem> openApprovals = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :sanitizedVPId LIMIT 1];
            
            if(!openApprovals.isEmpty()) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Removed');        
                req.setWorkitemId(openApprovals.get(0).Id);
                Approval.process(req);
            }
        }
    }
   
}