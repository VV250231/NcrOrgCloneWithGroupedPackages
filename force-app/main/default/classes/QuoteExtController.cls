public with sharing class QuoteExtController {

    private Id quoteId;
    
    
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    
    public PageReference onSubmit() {
        
        try {
            if (quoteId != null) {
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
            }
        } 
        // Approval Enablement Package 4.0 - Catch any errors (Validation, Apex) during approval process
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        
        // Approval Enablement Package 4.0 - If no error then return user to the quote page
        PageReference pr = new PageReference('/' + quoteId);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference onRecall() {
        boolean showMsg = false;
        PageReference pr = null;
        try {
            if (quoteId != null) {
                SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
                showMsg = CPQ_Util.getQulifiedQuotesForAlert(quoteId);
        		if(showMsg){
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'You need to get legal doc signed after recall.'));
                     pr = null;   
                }else{
                   // Approval Enablement Package 4.0 - If not error, return to quote page
                   pr = new PageReference('/' + quoteId);
                   pr.setRedirect(true);
                   
                }
               
            }
            
        }
        // Approval Enablement Package 4.0 - Catch any errors (Validation, Apex) during approval process
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            pr = null;
        }
		return pr;
 
    }

    // Approval Enablement Package 4.0 - Show a Cancel button on the page if an error occurs
    public PageReference onCancel() {
        return new PageReference('/' + quoteId);
    }

    @AuraEnabled
    public static boolean recallApproval(String quoteId){
        boolean showMsg = false;
        try {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
            showMsg = CPQ_Util.getQulifiedQuotesForAlert(quoteId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('***'+showMsg);
        return showMsg;
    }

}