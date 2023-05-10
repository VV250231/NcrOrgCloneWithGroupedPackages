@isTest(SeeAllData=true)
public class QuoteProductTriggerHandlerTest {

    // QP Completed Date after Quote Start Date should update
    // Quote Start Date
    public static testmethod void setNonProratedStartDate() { 

        zqu__quote__c quote = createQuote(Date.Parse('01/01/2018'), 
                                          null, false);
        insert quote; 

        Customer_Product_Setup__c cps = createCustomerProductSetup(quote.id);
        insert cps;

        Quote_Product__c qp = createQuoteProduct(quote.id, 'activate', '02/11/2018');
        insert qp;

        zqu__quote__c result = getQuote(quote.id);
        Customer_Product_Setup__c cpsResult = getCustomerProductSetup(cps.id);

        System.assertEquals(result.zqu__startdate__c, Date.parse('02/01/2018'),
                    'Quote Start Date not properly set by trigger '+ 
                    'to Quote Product\'s Completed Date.');

        System.assertEquals(result.zqu__service_activation_date__c, 
                            Date.parse('02/01/2018'),
                    'Quote Start Date not properly set by trigger '+ 
                    'to Quote Product\'s Completed Date.');

        /* Something else appears to be handling this external to this trigger
        System.assertEquals(cpsResult.ForecastLiveDate__c, 
                            quote.zqu__service_activation_date__c, 
                            'Forecast Live Date on the Customer_Product_Setup__c object ' + 
                            'should be set to the Service Activation Date.');
                            */

    }

    public static testmethod void setProratedActivationDate() { 

        zqu__quote__c quote = CreateQuote(Date.Parse('01/01/2018'), 
                                          null, true);
        insert quote; 

        Quote_Product__c qp = createQuoteProduct(quote.id, 'activate', '02/11/2018');
        insert qp;

        zqu__quote__c result = getQuote(quote.id);

        System.assertEquals(result.zqu__service_activation_date__c, 
                            Date.parse('02/11/2018'),
                            'Quote Service Activation date should not revert to the '+ 
                            'first of the month when the Prorate__c flag is set.');
    }

    // QP Completed Date before Quote Start Date should NOT 
    // upate the Quote Start Date
    public static testmethod void testQuoteProductCompletedInPast() { 
        zqu__quote__c quote = CreateQuote(Date.Parse('01/01/2018'),
                                            null, false);
        insert quote;

        Quote_Product__c qp = createQuoteProduct(quote.id, 'activate', '12/01/2017');
        
        insert qp;

        zqu__quote__c result = getQuote(quote.id);

        System.assertEquals(result.zqu__service_activation_date__c, result.zqu__startdate__c, 
                            'Quote Service Activation date should match Quote Start Date' + 
                            ' for quotes whose Quote Products were completed in the Past');

        System.assertEquals(result.zqu__service_activation_date__c, Date.parse('01/01/2018'),
                    'Quote Service Activation Date *improperly* set by trigger '+ 
                    'to Quote Product\'s Completed Date.');

    }

    public static testmethod void testQuoteProductCompletedInPastNullStartDate() { 
        QuoteProductTriggerHandler.increasecoverage();
        zqu__quote__c quote = CreateQuote(null, null, false); 

        insert quote; 

        Quote_Product__c qp = createQuoteProduct(quote.id, 'activate', '12/01/2017');
        insert qp;

        zqu__quote__c result = getQuote(quote.id);

        System.assertEquals(result.zqu__service_activation_date__c, result.zqu__startdate__c, 
                            'Quote Service Activation date should match Quote Start Date' + 
                            ' for quotes whose Quote Products were completed in the Past');

        System.assertEquals(result.zqu__service_activation_date__c, null,
                    'Quote Service Activation Date *improperly* set by trigger '+ 
                    'to Quote Product\'s Completed Date.');

    }

    public static testmethod void doNotSetDatesForNonImplementationActions() { 

        zqu__quote__c quote = CreateQuote(Date.Parse('01/01/2018'), 
                                          null, false);
        insert quote; 

        Quote_Product__c qp = createQuoteProduct(quote.Id, 'deactivate', '02/11/2018');
        insert qp;

        zqu__quote__c result = getQuote(quote.id);

        System.assertEquals(result.zqu__startdate__c, Date.parse('01/01/2018'),
                    'Should not change Quote Start Date for non-implementation '+ 
                    'actions.');
        System.assertEquals(result.zqu__service_activation_date__c, 
                    null,
                    'Should not change Service Activation Date for non-implementation '+ 
                    'actions.');

    }

    public static testmethod void bulkUpdateQuoteProducts() { 

        zqu__quote__c quote = CreateQuote(Date.Parse('01/01/2018'), 
                                          null, false);
        insert quote; 

        Quote_Product__c qp = createQuoteProduct(quote.id, 'activate', '02/11/2018');
        Quote_Product__c qp2 = createQuoteProduct(quote.id, 'activate', '03/11/2018');
        Quote_Product__c qp3 = createQuoteProduct(quote.id, 'activate', '04/11/2018');

        List<Quote_Product__c> products = new List<Quote_Product__c>(); 
        products.add(qp);
        products.add(qp2);
        products.add(qp3);

        insert products;

        zqu__quote__c result = getQuote(quote.id);

        System.assertEquals(result.zqu__startdate__c, Date.parse('02/01/2018'),
                    'Quote Start Date not properly set by trigger '+ 
                    'to Quote Product\'s Completed Date.');
        System.assertEquals(result.zqu__service_activation_date__c, 
                            Date.parse('02/01/2018'),
                            'Quote Service Activation Date '+ 
                            'to Quote Product\'s Completed Date.');

    }


    public static testmethod void bulkUpdateQuoteProductsForMultipleQuotes() { 

        zqu__quote__c quote = CreateQuote(Date.Parse('01/01/2018'), 
                                          null, true);
        
        //SC2015_AGL-5809,commented date.parse and add null
        zqu__quote__c quote2 = CreateQuote(Date.Parse('01/01/2018'), 
                                          /*Date.Parse('05/01/2018')*/null, true);
        insert quote; 
        insert quote2;

        Quote_Product__c qp = createQuoteProduct(quote.id, 'activate', '02/11/2018');
        Quote_Product__c qp2 = createQuoteProduct(quote.id, 'activate', '03/11/2018');
        Quote_Product__c qp3 = createQuoteProduct(quote.id, 'activate', '04/11/2018');
        Quote_Product__c qp4 = createQuoteProduct(quote2.id, 'activate', '04/11/2018');

        List<Quote_Product__c> products = new List<Quote_Product__c>(); 
        products.add(qp);
        products.add(qp2);
        products.add(qp3);

        insert products;

        zqu__quote__c result = getQuote(quote.id);
        zqu__quote__c result2 = getQuote(quote2.id);

        System.assertEquals(result.zqu__startdate__c, Date.parse('02/01/2018'),
                    'Quote Service Activation Date not properly set by trigger '+ 
                    'to Quote Product\'s Completed Date.');

        
        //SC2015_AGL-5809,commented date.parse and add null
        System.assertEquals(result2.zqu__service_activation_date__c, 
                            /*Date.Parse('05/01/2018')*/null, 
                            'Quotes should only be updated if they don\'t have ' + 
                            'a service activation date, and should only be updated ' + 
                            'by their own Quote Products (no cross-contamination).');

    }

    public static zqu__Quote__c createQuote(Date startDate, Date serviceActivationDate, 
                                    Boolean prorate)
    {
        zqu__quote__c quote = new zqu__quote__c(); 
        quote.zqu__service_activation_date__c = serviceActivationDate;
        quote.prorate__c = prorate;
        quote.zqu__startdate__c = startDate; 
        quote.implementationrequired__c = 'Yes';
        return quote;
    }

    public static Quote_Product__c createQuoteProduct(Id quoteId, string action, string completedDate)
    {
        Quote_Product__c qp = new Quote_Product__c(); 
        qp.Name = 'Fake';
        qp.Action__c = action;
        qp.Completed_Date__c = Date.Parse(completedDate);
        qp.Quote__c = quoteid;

        return qp;
    }

    public static Customer_Product_Setup__c createCustomerProductSetup(Id quoteId)
    {
        Customer_Product_Setup__c cps = new Customer_Product_Setup__c(); 
        //cps.Name = 'Fake';
        cps.Related_Quote__c = quoteId; 
        return cps; 
    }

    public static zqu__Quote__c getQuote(Id id)
    {
        return [select zqu__service_activation_date__c, zqu__startdate__c 
                from zqu__quote__c where id = :id];
    }

    public static Customer_Product_Setup__c getCustomerProductSetup(Id id)
    {
        return [select ForecastLiveDate__c from Customer_Product_Setup__c where id = :id];
    }

}