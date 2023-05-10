/* trigger of the BPM_Annuity__c object which used to set some predefined values in notification attempt automatically
	trigger for creating default PO and CA automatically on a new customer coming in contract using PO and CA Matrix object resp(logic written in BPM_APOCPORelation)
	it also covers functionality for creating BPM Contract aging history(logic written in BPMNotifyActionOwner class)
*/
//Test class name - BPM_Alert_Aging_HistoryTest
trigger BPM_Alert_Aging_History on BPM_Annuity__c (before insert,after insert,before update,after update) {
    Set<Id> bpmIdSet = new Set<Id>();
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            List<String> pcklstL= new List<String>();
            for( Schema.PicklistEntry val : BPM_Annuity__c.hold_reason_type__c.getDescribe().getPicklistValues()){
                pcklstL.add(val.getLabel());
            }     
            for(BPM_Annuity__c bpm : Trigger.new){
                if((Trigger.oldMap.get(bpm.id).BPMWorkflowCriteriaForHoldReason__c != bpm.BPMWorkflowCriteriaForHoldReason__c || Trigger.oldMap.get(bpm.id).Hold_Reason_Type__c != bpm.Hold_Reason_Type__c) && bpm.BPMWorkflowCriteriaForHoldReason__c){
                    if(BPM_Configuration__c.getValues('Stop Immediate Notification').values__c=='false'){
                        bpm.Email_Sent__c = true;
                    }
                    bpm.Contract_On_Hold__c = false;
                    if(pcklstL.contains(bpm.Hold_Reason_Type__c)){
                    	bpm.Notification_Attempt__c = 0;
                    }else{
                        bpm.Notification_Attempt__c = -1;
                    }
                    //bpm.Alert_Next_Date_Time__c = System.now();
                }
                if(bpm.SendAdhocMail__c&&bpm.BPMWorkflowCriteriaForHoldReason__c){
                    if(bpm.Notification_Attempt__c <=0){
                        if(pcklstL.contains(bpm.Hold_Reason_Type__c)){
                            bpm.Notification_Attempt__c = 0;
                        }else{
                       		bpm.Notification_Attempt__c = -1; 
                        }
                    }
                    else{
                    	bpm.Notification_Attempt__c = bpm.Notification_Attempt__c-1;
                    }
                    bpm.Contract_On_Hold__c = false;
                    bpmIdSet.add(bpm.Id);
                }
                if(!bpm.Contract_On_Hold__c||!bpm.BPMWorkflowCriteriaForHoldReason__c){
                    bpm.Alert_Next_Date_Time__c = null;
                    bpm.Contract_On_Hold__c = false;
                }               
            }
            if(!bpmIdSet.isEmpty()){
                Database.executeBatch(new BPMNotifyActionOwnerBatch(bpmIdSet));
            }
        }
    }
    else{
        if(Trigger.isInsert){
            BPMAPOC_PORelation.assignPOToAccountFromTrigger(JSON.serialize(Trigger.new));
        }
        if(Trigger.isUpdate){
            List<BPM_Annuity__c> bpmCustChngL = new List<BPM_Annuity__c>();
            List<BPM_Annuity__c> bpmAgingRec = new List<BPM_Annuity__c>();
            List<String> oldHldRsnL = new List<String>();
            Set<ID> bpmIdS = new Set<Id>();
            for(BPM_Annuity__c bpm : Trigger.new){
                BPM_Annuity__c oldRec = Trigger.oldMap.get(bpm.id);
                if(oldRec.BPMWorkflowCriteriaForHoldReason__c != bpm.BPMWorkflowCriteriaForHoldReason__c||oldRec.Hold_Reason_Type__c!= bpm.Hold_Reason_Type__c){
                    if(oldRec.Hold_Reason_Type__c!= bpm.Hold_Reason_Type__c&&bpm.BPMWorkflowCriteriaForHoldReason__c){
                        bpmAgingRec.add(bpm);
                        if(oldRec.Hold_Reason_Type__c!=null){
                            oldHldRsnL.add(oldRec.Hold_Reason_Type__c); 
                            bpmIdS.add(bpm.id);
                        }
                    }
                    else if(bpm.BPMWorkflowCriteriaForHoldReason__c){
                        bpmAgingRec.add(bpm);
                    }
                    else{
                        oldHldRsnL.add(oldRec.Hold_Reason_Type__c); 
                        bpmIdS.add(bpm.id);
                    } 
                }
                if(oldRec.Cust_Nbr_CH__c != bpm.Cust_Nbr_CH__c){
                    bpmCustChngL.add(bpm); 
                }
            }
            if(!bpmAgingRec.isEmpty()||!oldHldRsnL.isEmpty()){
                if(BPMNotifyActionOwner.isFirst){
                    BPMNotifyActionOwner.isFirst = false;
                    BPMNotifyActionOwner.createAgingHistory(bpmAgingRec, oldHldRsnL, bpmIdS);
                }
            }
            if(!bpmCustChngL.isempty()){
                BPMAPOC_PORelation.assignPOToAccountFromTrigger(JSON.serialize(bpmCustChngL));
            }
        }
    }
}