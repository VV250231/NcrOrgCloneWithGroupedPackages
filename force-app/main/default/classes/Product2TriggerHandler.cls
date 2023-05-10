public class Product2TriggerHandler {
    
    public void SyncOLIKeyFields(map<Id, Product2> mpNewProduct, map<Id, Product2> mpOldProduct){
        final String CLOUD_REVENUE_TYPE = 'CLOUD';
        map<Id, Product2> mpChangedProduct = new map<Id, Product2>();
        Set<Id> subtoNonSubProdList = new Set<Id>(); 
        Set<Id> nonSubtoSubProdList = new Set<Id>(); 
        
        for(Id pId : mpNewProduct.keyset()) {
            if(mpNewProduct.get(pId).Service_Offer_Category__c != mpOldProduct.get(pId).Service_Offer_Category__c
               || mpNewProduct.get(pId).Product_Category__c != mpOldProduct.get(pId).Product_Category__c               
               || mpNewProduct.get(pId).Name != mpOldProduct.get(pId).Name){
                   if(!mpChangedProduct.containsKey(pId)){
                       mpChangedProduct.put(pId,mpNewProduct.get(pId));        
                   }
               }
            
            if (mpNewProduct.get(pId).Service_Offer_Category__c != mpOldProduct.get(pId).Service_Offer_Category__c) {
                // Old Cloud Product and New Non-Cloud with not available for subscription 
                if (String.isNotBlank(mpOldProduct.get(pId).Service_Offer_Category__c) && mpOldProduct.get(pId).Service_Offer_Category__c.toUpperCase() == CLOUD_REVENUE_TYPE && mpNewProduct.get(pId).Available_for_Subscription__c == false) {
                    subtoNonSubProdList.add(pId);   
                } // Old Non-Cloud Product with available for subscription = true/false and New Cloud Product
                else if (String.isNotBlank(mpNewProduct.get(pId).Service_Offer_Category__c) && mpNewProduct.get(pId).Service_Offer_Category__c.toUpperCase() == CLOUD_REVENUE_TYPE) {
                    nonSubtoSubProdList.add(pId);   
                }
            } else if(String.isBlank(mpNewProduct.get(pId).Service_Offer_Category__c) || mpNewProduct.get(pId).Service_Offer_Category__c.toUpperCase() != CLOUD_REVENUE_TYPE) {
                if (mpOldProduct.get(pId).Available_for_Subscription__c == true && mpNewProduct.get(pId).Available_for_Subscription__c == false){
                    subtoNonSubProdList.add(pId); 
                }   
            }
        }
        System.debug('inside trigger handler'+mpChangedProduct);
        if(mpChangedProduct.keyset().size()>0 || subtoNonSubProdList.size() > 0 || nonSubtoSubProdList.size() > 0 ){
            
            System.debug('inside trigger handler if'+mpChangedProduct);
            //system.enqueueJob(new SyncOLIKeyFields(mpChangedProduct));
            Database.executeBatch(new SyncOLIKeyFields(mpChangedProduct, subtoNonSubProdList, nonSubtoSubProdList),400);
            
        }
    }
    /*
####################################################################################################################                                                                                                                          
# File............................: AutoPopulateHierarchyFields                                                            
# Created by................: Mohd Ahad                                                                       
# Created Date...........: 26-07-2016                                                                                                                                                                
# Description...............: This is to auto populating marketing hierarchy fields on Opportunity Product from Product. 
####################################################################################################################
*/
    public void AutoPopulateHierarchyFields(List<Product2> newProducts){
        Map<id,String> MultipleListMap0 = new Map<id,string>();
        Map<id,String> MultipleListMap1 = new Map<id,string>();
        Map<id,String> MultipleListMap2 = new Map<id,string>();
        Map<id,String> MultipleListMap3 = new Map<id,string>();
        Map<id,String> MultipleListMap4 = new Map<id,string>();
        
        for (Product2 Pro : newProducts){
            
            if(!MultipleListMap0.ContainsKey(Pro.id))
            {
                MultipleListMap0.put(Pro.id,String.valueof(Pro.L0_Category__c)); 
                
            }
            if(!MultipleListMap1.ContainsKey(Pro.id))
            {
                MultipleListMap1.put(Pro.id,String.valueof(Pro.L1_Category__c)); 
                
            }
            if(!MultipleListMap2.ContainsKey(Pro.id))
            {
                MultipleListMap2.put(Pro.id,String.valueof(Pro.L2_Category__c)); 
                
            }
            if(!MultipleListMap3.ContainsKey(Pro.id))
            {
                MultipleListMap3.put(Pro.id,String.valueof(Pro.L3_Category__c)); 
                
            }
            if(!MultipleListMap4.ContainsKey(Pro.id))
            {
                MultipleListMap4.put(Pro.id,String.valueof(Pro.L4_Category__c)); 
                
            }
            
            
        }
        for(Product2 Pro : newProducts)
        {
            if(MultipleListMap0.get(Pro.id) !=null && String.isNotBlank(MultipleListMap0.get(Pro.id)) || 
               (MultipleListMap1.get(Pro.id)!=null && String.isNotBlank(MultipleListMap1.get(Pro.id))) || 
               (MultipleListMap2.get(Pro.id)!=null && String.isNotBlank(MultipleListMap2.get(Pro.id))) || 
               (MultipleListMap3.get(Pro.id)!=null && String.isNotBlank(MultipleListMap3.get(Pro.id))) ||
               (MultipleListMap4.get(Pro.id)!=null && String.isNotBlank(MultipleListMap4.get(Pro.id))))
                Pro.L0_Category_text__c=MultipleListMap0.get(Pro.id);
            pro.L1_Category_text__c=MultipleListMap1.get(Pro.id);
            pro.L2_Category_text__c=MultipleListMap2.get(Pro.id);
            pro.L3_Category_text__c=MultipleListMap3.get(Pro.id);
            pro.L4_Category_text__c=MultipleListMap4.get(Pro.id);
            
        }
        
    }
    /*
####################################################################################################################                                                                                                                          
# File............................: AutoUpdateMarketProductIdOnQRP.trigger                                                            
# Created by................: Akshun Singh                                                                       
# Created Date...........: 15-04-2018                                                                                                                                                                
# Description...............: This trigger change the value on QuoteRateplan(those are not send to z-billing) Primary Market Product Id if the earlier Id QPR is not a valid one upon the change on mention Product Ids on Product2. 
####################################################################################################################
*/
    public void AutoUpdateMarketProductIdOnQRP(List<Product2> newProductList,List<Product2> oldProductList,map<Id,Product2> oldMapProduct){
        //if(Recursionblocker.flag)
        {
            map<Id, Set<string>> productIdMapSetMarketId = new map<Id, Set<string>>();
            map<Id, string> productIdMapPrimaryMarketId = new map<Id, string>();
            system.debug('newProductList----'+newProductList+'--old--'+oldProductList);
            for(Product2 varProd : newProductList){
                system.debug('the size comes in new list : '+String.isBlank(varProd.MarketProductIds__c)+'---'+varProd.MarketProductIds__c+'----'+oldMapProduct.get(varProd.Id).MarketProductIds__c+'----'+varProd.Product_Type__c);
                if(!String.isBlank(varProd.MarketProductIds__c) && varProd.MarketProductIds__c != oldMapProduct.get(varProd.Id).MarketProductIds__c && varProd.Product_Type__c == 'Zuora Product'){
                    if(!productIdMapSetMarketId.containsKey(varProd.Id)){
                        system.debug('Inside 2');
                        Set<String> exisitingmarketProdId = new Set<String>();
                        list<String> listOfMarketProductId = new List<String>();
                        listOfMarketProductId = varProd.MarketProductIds__c.split(';');
                        if(!listOfMarketProductId.isEmpty()){
                            system.debug('Inside 3');
                            productIdMapPrimaryMarketId.put(varProd.Id, listOfMarketProductId.get(0));
                            exisitingmarketProdId.addAll(listOfMarketProductId);
                            productIdMapSetMarketId.put(varProd.Id, exisitingmarketProdId);
                        }
                    }
                }       
            }
            system.debug('the size of map set : '+ productIdMapSetMarketId.keySet());
            if(!productIdMapSetMarketId.isEmpty()){
                Database.executeBatch(new updateMarketProductonQRP(productIdMapSetMarketId, productIdMapPrimaryMarketId),900);
            }
            //Recursionblocker.flag = false;    
        }
    }
    
    public void ppltAltfySol(List<Product2> prdLst, Map<Id,Product2> oldPrdMap) {
        String TNT_STR=' T&T ';
        Set<String> altPrdTyps = new Set<String>(Label.Altfy_Prod_RecTypes.split(','));      
        List<Product2> PIDSIDPrdLst = new List<Product2>();
        
        for(Product2 p : prdLst) {
            if(!p.Name.contains(TNT_STR) && altPrdTyps.contains(p.Product_Type__c) 
                && (!oldPrdMap.isEmpty()) && p.Service_Offer_Category__c != oldPrdMap.get(p.Id).Service_Offer_Category__c
              	&& String.isNotBlank(p.Service_Offer_Category__c) && (!p.Service_Offer_Category__c.equalsIgnoreCase(System.Label.NtwrkSol_RevType))) {                 
            
                PIDSIDPrdLst.add(p);  
            }
        }
        
        if(!PIDSIDPrdLst.isEmpty()) {
            Map<String, String> rvTypSolMap = getRevTypeAndAltSolMap(); 
            for(Product2 p : PIDSIDPrdLst) {
               String sid = rvTypSolMap.get(p.Service_Offer_Category__c);
               if(String.isBlank(sid))                    
                   p.addError(Label.No_AltSol_fnd_Err);
               else 
                   p.ALTF__Solution__c = sid;
            }
        }
    }
    
    public Map<String, String> getRevTypeAndAltSolMap() {
        Map<String, String> solMap = new Map<String, String>();
        Map<String,String> rvTypVsSolMap = new Map<String,String>();
        
        List<Altify_Solution_Mapping__mdt> asmLst = Altify_Solution_Mapping__mdt.getAll().values();
        
        for(Altify_Solution_Mapping__mdt a : asmLst) {
            if(String.isNotBlank(a.Product_Revenue_Type__c) && String.isNotBlank(a.Label)) {
                rvTypVsSolMap.put(a.Product_Revenue_Type__c, a.Label);  
            }
        }
        
        List<ALTF__Solution__c> altSolLst = [SELECT Id, Name, ALTF__Active__c FROM ALTF__Solution__c WHERE ALTF__Solution_Family__c = 'Revenue Types'
                                             AND ALTF__Active__c = true];
        
        for(ALTF__Solution__c a : altSolLst) {
            solMap.put(a.Name, a.Id);   
        }
        
        for(String rvt : rvTypVsSolMap.keySet()) {
            String solId = solMap.get(rvTypVsSolMap.get(rvt));
            if(String.isNotBlank(solId))  {
                rvTypVsSolMap.put(rvt, solId);   
            }
        }
        return rvTypVsSolMap;
    }
    
    // Added By: Dharmendra
    // Modification Date: 29-JUN-2022
    // Related To: SFCPQBLG-669 Manage rates for Headline ACV/TCV calculation at global level
    public void cpqSyncQLIFields(map<Id, Product2> mpNewProduct, map<Id, Product2> mpOldProduct){
        map<Id, Product2> mpChangedProduct = new map<Id, Product2>();
        
        for(Id pId : mpNewProduct.keyset()) {
            if(mpNewProduct.get(pId).qtc_Interchange_Cost_Percentage__c != mpOldProduct.get(pId).qtc_Interchange_Cost_Percentage__c
               || mpNewProduct.get(pId).qtc_Blended_Rate_Percentage__c != mpOldProduct.get(pId).qtc_Blended_Rate_Percentage__c){
                   if(!mpChangedProduct.containsKey(pId)){
                       mpChangedProduct.put(pId,mpNewProduct.get(pId));        
                   }
               }
        }
        
        if(mpChangedProduct.keyset().size()>0){
            System.debug('inside Product2TriggerHandler.cpqSyncQLIFields '+mpChangedProduct);
            Database.executeBatch(new CPQSyncQLIFields(mpChangedProduct),400);
        }
    }
    
    
}