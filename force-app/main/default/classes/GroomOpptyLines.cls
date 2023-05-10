public class GroomOpptyLines implements Database.Batchable<SObject>, Database.Stateful {
    Set<Id> lastAccids = new Set<Id>(); 
    String query= '';
    Boolean queueAbleGroom  = false;
   
    
    
 
    public GroomOpptyLines() {
        query = 'Select Id from Opportunitylineitem';    
        
      
    }
    
    /*
    public GroomOpptyLines(Boolean isAllGroom) {
        String yesValue = 'Yes';
        query = 'Select Id,Groomed__c from Opportunitylineitem WHERE createddate >= 2022-01-01  AND Groomed__c != :yesValue order by OpportunityId';       
    } */

    public GroomOpptyLines(String query, Boolean queueAbleGroom) {
        this.query = query; 
        this.queueAbleGroom = queueAbleGroom;  
    }
    
   public Database.queryLocator start(Database.BatchableContext bc) {
      return Database.getqueryLocator(query);
   } 
    
    public void execute(Database.BatchableContext bc, List<Opportunitylineitem> oppLines) {
        SyncOLIKeyFields.RunSyncOli = false;
        
        List<Opportunitylineitem> updateOLIs = new List<Opportunitylineitem>();
        List<Id> opptyLineIds = new List<Id>();
        Set<Id> accids = new Set<Id>(); 
   
        if(!this.queueAbleGroom) {
            Set<Id> oppIdSet = new  Set<Id>();
             Set<Id> zoppIds = new Set<Id>();
            
             for(Opportunitylineitem oli : oppLines) {
              oppIdSet.add(oli.OpportunityId);       
                 
             }
            
            if(!oppIdSet.isEmpty()) {
              List<zqu__Quote__c> quoteLst = [select Id,zqu__Opportunity__c from zqu__Quote__c WHERE zqu__Opportunity__c  != null and zqu__Opportunity__c IN :oppIdSet];
              
                for(zqu__Quote__c q : quoteLst) {
                  zoppIds.add(q.zqu__Opportunity__c);   
                }
                
            }
            
            
            for(Opportunitylineitem oli : oppLines) {
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
        } else {
            for(Opportunitylineitem oli : oppLines) {               
                if(!lastAccids.contains(oli.Opportunity.AccountId)) {
                    opptyLineIds.add(oli.Id);
                    accids.add(oli.Opportunity.AccountId);
                }
            }            
            
            if(!opptyLineIds.isEmpty()) {                
                lastAccids.clear();
                lastAccids.addAll(accids); 
                System.enqueueJob(new GroomOpptyLineQble(opptyLineIds));
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) { 
        
    }
}