/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central
# File............................: PopulateOCrTeamTest.Test class                                                        
# Created by................: Ahad Mohd                                                                   
# Created Date...........: 11/13/2016                                                                               
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-22-2016
# Description...............: This is the class for SearchBarComponent as part of the Product Scheduler in Lightining Experience.
#  Revision History
 Version     Modified By          Story No.
 V1        Nagendra Singh          NC_AGILE-425
Story No#         Date            DevName                Description
EBA_SF-1669       8th Dec 2021    Varsha Pal             Remove the testcoverage function and make the variables small
														test class - PS_SearchBarComponentControllerTest
BA_SF-2491        19-12-2022      Monika                JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/
public class PS_SearchBarComponentController{
    
    //Method to get the Products on launch of the product selection button
    @AuraEnabled       
    public static List<WrapperFavorite> getPrdrecords(String recordId){
        List<WrapperFavorite> pLst =new List<WrapperFavorite>(),pLst2 =new List<WrapperFavorite>();//make the variable small prodList to pLst - EBA_SF-1669
 			//make the variable small prodList to pLst2 - EBA_SF-1669
        
        //set<Id> olprdId=new set<Id>() ;//commented as not use in the code below
        set<Id> olprdId1 =new set<Id>(),mulLine =new set<Id>();//make the variable small opplineprodid1 to olprdId1 - EBA_SF-1669
        //set<Id> mulLine =new set<Id>();//make the variable small multipleLine to mulLine - EBA_SF-1669
        //@Saritha Logic to get Active PriceBook Entries
        Opportunity o = [Select Id, 
                                Pricebook2Id,
                                CurrencyIsoCode                                
                           from Opportunity  
                         where Id = :recordId];
        String spricebookId = GlobalVariable.pricebookId;
                               
       List<Id> pbeList=new List<Id>();
        List<PricebookEntry> pbeList1 = [Select CurrencyIsoCode,Id,Name,Pricebook2Id,Product2Id,ProductCode,UseStandardPrice, IsActive From PricebookEntry  Where Pricebook2Id = :spricebookId AND CurrencyIsoCode=:o.CurrencyIsoCode AND ISActive=TRUE ];
                   for(PricebookEntry pb:pbeList1 ){
                       pbeList.add(pb.Product2Id);
                   } 
        //Start V1       
        User u = [SELECT Division__c FROM User WHERE id = :UserInfo.getUserId()];       
        List<string> usrDiv= new List<string>(); //make the variable small UserDivision to usrDiv - EBA_SF-1669     
        if(u.Division__c!=null){        
            usrDiv = u.Division__c.split('[;]');      
        }       
        set<String> setDiv = new set<String>(); //make the variable small SetDivision to setDiv - EBA_SF-1669  
        for(String s: usrDiv){        
            setDiv.add(s);     
        }       
        List<Product2> lstObj;      
        if(usrDiv.size()>0){      
             lstObj = [select id, name from product2 where Industry__c in :setDiv And isActive=true AND Id IN:pbeList order by Name ASC];      
        }       
        else{       
             lstObj = [select id, name from product2 where isActive=true AND Id IN:pbeList order by Name ASC];      
        } 
        //End of V1
        List<OpportunityLineItem> mpOppLineItems = [select id,Product2Id from OpportunityLineItem where OpportunityId =:recordId];
        List<User_Favorite_Products__c> usfavlist= [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                                                    where User__c=:UserInfo.getUserId()];
        set<Id> prdid=new set<Id>() ;   
        
        
        for(User_Favorite_Products__c fav: usfavlist){
            
            prdid.add(fav.Products__c);
            
        }
        for(OpportunityLineItem oppln: mpOppLineItems ){  
            if(olprdId1.contains((oppln.Product2Id))){
                mulLine.add(oppln.Product2Id);
            }
            olprdId1.add(oppln.Product2Id);            
        }        
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            if(prdid.contains(pd.id) && (olprdId1.contains(pd.id))){
                wp.favselected=True; 
                wp.HasSchedule=True;
                wp.ProductName=pd.name;
                wp.SetsortColor=True;
                if(mulLine.contains(pd.id)){
                    wp.Hasmultiple=true;
                }else{
                    wp.Hasmultiple=false;
                }
                pLst2.add(wp); 
            }   
        }
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            wp.ProductName=pd.name;
           // wp.SetsortColor=True;
            if(prdid.contains(pd.id) && (!olprdId1.contains(pd.id))){
                wp.favselected=True; 
                wp.HasSchedule=false;
                
                if(mulLine.contains(pd.id)){
                    wp.Hasmultiple=false;
                }else{
                    wp.Hasmultiple=true;
                }
                pLst2.add(wp); 
            }   
            
        }     
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            wp.ProductName=pd.name;
            wp.SetsortColor=True;
            if(!prdid.contains(pd.id) && (olprdId1.contains(pd.id))){
                wp.favselected=false; 
                wp.HasSchedule=true;
                if(mulLine.contains(pd.id)){
                    wp.Hasmultiple=True;
                }else{
                    wp.Hasmultiple=false;
                }
                pLst2.add(wp);
            }
        }
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp= new WrapperFavorite();
            wp.prd = pd;
            wp.isselected = false;
            wp.ProductName =pd.name;
            if(!prdid.contains(pd.id) && (!olprdId1.contains(pd.id))){
                wp.favselected=false; 
                wp.HasSchedule=false;
                if(mulLine.contains(pd.id)){
                    wp.Hasmultiple=false;
                }else{
                    wp.Hasmultiple=true;
                    
                }
                pLst2.add(wp); 
            }   
        }
        
        pLst.addAll(pLst2);
        return pLst;
        
    }
    //Global Search method by Entering Name    
    @AuraEnabled            
    public static List<WrapperFavorite> findByName(String searchKey) {
        String name = '%' + searchKey + '%';
        List<WrapperFavorite> pLst1 =new List<WrapperFavorite>();//make the variable small prodList1 to pLst1 - EBA_SF-1669
        List<Product2> lstObj = [select id, name from product2 WHERE name LIKE :name ];
        for(Product2 pd: lstObj) {
            WrapperFavorite wp1= new WrapperFavorite();
            wp1.prd = pd;
            wp1.isselected = false;
            pLst1.add(wp1);
        }
        
        return pLst1;
    }
    
    
    //This is the method is used to get the picklist values for the Pd
    @AuraEnabled
    public static list<WrapperFavorite> getPrdCategorypickval()     
    {
         List<PMDMRevenueType__c> PMDMRev = PMDMRevenueType__c.getall().values();//make the variable small PMDMRevenue to PMDMRev - EBA_SF-1669
       // List<String> opts = new List<String>();//commented as not use in the code below
        list<WrapperFavorite> PrdCatpickval = new list<WrapperFavorite>();//make the variable small PrdCategorypickval to PrdCatpickval - EBA_SF-1669
        
        
        /*Schema.DescribeFieldResult fieldResult = Product2.Service_Offer_Category__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) { 
            WrapperFavorite wp = new WrapperFavorite();
            if(f.getLabel()!='IPS'){
            wp.FilterName = f.getLabel();
            wp.selected = false;
            PrdCategorypickval.add(wp);
            options.add(f.getLabel());
            }
        }  */  
        for (PMDMRevenueType__c PR: PMDMRev) { 
            WrapperFavorite wp = new WrapperFavorite();
            wp.FilterName = PR.Name;
            wp.selected = false;
            PrdCatpickval.add(wp);
            ///options.add(f.getLabel());
        }
        return PrdCatpickval;
    } 
    
    //This is the method is used to get the picklist values for division
    @AuraEnabled
    public static list<WrapperFavorite> getPrdDivisionvalues() {  
        //Start V1
        User u = [SELECT Division__c FROM User WHERE id = :UserInfo.getUserId()];
        List<string> UserDiv = new List<string>();//make the variable small UserDivision to UserDiv - EBA_SF-1669
        if(u.Division__c != null){
            UserDiv = u.Division__c.split('[;]');
        } 
        //End of V1
        list<WrapperFavorite> PrdDivVal = new list<WrapperFavorite>(); //make the variable small PrdDivisionval to PrdDivVal - EBA_SF-1669
        set<String> SetDiv = new set<String>();//make the variable small SetDivision to SetDiv - EBA_SF-1669
        for(String s: UserDiv){
            SetDiv.add(s);
        }
        
        //List<String> opts = new List<String>();//commented as not used in below code - EBA_SF-1669
        //list<WrapperFavorite> PrdCatpickval = new list<WrapperFavorite>();//commented as not used in below code - EBA_SF-1669              
        Schema.DescribeFieldResult fldRes = Product2.Industry__c.getDescribe();//make the variable small fieldResult to fldRes - EBA_SF-1669
        
        List<Schema.PicklistEntry> ple = fldRes.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) { 
            WrapperFavorite wp = new WrapperFavorite();
            wp.FilterName = f.getLabel();
            if(SetDiv.contains(f.getLabel())){
                wp.selected = true;
            }
            else{
                wp.selected = false;
            }
            PrdDivVal.add(wp);
        }       

        return PrdDivVal;
    }
    
    //Remove the  Individal Product from Favourites
    @AuraEnabled
    public static void removeFavourite(String ProductId) { 
        
        List<User_Favorite_Products__c> usfavlist= [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                                                    where User__c=:UserInfo.getUserId() AND Products__c =:ProductId];       
        if(usfavlist.size()>0){  
            delete usfavlist;         
        }           
    }  
    @AuraEnabled
    public static void dummyCall() {
         System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement
    } 
    @AuraEnabled
    public static String addFavourite(String ProductId){
        string msg;//make the variable small Message to msg - EBA_SF-1669
        try{
            Set<String> SetProdId = new Set<String>();//make the variable small SetProductId to SetProdId - EBA_SF-1669
            //for(String pid : ProductId){
            SetProdId.add(ProductId);
            //}
            List<User_Favorite_Products__c> listofFab=new List<User_Favorite_Products__c>();
            Map<Id,String> UFP_ToProdId =  new Map<Id,String>();//make the variable small UFP_ToProductId to UFP_ToProdId - EBA_SF-1669
            List<User_Favorite_Products__c> AlreadyFavProd =  [select id, name,user__c,Frequency_of_Use__c,Products__r.Name,Products__c  from User_Favorite_Products__c 
                                                                   where User__c=:UserInfo.getUserId() and Products__c  !=null ];//make the variable small AlreadyFavProducts to AlreadyFavProd - EBA_SF-1669
            for(User_Favorite_Products__c UFP : AlreadyFavProd){
                if(!UFP_ToProdId.containskey(UFP.Products__c)){
                    UFP_ToProdId.put(UFP.Products__c,UFP.Products__r.Name);
                }
            }
            
            for(Id selidobj : SetProdId){//make the variable small selectedidobj to selidobj - EBA_SF-1669
                if(!UFP_ToProdId.containsKey(selidobj)){
                    User_Favorite_Products__c obj = new User_Favorite_Products__c();
                    obj.user__c = UserInfo.getUserId();
                    obj.Products__c = selidobj;
                    listofFab.add(obj);
                }
            }
            if(listofFab.size()>0){
                insert listofFab;
            }
            
        }
        catch(DmlException e) 
        { 
            msg= e.getMessage();
        }
        return msg;
    }
    
    @AuraEnabled 
    public static String removeSchedule(String SelectedProductId, String recordId) { 
        List<OpportunityLineItem> opplist= [select id,Product2Id,Name  from OpportunityLineItem where OpportunityId =:recordId AND Product2Id=: SelectedProductId ];
        Set<id> setDup=new Set<id>();
        List<OpportunityLineItem> oliDel=new List<OpportunityLineItem>(); 
        //checking multiple instance
        for(OpportunityLineItem opp : opplist){
            if(setDup.contains(opp.Product2Id)){
                return opp.name;
            }{
                setDup.add(opp.Product2Id);
            }
            oliDel.add(opp);
        }
        Delete oliDel;
        return 'yes';
        
    }
    
    @AuraEnabled
    public static List<WrapperFavorite> doallunfavProduct(List<String> Productlist, List<String> filterArr, String sKey,  String recordId) { 
        List<User_Favorite_Products__c> favrecords= [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                                                     where User__c=:UserInfo.getUserId() AND Products__c IN:Productlist];
        set<String> prdid=new set<String>();          
        List<User_Favorite_Products__c> usfavlist= new List<User_Favorite_Products__c>();
        // if all are favourite in the list after search then user is trying to remove favorite
        if(favrecords.size()==Productlist.size()){
            Delete favrecords;
        }else{
            for(User_Favorite_Products__c fav: favrecords){            
                prdid.add(fav.Products__c);            
            }
            for(Id prd:Productlist){                          
                if(!prdid.contains(prd)){
                    // wp.favselected=True; 
                    User_Favorite_Products__c usfav = new User_Favorite_Products__c();
                    usfav.Products__c=prd;
                    usfav.User__c=UserInfo.getUserId();                           
                    usfavlist.add(usfav);  
                }           
            }   
            if(usfavlist.size()>0) {
                insert usfavlist;
            }
            
        }             
        return SearchFilteredProducts(filterArr, sKey, recordId);
    }
    
    @AuraEnabled
    public static List<WrapperFavorite> doallunScheduledProduct(List<String> filterArr1, String sKey1, String recordId) { 
        
        return SearchFilteredProducts(filterArr1, sKey1, recordId);
    }
    
    //This method is to change the search based on the Filters selected.
    @AuraEnabled
    public static List<WrapperFavorite> SearchFilteredProducts(List<String> filterSelected, String searchKey, String recordId){
        set<string> prodCat = new set<string>(), prodDiv = new set<string>();
        set<Id> opplineprodid2=new set<Id>(),multipleLine1 =new set<Id>();
        List<Product2> lstObj=new List<Product2>();
        for(String str: filterSelected){
            String str1=str.toUpperCase();
            if(str1.contains('REVENUETYPE: ')){
                prodCat.add(str1.remove('REVENUETYPE: '));
            }
            if(str1.contains('INDUSTRY: ')){
                prodDiv.add(str1.remove('INDUSTRY: '));
            }
        }
        List<WrapperFavorite> prodList2 =new List<WrapperFavorite>();
        //Adding logic to get Active pricebooks 
          
          Opportunity o = [Select Id, 
                                Pricebook2Id,
                                CurrencyIsoCode                                
                           from Opportunity  
                         where Id = :recordId];
        String spricebookId = GlobalVariable.pricebookId;
                               
       List<Id> pbeList=new List<Id>();
        List<PricebookEntry> pbeList1 = [Select CurrencyIsoCode,Id,Name,Pricebook2Id,Product2Id,ProductCode,UseStandardPrice, IsActive From PricebookEntry  Where Pricebook2Id = :spricebookId AND CurrencyIsoCode=:o.CurrencyIsoCode AND ISActive=TRUE ];
                   for(PricebookEntry pb:pbeList1 ){
                       pbeList.add(pb.Product2Id);
                   } 
                   
        String qury='select id, name, Service_Offer_Category__c, Industry__c , isActive from product2';
        /*String qury='select id, name, Service_Offer_Category__c, isActive, Industry__c from product2 where isActive=true';*/
        if(!String.isEmpty(searchKey)){
            String searchKeyCondition = '%' + searchKey + '%';
            qury=qury + ' WHERE name like :searchKeyCondition'; 
            /*qury=qury + ' WHERE  isActive=True AND name like \'%'+searchKey+'%\'' ;*/
        }
        if(prodCat.size()>0){
            String pc='(';                 
            Integer i=0;
            for(String s: prodCat){
                if(i==0){
                    pc=pc+'\''+String.escapeSingleQuotes(s); 
                }
                if(i>0 && i<prodCat.size()){
                    pc=pc+'\',\''+String.escapeSingleQuotes(s);
                }
                else{
                    if(i!=0)
                        pc=pc+'\',\''+String.escapeSingleQuotes(s);  
                }
                i++;
            }
            pc=pc+'\')';
            if(String.isEmpty(searchKey)){
                qury=qury + ' WHERE Service_Offer_Category__c IN '+pc; 
                
            }else{
                qury=qury + ' and Service_Offer_Category__c IN '+pc;   
            }
        }
        if(prodDiv.size()>0){
            String dv='(';                
            Integer i=0;
            for(String s: prodDiv){
                if(i==0){
                    dv=dv+'\''+String.escapeSingleQuotes(s);   
                }
                if(i>0 && i<prodCat.size()){
                    dv=dv+'\',\''+String.escapeSingleQuotes(s);
                }
                else{
                    if(i!=0)
                        dv=dv+'\',\''+String.escapeSingleQuotes(s);  
                }
                i++;
            }
            dv=dv+'\')';
            if(!String.isEmpty(searchKey) || prodCat.size()>0){
                qury=qury + ' and Industry__c IN'+dv;
                
            }else{
                qury=qury + ' WHERE Industry__c IN'+dv;   
            }
        }
        //Start of V1
          if(prodDiv.size()==0 && prodCat.size()==0 && String.isBlank(searchKey)){
            qury=qury+' where IsActive=true AND Id IN :pbeList Order By Name ASC';
        }
        else{
            qury=qury+' AND IsActive=true AND Id IN :pbeList Order By Name ASC';
        }
        //End of V1
        lstObj=Database.query((qury))   ; 
        List<User_Favorite_Products__c> usfavlist= [select id, name,user__c,Products__c  from User_Favorite_Products__c 
                                                    where User__c=:UserInfo.getUserId()];
        set<Id> prdid=new set<Id>() ;  
        //start of Logic added by Nagendra
        set<Id> SearchedProd=new set<Id>() ;
        for(Product2 obj : lstObj){
            SearchedProd.add(obj.id);
        }
        Map<Id,boolean> mpProdIdSched = new Map<Id,boolean>();//make the variable small mpProductIdToHasSchedule to mpProdIdSched - EBA_SF-1669
        List<OpportunityLineItem> mpOppLineItems = [select id,Product2Id,HasSchedule from OpportunityLineItem where OpportunityId =: recordId AND Product2Id In : SearchedProd limit 50000];
        for(OpportunityLineItem obj : mpOppLineItems){
            if(!mpProdIdSched.containskey(obj.Product2Id)){
                mpProdIdSched.put(obj.Product2Id,obj.HasSchedule);
            }
        }
        //End of logic added by Nagendra
        
        
        for(User_Favorite_Products__c fav: usfavlist){            
            prdid.add(fav.Products__c);            
        }
        
         for(OpportunityLineItem oppln: mpOppLineItems ){  
            if(opplineprodid2.contains((oppln.Product2Id))){
                multipleLine1.add(oppln.Product2Id);
            }
            opplineprodid2.add(oppln.Product2Id);            
        } 
        
        
        for(Product2 pd: lstObj) {
            WrapperFavorite wp2= new WrapperFavorite();
            wp2.prd = pd;
            if(!prdid.contains(pd.id)){
                wp2.favselected = false;
            }else{
                wp2.favselected = true;
            }
            wp2.isselected = false;
            //start of logic added by Nagendra
            if(mpProdIdSched.containskey(pd.id)){
                wp2.HasSchedule = true;
            }else{
                wp2.HasSchedule = false;
            }
            
            if(multipleLine1.contains(pd.id)){
                    wp2.Hasmultiple=true;
              system.debug('XXXX'+wp2.Hasmultiple);
                }else{
                    wp2.Hasmultiple=false;
                }
            //End of logic added by Nagendra
            prodList2.add(wp2);
        }
        return prodList2;
        
    }
    
    //Start Code By Pankaj for bundle Component//
    
    @AuraEnabled
    Public static List<Favorite_Bundle__c> getUserFavoriteBundle(){
       List<Favorite_Bundle__c> UserBundleOfProduct = new List<Favorite_Bundle__c>();
        for(Favorite_Bundle__c obj :[Select id,name from Favorite_Bundle__c where ownerid=:UserInfo.getUserId()]){
            UserBundleOfProduct.add(obj);
        }
    return UserBundleOfProduct;
    }
    //End Code By Pankaj for bundle Component//
    
}