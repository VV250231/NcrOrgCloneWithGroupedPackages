public class BillingCPQFormulaTriggerHandler {
    static Integer DISCOUNT_TIER_LOWER_BOUND = 2;

    private static Map<String, Integer> billingPeriodMultiplier {
        get {
            if(billingPeriodMultiplier == null) {
                billingPeriodMultiplier = new Map<String, Integer>();
                billingPeriodMultiplier.put('Monthly', 1);
                billingPeriodMultiplier.put('Quarterly', 3);
                billingPeriodMultiplier.put('Semiannual', 6);
                billingPeriodMultiplier.put('Annual', 12);
            }
            return billingPeriodMultiplier;
        }
        
        set;
        
    }
    public static void handleBeforeTrigger( List<SBQQ__QuoteLine__c> listQuoteLines ){
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> pricebookEntryIdSet = new Set<Id>();
        Set<Id> discountScheduleIdSet = new Set<Id>();
        Set<String> setCurrencyISOCode = new Set<String>();


        for( SBQQ__QuoteLine__c quoteLine : listQuoteLines ) {
            quoteIdSet.add( quoteLine.SBQQ__Quote__c );
            pricebookEntryIdSet.add( quoteLine.SBQQ__PricebookEntryId__c );
            discountScheduleIdSet.add( quoteLine.SBQQ__DiscountSchedule__c );
            setCurrencyISOCode.add( quoteLine.CurrencyIsoCode );
        }
        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([   
            SELECT SBQQ__StartDate__c, SBQQ__EndDate__c, QuoteBillThroughDate__c, SBQQ__ProrationDayOfMonth__c, BillingMultiplier__c, SBQQ__Type__c
            FROM SBQQ__Quote__c
            WHERE Id IN :quoteIdSet
        ]);

        Map<Id, Map<String, SBQQ__DiscountTier__c>> mapDiscountTierByCurrencyByDiscountScheduleId = generateDiscountTierReferenceMap( discountScheduleIdSet, setCurrencyISOCode );

        for(SBQQ__QuoteLine__c quoteLine : listQuoteLines) {
            SBQQ__Quote__c thisQuote = quoteMap.get( quoteLine.SBQQ__Quote__c );
            SBQQ__DiscountTier__c thisDiscountTier = mapDiscountTierByCurrencyByDiscountScheduleId?.get( quoteLine.SBQQ__DiscountSchedule__c )?.get( quoteLine.CurrencyISOCode );

            calculateQuoteLine(thisQuote, quoteLine, thisDiscountTier);
            setNetUnitAmend(thisQuote, quoteLine, thisDiscountTier);
        }
    }
    
    public static void calculateQuoteLine(SBQQ__Quote__c quote, SBQQ__QuoteLine__c quoteLine, SBQQ__DiscountTier__c discountTier) {
        
        // If BillThroughDate__c is not set on the quote line
        // Do not proceed further
        if (   quote.QuoteBillThroughDate__c == null 
            || quoteLine.SBQQ__NetTotal__c == 0 
            || quoteLine.SBQQ__NetTotal__c == null
            || quoteLine.SBQQ__DefaultSubscriptionTerm__c == null) {
            return;
        }
        System.debug( 'Id '+ quoteLine.Id );
        System.debug( 'SBQQ__NetTotal__c '+ quoteLine.SBQQ__NetTotal__c );
        System.debug( 'SBQQ__NetPrice__c '+ quoteLine.SBQQ__NetPrice__c );
        // Proration Day of the Month
        Integer pdom = Integer.valueOf(quote.SBQQ__ProrationDayOfMonth__c);
        
        // Billing Frequency Multiplier
        Integer bpMultiplier = billingPeriodMultiplier.get(quoteLine.SBQQ__BillingFrequency__c); // 6
        
        Decimal listPrice = quoteLine.SBQQ__ListPrice__c;
        Decimal priorQuantity = quoteLine.SBQQ__PriorQuantity__c == null? 0: quoteLine.SBQQ__PriorQuantity__c;
        Decimal quantity = quoteLine.SBQQ__Quantity__c  == null ? 0: quoteLine.SBQQ__Quantity__c;
        System.debug('priorQuantity: '+ priorQuantity);
        System.debug('quantity: '+ quantity);
        
        // Cross Order Usecase
        if(quote.SBQQ__Type__c == 'Quote' && priorQuantity > 0) {
            quantity += priorQuantity;
        }

        Decimal netQuantity = quantity - priorQuantity;
        
        Decimal effectivePrice = listPrice * netQuantity;

        System.debug('listPrice: '+ listPrice);
        System.debug('quantity: '+ quantity);
        System.debug('effectivePrice before discount: '+ effectivePrice);

        // First: Discount Schedule
        if(discountTier != null) {
            Decimal max = quantity;
            Decimal min = quantity;
            if(quantity > priorQuantity) {
                min = priorQuantity;
            } else {
                max = priorQuantity;
            }
            
            Decimal discountAmount = 0;
            while(max > min) {
                if(max >= discountTier.SBQQ__LowerBound__c) {
                	discountAmount += discountTier.SBQQ__DiscountAmount__c;
                }
                max -= 1;
            }
            
            if(effectivePrice > 0) {
            	effectivePrice -= discountAmount;
            } else {
                effectivePrice += discountAmount;
            }           
        }
        System.debug('effectivePrice after discount schedule: '+ effectivePrice);

        // Second: Additional Discount
        if(quoteLine.SBQQ__Discount__c != null) {
            effectivePrice = effectivePrice * (1 - (quoteLine.SBQQ__Discount__c/100));
        }
        System.debug('effectivePrice after additional discount: '+ effectivePrice);
		

        Decimal billableUnitPriceWithQuantity = effectivePrice;//.setScale(2, System.RoundingMode.DOWN);
        System.debug('billableUnitPriceWithQuantity: '+ billableUnitPriceWithQuantity);
        
        // NetPrice to NetTotal Ratio
        // This Ratio will be used to determine billable unit price without the quantity
        Decimal netPriceTotalRatio = quoteLine.SBQQ__NetTotal__c / quoteLine.SBQQ__NetPrice__c;
        System.debug('netPriceTotalRatio: '+ netPriceTotalRatio);

        // Billable Unit Price
        Decimal billableUnitPrice = billableUnitPriceWithQuantity / netPriceTotalRatio;
        billableUnitPrice = billableUnitPrice.setScale(2, System.RoundingMode.HALF_UP);
        System.debug('billableUnitPrice: '+ billableUnitPrice);
        

        // Get the billing multiplier so that final NetUnitPrice can be calculated
        Decimal billingMultiplier = quote.BillingMultiplier__c;
        Decimal netUnitPrice = billableUnitPrice * billingMultiplier;
        System.debug('NetUnitPrice -> (billableUnitPrice * billingMultiplier): '+ netUnitPrice);
        
        
        // Calculate Prorate Multiplier by reversing the Billable Unit Price formula
        billableUnitPriceWithQuantity = billableUnitPrice * netPriceTotalRatio;
        Decimal billableUnitPriceWithQuanitityWithSubscriptionTerm = (billableUnitPriceWithQuantity * quoteLine.SBQQ__DefaultSubscriptionTerm__c);
        if( billableUnitPriceWithQuanitityWithSubscriptionTerm != 0 ){
            Decimal prorateMultiplier = ((netUnitPrice * netPriceTotalRatio) * bpMultiplier) / billableUnitPriceWithQuanitityWithSubscriptionTerm;
            System.debug('Updated SBQQ__ProrateMultiplier__c: '+ prorateMultiplier);
            quoteLine.SBQQ__ProrateMultiplier__c = prorateMultiplier;

        }

        // Assign the values to the quote line
        quoteLine.SBQQ__NetPrice__c = netUnitPrice;
        quoteLine.BillingMultiplier__c = billingMultiplier;

    }

    public static void setNetUnitAmend(SBQQ__Quote__c quote, SBQQ__QuoteLine__c quoteLine, SBQQ__DiscountTier__c discountTier) {
        
        // If BillThroughDate__c is not set on the quote line
        // Do not proceed further
        if (   quote.QuoteBillThroughDate__c == null 
            || quoteLine.SBQQ__DefaultSubscriptionTerm__c == null
            || quote.SBQQ__Type__c != 'Amendment') {
            return;
        }
        Decimal listPrice = quoteLine.SBQQ__ListPrice__c;
        Decimal quantity = quoteLine.SBQQ__Quantity__c  == null ? 0: quoteLine.SBQQ__Quantity__c;

        if( quantity == 0 
            || quoteLine.SBQQ__ChargeType__c == 'One-Time'
            || quoteLine.SBQQ__ChargeType__c == 'Usage'
            || quoteLine.qtc_Pass_Through__c ){
            quoteLine.qtc_NetUnitAmend__c = 0;
            return;
        }
        Decimal effectivePrice = listPrice * quantity;
        Decimal netPriceTotalRatio; 

        // First: Discount Schedule
        if(discountTier != null) {
            Decimal max = quantity;
            Decimal min = 0;
            
            Decimal discountAmount = 0;
            while(max > min) {
                if(max >= discountTier.SBQQ__LowerBound__c) {
                	discountAmount += discountTier.SBQQ__DiscountAmount__c;
                }
                max -= 1;
            }
            
            if(effectivePrice > 0) {
            	effectivePrice -= discountAmount;
            } else {
                effectivePrice += discountAmount;
            }           

            netPriceTotalRatio = 1;
        } else {
            netPriceTotalRatio = quoteLine.SBQQ__Quantity__c;
        }

        // Second: Additional Discount
        if(quoteLine.SBQQ__Discount__c != null) {
            effectivePrice = effectivePrice * (1 - (quoteLine.SBQQ__Discount__c/100));
        }

        Decimal billableUnitPriceWithQuantity = effectivePrice;
        Decimal billableUnitPrice = billableUnitPriceWithQuantity / netPriceTotalRatio;
        billableUnitPrice = billableUnitPrice.setScale(2, System.RoundingMode.HALF_UP);

        quoteLine.qtc_NetUnitAmend__c= billableUnitPrice * netPriceTotalRatio;
    }

    private static Map<Id, Map<String, SBQQ__DiscountTier__c>> generateDiscountTierReferenceMap( Set<Id> discountScheduleIdSet, Set<String> setCurrencyISOCode ){
        Map<Id, Map<String, SBQQ__DiscountTier__c>> mapDiscountTierByCurrencyCodeByDiscountScheduleId = new Map<Id, Map<String, SBQQ__DiscountTier__c>>();
        for( SBQQ__DiscountTier__c discountTier : [ SELECT  Id, SBQQ__DiscountAmount__c, SBQQ__LowerBound__c, SBQQ__UpperBound__c, CurrencyIsoCode, SBQQ__Schedule__c
                                                    FROM    SBQQ__DiscountTier__c 
                                                    WHERE   SBQQ__Schedule__c IN :discountScheduleIdSet 
                                                        AND CurrencyIsoCode IN :setCurrencyISOCode
                                                        AND SBQQ__LowerBound__c = :DISCOUNT_TIER_LOWER_BOUND ]){
            if( !mapDiscountTierByCurrencyCodeByDiscountScheduleId.containsKey( discountTier.SBQQ__Schedule__c ) ){
                mapDiscountTierByCurrencyCodeByDiscountScheduleId.put( discountTier.SBQQ__Schedule__c, new Map<String, SBQQ__DiscountTier__c>() );
            }
            Map<String, SBQQ__DiscountTier__c> mapDiscountTierByCurrencyISOCode = mapDiscountTierByCurrencyCodeByDiscountScheduleId.get( discountTier.SBQQ__Schedule__c );
            mapDiscountTierByCurrencyISOCode.put( discountTier.CurrencyISOCode, discountTier );
        }
        return mapDiscountTierByCurrencyCodeByDiscountScheduleId;
    }
    
}