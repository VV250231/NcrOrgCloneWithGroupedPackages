@isTest
private class Testupdate_region_from_account {

    static testMethod void testUpdateRegion() {
        Account a = new Account(      
        Account_Country_Code__c = 'EG',
        Active_Account__c = true,        
        Master_Customer_Number__c = '1631',
        Name = 'Unit Test ' + System.now(),
        RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
        RoR_Update_Date_Time__c = System.now(),
        Industry = 'RETAIL:CHANNEL',
        account_region__c='INDIA'
        );
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
            insert a;
        }        
        
       Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'Financial Self Service';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        Presales_Engineer_Activity__c PFR = new Presales_Engineer_Activity__c();
        PFR.PSE_Account__c = a.id;
        PFR.PSE_Activity_Category__c  = 'Customer-Specific';
        PFR.PSE_Activity_Description__c = 'Early stage presales-meetings/Demos';
        PFR.PSE_Activity_Hours_YTD__c = 12.1;
        PFR.PSE_Current_Status_Comments__c = '1';
        PFR.PSE_Estimated_Remaining_Hours__c = 2;
        PFR.PSE_IsActive__c = True;
        PFR.PSE_Opportunity__c=opp.id;
        PFR.PSE_Opportunity_Number_Not_Yet_Created__c = False ;
        PFR.PSE_Region__c = 'NAMER MAJORS';
        PFR.PSE_Solution_Product_Supported__c = 'test';
        PFR.PSE_Start_Date__c = Date.today();
        insert PFR;
        update PFR;
        
        system.assertNotEquals(PFR.PSE_Region__c, null);
         
    }
         }