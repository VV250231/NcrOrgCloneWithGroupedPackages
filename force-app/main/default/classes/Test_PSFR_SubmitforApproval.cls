/*   Created by  : Saagar Kinja
*    Email ID    : saagar.kinja@ncr.com 
*    QLID        : SK250817
*    Details     : This Test class is created to test trigger : Reject_FundRequest in Raise Query Object.
*/

@isTest
public class Test_PSFR_SubmitforApproval{
    
    public static testmethod void Test_PSFR_SubmitforApproval(){
        
        Account a = TestRecordsFactory.createAccount();
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
        Account a = TestRecordsFactory.createAccount();
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
        
        Account a = TestRecordsFactory.createAccount();
        
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
        Account a = TestRecordsFactory.createAccount();
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
        Account a = TestRecordsFactory.createAccount();
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
        Account a = TestRecordsFactory.createAccount();
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
        
        Account a = TestRecordsFactory.createAccount();
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
        Account a = TestRecordsFactory.createAccount();
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