@isTest
Public Class GlobalSearchControllerTest{
   
    Public Static User getUser()
    {
       User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }  
    static testMethod void myTest() {
       // SMB_Partner_Profiles_for_CPQ__c setting = new SMB_Partner_Profiles_for_CPQ__c();
        All_profie_config__c setting = new All_profie_config__c(); 
        Profile p =[Select id from Profile limit 1];
        setting.Name = 'SMB Partner Profiles CPQ';
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = p.Id;
        insert setting;
        
        List<Product2> insertprodlist=new List<Product2>();
        Product2 pd=TestRecordsFactory.createProduct();
        System.runAs(getUser()){
            Product2 pd1=TestRecordsFactory.createProduct();
        }
        pd.IsActive=True;
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        opp.Contract_Term_Mths__c=2;
        List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'REVENUETYPE: ';
        p01.Service_Offer_Category__c ='SW';
        p01.OriginalCorporation__c = 'Cardtronics';
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
        p03.OriginalCorporation__c= 'NCR';
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
        GlobalSearchController.getProductList('NCR',PrdList, opp.id);

        opp.Type ='Existing Customer - ATMaaS';
        opp.CATM_Record__c = True;
        Update opp;
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        oli.Number_of_Terms__c = 2;
        
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
        
        GlobalSearchController.getFirstChunk(opp.Id);
        
        List<String> FilterString= new List<String>();
        FilterString.add('HW');
        GlobalSearchController.getNextPageFor_Filter(PrdList,FilterString, opp.Id);
        GlobalSearchController.getNextPageFor_SearchString(PrdList,'ncr', opp.Id);
        GlobalSearchController.SearchWithFilter(FilterString,'ncr',PrdList, opp.Id);
        GlobalSearchController.GetNextPage(PrdList, opp.Id);
        GlobalSearchController.getFilterResult(FilterString,PrdList, opp.Id);
        GlobalSearchController.get_PMDM_Product_Catoget(opp.Id);
        GlobalSearchController.getRnwableProds(opp.Id);
        
        List<Product2> lt = new List<Product2>();
        lt = GlobalSearchController.GetNextPage(PrdList, opp.Id);
        system.assert(lt!=null);
        
    }
    
    
    static testMethod void myTest1() {
        
        Product2 productObj=TestRecordsFactory.createProduct();
        User_Favorite_Products__c usfav1 = new User_Favorite_Products__c(); 
        usfav1.name='Testusfav';
        usfav1.user__c=UserInfo.getUserId();
        usfav1.Products__c  =productObj.id;
        
        Subscription_only_products__c sop = new Subscription_only_products__c();
        sop.Product_Name__c='test1';
        sop.Name='test1';
        sop.Product_Revenue_Type__c='Cloud';
        //cs.Other fiels values
        insert sop;
        
        ScrollComponentConreoller.addFavourite(productObj.Id);
        ScrollComponentConreoller.RemoveFavourite(productObj.Id);
        ScrollComponentConreoller.getSubsOnlyProd();
        
        
    }
    
    
    static testMethod void myTest2() {
        Product2 p01 = new Product2();
        //p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'REVENUETYPE: ';
        p01.Service_Offer_Category__c ='SW';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        insert p01;
        //FilerComponentController.getFilterResult('NCR');
        List<Product2> prdlist1=new List<product2>();
        prdlist1 = FilerComponentController.getFilterResult('1902');
        system.assertEquals(prdlist1[0].Name, '1902-ECPIX LSI','Incorrect product name');
    }
     static testMethod void myTest3() {
       // SMB_Partner_Profiles_for_CPQ__c setting = new SMB_Partner_Profiles_for_CPQ__c();
        All_profie_config__c setting = new All_profie_config__c(); 
        Profile p =[Select id from Profile limit 1];
        setting.Name = 'SMB Partner Profiles CPQ';
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = userinfo.getProfileId();
        insert setting;
        
        List<Product2> insertprodlist=new List<Product2>();
        Product2 pd=TestRecordsFactory.createProduct();
        System.runAs(getUser()){
            Product2 pd1=TestRecordsFactory.createProduct();
        }
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        opp.CATM_Record__c = False;
        Update opp;
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
        p02.OriginalCorporation__c = 'Cardtronics';
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
        p04.OriginalCorporation__c = 'NCR';
        prdlist4.add(P04);
        
        
        insertprodlist.add(P04);
        
        insert insertprodlist;
        
        Product2 productObj=TestRecordsFactory.createProduct(); 
        List<String> PrdList= new List<String>();
        PrdList.Add(productObj.Id);
          Product2 prod = new Product2();
        prod.Name = GlobalSearchController.getPartnerProducts()[0];
        prod.Family = 'Hardware';
        prod.CanUseQuantitySchedule = true;
        prod.Service_Offer_Category__c='HW';
         prod.Product_Type__c = 'Topline';
         prod.IsActive = true;
        insert prod;
         PrdList.Add(prod.Id);
        GlobalSearchController.getProductList('NCR',PrdList,opp.id);
 
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        oli.Number_of_Terms__c = 2;
        
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
        GlobalSearchController.getFirstChunk(opp.Id);
        
        List<String> FilterString= new List<String>();
        FilterString.add('HW');
        GlobalSearchController.getNextPageFor_Filter(PrdList,FilterString, opp.Id);
        GlobalSearchController.getNextPageFor_SearchString(PrdList,'ncr', opp.Id);
        GlobalSearchController.SearchWithFilter(FilterString,'ncr',PrdList, opp.Id);
        GlobalSearchController.GetNextPage(PrdList, opp.Id);
        GlobalSearchController.getFilterResult(FilterString,PrdList, opp.Id);
        GlobalSearchController.get_PMDM_Product_Catoget(opp.Id);
        //GlobalSearchController.getRnwableProds(opp.Id);
        GlobalSearchController.ProductInfoWrapper prodInfoWrapObj= new GlobalSearchController.ProductInfoWrapper(); 
        prodInfoWrapObj.HWMMntTypes = GlobalSearchController.getRnwableProds(opp.Id).HWMMntTypes;
        Boolean chk = prodInfoWrapObj.HWMMntTypes.contains('Connected HWM') ;
         system.assertEquals(chk, true);
		
               
    }
    
    
}