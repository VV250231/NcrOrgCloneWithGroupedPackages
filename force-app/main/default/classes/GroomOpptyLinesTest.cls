@isTest
public class GroomOpptyLinesTest {
     @testSetup static void setup() {
         Account act=TestRecordsFactory.createAccount('Test123');
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(act);
         Product2 p = new Product2();
        //p = TestRecordsFactory.createProduct(adv);
        p.Name = 'Test Product';
        p.Product_Category__c ='Software';
        p.Family ='Solution';
        p.service_offer_category__c='SWM';
        p.CanUseQuantitySchedule=true;
        insert p;
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(p);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=p.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        insert oli;
        
        zqu__Quote__c q = new zqu__Quote__c(name = 'test-quote', zqu__Account__c = act.id, zqu__Status__c = 'QA Processing Complete', zqu__Opportunity__c= opp .Id);
        insert q;
     }
    
     static testMethod void runTest1() {      
        Test.startTest();
            Database.executeBatch(new GroomOpptyLines('Select Id,OpportunityId, Opportunity.AccountId, Groomed__c from Opportunitylineitem WHERE Groomed__c != \'Yes\'', true),1); 
        Test.stopTest();
     }

    static testMethod void runTest2() {      
        Test.startTest();
            Database.executeBatch(new GroomOpptyLines('Select Id,OpportunityId, Opportunity.AccountId, Groomed__c from Opportunitylineitem WHERE Groomed__c != \'Yes\'', false),1); 
        Test.stopTest();
     }
}