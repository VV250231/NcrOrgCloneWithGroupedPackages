/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: PS_SearchBarComponentControllerTest.Test class                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-29-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-29-2016
# Description...............: This test class is the written with respect to Apex class:PS_SearchBarComponentController
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/

@IsTest
Public class  PS_SearchBarComponentControllerTest{

static testMethod void getPrdrecordstest() {
    PMDMRevenueType__c cs = new PMDMRevenueType__c();
        cs.Name = 'PS';
        
     insert cs;
List<String> filterlist=new List<String>();
WrapperFavorite wp= new WrapperFavorite();
List<Product2> insertprodlist=new List<product2>();
//Creating products 
  Product2 pd=TestRecordsFactory.createProduct();
  System.assertNotEquals(pd.id, null,'Product is Null');  
  pd.IsActive=True;
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
  //end products creation     
   
   //Creating Opportunity Line Items               
    Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
    List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
    List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
    OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
    
         Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
         bundle.Name = 'Test bundle';
         bundle.ownerid = UserInfo.getUserId();
         insert bundle;
    
      Test.starttest(); 
     String name = 'Cloud';
     set<Id> opplineprodid1=new set<Id>();
     set<Id> multipleLine =new set<Id>();
     filterlist.add(p01.Product_Category__c);
     filterlist.add(p02.Product_Category__c);
     //filterlist.add('INDUSTRY: Financial');
     
     //filterlist.add(p01.Division__C);
     List<String> prdids=new List<String>();
     prdids.add(pd.Id);
     prdids.add(p02.Id);
     prdids.add(p03.Id);

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
         usfav2.Products__c  =p02.id;
         usfavlist.add(usfav2);
         insert usfavlist;
        String key='Cloud';
        
       //Call methods from Apex class to execute           
        PS_SearchBarComponentController.getPrdrecords(opp.Id);
        PS_SearchBarComponentController.getPrdCategorypickval();
        PS_SearchBarComponentController.getPrdDivisionvalues();
        PS_SearchBarComponentController.removeFavourite(p01.Id);
        PS_SearchBarComponentController.addFavourite(pd.Id);
        PS_SearchBarComponentController.removeSchedule(pd.Id, opp.Id);
         
        PS_SearchBarComponentController.findByName('1902');
         
        PS_SearchBarComponentController.SearchFilteredProducts(filterlist,'1902',opp.Id);
        PS_SearchBarComponentController.doallunfavProduct(prdids,filterlist,'1902',opp.Id);
    PS_SearchBarComponentController.doallunScheduledProduct(filterlist,'1902',opp.Id);
        PS_SearchBarComponentController.dummyCall();
       // PS_SearchBarComponentController.TestCoverage();
        PS_SearchBarComponentController.getUserFavoriteBundle();
    Test.stoptest();
       
        }
    
static testMethod void getPrdrecordstest1() {
     Profile p = [SELECT Id FROM Profile WHERE Name='04 NSC UI Administrator']; 
        
        User userObj = new User(Alias = 'commuser', Email='standarduser1@testorg.com', quicklook_Id__c = 'ab123456',
                           EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='stand11122@testorg.com',Division__c='Hospitality;Retail');
        insert userObj;
        System.assertNotEquals(userObj.id, null,'Opportunity is Null');  
    System.runas(userObj){
    PMDMRevenueType__c cs = new PMDMRevenueType__c();
        cs.Name = 'PS';
        
     insert cs;
List<String> filterlist=new List<String>();
WrapperFavorite wp= new WrapperFavorite();
List<Product2> insertprodlist=new List<product2>();
//Creating products 
  Product2 pd=TestRecordsFactory.createProduct();
  pd.IsActive=True;
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
  //end products creation     
   
   //Creating Opportunity Line Items               
    Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
    List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
    List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
    OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
    
         Favorite_Bundle__c bundle = new Favorite_Bundle__c(); 
         bundle.Name = 'Test bundle';
         bundle.ownerid = UserInfo.getUserId();
         insert bundle;
    
      Test.starttest(); 
     String name = 'Cloud';
     set<Id> opplineprodid1=new set<Id>();
     set<Id> multipleLine =new set<Id>();
     filterlist.add(p01.Product_Category__c);
     filterlist.add(p02.Product_Category__c);
     filterlist.add('INDUSTRY: Financial');
     
     //filterlist.add(p01.Division__C);
     List<String> prdids=new List<String>();
     prdids.add(pd.Id);
     prdids.add(p02.Id);
     prdids.add(p03.Id);

      List<User_Favorite_Products__c> usfavlist=new List<User_Favorite_Products__c>(); 
        
       //Create user fav records
        User_Favorite_Products__c usfav1 = new User_Favorite_Products__c(); 
         usfav1.name='Testusfav';
         usfav1.user__c=userObj.id;
         usfav1.Products__c  =p01.id;
         usfavlist.add(usfav1);
         
         User_Favorite_Products__c usfav2 = new User_Favorite_Products__c(); 
         usfav2.name='Testusfav1';
         usfav2.user__c=userObj.Id;
         usfav2.Products__c  =p02.id;
         usfavlist.add(usfav2);
         insert usfavlist;
        String key='Cloud';
        
       //Call methods from Apex class to execute           
        PS_SearchBarComponentController.getPrdrecords(opp.Id);
        PS_SearchBarComponentController.getPrdCategorypickval();
        PS_SearchBarComponentController.getPrdDivisionvalues();
        PS_SearchBarComponentController.removeFavourite(p01.Id);
        PS_SearchBarComponentController.addFavourite(pd.Id);
        PS_SearchBarComponentController.removeSchedule(p01.Id, opp.Id);
         
        PS_SearchBarComponentController.findByName('1902');
         
        PS_SearchBarComponentController.SearchFilteredProducts(filterlist,'1902',opp.Id);
        PS_SearchBarComponentController.doallunfavProduct(prdids,filterlist,'1902',opp.Id);
    PS_SearchBarComponentController.doallunScheduledProduct(filterlist,'1902',opp.Id);
        PS_SearchBarComponentController.dummyCall();
       // PS_SearchBarComponentController.TestCoverage();
        PS_SearchBarComponentController.getUserFavoriteBundle();
    Test.stoptest();
       
        }
}
}