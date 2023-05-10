/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: ProductSelectionTest.Test class                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-29-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-29-2016
# Description...............: This test class is the written with respect to Apex class:ProductSelection
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/
@IsTest
Public class  ProductSelectionTest{ 
    
    static testMethod void selectedPrdactions() {
        
        List<String> strlist=new List<String>();
        List<String> prdstrlist=new List<String>();
        List<Boolean> gg = new List<Boolean>() ;
        gg.add(false) ;
        List<String> serviceOLIList = new List<String>() ;
        serviceOLIList.add('New') ;
        List<String> HWMMntcTypeArray = new List<String>{'Connected HWM'} ;
        List<String> QtyTypeArray = new List<String>{'Cards'} ;
        EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
        ebdedd.Name = 'EDSD_Calc';
        ebdedd.isActive__c = true;
        insert ebdedd;   
        
        
        
        
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        
        Product2 p01 = new Product2();
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'PRODUCTCATEGORY: ';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p01.isActive=true; 
        insert p01;
        
        Product2 p02 = new Product2();
        p02.CurrencyIsoCode = 'USD';
        p02.Family = 'Solution';
        p02.Name = '1902-ECPIX LSI';
        p02.Product_Category__c = 'PRODUCTCATEGORY: ';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p02.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p02.isActive=true; 
        insert p02;
        
        User_Favorite_Products__c ob= new User_Favorite_Products__c(); 
        ob.name='Testusfav';
        ob.user__c=UserInfo.getUserId();
        ob.Products__c  =p01.id;
        ob.Frequency_of_Use__c=2;    
        insert ob;
        prdstrlist.add(p01.id);
        
        PricebookEntry pbe=TestRecordsFactory.createPriceBookEntry(p01);
        //OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        OpportunityLineItem oliprd=TestRecordsFactory.createOpportunityLineItem_Product(opp,pbe);
        
        //strlist.add(oli.Id);
        strlist.add(oliprd.Id);
        Test.startTest() ;
        List<String> prdstglist=new List<String>();
        prdstglist.add(p01.id);
        List<String> prdstglist2=new List<String>();
        prdstglist2.add(p02.id);
            
            
        
       
        String JSON='[{"AvailableforSubscription":false,"Eroorvalue":false,"isCATMProduct":true,"MonthlyFee":4,"NoOfTerms":202,"OliId":'+ oliprd.Id +',"OneTimeFee":4,"ProductCatogery":"HW","ProductId":"01t0g00000ON7S2AAL","ProductName":"0757","qtyTyp":"Flat Rate","quantity":2,"totalValue":1616,"unitPrice":4.0000,"value":false}]';
        try{
        ProductSelection.getProductList(opp.id);
        // ProductSelection.SelectforFavroute1(new List<String>{'0030g00002RohVj'});
        ProductSelection.SelectforFavroute1(prdstglist);
        ProductSelection.SelectforFavroute1(prdstglist2);
        ProductSelection.SelectforDel(strlist);
        ProductSelection.SelectforDel(strlist);
        ProductSelection.removeSchedule(prdstglist,opp.id);
        ProductSelection.InsertOpportunityLineItem(prdstrlist,opp.id , gg, serviceOLIList, HWMMntcTypeArray, QtyTypeArray);
        
        string testString='{"data": [{"value":false,"quantity":1,"unitPrice":100,"totalValue":0,"ProductName":"1611-Server (S500MT)","OliId":"00k54000003D8VUAA0","ProductId":"01t7000000GdbvgAAB"}]}';
        ProductSelection.ClientToServerProductSynk(testString);
        ProductSelection.getOpportunity(opp.Id);
        ProductSelection.updateLineItemTerm(oliprd.Id, 1002);

    }
    Catch(Exception e){
     Test.stopTest() ;   
    }
        ProductSelection.saveBulkProduct(opp.Id, true, '10', '');
        //ProductSelection.saveBulkProduct(opp.Id, true, '10', JSON);
    }
    ProductSelection.cls_data obj = new ProductSelection.cls_data();
    ProductSelection.SubsProductWrapper obj1= new ProductSelection.SubsProductWrapper();
    
    @isTest(SeeAllData=true)
    public static void myTestforgetSubsOnlyProd() {
        
        Subscription_only_products__c sop = new Subscription_only_products__c();
        sop.Product_Name__c='test';
        sop.Name='test';
        sop.Product_Revenue_Type__c='Cloud';
        //cs.Other fiels values
        insert sop;
        ProductSelection.getSubsOnlyProd();
    }
    
    
}