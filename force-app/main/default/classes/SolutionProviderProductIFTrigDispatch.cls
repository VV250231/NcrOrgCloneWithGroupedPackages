public class SolutionProviderProductIFTrigDispatch extends TriggerHandlerBase {
	
    public override void afterInsert() {
        
        SolutionProviderProductIFTriggerHandler.HandleAfterInsert(Trigger.new); 
        
    }
    
    public override void afterUpdate() { 
        
        SolutionProviderProductIFTriggerHandler.HandleAfterUpdate(Trigger.new);
        
    }
}