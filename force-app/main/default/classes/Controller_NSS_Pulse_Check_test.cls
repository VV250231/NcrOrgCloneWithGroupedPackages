@istest
public class Controller_NSS_Pulse_Check_test {
    
    public static testmethod void Opportunity(){
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();//0127000000014kqAAA
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
           /* CAP_Watch__c = 'CAP',*/
            //EBA_SF-688
            account_region__c='INDIA'
        );
        System.runAs(TestRecordsFactory.getUser()){
        	insert a;
        }
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        
        
        Profile RenualProfile = TestRecordsFactory.getProfile('Global Renewals'); 
        List<User> UserList = TestRecordsFactory.createUsers(RenualProfile.Id,'GlobalRenewals',1);
        
        System.runAs(UserList[0]) 
        { 
        Opportunity opp = new Opportunity();
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        //opp.Solution_Portfolio__c = 'Financial Self Service'; -- P360 Initial Change - Ahad
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        Opp.Forecast_Category__c ='Pipeline';
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.NSSOffered__c=false;
            System.runAs(TestRecordsFactory.getUser()){ 
                insert opp; 
            Test.startTest(); 
            //system.debug('0000000000000000000'+opp.id); 
            Boolean checkvalidate =  Controller_NSS_Pulse_Check.validateproductlist(opp.Id);
            System.assert(checkvalidate);
            Test.stopTest();
        }
        }
  
    }
    
}