@isTest
public class synchUSMOnOppUpdt_Test {
     
    public static testMethod void SynkUSMQueUpdate(){
       List<Product2> products = new List<Product2>(); 
       Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD',  Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        products.add(HWMProduct1) ;
       insert products;
        
       List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(1);
       Opportunity opp = Opportunities[0]; 
       insert opp;
       List<Id> Opplist = new List<Id>(); 
       Opplist.add(Opp.Id);	
       OpportunityLineItem lstOLI = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(HWMProduct1));
       synchUSMOnOppUpdateQueueable QueableObj = new synchUSMOnOppUpdateQueueable(Opplist); 
       synchUSMOnOppLinkQueueable QueableLinkObj = new synchUSMOnOppLinkQueueable(Opplist);
        Test.startTest();
           Id job1= System.enqueueJob(QueableObj);
            System.enqueueJob(QueableLinkObj);
        system.assert(job1 !=null);
        Test.stopTest();
    }
}