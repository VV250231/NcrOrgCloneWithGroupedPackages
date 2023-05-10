/*
################################################################################################## 
Apex Class Name    : GlobalSearchController
Modification Log:
Date             Author               Modification
9-11-2021		 Dev Admin            Initial Version
01-20-2022       Puneet Bhatia        EBA_SF-1646 - Added changes for Connected HWM in Salesforce
25-05-2022       Stuti Srivastava     EBA_SF-2059 - Added changes related to Cardtronix Integrtion
12-08-2022       Stuti Srivastava     EBA_SF-2174 - Added check for NCR Payment Processing product
################################################################################################
*/
public class GlobalSearchController {
    
    @AuraEnabled(cacheable=true)
    public static Boolean IsCurrentProfileExistInCustomSetting(){
        Set<String> checkProfileIds = new Set<String>();
        /*List<SMB_Partner_Profiles_for_CPQ__c> sppc = SMB_Partner_Profiles_for_CPQ__c.getall().values();
for(SMB_Partner_Profiles_for_CPQ__c sp : sppc) {
checkProfileIds.add(sp.Profile_Id__c);
}*/
        All_profie_config__c sppc = All_profie_config__c.getValues('SMB Partner Profiles CPQ');	
        for(string sp : sppc?.Profile_Id__c?.split(',')) {
            checkProfileIds.add(sp);
        }
        system.debug('@@@@@Profileid: '+userInfo.getProfileId()); 
        system.debug('@@@@@checkProfileIds: '+checkProfileIds); 
        if(checkProfileIds.contains(String.valueOf(userInfo.getProfileId()))){ return true; }
        else{ return false;}
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPartnerProducts(){
        List<String> AllowedProductForPartners = new List<String>();
        AllowedProductForPartners.addAll((Label.AllowedProductForSMBPartner).split(','));
        return AllowedProductForPartners;
    }
    
    @AuraEnabled(cacheable=true)
    Public Static List<Product2> getProductList(String searchKey , List<String> SchFavListId, String OppId){
        
        String key = '%' + searchKey + '%';
        // if(Profileid.contains('00e70000000x3egAAA')){
        //if(Profileid !='00e2f000000EmXrAAK' && Profileid !='00e2f000000EoCCAA0'){
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        if(o.CATM_Record__c == True){
            return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from Product2 where isActive = true and  name Like : key and Id NOT IN : SchFavListId and Product_Type__c='Topline' and OriginalCorporation__c='Cardtronics' order by name limit 20 ];     
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from Product2 where isActive = true and  name Like : key and Id NOT IN : SchFavListId and Product_Type__c='Topline'and OriginalCorporation__c!='Cardtronics' order by name limit 20];    
            } 
            else{
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from Product2 where isActive = true and  name Like : key and Id NOT IN : SchFavListId and Product_Type__c='Topline' and Name in :(GlobalSearchController.getPartnerProducts()) and OriginalCorporation__c!='Cardtronics' order by name limit 20];   
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    Public Static List<Product2> getFilterResult(List<String> FilterString , List<String> SchFavListId, String OppId){ 
        system.debug('>>>'+FilterString); 
        system.debug(':::::'+SchFavListId); 
        //if(Profileid.contains('00e70000000x3egAAA')){
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId]; //By stuti -2059
        if(o.CATM_Record__c == True){
            return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from product2 where Service_Offer_Category__c IN : FilterString and Id NOT IN : SchFavListId and isActive = true and Product_Type__c='Topline'and OriginalCorporation__c = 'Cardtronics'order by name limit 20];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from product2 where Service_Offer_Category__c IN : FilterString and Id NOT IN : SchFavListId and isActive = true and Product_Type__c='Topline'and OriginalCorporation__c != 'Cardtronics' order by name limit 20];
            }
            else{
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from product2 where Service_Offer_Category__c IN : FilterString and Id NOT IN : SchFavListId and name in :(GlobalSearchController.getPartnerProducts()) and isActive = true and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name limit 20];
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    Public Static List<Schedle_Fav_Wrapper> getFirstChunk(String OpportunityId){  
        List<User_Favorite_Products__c> favobjList=new List<User_Favorite_Products__c>();
        List<Product2> Product2List =new List<Product2>();
        System.debug('@@@@@: '+GlobalSearchController.IsCurrentProfileExistInCustomSetting());
        System.debug('@@@@@: '+GlobalSearchController.getPartnerProducts());
        //return [Select id,name,Service_Offer_Category__c from Product2 where Id NOT IN :SchedulePrdList AND isActive=true limit 10];
        List<Schedle_Fav_Wrapper> ListSchedle_Fav_Wrapper = new List<Schedle_Fav_Wrapper>();
        Map<id,Schedle_Fav_Wrapper> ScheduleProductMap = new Map<Id,Schedle_Fav_Wrapper>();
        //By stuti -2059 added Original Corporation and CATM_Record__c check
        for(OpportunityLineItem oli : [select id,name,Product2.Name,Product2.id,Product2.Service_Offer_Category__c,Product2.Pmdm_Product_Category__c, 
                                       Product2.Available_for_Subscription__c, Product2.Available_as_Connected_HWM__c from OpportunitylineItem where OpportunityId =:OpportunityId and
                                       Product2.Product_Type__c='Topline' and ((Opportunity.CATM_Record__c = TRUE and product2.OriginalCorporation__c='Cardtronics') OR (Opportunity.CATM_Record__c = FALSE and product2.OriginalCorporation__c!='Cardtronics'))]){
                                           Schedle_Fav_Wrapper schfavobj = new Schedle_Fav_Wrapper();
                                           schfavobj.ProductId=oli.Product2.id;
                                           schfavobj.ProductName=oli.Product2.Name;
                                           schfavobj.IsSchedule=true;
                                           schfavobj.IsFav=false;
                                           schfavObj.IsCheckBoxSelected=false; 
                                           schfavObj.ServiceOfferCatogery=oli.Product2.Service_Offer_Category__c;
                                           schfavObj.availForSubscription = oli.Product2.Available_for_Subscription__c ;
                                           schfavObj.avlAsCnctdHWM =  oli.Product2.Available_as_Connected_HWM__c;
                                           ScheduleProductMap.put(oli.Product2.id,schfavobj); 
                                           
                                       }
        // By stuti - 2059 - Cardtrnics Changes
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OpportunityId];
        if(o.CATM_Record__c == True){
            
            favobjList=[select id,Products__r.Name,Products__r.Id,Products__r.Service_Offer_Category__c,Products__r.Pmdm_Product_Category__c,Products__c, Products__r.Available_for_Subscription__c, Products__r.Available_as_Connected_HWM__c, Products__r.OriginalCorporation__c from User_Favorite_Products__c 
                        where User__c=:UserInfo.getUserId() and Products__c!=null AND Products__r.OriginalCorporation__c = 'Cardtronics'
                        Order By Products__r.Name,Frequency_of_Use__c DESC Limit 1000];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                favobjList=[select id,Products__r.Name,Products__r.Id,Products__r.Service_Offer_Category__c,Products__r.Pmdm_Product_Category__c,Products__c, Products__r.Available_for_Subscription__c, Products__r.Available_as_Connected_HWM__c, Products__r.OriginalCorporation__c from User_Favorite_Products__c 
                            where User__c=:UserInfo.getUserId() and Products__c!=null and Products__r.OriginalCorporation__c != 'Cardtronics' 
                            Order By Products__r.Name, Frequency_of_Use__c DESC Limit 1000];
            }
            
            else{
                favobjList=[select id,Products__r.Name,Products__r.Id,Products__r.Service_Offer_Category__c,Products__r.Pmdm_Product_Category__c,Products__c, Products__r.Available_for_Subscription__c, Products__r.Available_as_Connected_HWM__c, Products__r.OriginalCorporation__c from User_Favorite_Products__c where User__c=:UserInfo.getUserId() and Products__c  !=null and Products__r.Name in :(GlobalSearchController.getPartnerProducts()) and Products__r.OriginalCorporation__c != 'Cardtronics' Order By Products__r.Name,Frequency_of_Use__c DESC Limit 1000];
            }
        }
        
        for(User_Favorite_Products__c favobj : favobjList){
            Schedle_Fav_Wrapper schfavobj = new Schedle_Fav_Wrapper();
            if(ScheduleProductMap.containsKey(favobj.Products__r.Id)){
                ScheduleProductMap.get(favobj.Products__r.Id).IsFav=true;
                schfavObj.IsCheckBoxSelected=false; 
                
            }
            else{
                schfavobj.ProductId=favobj.Products__r.Id;
                schfavobj.ProductName=favobj.Products__r.Name;
                schfavobj.IsSchedule=false;
                schfavobj.IsFav=true;
                schfavObj.IsCheckBoxSelected=false;
                schfavObj.availForSubscription = favobj.Products__r.Available_for_Subscription__c ;
                schfavObj.ServiceOfferCatogery=favobj.Products__r.Service_Offer_Category__c;
                schfavObj.avlAsCnctdHWM=favobj.Products__r.Available_as_Connected_HWM__c;
                ScheduleProductMap.put(favobj.Products__r.Id,schfavobj);
                
            }                                       
            
            
        }
        ListSchedle_Fav_Wrapper.addAll(ScheduleProductMap.values());
        
        // By stuti - 2059 - Cardtrnics Changes
        if(o.CATM_Record__c == True){
            Product2List=[select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c from Product2 
                          where Id NOT IN :ScheduleProductMap.keySet() and isActive=true and Product_Type__c='Topline' and OriginalCorporation__c = 'Cardtronics' order by name Limit 20];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                Product2List=[select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c from Product2 
                              where Id NOT IN :ScheduleProductMap.keySet() and isActive=true and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name Limit 20];
            }
            else{
                Product2List=[select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c from Product2 where Id NOT IN :ScheduleProductMap.keySet() and isActive=true and Product_Type__c='Topline' and Name in :(GlobalSearchController.getPartnerProducts()) and OriginalCorporation__c != 'Cardtronics' order by name Limit 20];  
            }
        }
        
        for(Product2 PrdObj:Product2List){
            Schedle_Fav_Wrapper schfavobj = new Schedle_Fav_Wrapper();
            schfavobj.ProductId=PrdObj.id;
            schfavobj.ProductName=PrdObj.Name;
            schfavobj.IsSchedule=false;
            schfavobj.IsFav=false;
            schfavObj.IsCheckBoxSelected=false;
            schfavObj.ServiceOfferCatogery=PrdObj.Service_Offer_Category__c;
            schfavObj.availForSubscription = PrdObj.Available_for_Subscription__c ;
            ListSchedle_Fav_Wrapper.add(schfavobj);
            
            
        }
        
        
        return ListSchedle_Fav_Wrapper;
    }
    
    @AuraEnabled
    public Static List<Product2> GetNextPage(List<String> ProductId, String OppId){
        // By stuti - 2059 - Cardtrnics Changes
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        if(o.CATM_Record__c == True){
            return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from Product2 where Id NOT IN :ProductId and isActive=true and Product_Type__c='Topline'and OriginalCorporation__c = 'Cardtronics' order by name Limit 100];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from Product2 where Id NOT IN :ProductId and isActive=true and Product_Type__c='Topline'and OriginalCorporation__c != 'Cardtronics' order by name Limit 100];
            }
            else{
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c, Available_as_Connected_HWM__c from Product2 where Id NOT IN :ProductId and isActive=true and Name in :(GlobalSearchController.getPartnerProducts()) and Product_Type__c='Topline'and OriginalCorporation__c != 'Cardtronics' order by name Limit 100]; 
            }
        }
    }
    
    Public Class ProductDataWrapper{
        public String id;
    }
    
    Public Class Schedle_Fav_Wrapper{
        @Auraenabled
        Public Id ProductId;
        @Auraenabled
        Public String ProductName;
        @Auraenabled
        Public Boolean IsSchedule;
        @Auraenabled
        Public Boolean IsFav;
        @Auraenabled
        Public Boolean IsCheckBoxSelected; 
        @Auraenabled
        Public String ServiceOfferCatogery;
        // START Change Divya NC_AGILE-2336
        @AuraEnabled
        public Boolean availForSubscription ;
        // END Change , NC_AGILE-2336
        @AuraEnabled
        public Boolean avlAsCnctdHWM; //availAsConnectedHWM
        
        
    }
    
    @AuraEnabled
    Public Static List<Product2> getNextPageFor_Filter(List<String> ProductId, List<String> FilterString, String OppId){
        // By stuti - 2059 - Cardtrnics Changes
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        if(o.CATM_Record__c == True){
            return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive=true and Id NOT IN :ProductId and Service_Offer_Category__c IN : FilterString and Product_Type__c='Topline' and OriginalCorporation__c = 'Cardtronics' order by name limit 40];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive=true and Id NOT IN :ProductId and Service_Offer_Category__c IN : FilterString and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name limit 40];
            }
            else{
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive=true and Id NOT IN :ProductId and Service_Offer_Category__c IN : FilterString and Name in :(GlobalSearchController.getPartnerProducts()) and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name limit 40];
            } 
        }
        
    }
    
    @AuraEnabled
    public Static List<Product2> getNextPageFor_SearchString(List<String> ProductId, String searchKey, String OppId){
        String key = '%' + searchKey + '%';
        // By stuti - 2059 - Cardtrnics Changes
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        if(o.CATM_Record__c == True){
            return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive = true and  name Like : key and Id NOT IN : ProductId and Product_Type__c='Topline'and OriginalCorporation__c = 'Cardtronics' order by name limit 20];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive = true and  name Like : key and Id NOT IN : ProductId and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name limit 20];
            }
            else{
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive = true and name Like : key and Id NOT IN : ProductId and Name in :(GlobalSearchController.getPartnerProducts()) and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name  limit 20];  
            }
        }
    }
    
    @AuraEnabled
    Public Static List<Product2> SearchWithFilter(List<String> FilterString, String searchKey , List<String> SchFavListId, String OppId){
        String key = '%' + searchKey + '%';
        // By stuti - 2059 - Cardtrnics Changes
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        if(o.CATM_Record__c == True){
            return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive = true and name like : key and Service_Offer_Category__c IN : FilterString and Id NOT IN : SchFavListId and isActive = true and Product_Type__c='Topline' and OriginalCorporation__c = 'Cardtronics' order by name];
        }
        else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive = true and name like : key and Service_Offer_Category__c IN : FilterString and Id NOT IN : SchFavListId and isActive = true and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name];
            }
            
            else{
                return [Select id,name,Service_Offer_Category__c,Pmdm_Product_Category__c, Available_for_Subscription__c,Available_as_Connected_HWM__c from Product2 where isActive = true and name like : key and Service_Offer_Category__c IN : FilterString and Id NOT IN : SchFavListId and Name in :(GlobalSearchController.getPartnerProducts()) and isActive = true and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' order by name]; 
            }
        }
    }
    @AuraEnabled
    Public Static List<AggregateResult> get_PMDM_Product_Catoget(String OppId){
        // By stuti - 2059 - Cardtrnics Changes
        Opportunity o=[Select id, name,CATM_Record__c from Opportunity where id =: OppId];
        if(o.CATM_Record__c == True){
            return [Select Service_Offer_Category__c from Product2 where isActive=true and Product_Type__c='Topline' and Service_Offer_Category__c!=null and OriginalCorporation__c = 'Cardtronics' group by Service_Offer_Category__c  ]; 
        }else{
            if(!GlobalSearchController.IsCurrentProfileExistInCustomSetting()){ 
                return [Select Service_Offer_Category__c from Product2 where isActive=true and Product_Type__c='Topline' and OriginalCorporation__c != 'Cardtronics' and Service_Offer_Category__c!=null  group by Service_Offer_Category__c ]; 
            }
            else{
                return [Select Name,Service_Offer_Category__c  from Product2 where isActive=true and Product_Type__c='Topline' and 
                        Name in :(GlobalSearchController.getPartnerProducts()) and OriginalCorporation__c != 'Cardtronics' and Service_Offer_Category__c!=null  group by Service_Offer_Category__c,Name ]; 
            }
        }
    }
    
    /* @AuraEnabled	
public static NCR_Payment_Products_Name__c getProdName(){	
return NCR_Payment_Products_Name__c.getValues('NCR Payment Product');	
}	

@AuraEnabled	
public static void updateNCRPaymentProd(String oppId,String prodId, Decimal annualTrans, Decimal annualVol, Decimal amtPerTrans, Decimal amtPerVol, Decimal yieldVal, Decimal monthlyFee, String oliId){	
String prodName = NCR_Payment_Products_Name__c.getValues('NCR Payment Product').Products_Name__c;	
Product2 obj = [Select Id, Name, Service_Offer_Category__c FROM Product2 WHere Id = : prodId];	
List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();	
System.debug('obj.Name : '+obj.Name);	
System.debug('prodName : '+prodName);	
if(obj.Name == prodName){	
OpportunityLineItem oli = new OpportunityLineItem();	
if(String.isNotBlank(oliId)){	
oli = [Select id, Quantity, Number_of_Terms__c, Annual_Transactions__c, Annual_volume__c, Amount_per_transactions__c, Amount_per_volume__c from OpportunityLineItem where Id =: oliId];	
}else{	
oli = [Select id, Quantity, Number_of_Terms__c, Annual_Transactions__c, Annual_volume__c, Amount_per_transactions__c, Amount_per_volume__c from OpportunityLineItem WHERE OpportunityId =: oppId AND Product2.Name =: prodName Order By CreatedDate DESC LIMIT 1];	
}	
System.debug('OLI !!@@ '+oli);	
oli.Annual_Transactions__c = annualTrans;	
oli.Annual_volume__c = annualVol;	
oli.Amount_per_transactions__c = amtPerTrans;	
oli.Amount_per_volume__c = amtPerVol;	
oli.Estimated_Yield__c = yieldVal;	
oli.Monthly_Fee__c = monthlyFee;	
Decimal acv = (annualTrans*amtPerTrans)+(annualVol*(amtPerVol/100));	
oli.Actual_Contract_Value__c = acv;	
if(oli.Quantity != null && oli.Number_of_Terms__c != null){	
oli.Total_Cost_Value__c = monthlyFee * oli.Quantity *oli.Number_of_Terms__c;	
}else{	
oli.Total_Cost_Value__c = 0;	 
}	
oli.TotalPrice = oli.Total_Cost_Value__c;	
update oli;	
}	
} */
    
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
        
        /*****Stuti - EBA_SF-1595 entry condition start***/
        /*Opportunity o=[Select type from Opportunity where Id =: OppId];
        List<OpportunityLineItem__mdt> oli = [Select Opportunity_Line_Item_Type__c from OpportunityLineItem__mdt where Type__c =: o.Type limit 1];
        if(!oli.isEmpty()){
            String typ=oli[0].Opportunity_Line_Item_Type__c;
            if(String.isNotBlank(typ)){
                for(String s : typ.split(',')){
                    lineItemTypeOpts.put(s,s);
                }
               
            }
        }*/
        
        /****EBA_SF-1595 condition end****/
        
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
        
        /*****EBA_SF-2174 by Stuti condition start*****/
        List<Subscription_only_products__c> subsProdList=  Subscription_only_products__c.getall().values();
        
        if(subsProdList.size()>0){
            if(String.isNotBlank(subsProdList[0].Product_Name__c)){
                List<String> subProdLst = subsProdList[0].Product_Name__c.split(',');
                for(String prodName : subProdLst){
                    SubsProdSet.add(prodname);            
                }
                if(String.isNotBlank(subsProdList[0].Product_Revenue_Type__c)){
                    List<String> subRevtypeLst = subsProdList[0].Product_Revenue_Type__c.split(',');
                    for(String revenueType : subRevtypeLst){
                        SubsRevenueSet.add(revenueType);               
                    }
                }
            }
            
            prodInfoWrapObj.ProductNames = SubsProdSet;
            prodInfoWrapObj.RevenueTypes = SubsRevenueSet;

        }
        /*****EBA_SF-2174 by Stuti condition start*****/

        return prodInfoWrapObj;
    } 
    
    public class ProductInfoWrapper {
        @AuraEnabled public Set<String> RnwablRevTypes{get;set;}
        @AuraEnabled public Map<String, String> OppLineItemTypes{get;set;}
        @AuraEnabled public Set<String> HWMMntTypes{get;set;}
        @AuraEnabled public Map<String, String> qtyTypes{get;set;} // CSI-304 - QtyType Enhancement by Stuti
        @AuraEnabled public Set<String> ProductNames{get;set;} //EBA_SF-2174 by Stuti
        @AuraEnabled public Set<String> RevenueTypes{get;set;} //EBA_SF-2174 by Stuti
    }
       /*-- CSI-304 - QtyType Enhancement by Stuti--*/
    @AuraEnabled
    public static boolean getOpportunity(String OppId){
         Opportunity O=[Select id, Catm_Record__c from Opportunity where id=:OppId];
         return O.CATM_Record__c;
    }
     /*-- CSI-304 - QtyType Enhancement condition end--*/
    
}