/*
################################################################################################## 
Apex Class Name    : FavoriteController
Modification Log:
Date             Author               Modification
01-20-2022       Puneet Bhatia        EBA_SF-1646 - Added changes for Connected HWM in Salesforce
25-05-2022       Stuti Srivastava     EBA_SF-2059 - Changes related to Cardtronics
05-08-2022       Stuti Srivastava	  EBA_SF-2206
################################################################################################
*/
Public class TableContainerClass{
       @AuraEnabled
       public static List<ProductBundleWrapper> GetUserFavBundle_Product(String OppId) {
       list<ProductBundleWrapper> BundleProductlist= new List<ProductBundleWrapper>();
       list<ProductBundleWrapper> BundleProductlistSort= new List<ProductBundleWrapper>();
       set<Id> bundleIds = new set<Id>();
           for(User_Favorite_Products__c FavObj : [Select Id,Name,Bundle__c from User_Favorite_Products__c where Bundle__c != null AND User__c=:UserInfo.getUserId() ORDER BY Name ASC]){
               bundleIds.add(FavObj.Bundle__c);
               system.debug('bundleIds'+bundleIds);
           }    
       Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId]; //EBA 2059 BY Stuti
           String originalProduct;
           List<Favorite_Bundle__c> favBundList=new List<Favorite_Bundle__c>();
           if(o.CATM_Record__c == True){
               favBundList = [Select id,name,(Select id,name,Quantity__c,UnitPrice__c,Products__c,Products__r.IsActive,Products__r.Name,LineItemType__c,IsSubscription__c from User_Favorite_Products__r where Products__r.IsActive = true and Products__r.OriginalCorporation__c='Cardtronics')from Favorite_Bundle__c where ownerid=:UserInfo.getUserId() ORDER BY NAME ASC];
           }
           else{
               favBundList = [Select id,name,(Select id,name,Quantity__c,UnitPrice__c,Products__c,Products__r.IsActive,Products__r.Name,LineItemType__c,IsSubscription__c from User_Favorite_Products__r where Products__r.IsActive = true and Products__r.OriginalCorporation__c!='Cardtronics')from Favorite_Bundle__c where ownerid=:UserInfo.getUserId() ORDER BY NAME ASC];
           }
  
       for(Favorite_Bundle__c obj : favBundList)
       {
           list<ProductListWrapper> BundleRelatedProduct = new List<ProductListWrapper>();
           ProductBundleWrapper WrapperObj = new ProductBundleWrapper();
           
           WrapperObj.IsSelected= false;
           WrapperObj.Name=obj.Name;
           WrapperObj.Id=obj.Id;
           if(bundleIds.contains(obj.Id)){
               WrapperObj.isFav=true;
           }
            
           
           //WrapperObj.ProductList=obj.User_Favorite_Products__r; 
           WrapperObj.ProductList = new  List<ProductListWrapper>();
           for(User_Favorite_Products__c userObj : obj.User_Favorite_Products__r){
               ProductListWrapper WrapperProductObj = new ProductListWrapper();
               WrapperProductObj.ProductId=userObj.id;
               WrapperProductObj.PrdId=userObj.Products__c;
               WrapperProductObj.ProductName=userObj.Products__r.Name;
               WrapperProductObj.IsProductSelected=false;
               WrapperProductObj.UnitPrice=userObj.UnitPrice__c; 
               WrapperProductObj.Quantity=userObj.Quantity__c;
              // WrapperProductObj.IsAvailableforSubscription=userObj.Products__r.Available_for_Subscription__c;
               WrapperProductObj.IsActive=userObj.Products__r.IsActive;
               WrapperProductObj.LineItemType=userObj.LineItemType__c;
               WrapperProductObj.IsSubscription=userObj.IsSubscription__c;
               //BundleRelatedProduct.add(WrapperProductObj); 
                 WrapperObj.ProductList.add(WrapperProductObj); 
               
           }
           
             
           BundleProductlist.add(WrapperObj);
           
       }
           
         for(Integer i =0;i<BundleProductlist.size();i++){
           if(BundleProductlist[i].isFav == true){
               BundleProductlistSort.add(BundleProductlist[i]);
               //BundleProductlist.remove(i);
           }
       } 
        for(Integer i =0;i<BundleProductlist.size();i++){
           if(BundleProductlist[i].isFav == false){
               BundleProductlistSort.add(BundleProductlist[i]);
               //BundleProductlist.remove(i);
           }
       }   
           
    return  BundleProductlistSort;
    
   }
    
    public class ProductBundleWrapper{
         @AuraEnabled
         public Boolean IsSelected;
         @AuraEnabled
         public String Name;
         @AuraEnabled
         public String Id;
         @AuraEnabled
         public Boolean isFav= false;
         @AuraEnabled 
         public List<ProductListWrapper> ProductList;
         
    }
    
    public class ProductListWrapper{
         @AuraEnabled
         public Boolean IsProductSelected;
         @AuraEnabled
         public String ProductName;
         @AuraEnabled
         public String ProductId;
         @AuraEnabled
         public Decimal UnitPrice;
         @AuraEnabled
         public Decimal Quantity;
         @AuraEnabled
         pUBLIC Boolean IsActive;
         @AuraEnabled
         public Boolean IsSubscription;
         @AuraEnabled
         Public String LineItemType;
         @AuraEnabled
         Public String PrdId;
        
    }
    
    //Code Added By Pankaj kashyap for Bundle Component//
    @AuraEnabled 
    public static Void InsertBundle(String BundleName){
        Favorite_Bundle__c UserFav = new Favorite_Bundle__c();
        UserFav.Name=BundleName;
        insert UserFav;
        system.debug('>>>>'+UserFav);  
    }
    //Code End By Pankaj kashyap for Bundle Component//
    @AuraEnabled
    public Static void delbundle(String BundleIds,String ProductIds ){
            List<Favorite_Bundle__c> BundleForDelete = new List<Favorite_Bundle__c>();
            List<User_Favorite_Products__c> BundleProductForDelete = new List<User_Favorite_Products__c>();
            try{
              
               List<Bundle_Delete_Wrapper> Bundlelst_JsonParse = (List<Bundle_Delete_Wrapper>)Json.deserialize(BundleIds,List<Bundle_Delete_Wrapper>.class);
               List<BundleProduct_Delete_Wrapper> BundleProductlst_JsonParse = (List<BundleProduct_Delete_Wrapper>)Json.deserialize(ProductIds,List<BundleProduct_Delete_Wrapper>.class);  
                for(Bundle_Delete_Wrapper   obj1 : Bundlelst_JsonParse){
                    system.debug('>>>'+obj1.Id);
                    Favorite_Bundle__c favObj = new Favorite_Bundle__c();
                    favObj.id=obj1.Id;
                    BundleForDelete.Add(favObj);
                }
                
                for(BundleProduct_Delete_Wrapper obj2 : BundleProductlst_JsonParse){
                    User_Favorite_Products__c userFavPrdObj= new User_Favorite_Products__c();
                    userFavPrdObj.id=obj2.Id;
                    BundleProductForDelete.add(userFavPrdObj);
                }
                
                for(Favorite_Bundle__c obj3 : [select id,name,(Select id,name from User_Favorite_Products__r) from Favorite_Bundle__c where Id IN : BundleForDelete]){
                    if(obj3.User_Favorite_Products__r.size() > 0){
                        BundleProductForDelete.addAll(obj3.User_Favorite_Products__r);
                    }
                }
                if(BundleProductForDelete.size() > 0){
                    delete BundleProductForDelete;
                }
                if(BundleForDelete.size() > 0 ){
                   delete  BundleForDelete;
                }
            }
            catch (Exception e) {
               
                throw new AuraHandledException('Darn it! Something went wrong: '
                    + e.getMessage());    
            }
            
    }
   
   @AuraEnabled
    public static String AddBundle_Product_To_ItemToSchedule(String MapForInsert, String OpportunityId ,String MapBundleSpecificProduct){
    Set<String> ListOfBundleId =  new Set<String>();   
    Set<String> ListOfSpecificProduct = new set<String>();     
    List<User_Favorite_Products__c> ProductIdSet = new List<User_Favorite_Products__c>();    
    List<Bundle_Delete_Wrapper> Bundlelst_JsonParse = (List<Bundle_Delete_Wrapper>)Json.deserialize(MapForInsert,List<Bundle_Delete_Wrapper>.class);
    List<BundleSpecificProduct> SpecificProductId = (List<BundleSpecificProduct>)Json.deserialize(MapBundleSpecificProduct,List<BundleSpecificProduct>.class);   
        system.debug('SpecificProductId'+SpecificProductId);
        for(Bundle_Delete_Wrapper obj : Bundlelst_JsonParse){
            ListOfBundleId.add(obj.Id);
        }
        
        for(BundleSpecificProduct favObj: SpecificProductId){
            ListOfSpecificProduct.add(favObj.Id);
        }
        Opportunity opp=[Select id, name,CATM_Record__c,Contract_Term_Mths__c from Opportunity where id =: OpportunityId];
        for(User_Favorite_Products__c  FavObj : [Select Id,Name,IsSubscription__c,LineItemType__c,Products__r.Service_Offer_Category__c,Products__c,Products__r.Name,Quantity__c,UnitPrice__c,Favorite_Bundle__c,Maintenance_Type__c,Qty_Type__c  from User_Favorite_Products__c where Favorite_Bundle__c IN : ListOfBundleId and Products__r.IsActive= True]){
                ProductIdSet.add(FavObj);
            
                
         }  
      
        for(User_Favorite_Products__c SpecificFavProduct : [Select Id,Name,IsSubscription__c,LineItemType__c,Products__c,Products__r.Service_Offer_Category__c,Quantity__c,UnitPrice__c,Favorite_Bundle__c, Maintenance_Type__c,Qty_Type__c  from User_Favorite_Products__c where ID IN : ListOfSpecificProduct and Products__r.IsActive=True]){
            ProductIdSet.add(SpecificFavProduct);
        }
        
     String spricebookId = GlobalVariable.pricebookId;
     String Msg; 
     //system.debug('<><><><><><><><><><><>>>>>>>>>'+OpportunityId);   
     Opportunity o = [Select o.Id, 
                                o.Pricebook2Id,
                                o.CurrencyIsoCode                                
                           from Opportunity o  
                         where o.Id = :OpportunityId];
      ID pricebookId = o.Pricebook2Id;   
      
        if(pricebookId == null) {
            pricebookId = spricebookId;
             try{
            Pricebook2 pb2 = [Select p.Description, p.Id, p.Name 
                               from Pricebook2 p
                             where p.Id = :pricebookId];
            //save the pricebook into opportunity
            o.Pricebook2Id = pb2.Id;
           
               update o; 
            }
            catch(Exception e){
                Msg = e.getMessage();
                return Msg;
            }
            
        }  
        
        if(pricebookId != null) {
            try{
                
           List<ID> productIdList = new List<ID>();
            for(User_Favorite_Products__c cp2 : ProductIdSet) {
                productIdList.add(cp2.Products__c);
            }
            
           if(SpecificProductId.size() > 0){
               for(BundleSpecificProduct prdid : SpecificProductId){
                      
                      productIdList.add(prdid.Id);
               }   
               system.debug(':::>>>'+productIdList);
           }    
                
            List<PricebookEntry> pbeList = [Select p.CurrencyIsoCode, 
                                                   p.Id, 
                                                   p.Name, 
                                                   p.Pricebook2Id, 
                                                   p.Product2Id, 
                                                   p.ProductCode, 
                                                   p.UseStandardPrice,
                                                   p.IsActive                                                  
                                              From PricebookEntry p  
                                             Where p.Pricebook2Id = :pricebookId
                                               and p.CurrencyIsoCode = :o.CurrencyIsoCode                                              
                                               and p.Product2Id in :productIdList
                                            ];
            
            List<OpportunityLineItem> addOLIlist = new List<OpportunityLineItem>();
            List<CurrencyType> clist = [Select c.ConversionRate from CurrencyType c where c.IsoCode = :o.CurrencyIsoCode];
            Double conversionRate = clist[0].ConversionRate;  
            for(User_Favorite_Products__c cp2 : ProductIdSet) {
                OpportunityLineItem aoli = new OpportunityLineItem();
                aoli.OpportunityId = o.id;
                aoli.ServiceDate = System.today();  
                
                Double totalPriceInUSD = 0.00;

                aoli.Quantity = cp2.Quantity__c; 
                aoli.Is_Subscriptioned__c=cp2.IsSubscription__c;
                
                
                if(String.isNotBlank(cp2.LineItemType__c)){
                    aoli.Opportunity_Line_Item_Type__c=cp2.LineItemType__c;
                }
                
                
                if(String.isNotBlank(cp2.Maintenance_Type__c)){
                    aoli.Maintenance_Type__c=cp2.Maintenance_Type__c;
                }
                
                if((cp2.IsSubscription__c) || (String.isNotBlank(cp2.Products__r.Service_Offer_Category__c) && cp2.Products__r.Service_Offer_Category__c.equalsIgnoreCase('Cloud'))){
                    aoli.Monthly_Fee__c = cp2.UnitPrice__c;
                    aoli.UnitPrice=0;
                }
                
                
                else{
                      aoli.UnitPrice=cp2.UnitPrice__c;
                } 
                if(String.isNotBlank(cp2.Qty_Type__c)){
                    aoli.Qty_Type__c = cp2.Qty_Type__c;
                }
                 //EBA_SF-2206 by Stuti 
                 if(opp.CATM_Record__c==True){
                     if(opp.Contract_Term_Mths__c!=null){
                		aoli.Number_of_Terms__c = opp.Contract_Term_Mths__c;
                        aoli.Monthly_Fee__c = cp2.UnitPrice__c; //EBA_SF-2209
                     }
                     else{
                         aoli.Number_of_Terms__c=0;
                     }
            }  
                
                
               
                
               
                //aoli.PSM__c = cp2.oppProduct.PSM__c; // retalix to ncr migration
                
                for(Integer i = 0; i < pbeList.size(); i++) {
                    PricebookEntry pbe = (PricebookEntry) pbeList[i];
                    if(pbe.Product2Id == cp2.Products__c) {
                        aoli.PricebookEntryId = pbe.Id;                     
                        break;
                    }
                }
                addOLIList.add(aoli);
            }
            if(addOLIlist.size() > 0) {                             
                insert addOLIlist; 
                
            }
        }
            
           catch(Exception e){
               Msg = e.getMessage();
               //return Msg;
               throw new AuraHandledException('Darn it! Something went wrong: '
                    + e.getMessage());
            } 
        }
        
        
      return Msg;
    }
    
    
   public class Bundle_Delete_Wrapper {
        public String Id;
        
    }   
    
   public class BundleProduct_Delete_Wrapper {
        public String Id;
        
    }   
    
    Public Class BundleSpecificProduct{
         public String Id;
    }    
}