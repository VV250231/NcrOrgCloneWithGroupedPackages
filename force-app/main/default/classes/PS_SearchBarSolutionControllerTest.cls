@IsTest
Public class  PS_SearchBarSolutionControllerTest{

static testMethod void getPrdrecordstest() {
	   Product_Solution__c PSObj = new Product_Solution__c();
	   PSObj.Solution_ID__c = 'A100Q';
	   insert PSObj;
	   
       
       WrapperFavorite wp= new WrapperFavorite();
       List<Product2> insertprodlist=new List<product2>();
       //Creating products 
       Product2 pd=TestRecordsFactory.createProduct();
       pd.IsActive=True;
	   System.assertNotEquals(pd.id, null,'Product is Null');  
       List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'PRODUCTCATEGORY: ';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
		//p01.Product_Solution__c =PSObj.id;
        prdlist1.add(P01);
        insertprodlist.add(P01);

 List<Product2> prdlist2=new List<product2>();
        Product2 p02 = new Product2();
        p02.name= 'IPS';
        p02.CurrencyIsoCode = 'USD';
        p02.Family = 'Solution';
        p02.Name = '1902-ECPIX LSI';
        p02.Product_Category__c = 'PRODUCTCATEGORY:SW ';
        //p02.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p02.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='DIVISION: ';
        p02.isActive=true;
		//p02.Product_Solution__c =PSObj.id;
        prdlist2.add(P02);
        insertprodlist.add(P02);
        
 List<Product2> prdlist3=new List<product2>();
        Product2 p03 = new Product2();
        p03.Name= '2186';
        p03.CurrencyIsoCode = 'USD';
        p03.Family = 'Solution';
        p03.Name = '1902-ECPIX LSI';
        p03.Product_Category__c = 'HW';
        //p03.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p03.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p03.isActive=true;
		//p03.Product_Solution__c =PSObj.id;
        prdlist3.add(P03);
        insertprodlist.add(P03);
         
         
        List<Product2> prdlist4=new List<product2>();
        Product2 p04 = new Product2();
        p04.Name= 'Cloud';
        p04.CurrencyIsoCode = 'USD';
        p04.Family = 'Solution';
        p04.Name = '1902-ECPIX LSI';
        p04.Product_Category__c = 'PRODUCTCATEGORY:SW';
        //p04.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p04.Solution_Portfolio__c = 'Payment Solutions';
		//p04.Product_Solution__c =PSObj.id;
        p04.isActive=true;
        prdlist4.add(P04);
        

        insertprodlist.add(P04);
    

   insert insertprodlist;   
  //end products creation     
   
    Product_Solution_Mapping__c PSM = new Product_Solution_Mapping__c(Product__c = P01.id,Product_Solution__c=PSObj.id);
    insert PSM;
    
    Product_Solution_Mapping__c PSM1 = new Product_Solution_Mapping__c(Product__c = P02.id,Product_Solution__c=PSObj.id);
    insert PSM1;
    
     Product_Solution_Mapping__c PSM2 = new Product_Solution_Mapping__c(Product__c = P03.id,Product_Solution__c=PSObj.id);
    insert PSM2;
    
   //Creating Opportunity Line Items
    
    EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
    ebdedd.Name = 'EDSD_Calc';
    ebdedd.isActive__c = true;
    insert ebdedd;
    
    Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
    List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
    List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
    OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
      Test.starttest(); 
     String name = 'Cloud';



      List<User_Favorite_Products__c> usfavlist = new List<User_Favorite_Products__c>(); 
        
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
		 
        
       //Call methods from Apex class to execute           
        PS_SearchSolutionsController.getProducts(PSObj.Id,opp.id);
        PS_SearchSolutionsController.removeFavourite(p01.Id);
        PS_SearchSolutionsController.addFavourite(pd.Id);
        
         

    Test.stoptest();
       
        }
}