public class CPQERPOrderShipped implements Schedulable{
    
     private static final Integer maxTrackingCount = 20;
     private static final Integer maxCarrierCount = 10;
 
    public void execute(SchedulableContext SC) {
        try{
            
            doOrderShipped();
            
        }catch(Exception ex){
            
        }  
    }
    
     private static void doOrderShipped(){
        List<qtc_FulfillmentOrder__c> allFOrder;
        List<qtc_FulfillmentOrder__c> updatedFOrder = new List<qtc_FulfillmentOrder__c>();
        Set<Id> foIds = new Set<Id>();
        Map<Id, ERPTrackingInfo> mapifyERPInfo = null;
        try{
            
            allFOrder = [Select id,Order_Interface_Status__c,qtc_Tracking_Number__c,qtc_Carrier__c               
						from qtc_FulfillmentOrder__c where Order_Interface_Status__c = 'Order Booked' AND Shipping_Required__c = 0 
						ORDER BY LastModifiedDate
						LIMIT 20];
            
            if(allFOrder!=null && allFOrder.size()>0){
                
                for(qtc_FulfillmentOrder__c f:allFOrder){
                    
                     foIds.add(f.id);
                }
                mapifyERPInfo = getERPInformation(foIds);
                for(qtc_FulfillmentOrder__c f:allFOrder){
                    
                    f.Order_Interface_Status__c = 'Order Shipped';
                    if(mapifyERPInfo.containsKey(f.id)){
                        if(mapifyERPInfo.get(f.id).trackingNo.size() > 0){
                            f.qtc_Tracking_Number__c = getDetails(mapifyERPInfo.get(f.id).trackingNo);
                        }
                        if(mapifyERPInfo.get(f.id).carrier.size() > 0){
                            f.qtc_Carrier__c = getDetails(mapifyERPInfo.get(f.id).carrier);
                        }
                    }
                    updatedFOrder.add(f);
                }
                if(updatedFOrder.size()>0){
                    Update updatedFOrder;
                }
                
            }				 
        } catch(Exception ex){
            
        }
    }
    public static String getDetails(Set<String> details){
        Integer index = 0;
        String data = '';
        for(String str : details){
            if(index == 0) {
                data = str;
            }else{
                data = data + ',' +  str;
                
            }
            index = index +1;
        }
        return data;
        
    }
  public static Map<Id, ERPTrackingInfo> getERPInformation(Set<Id> foIds) {
      
        Map<Id, ERPTrackingInfo> mapifyERPInfo = new Map<Id, ERPTrackingInfo>();
      	      
        List<qtc_FulfillmentOrderProduct__c> foProducts = [SELECT id,qtc_Tracking_Number__c, 
                qtc_Carrier__c,qtc_FulfillmentOrder__r.id FROM qtc_FulfillmentOrderProduct__c
                WHERE qtc_FulfillmentOrder__r.id IN: foIds 
                AND (qtc_Tracking_Number__c != NULL OR qtc_Carrier__c != NULL)
                ORDER BY qtc_FulfillmentOrder__r.id 
               ];
      
      for(qtc_FulfillmentOrderProduct__c fo:foProducts){
          
          if(mapifyERPInfo.containsKey(fo.qtc_FulfillmentOrder__r.id)){
              if(mapifyERPInfo.get(fo.qtc_FulfillmentOrder__r.id).trackingNo.size() < maxTrackingCount){
                  mapifyERPInfo.get(fo.qtc_FulfillmentOrder__r.id).trackingNo.add(fo.qtc_Tracking_Number__c);
              }
              if(mapifyERPInfo.get(fo.qtc_FulfillmentOrder__r.id).carrier.size() < maxCarrierCount){
                  mapifyERPInfo.get(fo.qtc_FulfillmentOrder__r.id).carrier.add(fo.qtc_Carrier__c);
              }
           }else{
              mapifyERPInfo.put(fo.qtc_FulfillmentOrder__r.id,new ERPTrackingInfo());
              mapifyERPInfo.get(fo.qtc_FulfillmentOrder__r.id).trackingNo.add(fo.qtc_Tracking_Number__c);
              mapifyERPInfo.get(fo.qtc_FulfillmentOrder__r.id).carrier.add(fo.qtc_Carrier__c); 
          }
      }
      return mapifyERPInfo;
    }
    
    public class ERPTrackingInfo {
        Set<String> trackingNo = new Set<String>();
        Set<String> carrier = new Set<String>();
        
    }
}