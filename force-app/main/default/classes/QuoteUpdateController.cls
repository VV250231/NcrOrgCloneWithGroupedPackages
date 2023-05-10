// ===========================================================================
// Object: QuoteUpdateController
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Controller for custom button to update a quote from Zuora
// ===========================================================================
// Changes: 2017-04-27 Reid Beckett
//           Class created
// ===========================================================================
public  with sharing  class QuoteUpdateController {
    private Id quoteId;
    public Boolean hasError {get;set;}
    public String beforeSubscriptionID {get;set;}
    public Decimal beforeVersion {get;set;}
    public String afterSubscriptionID {get;set;}
    public Decimal afterVersion {get;set;}
        
    public QuoteUpdateController(ApexPages.StandardController stdController) {
        this.quoteId = stdController.getId();
    }
    
    public PageReference initAction(){
        try{
            hasError = false;
            zqu__Quote__c qt = [select Id, zqu__ExistSubscriptionID__c, zqu__SubscriptionVersion__c from zqu__Quote__c where Id = :quoteId];
            
            beforeSubscriptionID = qt.zqu__ExistSubscriptionID__c;
            beforeVersion = qt.zqu__SubscriptionVersion__c;

            ZQuoteUpdateUtil.updateQuote(qt.Id);
            
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Update successful'));

            qt = [select Id, zqu__ExistSubscriptionID__c, zqu__SubscriptionVersion__c from zqu__Quote__c where Id = :quoteId];

            afterSubscriptionID = qt.zqu__ExistSubscriptionID__c;
            afterVersion = qt.zqu__SubscriptionVersion__c;
        }catch(Exception e){
            hasError = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }

    public PageReference goBack(){
        return new PageReference('/' + quoteId);
    }

}