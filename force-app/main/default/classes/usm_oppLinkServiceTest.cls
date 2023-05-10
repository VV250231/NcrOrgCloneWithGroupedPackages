@isTest
private class usm_oppLinkServiceTest {
    
    private static testMethod void test() {
        usm_oppLinkService.usmLinkServiceRequest tstObj = new usm_oppLinkService.usmLinkServiceRequest() ;
        tstObj.nscOppNum = 'OPP001' ;
        tstObj.usmOppNum = 'USM001' ;
        Opportunity oppNew1 = TestRecordsFactory.createOpportunityWithLineItem() ;
        
        Opportunity oppNew2 = new Opportunity();
        oppNew2.name = 'abc01';
        oppNew2.AccountID = TestRecordsFactory.createAccount('MCN001').id;
        oppNew2.Name = 'Linkage Opportunity01';
        oppNew2.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        oppNew2.CURRENCYISOCODE = 'USD';
        oppNew2.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        oppNew2.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        oppNew2.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        oppNew2.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        oppNew2.closeDate = System.TODAY();
        oppNew2.stagename = 'Analyzing';
        oppNew2.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');

        oppNew2.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        oppNew2.EndCustomerUnknown__c = true;
        insert oppNew2;
        
        // Opportunity oppNew2 = TestRecordsFactory.createOpportunityWithLineItem() ;
        USM_Opportunity_Detail__c usmDet1 = new USM_Opportunity_Detail__c(Name='USM001') ;
        insert usmDet1 ;
        
        Test.startTest() ;
        Opportunity nUpdate = new Opportunity(Id=oppNew1.Id, usm_Opportunity_Number__c =  'USM001' ) ;
        update nUpdate ;
        
        
        Opportunity nquery = [SELECT Id, Opportunity_Number__c  FROM Opportunity WHERE Id=:oppNew1.Id] ;
        
        usm_oppLinkService.usmOppLink(tstObj) ;
        tstObj.nscOppNum = nquery.Opportunity_Number__c ;
        tstObj.usmOppNum = 'USM001' ;
        usm_oppLinkService.usmOppLink(tstObj) ;
        usm_oppLinkService.usmLinkServiceRequest tstObj1 = new usm_oppLinkService.usmLinkServiceRequest() ;
        tstObj1.nscOppNum = 'Tset001' ;
        usm_oppLinkService.usmOppLink(tstObj1) ;
        Opportunity nUpdate1 = new Opportunity(Id=oppNew2.Id, usm_Opportunity_Number__c =  'USM001' ) ;
        update nUpdate1 ;
        tstObj.nscOppNum = 'Test' ;
        tstObj.usmOppNum = 'USM001' ;
        
        usm_oppLinkService.usmOppLink(tstObj) ;
        usm_oppLinkService.usmOppLink(null) ; 
        tstObj1.nscOppNum = 'OOID' ;
        usm_oppLinkService.usmOppLink(tstObj1) ;
        tstObj.nscOppNum = 'Test111' ;
        tstObj.usmOppNum = 'USM001111' ;
        usm_oppLinkService.usmOppLink(tstObj) ;
        System.assertEquals(usm_oppLinkService.usmOppLink(tstObj1).Status, 'Failure');
        Test.stopTest() ;
        
    }
    
}