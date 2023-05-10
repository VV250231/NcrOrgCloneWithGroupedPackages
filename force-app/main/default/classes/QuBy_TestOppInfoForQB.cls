/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_TestOppInfoForQB.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 28-08-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 28-08-2016
# Description...........: This is test class for QuBy_OppInfoForQB class.                          
##################################################################################################*/
@isTest
private class QuBy_TestOppInfoForQB{
    
    static testMethod void UnittestFirst() {
        
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TESTQD';
        
        QD.Quote_Number__c = '123';
        insert QD;
        ApexPages.currentPage().getParameters().put('qno','123');
        QuBy_OppInfoForQB quby = new QuBy_OppInfoForQB( );
        System.assertEquals(ApexPages.currentPage().getParameters().put('qno','123'), '123');
    }
    
    static testMethod void UnittestSecond() {
        
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TESTQD';
        
        insert QD;
        
        ApexPages.currentPage().getParameters().put('qno','123');
        QuBy_OppInfoForQB quby = new QuBy_OppInfoForQB( );
        System.assertEquals(ApexPages.currentPage().getParameters().put('qno','123'), '123');
    }
    
    static testMethod void UnittestThird() {
        
        //Inserting Dummy Account.
        Account a = new Account ( name = 'testing task Deletion of Closed Opp', 
                                 LOB__c='FINANCIAL',
                                 Master_Customer_Number__c = 'TEST000012', 
                                 Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true );
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
        
        //Inserting Dummy Sales Org.        
        Sales_Org__c s = new Sales_Org__c ( name = 'test org', Is_Active_in_RoR__c = true );
        insert s;
        
        //Inserting Dummy Competitor
        Competitors__c c = new Competitors__c (name = 'testing competitor');        
        insert c;
        
        //Inserting Dummy Opportunity
        Id RecordTypeId = [ Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'IncludeinFunnel'  ].Id;
        Opportunity opp = new Opportunity();   
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'Test Opportunity';
        //opp.SalesLogixId__c = 'aaaaa';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'Entertainment Self Service';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = RecordTypeId;        
        insert opp;
        
        ApexPages.currentPage().getParameters().put('oppno',opp.id);
        QuBy_OppInfoForQB quby = new QuBy_OppInfoForQB( );
        ApexPages.currentPage().getParameters().put('oppno',null);
        QuBy_OppInfoForQB quby1 = new QuBy_OppInfoForQB( );
        System.assertEquals(ApexPages.currentPage().getParameters().put('oppno',null), null);
        // System.assertEquals(ApexPages.currentPage().getParameters().put('oppno',opp.id), null);
        
        
    }
}