/*
##################################################################################################
# Class Name............................:fetchOpportunityDetail.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public class fetchOpportunityDetail {
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static List<opportunity> getOppDetails(String oppId){
        List<Opportunity> opps= [select id,CPQ__c from opportunity where id =:oppId Limit 1];
        return opps;
    }
    
    /*@AuraEnabled
public static List<AAS_Functionality_Assignment__c> aasFunctionalityAccess(){
User userDetails =[SELECT Id,Profile.Name,UserRole.Name FROM User where Id=:userinfo.getUserId() ];   
List<AAS_Functionality_Assignment__c> assUsers= [select Profile_Name__c,Role_Name__c,UserId__c from AAS_Functionality_Assignment__c where (Role_Name__c=: userDetails.UserRole.Name and Role_Name__c !=null)  or Profile_Name__c=:userDetails.Profile.Name or UserId__c=:userDetails.Id ];
return assUsers;
}*/
    
    @AuraEnabled      
    public static Map<String, opportunity> getOpportunity(String rdId) {
        Map<String, opportunity> mpOppDetail = new Map<String, opportunity>();
        String admin04;
        // Changes by Yogesh - Story EBA_SF-1918
        Set<Id> profileIds = NSCCommonInfoUtil.getIdSetOf('Admn_Profle_Id');
        Set<Id> NonAdmnprofileIds = NSCCommonInfoUtil.getIdSetOf('Non_Admn_Profle_Id');
        
            /*  if(userInfo.getProfileId()=='00e70000000x3egAAA' || userInfo.getProfileId()=='00e70000000x3eg'){
admin04='Admin';
}
else if(userInfo.getProfileId()== '00e700000013gPe'|| userInfo.getProfileId()=='00e700000013gPeAAI' ||userInfo.getProfileId() =='00e70000000sR8U' || userInfo.getProfileId()=='00e70000000sR8UAAU'){
admin04='Other Admin';
}*/
        if(profileIds.Contains(userInfo.getProfileId())){
            admin04='Admin';
        }
        else if(NonAdmnprofileIds.contains(userInfo.getProfileId())){
            admin04='Other Admin';
        }
        else{
            admin04='Non Admin';
        }
        // End Changes - Yogesh 
        Opportunity Opp= [    
            SELECT Id, Name,CATM_Record__c,/*Solution_Portfolio__c, -//P360 Initial Change - Ahad*/IsClosed, Expected_Delivery_Date__c, Amount, CurrencyIsoCode FROM Opportunity  
            WHERE Id =:rdId ];  
        mpOppDetail.put(admin04,Opp);
        return (mpOppDetail);  
    } 
    
    //Code Added By Pankaj kashyap for Bundle Component//
    @AuraEnabled
    public static Void DeleteProductFromBundle(String MapForDelete ,String MapOfBundleProductForDelete){
        //Code For Deleting Products//
        Set<User_Favorite_Products__c> DeleteListforProduct = new Set<User_Favorite_Products__c>();
        
        List<DeleteProductWrapper> Bundlelst_JsonParse = (List<DeleteProductWrapper>)Json.deserialize(MapForDelete,List<DeleteProductWrapper>.class);
        for(DeleteProductWrapper  S : Bundlelst_JsonParse){
            //system.debug('Id'+S.Id);
            //system.debug('Id'+S.Status);
            if(S.Status){
                User_Favorite_Products__c  PrdObj = new User_Favorite_Products__c();
                PrdObj.id=S.Id;
                DeleteListforProduct.add(PrdObj);
            }
        }
        
        //Code End For Deleting Product//
        //-------------------------------------------------------------------------//
        //Code For Deleting Product Under Selected Bundle
        List<DeleteProductWrapper> Bundlelst_JsonParse_Bundle = (List<DeleteProductWrapper>)Json.deserialize(MapOfBundleProductForDelete,List<DeleteProductWrapper>.class);
        Set<String> BundleIdSet =  new Set<String>();
        lIST<Favorite_Bundle__c> BundleListForDelete = new List<Favorite_Bundle__c>();
        for(DeleteProductWrapper S1 : Bundlelst_JsonParse_Bundle){
            if(S1.Status){
                BundleIdSet.add(S1.Id);
                Favorite_Bundle__c BundleObj = new Favorite_Bundle__c();
                BundleObj.id=S1.Id; 
                BundleListForDelete.add(BundleObj);
            }
            
        }
        
        for(User_Favorite_Products__c UserFab_Obj : [Select id,Products__c,name from User_Favorite_Products__c  Where Favorite_Bundle__c IN : BundleIdSet]){
            User_Favorite_Products__c  PrdObj_Bundle = new User_Favorite_Products__c();
            PrdObj_Bundle.id=UserFab_Obj.Id;
            DeleteListforProduct.add(PrdObj_Bundle);
        }
        //Code End for Deleting Product Under Selected Bundle
        
        
        if(DeleteListforProduct.size() > 0){
            List<User_Favorite_Products__c> TempListForDelete = new List<User_Favorite_Products__c>();
            TempListForDelete.addAll(DeleteListforProduct);
            delete TempListForDelete;
        }
        
        If(BundleListForDelete.size() > 0 ){
            Delete BundleListForDelete; 
        }
    }
    
    public class DeleteProductWrapper {
        public String Id;
        Public Boolean Status;  
    }
    
    //Code Added By Pankaj kashyap for Bundle Component//
    @AuraEnabled 
    public static Void InsertBundle(String BundleName){
        Favorite_Bundle__c UserFav = new Favorite_Bundle__c();
        UserFav.Name=BundleName;
        insert UserFav;
        //system.debug('>>>>'+UserFav);  
    }
    //Code End By Pankaj kashyap for Bundle Component//
    
    @AuraEnabled
    public static String AddBundleProductToItemToSchedule(String MapForInsert, String OpportunityId){
        List<InsertSchedueWrapper> Bundlelst_JsonParse = (List<InsertSchedueWrapper>)Json.deserialize(MapForInsert,List<InsertSchedueWrapper>.class);
        List<String> ListOfBundleId =  new List<String>(); 
        List<String> ProductIdSet = new List<String>();
        for(InsertSchedueWrapper obj : Bundlelst_JsonParse){
            if(obj.Status){
                ListOfBundleId.add(obj.Id); 
            }
        }  
        
        for(User_Favorite_Products__c  FavObj : [Select Id,Name,Products__c,Favorite_Bundle__c  from User_Favorite_Products__c where Favorite_Bundle__c IN : ListOfBundleId]){
            ProductIdSet.add(FavObj.Products__c);
            
        }
        
        String spricebookId = GlobalVariable.pricebookId;
        String Msg;
        Opportunity o = [Select o.Id, 
                         o.Pricebook2Id,
                         o.CurrencyIsoCode                                
                         from Opportunity o  
                         where o.Id = :OpportunityId];
        
        ID pricebookId = o.Pricebook2Id;
        
        
        if(pricebookId == null) {
            pricebookId = spricebookId;
            Pricebook2 pb2 = [Select p.Description, p.Id, p.Name 
                              from Pricebook2 p
                              where p.Id = :pricebookId];
            //save the pricebook into opportunity
            o.Pricebook2Id = pb2.Id;
            try{
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
                for(String cp2 : ProductIdSet) {
                    productIdList.add(cp2);
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
                for(String cp2 : ProductIdSet) {
                    OpportunityLineItem aoli = new OpportunityLineItem();
                    aoli.OpportunityId = o.id;
                    aoli.ServiceDate = System.today();  
                    
                    Double totalPriceInUSD = 0.00;
                    
                    aoli.Quantity = 1; 
                    aoli.UnitPrice = 0.00;
                    //aoli.HasRevenueSchedule=false;
                    
                    
                    //aoli.PSM__c = cp2.oppProduct.PSM__c; // retalix to ncr migration
                    
                    for(Integer i = 0; i < pbeList.size(); i++) {
                        PricebookEntry pbe = (PricebookEntry) pbeList[i];
                        if(pbe.Product2Id == cp2) {
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
                return Msg;
            } 
        }
        
        
        
        return Msg;
    }
    
    
    public class InsertSchedueWrapper {
        public String Id;
        Public Boolean Status;  
    }
    
    ///////////Code For Bunlde//////
    //
    /*@AuraEnabled
public static List<WrapperBundle> getProducts() {

List<Favorite_Bundle__c> FavBundles=[Select id,name,(Select id,name,Products__c,Products__r.Name from User_Favorite_Products__r) from Favorite_Bundle__c where ownerid=:UserInfo.getUserId()];
List<WrapperBundle> lstFavBundle = new  List<WrapperBundle>(); 
System.debug('FavBundles'+FavBundles);
for(Favorite_Bundle__c FB:FavBundles){
list<WrapperFavorite> lstUserFav= new  list<WrapperFavorite>();
for(User_Favorite_Products__c userFavProd: FB.User_Favorite_Products__r){
WrapperFavorite WF = new WrapperFavorite();
WF.Prod = userFavProd;
WF.ProductName  = userFavProd.Products__r.Name;
WF.ProductId = userFavProd.Products__c;
WF.favselected = false;
lstUserFav.add(WF);
}
WrapperBundle WB = new WrapperBundle();
WB.UserBundle = FB;
WB.selected = false;
WB.BundleProducts= lstUserFav;
lstFavBundle.add(WB);
}
return lstFavBundle;
}
public class WrapperBundle{ 
@AuraEnabled
public Boolean selected {get;set;}
@AuraEnabled
public  Favorite_Bundle__c  UserBundle{get;set;}
@AuraEnabled
public List<WrapperFavorite> BundleProducts{get;set;}
}*/
    
    @AuraEnabled
    public static List<Favorite_Bundle__c> getProductBundle(){
        List<ProductBundleWrapper> BundleProductName = new List<ProductBundleWrapper>();
        
        
        return[Select id,name from Favorite_Bundle__c where ownerid=:UserInfo.getUserId()] ;
    }
    
    
    public class ProductBundleWrapper{
        @AuraEnabled
        public String Width;
        @AuraEnabled
        public String BundleName;
        @AuraEnabled
        public String DataType;
        @AuraEnabled
        public List<WrapperFavorite> BundleProducts;
    }
    
}