public class NonERPOrderTriggerDispatcher extends TriggerHandlerBase{
    /**** CLASS LEVEL VARIABLES *****************************************************/
    // map to store stage mapping "UpdateStage trigger" 
    private static NonERPOrderTriggerHandler ldHandler;
    /************************       TRIGGER CORE OPERATIONS      *******************/  
    // before insert will fire only once for inserting records
    
    
    public override void beforeInsert(){ 
        
        ldHandler = (ldHandler != null) ? ldHandler : new NonERPOrderTriggerHandler();
         
             ldHandler.ConvertLocaleAmoutToUsd(trigger.new);
       
        }
    
    public override void beforeUpdate() {
        
         ldHandler = (ldHandler != null) ? ldHandler : new NonERPOrderTriggerHandler();
                 
    }
    
}