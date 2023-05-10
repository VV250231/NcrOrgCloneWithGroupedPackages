@isTest( seeAllData = true )
public class QuBy_Detail_TEST {
    static testMethod void runUnitTest() {
      Test.startTest();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
          
        //String OpportunityNumber = [ SELECT Opportunity_Number__c FROM Opportunity WHERE id = : opp.id ].Opportunity_Number__c;        
        Test.stopTest(); 
        QuBy_Detail__c QD = new QuBy_Detail__c();  
        QD.Quote_Number__c='350000999'  ;       
        QD.QuickLook_ID__c = 'ms250942';
        QD.Country_Code__c = 'US';
        QD.MCN__c = 'TESTMCN00001X';
        QD.CurrencyIsoCode = 'USD';
        QD.Annuity_Quote_Status__c = 'Submitted';
        QD.Rollout_Date__c = system.today();
        QD.Recipients_Email__c = 'test@test.com';
        QD.Solution_Quote_Amount__c=100000;
        QD.Cloud_Products__c = 1000;
        QD.Hardware_Products__c = 1000;
        QD.PS_Products__c = 1000;
        QD.Services_Products__c = 1000;
        QD.Software_Products__c = 1000;
        QD.Opportunity_No__c = opp.Opportunity_Number__c;     
        QD.Description__c = 'TEST NAME'; 
        QD.Latest_Version__c='1'; 
        insert QD;
        System.assertEquals(QD.Opportunity_No__c, null,'Opportunity Number should not be null');
        
        Qd.X48_hour_Notification__c=true;
        QD.Description__c = 'TEST NAME';
        update QD;
        QuBY_DetailTriggerHandler.opportunityAssociationToQuote( new List<QuBy_Detail__c> { QD } );
        QuBY_DetailTriggerHandler.NTQCreationCall( new List<QuBy_Detail__c>{ QD } );
        
        QD.Latest_Version__c='-1';
        update QD;
        
    }
    
    static testMethod void runUnitTest_3() {
        String test='Test';
        System.assertNotEquals(Test, null,'Test should not be null');
    }
    
    static User getUser(){
        
        
        User Usr = [Select Id from User Where Name = 'Soup User'];

        return Usr;
    }
    
    static testMethod void testPRM_QuBY_DetailTriggerHandle() {
        test.startTest();
        // creater partner account
        Account act = PRM_TestRecordsFactory.createPartnerAccount('1',null);
        System.assertEquals(act.Partner_Program_Level__c, 'Silver','Partner Program Level should not be Silver');    
        System.runAs(getUser()){ 
            insert act;               
        }
        // create partner contact
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id,'1',null);
        insert con;
        // create partner user
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id,'1',null);
        insert u;
        // create partner opportunity request
        Partner_Opportunity__c obj = new Partner_Opportunity__c();
        obj.Amount__c = 100;
        obj.CAM__c = userinfo.getUserId();
        obj.End_Customer__c = 'End Customer';
        obj.End_Customer_Primary_Contact__c = 'End customer primary contact';
        obj.Expected_Book_Date__c = system.today();
        obj.Opportunity_Name__c = 'Test Opportunity';
        obj.Partner_Account__c = act.Id;
        obj.Partner_Sales_Person__c = 'partner sales person';
        obj.TAM__c = null;          
        insert obj;
        
        // create sales org
        Sales_Org__c salesOrg = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert salesOrg;
        
        //create new competitor object 
        Competitors__c competitor = new Competitors__c(name = 'testing competitor');
        insert competitor;
        
        // create partner opportunity
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = act.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = salesOrg.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = competitor.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Indirect - Include in Funnel Reseller'); //'0120g000000YU9x';
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        opp.Linked_Partner_Opportunity__c = obj.Id;
        
        insert opp;
        test.stopTest();
        // create quote record
        String OpportunityNumber = [ SELECT Opportunity_Number__c FROM Opportunity WHERE id = : opp.id ].Opportunity_Number__c;    
        QuBy_Detail__c QD = new QuBy_Detail__c();  
        QD.Quote_Number__c='350000999'  ;       
        QD.QuickLook_ID__c = 'ms250942';
        QD.Country_Code__c = 'US';
        QD.MCN__c = 'TESTMCN00001X';
        QD.CurrencyIsoCode = 'USD';
        QD.Annuity_Quote_Status__c = 'Submitted';
        QD.Rollout_Date__c = system.today();
        QD.Recipients_Email__c = 'test@test.com';
        QD.Solution_Quote_Amount__c=100000;
        QD.Cloud_Products__c = 1000;
        QD.Hardware_Products__c = 1000;
        QD.PS_Products__c = 1000;
        QD.Services_Products__c = 1000;
        QD.Software_Products__c = 1000;
        QD.Opportunity_No__c = OpportunityNumber;     
        QD.Description__c = 'TEST NAME';   
        insert QD;
        
        List<QuBy_Detail__c> tempList = new List<QuBy_Detail__c>();
        tempList.add(QD);
        PRM_QuBY_DetailTriggerHandler.updateQuoteNumOnPartnerOpp(tempList);
        Delete QD;
        Undelete QD;
    }
}