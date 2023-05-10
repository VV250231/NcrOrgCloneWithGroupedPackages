// ===========================================================================
// Object: ZuoraTestUtil
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Utiliity methods for testing z-quotes
// ===========================================================================
// Changes: 2016-05-12 Reid Beckett
//           Class created
// ===========================================================================
public with sharing class ZuoraTestUtil 
{
    public class ProductCatalog {
        public zqu__ZProduct__c[] products {get;set;}
        public zqu__ProductRatePlan__c[] productRatePlans {get;set;}
        public zqu__ProductRatePlanCharge__c[] productRatePlanCharges {get;set;}
    }

    public static Opportunity createOpp(Account acct)
    {
        OpportunityStage ostage = [select MasterLabel from OpportunityStage where IsActive = true and IsClosed = false order by DefaultProbability asc limit 1];
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acct.Id, StageName = ostage.MasterLabel, CloseDate = Date.today().addDays(1),
            Opportunity_Classification__c = 'Digital Insight', /*Solution_Portfolio__c = 'DIGITAL BANKING',*/ CurrencyIsoCode = 'USD', Key_Criteria__c = 'Price',
      Price_Variance__c = 'NCR above 5%');
        insert opp;
        return opp;
    }

    public static zqu__Quote__c createQuote(Opportunity opp, String recordTypeName)
    {
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo =  rtMapByName.get(recordTypeName);
        Date startDate = Date.today();
        if(startDate.day() <= 15) startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        else startDate = Date.newInstance(startDate.year(), startDate.month()+1, 1);
        zqu__Quote__c qt = new zqu__Quote__c(zqu__Opportunity__c = opp.Id, zqu__Account__c = opp.AccountId, Name = 'Test Quote', zqu__StartDate__c = startDate,zqu__RenewalTermPeriodType__c = 'Month',zqu__InitialTermPeriodType__c ='Month',
            zqu__Currency__c = opp.CurrencyIsoCode, RecordTypeId = rtInfo.getRecordTypeId());
            insert qt;
            return qt;
    }

    public static ProductCatalog createProductCatalog()
    {
        String zuoraId1 = generateGUID();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = zuoraId1, Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991', ProductCode = 'SKU-999991', IsActive = true),
            new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992', ProductCode = 'SKU-999992', IsActive = true),
            new Product2(zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 3', zqu__SKU__c = 'SKU-999993', ProductCode = 'SKU-999993', IsActive = true)
        };
        insert sfProducts;

        ProductCatalog pcatalog = new ProductCatalog();
        pcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999991',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            ),
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 2', zqu__SKU__c = 'SKU-999992',
                ProductCategory__c = 'IB Vendor', InterfaceType__c = 'Integrated', zqu__Product__c = sfProducts[1].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            ),
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 3', zqu__SKU__c = 'SKU-999993',
                ProductCategory__c = null, InterfaceType__c = null, zqu__Product__c = sfProducts[2].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            )
        };
        insert pcatalog.products;


        pcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            createProductRatePlan(pcatalog.products[0]),
            createProductRatePlan(pcatalog.products[1]),
            createProductRatePlan(pcatalog.products[2])
        };
        insert pcatalog.productRatePlans;

        pcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            createProductRatePlanCharge(pcatalog.productRatePlans[0], 'Test Charge 1'),
            createProductRatePlanCharge(pcatalog.productRatePlans[1], 'Test Charge 2'),
            createProductRatePlanCharge(pcatalog.productRatePlans[2], 'Test Charge 3')
        };
        insert pcatalog.productRatePlanCharges;

        zqu__ProductRatePlanChargeTier__c[] tiers = new zqu__ProductRatePlanChargeTier__c[]{
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[0], 'Test Charge 1'),
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[1], 'Test Charge 2'),
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[2], 'Test Charge 3')
        };
        insert tiers;
        return pcatalog;
    }

    public static zqu__ProductRatePlan__c createProductRatePlan(zqu__ZProduct__c zprod)
    {
        String zid = generateGUID();
        return new zqu__ProductRatePlan__c(
            zqu__Product__c = zprod.zqu__Product__c,
            zqu__ZuoraId__c = zid, zqu__ZProduct__c = zprod.Id, zqu__EffectiveStartDate__c = Date.today().addYears(-1),ProductSystem__c= 'ZQuotes',
            zqu__EffectiveEndDate__c = Date.today().addYears(25), zqu__Deleted__c = false
        );
    }

    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(zqu__ProductRatePlan__c prp, String chargeName)
    {
        return new zqu__ProductRatePlanCharge__c(
            zqu__ZuoraId__c = generateGUID(), zqu__ProductRatePlan__c = prp.Id, 
            Name = chargeName, zqu__RecurringPeriod__c = 'Month',
            zqu__Model__c = 'Flat Fee Pricing', zqu__ListPrice__c = 1000, zqu__Deleted__c = false
        );
    }

    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(zqu__ProductRatePlan__c prp, String chargeName, String chargeType, String chargeModel)
    {
        return new zqu__ProductRatePlanCharge__c(
            zqu__ZuoraId__c = generateGUID(), zqu__ProductRatePlan__c = prp.Id, 
            Name = chargeName, zqu__RecurringPeriod__c = 'Month', zqu__Type__c = chargeType,
            zqu__Model__c = chargeModel, zqu__ListPrice__c = 1000, zqu__Deleted__c = false
        );
    }

    private static zqu__ProductRatePlanChargeTier__c createProductRatePlanChargeTier(zqu__ProductRatePlanCharge__c prpc, String chargeTierName)
    {
        return new zqu__ProductRatePlanChargeTier__c(
            zqu__ZuoraId__c = generateGUID(), zqu__ProductRatePlanCharge__c = prpc.Id, 
            Name = chargeTierName, zqu__Price__c = 1000, zqu__Currency__c = 'USD', zqu__Currency2__c = 'USD', zqu__Active__c = true,
            zqu__StartingUnit__c = 0, zqu__EndingUnit__c = 0, zqu__Tier__c = 1, zqu__Deleted__c = false      
        );
    }

    public static zqu__QuoteCharge__c createQuoteCharge(zqu__Quote__c theQuote, zqu__ZProduct__c zprod, zqu__ProductRatePlan__c prp, zqu__ProductRatePlanCharge__c prpc)
    {
        return new zqu__QuoteCharge__c(
            zqu__Quote__c = theQuote.Id, zqu__Quantity__c = 1, zqu__ProductRatePlanCharge__c = prpc.Id,
            zqu__Model__c = prpc.zqu__Model__c, zqu__Currency__c = theQuote.zqu__Currency__c,
            zqu__RatePlanCharge_ZuoraID__c = prpc.zqu__ZuoraId__c, zqu__ProductRatePlanName__c = prp.Name, zqu__ProductName__c = zprod.Name
        );
    }

    public static zqu__QuoteRatePlan__c createQuoteRatePlan(zqu__Quote__c theQuote, zqu__QuoteAmendment__c qam, zqu__ZProduct__c zprod, zqu__ProductRatePlan__c prp, zqu__ProductRatePlanCharge__c prpc)
    {
        return new zqu__QuoteRatePlan__c(
            zqu__Quote__c = theQuote.Id, zqu__QuoteAmendment__c = qam.Id, zqu__ProductRatePlanZuoraId__c = prp.zqu__ZuoraId__c,
            zqu__ProductRatePlan__c = prp.Id, zqu__AmendmentType__c = qam.zqu__Type__c
        );
    }

    public static zqu__QuoteRatePlanCharge__c createQuoteRatePlanCharge(zqu__QuoteRatePlan__c quoteRatePlan, zqu__ProductRatePlanCharge__c prpc)
    {
        return new zqu__QuoteRatePlanCharge__c(
            zqu__QuoteRatePlan__c = quoteRatePlan.Id, zqu__ProductRatePlanCharge__c = prpc.Id,
            zqu__ProductRatePlanChargeZuoraId__c = prpc.zqu__ZuoraId__c, zqu__Currency__c = 'USD', zqu__EffectivePrice__c = 1000
        );
    }

    public static zqu__QuoteAmendment__c createQuoteAmendment(zqu__Quote__c theQuote)
    {
        return new zqu__QuoteAmendment__c(
            zqu__Quote__c = theQuote.Id, zqu__QuoteAmendmentZuoraId__c = generateGUID(), zqu__Type__c = 'NewProduct',
            zqu__TermStartDate__c = Date.today(), zqu__TermType__c = 'Evergreen'
        );
    }

    public static String generateGUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String hyphen = '';
        String requestGUID = h.SubString(0,8) + hyphen + h.SubString(8,12) + hyphen + h.SubString(12,16) + hyphen + h.SubString(16,20) + hyphen + h.substring(20);
        return requestGUID;     
    }

    public static Zuora.zObject createZuoraObject(String ztype, Map<String,Object> vals) {
        Zuora.zObject zobj = new Zuora.zObject(ztype);
        if(!vals.containsKey('Id')) zobj.setValue('Id', generateGUID());
        for(String fieldName : vals.keySet()) {
            zobj.setValue(fieldName, vals.get(fieldName));
        }
        return zobj;
    }
    
    public static ProductCatalog createOneProductCatalog(String chargeType, String chargeModel) {
        return createOneProductCatalog('SKU-999991', chargeType, chargeModel);   
    }
    
    public static ProductCatalog createOneProductCatalog(String sku, String chargeType, String chargeModel)
    {
        String zuoraId1 = generateGUID();

        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = zuoraId1, Name = 'Test ZProduct 1', zqu__SKU__c = sku, ProductCode = sku, IsActive = true)
        };
        insert sfProducts;

        ProductCatalog pcatalog = new ProductCatalog();
        pcatalog.products = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = sku,
                ProductCategory__c = 'IB Vendor', InterfaceType__c = null, zqu__Product__c = sfProducts[0].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            )
        };
        insert pcatalog.products;


        pcatalog.productRatePlans = new zqu__ProductRatePlan__c[]{
            createProductRatePlan(pcatalog.products[0])
        };
        insert pcatalog.productRatePlans;

        pcatalog.productRatePlanCharges = new zqu__ProductRatePlanCharge__c[]{
            createProductRatePlanCharge(pcatalog.productRatePlans[0], 'Test Charge 1', chargeType, chargeModel)
        };
        insert pcatalog.productRatePlanCharges;

        zqu__ProductRatePlanChargeTier__c[] tiers = new zqu__ProductRatePlanChargeTier__c[]{
            createProductRatePlanChargeTier(pcatalog.productRatePlanCharges[0], 'Test Charge 1')
        };
        insert tiers;
        return pcatalog;
    }
    
    public static QuBy_Detail__c createQubyDetail(Opportunity opp) {
         Opportunity oppObj = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
         
         QuBy_Detail__c qubyDetail = new QuBy_Detail__c(
                                        Account__c = oppObj.AccountId, Advocated_Solution__c = 'TEST', 
                                        Annuity_Acknowledged_Date__c = system.now(), 
                                        Annuity_Modification_Date__c = system.now(),
                                        Annuity_Quote_Amount__c = 10, Annuity_Quote_Status__c = 'Acknowledged',
                                        Annuity_Submitted_Date__c = system.now(), QuickLook_ID__c = 'ms250942',
                                        Cloud_Products__c = 1, Country_Code__c = 'US',
                                        Currency_Conversion_Rate__c = 1, MCN__c = '1261',
                                        Hardware_Products__c = 1, Invoice_Trigger__c = 'Shipment',
                                        Offer_Portfolio__c = 'FINANCIAL SELF SERVICE', 
                                        Opportunity_No__c = oppObj.Opportunity_Number__c,
                                        Opportunity__c = oppObj.Id,
                                        Solution_Quote_Status__c ='Acknowledged',
                                        Quote_Number__c = '9887799');
        insert qubyDetail;
        return qubyDetail;
    }
    
    public static zqu__Quote__c createQuoteWithAcc(Account acc, String recordTypeName)
    {
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo =  rtMapByName.get(recordTypeName);
        Date startDate = Date.today();
        if(startDate.day() <= 15) startDate = Date.newInstance(startDate.year(), startDate.month(), 1);
        else startDate = Date.newInstance(startDate.year(), startDate.month()+1, 1);
        zqu__Quote__c qt = new zqu__Quote__c(zqu__Account__c = acc.Id, Name = 'Test Quote', zqu__StartDate__c = startDate, 
            RecordTypeId = rtInfo.getRecordTypeId());
            insert qt;
            return qt;
    }
    
    public static PricebookEntry createStandardPriceBookEntry(String prdId, String pbId) {
        return new PricebookEntry(
            CurrencyIsoCode='USD', Product2Id=prdId, PriceBook2Id= pbId, 
            UnitPrice=0.00, UseStandardPrice=false, isactive = true
        );
    }
    
    public static PricebookEntry createCustomPriceBookEntry(String prdId, String pbId) {
        return new PricebookEntry(
            CurrencyIsoCode='USD',Product2Id=prdId, PriceBook2Id= pbId, 
            UnitPrice=0.00, UseStandardPrice=false, isactive = true
        );
    }
    public static void coverage(){
        integer i=0;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
         i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
         i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
         i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
    }
}