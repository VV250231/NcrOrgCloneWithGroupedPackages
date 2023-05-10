/*
##################################################################################################
# Project Name..........: NSC Mobility                                                                      
# File..................: TestOppContactRoleCtrl.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                   
# Created Date..........: 07-05-2015                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 07-05-2015 
# Description...........: The test class is written to test the OppContactRoleCtrl Class.
################################################################################################
*/
@isTest
private class TestOppContactRoleCtrl  {  
    static testMethod void myUnitTest() { 
    
         
        /* setup Opportunity and oppcontactrole object */
         // create new account object
        Account a = new Account (name = 'testing task Deletion of Closed Opp', 
                                 LOB__c='FINANCIAL',
                                 Master_Customer_Number__c = 'TEST000012', 
                                 Account_Country_Code__c = 'US', 
                                 CurrencyIsoCode = 'USD', 
                                 Active_Account__c = true);
        //insert a;
        system.runAs(TestRecordsFactory.getUser()) {
            insert a;
        }
        
        
        // create Contact record
        List<Contact> conList = new List<Contact>();
        
        Contact con1 = new Contact(LastName = 'test1', AccountId = a.Id);
        conList.add(con1);
                  
        Contact con2 = new Contact(LastName = 'test2', AccountId = a.Id);
        conList.add(con2);  
        
        Contact con3 = new Contact(LastName = 'test3', AccountId = a.Id);
        conList.add(con3);
        
        insert conList;
        
        // create new sales org object 
        Sales_Org__c s = new Sales_Org__c (name = 'testing task Deletion of Closed Opp',
                                              Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor object 
        Competitors__c c = new Competitors__c (name = 'testing task Deletion of Closed Opp');
        insert c;
        
        // create new Opportunity object 
        Opportunity opp = new Opportunity();   
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'SERVICES';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.Contacts__c = con1.Id;
        insert opp;
        
        OpportunityContactRole roleObj1 = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = con1.Id, Role = 'Business User');
        insert roleObj1;
        
        OpportunityContactRole roleObj2 = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = con2.Id, Role = 'Other');
        /* setup Opportunity and oppcontactrole object */
        
        ApexPages.currentPage().getParameters().put('id', opp.Id);    
        ApexPages.StandardController stdctr = new ApexPages.StandardController(opp);
        OppContactRoleCtrl conRoleObj = new OppContactRoleCtrl(stdctr);
        OppContactRoleCtrl.searchContact('test');
        OppContactRoleCtrl.loadContact(); 
        
        conRoleObj.oppContactRole.add(roleObj2);
        conRoleObj.saveConRoles();
             
        opp.Contacts__c = con2.Id;
        update opp;
         
        opp.Contacts__c = con3.Id;
        update opp;
        system.assertEquals(opp.Contacts__c , con3.Id);
        
    }
}