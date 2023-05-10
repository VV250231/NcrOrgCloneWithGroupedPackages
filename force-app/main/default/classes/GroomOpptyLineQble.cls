public class GroomOpptyLineQble implements Queueable {
    List<Id> opptyLineIds;
      
    public GroomOpptyLineQble(){}
    public GroomOpptyLineQble(List<Id> opptyLineIds) {
   		this.opptyLineIds = opptyLineIds;   
    }
    
    /*
    @future
    public static void updatelineItem(List<Id> opptyLineIds) {
        SyncOLIKeyFields.RunSyncOli = false;
        List<Opportunitylineitem> opptyLines = [Select Id,Groomed__c from Opportunitylineitem WHERE Id IN :opptyLineIds];
        for(Opportunitylineitem opp: opptyLines) {
            opp.Groomed__c  ='Yes';
        }   
        try {
        update opptyLines;
        } catch(Exception e) { 
        	CDMUtil.addWait(500);    
            
             update opptyLines; 
        }
    } */
    
    
    public void execute(QueueableContext context) {
        SyncOLIKeyFields.RunSyncOli = false;
        List<Opportunitylineitem> updateOLIs = new List<Opportunitylineitem>();
        List<Opportunitylineitem> opptyLines = [Select Id, unitprice,quantity,TotalPrice, Total_Cost_Value__c,Total_Price_vs_TCV_diff__c,Opportunity.AccountId, OpportunityId from Opportunitylineitem WHERE Id IN :opptyLineIds];
        /*for(Opportunitylineitem oli: opptyLines) {
            //opp.Groomed__c  ='Yes';            
            oli.UnitPrice = oli.Total_Cost_Value__c / oli.Quantity;
        }*/  
        Set<Id> oppIdSet = new  Set<Id>();
         Set<Id> zoppIds = new Set<Id>();
        
        for(Opportunitylineitem oli : opptyLines) {
              oppIdSet.add(oli.OpportunityId);       
         }
        
         if(!oppIdSet.isEmpty()) {
              List<zqu__Quote__c> quoteLst = [select Id,zqu__Opportunity__c from zqu__Quote__c WHERE zqu__Opportunity__c  != null and zqu__Opportunity__c IN :oppIdSet];
              
                for(zqu__Quote__c q : quoteLst) {
                  zoppIds.add(q.zqu__Opportunity__c);   
                }
                
            }

        for(Opportunitylineitem oli : opptyLines) {
                if(!zoppIds.contains(oli.OpportunityId)) {
                    oli.Actual_Contract_Value__c = oli.TotalPrice;
                    oli.Total_Cost_Value__c = oli.TotalPrice;
                    updateOLIs.add(oli);
                }
                
                /*oli.UnitPrice = oli.Total_Cost_Value__c / oli.Quantity;*/
            }
        
        if(!updateOLIs.isEmpty() || Test.isRunningTest()) {
            TriggerHandlerBase.bypass('AccountTriggerDispatcher');
            TriggerHandlerBase.bypass('OpportunityTriggerDispatcher');
            TriggerHandlerBase.bypass('OpportunityLineItemTriggerDispatcher');
       
        	update updateOLIs;
        
            TriggerHandlerBase.clearBypass('AccountTriggerDispatcher');
            TriggerHandlerBase.clearBypass('OpportunityTriggerDispatcher');
            TriggerHandlerBase.clearBypass('OpportunityLineItemTriggerDispatcher');
        }
    }

}