public virtual class TriggerHandlerBase {
    
    // static map to bypass Object Trigger Handler
    private static Set<String> bypassedHandlers;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
    
    // boolean variable to control use of before and after old maps
    private static final Boolean useProcessOldMap = true;
    
    // beforeupdate and afterUpdate sObject records processedMap
    private static Map<Id, sObject> beforeUpdateProcessedMap;     
    private static Map<Id, sObject> afterUpdateProcessedMap;
    
    // static initialization
    static {
        bypassedHandlers = new Set<String>();
        beforeUpdateProcessedMap = new Map<Id, sObject>();      
        afterUpdateProcessedMap = new Map<Id, sObject>();
    }
    
    // constructor
    public TriggerHandlerBase() {
        this.setTriggerContext();
    }
    
    /***************************************
* public instance methods
***************************************/
    
    // main method that will be called during execution
    public void run() {
        
        if(!validateRun()) return;
        
        // dispatch to the correct handler method
        if(this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            Map<Id, sObject> tempMap;
            if(!getHandlerName().equalsIgnoreCase('OpportunityLineItemTriggerDispatcher')) {
                if(Trigger.newMap != null && Trigger.newMap.size() > 0) {
                    tempMap = Trigger.newMap.deepClone();
                }
            }
            
            this.beforeUpdate();
            
            if(!getHandlerName().equalsIgnoreCase('OpportunityLineItemTriggerDispatcher')) {
                if(tempMap != null && tempMap.size() > 0) {
                    this.addRecordstoBeforeUpdateMap(tempMap);
                }
            }
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            Map<Id, sObject> tempMap;
            if(!getHandlerName().equalsIgnoreCase('OpportunityLineItemTriggerDispatcher')) {
                if(Trigger.newMap != null && Trigger.newMap.size() > 0) {
                    tempMap = Trigger.newMap.deepClone();
                }
            }
            
            this.afterUpdate();
            
            if(!getHandlerName().equalsIgnoreCase('OpportunityLineItemTriggerDispatcher')) {
                if(tempMap != null && tempMap.size() > 0) {
                    this.addRecordstoAfterUpdateMap(tempMap);
                }
            }
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
        
    }
    
    /***************************************
* public static methods
***************************************/
    
    public static void bypass(String handlerName) {
        TriggerHandlerBase.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        TriggerHandlerBase.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandlerBase.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        TriggerHandlerBase.bypassedHandlers.clear();
    }
    
    /***************************************
* private instancemethods
***************************************/
    
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
        
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
           (ctx != null && ctx == 'before insert')) {
               this.context = TriggerContext.BEFORE_INSERT;
           } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                     (ctx != null && ctx == 'before update')){
                         this.context = TriggerContext.BEFORE_UPDATE;
                     } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                               (ctx != null && ctx == 'before delete')) {
                                   this.context = TriggerContext.BEFORE_DELETE;
                               } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                                         (ctx != null && ctx == 'after insert')) {
                                             this.context = TriggerContext.AFTER_INSERT;
                                         } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                                                   (ctx != null && ctx == 'after update')) {
                                                       this.context = TriggerContext.AFTER_UPDATE;
                                                   } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                                                             (ctx != null && ctx == 'after delete')) {
                                                                 this.context = TriggerContext.AFTER_DELETE;
                                                             } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                                                                       (ctx != null && ctx == 'after undelete')) {
                                                                           this.context = TriggerContext.AFTER_UNDELETE;
                                                                       }
    }
    
    
    
    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if(TriggerHandlerBase.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }
    
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /***************************************
* context methods
***************************************/
    
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement         
    }
    @TestVisible
    protected virtual void beforeUpdate(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    @TestVisible
    protected virtual void beforeDelete(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    @TestVisible
    protected virtual void afterInsert(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    @TestVisible
    protected virtual void afterUpdate(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    @TestVisible
    protected virtual void afterDelete(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    @TestVisible
    protected virtual void afterUndelete(){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    
    /***************************************
* inner classes
***************************************/
    
    @TestVisible
    public void addRecordstoBeforeUpdateMap(Map<Id, sObject> recordsMap) {
        beforeUpdateProcessedMap.putAll(recordsMap);   
    }
    
    @TestVisible
    public void addRecordstoAfterUpdateMap(Map<Id, sObject> recordsMap) {
        afterUpdateProcessedMap.putAll(recordsMap);   
    }
    
    @TestVisible
    public Map<Id, sObject> getOldBeforeUpdateMap(Set<Id> recordIds) {
        // check trigger context before update and after update
        Map<Id, sObject> oldRecordsMap = new Map<Id, sObject>();
        
        if(recordIds != null && recordIds.size() > 0) {
            if(useProcessOldMap) {
                for (Id recId : recordIds) {    
                    if(beforeUpdateProcessedMap.containsKey(recId)) {
                        oldRecordsMap.put(recId, beforeUpdateProcessedMap.get(recId)); 
                        
                    } else if(Trigger.oldMap.containsKey(recId)) {
                        oldRecordsMap.put(recId, Trigger.oldMap.get(recId));     
                    }
                }
            } else {
                for (Id recId : recordIds) { 
                    oldRecordsMap.put(recId, Trigger.oldMap.get(recId));     
                }
            }
        }       
        return oldRecordsMap; 
    }
    
    @TestVisible
    public Map<Id, sObject> getOldAfterUpdateMap(Set<Id> recordIds) {
        // check trigger context before update and after update
        Map<Id, sObject> oldRecordsMap = new Map<Id, sObject>();
        
        if(recordIds != null && recordIds.size() > 0) {
            if(useProcessOldMap) {
                for (Id recId : recordIds) {    
                    if(afterUpdateProcessedMap.containsKey(recId)) {
                        oldRecordsMap.put(recId, afterUpdateProcessedMap.get(recId)); 
                        
                    } else if(Trigger.oldMap.containsKey(recId)) {
                        oldRecordsMap.put(recId, Trigger.oldMap.get(recId));     
                    }
                }
            } else {
                for (Id recId : recordIds) { 
                    oldRecordsMap.put(recId, Trigger.oldMap.get(recId));     
                }
            }
        }       
        return oldRecordsMap; 
    }
    
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    // exception class
    public class TriggerHandlerException extends Exception {}
    
}