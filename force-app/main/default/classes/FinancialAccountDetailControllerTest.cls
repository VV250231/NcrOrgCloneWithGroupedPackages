@IsTest
public class FinancialAccountDetailControllerTest{
    static testmethod void testFinAccDetail() {
        Account a=TestRecordsFactory.createAccount();
        a.Industry='FINANCIAL:BANKING';
        FinancialAccountDetailController.getAccount(a.id);
        FinancialAccountDetailController.getLabels();
         System.runAs(getUser()){
        FinancialAccountDetailController.saveAccount(a);
        } 
        FinancialAccountDetailController.getOpts('NAMER',a.Id);
        
        Sales_Org__c s = TestRecordsFactory.createSalesOrg();
        Competitors__c c = TestRecordsFactory.createCompetitor();
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true; 
        
        insert opp ;
        system.assertEquals(opp.AccountID , a.id);
        TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()))   ;

        FinancialAccountDetailController.getHeatMapData(a.Id) ;
    }
    
     Public Static User getUser()
    {
        
       User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    
    
}