trigger UpdatePartnerMaturityLevel on Partner_Maturity_Level__c (before update, after update) {
    final String APPROVED_STATUS = 'Approved';
    final String REJECTED_STATUS = 'Rejected';
    final String INITIAL_MATURITY_LEVEL = 'LEVEL 0';
    final String MAX_MATURITY_LEVEL = 'ALL LEVEL COMPLETED';
    Partner_Maturity_Level__c pmLevel  ;
    if(Trigger.isAfter)  {
        if (Trigger.new.size() == 1) {
            for(Partner_Maturity_Level__c pml : Trigger.new){
			   pmLevel = pml;            
            }
            //Partner_Maturity_Level__c pmLevel = Trigger.new[0];
            Partner_Maturity_Level__c oldPMLevel = Trigger.oldMap.get(pmLevel.Id);
            
            if(pmLevel.Approval_Status__c != oldPMLevel.Approval_Status__c) {
                if((pmLevel.Account__c != null) && (pmLevel.Approval_Status__c == APPROVED_STATUS  ||  oldPMLevel.Approval_Status__c == APPROVED_STATUS )) {
                   String nextlevel = '';
                    
                    // query all levels from custom setting in asc order
                    List<AggregateResult> allMatLvls = [Select Level__c from PartnerMaturityLevelActions__c group by Level__c order by Level__c];
                    
                    // query all approved maturity levels in desc order
                    List<Partner_Maturity_Level__c> apprvdLvls = [SELECT Id, Account__c, Name FROM Partner_Maturity_Level__c WHERE Approval_Status__c = 'Approved' AND Account__c = :pmLevel.Account__c ORDER BY Name Desc LIMIT 1];
                    
                    if (!apprvdLvls.isEmpty()) { 
                        String hghAprvdLvl = apprvdLvls.get(0).Name;
                                     
                        for(integer i=0; i < (allMatLvls.size() -1); i++) {
                             String level = (String)allMatLvls[i].get('Level__c');  
                             
                            if (level == hghAprvdLvl) {
                                nextlevel =  (String)allMatLvls[i+1].get('Level__c');
                                break;                  
                            } 
                        }
                        
                        // assign max maturity level in case highest approved level not match with all levels-1 list
                        if (String.isBlank(nextlevel)) {
                             //nextlevel = (String) allMatLvls[allMatLvls.size() - 1].get('Level__c');
                             nextlevel = MAX_MATURITY_LEVEL;
                        }                      
                    } else { nextlevel = INITIAL_MATURITY_LEVEL; }
                    
                    // Account for update
                    Account accUpdate = new Account(Id = pmLevel.Account__c, Partner_Maturity_Level__c = nextlevel);
                    update accUpdate;
                }  
                
                if(pmLevel.Approval_Status__c != oldPMLevel.Approval_Status__c) {
                 if(pmLevel.Approval_Status__c == APPROVED_STATUS  || pmLevel.Approval_Status__c == REJECTED_STATUS) {
                        List<ProcessInstanceStep> processSteps = [SELECT ProcessInstanceId, StepStatus ,Comments FROM ProcessInstanceStep 
                                    WHERE ProcessInstance.TargetObjectId = :pmLevel.Id AND StepNodeId != null 
                                    AND (StepStatus = 'Approved' OR StepStatus = 'Rejected') ORDER BY CreatedDate DESC LIMIT 1];
                           
                        if(!processSteps.isEmpty()) {
                            Partner_Maturity_Level__c pmLevelUpdate = [SELECT Id, Approver_Comments__c FROM Partner_Maturity_Level__c  where Id = :pmLevel.Id LIMIT 1];
                            pmLevelUpdate.Approver_Comments__c = processSteps.get(0).Comments; 
                            update pmLevelUpdate;       
                        }   
                    }
                }
            }
           
        }
    
    }
    
    
}