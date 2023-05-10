/****************************************************************************************************************
* Author        :   Ajay Dixit    
* Description   :   
1- Synchronizes Opportunity Products and schedules
Modification Log:
1.0   11-13-2021   Puneet Bhatia      calling SyncOli quueable to sync data in oppty product and prod scheule custom objects    
****************************************************************************************************************/
public class OpportunityLineItemTriggerDispatcher extends TriggerHandlerBase {
    /************************       TRIGGER CORE OPERATIONS      *******************/  
    // before insert will fire only once for inserting records
    private Static Boolean doNotSync=false, runSyncOLI = false;
    public Static Boolean runTrigger=false;
    public static List<OpportunityLineItem> syncOLILst = new List<OpportunityLineItem>();
        
    public override void beforeInsert() {
        new MarketProductHelper().ppltMrktPrdBfrInsrt((List<OpportunityLineItem>)trigger.new);
        doNotSync  = true;
    }
    
    // after insert will fire only once for after records inserted
    public override void afterInsert() {
       CheckRecursive.setAutoPOSValue = true;
       doNotSync  = true;
        
       // sync data in oppty product and prod scheule custom objects 
       if((!System.isQueueable() || (System.isQueueable() && Limits.getQueueableJobs()==0))) {  
           syncOLILst.addAll((List<OpportunityLineItem>)Trigger.new);
           if(!runSyncOLI) {
               runSyncOLI = true;
               system.enqueueJob(new SyncOli(syncOLILst));
           }
       }
    }
    
    public override void beforeUpdate() {
        if (!doNotSync || test.isRunningTest()) {
            new MarketProductHelper().ppltMrktPrdBfrUpdt((List<OpportunityLineItem>)trigger.new,(Map<Id,OpportunityLineItem>) trigger.oldMap);
        }
    }
    
    // before Update will fire only once for updated records
    public override void afterUpdate() {
         CheckRecursive.setAutoPOSValue = true;
         doNotSync  = true;
        
		// sync data in oppty product and prod scheule custom objects 	
        if(SyncOLIKeyFields.RunSyncOli && (!System.isQueueable() || (System.isQueueable() && Limits.getQueueableJobs()==0))) {
           syncOLILst.addAll((List<OpportunityLineItem>)Trigger.new);
           if(!runSyncOLI) {
               runSyncOLI = true;
               system.enqueueJob(new SyncOli(syncOLILst));
           }
        }

    }
    //Code Added By Pankaj Kashyap
    
    // before Update will fire only once for updated records
    public override void afterDelete() {
         CheckRecursive.setAutoPOSValue = true;
        
        // sync data in oppty product and prod scheule custom objects 
        if(SyncOLIKeyFields.RunSyncOli && (!System.isQueueable() || (System.isQueueable() && Limits.getQueueableJobs()==0))) {
           syncOLILst.addAll((List<OpportunityLineItem>)Trigger.old);
           if(!runSyncOLI) {
               runSyncOLI = true;
               system.enqueueJob(new SyncOli(syncOLILst));
           }
        }
    } 
}