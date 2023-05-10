/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * # Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 
 */
@isTest 
private with sharing class OpportunityLeadTimeMsg_ltngTest {
    
    static testmethod void  ValidateOpportunityLeadTimeMsg_ltng(){
    
       OpportunityLeadTimeMsg_ltng ltngObj = new OpportunityLeadTimeMsg_ltng();
       //OpportunityLeadTimeMsg_ltng.testHack_1();
       
        Product2 oldprod = new product2();     
        Map<ID,ID>PricebookIDfor1stCondition = New  Map<ID,ID>();
        Map<ID,ID>PricebookIDfor2ndCondition= New  Map<ID,ID>();
        Map<ID,ID>PricebookIDfor3rdCondition= New  Map<ID,ID>();
        
//        Test.startTest();
        
        //Case 1
        //create new account
        Account a = new Account (name = 'testing task Deletion of Closed Opp', 
                                 Master_Customer_Number__c = 'TEST000012',
                                 Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true);
       
        User u3 = TestRecordsFactory.getUser();
        System.runAs(u3){insert a;}
        system.assertNotEquals(a,null,'account should not be null' );
        
        
//      Account a = [Select id from Account where Active_Account__c = TRUE limit 1];
        //create new salesorg
        Sales_Org__c s = new Sales_Org__c (name = 'testing task Deletion of Closed Opp',
                                              Is_Active_in_RoR__c = true);
        insert s;

        //create new competitor
        Competitors__c c = new Competitors__c (name = 'testing task Deletion of Closed Opp');
        insert c;
        
        //Advocated_Solution__c adv1 = new Advocated_Solution__c(name='test1', Advocated_Solution_ID__c='test', Lead_Time__c = 4, Line_of_Business__c = 'Financial');
        //insert adv1;
        // soql queries count = 7
        
        
        List<Product2> products = new List<Product2>();
        Product2 EntertainmentProduct = new Product2(Name='Entertainment Product', End_Date__c=System.now(),CurrencyIsoCode='USD', Product_Category__c ='HW', Solution_Portfolio__c='Entertainment Self Service', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*Advocated_Solution_Lookup__c = adv1.Id*/);
        Product2 PCELSProduct = new Product2(Name='PCELS Product', CurrencyIsoCode='USD', Product_Category__c ='HW', Solution_Portfolio__c='PC / ELS', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*Advocated_Solution_Lookup__c = adv1.Id*/);
        Product2 TravelProduct = new Product2(Name='Travel Product', CurrencyIsoCode='USD', Product_Category__c ='HW', Solution_Portfolio__c='Travel Self Service', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*Advocated_Solution_Lookup__c = adv1.Id*/);
        Product2 ChequeProduct = new Product2(Name='SW-ChequeMark', CurrencyIsoCode='USD', Product_Category__c ='SW', Solution_Portfolio__c='Travel Self Service', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*Advocated_Solution_Lookup__c = adv1.Id*/);
        products.addAll(new List<Product2>{EntertainmentProduct,PCELSProduct,TravelProduct,ChequeProduct});
        insert products;
        
        List<PricebookEntry> standardpriceBooks = new List<PricebookEntry>();
         string standrdPrcBkId = NSCCommonInfoUtil.getIdOf('Standard_Price_Book');
      /*  PricebookEntry EntertainmentStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=EntertainmentProduct.id,PriceBook2Id='01s700000002GMcAAM', UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry PCELSStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=PCELSProduct.id,PriceBook2Id='01s700000002GMcAAM', UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry TravelStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=TravelProduct.id,PriceBook2Id='01s700000002GMcAAM', UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry ChequeStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=ChequeProduct.id,PriceBook2Id='01s700000002GMcAAM', UnitPrice=0.00, UseStandardPrice=false, isactive = true); */
        PricebookEntry EntertainmentStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=EntertainmentProduct.id,PriceBook2Id=standrdPrcBkId, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry PCELSStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=PCELSProduct.id,PriceBook2Id=standrdPrcBkId, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry TravelStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=TravelProduct.id,PriceBook2Id=standrdPrcBkId, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry ChequeStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=ChequeProduct.id,PriceBook2Id=standrdPrcBkId, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        standardpriceBooks.addAll(new List<PricebookEntry>{EntertainmentStandardPricebook, PCELSStandardPricebook, TravelStandardPricebook, ChequeStandardPricebook});
        insert standardpriceBooks;
        
        List<PricebookEntry> GlobalSalespriceBooks = new List<PricebookEntry>();
        string globalPrcBkId = NSCCommonInfoUtil.getIdOf('Global_PriceBookId');
      /*  PricebookEntry EntertainmentGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=EntertainmentProduct.id,PriceBook2Id='01s7000000030GMAAY', UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry PCELSGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=PCELSProduct.id,PriceBook2Id='01s7000000030GMAAY', UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry TravelGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=TravelProduct.id,PriceBook2Id='01s7000000030GMAAY', UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry ChequeGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=ChequeProduct.id,PriceBook2Id='01s7000000030GMAAY', UnitPrice=0.00, UseStandardPrice=true, isactive = true); */
        PricebookEntry EntertainmentGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=EntertainmentProduct.id,PriceBook2Id=globalPrcBkId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry PCELSGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=PCELSProduct.id,PriceBook2Id =globalPrcBkId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry TravelGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=TravelProduct.id,PriceBook2Id=globalPrcBkId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry ChequeGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=ChequeProduct.id,PriceBook2Id=globalPrcBkId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        GlobalSalespriceBooks.addAll(new List<PricebookEntry>{EntertainmentGlobalPricebook, PCELSGlobalPricebook, TravelGlobalPricebook, ChequeGlobalPricebook});
        
        insert GlobalSalespriceBooks;
        
       list<PricebookEntry> pbe1 = [Select p.CurrencyIsoCode,p.Product2.Solution_Portfolio__c, p.Id, p.Name, p.Pricebook2Id, p.Product2Id, p.ProductCode, p.UnitPrice, p.UseStandardPrice 
                                     from PricebookEntry p  
                                        where p.Pricebook2Id = :Test.getStandardPricebookId()
                                           and p.CurrencyIsoCode = 'USD'
                                           and IsActive=true and Product2.IsActive=true
                                           and Product2.Product_Category__c='HW'
                                           and Product2.Solution_Portfolio__c IN ('Entertainment Self Service','PC / ELS','Travel Self Service')                                           
                                           limit 20];
       //System.debug('ttttttttttttt====>>'+pbe1.size()+'===='+pbe1);                          
       if(pbe1!=null && pbe1.size()>0)
       {
        for(PricebookEntry pbe:pbe1)
         {
            //System.debug('darshanName'+pbe.name);
            if(pbe.Product2.Solution_Portfolio__c=='Entertainment Self Service')
               {
                  PricebookIDfor1stCondition.put(pbe.Product2Id,pbe.id); 
               }
             else if(pbe.Product2.Solution_Portfolio__c=='PC / ELS')
                {
                    PricebookIDfor2ndCondition.put(pbe.Product2Id,pbe.id);
                }
              else if(pbe.Product2.Solution_Portfolio__c=='Travel Self Service')
                {
                        PricebookIDfor3rdCondition.put(pbe.Product2Id,pbe.id);
                }      
              
         }
        // soql queries count = 9
          Opportunity oppObj = new Opportunity();
          Opportunity opp = new Opportunity();
          Opportunity opp2 = new Opportunity();
          Opportunity opp1 = new Opportunity();
          Opportunity oppW = new Opportunity();
          OpportunityLineItem Oli1st = new OpportunityLineItem(); 
          OpportunityLineItem Oli1stObj = new OpportunityLineItem(); 
          
          OpportunityLineItem Oli2nd = new OpportunityLineItem(); 
           OpportunityLineItem Oli3rd = new OpportunityLineItem(); 
          
             
           List<Opportunity> oppList = new List<Opportunity>();
           List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>(); 
           List<OpportunityLineItemSchedule> lineItemScheduleList = new List<OpportunityLineItemSchedule>();
        
             if(PricebookIDfor1stCondition!=null)
             {
                /*Product2 EntertainProd=[Select Id, IsActive,Name,Product_Category__c,Solution_Portfolio__c 
                                 from Product2 where Id in :PricebookIDfor1stCondition.keySet() limit 1 ];*/
                                
                oppObj.name = 'abc';
                oppObj.AccountID = a.id;
                oppObj.type = 'Indirect Channel';
                //oppObj.ADVOCATED_SOLUTION__C = 'Image and Item Processing';
                oppObj.MARKETING_PROGRAM__C = 'None';
                //oppObj.APPLICATION__C = 'ITRAN 8000';
                oppObj.CURRENCYISOCODE = 'USD';
                oppObj.SALES_ORG__C = s.id;
                oppObj.INVOICE_TRIGGER__C='Shipment';
                //oppObj.Solution_Portfolio__c='TRAVEL SELF SERVICE'; P360 Initial Change - Ahad
                //oppObj.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                oppObj.PRIMARY_COMPETITOR__C = c.id;
                oppObj.Expected_Delivery_Date__c = System.TODAY().addDays(30);
                oppObj.closeDate = System.TODAY();
                oppObj.stagename = 'Offering';
                oppObj.Is_PreBuild_Order__c = true;
                oppObj.Amount = 0;
                
               
                oppList.add(oppObj);
                
                
                opp.name = 'abc';
                opp.AccountID = a.id;
                opp.type = 'Indirect Channel';
                //opp.ADVOCATED_SOLUTION__C = 'Image and Item Processing';
                opp.MARKETING_PROGRAM__C = 'None';
                //opp.APPLICATION__C = 'ITRAN 8000';
                opp.CURRENCYISOCODE = 'USD';
                opp.SALES_ORG__C = s.id;
                opp.INVOICE_TRIGGER__C='Shipment';
                 
                 
                //opp.Solution_Portfolio__c='TRAVEL SELF SERVICE'; P360 Initial Change - Ahad
                //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                opp.PRIMARY_COMPETITOR__C = c.id;
                opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
                opp.closeDate = System.TODAY();
                opp.stagename = 'Analyzing';
                oppList.add(opp);
                
            }
            
            if(PricebookIDfor2ndCondition!=null)
             {
                /* Product2 RETAILProd=[Select Id, IsActive,Name,Product_Category__c,Solution_Portfolio__c 
                                 from Product2 where Id in :PricebookIDfor2ndCondition.keySet() limit 1 ]; */
                
                
                opp1.name = 'abc';
                opp1.AccountID = a.id;
                opp1.type = 'Indirect Channel';
                //opp1.ADVOCATED_SOLUTION__C = 'Image and Item Processing';
                opp1.MARKETING_PROGRAM__C = 'None';
                //opp1.APPLICATION__C = 'ITRAN 8000';
                opp1.CURRENCYISOCODE = 'USD';
                opp1.SALES_ORG__C = s.id;
                opp1.INVOICE_TRIGGER__C='Shipment';
                //opp1.Solution_Portfolio__c='PC / ELS'; P360 Initial Change - Ahad
                //opp1.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                opp1.PRIMARY_COMPETITOR__C = c.id;
                opp1.Expected_Delivery_Date__c = System.TODAY().addDays(30);
                opp1.closeDate = System.TODAY();
                opp1.stagename = 'Analyzing';
                opp1.forecastcategoryname = 'Commit';
                opp1.Is_PreBuild_Order__c = true; 
                oppList.add(opp1);
    
            }
    
    
             if(PricebookIDfor3rdCondition!=null)
             {
                 /*Product2 TravelProd=[Select Id, IsActive,Name,Product_Category__c,Solution_Portfolio__c 
                                 from Product2 where Id in :PricebookIDfor3rdCondition.keySet() limit 1 ];*/
                
               
                opp2.name = 'abc2';
                opp2.AccountID = a.id;
                opp2.type = 'Indirect Channel';
                //opp2.ADVOCATED_SOLUTION__C = 'Image and Item Processing';
                opp2.MARKETING_PROGRAM__C = 'None';
                //opp2.APPLICATION__C = 'ITRAN 8000';
                opp2.CURRENCYISOCODE = 'USD';
                opp2.SALES_ORG__C = s.id;
                opp2.INVOICE_TRIGGER__C='Shipment';
                //opp2.Solution_Portfolio__c='Travel Self Service'; P360 Initial Change - Ahad
                //opp2.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                opp2.PRIMARY_COMPETITOR__C = c.id;
                opp2.Expected_Delivery_Date__c = System.TODAY().addDays(29);
                opp2.closeDate = System.TODAY();
                opp2.stagename = 'Analyzing';
                opp2.Amount=0;
               
                oppList.add(opp2);
            }
           
             EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
             ebdedd.Name = 'EDSD_Calc';
             ebdedd.isActive__c = true;
             insert ebdedd;
            //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
			Id r = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
         
             // CODE ADDED BY (Darshan Singh Farswan) DF250061 FOR MODIFIED CLASS.
                User HospitalityUser = [SELECT id, LOB__c, License_Entitlement__c from User where (LOB__c = 'Hospitality' OR License_Entitlement__c = 'Hospitality') AND IsActive = true limit 1].get(0);
                
                oppW.name = 'Test Warning';
                oppW.AccountID = a.id;
                oppW.type = 'Indirect Channel';
                //oppW.ADVOCATED_SOLUTION__C = 'Image and Item Processing';
                oppW.MARKETING_PROGRAM__C = 'None';
                //oppW.APPLICATION__C = 'ITRAN 8000';
                oppW.CURRENCYISOCODE = 'USD';
                oppW.SALES_ORG__C = s.id;
                oppW.INVOICE_TRIGGER__C='Shipment';
                //oppW.Solution_Portfolio__c='RETAIL SELF SERVICE'; P360 Initial Change - Ahad
                //oppW.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                oppW.PRIMARY_COMPETITOR__C = c.id;
                oppW.Expected_Delivery_Date__c = System.TODAY().addDays(1000);
                oppW.closeDate = System.TODAY();
                oppW.stagename = 'Analyzing';
                oppW.RecordTypeId = r;
                oppW.OwnerId = HospitalityUser.id;
                oppW.Amount = 100.00;
                oppList.add(oppW);
            
            if(!oppList.IsEmpty()){
                insert oppList;
            }
           
            
            Test.startTest();

           
            /** OpportunityLineItem for PricebookIDfor1stCondition **/
            
            if(opp.Id != null){     
                
                Oli1st.OpportunityId=opp.Id;
                Oli1st.UnitPrice=10;
                Oli1st.Quantity=100;
                Oli1st.PricebookEntryId=EntertainmentGlobalPricebook.id;
                Oli1st.Quantity=10000;
                Oli1st.UnitPrice=1000;
                Oli1st.Revenue_Type__c='HW';
                lineItemList.add(Oli1st);
                
                Oli1stObj  = new OpportunityLineItem();
                Oli1stObj.OpportunityId=opp.Id;
                Oli1stObj.UnitPrice=10;
                Oli1stObj.Quantity=100;
                Oli1stObj.Revenue_Type__c='SW';
                Oli1stObj.PricebookEntryId=ChequeGlobalPricebook.id;
                Oli1stObj.Quantity=1000;
                Oli1stObj.UnitPrice=5000;
                lineItemList.add(Oli1stObj);
            }
            
            if(opp1.Id != null){
                
                Oli2nd.OpportunityId=opp1.Id;
                Oli2nd.UnitPrice=10;
                Oli2nd.Quantity=100;
                Oli2nd.Revenue_Type__c='HW';
                Oli2nd.PricebookEntryId =   PCELSGlobalPricebook.Id;
                Oli2nd.Quantity=100;
                Oli2nd.UnitPrice=10;
                lineItemList.add(Oli2nd);
            }
            
            if(opp2.Id != null){
            
                Oli3rd  = new OpportunityLineItem();
                Oli3rd.OpportunityId=opp2.Id;
                Oli3rd.UnitPrice=10;
                Oli3rd.Quantity=100;
                Oli3rd.Revenue_Type__c='SW';
                Oli3rd.PricebookEntryId=TravelGlobalPricebook.Id;
                Oli3rd.Quantity=100;
                Oli3rd.UnitPrice=10;
                lineItemList.add(Oli3rd);
            }
            
            
            if(oppW != null){
                OpportunityLineItem OliW = new OpportunityLineItem();
                OliW.OpportunityId=oppW.Id;
                OliW.UnitPrice=10;
                OliW.Quantity=100; 
                OliW.Revenue_Type__c='SW';
                OliW.PricebookEntryId=TravelGlobalPricebook.Id;
                OliW.Quantity=100;
                OliW.UnitPrice=10; 
                
                lineItemList.add(OliW);
            }
            
            if(lineItemList != null){
                insert lineItemList;
            }
  
            if(Oli1st.Id != null){
                OpportunityLineItemSchedule Olis = new OpportunityLineItemSchedule();
                Olis.Quantity=10;
                Olis.scheduleDate=System.Today()+30;
                Olis.OpportunityLineItemId=Oli1st.ID;
                Olis.Type='Quantity';
                lineItemScheduleList.add(Olis);
        //         insert Olis;
        
                OpportunityLineItemSchedule Olis1 = new OpportunityLineItemSchedule();
                Olis1.Quantity=10;
                Olis1.scheduleDate=System.Today()+60;
                Olis1.OpportunityLineItemId=Oli1st.ID;
                Olis1.Type='Quantity';  
                lineItemScheduleList.add(Olis1);  
            }
            
            if(Oli1stObj.id != null){
                OpportunityLineItemSchedule Olis0 = new OpportunityLineItemSchedule();
                Olis0.Quantity=10;
                Olis0.scheduleDate=System.Today()+30;
                Olis0.OpportunityLineItemId=Oli1stObj.ID;
                Olis0.Type='Quantity';
                lineItemScheduleList.add(Olis0); 
            }
            
            if(Oli2nd.Id != null){
                OpportunityLineItemSchedule Olis2 = new OpportunityLineItemSchedule();
                Olis2.Quantity=10;
                Olis2.scheduleDate=System.Today()+30;
                Olis2.OpportunityLineItemId=Oli2nd.ID;
                Olis2.Type='Quantity';
                lineItemScheduleList.add(Olis2);  
                
                OpportunityLineItemSchedule Olis3 = new OpportunityLineItemSchedule();
                Olis3.Quantity=10;
                Olis3.scheduleDate=System.Today()+60;
                Olis3.OpportunityLineItemId=Oli2nd.ID;
                Olis3.Type='Quantity';
                lineItemScheduleList.add(Olis3); 
            }
            
            
            if(Oli3rd.id != null){
                OpportunityLineItemSchedule Olis4 = new OpportunityLineItemSchedule();
                Olis4.Quantity=10;
                Olis4.scheduleDate=System.Today()+30;
                Olis4.OpportunityLineItemId=Oli3rd.ID;
                Olis4.Type='Quantity';
                 lineItemScheduleList.add(Olis4);
                // insert Olis4;
                
                OpportunityLineItemSchedule Olis5 = new OpportunityLineItemSchedule();
                Olis5.Quantity=10;
                Olis5.scheduleDate=System.Today()+60;
                Olis5.OpportunityLineItemId=Oli3rd.ID;
                Olis5.Type='Quantity'; 
                 lineItemScheduleList.add(Olis5);
            }
            
            if(!lineItemScheduleList.IsEmpty()){
                insert lineItemScheduleList;
            }
            
            
        // CODE ADDED BY (Darshan Singh Farswan) DF250061 FOR MODIFIED CLASS.
            if(oppObj.id != null){
                
                System.debug('oppObj:'+oppObj);
                OpportunityLeadTimeMsg_ltng CVC5 = new OpportunityLeadTimeMsg_ltng();  
                  OpportunityLeadTimeMsg_ltng.getNotification(oppObj.id);               
            }
            
            if(opp.id!=null){
            //ApexPages.currentPage().getParameters().put('id',opp.id);
            //ApexPages.StandardController stc4 = new ApexPages.StandardController(opp);
            //OpportunityLeadTimeMsg CVC4 = new OpportunityLeadTimeMsg(stc4);        
            
                OpportunityLeadTimeMsg_ltng.getNotification(opp.id);

                //ApexPages.currentPage().getParameters().put('id',opp.id);
                //ApexPages.StandardController stc = new ApexPages.StandardController(opp);
                //OpportunityLeadTimeMsg CVC = new OpportunityLeadTimeMsg(stc);
                
            }
            //commented to deploy Sales Analytics
            /*if(opp1.id!=null){
            
            opp1.forecastcategoryname = 'Pipeline';
            update opp1;
            ApexPages.currentPage().getParameters().put('id',opp1.id);
            ApexPages.StandardController stc1 = new ApexPages.StandardController(opp1);
            OpportunityLeadTimeMsg CVC1 = new OpportunityLeadTimeMsg(stc1);
             }
              if(opp2.id!=null){
             ApexPages.currentPage().getParameters().put('id',opp2.id);
            ApexPages.StandardController stc11 = new ApexPages.StandardController(opp2);
            OpportunityLeadTimeMsg CVC11 = new OpportunityLeadTimeMsg(stc11);    
              }
               if(oppW.id!=null){
            ApexPages.currentPage().getParameters().put('id',oppW.id);
            ApexPages.StandardController stcW1 = new ApexPages.StandardController(oppW);
            OpportunityLeadTimeMsg CVCW1 = new OpportunityLeadTimeMsg(stcW1);
               }*/
            Test.stopTest();
        }
    }
    
    static testmethod void  validateValuePrompterLeadTimeMsg_ltng(){
        //create new salesorg
        Sales_Org__c s = TestRecordsFactory.createSalesOrg();

        //create new competitor
        Competitors__c c = TestRecordsFactory.createCompetitor();
        
         //create new account
        Account a = TestRecordsFactory.createAccount('TESTM');
       
       //create new opportunity 
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        
        Product2 HWProduct = new Product2(Name='HW Product', End_Date__c=System.now(),CurrencyIsoCode='USD', Product_Category__c ='SW', Solution_Portfolio__c='Entertainment Self Service',Service_Offer_Category__c='HW', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*Advocated_Solution_Lookup__c = adv1.Id*/);
        insert HWProduct;
        /*PricebookEntry HWProductStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=HWProduct.id,PriceBook2Id='01s700000002GMcAAM', UnitPrice=10.00, UseStandardPrice=false, isactive = true);
        insert HWProductStandardPricebook;*/
        
        Product2 SWProduct = new Product2(Name='SF Product', End_Date__c=System.now(),CurrencyIsoCode='USD', Product_Category__c ='SW', Solution_Portfolio__c='Entertainment Self Service',Service_Offer_Category__c='SW', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*Advocated_Solution_Lookup__c = adv1.Id*/);
        insert SWProduct;
       /* PricebookEntry SWProductStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=SWProduct.id,PriceBook2Id='01s700000002GMcAAM', UnitPrice=10.00, UseStandardPrice=false, isactive = true);
        insert SWProductStandardPricebook;*/
        
        
        //create new opportunityLineItem 
        OpportunityLineItem Oli1st= TestRecordsFactory.createOpportunityLineItem(opp,TestRecordsFactory.createPriceBookEntry(HWProduct));
        OpportunityLineItem Oli1st2= TestRecordsFactory.createOpportunityLineItem(opp,TestRecordsFactory.createPriceBookEntry(SWProduct));

        // Query the Opportunity again to get the updated rollup summary field.
        Opportunity oppAfterInsert = [Select Hardware_Products__c,(select id, Revenue_Type__c, OpportunityId,TotalPrice,Quantity from OpportunityLineItems ) from Opportunity where Id= :opp.Id];
        System.assertEquals(20000000.00, oppAfterInsert.Hardware_Products__c); 
        OpportunityLeadTimeMsg_ltng.getNotification(opp.id);
    }
}