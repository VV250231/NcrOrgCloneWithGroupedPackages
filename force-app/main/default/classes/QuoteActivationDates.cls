// ===========================================================================
// Object: QuoteActivationDates
// Company: NCR
// Author: Brian Rickard
// Purpose: To share the logic that sets Service Activation Date, Quote Start
//          date, and the sending of this information to Zuora between the
//          QuoteProductTriggerHandler and the AutomateSendToZBilling trigger
//          classes. 
// Tests: This class is largely covered by the QuoteProductTriggerHandlerTests
//        class.
// JIRAs: SC2015_AGL-4322 and SC2015_AGL-4659
// ===========================================================================
// Changes: 2018-03-06 Brick
//           Class created
// ===========================================================================
public with Sharing class QuoteActivationDates 
{

    public static void setActivationDatesOnQuote()
    {
        System.debug('Method : setActivationDatesOnQuote');//SC2015_AGL-5809
    }


    public static List<Quote_Product__c> findDeliveredProducts(List<Quote_Product__c> allQuoteProducts, Set<Id> quoteIds)
    {
        List<Quote_Product__c> activatedProducts = new List<Quote_Product__c>();
        Map<Id, zqu__quote__c> quotesWithAllDeactivationProducts = 
            new Map<Id, zqu__quote__c>([select Id, All_Deactivation_Products__c 
                                        from zqu__quote__c 
                                        where Id in :quoteIds and All_Deactivation_Products__c = true]);

        for(Quote_Product__c qp : allQuoteProducts){

            if(productHasBeenActivated(qp, quotesWithAllDeactivationProducts)) 
                activatedProducts.add(qp);
        }
        return activatedProducts;
    }

    private static boolean productHasBeenActivated(Quote_Product__c qp, Map<Id, zqu__quote__c> quotesWithAllDeactivationProducts)
    {
        boolean isAnActivatedProduct = (qp.Action__c == 'activate' || qp.Action__c == 'softlock' || qp.Action__c == 'reactivate');
        boolean isOnAQuoteWhereAllProductsAreDeactivated = quotesWithAllDeactivationProducts.containsKey(qp.Quote__c); 
        boolean completedDateIsSet = (qp.Completed_Date__c != null);

        if(isOnAQuoteWhereAllProductsAreDeactivated) system.debug('Adding quote product due to all-deactivations flag set: ' + qp);

        return (isAnActivatedProduct || isOnAQuoteWhereAllProductsAreDeactivated) && completedDateIsSet;
    }

    public static void setQuoteDatesFromDeliveredProducts(Set<Id> quoteIds, List<Quote_Product__c> activatedProducts)
    {
        // We'll only deal with products that have a Completed_Date__c value set
        // and the correct Action__c values (or cases where all quote products are deactivations/softlocks)
        if(activatedProducts.size() > 0)
        {
            List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
            List<Customer_Product_Setup__c> cpsToUpdate = new List<Customer_Product_Setup__c>();

            // And we're only interested in Quotes that don't have a Service Activation Date set
            Map<Id, zqu__Quote__c> quotesById = new Map<Id, zqu__Quote__c>(
                [select Id, zqu__StartDate__c, zqu__service_activation_date__c, prorate__c, 
                            zqu__ZuoraSubscriptionID__c ,Check_for_completed_date__c,Forecasted_Live_Date__c
                    from zqu__Quote__c 
                    where Id in :quoteIds and zqu__service_activation_date__c = null]
            );

            // We may need to update the Customer Product Setup's ForecastLiveDate field (if
            // we update the Service Activation Date).
            List<Customer_Product_Setup__c> cps = [select Id, Related_Quote__r.Id, ForecastLiveDate__c 
                                                    from Customer_Product_Setup__c
                                                    where Related_Quote__c in :quoteIds];

            /* If we have just one set of quote products coming in, we should only have one quote. 
               If we have a data load of Quote Products coming in, then we'll have multiples. Need to 
               avoid limits here, so we'll go up to the Quote level and work back down with loops 
               instead of using lookup queries. 
               
               Single Quote: 
               - Quote is missing S.A.D? Run through logic: 
               - Loop through Quote Products
               - 
               - Go to next product. Activated date is earlier than SAD? Use that instead. 

               Multiple Quotes
               - Iterate through quotes. SAD missing? Run through logic: 
               - Loop through activated products (or products on a quote where all actions are "deactivate" or "softlock")
               - If activated product has completed date and associated quote matches current quote, use completed date
               - Repeat
             */

            for(zqu__Quote__c quote : quotesById.values())
            {
                Date earliestDeliveryDate = findEarliestDeliveryDate(quote, activatedProducts);

                quote.zqu__service_activation_date__c = getServiceActivationDate(quote, earliestDeliveryDate);
                quote.zqu__StartDate__c = getStartDate(quote, earliestDeliveryDate); 
                quote.Forecasted_Live_Date__c = getForecastLiveDate(quote, earliestDeliveryDate);
                quote.Check_for_completed_date__c = true;

                if(quote.zqu__service_activation_date__c != null)
                {
                    system.debug('Updating subscription [' + quote.zqu__ZuoraSubscriptionID__c + '] start date [' +
                        quote.zqu__service_activation_date__c.format() + ']');

                    // SCA-4690 : Don't set the date on the Zuora side after all. 
                    /*
                    ZuoraClient.activateSubscription(updatedQuote.zqu__ZuoraSubscriptionID__c, 
                                                                         updatedQuote.zqu__service_activation_date__c);
                     */

                    Customer_Product_Setup__c setup = findCustomerProductSetupByQuoteId(quote.Id, cps);
                    if(setup != null)
                    {
                        setup.ForecastLiveDate__c = quote.zqu__service_activation_date__c;
                        cpsToUpdate.add(setup);
                        //update setup;
                    }

                    // SC2015_AGL-4689
                    /*
                    if(updatedQuote.zqu__SubscriptionType__c == 'Amend Subscription') 
                    { 
                        updatedQuote.zqu__StartDate__c = updatedQuote.zqu__service_activation_date__c; 
                    }
                    */
                }

                quotesToUpdate.add(quote);
            }
            
            if(!cpsToUpdate.isEmpty()) update cpsToUpdate;
            update quotesToUpdate;
        }
    }


    // If multiple products have their Completed Dates set at once we want to make sure
    // that we're setting the Service Activation and Quote Start dates as early as possible. 
    // This method also ensures that the delivery date we're finding is for a product that actually
    // is related to the given quote.
    private static Date findEarliestDeliveryDate(zqu__Quote__c quote, List<Quote_Product__c> activatedProducts)
    {
        Date earliestDeliveryDate; 
        for(Quote_Product__c quoteProduct : activatedProducts)
        {
            if(quoteProduct.Quote__c == quote.Id && (earliestDeliveryDate == null || 
                                                        earliestDeliveryDate > quoteProduct.Completed_Date__c))
            {
                earliestDeliveryDate = quoteProduct.Completed_Date__c;
            }
        }
        return earliestDeliveryDate;
    }

    public static Date getServiceActivationDate(zqu__Quote__c quote, Date earliestDeliveryDate)
    {
        Date sad = null;

        if (earliestDeliveryDate >= quote.zqu__StartDate__c) 
        {
            // If we're setting the SAD, the date depends on the Prorate flag ("Prorate to Day" in UI)
            if(quote.prorate__c) 
            {
                sad = earliestDeliveryDate;
            } 
            else 
            {
                sad = toFirstOfTheMonth(earliestDeliveryDate);
            }

        }
        else 
        {
            sad = quote.zqu__StartDate__c; 
        }
       
        return sad;
    }

    public static Date getStartDate(zqu__Quote__c quote, Date earliestDeliveryDate)
    {
        if (earliestDeliveryDate >= quote.zqu__StartDate__c) 
        {
            // If we're setting a start date, we always use the first of the month
            return toFirstOfTheMonth(earliestDeliveryDate);
        }
        else
            return quote.zqu__StartDate__c; 
    }
     
        // Added for story number 4717
    public static Date getForecastLiveDate(zqu__Quote__c quote, Date earliestDeliveryDate)
    {
         Date forcatsDat= null;

        if (earliestDeliveryDate >= quote.Forecasted_Live_Date__c) 
        {
            // If we're setting the SAD, the date depends on the Prorate flag ("Prorate to Day" in UI)
            if(quote.prorate__c) 
            {
                forcatsDat= earliestDeliveryDate;
            } 
            else 
            {
                forcatsDat= toFirstOfTheMonth(earliestDeliveryDate);
            }

        }
        else 
        {
            forcatsDat= quote.zqu__StartDate__c; 
        }
       
        return forcatsDat;
    }

    private static Customer_Product_Setup__c findCustomerProductSetupByQuoteId(Id quoteId, List<Customer_Product_Setup__c> setups)
    {
        for(Customer_Product_Setup__c setup : setups)
        {
            if(setup.Related_Quote__c == quoteId)
                return setup;
        }
        return null;
    }

    private static Date toFirstOfTheMonth(Date d)
    {
        //return Date.Parse(d.Year() + '-' + d.Month() + '-1');
        string year = String.valueOf(d.Year());
        string month = d.Month() < 10 ? '0' + d.Month() : String.valueOf(d.Month()); 
        string day = '01'; 
        return Date.Parse(month + '/' + day + '/' + year);

    }
    
}