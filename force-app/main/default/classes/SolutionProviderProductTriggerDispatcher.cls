public class SolutionProviderProductTriggerDispatcher extends TriggerHandlerBase {

    public override void afterInsert() {
        
        SolutionProviderProductTriggerHandler.HandleAfterInsert(Trigger.new); 
        
    }
    
    public override void afterUpdate() { 
        
        SolutionProviderProductTriggerHandler.HandleAfterUpdate(Trigger.new);
        
    }
}