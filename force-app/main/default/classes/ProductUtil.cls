public class ProductUtil {
    
     public void populateToplines(Map<String, List<Product2>> zPrdMap, Set<String> OPIDSet) {
       
      /*  if ((!zPrdMap.isEmpty()) && (!OPIDSet.isEmpty())) {
           Map<String, Product2> toplineMap = new Map<String, Product2>();
            
           for(Product2 topline : [SELECT Id, Name, Offer_Portfolio_Id__c FROM Product2
                                WHERE Product_Type__c = 'Topline'AND IsActive = true 
                                AND DataHubReferenceKey__c != null and Name IN :zPrdMap.keySet()
                                AND Offer_Portfolio_Id__c IN :OPIDSet]) {
               toplineMap.put(topline.Name, topline);
           }
           
           for (String toplineName : zPrdMap.keySet()) {
               List<Product2> zPrdList = zPrdMap.get(toplineName);
               Product2 topline = toplineMap.get(toplineName);
               
               if(topline != null) {
                   for(Product2 zPrd : zPrdList) {
                       if(topline.Name == zPrd.ToplineProduct__c && topline.Offer_Portfolio_Id__c == zPrd.OPID__c) {
                           zPrd.Topline_Product_Lkp__c = topline.Id;
                       }  else {
                            //zPrd.addError('No matching topline found for Product: ' + zPrd.Name);
                       } 
                   }    
               } else {
                   // adderror to zPrdList that no matching topline found;
               }                 
           }                         
        }*/
    } 
}