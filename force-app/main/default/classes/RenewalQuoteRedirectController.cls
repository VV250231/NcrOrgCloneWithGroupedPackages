// ===========================================================================
// Object: RenewalQuoteRedirectController
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Serves the redirect page - to redirect renewals to use the standard quote flow
// ===========================================================================
// Changes: 2016-04-26 Reid Beckett
//           Class created
// ===========================================================================
public with sharing class RenewalQuoteRedirectController 
{
    public zqu__Quote__c quoteSobject {get;set;}
    
    public RenewalQuoteRedirectController(ApexPages.StandardController stdController) 
    {
        quoteSobject = (zqu__Quote__c)stdController.getRecord();
    }

    public PageReference init()
    {
        String subscriptionId = ApexPages.currentPage().getParameters().get('subscriptionId');
        String url = Page.zqu__CreateQuote.getUrl();
        Id oppId = ApexPages.currentPage().getParameters().get('oppId');
        Opportunity opp = [select Id, Name, Opportunity_Classification__c,Account.Subscription_Group__c,/* Solution_Portfolio__c,*/
         AccountId from Opportunity where Id = :oppId];
        if(!DIQuoteUtil.isDigitalInsight(opp))
        {
            //just redirect to the next page in the renewal wizard
            url += '?stepNumber=3&subscriptionId='+subscriptionId;
            return new PageReference(url);
        }else {
            
            ZuoraSubscription zuoraSub = ZuoraClient.getInstance().findZuoraSubscription(subscriptionId);
            ZuoraSubscriptionState zss = new ZuoraSubscriptionState(zuoraSub);

            //create the quote...
            String billingAccountId = ApexPages.currentPage().getParameters().get('billingAccountId');
            Id quoteId = DIQuoteUtil.createRenewalQuote(billingAccountId, subscriptionId, oppId);
            String crmAccountId = opp.AccountId;

            //redirect to the next page in the renewal wizard
            //DI 1105 pass the billingAccountId it will make the Bill To & Sold To Read-only
            url += '?id='+quoteId+'&billingAccountId='+billingAccountId+'&crmAccountId='+crmAccountId+'&subscriptionId='+subscriptionId+'&stepNumber=2&quoteType=Subscription&retURL='+
                EncodingUtil.urlEncode('/'+oppId, 'UTF-8') + '&oppId='+oppId;
            return new PageReference(url).setRedirect(true);
        }
    }
}