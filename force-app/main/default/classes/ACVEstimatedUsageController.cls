// ===========================================================================
// Object: ACVEstimatedUsageController
// Author: Garrett Heathcote
// Purpose: Serves the page "4" Estimated Usage page of the quote wizard used for ACV calculations
// ===========================================================================
// Changes: 2018-02-15 Garrett Heathcote
//           Class created
// ===========================================================================
public with sharing class ACVEstimatedUsageController {

    public zqu__Quote__c quoteSobject {get;set;}
    public Account account {get;set;}
    public List<zqu__QuoteRatePlan__c> quoteRatePlans {get;set;}
    public List<zqu__QuoteRatePlanCharge__c> quoteCharges {get;set;}
    public Set<string> messages {get; set;}
    public Boolean hasMessages {get; set;}
    public string noUsageCharges {get; set;}
    
    public ACVEstimatedUsageController(ApexPages.StandardController stdController) 
    {
        if(quoteSobject == null) quoteSobject = (zqu__Quote__c)stdController.getRecord();
    }

    public PageReference init()
    {
        //system.debug('init: quoteSobject.zqu__Opportunity__r='+quoteSobject.zqu__Opportunity__r);
        //system.debug('init: quoteSobject.zqu__Opportunity__c='+quoteSobject.zqu__Opportunity__c);
        noUsageCharges = 'false';
        //Get the Quote
        quoteSobject = [select Id, zqu__StartDate__c,zqu__Opportunity__r.Account.Subscription_Group__c, zqu__Opportunity__r.Opportunity_Classification__c, /*zqu__Opportunity__r.Solution_Portfolio__c, */
            RecordType.Name, Renewal_Discount_Level__c, Add_on_monthly_fees_discount__c, Add_on_Setup_fees_discount__c, Add_on_Setup_fees_discount_Platform__c, All_transaction_fees_discount__c,
            Renewal_ARPU__c, Is_Team_Connect__c,
            Professional_Services_fees_discount__c, Term_of_contract__c, Effective_Date_of_Pricing_in_a_Renewal__c, Price_Increase__c, Payment_Terms_or_Waiver_Delay_of_Minimum__c, Early_Term_Calculation__c,
            zqu__Opportunity__c, zqu__Account__c, zqu__Opportunity__r.AccountId from zqu__Quote__c where Id = :quoteSobject.Id];
        
        //Get Quote Rate Plan Charges and add to a list             
        quoteCharges = [select Id, Name, zqu__ChargeType__c, Monthly_Estimated_Usage__c,zqu__UOM__c
            from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__r.Id = :quoteSobject.Id AND zqu__ChargeType__c = 'Usage' order by Name asc]; 

                
        //system.debug('quoteCharges.size()='+quoteCharges.size());
        if(quoteCharges.size() <= 0)
        {
            noUsageCharges = 'true';
            return next();
        }
        return null;
    }

    public PageReference next()
    {
        Boolean inWizard = ApexPages.currentPage().getParameters().get('stepNumber') != null;
        if(!inWizard) {
            return new PageReference('/' + quoteSobject.Id);
        }else{
            PageReference nextPage = zqu.QuoteWizardManager.navigateNext(New Map<String, String> {'Id' => quoteSobject.Id, 'noUsageCharges' => noUsageCharges, 'quoteType' => ApexPages.currentPage().getParameters().get('quoteType')});
            return nextPage;
        }
    }
 
    public PageReference save()
    {
        update quoteCharges;
        String[] errors;
        if(errors != null && !errors.isEmpty()) {
            hasMessages = true;
            for(String e : errors) { 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e)); 
            }
            return null;
        }
        
        return next();
        /*String quoteType = ApexPages.currentPage().getParameters().get('quoteType');
        String stepNumber = ApexPages.currentPage().getParameters().get('stepNumber');
        if(String.isBlank(stepNumber)) {
            return new PageReference('/' + quoteSobject.Id);
        }else{
            return new PageReference(Page.ACVEstimatedUsage.getUrl() + '?id='+quoteSobject.Id+'&quoteType='+quoteType+'&stepNumber='+stepNumber);
        }*/
    }
   
    public PageReference back()
    {
        Boolean inWizard = ApexPages.currentPage().getParameters().get('stepNumber') != null;
        
        if(!inWizard) {
            return new PageReference('/' + quoteSobject.Id);
        }else{
            PageReference nextPage = zqu.QuoteWizardManager.navigateBack(New Map<String, String> {'Id' => quoteSobject.Id, 'quoteType' => ApexPages.currentPage().getParameters().get('quoteType')});
            return nextPage;
        }
    }

    public PageReference done()
    {
       /* String[] errors;
        if(errors != null && !errors.isEmpty()) {
            hasMessages = true;
            for(String e : errors) { 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e)); 
            }
            return null;
        }*/
        
        return next();
    }       
        
}