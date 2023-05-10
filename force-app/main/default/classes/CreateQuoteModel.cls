// ===========================================================================
// Object: CreateQuoteModel
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Model objects for the CreateQuoteService
// ===========================================================================
// Changes: 2017-04-03 Reid Beckett
//           Class created
// ===========================================================================
public class CreateQuoteModel 
{
    public class IncomingJSONBodyWrapper
    {
        public QuoteInformation quoteInformation;
        public RatePlan[] ratePlans;
        
        public String[] validate() {
            String[] errors = new String[]{};
    
            if(quoteInformation.startDate == null) {
                errors.add('startDate is required');
            }
    
            if(String.isBlank(quoteInformation.opportunityId)) {
                errors.add('opportunityId is required');
            }
    
            if(String.isBlank(quoteInformation.quoteType)) {
                errors.add('quoteType is required');
            }
            
            if(quoteInformation.quoteType == 'Amendment' && String.isBlank(quoteInformation.subscriptionId)) {
                errors.add('subscriptionId is required for an Amendment');
            }

            return errors;
        }
    }
    
    public class QuoteInformation 
    {
        public String id;
        public String billingAccountId;
        public String masterCustomerNumber;
        public String subscriptionId;
        public String opportunityId;
        public String quoteType;
        public Date startDate;
        public String ownerFirstName;
        public String ownerLastName;
        public String name;
    }

    public class RatePlan 
    {
        public String action; //add/remove/update
        public String name;
        public String productRatePlanId;
        public Decimal quantity;
        public Decimal price; 
        public String subscriptionRatePlanId;
        public String tpv;
        public RatePlanTier[] tiers;
    }
    
    public class RatePlanTier
    {
        public Integer tier;
        public Decimal startingUnit;
        public Decimal endingUnit;
        public Decimal price;
        public String priceFormat;
    }

    public class OutgoingJSONBodyWrapper
    {
        public String status;
        public String[] messages;
        public String quoteId;
    }
}