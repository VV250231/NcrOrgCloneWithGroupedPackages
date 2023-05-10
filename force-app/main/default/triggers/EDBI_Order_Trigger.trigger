trigger EDBI_Order_Trigger on EDBI_Order__c (before insert, before update,After insert, After update) {
    if(Trigger.isInsert && Trigger.isbefore) 
    {
        EDBI_Order_Trigger_Handler.PopulateQuBYQuote(trigger.New,null);
        
    }
    
    if(Trigger.isUpdate && Trigger.isbefore) 
    {
        EDBI_Order_Trigger_Handler.PopulateQuBYQuote(trigger.New,trigger.oldMap);
        
        EDBI_Order_Trigger_Handler.PopulateAllQBOppNo(trigger.New,trigger.oldMap);
    } 
    
    if(Trigger.IsAfter && Trigger.IsInsert)
    {
        EDBI_Order_Trigger_Handler.SyncEDBIWithCADDIsInsertTrigger(trigger.new);
        
    }
    if(Trigger.IsAfter && Trigger.IsUpdate)
    {
        
        EDBI_Order_Trigger_Handler.SyncEDBIWithCADDIsUpdateTrigger(trigger.new,trigger.oldMap);
        
    }
}