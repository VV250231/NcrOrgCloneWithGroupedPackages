trigger SetQualifiedProspect on Value_Prompter__c (before insert, before update) {
    
    /**********************************************************************************************************
* Author        :   Vivek Kumar 
* Description   :   Update Commitment Risk on Opportunity based on 8 fields on Value_Prompter__c 
* ********************************************************************************************************/ 
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id, Opportunity> oppIdToOpportunityMap = new Map<Id, Opportunity>();
        
        for(Value_Prompter__c obj : Trigger.new){
            opportunityIdSet.add(obj.Opportunity__c);
        }
        
        for(Opportunity opp : [Select Id, Industry__c FROM Opportunity WHERE Id IN : opportunityIdSet AND Industry__c = 'Retail']){
            oppIdToOpportunityMap.put(opp.Id, opp);
        }
        
        for(Value_Prompter__c vp : Trigger.new){
            if(oppIdToOpportunityMap.containsKey(vp.Opportunity__c)){
                Decimal countTotalYes = 0;
                
                if(vp.Has_the_Business_Value_been_quantified__c && vp.Do_prospect_agreed_potential_buss_value__c){
                    countTotalYes += 1;
                }
                else if(vp.Has_the_Business_Value_been_quantified__c || vp.Do_prospect_agreed_potential_buss_value__c){
                    countTotalYes += 0.5;
                }
                if(vp.Has_Plan_confirmed_with_customer__c){
                    countTotalYes += 1;
                }
                if(vp.Access_to_the_Power_Person__c && vp.Have_we_developed_an_eVP__c){
                    countTotalYes += 1;
                }
                else if(vp.Access_to_the_Power_Person__c || vp.Have_we_developed_an_eVP__c){
                    countTotalYes += 0.5;
                }
                if(vp.Are_Top_Risk_Identify_if_they_Occur_CMR__c){
                    countTotalYes += 1;
                }
                if(vp.Can_it_be_related_to_Revenue_or_Profit__c && vp.Is_prospect_req_any_unique_or_diff_sol__c){
                    countTotalYes += 1;
                }
                else if(vp.Can_it_be_related_to_Revenue_or_Profit__c || vp.Is_prospect_req_any_unique_or_diff_sol__c){
                    countTotalYes += 0.5;
                }
                
                Opportunity opp = new Opportunity(Id = vp.Opportunity__c);
                opp.Commitment_Risk__c = (countTotalYes == 5 ? 'Green' : ((countTotalYes > 4 || countTotalYes == 4) ? 'Yellow' : (countTotalYes == 0 ? 'None' : 'Red' )));
                opp.Commitment_Risk_Score__c=countTotalYes;
                oppListToUpdate.add(opp);
            }
        }
        
        if(!oppListToUpdate.isEmpty())
            update oppListToUpdate;	
    }
    /*****************************************End Here******************************************************/
    
    
    if (Trigger.isInsert) {
        for(Value_Prompter__c vp : Trigger.new) {
            System.debug('vp : '+vp);
            vp.Opportunity_Id__c = vp.Opportunity__c;
        }       
    } 
    
    for(Value_Prompter__c vp : Trigger.new) {
        if (String.isNotBlank(vp.Business_Issue__c) && String.isNotBlank(vp.Problem__c) &&
            String.isNotBlank(vp.Solution__c) && String.isNotBlank(vp.Value__c) &&
            String.isNotBlank(vp.Power__c) && String.isNotBlank(vp.Plan__c)) {
                vp.Is_Qualified_Prospect__c = true;    
            } else {
                vp.Is_Qualified_Prospect__c = false; 
            } 
        
        Decimal totalYes =  (vp.Organizational_chart_Completed__c ? 1 : 0) +  (vp.Access_to_the_Power_Person__c ? 1 : 0)  
            + (vp.Have_we_developed_an_eVP__c ? 1 : 0) +  (vp.Validatd_Power_Person_decsion_authority__c ? 1 : 0) 
            + (vp.Power_Person_has_access_to_funds_bdgt__c ? 1 : 0) +  (vp.Has_the_Business_Value_been_quantified__c ? 1 : 0) 
            + (vp.Has_a_cost_justification_been_completed__c ? 1 : 0) +  (vp.Do_prospect_agreed_potential_buss_value__c? 1 : 0)  
            + (vp.Was_any_personal_value_uncovered__c ? 1 : 0) +  (vp.Understand_personal_value_of_dec_maker__c ? 1 : 0) 
            + (vp.Can_it_be_related_to_Revenue_or_Profit__c ? 1 : 0) +  (vp.Has_prspect_acknowledged_business_issue__c ? 1 : 0)
            + (vp.Find_prob_make_this_issue_hard_to_solve__c ? 1 : 0) +  (vp.identified_prblm_that_only_we_can_solve__c ? 1 : 0) 
            + (vp.Is_prospect_req_any_unique_or_diff_sol__c ? 1 : 0) +  (vp.Has_Plan_confirmed_with_customer__c ? 1 : 0)
            + (vp.Has_client_agreed_to_a_completion_date__c ? 1 : 0) +  (vp.Has_power_person_agreed_on_mutual_plan__c ? 1 : 0)
            + (vp.Is_this_Plan_with_a_sponsor__c ? 1 : 0) +  (vp.Are_checkpnts_for_Decision_Maker_review__c ? 1 : 0);
        vp.VPQ_Score__c = (totalYes/ Decimal.valueOf(20))* 100;
    }   
}