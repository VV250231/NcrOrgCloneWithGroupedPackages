/*
################################################################################################## 
Apex Class Name    : FavoriteController
Modification Log:
Date             Author               Modification
01-20-2022       Puneet Bhatia        EBA_SF-1646 - Added changes for Connected HWM in Salesforce
################################################################################################
*/
public class AddProductToBundleController {
    
    @AuraEnabled
    Public Static List<User_Favorite_Products__c> AddProductToBundleMethod(String PrdList,String BndlList)
    {
        
        List<User_Favorite_Products__c> ListOfBundle=new List<User_Favorite_Products__c>();
         //system.debug(':::::::::::'+PrdList);
         //system.debug(':":":":":":":'+BndlList);
        try{
            List<BundleWrapper> Bundlelst_JsonParse = (List<BundleWrapper>)Json.deserialize(BndlList,List<BundleWrapper>.class);
            List<ProductWrapper> Productlst_JsonParse = (List<ProductWrapper>)Json.deserialize(PrdList,List<ProductWrapper>.class);
            
            for(BundleWrapper   obj1 : Bundlelst_JsonParse){
                if(obj1.Status){ 
                    for(ProductWrapper obj2 : Productlst_JsonParse){
                        if(obj2.Status){
                            User_Favorite_Products__c UserFavProductObj = new User_Favorite_Products__c();
                            UserFavProductObj.Products__c=obj2.Id;
                            //system.debug('>>>>>>'+obj2.Status);
                            UserFavProductObj.Favorite_Bundle__c=obj1.Id;
                           //UserFavProductObj.User__c=UserInfo.getUserId();
                            if(obj2.isSubricption != null){
                                 UserFavProductObj.IsSubscription__c=obj2.isSubricption;
                            }
                            if(String.isNotBlank(obj2.LineItemType)){
                                UserFavProductObj.LineItemType__c=obj2.LineItemType;
                            }
                            if(String.isNotBlank(obj2.HWMMntcType)){
                           		UserFavProductObj.Maintenance_Type__c=obj2.HWMMntcType;
                            }
                            if(String.isNotBlank(obj2.qtyType)){
                           		UserFavProductObj.Qty_Type__c=obj2.qtyType;
                            }
                            
                           
                           ListOfBundle.add(UserFavProductObj);
                        }
                         
                	}
                }   
                
            }
           
           Insert ListOfBundle;
           
           
        }
           
        
        
        catch(Exception e){
            system.debug('>>>>'+e);
        }
        return ListOfBundle;
    }
    public class BundleWrapper {
        public String Id;
        public Boolean Status;
    }
    
    public class ProductWrapper{
        public String Id;
        public Boolean Status;
        Public Boolean isSubricption;
        pUBLIC String LineItemType;
        public String HWMMntcType;
        public String qtyType;
    }
    
    @AuraEnabled
    Public Static String UpdateBundleName(String BundleIdForUpdate ,String UpdatedBundleName){
        //system.debug('BundleIdForUpdate'+BundleIdForUpdate);
        //system.debug('BundleIdForUpdate'+UpdatedBundleName);
        String UpdateStatus='';
        try{
            Favorite_Bundle__c FavObj =  new Favorite_Bundle__c();
            FavObj.id=BundleIdForUpdate;
            FavObj.Name= UpdatedBundleName;
            Update FavObj;
            UpdateStatus = UpdateStatus+'Success' + FavObj.Name;
        }
        catch (Exception e) {

            UpdateStatus=UpdateStatus+e;
        }
        return UpdateStatus;
    }
    
    @AuraEnabled
    public static ProductInfoWrapper getRnwableProds(){     
        Set<String> SubsProdSet= new Set<String>(); 
        Set<String> SubsRevenueSet= new Set<String>();
        Set<String> RnwablRevnSet= new Set<String>();
        Map<String, String> lineItemTypeOpts = new Map<String, String>();
        
        ProductInfoWrapper prodInfoWrapObj= new ProductInfoWrapper();
        List<Renewable_Products__c> renewablePrdLst = Renewable_Products__c.getAll().values();        
        
        if (renewablePrdLst != NULL && renewablePrdLst.size() > 0) {
            if (String.isNotBlank(renewablePrdLst[0].Product_Revenue_Types__c)) { 
                RnwablRevnSet.addAll(renewablePrdLst[0].Product_Revenue_Types__c.split(','));
                prodInfoWrapObj.RnwablRevTypes = RnwablRevnSet;
            }
        }
        
        for(Schema.PicklistEntry p : OpportunityLineItem.Opportunity_Line_Item_Type__c.getDescribe().getPicklistValues()) {
            lineItemTypeOpts.put(p.getValue(), p.getLabel());
        } 
        prodInfoWrapObj.OppLineItemTypes = lineItemTypeOpts;
        
        return prodInfoWrapObj;
    }

    public class ProductInfoWrapper { 
        @AuraEnabled public Set<String> RnwablRevTypes{get;set;}
        @AuraEnabled public Map<String, String> OppLineItemTypes{get;set;}
    }
}