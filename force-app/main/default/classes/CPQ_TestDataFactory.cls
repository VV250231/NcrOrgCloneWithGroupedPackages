@isTest
public with sharing class CPQ_TestDataFactory {
    
    // get Soup User

    public static User getSoupUser() {
        return [Select Id, profileId from User Where Name = 'Soup User' LIMIT 1];
    }
    /*
    **********************************************************************
    * @description : Create customer account
    * @param : suffix - suffix to add with field values to differentiate with other account
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field.
    * @return : Account record.
    ***********************************************************************
    */
    public static Account createAccount(String suffix, Map<String,String> fieldApiNameToFieldValue){
        
        Account act = new Account();
        act.Name = 'CA'+suffix;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'HOSPITALITY:QSR';
        act.Master_Customer_Number__c = '9166111'+suffix;
        act.LOB__c = 'HOSPITALITY';
        act.Account_Region__c = 'NAMER SMB';
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(); 
        act.BillingStreet = 'Test Street';
        act.BillingCity = 'Test City';
        act.BillingState = 'Test State';
        act.BillingPostalCode = '123456';
        act.BillingCountry = 'US';
        act.SBQQ__RenewalModel__c = 'Contract Based';
        act.CDM_Account_Status__c = 'Active';
        // adding this block in last if we also need to override field value.
        if (fieldApiNameToFieldValue != null) {
            for (String fieldAPIname : fieldApiNameToFieldValue.keySet()) {
                act.put(fieldAPIname, fieldApiNameToFieldValue.get(fieldAPIname));
            }
        }     
        return act;
    }

    /*
    **********************************************************************
    * @description : Create customer site
    * @param : parentAct - parent account of the site.
    * @param : suffix - suffix to add with field values to differentiate with other site
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field.
    * @return : Account record.
    ***********************************************************************
    */
    public static Account createSite(Account parentAct, String suffix, Map<String,String> fieldApiNameToFieldValue){
        
        Account site = new Account();
        site.ParentId = parentAct.Id;
        site.Name = 'Site'+suffix;
        site.Site_Number__c='123'+suffix;
        site.cdm_Store_Branch_Number__c='123'+suffix;
        site.Bill_To__c = true;
        site.Primary_Bill_To__c = true;
        site.Ship_To__c = true;
        site.Primary_Ship_To__c = true;
        site.Deliver_To__c = true;
        site.Primary_Deliver_To__c = true;
        site.CDM_Account_Type__c = 'Site';
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();  
        site.BillingStreet = 'Test Street';
        site.BillingCity = 'Test City';
        site.BillingState = 'Test State';
        site.BillingPostalCode = '123456';
        site.BillingCountry = 'US';
        // adding this block in last if we also need to override field value.
        if (fieldApiNameToFieldValue != null) {
            for (String fieldAPIname : fieldApiNameToFieldValue.keySet()) {
                site.put(fieldAPIname, fieldApiNameToFieldValue.get(fieldAPIname));
            }
        }     
        return site;
    }

    /*
    **********************************************************************
    * @description : Create partner account
    * @param : suffix - suffix to add with field values to differentiate with other account
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field.
    * @return : Account record.
    ***********************************************************************
    */
    public static Account createPartnerAccount(String suffix, Map<String,String> fieldApiNameToFieldValue){
        
        Account act = new Account();
        act.Name = 'PA'+suffix;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'HOSPITALITY:QSR';
        act.Master_Customer_Number__c = '9155111'+suffix;
        act.LOB__c = 'HOSPITALITY';
        act.Account_Region__c = 'NAMER SMB';
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        act.BillingStreet = 'Test Street';
        act.BillingCity = 'Test City';
        act.BillingState = 'Test State';
        act.BillingPostalCode = '123456';
        act.BillingCountry = 'US';
        act.CDM_Account_Status__c = 'ERP Ready';
        act.CDM_Account_Type__c = 'PARTNER';
        // adding this block in last if we also need to override field value.
        if (fieldApiNameToFieldValue != null) {
            for (String fieldAPIname : fieldApiNameToFieldValue.keySet()) {
                act.put(fieldAPIname, fieldApiNameToFieldValue.get(fieldAPIname));
            }
        }     
        return act;
    }


    /*
    ************************************************************************************
    * @description : Create contact
    * @param : AccountID - Id of the account to which contact is associated
    * @param : suffix - suffix to add with field values to differentiate with other contact
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field.
    * @return : contact record.
    ***********************************************************************************
    */
    public static Contact createContact(Id accountID, String suffix, Map<String,String> fieldApiNameToFieldValue)
    {
        Contact con = new Contact();
        con.LastName = 'conLastName'+suffix;
        con.Email = 'test'+suffix+'@domain.com';
        con.AccountId = AccountID;
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        // adding this block in last if we also need to override field value.
        if (fieldApiNameToFieldValue != null) {
            for (String fieldAPIname : fieldApiNameToFieldValue.keySet()) {
                con.put(fieldAPIname, fieldApiNameToFieldValue.get(fieldAPIname));
            }
        } 
        return con;
    }

    // create Opportunity
    public static Opportunity createCpqOpportunity(Id accountId, String suffix, Map<String,String> fieldApiNameToFieldValue) {  
        Opportunity Opp = new Opportunity();
        Opp.Name = 'test'+suffix;
        Opp.AccountId = accountId;
        Opp.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Opp.CloseDate = System.today().addMonths(12);
        Opp.StageName = 'Analyzing';
        Opp.Pricebook2Id = Test.getStandardPricebookId(); 
        Opp.cpq__c=true;   
        return Opp;
     }

    // create cpq quote
    public static SBQQ__Quote__c createMultiSiteQuote(Account act, Account site, Contact primaryCon){
        SBQQ__Quote__c qte = new SBQQ__Quote__C();
        qte.SBQQ__Account__c  = act.Id;
        qte.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        qte.SBQQ__StartDate__c = system.today();
        qte.SBQQ__Primary__c = true;
        qte.SBQQ__Type__c = 'Quote';
        qte.qtc_Bill_To_Site__c = site.Id;
        qte.qtc_Ship_To_Account__c  = site.Id;
        qte.Deliver_To_Site__c  = site.Id;
        qte.SBQQ__SubscriptionTerm__c = 36;
        qte.qtc_Multi_Site__c = true;
        qte.qtc_Multi_Site_Relationship__c = 'Parent';
        qte.qtc_Multi_Site_Type__c = 'PP Only';
        qte.qtc_Number_of_Sites_with_Payments__c = 2;
        return qte;
    }

    // create cpq quote
    public static SBQQ__Quote__c createMultiSiteQuote(Account act, Account site, Contact primaryCon,
            String multiSiteType, String multiSiteRelationship) {
        SBQQ__Quote__c qte = new SBQQ__Quote__C();
        qte.SBQQ__Account__c  = act.Id;
        qte.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        qte.SBQQ__StartDate__c = system.today();
        qte.SBQQ__Primary__c = true;
        qte.SBQQ__Type__c = 'Quote';
        qte.qtc_Bill_To_Site__c = site.Id;
        qte.qtc_Ship_To_Account__c  = site.Id;
        qte.Deliver_To_Site__c  = site.Id;
        qte.SBQQ__SubscriptionTerm__c = 36;
        qte.qtc_Multi_Site__c = true;
        qte.qtc_Multi_Site_Relationship__c = multiSiteRelationship;
        qte.qtc_Multi_Site_Type__c = multiSiteType;
        return qte;
    }


    // Create Signle Site Quote
    public static SBQQ__Quote__c createSingleSiteQuote(Account act, Account site, Contact primaryCon){
        SBQQ__Quote__c qte = new SBQQ__Quote__C();
        qte.SBQQ__Account__c  = act.Id;
        qte.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        qte.SBQQ__StartDate__c = system.today();
        qte.SBQQ__Primary__c = true;
        qte.SBQQ__Type__c = 'Quote';
        qte.qtc_Bill_To_Site__c = site.Id;
        qte.qtc_Ship_To_Account__c  = site.Id;
        qte.Deliver_To_Site__c  = site.Id;
        qte.SBQQ__SubscriptionTerm__c = 36;
        qte.Payments_Application_Signee__c = primaryCon.Id;
        return qte;
    }

    // create products
    public static List<Product2> createProducts(integer noOfProducts) {
        List<Product2> products = new List<Product2> ();
        blng__BillingRule__c billingRule = new blng__BillingRule__c(
            Name = 'Test Billing Rule',
            blng__Active__c = true,
            blng__GenerateInvoices__c = 'No',
            blng__InitialBillingTrigger__c = 'Order Product Activation Date',
            blng__PartialPeriodTreatment__c = 'Separate'
        );
        insert billingRule;

        blng__RevenueRecognitionRule__c revenueRecognizationRule = new blng__RevenueRecognitionRule__c(
            Name = 'Test Schedule',
            blng__CreateRevenueSchedule__c = 'Yes',
            blng__Active__c = true
        );
        insert revenueRecognizationRule;

        blng__TaxRule__c taxrule = new blng__TaxRule__c(
            Name = 'Test Rule',
            blng__TaxableYesNo__c = 'Yes',
            blng__Active__c = TRUE);
        insert taxrule;

        for (Integer i = 1; i <= noOfProducts; i++) {
            products.add(new product2(
                            name='Prod'+String.valueOf(i),
                            Service_Offer_Category__c='cloud', 
                            family='Hardware',
                             ProductCode = 'code - '+ String.valueOf(i), 
                             product_type__c = 'PID', 
                             IsActive=true,
                             blng__BillingRule__c = billingRule.Id,
                             blng__RevenueRecognitionRule__c = revenueRecognizationRule.Id,
                             blng__TaxRule__c = taxrule.ID,
                             SBQQ__SubscriptionPricing__c = 'Fixed Price',
                             SBQQ__SubscriptionType__c = 'Renewable',
                             SBQQ__SubscriptionTerm__c = 1,
                             SBQQ__PricingMethod__c = 'List'));
        }
        return products;
    }

    //Add products to standard price book/catlog (create price book enteries)
    public static List<PricebookEntry> createPriceBookEntries(String pbID, List<Product2> products) {
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
            pbEntries.add(new PricebookEntry(Pricebook2Id = pbId, Product2Id = pro.Id, UnitPrice = 1, IsActive = true));
        }
        return pbEntries;
    }

    // create quote line items
    public static SBQQ__QuoteLine__c createQuoteLineItem(SBQQ__Quote__c qte, Product2 product,
            PricebookEntry pbEntry) 
    {
        return new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = qte.Id,
            SBQQ__PricebookEntryId__c = pbEntry.Id, 
            SBQQ__DefaultSubscriptionTerm__c = 36,
            SBQQ__Quantity__c = 4,
            SBQQ__Product__c = product.Id);
    }

    // Create NCR Payment Site
    public static NCR_Payments_Site__c createNcrPaymentSite(SBQQ__Quote__c quote, Account site){
        NCR_Payments_Site__c obj = new NCR_Payments_Site__c();
        obj.Quote__c = quote.Id;
        obj.Account_Sites__c = site.Id;
        return obj;
    }
    
}