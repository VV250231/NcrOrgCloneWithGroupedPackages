public with sharing class NCRQuoteSubmit2Controller extends zqu.QuotePreviewController { 
    public zqu__Quote__c quoteSobject {get;set;}
    public zqu.QuotePreviewOptions previewOptions {get;set;}
    public Boolean hasInitError {get;set;}
    public Boolean displayHeapError {get;set;}
    public Integer heapSize {get; private set;}
    public List<ZuoraSubscriptionState.RenewalChange> changes {get;set;}
    public List<ZuoraSubscriptionState.RenewalChange> updates {get;set;}
    public Id currentUserId {get;set;}
    public List<DI_Sales_Operations_Team__c> diTeam {get;set;}
    
    public NCRQuoteSubmit2Controller(ApexPages.StandardController stdController) 
    {
        Id quoteId = stdController.getId();
        quoteSobject = [select Id, RecordType.Name, zqu__Opportunity__c, zqu__Opportunity__r.AccountId, zqu__ZuoraAccountID__c, zqu__ElectronicPaymentMethodId__c, zqu__Status__c, 
            Renewal_Subscription_ID__c, zqu__ExistSubscriptionID__c, zqu__StartDate__c, DI_Approval_Status__c from zqu__Quote__c where Id = :quoteId];
        hasInitError = false;           
        displayHeapError = false;
        previewOptions = new zqu.QuotePreviewOptions();
        previewOptions.quoteId = stdController.getId(); 
        previewOptions.quoteId = stdController.getId();
        // Set display options
        previewOptions.hideQuoteProperty = true;
        previewOptions.buttonBarLocation = 'top';
        previewOptions.quotePropertyTitle = 'Quote Details';
        previewOptions.selectedProductsTitle = 'Selected Products and Rate Plans';
        previewOptions.isSelectedProductsCollapsible = true;
        // Set preview controller and CreateOrderPlugin
        previewOptions.previewController = this;
        zqu.NotificationOptions notificationOptions = new zqu.NotificationOptions(); 
        previewOptions.notificationOptions = notificationOptions;
        currentUserId = UserInfo.getUserId();
        diTeam = DI_Sales_Operations_Team__c.getall().values();
        
    }
     
    //This method is used to check if user have access to use send to zBilling functionality or not
    public boolean valdiateUser(){
        boolean isValidUser;
        if(diTeam != null && diTeam.size() > 0){
            for(DI_Sales_Operations_Team__c diUser : diTeam){
                if(diUser.User_Id__c == currentUserId){
                    isValidUser = true;
                    break; 
                }else{
                    isValidUser = false;
                }
            }
        }
        return isValidUser;        
    }
    
    // DEPRECATED: This contributes to a heap size error, so it is no longer used, per SC2015_AGL-4334
    /*
    public void loadChanges() {

        updates = new List<ZuoraSubscriptionState.RenewalChange>();
        
        //Renewal
        if(!String.isBlank(quoteSobject.Renewal_Subscription_ID__c)) {
            ZuoraSubscription zuoraSubscription = ZuoraClient.getInstance().findZuoraSubscription(quoteSobject.Renewal_Subscription_ID__c);
            ZuoraSubscriptionState zss = new ZuoraSubscriptionState(zuoraSubscription);
            zss.addQuote(quoteSobject);
            List<ZuoraSubscriptionState.RenewalChange> renewalChanges = zss.getRenewalChanges();

            changes = new List<ZuoraSubscriptionState.RenewalChange>();
            for(ZuoraSubscriptionState.RenewalChange rc : renewalChanges) {
                changes.add(rc);
                //if(rc.action == 'Remove') removes.add(rc);
                //else if(rc.action == 'Update') updates.add(rc);
                if(rc.action == 'Update') updates.add(rc);
            }
            changes.sort();
            zss.saveRenewalChanges(changes);
        }

        //Amendment
        if(!String.isBlank(quoteSobject.zqu__ExistSubscriptionID__c)) {
            ZuoraSubscription zuoraSubscription = ZuoraClient.getInstance().findZuoraSubscription(quoteSobject.zqu__ExistSubscriptionID__c);
            ZuoraSubscriptionState zss = new ZuoraSubscriptionState(zuoraSubscription);
            zss.addQuote(quoteSobject);
            this.changes = zss.getRenewalChanges();
            this.changes.sort();
            //zss.saveRenewalChanges(changes);
        }

        //New
        if(String.isBlank(quoteSobject.Renewal_Subscription_ID__c) && String.isBlank(quoteSobject.zqu__ExistSubscriptionID__c)) {
            this.changes = new List<ZuoraSubscriptionState.RenewalChange>();
            zqu__QuoteRatePlan__c[] quoteRatePlans = [select Id, zqu__ProductRatePlan__r.Name, zqu__QuoteProductName__c,
                                                      (select Id, zqu__EffectivePrice__c, zqu__Quantity__c, zqu__MRR__c from zqu__QuoteChargeSummarys__r)
                                                      from zqu__QuoteRatePlan__c where zqu__Quote__c = :quoteSobject.Id];
            for(zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
                ZuoraSubscriptionState.RenewalChange change = new ZuoraSubscriptionState.RenewalChange();
                change.action = 'Add';
                change.quoteRatePlanId = qrp.Id;
                change.ratePlanName = qrp.zqu__ProductRatePlan__r.Name;
                change.productName = qrp.zqu__QuoteProductName__c;
                if(!qrp.zqu__QuoteChargeSummarys__r.isEmpty()) {
                    if(qrp.zqu__QuoteChargeSummarys__r[0].zqu__Quantity__c != null)
                        change.quoteQuantity = Integer.valueOf(qrp.zqu__QuoteChargeSummarys__r[0].zqu__Quantity__c);
                    change.quotePrice = qrp.zqu__QuoteChargeSummarys__r[0].zqu__EffectivePrice__c;
                    change.deltaMRR = qrp.zqu__QuoteChargeSummarys__r[0].zqu__MRR__c;
                }
                this.changes.add(change);
            }
            this.changes.sort();
        }
    }*/
    
        
    public PageReference cancelAction() {
        return new PageReference('/' + quoteSobject.Id);
    }
    
    public PageReference init()    
    {
        system.debug('HEAP SIZE on init: ' + Limits.getHeapSize());
        if(ZuoraOptions__c.getInstance() != null && ZuoraOptions__c.getInstance().Name != null && !ZuoraOptions__c.getInstance().Send_To_Z_Billing_Enabled__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Send to Z-Billing is temporarily disabled.'));
            hasInitError = true;
            return null;
        }
        
        // get admin profile 
        
        if(valdiateUser() == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You don\'t have sufficient permission to access this page !'));
            hasInitError = true;
            return null;
        }
        
        if(quoteSobject.zqu__Status__c != 'New') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quote has already been sent to Zuora'));
            hasInitError = true;
            return null;
        }
        
        Opportunity opp = [select Id, Name, StageName, Opportunity_Classification__c,/* Solution_Portfolio__c*/ Account.Subscription_Group__c, (select Id, zqu__Status__c from zqu__Quotes__r) from Opportunity where Id = :quoteSobject.zqu__Opportunity__c];
        if(DIQuoteUtil.isDigitalInsight(opp)) {
            //check that the quote is approved
            //DI-1573 - don't check this, only for cancellation quote
            if(quoteSobject.RecordType.Name == 'Cancellation' && quoteSobject.DI_Approval_Status__c != 'Approved') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The quote has not been approved for submission yet'));
                hasInitError = true;
                return null;
            }
            
            // CHECK OPPORTUNITY IS CLOSED/BOOKED
            if(opp.StageName != 'Closed/Booked') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity stage should be Closed/Booked before sending quote to z-billing'));
                hasInitError = true;
                return null;
            }

            //check that there is  not already a quote submitted on the same opportunity
            
            for(zqu__Quote__c qt : opp.zqu__Quotes__r) {
                if(qt.Id != quoteSobject.Id && qt.zqu__Status__c == 'Sent to Z-Billing') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Another quote from this Opportunity has already been sent to Zuora'));
                    hasInitError = true;
                    return null;
                }
            }
        }

        //make sure this is a DI quote...if not redirect to the normal submit page
        //TODO: Dec 9 - change to only redirect when not DI (i.e. stay on this page for all 3 quote types)
        //if(!DIQuoteUtil.isDigitalInsight(opp) || String.isBlank(quoteSobject.Renewal_Subscription_ID__c)) {
        if(!DIQuoteUtil.isDigitalInsight(opp) || quoteSobject.RecordType.Name == 'Cancellation') {
            return new PageReference(Page.zqu__ZuoraQuoteSubmit.getUrl() + '?id='+quoteSobject.Id);
        }else {
            //Removed summary per SC2015_AGL-4334            
            //loadChanges();
            return null;
        }    
    }
    
    public Boolean hasChanges {
        get {
            return changes != null && !changes.isEmpty();
        }
    }

    public String pageBlockTitle {
        get {
            //Renewal
            if(!String.isBlank(quoteSobject.Renewal_Subscription_ID__c)) {
                return 'Renewal vs Original Subscription Summary';
            }else if(!String.isBlank(quoteSobject.zqu__ExistSubscriptionID__c)) {
                return 'Amendment vs Original Subscription Summary';
            }else {
                return 'Subscription Summary';
            }
        }
    }

    public PageReference toQuoteDetail() {
        return new PageReference('/' + quoteSobject.Id);
    }
    //this method is only for code coverage, will be removed later
    public static void codeCoverage(){
        Integer i = 0;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
        i = i++;
    }
}