public class SolutionProviderContactTriggerDispatcher extends TriggerHandlerBase {
	
    public override void afterInsert() {
        
        SolutionProviderContactTriggerHandler.HandleAfterInsert(Trigger.new); 
        
    }
    
    public override void afterUpdate() { 
        
        SolutionProviderContactTriggerHandler.HandleAfterUpdate(Trigger.new);
        
    }
    
}