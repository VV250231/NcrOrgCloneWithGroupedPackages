// ===========================================================================
// Object: QuoteOnSubmitTriggerHandler
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Called by trigger when quote status changes to Sent to Z-Billing
// ===========================================================================
// Changes: 2016-06-13 Reid Beckett
//           Class created
// ===========================================================================
//public with sharing class QuoteOnSubmitTriggerHandler 
public with sharing class QuoteOnSubmitTriggerHandler 
{
    public QuoteOnSubmitTriggerHandler() 
    {       
    }


    //called on status change to Sent to Z-Billing
    public void onSubmit(zqu__Quote__c qt) 
    {
        if(qt.zqu__Opportunity__c != null) 
        {
            Opportunity opp = [select Id, Opportunity_Classification__c, 
                                        /*Solution_Portfolio__c*/ Account.Subscription_Group__c, Account.DI_Customer__c, 
                                        Account.Id
                                from Opportunity where Id = :qt.zqu__Opportunity__c];
            if(DIQuoteUtil.isDigitalInsight(opp)) 
            {
                //Update Zuora Subscription custom fields
                //DI-1149 - not triggering on New subscriptions because this condition is wrong
                //if(qt.zqu__ZuoraSubscriptionID__c != null && !String.isBlank(qt.Renewal_Subscription_ID__c)) 
                if(qt.zqu__ZuoraSubscriptionID__c != null) 
                {
                    ZuoraClient.updateZuoraSubscription(qt.Id);
                    ZuoraClient.updateZuoraAccount(qt.Id);
                }

                //Set the Opportunity to Won stage
                //DI-1498 - remove this auto-close of Opportunity logic:
                /*
                try {
                    Opportunity oppUpdate = new Opportunity(Id = qt.zqu__Opportunity__c, StageName = getOpportunityWonStageName());
                    update oppUpdate;
                }catch(Exception e) {
                    //Ignore? - exception thrown by trigger gets added to displayed messages on quote screen pop-up
                }
        */

                //Set the account's DI Customer # if necessary - only for new subscription quote and if the Account doesn't already have a DI #
                if(needsDiNumber(opp, qt))
                {
                    Account acctUpdate = new Account();
                    acctUpdate.Id = opp.AccountId;
                    acctUpdate.DI_Customer__c = getNextDICustomerNumber(); 
                    // Per Phone conversation with Bill Wise on 08/08/16, DI number should overwrite MCN on win
                    // REMOVED because of a validation rule that prevents non NSC Admins from changing the MCN once it's set
                    //acctUpdate.Master_Customer_Number__c = acctUpdate.DI_Customer__c + 'DI'; 
                    update acctUpdate;
                    incrementNextDICustomerNumber();
                }

                // Need to query for the Record Type to identify if this is a Renewal or not (DI_QI_AGIL-1082)
                zqu__quote__c q = [select Name, RecordType.Name from zqu__Quote__c where id = :qt.Id]; 

                // Send this to SOUP for Provisioning in Pivotal
                if(q.Name != 'New Renewal') { 
                    NSCProvisioningUtil.AsyncSendToProvisioning(qt.Id); 
                }
            }
        }
    }

    private String getOpportunityWonStageName()
    {
        //TODO: read from OpportunityStage?
        return 'Closed/Booked';
    }

    // Ensure we only assign DI Numbers to customers who need them
    private boolean needsDiNumber(Opportunity opp, zqu__Quote__c qt) { 
        boolean required = (opp.Opportunity_Classification__c == 'Digital Insight' /*opp.Solution_Portfolio__c == 'DIGITAL BANKING'*/ || opp.Account.Subscription_Group__c == 'Digital Insight' || opp.Account.Subscription_Group__c == 'Digital Insight- Billing Hold') && // Opp is a DI one
                (String.isBlank(opp.Account.DI_Customer__c) || Integer.valueOf(opp.Account.DI_Customer__c) == 0) && // And the associated Account has no DI Number
                qt.zqu__SubscriptionType__c == 'New Subscription'; // And this is a new subscription
        system.debug('A di number for this opp is ' + (required ? '' : 'not ') + 'required.');
        return required; 
    }

    //Reid - 11/15/2016
    //Refactored to use custom setting "sequence" value, and update it after updating the account
    public static String getNextDICustomerNumber() {
        DICustomerNumberSequence__c seq = DICustomerNumberSequence__c.getOrgDefaults();
        Integer next = Integer.valueOf(seq.Next__c);   
        return String.valueOf(next);
    }
    
    public static void incrementNextDICustomerNumber() {
        DICustomerNumberSequence__c seq = DICustomerNumberSequence__c.getOrgDefaults();
        Decimal next = seq.Next__c;   
        if(next == null) next = 1;
        seq.Next__c = next+1;
        upsert seq;
    }
    
    // We currently have large gaps in our DI Numbers. At the time of writing, if we take the HIGHEST di number from the system
    // we end up with a 9000+ number. If we take the *next available* one starting at 1000, we end up with 1003. To ensure that
    // we stay within a four or five digit DI Number, we're starting at 1626 each time we want a new DI Number and finding the
    // next gap that we can slot a new Customer into. This method handles that. TODO: Switch to a Custom Setting or other 
    // mechanism for storing the '1625' value so that it's not hardcoded. Maybe move this to a util class as well. 
    // Jan 2/2016 - Reid commenting out for code coverage - this method is no longer used
    /** 

  public static String getCurrentDICustomerNumberFromAccounts()
    {
        List<Account> accounts = [select Id, DI_Customer__c from account where DI_Customer__c > '1625' order by DI_Customer__c];

        // Starting point
        integer nextNumber = 0; 
        // Not ideal, but we've lost our "last di number" storage space when moving to Salesforce
        if (Integer.valueOf(accounts[0].DI_Customer__c) > 1626) { 
           nextNumber =  1626; // If 1626 isn't in the list, then we've got a gap between 1626 and the next-highest used number
        }
        else { 
            nextNumber = Integer.valueOf(accounts[0].DI_Customer__c); 
        }
        integer nextValidNumber = 0; 

        // Ordered list to compare against
        for(Account a : accounts) { 
            system.debug('Comparing values: ' + a.DI_Customer__c + ' and ' + nextNumber);
            if((Integer.valueOf(a.DI_Customer__c) - nextNumber) > 1) //1000 vs 1001? No Number to use. 1000 vs 1005? We can use 1001. 
            {
                nextValidNumber = nextNumber + 1; 
                break;
            }
            nextNumber = Integer.valueOf(a.DI_Customer__c); // If that number didn't work look at the next one, naturally. 
        }   
        system.debug('Setting new DI Number to: ' + nextValidNumber);
        if(nextValidNumber == 0) throw new NSCProvisioningUtil.ProvisioningException('Unable to set DI Number.'); 
        return String.valueOf(nextValidNumber);
    } 

  **/
}