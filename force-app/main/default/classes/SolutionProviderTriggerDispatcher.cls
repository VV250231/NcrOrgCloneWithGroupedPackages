public class SolutionProviderTriggerDispatcher extends TriggerHandlerBase {

    public override void afterInsert() {
        
        SolutionProviderTriggerHandler.HandleAfterInsert(Trigger.new); 
        
    }
    
    public override void afterUpdate() { 
        
        SolutionProviderTriggerHandler.HandleAfterUpdate(Trigger.new);
        
    }
}