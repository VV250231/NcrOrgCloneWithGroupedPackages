public class Product2TriggerDispatcher extends TriggerHandlerBase{
    private static Product2TriggerHandler prodHandler;
    
    /************************************** PRODUCT BEFORE INSERT *************************************
      * Description : 1. This is to auto populating marketing hierarchy fields on Opportunity Product from Product. 
                         
      *************************************************************************************************/
    public override void beforeInsert() {
         prodHandler = (prodHandler != null) ? prodHandler : new Product2TriggerHandler();
         prodHandler.AutoPopulateHierarchyFields((List<Product2>) Trigger.new);
    }
    /************************************** PRODUCT BEFORE UPDATE *************************************
      * Description : 1. This is to auto populating marketing hierarchy fields on Opportunity Product from Product. 
                      2. Change the value on QuoteRateplan   
      *************************************************************************************************/
    public override void beforeUpdate() {
         prodHandler = (prodHandler != null) ? prodHandler : new Product2TriggerHandler();
        
         Map < Id, sObject > oldBeoreUpdateMap = this.getOldBeforeUpdateMap(Trigger.newMap.keySet());
         map<Id,  Product2> oldMapProduct = new Map < Id, Product2 > ();
         
        for (Id Pid: oldBeoreUpdateMap.keyset()) {
            oldMapProduct.put(Pid, (Product2) oldBeoreUpdateMap.get(Pid));
        }
         //auto populating marketing hierarchy fields on Opportunity
         prodHandler.AutoPopulateHierarchyFields((List<Product2>) Trigger.new);
         //populate Altify solution on Product
         prodHandler.ppltAltfySol((List<Product2>) Trigger.new, oldMapProduct);
         //Change the value on QuoteRateplan   
         prodHandler.AutoUpdateMarketProductIdOnQRP((List<Product2>) Trigger.new,(List<Product2>) Trigger.old,oldMapProduct);
    }
    /************************************** PRODUCT AFTER UPDATE *************************************
      * Description : 1. When key field changes then update OLI 
                         
      *************************************************************************************************/
    public override void afterUpdate() {
          prodHandler = (prodHandler != null) ? prodHandler : new Product2TriggerHandler();
        
           map<Id, Product2> mpOldProduct = new map<Id, Product2>();
           map<Id, Product2> mpNewProduct = new map<Id, Product2>();
           
           
           for(Product2 prod :(List<Product2>) Trigger.new){
              mpNewProduct.put(prod.id, prod);  
           }
         
           Map < Id, sObject > recOldMap = this.getOldAfterUpdateMap(Trigger.newMap.keySet());
           for (Id pId: recOldMap.keyset()) {
             mpOldProduct.put(pId, (Product2) recOldMap.get(pId));
          }
        System.debug('inside trigger'+mpNewProduct);
        prodHandler.SyncOLIKeyFields(mpNewProduct,mpOldProduct);
        // CPQ team Added, 29-JUN-2022, by Dharmendra
        // commented Dharmendra due to Prformace issue in Production
        prodHandler.cpqSyncQLIFields(mpNewProduct,mpOldProduct);
    }
}