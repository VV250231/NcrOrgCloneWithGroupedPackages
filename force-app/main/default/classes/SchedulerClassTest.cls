/*
##################################################################################################
# Project Name && Request Num..........: NSC Sales Central&& Product Scheduler For Lightining
# File............................: SchedulerClassTest.Test class                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-29-2016                                                                              
# Last Modified by......:  Saritha karutrui 
# Last Modified Date..: 12-29-2016
# Description...............: This test class is the written with respect to Apex class:SchedulerClass 
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
################################################################################################
*/
@IsTest
public class SchedulerClassTest {
    
    static testMethod void SchedulingTestMethods() {
        List<id> idist=new List<id>();
        Set<Id> hosp = NSCCommonInfoUtil.getIdSetOf('Hospitality_Ids');
        //Set<ID> Hospitality_IDS = new Set<ID>{'00e70000000xBoN','00e70000000xBoS','00e70000000xBoX'};
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
        p01.Product_Category__c = 'PRODUCTCATEGORY: ';
        //p01.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p01.Solution_Portfolio__c = 'Payment Solutions';
        //p01.Division__c='DIVISION: ';
        p01.isActive=true;
        p01.service_offer_category__c = 'SWM';
        p01.CanUseQuantitySchedule =true;
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
        p02.service_offer_category__c = 'SWM';
        p02.CanUseQuantitySchedule =true;
        prdlist2.add(P02);
        insertprodlist.add(P02);
        
        List<Product2> prdlist3=new List<product2>();
        Product2 p03 = new Product2();
        p03.Name= '2186';
        p03.CurrencyIsoCode = 'USD';
        p03.Family = 'Solution';
        p03.Name = '1902-ECPIX LSI';
        p03.Product_Category__c = 'Hardware';
        //p03.Product_Line_Name__c = 'Financial Image and Payment Systems';
        p03.Solution_Portfolio__c = 'Payment Solutions';
        //p02.Division__c='Retail';
        p03.isActive=true;
        p03.service_offer_category__c = 'SWM';
        p03.CanUseQuantitySchedule =true;
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
        p04.isActive=true;
        p04.service_offer_category__c = 'SWM';
        p04.CanUseQuantitySchedule =true;
        prdlist4.add(P04);
        
        
        insertprodlist.add(P04);
        
        
        insert insertprodlist;   
        //end products creation     
        
        //Creating Opportunity Line Items               
        Opportunity opp= TestRecordsFactory.createSimpleOpportunity();
        List<PricebookEntry> pbe=TestRecordsFactory.createPriceBookEntry(insertprodlist);
        List <OpportunityLineItem> oliL=TestRecordsFactory.createOpportunityLineItem(opp,pbe);
        OpportunityLineItem oli=TestRecordsFactory.createOpportunityLineItem(opp,pbe[0]);
        OpportunityLineItem olObj = [Select PricebookEntryId,quantity From OpportunityLineItem where PricebookEntry.Product2.Product_Category__c = 'Hardware'
                                     and Id IN:oliL limit 1 ];
        OpportunityLineItemSchedule oLIS = TestRecordsFactory.createOpportunityLineitemSchedule(olObj);
        idist.add(oli.Id);
        SchedulerClass.getOpportunity(opp.id);
        SchedulerClass.validateOppForWarning(opp.id);
        SchedulerClass.getProducts();
        SchedulerClass.ScheduleCalculateWrapper(opp.Id);
        SchedulerClass.DeleteOLI1(idist,opp.id);
        list<OpportunityLineItem> oppLineObj = new list<OpportunityLineItem> ();
        oppLineObj =[select id from OpportunityLineItem where id IN :idist];
        System.assert(oppLineObj.size()==0);    
        SchedulerClass.SubmitManegeSchedule1('JsonStringSubmit');
        SchedulerClass.SaveManegeSchedule1('JsonString');
    }
    static testmethod void  ValidateLeadTime(){
        
        Product2 oldprod = new product2();     
        Map<ID,ID>PricebookIDfor1stCondition = New  Map<ID,ID>();
        Map<ID,ID>PricebookIDfor2ndCondition= New  Map<ID,ID>();
        Map<ID,ID>PricebookIDfor3rdCondition= New  Map<ID,ID>();
        
        //create new account
        Account a = new Account (name = 'testing task Deletion of Closed Opp', 
                                 Master_Customer_Number__c = 'TEST000012', 
                                 Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true);
        System.runAs(testRecordsFactory.getUser()){
            insert a;
        }
        //create new salesorg
        Sales_Org__c s = new Sales_Org__c (name = 'testing task Deletion of Closed Opp',
                                           Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor
        Competitors__c c = new Competitors__c (name = 'testing task Deletion of Closed Opp');
        insert c;
        
        //Advocated_Solution__c adv1 = new Advocated_Solution__c(name='test1', Advocated_Solution_ID__c='test', Lead_Time__c = 4, Line_of_Business__c = 'Financial');
        //insert adv1;
        
        List<Product2> products = new List<Product2>();
        Product2 EntertainmentProduct = new Product2(Name='Entertainment Product', service_offer_category__c = 'SWM',CurrencyIsoCode='USD', Product_Category__c ='HW', Solution_Portfolio__c='Travel Self Service', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*,Advocated_Solution_Lookup__c = adv1.Id*/);
        Product2 PCELSProduct = new Product2(Name='PCELS Product', CurrencyIsoCode='USD', Product_Category__c ='HW',service_offer_category__c = 'SWM', Solution_Portfolio__c='PC / ELS', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*, Advocated_Solution_Lookup__c = adv1.Id*/);
        Product2 TravelProduct = new Product2(Name='Travel Product', CurrencyIsoCode='USD', Product_Category__c ='HW',service_offer_category__c = 'SWM', Solution_Portfolio__c='Travel Self Service', /*Product_Line_Name__c='Other',*/ isactive=true, CanUseQuantitySchedule = true /*, Advocated_Solution_Lookup__c = adv1.Id*/);
        products.addAll(new List<Product2>{EntertainmentProduct,PCELSProduct,TravelProduct});
        insert products;
        
        List<PricebookEntry> standardpriceBooks = new List<PricebookEntry>();
        String stdPriceBook = Test.getStandardPricebookId();//01s700000002GMcAAM
        PricebookEntry EntertainmentStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=EntertainmentProduct.id,PriceBook2Id=stdPriceBook, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry PCELSStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=PCELSProduct.id,PriceBook2Id=stdPriceBook, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        PricebookEntry TravelStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=TravelProduct.id,PriceBook2Id=stdPriceBook, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
        standardpriceBooks.addAll(new List<PricebookEntry>{EntertainmentStandardPricebook, PCELSStandardPricebook, TravelStandardPricebook});
        insert standardpriceBooks;
        
        List<PricebookEntry> GlobalSalespriceBooks = new List<PricebookEntry>();//01s7000000030GMAAY = GlobalVariable.pricebookId
        PricebookEntry EntertainmentGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=EntertainmentProduct.id,PriceBook2Id=GlobalVariable.pricebookId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry PCELSGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=PCELSProduct.id,PriceBook2Id=GlobalVariable.pricebookId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        PricebookEntry TravelGlobalPricebook = new PricebookEntry(CurrencyIsoCode='USD',Product2Id=TravelProduct.id,PriceBook2Id=GlobalVariable.pricebookId, UnitPrice=0.00, UseStandardPrice=true, isactive = true);
        GlobalSalespriceBooks.addAll(new List<PricebookEntry>{EntertainmentGlobalPricebook, PCELSGlobalPricebook, TravelGlobalPricebook});
        
        insert GlobalSalespriceBooks;
        
        list<PricebookEntry> pbe1 = [Select p.CurrencyIsoCode,p.Product2.Solution_Portfolio__c, p.Id, p.Name, p.Pricebook2Id, p.Product2Id, p.ProductCode, p.UnitPrice, p.UseStandardPrice 
                                     from PricebookEntry p  
                                     where p.Pricebook2Id = :GlobalVariable.pricebookId
                                     and p.CurrencyIsoCode = 'USD'
                                     and IsActive=true and Product2.IsActive=true
                                     and Product2.Product_Category__c='HW'
                                     and Product2.Solution_Portfolio__c IN ('PC / ELS','Travel Self Service')                                           
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
            Opportunity opp2 = new Opportunity();
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
                //oppObj.Solution_Portfolio__c='Travel Self Service'; - P360 Initial Change - Ahad
                //oppObj.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                oppObj.PRIMARY_COMPETITOR__C = c.id;
                oppObj.Expected_Delivery_Date__c = System.TODAY().addDays(30);
                oppObj.closeDate = System.TODAY();
                oppObj.stagename = 'Analyzing';
                oppObj.Is_PreBuild_Order__c = true;
                oppObj.Amount = 0;
                
                
                oppList.add(oppObj);
                
                
                
            }
            
            
            User HospitalityUser = [SELECT id, LOB__c, License_Entitlement__c from User where (LOB__c = 'Hospitality' OR License_Entitlement__c = 'Hospitality') AND IsActive = true limit 1].get(0);
            
            oppW.name = 'Test Warning';
            oppW.AccountID = a.id;
            oppW.type = 'Indirect Channel';
            Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
            //oppW.ADVOCATED_SOLUTION__C = 'Image and Item Processing';
            oppW.MARKETING_PROGRAM__C = 'None';
            //oppW.APPLICATION__C = 'ITRAN 8000';
            oppW.CURRENCYISOCODE = 'USD';
            oppW.SALES_ORG__C = s.id;
            oppW.INVOICE_TRIGGER__C='Shipment';
            //oppW.Solution_Portfolio__c='Travel Self Service'; -- P360 Initial Change - Ahad
            //oppW.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
            oppW.PRIMARY_COMPETITOR__C = c.id;
            oppW.Expected_Delivery_Date__c = System.TODAY().addDays(1000);
            oppW.closeDate = System.TODAY();
            oppW.stagename = 'Analyzing';
            oppW.RecordTypeId = r1;
            oppW.OwnerId = HospitalityUser.id;
            oppW.Amount = 100.00;
            oppList.add(oppW);
            
            if(!oppList.IsEmpty()){
                insert oppList;
            }
            
            Test.startTest();
            
            
            /** OpportunityLineItem for PricebookIDfor1stCondition **/
            
            if(oppObj.Id != null){     
                
                Oli1st.OpportunityId=oppObj.Id;
                Oli1st.UnitPrice=10;
                Oli1st.Quantity=100;
                Oli1st.PricebookEntryId=EntertainmentGlobalPricebook.id;
                Oli1st.Quantity=100;
                Oli1st.UnitPrice=10;
                lineItemList.add(Oli1st);
                
                Oli1stObj  = new OpportunityLineItem();
                Oli1stObj.OpportunityId=oppObj.Id;
                Oli1stObj.UnitPrice=10;
                Oli1stObj.Quantity=100;
                Oli1stObj.PricebookEntryId=EntertainmentGlobalPricebook.id;
                Oli1stObj.Quantity=100;
                Oli1stObj.UnitPrice=10;
                lineItemList.add(Oli1stObj);
            }
            
            if(oppObj.Id != null){
                
                Oli2nd.OpportunityId=oppObj.Id;
                Oli2nd.UnitPrice=10;
                Oli2nd.Quantity=100;
                Oli2nd.PricebookEntryId =   PCELSGlobalPricebook.Id;
                Oli2nd.Quantity=100;
                Oli2nd.UnitPrice=10;
                lineItemList.add(Oli2nd);
            }
            
            if(oppObj.Id != null){
                
                Oli3rd  = new OpportunityLineItem();
                Oli3rd.OpportunityId=oppObj.Id;
                Oli3rd.UnitPrice=10;
                Oli3rd.Quantity=100;
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
            
            if(oppObj.id != null){
                List<string> wrningList =  SchedulerClass.validateOppForWarning(oppObj.id);  
                System.assert(wrningList.size()==0);
            }
            
            Test.stopTest();
        }
    }
}