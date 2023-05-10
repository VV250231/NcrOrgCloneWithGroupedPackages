/*   Created by  : Saagar Kinja
     *    Email ID    : saagar.kinja@ncr.com 
     *    QLID        : SK250817
     *    Details     : This Test class is created to test trigger : PSFR_SENDTOPS_UpdateEmailID in Send to PS/Presales_Engineer__c Object.
*/

@isTest

    public class Test_PSFR_SENDTOPS_UpdateEmailID
    {   public static Presales_Funding_Request__c PSFR;
        public static Presales_Engineer__c STP;
        public static testmethod void PSFR_SENDTOPS_UpdateEmailID()
        {
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
            system.runAs(TestRecordsFactory.getUser()){
                insert a;
            }
       
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c=NSCCommonInfoUtil.getIdOf('sales_org_temp'));
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
        
         STP = new Presales_Engineer__c();
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         STP.Body__c = 'test@test.com';
         STP.Presales_Funding_Request__c = PFR.id;
         insert STP;
        
       
        If(STP.Opportunity_Owner_Email_ID__c == null)
         { 
             STP.Opportunity_Owner_Email_ID__c = 'null@null.com';
          }
          
             if(STP.Opportunity_Owner_Manager__c == null)
                 {
                  STP.Opportunity_Owner_Manager__c='null@null.com';
                  }
                   if(STP.Account_Manager__c == null)
                        {
                        STP.Account_Manager__c = 'null@null.com';
                        }
        NCR_EmailMessage__c ncrEMailObj =[select id from NCR_EmailMessage__c where Recipient1__c =:STP.Email_ID_5__c limit 1];
        System.assertNotEquals(ncrEMailObj.id,null);
        } 
        
        public static testmethod void PSFR_SENDTOPS_StatusTest()
        {
        Account a = new Account(      
        Account_Country_Code__c = 'EG',
        Active_Account__c = true,        
        Master_Customer_Number__c = '1631',
        Name = 'Unit Test ' + System.now(),
        RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
        RoR_Update_Date_Time__c = System.now(),
        Industry = 'RETAIL:CHANNEL',
        CAP_Watch__c = 'CAP',
        account_region__c='INDIA'
        );
         system.runAs(TestRecordsFactory.getUser()){
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
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        
        insert PFR;
        
         STP = new Presales_Engineer__c();
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         STP.Body__c = 'test@test.com';
         STP.Presales_Funding_Request__c = PFR.id;
         insert STP;
         /*
         PFR.Approval_Status__c = 'Sent to PS';
         update PFR ;
        
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         */
         
         STP.Trigger_Notification_Status__c = 'Sent to PS';
         Update STP;
         NCR_EmailMessage__c ncrEMailObj =[select id from NCR_EmailMessage__c where Recipient1__c =:STP.Email_ID_5__c limit 1];
         System.assertNotEquals(ncrEMailObj.id,null);
        } 
        
        public static testmethod void PSFR_Approved_StatusTest()
        {
        Account a = new Account(      
        Account_Country_Code__c = 'EG',
        Active_Account__c = true,        
        Master_Customer_Number__c = '1631',
        Name = 'Unit Test ' + System.now(),
        RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
        RoR_Update_Date_Time__c = System.now(),
        Industry = 'RETAIL:CHANNEL',
        CAP_Watch__c = 'CAP',
        account_region__c='INDIA'
        );
         system.runAs(TestRecordsFactory.getUser()){ 
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
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        
        insert PFR;
        
         STP = new Presales_Engineer__c();
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         STP.Body__c = 'test@test.com';
         STP.Presales_Funding_Request__c = PFR.id;
         insert STP;
        /*
         PFR.Approval_Status__c = 'Approved';
         update PFR ;
        */
         STP.Trigger_Notification_Status__c = 'Approved';
         Update STP;
         NCR_EmailMessage__c ncrEMailObj =[select id from NCR_EmailMessage__c where Recipient1__c =:STP.Email_ID_5__c limit 1];
         System.assertNotEquals(ncrEMailObj.id,null);
        }
        
        public static testmethod void PSFR_Reject_StatusTest()
        {
        Account a = new Account(      
        Account_Country_Code__c = 'EG',
        Active_Account__c = true,        
        Master_Customer_Number__c = '1631',
        Name = 'Unit Test ' + System.now(),
        RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
        RoR_Update_Date_Time__c = System.now(),
        Industry = 'RETAIL:CHANNEL',
        CAP_Watch__c = 'CAP',
        account_region__c='INDIA'
        );
         system.runAs(TestRecordsFactory.getUser()){
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
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        
        insert PFR;
        
         STP = new Presales_Engineer__c();
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         STP.Body__c = 'test@test.com';
         STP.Presales_Funding_Request__c = PFR.id;
         insert STP;
     
        /*
         PFR.Approval_Status__c = 'Rejected';
         update PFR ;
         */
         
         STP.Trigger_Notification_Status__c = 'Rejected';
         Update STP;
         NCR_EmailMessage__c ncrEMailObj =[select id from NCR_EmailMessage__c where Recipient1__c =:STP.Email_ID_5__c limit 1];
         System.assertNotEquals(ncrEMailObj.id,null);
        
        }
        public static testmethod void PSFR_Pendingforapproval_StatusTest()
        {
        Account a = new Account(      
        Account_Country_Code__c = 'EG',
        Active_Account__c = true,        
        Master_Customer_Number__c = '1631',
        Name = 'Unit Test ' + System.now(),
        RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
        RoR_Update_Date_Time__c = System.now(),
        Industry = 'RETAIL:CHANNEL',
        CAP_Watch__c = 'CAP',
        account_region__c='INDIA'
        );
         system.runAs(TestRecordsFactory.getUser()){             
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
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        
        insert PFR;
        
         STP = new Presales_Engineer__c();
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         STP.Body__c = 'test@test.com';
         STP.Presales_Funding_Request__c = PFR.id;
         insert STP;
        
        /*
         PFR.Approval_Status__c = 'Pending for Approval';
         update PFR ;
         
         STP.Email_ID__c = 'test@test.com';
         STP.Email_ID_1__c = 'test@test.com';
         STP.Email_ID_2__c = 'test@test.com';
         STP.Email_ID_3__c = 'test@test.com';
         STP.Email_ID_4__c = 'test@test.com';
         STP.Email_ID_5__c = 'test@test.com';
         */
         
         STP.Trigger_Notification_Status__c = 'Pending for Approval';
         Update STP;
         NCR_EmailMessage__c ncrEMailObj =[select id from NCR_EmailMessage__c where Recipient1__c =:STP.Email_ID_5__c limit 1];
         System.assertNotEquals(ncrEMailObj.id,null);
        }
        
        
   }