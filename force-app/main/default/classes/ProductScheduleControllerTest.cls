/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: ProductScheduleControllerTest.Test class                                                        
# Created by................: Ahad Mohd                                                                  
# Created Date...........: 12-30-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-30-2016
# Description...............: This test class is the written with respect to Apex class:ProductScheduleController
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
################################################################################################
*/

@IsTest
Public class ProductScheduleControllerTest{
    
    static testMethod void getPrdScedtestMethod() {
        
        //ProductScheduleController.TestCoverage();  
        List<id> idlist=new List<id>();
        List<String> prductids=new List<String>();
        List<String> prductids1=new List<String>();
        List<String> datelist=new List<String>();
        List<Product2> insertprodlist=new List<product2>();
        boolean isAdmin=false;
        //Creating products 
        Product2 pd=TestRecordsFactory.createProduct();
        prductids1.add(pd.id);
        pd.IsActive=True;
        List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'SOFTWARE';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        p01.CanUseQuantitySchedule =true;
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        p01.service_offer_category__c = 'SWM';
        prdlist1.add(P01);
        prductids1.add(p01.id);
        insertprodlist.add(P01);
        
        List<Product2> prdlist2=new List<product2>();
        Product2 p02 = new Product2();
        p02.name= 'IPS'; 
        p02.CurrencyIsoCode = 'USD';
        p02.Family = 'Solution';
        p02.Name = '1902-ECPIX LSI';
        p02.Product_Category__c = 'SOFTWARE';
        p02.CanUseQuantitySchedule =true;
        //p02.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p02.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='DIVISION: ';
        p02.isActive=true;
        p02.service_offer_category__c = 'SWM';
        prdlist2.add(P02);
        prductids1.add(p02.id);
        insertprodlist.add(P02);
        
        List<Product2> prdlist3=new List<product2>();
        Product2 p03 = new Product2();
        p03.Name= '2186';
        p03.CurrencyIsoCode = 'USD';
        p03.Family = 'Solution';
        p03.Name = '1902-ECPIX LSI';
        p03.Product_Category__c = 'HARDWARE';
        p03.CanUseQuantitySchedule =true;    
        //p03.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p03.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p03.isActive=true;
        p03.service_offer_category__c = 'SWM';    
        prdlist3.add(P03);
        prductids1.add(p03.id);
        insertprodlist.add(P03);
        
        
        List<Product2> prdlist4=new List<product2>();
        Product2 p04 = new Product2();
        p04.Name= 'Cloud';
        p04.CurrencyIsoCode = 'USD';
        p04.Family = 'Solution';
        p04.Name = '1902-ECPIX LSI';
        p04.Product_Category__c = 'SERVICE';
        //p04.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p04.Solution_Portfolio__c = 'Payment Solutions';
        p04.isActive=true;
        p04.service_offer_category__c = 'SWM'; 
        p04.CanUseQuantitySchedule =true;    
        prdlist4.add(P04);
        prductids1.add(p04.id);
        
        insertprodlist.add(P04);
        prductids.add(P04.id);
        
        
        insert insertprodlist;   
        //end products creation     
        
        //Creating Opportunity Line Items   
        //Pricebook2 pbk=TestRecordsFactory.createPriceBook();            
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        Account acc1 = TestRecordsFactory.createAccount('test01010');
        Opportunity opp1= TestRecordsFactory.createSimpleOpportunity(acc1);
        opp1.Pricebook2Id = null;
        //opp.Pricebook2Id ='01s7000000030GMAAY';
        opp.Pricebook2Id = GlobalVariable.pricebookId;        
        opp.CurrencyIsoCode = 'USD';
        opp.Contract_Term_Mths__c = 0;
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        //List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        OpportunityLineItem oli2=TestRecordsFactory.createOpportunityLineItem(opp,pbe[2]);
        OpportunityLineItem oli3=TestRecordsFactory.createOpportunityLineItem(opp,pbe[3]);
        idlist.add(oli.Id);
        
        List<OpportunityLineItemSchedule> olislst = new  List<OpportunityLineItemSchedule>();
        
        for(OpportunityLineitem oli_new: [Select id,name from OpportunityLineitem where  OpportunityId =:opp.id]){
            
            OpportunityLineItemSchedule olis = New OpportunityLineItemSchedule();
            olis.Description = '';
            olis.OpportunityLineItemId = oli_new.Id;
            olis.Quantity = 1;
            olis.ScheduleDate = System.today();
            olis.Type='Quantity';
            olislst.add(olis);
            
        }
        insert olislst;
        Test.startTest();
        
        ProductScheduleController.ScheduleCalculateWrapper(opp.Id,false);
        ProductScheduleController.ScheduleCalculateWrapper(opp.Id,true);
        ProductScheduleController.deleteOldSchedules(idlist);
        list<OpportunityLineItemSchedule> oppLineList = new  list<OpportunityLineItemSchedule>();
        oppLineList = [Select id from OpportunityLineItemSchedule where OpportunityLineItemId in :idlist];
        System.assert(oppLineList.size()==0);
        ProductScheduleController.DeleteOli(oli.id);
        ProductScheduleController.InsertOpportunityLineItem(prductids1,opp.Id);
        opp1.Pricebook2Id=null;
        ProductScheduleController.InsertOpportunityLineItem(prductids1,opp1.Id);
        ProductScheduleController.removeSchedule(prductids,opp.Id);
        ProductScheduleController.InsertOpportunityLineItemPS(prductids1,opp.Id);
        ProductScheduleController.getOpportunityLineItemPS();
        ProductScheduleController.SubmitManegeSchedule('TestString');
        //ProductScheduleController.SaveScheduleValidations(prductids,datelist);
        // boolean abc= ProductScheduleController.isAdmin();
        ProductScheduleController.getOpportunityLineItemPS();
        ProductScheduleController.getOpportunityLineItemPS();
        
        //added by Pankaj 3 jan 2017//
        string testString ='{ "OpportunityLineItem": [{ "Id": "00k54000003D8VZAA0", "Quantity": 20, "UnitPrice": 200, "TotalPrice": 400, "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0", "OpportunityLineItemSchedule": [{ "Quantity": 2, "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1" }] }] }';
        ProductScheduleController.SaveManegeSchedule(testString); 
        ProductScheduleController.SubmitManegeSchedule(testString);
        testString =''; 
        ProductScheduleController.SaveManegeSchedule(testString);
        testString='{"OpportunityLineItem": [{"Id":'+ oli.id+',"Quantity":2,"UnitPrice":200,"TotalPrice":400,"ProductName":"1635-Bump Bar","UnschldQty":"0","counter":"0","Duration":"----","OpportunityLineItemSchedule": [{"Quantity":2,"Id":"00o54000000NH9bAAG","Type":"Quantity","ScheduleDate":"2017-Dec-01"}]},{"Id":"00k54000003D8I6AAK","Quantity":2,"UnitPrice":200,"TotalPrice":400,"ProductName":"1611-Server (S500MT)","UnschldQty":"0","counter":"0","Duration":"2 months","OpportunityLineItemSchedule": [{"Quantity":1,"Id":"","Type":"Quantity","ScheduleDate":"2017-Dec-1"},{"Quantity":1,"Id":"","Type":"Quantity","ScheduleDate":"2018-Jan-1"}]},{"Id":"00k54000003D8VUAA0","Quantity":1,"UnitPrice":0,"TotalPrice":0,"ProductName":"1611-Server (S500MT)","UnschldQty":"1","counter":"1","Duration":"----","OpportunityLineItemSchedule": []}]}';
        //Add code coverage By nagendra
        testString ='{ "OpportunityLineItem": [{ "Id": '+ oli.id+', "Quantity": 20h, "UnitPrice": 200, "TotalPrice": 400, "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0", "OpportunityLineItemSchedule": [{ "Quantity": 2, "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1" }] }] }';
        ProductScheduleController.SaveManegeSchedule(testString);
        ProductScheduleController.SubmitManegeSchedule(testString);
        testString ='{ "OpportunityLineItem": [{ "Id": '+ oli.id+', "Quantity": , "UnitPrice": , "TotalPrice": , "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0", "OpportunityLineItemSchedule": [{ "Quantity": , "Id": "", "Type": "", "ScheduleDate": "2017-Dec-1" }] }] }';
        ProductScheduleController.SaveManegeSchedule(testString); 
        ProductScheduleController.SubmitManegeSchedule(testString);
       
        //End
        List<string> str1=new List<String>();
        List<string> str2=new List<String>();
        //ProductScheduleController.SaveScheduleValidations(str1,str1);
        Test.stopTest();
    }           
   /* static testMethod void getPrdScedtestMethod1() {
        List<String> prductids1=new List<String>();
        Product2 pd1=TestRecordsFactory.createProduct();
        prductids1.add(pd1.id);
        
        Opportunity opp1= TestRecordsFactory.createSimpleOpportunity();
        ProductScheduleController.ScheduleCalculateWrapper(opp1.Id,true);
        //ProductScheduleController.SaveScheduleValidations(prductids1,null);
        
    }*/
    static testMethod void getPrdScedtestMethod2() {
        
        //ProductScheduleController.TestCoverage();  
        List<id> idlist=new List<id>();
        List<String> prductids=new List<String>();
        List<String> prductids1=new List<String>();
        List<String> datelist=new List<String>();
        List<Product2> insertprodlist=new List<product2>();
        boolean isAdmin=false;
        //Creating products 
        Product2 pd=TestRecordsFactory.createProduct();
        prductids1.add(pd.id);
        pd.IsActive=True;
        List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'SOFTWARE';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        p01.CanUseQuantitySchedule =true;
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        p01.service_offer_category__c = 'SWM';
        prdlist1.add(P01);
        prductids1.add(p01.id);
        insertprodlist.add(P01);
        
        List<Product2> prdlist2=new List<product2>();
        Product2 p02 = new Product2();
        p02.name= 'IPS'; 
        p02.CurrencyIsoCode = 'USD';
        p02.Family = 'Solution';
        p02.Name = '1902-ECPIX LSI';
        p02.Product_Category__c = 'SOFTWARE';
        p02.CanUseQuantitySchedule =true;
        //p02.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p02.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='DIVISION: ';
        p02.isActive=true;
        p02.service_offer_category__c = 'SWM';
        prdlist2.add(P02);
        prductids1.add(p02.id);
        insertprodlist.add(P02);
        
        List<Product2> prdlist3=new List<product2>();
        Product2 p03 = new Product2();
        p03.Name= '2186';
        p03.CurrencyIsoCode = 'USD';
        p03.Family = 'Solution';
        p03.Name = '1902-ECPIX LSI';
        p03.Product_Category__c = 'HARDWARE';
        p03.CanUseQuantitySchedule =true;    
        //p03.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p03.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p03.isActive=true;
        p03.service_offer_category__c = 'SWM';    
        prdlist3.add(P03);
        prductids1.add(p03.id);
        insertprodlist.add(P03);
        
        
        List<Product2> prdlist4=new List<product2>();
        Product2 p04 = new Product2();
        p04.Name= 'Cloud';
        p04.CurrencyIsoCode = 'USD';
        p04.Family = 'Solution';
        p04.Name = '1902-ECPIX LSI';
        p04.Product_Category__c = 'SERVICE';
        //p04.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p04.Solution_Portfolio__c = 'Payment Solutions';
        p04.isActive=true;
        p04.service_offer_category__c = 'SWM'; 
        p04.CanUseQuantitySchedule =true;    
        prdlist4.add(P04);
        prductids1.add(p04.id);
        
        insertprodlist.add(P04);
        prductids.add(P04.id);
        
        
        insert insertprodlist;   
        //end products creation     
        
        //Creating Opportunity Line Items   
        //Pricebook2 pbk=TestRecordsFactory.createPriceBook();            
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        //opp.Pricebook2Id ='01s7000000030GMAAY';
        opp.Pricebook2Id = GlobalVariable.pricebookId;        
        opp.CurrencyIsoCode = 'USD';
        opp.CATM_Record__c = true;
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        //List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        OpportunityLineItem oli2=TestRecordsFactory.createOpportunityLineItem(opp,pbe[2]);
        OpportunityLineItem oli3=TestRecordsFactory.createOpportunityLineItem(opp,pbe[3]);
        oli.Number_of_Terms__c = 7;
        opp.Contract_Term_Mths__c = oli.Number_of_Terms__c;
        string testString ='{ "OpportunityLineItem": [{ "Id":'+ oli.id+',"OpportunityId":'+opp.Id+', "Quantity": "20", "UnitPrice": "200", "TotalPrice": "400", "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0", "RevenueType":"Cloud" ,"TotalTCVPrice":"300", "isSubscriptioned":"true" ,"NumberOfTerms":"20", "OpportunityLineItemSchedule": [{ "Quantity": "2", "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1" }] }] }';
        idlist.add(oli.Id);
        Test.startTest();
        
        ProductScheduleController.ScheduleCalculateWrapper(opp.Id,false);
        ProductScheduleController.ScheduleCalculateWrapper(opp.Id,true);
        ProductScheduleController.updateFirstScheduleOpp(opp.Id);
        ProductScheduleController.deleteOldSchedules(idlist);
        ProductScheduleController.DeleteOli(oli.id);
        ProductScheduleController.DeleteOli(oli.id);
        ProductScheduleController.InsertOpportunityLineItem(prductids1,opp.Id);
        List<OpportunityLineItem> addOLIlist = new  List<OpportunityLineItem>();
        addOLIlist = [select id from OpportunityLineItem where OpportunityId =:opp.Id ];
        System.assert(addOLIlist.size()>0);
        ProductScheduleController.removeSchedule(prductids,opp.Id);
        ProductScheduleController.InsertOpportunityLineItemPS(prductids1,opp.Id);
        ProductScheduleController.getOpportunityLineItemPS();
        ProductScheduleController.SubmitManegeSchedule(testString);
        //ProductScheduleController.SaveScheduleValidations(prductids,datelist);
        // boolean abc= ProductScheduleController.isAdmin();
        ProductScheduleController.getOpportunityLineItemPS();
        ProductScheduleController.getOpportunityLineItemPS();
        
        
        //added by Pankaj 3 jan 2017//
        testString ='{ "OpportunityLineItem": [{ "Id": "00k54000003D8VZAA0","OpportunityId":"006790000024UnGAAU", "Quantity": 20, "UnitPrice": 200, "TotalPrice": 400, "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0", "RevenueType":"Cloud" ,"TotalTCVPrice":300, "isSubscriptioned":true ,"NumberOfTerms":20, "OpportunityLineItemSchedule": [{ "Quantity": 2, "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1" }] }] }';
        ProductScheduleController.SaveManegeSchedule(testString); 
        ProductScheduleController.SubmitManegeSchedule(testString);
        testString =''; 
        ProductScheduleController.SaveManegeSchedule(testString);
        testString='{"OpportunityLineItem": [{"Id":'+ oli.id+',"NumberOfTerms":20, "OpportunityId":'+opp.Id+',"Quantity":2,"UnitPrice":200,"TotalPrice":400,"ProductName":"1635-Bump Bar","UnschldQty":"0","counter":"0","Duration":"----","OpportunityLineItemSchedule": [{"Quantity":2,"Id":"00o54000000NH9bAAG","Type":"Quantity","ScheduleDate":"2017-Dec-01"}]},{"Id":"00k54000003D8I6AAK","Quantity":2,"UnitPrice":200,"TotalPrice":400,"ProductName":"1611-Server (S500MT)","UnschldQty":"0","counter":"0","Duration":"2 months","OpportunityLineItemSchedule": [{"Quantity":1,"Id":"","Type":"Quantity","ScheduleDate":"2017-Dec-1"},{"Quantity":1,"Id":"","Type":"Quantity","ScheduleDate":"2018-Jan-1"}]},{"Id":"00k54000003D8VUAA0","Quantity":1,"UnitPrice":0,"TotalPrice":0,"ProductName":"1611-Server (S500MT)","UnschldQty":"1","counter":"1","Duration":"----","OpportunityLineItemSchedule": []}]}';
        //Add code coverage By nagendra
        testString ='{ "OpportunityLineItem": [{ "Id": '+ oli2.id+', "OpportunityId":'+opp.Id+', "Quantity": 20h, "UnitPrice": 200, "TotalPrice": 400, "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0","NumberOfTerms":20, "OpportunityLineItemSchedule": [{ "Quantity": 2, "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1"}] }] }';
        ProductScheduleController.SaveManegeSchedule(testString); 
        ProductScheduleController.SubmitManegeSchedule(testString);
        system.debug('opportunity in test class'+opp.Id);
        testString ='{ "OpportunityLineItem": [{ "Id": '+ oli3.id+', "OpportunityId":'+opp.Id+', "Quantity": , "UnitPrice": , "TotalPrice": , "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0","NumberOfTerms":20, "OpportunityLineItemSchedule": [{ "Quantity": , "Id": "", "Type": "", "ScheduleDate": "2017-Dec-1" }] }] }';
        ProductScheduleController.SaveManegeSchedule(testString); 
        ProductScheduleController.SubmitManegeSchedule(testString);
        
        //End
        List<string> str1=new List<String>();
        List<string> str2=new List<String>();
        //ProductScheduleController.SaveScheduleValidations(str1,str1);
        Test.stopTest();
        ProductScheduleController.deleteOldSchedules(idlist);
    }
    static testMethod void getPrdScedtestMethod3() {
        
        //ProductScheduleController.TestCoverage();  
        List<id> idlist=new List<id>();
        List<String> prductids=new List<String>();
        List<String> prductids1=new List<String>();
        List<String> datelist=new List<String>();
        List<Product2> insertprodlist=new List<product2>();
        boolean isAdmin=false;
        //Creating products 
        Product2 pd=TestRecordsFactory.createProduct();
        prductids1.add(pd.id);
        pd.IsActive=True;
        List<Product2> prdlist1=new List<product2>();
        Product2 p01 = new Product2();
        p01.Name= '2181-Full-Size Cash Drawer';
        p01.CurrencyIsoCode = 'USD';
        p01.Family = 'Solution';
        p01.Name = '1902-ECPIX LSI';
        p01.Product_Category__c = 'SOFTWARE';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        p01.CanUseQuantitySchedule =true;
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        p01.service_offer_category__c = 'SWM';
        prdlist1.add(P01);
        prductids1.add(p01.id);
        insertprodlist.add(P01);
        insert insertprodlist;   
        //end products creation     
        
        //Creating Opportunity Line Items   
        //Pricebook2 pbk=TestRecordsFactory.createPriceBook();            
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        //opp.Pricebook2Id ='01s7000000030GMAAY';
        opp.Pricebook2Id = GlobalVariable.pricebookId;        
        opp.CurrencyIsoCode = 'USD';
        opp.Pricebook2Id = null;
        opp.catm_record__c = true;
        opp.Contract_Term_Mths__c = 8;
        
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        //List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        idlist.add(oli.Id);
        Test.startTest();
        
        ProductScheduleController.ScheduleCalculateWrapper(opp.Id,false);
        ProductScheduleController.ScheduleCalculateWrapper(opp.Id,true);
        ProductScheduleController.updateFirstScheduleOpp(opp.Id);
        ProductScheduleController.deleteOldSchedules(idlist);
        list<OpportunityLineItemSchedule> oppLineList = new  list<OpportunityLineItemSchedule>();
        oppLineList = [Select id from OpportunityLineItemSchedule where OpportunityLineItemId in :idlist];
        System.assert(oppLineList.size()==0);
        ProductScheduleController.DeleteOli(oli.id);
        ProductScheduleController.DeleteOli(oli.id);
        ProductScheduleController.InsertOpportunityLineItem(prductids1,opp.Id);
        ProductScheduleController.removeSchedule(prductids,opp.Id);
        ProductScheduleController.InsertOpportunityLineItemPS(prductids1,opp.Id);
        ProductScheduleController.getOpportunityLineItemPS();
        ProductScheduleController.SubmitManegeSchedule('TestString');
        //ProductScheduleController.SaveScheduleValidations(prductids,datelist);
        // boolean abc= ProductScheduleController.isAdmin();
        ProductScheduleController.getOpportunityLineItemPS();
        ProductScheduleController.getOpportunityLineItemPS();
        
        
        //added by Pankaj 3 jan 2017//
        string testString ='{ "OpportunityLineItem": [{ "Id": "00k54000003D8VZAA0","OpportunityId":"'+ opp.Id + '", "Quantity": 10, "UnitPrice": 200, "TotalPrice": 400, "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0" ,"TotalTCVPrice":300,"RevenueType":"Service", "isSubscriptioned":false,"isCATMProduct":false,"NumberOfTerms":20,  "OpportunityLineItemSchedule": [{ "Quantity": 0, "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1" }] }] }';
        opp.Contract_Term_Mths__c =20;
        update opp;
        ProductScheduleController.SaveManegeSchedule(testString); 
        System.debug('@@@@@@@@@@' + testString);
        ProductScheduleController.SubmitManegeSchedule(testString);
       
        Test.stopTest();
    }
    static testMethod void getPrdScedtestMethod4(){
        List<id> idlist=new List<id>();
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        opp.CATM_Record__c = true;
        opp.Pricebook2Id = GlobalVariable.pricebookId;        
        opp.CurrencyIsoCode = 'USD';
        opp.Pricebook2Id = null;
        opp.catm_record__c = true;
        opp.Contract_Term_Mths__c = 0;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.Number_of_Terms__c =9;
        opp.Contract_Term_Mths__c = oli.Number_of_Terms__c;
        string testString ='{ "OpportunityLineItem": [{ "Id": '+oli.Id+',"OpportunityId":'+ opp.Id +', "Quantity": 0, "UnitPrice": 200, "TotalPrice": 400, "ProductName": "1635-Bump Bar","UnschldQty": "2", "counter": "0" ,"TotalTCVPrice":300,"RevenueType":"Service", "isSubscriptioned":false,"NumberOfTerms":20,  "OpportunityLineItemSchedule": [{ "Quantity": 0, "Id": "", "Type": "Quantity", "ScheduleDate": "2017-Dec-1" }] }] }';
        opp.Contract_Term_Mths__c =20;
        update opp;
        idlist.add(oli.Id);
        Test.startTest();
        ProductScheduleController.SaveManegeSchedule(testString); 
    }
    
}