@isTest
private Class CDMServiceTest {

    static testMethod void syncCustomerTest() {
        CDMService.CustomerWrapper custWrap = new CDMService.CustomerWrapper();
        custWrap.CustomerCDMId = 'c1';
        custWrap.CustomerNumber = 'c1';
        custWrap.CustomerName = 'c1';

        CDMService.CustomerHierarchyRequest custHrchyReq = new CDMService.CustomerHierarchyRequest();
        custHrchyReq.Customer = custWrap;
        custHrchyReq.CDMActionType = 'CustomerCreate';

        CDMService.syncCustomerHierachy(custHrchyReq);

        custHrchyReq.CDMActionType = 'CustomerUpdate';
        CDMService.syncCustomerHierachy(custHrchyReq);
        system.assertEquals(custHrchyReq.CDMActionType, 'CustomerUpdate');
    }

    static testMethod void syncCustomeRelationship() {
        CDMService.CustomerWrapper custWrap = new CDMService.CustomerWrapper();
        custWrap.CustomerCDMId = 'c1';
        custWrap.CustomerNumber = 'c1';
        custWrap.CustomerName = 'c1';
        custWrap.DUNS_Number = 'c1';

        CDMService.CustomerHierarchyRequest custHrchyReq = new CDMService.CustomerHierarchyRequest();
        custHrchyReq.Customer = custWrap;
        custHrchyReq.CDMActionType = 'CustomerCreate';

        CDMService.syncCustomerHierachy(custHrchyReq);


        Date d = Date.today();
        CDMService.RelationshipWrapper customerRelation = new CDMService.RelationshipWrapper();
        customerRelation.Related_PartyNumber = 'c1';
        customerRelation.RelationShip_Name = 'Enterprise Parent';
        customerRelation.RelationShip_Code = 'Enterprise Child of';
        customerRelation.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        customerRelation.RelationShip_End_Date = '4712-12-31';
        customerRelation.RelationShip_Status = 'A';


        CDMService.CustomerWrapper custWrap1 = new CDMService.CustomerWrapper();
        custWrap1.CustomerCDMId = 'c2';
        custWrap1.CustomerNumber = 'c2';
        custWrap1.CustomerName = 'c2';
        custWrap1.DUNS_Number = 'c2';
        custWrap1.Domestic_Ultimate_DUNS_Number = 'c1';
        custWrap1.CustomerRelations = new List<CDMService.RelationshipWrapper>();
        custWrap1.CustomerRelations.add(customerRelation);

        CDMService.CustomerHierarchyRequest custHrchyReq1 = new CDMService.CustomerHierarchyRequest();
        custHrchyReq.Customer = custWrap1;
        custHrchyReq.CDMActionType = 'CustomerCreate';

        CDMService.syncCustomerHierachy(custHrchyReq1);

        String EnterpriseRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        system.assert(EnterpriseRecTypeId != null);
        Account entCstmr = CDMUtil.createEPCstmr('test1', 'test1', EnterpriseRecTypeId);
        CDMUtil.populateEPFields(entCstmr, customerRelation, true);
        CDMUtil.populateEPFields(entCstmr, customerRelation, false);

        Test.startTest();
        CDMUtil.scheduleHRYUpdate();
        Test.stopTest();
    }


    static testMethod void syncAccountTest() {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        system.assertNotEquals(Usr.Id, null);

        //DisableCDMNSCSupportNotifications__c cdmNotificatin = new DisableCDMNSCSupportNotifications__c(Name='test', TurnMailOn__c = 'ON');
        //insert cdmNotificatin;

        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name = 'NSC Job Failure', ToEmailAddresses__c = 'test@ncr.com');
        insert nscNotification;

        //CDMService.RelationshipWrapper localOffRel = new CDMService.RelationshipWrapper();
        //localOffRel.Related_PartyName = 
        List<CDMService.SiteUseWrapper> siteUseList = new List<CDMService.SiteUseWrapper>();
        CDMService.SiteUseWrapper siteuse1 = new CDMService.SiteUseWrapper();
        siteuse1.SiteUseType = 'PRIMARY_BILL_TO';
        siteuse1.Status = 'A';

        CDMService.SiteUseWrapper siteuse2 = new CDMService.SiteUseWrapper();
        siteuse2.SiteUseType = 'PRIMARY_SHIP_TO';
        siteuse2.Status = 'A';

        CDMService.SiteUseWrapper siteuse3 = new CDMService.SiteUseWrapper();
        siteuse3.SiteUseType = 'PRIMARY_DELIVER_TO';
        siteuse3.Status = 'A';
        CDMService.SiteUseWrapper siteuse4 = new CDMService.SiteUseWrapper();
        siteuse4.SiteUseType = 'BILL_TO';
        siteuse4.Status = 'A';

        CDMService.SiteUseWrapper siteuse5 = new CDMService.SiteUseWrapper();
        siteuse5.SiteUseType = 'SHIP_TO';
        siteuse5.Status = 'A';

        CDMService.SiteUseWrapper siteuse6 = new CDMService.SiteUseWrapper();
        siteuse6.SiteUseType = 'DELIVER_TO';
        siteuse6.Status = 'A';
        siteUseList.add(siteuse1);
        siteUseList.add(siteuse2);
        siteUseList.add(siteuse3);
        siteUseList.add(siteuse4);
        siteUseList.add(siteuse5);
        siteUseList.add(siteuse6);

        CDMService.SiteUseListWrapper siteUseWrap = new CDMService.SiteUseListWrapper();
        siteUseWrap.SiteUse = siteUseList;

        CDMService.SiteWrapper siteWrap = new CDMService.SiteWrapper();
        siteWrap.SiteCDMId = 'Test site1';
        siteWrap.SiteNumber = 'Testsite1';
        siteWrap.NCR_Status = 'ACTIVE';
        siteWrap.SiteName = 'Test Account';
        //siteWrap.CMCID = 'id=1234564';
        siteWrap.SiteUseList = siteUseWrap;

        CDMService.SiteListWrapper siteLstWrp = new CDMService.SiteListWrapper();
        siteLstWrp.Site = new List<CDMService.SiteWrapper>();
        siteLstWrp.Site.add(siteWrap);


        CDMService.AccountWrapper AcctWrap = new CDMService.AccountWrapper();
        AcctWrap.AccountCDMId = 'Test1';
        AcctWrap.AccountNumber = 'Test1';
        AcctWrap.Status = 'ACTIVE';
        AcctWrap.OperatingUnit = 'US';
        AcctWrap.AccountType = 'END CUSTOMER';
        AcctWrap.AccountName = 'Test Account';
        AcctWrap.Sites = siteLstWrp;

        CDMService.CustomerWrapper custWrap = new CDMService.CustomerWrapper();
        custWrap.CustomerCDMId = 'c1';
        custWrap.CustomerNumber = 'c1';
        custWrap.CustomerName = 'c1';
        custWrap.Account = AcctWrap;


        CDMService.CustomerHierarchyRequest custHrchyReq = new CDMService.CustomerHierarchyRequest();
        custHrchyReq.Customer = custWrap;
        custHrchyReq.CDMActionType = 'AccountCreate';

        System.runAs(Usr) {
            CDMService.syncCustomerHierachy(custHrchyReq);
            CDMService.syncCustomerHierachy(custHrchyReq);
        }

        // Account relationship
        Date d = Date.today().addDays(-2);
        CDMService.RelationshipWrapper localOffRel = new CDMService.RelationshipWrapper();
        localOffRel.Related_PartyNumber = 'Test1';
        localOffRel.Related_PartyName = 'Test Account';
        localOffRel.RelationShip_Name = 'Local Office - End Customer';
        localOffRel.RelationShip_Code = 'End Customer Of';
        localOffRel.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        localOffRel.RelationShip_End_Date = '4712-12-31';
        localOffRel.RelationShip_Status = 'A';

        CDMService.RelationshipWrapper partnerRel = new CDMService.RelationshipWrapper();
        partnerRel.Related_PartyNumber = 'Test1';
        partnerRel.Related_PartyName = 'Test Account';
        partnerRel.RelationShip_Name = 'Partner - End Customer';
        partnerRel.RelationShip_Code = 'End Customer Of';
        partnerRel.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        partnerRel.RelationShip_End_Date = '4712-12-31';
        partnerRel.RelationShip_Status = 'A';

        List<CDMService.RelationshipWrapper> localOfficeRelationList = new List<CDMService.RelationshipWrapper>();
        localOfficeRelationList.add(localOffRel);

        List<CDMService.RelationshipWrapper> partnerRelationList = new List<CDMService.RelationshipWrapper>();
        partnerRelationList.add(partnerRel);

        CDMService.AccountWrapper AcctWrap1 = new CDMService.AccountWrapper();
        AcctWrap1.AccountCDMId = 'Test2';
        AcctWrap1.AccountNumber = 'Test2';
        AcctWrap1.Status = 'ACTIVE';
        AcctWrap1.OperatingUnit = 'US';
        AcctWrap1.AccountType = 'Local Office';
        AcctWrap1.AccountName = 'Local Office Account';
        AcctWrap1.LocalOffice_Of_Relation = localOfficeRelationList;
        AcctWrap1.Partner_Of_Relation = partnerRelationList;

        custWrap.Account = AcctWrap1;
        System.runAs(Usr) {
            CDMService.syncCustomerHierachy(custHrchyReq);

            CDMService.syncCustomerHierachy(custHrchyReq);
        }
    }

    static testMethod void customerMergeTest() {
        User Usr = [SELECT Id, ProfileId FROM User WHERE Name = 'Soup User'];
        System.assertNotEquals(Usr.Id, null);

        Sales_Org__c s = new Sales_Org__c(Name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c = '126232');
        insert s;

        Competitors__c c = new Competitors__c(Name = 'testing competitor');
        insert c;

        Account acc1, acc2;

        System.runAs(Usr) {
            acc1 = new Account(Name = 'Account1', Master_Customer_Number__c = 'Test1', Interface_Source__c = 'CDM', Active_Account__c = true);
            acc2 = new Account(Name = 'Account1', Master_Customer_Number__c = 'Test2', Interface_Source__c = 'CDM', Active_Account__c = true);
            insert new List<Account>{
                    acc1, acc2
            };

            Opportunity opp = new Opportunity();
            Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
            opp.Name = 'abc';
            opp.Industry__c = 'Financial';
            opp.AccountId = acc2.Id;
            opp.Name = 'OppQuote Linkage Opportunity';
            opp.Type = 'Indirect Channel';
            /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change -Ahad*/
            opp.CurrencyIsoCode = 'USD';
            opp.Sales_Org__c = s.Id;
            opp.Invoice_Trigger__c = 'Shipment';
            //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
            opp.Primary_Competitor__c = c.Id;
            opp.Expected_Delivery_Date__c = System.today().addDays(30);
            opp.CloseDate = System.today();
            opp.StageName = 'Analyzing';
            opp.RecordTypeId = r1;
            insert opp;
        }

        CDMService.MergePartyWrapper masterPartyWrap = new CDMService.MergePartyWrapper();
        masterPartyWrap.PartyId = 'party1';
        masterPartyWrap.PartyType = 'Account_Party';
        masterPartyWrap.PartyNumber = acc1.Master_Customer_Number__c;
        masterPartyWrap.PartyName = acc1.Name;
        masterPartyWrap.MasterFlag = 'Y';

        CDMService.MergePartyWrapper victimPartyWrap = new CDMService.MergePartyWrapper();
        victimPartyWrap.PartyId = 'party2';
        victimPartyWrap.PartyType = 'Account_Party';
        victimPartyWrap.PartyNumber = acc2.Master_Customer_Number__c;
        victimPartyWrap.PartyName = acc2.Name;
        victimPartyWrap.MasterFlag = 'N';
        List<CDMService.MergePartyWrapper> victimParties = new List<CDMService.MergePartyWrapper>{
                victimPartyWrap
        };

        CDMService.MergePartyDetailWrapper mergeDtlWrap = new CDMService.MergePartyDetailWrapper();
        mergeDtlWrap.masterParty = masterPartyWrap;
        mergeDtlWrap.victimParties = victimParties;

        CDMService.CustomerMergeRequest cstmrMergeReq = new CDMService.CustomerMergeRequest();
        cstmrMergeReq.MergePartyDetail = mergeDtlWrap;

        CDMService.syncCustomerMerge(cstmrMergeReq);
    }


    static testMethod void syncAccountTest1() {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        system.assertNotEquals(Usr.Id, null);

        DisableCDMNSCSupportNotifications__c cdmNotificatin = new DisableCDMNSCSupportNotifications__c(Name = 'test', TurnMailOn__c = 'ON');
        insert cdmNotificatin;

        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name = 'NSC Job Failure', ToEmailAddresses__c = 'test@ncr.com');
        insert nscNotification;


        CDMService.AccountWrapper AcctWrap = new CDMService.AccountWrapper();
        AcctWrap.AccountCDMId = 'Test1';
        AcctWrap.AccountNumber = 'Test1';
        AcctWrap.Status = 'ACTIVE1';
        AcctWrap.OperatingUnit = 'US';
        AcctWrap.AccountType = 'END CUSTOMER';
        AcctWrap.AccountName = 'Test Account';

        CDMService.CustomerWrapper custWrap = new CDMService.CustomerWrapper();
        custWrap.CustomerCDMId = 'c1';
        custWrap.CustomerNumber = 'c1';
        custWrap.CustomerName = 'c1';
        custWrap.Account = AcctWrap;


        CDMService.CustomerHierarchyRequest custHrchyReq = new CDMService.CustomerHierarchyRequest();
        custHrchyReq.Customer = custWrap;
        custHrchyReq.CDMActionType = 'AccountCreate';

        System.runAs(Usr) {
            CDMService.syncCustomerHierachy(custHrchyReq);

            AcctWrap.Status = 'ACTIVE';
            CDMService.syncCustomerHierachy(custHrchyReq);

            custHrchyReq.CDMActionType = 'AccountUpdate';
            CDMService.syncCustomerHierachy(custHrchyReq);
        }
    }

    // Added by Basel Altamimi as part of SFHS-637
    static testMethod void testSiteAccountCreation() {
        User Usr = [SELECT Id, ProfileId FROM User WHERE Name = 'Soup User'];
        System.assertNotEquals(Usr.Id, null);

        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name = 'NSC Job Failure', ToEmailAddresses__c = 'test@ncr.com');
        insert nscNotification;

        List<CDMService.SiteUseWrapper> siteUseList = new List<CDMService.SiteUseWrapper>();
        CDMService.SiteUseWrapper siteuse1 = new CDMService.SiteUseWrapper();
        siteuse1.SiteUseType = 'PRIMARY_BILL_TO';
        siteuse1.Status = 'A';

        CDMService.SiteUseWrapper siteuse2 = new CDMService.SiteUseWrapper();
        siteuse2.SiteUseType = 'PRIMARY_SHIP_TO';
        siteuse2.Status = 'A';

        CDMService.SiteUseWrapper siteuse3 = new CDMService.SiteUseWrapper();
        siteuse3.SiteUseType = 'PRIMARY_DELIVER_TO';
        siteuse3.Status = 'A';
        CDMService.SiteUseWrapper siteuse4 = new CDMService.SiteUseWrapper();
        siteuse4.SiteUseType = 'BILL_TO';
        siteuse4.Status = 'A';

        CDMService.SiteUseWrapper siteuse5 = new CDMService.SiteUseWrapper();
        siteuse5.SiteUseType = 'SHIP_TO';
        siteuse5.Status = 'A';

        CDMService.SiteUseWrapper siteuse6 = new CDMService.SiteUseWrapper();
        siteuse6.SiteUseType = 'DELIVER_TO';
        siteuse6.Status = 'A';
        siteUseList.add(siteuse1);
        siteUseList.add(siteuse2);
        siteUseList.add(siteuse3);
        siteUseList.add(siteuse4);
        siteUseList.add(siteuse5);
        siteUseList.add(siteuse6);

        CDMService.SiteUseListWrapper siteUseWrap = new CDMService.SiteUseListWrapper();
        siteUseWrap.SiteUse = siteUseList;

        CDMService.SiteWrapper siteWrap = new CDMService.SiteWrapper();
        siteWrap.SiteCDMId = 'Test site1';
        siteWrap.SiteNumber = 'Testsite1';
        siteWrap.NCR_Status = 'ACTIVE';
        siteWrap.SiteName = 'Test Account';
        siteWrap.SiteUseList = siteUseWrap;
        //siteWrap.CustomerSerialization = true;
        //siteWrap.SiteLockDown = true;
        //siteWrap.CMCId = 'id12398';

        CDMService.SiteListWrapper siteLstWrp = new CDMService.SiteListWrapper();
        siteLstWrp.Site = new List<CDMService.SiteWrapper>();
        siteLstWrp.Site.add(siteWrap);

        // Account relationship
        Date d = Date.today().addDays(-2);
        CDMService.RelationshipWrapper localOffRel = new CDMService.RelationshipWrapper();
        localOffRel.Related_PartyNumber = 'Test1';
        localOffRel.Related_PartyName = 'Test Account';
        localOffRel.RelationShip_Name = 'Local Office - End Customer';
        localOffRel.RelationShip_Code = 'End Customer Of';
        localOffRel.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        localOffRel.RelationShip_End_Date = '4712-12-31';
        localOffRel.RelationShip_Status = 'A';

        CDMService.RelationshipWrapper partnerRel = new CDMService.RelationshipWrapper();
        partnerRel.Related_PartyNumber = 'Test1';
        partnerRel.Related_PartyName = 'Test Account';
        partnerRel.RelationShip_Name = 'Partner - End Customer';
        partnerRel.RelationShip_Code = 'End Customer Of';
        partnerRel.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        partnerRel.RelationShip_End_Date = '4712-12-31';
        partnerRel.RelationShip_Status = 'A';

        List<CDMService.RelationshipWrapper> localOfficeRelationList = new List<CDMService.RelationshipWrapper>();
        localOfficeRelationList.add(localOffRel);

        List<CDMService.RelationshipWrapper> partnerRelationList = new List<CDMService.RelationshipWrapper>();
        partnerRelationList.add(partnerRel);

        CDMService.AccountWrapper AcctWrap = new CDMService.AccountWrapper();
        AcctWrap.AccountCDMId = 'Test1';
        AcctWrap.AccountNumber = 'Test1';
        AcctWrap.Status = 'ACTIVE';
        AcctWrap.OperatingUnit = 'US';
        AcctWrap.AccountType = 'END CUSTOMER';
        AcctWrap.AccountName = 'Test Account';
        AcctWrap.Sites = siteLstWrp;
        AcctWrap.PartyType = 'Sample type';
        AcctWrap.Country = 'sample country';
        AcctWrap.NCRPartyUsage = 'sample value';
        AcctWrap.PulseFlag = true;
        AcctWrap.Regionlov = 'sample value';

        AcctWrap.LocalOffice_Of_Relation = localOfficeRelationList;
        AcctWrap.Partner_Of_Relation = partnerRelationList;


        CDMService.CustomerWrapper custWrap = new CDMService.CustomerWrapper();
        custWrap.CustomerCDMId = 'c1';
        custWrap.CustomerNumber = 'c1';
        custWrap.CustomerName = 'c1';
        custWrap.Account = AcctWrap;


        CDMService.CustomerHierarchyRequest custHrchyReq = new CDMService.CustomerHierarchyRequest();
        custHrchyReq.Customer = custWrap;
        custHrchyReq.CDMActionType = 'AccountCreate';

        String siteRecordTypeId = Account.getSObjectType().getDescribe().recordTypeInfosByName.get('Site').getRecordTypeId();

        // Skip trigger execution for the running user
        insert new Automation_Setting__c(Skip_Trigger__c = true, Skip_Validation_Rule__c = true);

        Account existingSite = new Account(RecordTypeId = siteRecordTypeId, Name = 'Test Account', Customer_CDM_ID__c = 'Test Site 1', Site_Number__c = 'Testsite1');
        insert existingSite;

        Id customerId = CDMService.createCustomer(custWrap);
        Id accountId = CDMService.createAccount(AcctWrap, customerId, custWrap);

        List<Account> sites = CDMUtil.generateSites(accountId, new Map<String, Account>{
                existingSite.Id => existingSite
        }, siteLstWrp);

        System.assertEquals(1, sites.size());
        //System.assertEquals(true, sites[0].Customer_Serialization__c);
        //System.assertEquals(true, sites[0].Site_Lockdown__c);
    }

    static testMethod void testRelationshipCheck() {
        // Skip trigger execution for the running user
        insert new Automation_Setting__c(Skip_Trigger__c = true, Skip_Validation_Rule__c = true);

        Account account = new Account(Name = 'Test Account', Master_Customer_Number__c = '123456');
        insert account;

        // Account relationship
        Date d = Date.today().addDays(-2);
        CDMService.RelationshipWrapper localOffRel = new CDMService.RelationshipWrapper();
        localOffRel.Related_PartyNumber = '123456';
        localOffRel.Related_PartyName = 'Test Account';
        localOffRel.RelationShip_Name = 'Local Office - End Customer';
        localOffRel.RelationShip_Code = 'End Customer Of';
        localOffRel.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        localOffRel.RelationShip_End_Date = '4712-12-31';
        localOffRel.RelationShip_Status = 'A';
        localOffRel.ROR_Update_Datetime = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day() + 1).format('yyyy-MM-dd') + 'T11:10:03.002Z';

        CDMService.RelationshipWrapper partnerRel = new CDMService.RelationshipWrapper();
        partnerRel.Related_PartyNumber = '123456';
        partnerRel.Related_PartyName = 'Test Account';
        partnerRel.RelationShip_Name = 'Partner - End Customer';
        partnerRel.RelationShip_Code = 'End Customer Of';
        partnerRel.RelationShip_StartDate = Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
        partnerRel.RelationShip_End_Date = '4712-12-31';
        partnerRel.RelationShip_Status = 'A';
        partnerRel.ROR_Update_Datetime = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day() + 1).format('yyyy-MM-dd') + 'T11:10:03.002Z';


        List<CDMService.RelationshipWrapper> localOfficeRelationList = new List<CDMService.RelationshipWrapper>();
        localOfficeRelationList.add(localOffRel);

        List<CDMService.RelationshipWrapper> partnerRelationList = new List<CDMService.RelationshipWrapper>();
        partnerRelationList.add(partnerRel);

        cdm_Account_Relationship__c accountRelationLocal = new cdm_Account_Relationship__c(
                Name = 'Local Office - End Customer',
                Start_Date__c = d,
                End_Date__c = System.today().addDays(7),
                ROR_Update_Date_Time__c = System.now(),
                Active__c = true,
                Account__c = account.Id,
                Related_Account__c = account.Id,
                Relationship_Type__c = 'Local Office - End Customer',
                Relationship_Code__c = 'End Customer Of',
                Account_Number__c = '123456'
        );
        cdm_Account_Relationship__c accountRelationPartner = new cdm_Account_Relationship__c(
                Name = 'Local Office - End Customer',
                Start_Date__c = d,
                End_Date__c = System.today().addDays(7),
                ROR_Update_Date_Time__c = System.now(),
                Active__c = true,
                Account__c = account.Id,
                Related_Account__c = account.Id,
                Relationship_Type__c = 'Partner - End Customer',
                Relationship_Code__c = 'End Customer Of',
                Account_Number__c = '123456'
        );
        List<cdm_Account_Relationship__c> accountRelations = new List<cdm_Account_Relationship__c>{
                accountRelationLocal, accountRelationPartner
        };
        insert accountRelations;

        List<cdm_Account_Relationship__c> accountRelationships = CDMUtil.checkExistingRelationship(account.Master_Customer_Number__c, new Map<String, CDMService.RelationshipWrapper>{
                localOffRel.Related_PartyNumber => localOffRel
        }, new Map<String, CDMService.RelationshipWrapper>{
                partnerRel.Related_PartyNumber => partnerRel
        });

        System.assertEquals(2, accountRelationships.size());

    }

    @IsTest
    private static void CDMUtil_testGetPrntCstmrAccts() {
        // make sure the query builder is well formatted and doesn't throw DML errors
        try {
            List<Account> account = CDMUtil.getPrntCstmrAccts('test', 'test');
        } catch (Exception err) {
            System.assertEquals(false, true, 'Unexpected errors');
        }
    }

    @IsTest
    private static void CDMUtil_testSiteDiff() {
        Account acc1 = new Account(Name = 'Account1', Master_Customer_Number__c = 'Test1', Interface_Source__c = 'CDM', Active_Account__c = true);
        Account acc2 = new Account(Name = 'Account1', Master_Customer_Number__c = 'Test1', Interface_Source__c = 'CDM', Active_Account__c = true);

        Boolean isDiff = CDMUtil.isSiteDiff(acc1, acc2);
        System.assertEquals(false, isDiff);
    }

    @IsTest
    private static void CDMUtil_trimStr() {
        String str = 'some random string';

        String trimStr = CDMUtil.trimStr(str, 2);
        System.assertEquals(2, trimStr.length());
    }
}