public class PRM_TriggersController {
    public static Boolean getTriggersStatus(String triggerName){
        PRM_Triggers_Controller__mdt prmTriggers  = new PRM_Triggers_Controller__mdt();
        if(triggerName != null){
            prmTriggers = [SELECT Label, Is_Active__c  FROM PRM_Triggers_Controller__mdt WHERE Label =:triggerName LIMIT 1];
        }
        
        if(prmTriggers != null){
            Return prmTriggers.Is_Active__c; 
        }else{
            Return false;
        }
    }
}