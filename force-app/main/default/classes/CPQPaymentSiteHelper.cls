public class CPQPaymentSiteHelper {
    
 public Id quoteId {get; set;}
    public Id getQuoteId(){
        return quoteId;
    }
    public List<NCR_Payments_Site__c> sites;
    
    public CPQPaymentSiteHelper() {
        
        
    }
    
    public List<NCR_Payments_Site__c> getPaymentSites(){
        sites = [ 
            SELECT Id, Account_Sites__c,Account_Sites__r.Name, MID__c,TID__c,Account_Sites__r.BillingStreet,
            Account_Sites__r.BillingCity,Account_Sites__r.BillingState,Account_Sites__r.BillingPostalCode,Account_Sites__r.BillingCountry
            FROM NCR_Payments_Site__c
            WHERE Quote__c =: quoteId AND NCR_Payments_Application_Status__c = 'ApprovedAndBoarded'
        ]; 
        return sites;
    }
    
}