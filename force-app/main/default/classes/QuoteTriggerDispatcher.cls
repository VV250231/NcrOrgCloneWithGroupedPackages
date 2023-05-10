public class QuoteTriggerDispatcher extends TriggerHandlerBase {
	private static QuoteTriggerHandler qtHandler;
    
    public override void beforeInsert(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        
        //handle the Custom Payment Term and Subscription Group changes and show the error accordingly
        qtHandler.showErrorOnQuoteWizard((list<zqu__Quote__c>) Trigger.new);
        
        //populate Bundle Name, Status, Opportunity Owner Email,Total Amendment One Time Fee, Total Amendment Monthly Fee on Quote object.
    	qtHandler.beforeInsertUpdateQuoteBundleDetail((list<zqu__Quote__c>) Trigger.new);
        
        //reporting fields from billing account
        qtHandler.ReportingFieldsFromBillingAccount((list<zqu__Quote__c>) Trigger.new);
    }
    
    public override void afterInsert(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        
        //calcQuoteSharingForAccount
        qtHandler.afterInsertcalcQuoteSharingForAccount((list<zqu__Quote__c>) Trigger.new);
        
        //send the eligible quote to Zuora instead of manually hitting the send to z billing button.
        qtHandler.AutomateSendToZBilling((list<zqu__Quote__c>) Trigger.new);
        
        //insert quote product when quote is of cancellation type
        qtHandler.insertQuoteProduct((list<zqu__Quote__c>)Trigger.new, null);
    }
    
    public override void beforeUpdate(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        //GET OLD RECORD MAP FOR INCOMING RECORDS
        Map < Id, sObject > oldBeoreUpdateMap = this.getOldBeforeUpdateMap(Trigger.newMap.keySet());
        Map < Id, zqu__Quote__c > oldMapQuote = new Map < Id, zqu__Quote__c > ();
        Map < Id, zqu__Quote__c > newMapQuote = new Map < Id, zqu__Quote__c > ();
        for (Id qutId: oldBeoreUpdateMap.keyset()) {
            oldMapQuote.put(qutId, (zqu__Quote__c) oldBeoreUpdateMap.get(qutId));
        }
        for(zqu__Quote__c obj: (List<zqu__Quote__c>) Trigger.new) {
            newMapQuote.put(obj.Id,obj);
        }
        
        //send a notification to opp sales team when quote stage is changed to rejected
        qtHandler.sendMailOnReject((list<zqu__Quote__c>)Trigger.new, oldMapQuote);
        
        //change the connection for others quotes of same opportunity
        qtHandler.UpdateOldAccountId((list<zqu__Quote__c>)Trigger.new, newMapQuote, oldMapQuote);
        
        //handle the Custom Payment Term and Subscription Group changes and show the error accordingly
        qtHandler.showErrorOnQuoteWizard((list<zqu__Quote__c>) Trigger.new);
        
        //populate Bundle Name, Status, Opportunity Owner Email,Total Amendment One Time Fee, Total Amendment Monthly Fee on Quote object.
    	qtHandler.beforeInsertUpdateQuoteBundleDetail((list<zqu__Quote__c>) Trigger.new);
        
        //SC2015_AGL-4659 - Set SAD to correct date when the quote enters an approved status
        qtHandler.setServiceActivationDate((list<zqu__Quote__c>) Trigger.new);
        
        //reporting fields from billing account
        qtHandler.ReportingFieldsFromBillingAccount((list<zqu__Quote__c>) Trigger.new);
    }
    
    public override void afterUpdate(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        //GET OLD RECORD MAP FOR INCOMING RECORDS
        //Map < Id, sObject > oldBeoreUpdateMap = this.getOldBeforeUpdateMap(Trigger.newMap.keySet());
        Map < Id, sObject > recOldMap = this.getOldAfterUpdateMap(Trigger.newMap.keySet());
        Map < Id, zqu__Quote__c > oldMapQuote = new Map < Id, zqu__Quote__c > ();
        Map < Id, zqu__Quote__c > newMapQuote = new Map < Id, zqu__Quote__c > ();
        for (Id qutId: recOldMap.keyset()) {
            oldMapQuote.put(qutId, (zqu__Quote__c) recOldMap.get(qutId));
        }
        for(zqu__Quote__c obj: (List<zqu__Quote__c>) Trigger.new) {
            newMapQuote.put(obj.Id,obj);
        }
        
        //update zuora subscription and zuora account and opp when approval status change on quote
        qtHandler.UpdateZuoraSubscriptionOnApprovalChange((list<zqu__Quote__c>)Trigger.new, oldMapQuote);
        
        //calcQuoteSharingForAccount
        qtHandler.afterUpdatecalcQuoteSharingForAccount((list<zqu__Quote__c>)Trigger.new, oldMapQuote);
        
        ////Update And Delete opportunity line item from Opportunity
        qtHandler.UpdateAndDeleteOLIfromOpp((list<zqu__Quote__c>)Trigger.new, oldMapQuote);
        
        //populate Bundle Name, Status, Opportunity Owner Email,Total Amendment One Time Fee, Total Amendment Monthly Fee on Quote object.
    	qtHandler.afterUpdateQuoteBundleDetail((list<zqu__Quote__c>) Trigger.new, newMapQuote, oldMapQuote);
        
        //send the eligible quote to Zuora instead of manually hitting the send to z billing button.
        qtHandler.AutomateSendToZBilling((list<zqu__Quote__c>) Trigger.new);
        
        //insert quote product when quote is of cancellation type
        qtHandler.insertQuoteProduct((list<zqu__Quote__c>)Trigger.new, oldMapQuote);
        
        //RejectQuoteWhenProvisioningFailsOnPendingRecord
        qtHandler.RejectQuoteWhenProvisioningFailsOnPendingRecord((list<zqu__Quote__c>)Trigger.new, oldMapQuote);
    }
    
    public override void beforeDelete(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        
        //prevent delete when status != New
        qtHandler.QuotePreventDelete((List<zqu__Quote__c>) Trigger.old);
    }
    
    public override void afterDelete(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        
        //make other quote primary on same opportunity
        qtHandler.afterDeletePrimaryQuoteOnOpp((List<zqu__Quote__c>) Trigger.old);
    }
    
    public override void afterUndelete(){
        qtHandler = (qtHandler != null) ? qtHandler : new QuoteTriggerHandler();
        
        //update opportunity line items
        qtHandler.afterUndeleteupdateOppLineItems((List<zqu__Quote__c>) Trigger.new);
    }
}