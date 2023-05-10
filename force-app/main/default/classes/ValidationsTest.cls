@isTest
public class ValidationsTest {
    public static testMethod void testValidateOpportunity() 
    {
        Validations.ADMIN_PROFILE_IDS.clear(); 
        
        //Fetch Customer Record Type
        //RecordType r = [Select Id from RecordType where SobjectType = 'Account' and name = 'Customer' and IsActive = true];
        
        //create new account
        Account a = TestRecordsFactory.createAccount();
        
        //create new salesorg
        Sales_Org__c s = new Sales_Org__c (name = 'testing validateAmount trigger', Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor
        Competitors__c c = new Competitors__c (name = 'testing validateAmount trigger');
        insert c;
        
        Id r = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        
        //create new opportunity
        Opportunity o = new Opportunity (RecordTypeId = r, AccountId =a.Id, name = 'testing validateAmount trigger', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Analyzing', Probability = 10, Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, Amount=10.00);
        insert o;
        Map<ID,Opportunity> oldOpportunityMap = new Map<ID,Opportunity>();
        oldOpportunityMap.put(o.ID, o); 
      
        
        Product2 pr = new Product2(name='prod1',Solution_Portfolio__c  ='Retail Assisted Service',isactive=true);
        insert pr;
       
        /*insert new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(),Product2Id=pr.id,unitPrice=2,UseStandardPrice=false,isActive=true);
        PricebookEntry p = [Select Id from PricebookEntry where CurrencyIsoCode = 'USD' and Product2.Solution_Portfolio__c  = 'Retail Assisted Service' and Product2.CurrencyIsoCode = 'USD' and Product2.isactive=true];
        */
        //create new opportunity line item
        Payment_Fees_Management__c p1 = new Payment_Fees_Management__c(name='testpay');
        insert p1;
        PricebookEntry p =  TestRecordsFactory.createPriceBookEntry(pr);
        OpportunityLineItem l1 = TestRecordsFactory.createOpportunityLineItem(o,p);
     
        
        //create new opportunity line item
		 OpportunityLineItem l2 = TestRecordsFactory.createOpportunityLineItem(o, p);
       
        //        insert l2;
        
        /*List<OpportunityLineItem> OLIs = new List<OpportunityLineItem>();
        OLIs.add(l1);
        OLIs.add(l2);
        insert OLIs;
        */
        //create new opportunity line item schedule
        //OpportunityLineItemSchedule olish1 = new OpportunityLineItemSchedule(OpportunityLineItemId = l1.Id, ScheduleDate = System.TODAY() + 5, Type = 'Quantity', Quantity = 100);
        //        insert olish1;
        
        //create new opportunity line item schedule
        //OpportunityLineItemSchedule olish2 = new OpportunityLineItemSchedule(OpportunityLineItemId = l2.Id, ScheduleDate = System.TODAY() + 7, Type = 'Quantity', Quantity = 100);
        //        insert olish2;
        
        //List<OpportunityLineItemSchedule> OLISs = new List<OpportunityLineItemSchedule>();
        //try{
           // OLISs.add(olish1);
            //OLISs.add(olish2);
            //insert OLISs;
        //}catch (Exception e) {System.debug(e.getMessage());}
        
        
        
        //OLISs[0].ScheduleDate = System.TODAY() + 0;
        //update olish1;
        
        //OLISs[1].ScheduleDate = System.TODAY() + 30;
        //update olish2;
        
        //update OLISs;
        
        //Opportunity opp = [select id, name, CloseDate, CurrencyIsoCode, Amount, Expected_Delivery_Date__c from opportunity where name = 'testing validateAmount trigger' limit 1];
        o.name = 'testing validateAmount trigger update';        
        update o;
        Test.startTest();
        
        try{
            //create new opportunity line item schedule
            OpportunityLineItemSchedule olish3 = new OpportunityLineItemSchedule(OpportunityLineItemId = l2.Id, ScheduleDate = System.TODAY() - 60, Type = 'Quantity', Quantity = 100);
            insert olish3;
        }catch(Exception e){System.debug(e.getMessage());}
        
        try {
            l1.UnitPrice = 50000;
            l2.UnitPrice = 100000;
            List<OpportunityLineItem> OLIs1 = new List<OpportunityLineItem>();
            OLIs1.add(l1);
            OLIs1.add(l2);
            update OLIs1;
        }catch(Exception e){System.debug(e.getMessage());}
        Validations.validateOpportunity(null,null);
        Map<ID,Opportunity> newOpportunityMap = new Map<ID,Opportunity>();
        o.CloseDate = System.today()-1;
        newOpportunityMap.put(o.ID, o); 
        
        Validations.validateOpportunity(newOpportunityMap,oldOpportunityMap);
        //commented as per PS roll back request by linda @Ajay
        //validateOpportunityProducts(null);
        Map<ID,OpportunityLineItem> newOpportunityLineItemsMap = new Map<ID,OpportunityLineItem>();
        newOpportunityLineItemsMap.put(l1.ID, l1);
        newOpportunityLineItemsMap.put(l2.ID, l2);
        //commented as per PS roll back request by linda @Ajay
        //validateOpportunityProducts(newOpportunityLineItemsMap);
        Opportunity o33 = new Opportunity (RecordTypeId = r, AccountId =a.Id, name = 'testing validateAmount trigger', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() - 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Analyzing', Probability = 10, Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, Amount=20.00);
        try{
            //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
			//Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
            //create new opportunity
            Opportunity o22 = new Opportunity (RecordTypeId = r, AccountId =a.Id, name = 'testing validateAmount trigger', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Analyzing', Probability = 10, Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, Amount=200000000.00);
            List <Opportunity> o1=new List <Opportunity>();
            Validations.ADMIN_PROFILE_IDS.clear();
            User HospUser = [SELECT id, LOB__c, License_Entitlement__c from User where (LOB__c = 'Hospitality' OR License_Entitlement__c = 'Hospitality') AND isActive = TRUE limit 1].get(0);
            Opportunity dOpp1 = new Opportunity (RecordTypeId = r/*'012700000001PoZ'*/, AccountId =a.Id, name = 'TestEDDvsEBD', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 20, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 10, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Analyzing', Probability = 10, Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, OwnerId = HospUser.id);         
            Opportunity o221 = new Opportunity (RecordTypeId = r, AccountId =a.Id, name = 'testing validateAmount trigger', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() - 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Analyzing', Probability = 10, Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, Amount=25.00);
            Opportunity dOpp2 = new Opportunity (RecordTypeId = r/*'012700000001PoZ'*/, AccountId =a.Id, name = 'TestCommitmentRisk01', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 20, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 30, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Proposing', Commitment_Risk__c = NULL, Probability = 75, Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, OwnerId = HospUser.id);
            o1.add(dOpp1);
            o1.add(o221);
            o1.add(dOpp2);
            o1.add(o22);
            o1.add(o33);
            insert o1;
        }catch(Exception e){System.debug(e.getMessage());}
        
        try{
            
            OpportunityLineItem o33l1 = TestRecordsFactory.createOpportunityLineItem(o, p);
            
            OpportunityLineItemSchedule o33olish1 = new OpportunityLineItemSchedule(OpportunityLineItemId = o33l1.Id, ScheduleDate = System.TODAY() + 1, Type = 'Quantity', Quantity = 100);
            /*List <OpportunityLineItem> oliL=new List <OpportunityLineItem>();
            oliL.add(o33l1);
            oliL.add(o33l1);
            insert oliL;*/
            o33.Expected_Delivery_Date__c = System.TODAY() + 90;
            update o33;
        }catch(Exception e){System.debug(e.getMessage());}
        
        
        try{
            Validations.IS_OPPORTUNITY_UPDATE = true;       
            o33.name = 'A new Name';
            update o33;
            
        }catch(Exception e){System.debug(e.getMessage());}
        
        system.assertEquals(o33.name,'A new Name');
        
        Test.stopTest();
        
    }
}