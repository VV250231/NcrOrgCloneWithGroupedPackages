/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: PS_SearchBarComponentControllerTest.Test class                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-29-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-29-2016
# Description...............: This test class is the written with respect to Apex class:FavoriteController
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5
################################################################################################
*/
@IsTest
Public Class FavoriteControllerTest{
    static testmethod  Void getfavproducts(){
     Subscription_only_products__c sop = new Subscription_only_products__c();
        sop.Product_Name__c='test';
         sop.Name='test';
        sop.Product_Revenue_Type__c='Cloud';
        //cs.Other fiels values
        insert sop;
        
       Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
       opp.Type ='Existing Customer - ATMaaS';
       opp.CATM_Record__c = True;
       Update opp;
        
    WrapperFavorite wp=new WrapperFavorite();
    
      List<Id> prdidset=new List<Id>();
      //Create Product Record
        Product2 p01 = new Product2();
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'PRODUCTCATEGORY: ';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        p01.OriginalCorporation__c = 'Cardtronics';
      insert p01;
     //End Product Creation
    
    List<Product2> prdlist=[select id ,name,ISActive from Product2 where IsActive=True];
    //Create user favourite records
    List<User_Favorite_Products__c> usfav1 = new List<User_Favorite_Products__c>(); 
    for(Product2 pd:prdlist){
     User_Favorite_Products__c ob= new User_Favorite_Products__c(); 
         ob.name='Testusfav';
         ob.user__c=UserInfo.getUserId();
         ob.Products__c  =p01.id;
         ob.Frequency_of_Use__c=2;   
         
         usfav1.add(ob);
         }
         insert usfav1;
          system.assert(usfav1.size() >0);
        for(Product2 prid:prdlist){
        prdidset.add(prid.Id);
        }
    //Call methods from Apex class FavoriteController
    Product2  pd=TestRecordsFactory.createProduct(); 
    FavoriteController.getProducts(opp.Id);
    FavoriteController.UnFavProduct(prdidset);
    FavoriteController.insertFavourite(prdidset, opp.Id);
    FavoriteController.deleteFavProduct(prdidset);
    FavoriteController.getSubsOnlyProd();
    FavoriteController.getRnwableProds(opp.Id);
    
    }
         static testMethod void myTest2() {
       // SMB_Partner_Profiles_for_CPQ__c setting = new SMB_Partner_Profiles_for_CPQ__c();
        All_profie_config__c setting = new All_profie_config__c(); 
        Profile p =[Select id from Profile limit 1];
        setting.Name = 'SMB Partner Profiles CPQ';
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = userinfo.getProfileId();
        insert setting;
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        opp.CATM_Record__c = True;
        opp.Contract_Term_Mths__c = 12;
        Update opp;
        List<Product2> insertprodlist=new List<Product2>();
        Product2 pd=TestRecordsFactory.createProduct();
        System.runAs(TestRecordsFactory.getUser()){
            Product2 pd1=TestRecordsFactory.createProduct();
        }
        List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'REVENUETYPE: ';
        p01.Service_Offer_Category__c ='SW';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        p01.OriginalCorporation__c = 'Cardtronics';
        prdlist1.add(P01);
        insertprodlist.add(P01);
        
        List<Product2> prdlist2=new List<product2>();
        Product2 p02 = new Product2();
        p02.name= 'IPS';
        p02.CurrencyIsoCode = 'USD';
        p02.Family = 'Solution';
        p02.Name = '1902-ECPIX LSI';
        p02.Product_Category__c = 'REVENUETYPE: SW ';
        p02.Service_Offer_Category__c ='SW';
        //p02.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p02.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='DIVISION: ';
        p02.isActive=true;
        p01.OriginalCorporation__c = 'NCR';
        prdlist2.add(P02);
        insertprodlist.add(P02);
        
        List<Product2> prdlist3=new List<product2>();
        Product2 p03 = new Product2();
        p03.Name= '2186';
        p03.CurrencyIsoCode = 'USD';
        p03.Family = 'Solution';
        p03.Name = '1902-ECPIX LSI';
        p03.Product_Category__c = 'INDUSTRY: ';
        p03.Service_Offer_Category__c ='SW';
        //p03.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p03.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p03.isActive=true;
        prdlist3.add(P03);
        insertprodlist.add(P03);
        
        
        List<Product2> prdlist4=new List<product2>();
        Product2 p04 = new Product2();
        p04.Name= 'Cloud';
        p04.CurrencyIsoCode = 'USD';
        p04.Family = 'Solution';
        p04.Name = '1902-ECPIX LSI';
        p04.Product_Category__c = 'REVENUETYPE: SW';
        //p04.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p04.Solution_Portfolio__c = 'Payment Solutions';
        p04.isActive=true;
        prdlist4.add(P04);
        
        
        insertprodlist.add(P04);
        
        insert insertprodlist;
        
        Product2 productObj=TestRecordsFactory.createProduct(); 
        List<String> PrdList= new List<String>();
        PrdList.Add(productObj.Id);
          Product2 prod = new Product2();
        prod.Name = '1902-ECPIX LSI';
        prod.Family = 'Hardware';
        prod.CanUseQuantitySchedule = true;
        prod.Service_Offer_Category__c='HW';
         prod.Product_Type__c = 'Topline';
         prod.IsActive = true;
        insert prod;
         PrdList.Add(prod.Id);
       
        
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        
        
        List<User_Favorite_Products__c> usfavlist=new List<User_Favorite_Products__c>(); 
        
        //Create user fav records
        User_Favorite_Products__c usfav1 = new User_Favorite_Products__c(); 
        usfav1.name='Testusfav';
        usfav1.user__c=UserInfo.getUserId();
        usfav1.Products__c  =p01.id;
        usfavlist.add(usfav1);
        
        User_Favorite_Products__c usfav2 = new User_Favorite_Products__c(); 
        usfav2.name='Testusfav1';
        usfav2.user__c=UserInfo.getUserId();
        usfav2.Products__c  =productObj.id;
        usfavlist.add(usfav2);
        insert usfavlist;
        Renewable_Products__c rp = new Renewable_Products__c();
         rp.Name = 'Record1';
         rp.Product_Revenue_Types__c = 'HWM,SWM,Managed Service';
        insert rp;
          system.assertEquals(rp.Name,'Record1');
        
        List<String> FilterString= new List<String>(); 
        FilterString.add('HW');
        FavoriteController.getRnwableProds(opp.Id);
        FavoriteController.getProducts(opp.Id);
        
               
    }

    }