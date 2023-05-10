public class QuoteAdminController {

    public final zqu__Quote__c quote; 
    public string QuoteId;
    public List<AsyncApexJob> provisioningJobs; 
    private boolean AutoSubmit; 
    
    public QuoteAdminController() { 
        try 
        {
            QuoteId = ApexPages.currentPage().getParameters().get('id'); 
            if(ApexPages.currentPage().getParameters().containsKey('autoSubmit'))
                        AutoSubmit = Boolean.valueOf(ApexPages.currentPage().getParameters().get('autoSubmit'));
            system.debug('Quote Id from URL query string: [' + QuoteId + ']');
            system.debug('AutoSubmit? ' + AutoSubmit);
            
            if(String.isNotEmpty(QuoteId)) {
                quote = [SELECT Id, Name FROM zqu__Quote__c
                         WHERE Id = :QuoteId];
                QuoteId = quote.Id;
            } else {
                quote = new zqu__Quote__c(); 
            }

        }
        catch (System.QueryException ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Unable to look up the quote based on the Id given: [' + QuoteId + ']. ' + 
                                                       'Please enter the 15-digit Quote Id in the text box below and try again.'));
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    public void init() { 
        if(String.isNotEmpty(this.QuoteId) && AutoSubmit) { 
            Provision(); 
        }
    }
    
    public PageReference refreshJobs() { 
        getProvisioningJobs();
        return null;
    }
    
    public List<AsyncApexJob> getProvisioningJobs() { 
        provisioningJobs = [Select ID, Status, MethodName, ApexClass.Name, ExtendedStatus, CompletedDate, CreatedBy.Name
                from AsyncApexJob where ApexClass.Name='NSCProvisioningUtil' and MethodName = 'AsyncSendToProvisioning' order by CompletedDate desc];   
        return provisioningJobs;
    }
    
    public zqu__Quote__c getQuote() {
        return quote;
    }
    
    public void Provision() { 
        if(!Test.isRunningTest()) NSCProvisioningUtil.AsyncSendToProvisioning(this.QuoteId);    
    }
}