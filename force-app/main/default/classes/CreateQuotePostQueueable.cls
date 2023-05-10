public class CreateQuotePostQueueable implements Queueable, Database.AllowsCallouts {
    public Id quoteId {get;set;}
    public String quoteType {get;set;}
    public Map<Id, String> subscriptionRatePlanIdsByQRPID {get;set;}
    public CreateQuoteModel.IncomingJSONBodyWrapper jsonBody {get;set;}
    
    public CreateQuotePostQueueable(Id quoteId, CreateQuoteModel.IncomingJSONBodyWrapper jsonBody, Map<Id, String> subscriptionRatePlanIdsByQRPID) {
        this.quoteId = quoteId;
        this.quoteType = jsonBody.quoteInformation.quoteType;
        this.jsonBody = jsonBody;
        this.subscriptionRatePlanIdsByQRPID = subscriptionRatePlanIdsByQRPID;
    }
    
    public void execute(QueueableContext context) {
        log('starting to create Quote Products');
        DIQuoteUtil.createQuoteProducts(new Set<Id>{ quoteId });
        log('completed creating Quote Products');

        if(quoteType == 'New Renewal') {
            CreateQuoteServiceUtil.updateRenewalQuoteRatePlans(subscriptionRatePlanIdsByQRPID);
        }
        
        CreateQuoteServiceUtil.updateQuoteProductTPVs(quoteId, jsonBody);
    }

    private static void log(String message) {
        system.debug(message);
    }

}