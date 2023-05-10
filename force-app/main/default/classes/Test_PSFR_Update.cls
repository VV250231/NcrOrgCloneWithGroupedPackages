/*   Created by  : Saagar Kinja
*    Email ID    : saagar.kinja@ncr.com 
*    QLID        : SK250817
*    Details     : This Test class is created to test trigger : Reject_FundRequest in Raise Query Object.
*/

@isTest
public class Test_PSFR_Update{
    
    Public Static User getUser()
    {
        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval(){
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        System.assertEquals(opp.recordTypeId, r1);
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        
        
        insert PFR;
        PFR.PSFR_Authentication_Trigger__c=true;
        //PFR.Division_of_User__c='FIN';
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        System.assertEquals(PFR.Approval_Status__c, 'Approved');      
        
        
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval4(){
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        // PFR.PFR_Opportunity__c = opp.id;
        PFR.Account__c=a.id;
        insert PFR;
        
        
        
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        
        System.assertEquals(PFR.Approval_Status__c, 'Approved');
        
    }
    public static testmethod void Test_PSFR_SubmitforApproval2(){
        RecordType r =[Select id from recordtype where developername ='Partner'];
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r.Id,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
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
        opp.recordTypeId = r1.Id;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        // PFR.PFR_Opportunity__c = opp.id;
        //  PFR.Account__c=a.id;
        insert PFR;
        
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        System.assertEquals(PFR.Approval_Status__c, 'Approved');
        
        
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval3(){
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        // RecordType r =[Select id from recordtype where developername ='Partner'];
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '2-Early Stage Presales';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        //PFR.Account__c=a.id;
        insert PFR;
        
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        System.assertEquals(PFR.Approval_Status__c, 'Approved');  
        
        
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval12(){
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '3- Proof of Concept';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        //PFR.Account__c=a.id;
        insert PFR;
        
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        System.assertEquals(PFR.Approval_Status__c, 'Approved');
        
        
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval15(){
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '4-PS SOW Creation & Pricing';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        //PFR.Account__c=a.id;
        insert PFR;
        
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        
        System.assertEquals(PFR.Approval_Status__c, 'Approved');
        
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval125(){
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '5-PS work-ahead pending SOW signature';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        //PFR.Account__c=a.id;
        insert PFR;
        
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        
        
        System.assertEquals(PFR.Approval_Status__c, 'Approved');
    }
    
    public static testmethod void Test_PSFR_SubmitforApproval1225(){
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        
        System.runAs(getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
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
        opp.recordTypeId = r1;
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '6-Non-Standard Gratis work / Customer satisfaction issue';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        //PFR.Account__c=a.id;
        insert PFR;
        
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        PFR.Approval_Status__c='Pending for Approval';
        update PFR;
        PFR.Approval_Status__c = 'Approved';
        update PFR;
        
        System.assertEquals(PFR.Approval_Status__c, 'Approved');
        
    }
    
}