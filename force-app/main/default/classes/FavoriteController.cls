/*
################################################################################################## 
Apex Class Name    : FavoriteController
Modification Log:
Date             Author               Modification
9-11-2021		 Dev Admin            Initial Version
01-20-2022       Puneet Bhatia        EBA_SF-1646 - Added changes for Connected HWM in Salesforce
25-05-2022       Stuti Srivastava     EBA_SF-2059 - Added changes related to Cardtronix Integrtion
19-12-2022       Monika               BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/
public class   FavoriteController {
    
    @AuraEnabled
    public static List<WrapperFavorite> getProducts(String OppId) { 
        List<WrapperFavorite> prodList =new List<WrapperFavorite>();
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId]; //By stuti EBA_SF-2059
        List<User_Favorite_Products__c> lstObj;
        if(o.CATM_Record__c == TRUE){
            lstObj = [select id, name,user__c,Products__r.Name,Products__c,Products__r.IsActive
                      ,  Products__r.Available_for_Subscription__c,Products__r.Service_Offer_Category__c,
                      Products__r.Available_as_Connected_HWM__c, Products__r.OriginalCorporation__c
                      from User_Favorite_Products__c 
                      where User__c=:UserInfo.getUserId() and Products__c  !=null and  Products__r.IsActive =true and Products__r.OriginalCorporation__c = 'Cardtronics'  Order By Products__r.Name ASC  Limit 1000 ];
        }
        else{
            lstObj = [select id, name,user__c,Products__r.Name,Products__c,Products__r.IsActive
                      ,  Products__r.Available_for_Subscription__c,Products__r.Service_Offer_Category__c,
                      Products__r.Available_as_Connected_HWM__c,Products__r.OriginalCorporation__c
                      from User_Favorite_Products__c 
                      where User__c=:UserInfo.getUserId() and Products__c  !=null and  Products__r.IsActive =true and Products__r.OriginalCorporation__c != 'Cardtronics'  Order By Products__r.Name ASC  Limit 1000 ];
        }
        
        for(User_Favorite_Products__c p: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.Prod = p;
            wp.selected = false;
            prodList.add(wp);
        }
        //system.debug('HiHi'+prodList); 
        
        return prodList;
    }
    @AuraEnabled
    public static String UnFavProduct(Id[] ProductId){
        //system.debug('abc'+ProductId);
        String Msg;
        set<id> ProductsId = new set<id>();
        //Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        for(Id wp: ProductId){ 
            ProductsId.add(wp);
        }
        try{
            List<User_Favorite_Products__c> lstObj;
            //if(o.CATM_Record__c == TRUE){
            lstObj = [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                      where User__c=:UserInfo.getUserId() and Products__c In : ProductsId ];
            /*}
else{
lstObj = [select id, name,user__c,Products__c  from User_Favorite_Products__c 
where User__c=:UserInfo.getUserId() and Products__c In : ProductsId and Products__r.OriginalCorporation__c = 'NCR'];
}*/
            //system.debug('lstObj'+lstObj);
            Delete lstObj;
            List<WrapperFavorite> prodList =new List<WrapperFavorite>();
        }
        catch(Exception e){
            Msg = e.getMessage();
            //System.debug('Execption occured'+e.getMessage()); 
        }
        return Msg;
    }
    
    /* @AuraEnabled
public static Void insertFavourite(String[] ProductId){
List <User_Favorite_Products__c> usFavList=new List <User_Favorite_Products__c>();
for(String prd:ProductId){                          
User_Favorite_Products__c usfav = new User_Favorite_Products__c();
usfav.Products__c=prd;
usfav.User__c=UserInfo.getUserId();                           
usFavList.add(usfav);  
}             

insert usFavList;      

} */
    
    @AuraEnabled
    public static String insertFavourite(String[] ProductId, String OppId){
        string Message;
        try{
            Set<Id> SetProductId = new Set<Id>();
            for(String pid : ProductId){
                SetProductId.add(pid);
            }
            List<User_Favorite_Products__c> listofFab=new List<User_Favorite_Products__c>();
            Map<Id,String> UFP_ToProductId =  new Map<Id,String>();
            Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId]; //by Stuti EBA_SF-2059
            List<User_Favorite_Products__c> AlreadyFavProducts;
            if(o.CATM_Record__c == TRUE){
                AlreadyFavProducts =  [select id, name,user__c,Frequency_of_Use__c,Products__r.Name,Products__c  from User_Favorite_Products__c 
                                       where User__c=:UserInfo.getUserId() and Products__c  !=null and Products__r.IsActive= true and Products__r.OriginalCorporation__c = 'Cardtronics'];
            }
            else{
                AlreadyFavProducts =  [select id, name,user__c,Frequency_of_Use__c,Products__r.Name,Products__c  from User_Favorite_Products__c 
                                       where User__c=:UserInfo.getUserId() and Products__c  !=null and Products__r.IsActive= true and Products__r.OriginalCorporation__c != 'Cardtronics'];
            }
            for(User_Favorite_Products__c UFP : AlreadyFavProducts){
                if(!UFP_ToProductId.containskey(UFP.Products__c)){
                    UFP_ToProductId.put(UFP.Products__c,UFP.Products__r.Name);
                }
            }
            //System.debug('********'+SetProductId.size());
            //System.debug('all set val'+SetProductId);
            for(Id selectedidobj : SetProductId){
                if(!UFP_ToProductId.containsKey(selectedidobj)){
                    User_Favorite_Products__c obj = new User_Favorite_Products__c();
                    obj.user__c = UserInfo.getUserId();
                    obj.Products__c = selectedidobj;
                    listofFab.add(obj);
                }
            }
            if(listofFab.size()>0){
                insert listofFab;
            }
        }
        catch(DmlException e){ 
            Message= e.getMessage();
        }
        return Message;
    }
    
    @AuraEnabled
    public static Void deleteFavProduct(String[] ProductId){
        set<id> ProductsId = new set<id>();
        for(String wp: ProductId){ 
            ProductsId.add(wp);
        }
        try{
            List<User_Favorite_Products__c> lstObj = [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                                                      where User__c=:UserInfo.getUserId() and Products__c In : ProductsId];
            Delete lstObj;
            List<WrapperFavorite> prodList =new List<WrapperFavorite>();
        }
        catch(Exception e){
            System.debug('Exception Caught'+e.getMessage());
        }
        
    }
    @AuraEnabled
    public static SubsProductWrapper getSubsOnlyProd(){     
        Set<String> SubsProdSet= new Set<String>(); 
        Set<String> SubsRevenueSet= new Set<String>();
        
        SubsProductWrapper subsProdWrapObj= new subsProductWrapper();
        List<Subscription_only_products__c> subsProdList=  Subscription_only_products__c.getall().values();
        
        if(subsProdList.size()>0){            
            if(String.isNotBlank(subsProdList[0].Product_Name__c)){
                for(String prodName : subsProdList[0].Product_Name__c.split(',')){
                    SubsProdSet.add(prodname);            
                }
                if(String.isNotBlank(subsProdList[0].Product_Revenue_Type__c)){
                    for(String revenueType : subsProdList[0].Product_Revenue_Type__c.split(',')){
                        SubsRevenueSet.add(revenueType);               
                    }
                }
            }
            subsProdWrapObj.ProductNames = SubsProdSet;
            subsProdWrapObj.RevenueTypes = SubsRevenueSet;
        }
        return subsProdWrapObj;
    } 
    
    public class SubsProductWrapper{
        @AuraEnabled public Set<String> ProductNames{get;set;}
        @AuraEnabled public Set<String> RevenueTypes{get;set;}
    }   
    
    @AuraEnabled
    public static ProductInfoWrapper getRnwableProds(String OppId){     
        Set<String> SubsProdSet= new Set<String>(); 
        Set<String> SubsRevenueSet= new Set<String>();
        Set<String> RnwablRevnSet= new Set<String>();
        Map<String, String> lineItemTypeOpts = new Map<String, String>();
        Set<String> HWMMntTypeOpts = new Set<String>(); 
        Map<String,String> qtyTypOpts = new Map<String,String>(); //added by stuti - CSI-304 - QtyType Enhancement
        
        ProductInfoWrapper prodInfoWrapObj= new ProductInfoWrapper();
        List<Renewable_Products__c> renewablePrdLst = Renewable_Products__c.getAll().values();        
        
        if (renewablePrdLst != NULL && renewablePrdLst.size() > 0) {
            if (String.isNotBlank(renewablePrdLst[0].Product_Revenue_Types__c)) { 
                RnwablRevnSet.addAll(renewablePrdLst[0].Product_Revenue_Types__c.split(','));
                prodInfoWrapObj.RnwablRevTypes = RnwablRevnSet;
            }
        }
        /*****Stuti - EBA_SF-1595 start**
Opportunity oId=[Select type from Opportunity where Id =: OppId];
List<OpportunityLineItem__mdt> oli = [Select Opportunity_Line_Item_Type__c from OpportunityLineItem__mdt where Type__c =: oId.Type limit 1];
if(!oli.isEmpty()){
if(String.isNotBlank(oli[0].Opportunity_Line_Item_Type__c)){
for(String s : oli[0].Opportunity_Line_Item_Type__c.split(',')){
lineItemTypeOpts.put(s,s); 
}
}
} 
***EBA_SF-1595 condition end****/
        
        for(Schema.PicklistEntry p : OpportunityLineItem.Opportunity_Line_Item_Type__c.getDescribe().getPicklistValues()) {
            lineItemTypeOpts.put(p.getValue(), p.getLabel());
        }
        
        prodInfoWrapObj.OppLineItemTypes = lineItemTypeOpts;
        
        for(Schema.PicklistEntry p : OpportunityLineItem.Maintenance_Type__c.getDescribe().getPicklistValues()) {
            HWMMntTypeOpts.add(p.getLabel());
        }
        prodInfoWrapObj.HWMMntTypes = HWMMntTypeOpts;
        
        /*---added by stuti - CSI-304 - QtyType Enhancement condition start---*/
        for(Schema.PicklistEntry p : OpportunityLineItem.Qty_Type__c.getDescribe().getPicklistValues()) {
            qtyTypOpts.put(p.getLabel(), p.getValue());
        }
        prodInfoWrapObj.qtyTypes = qtyTypOpts;
        /*---CSI 304 condition end--*/
        
        
        return prodInfoWrapObj;
    } 
    
    public class ProductInfoWrapper {
        @AuraEnabled public Set<String> RnwablRevTypes{get;set;}
        @AuraEnabled public Map<String, String> OppLineItemTypes{get;set;}
        @AuraEnabled public Set<String> HWMMntTypes{get;set;} 
        @AuraEnabled public Map<String, String> qtyTypes{get;set;} // CSI-304 - QtyType Enhancement by Stuti
    }
    /*-- CSI-304 - QtyType Enhancement by Stuti--*/
    @AuraEnabled
    public static boolean getOpportunity(String OppId){
        Opportunity O=[Select id, Catm_Record__c from Opportunity where id=:OppId];
        return O.CATM_Record__c;
    }
    /*-- CSI-304 - QtyType Enhancement condition end--*/
    
}