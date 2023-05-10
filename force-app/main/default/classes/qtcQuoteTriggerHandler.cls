public with sharing class qtcQuoteTriggerHandler extends ErrorLogUtil {
    @TestVisible private static Boolean bypassTrigger =false;

    public static String    RECORD_TYPE_DRAFT               = 'AAE_Draft_Quote',
                            RECORD_TYPE_IN_PROGRESS         = 'AAE_In_Progress_Quote',
                            RECORD_TYPE_APPROVED            = 'AAE_Approved_Quote',
                            STATUS_DRAFT                    = 'Draft',
                            STATUS_IN_REVIEW                = 'In Review',
                            STATUS_PENDING                  = 'Pending',
                            STATUS_APPROVED                 = 'Approved',
                            STATUS_APPROVED_PAYMENTS_TEAM   = 'Approved - Payments Team',
                            STATUS_REJECTED                 = 'Rejected',
                            STATUS_RECALLED                 = 'Recalled',
                            STATUS_DENIED                   = 'Denied',
                            PAYMENT_APPROVAL_STATUS_APPROVED = 'Approved',
                            TYPE_AMENDMENT                  = 'Amendment',
                            MULTI_SITE_TYPE_AE_PP           = 'AE+PP',
                            MULTI_SITE_RELATIONSHIP_CHILD   = 'Child',
                            PAYMENT_TYPE_NO_PAYMENT         = 'No Payments',
                            ERROR_MESSAGE_AE_PP_INVALID     = 'The quote cannot be saved because this quote\'s Parent, AE+PP quote was amended and canceled.';
    public static Integer   DEFAULT_SUBSCRIPTION_TERM       = 36;

    List<SBQQ__Quote__c> listNewRecords = new List<SBQQ__Quote__c>();
    Map<Id, SBQQ__Quote__c> mapOldRecords = new Map<Id, SBQQ__Quote__c>();

    public qtcQuoteTriggerHandler( List<SBQQ__Quote__c> listTriggerNew, Map<Id, SBQQ__Quote__c> mapTriggerOld ){
        this.listNewRecords = listTriggerNew;
        this.mapOldRecords = mapTriggerOld;
    }

    public void handleBeforeInsert(){
        if(bypassTrigger) {return;}
        Set<Id> setContractId = new Set<Id>();
        string MapofInFlightAmendQuotes = '';
        
        for( SBQQ__Quote__c thisQuote : listNewRecords ){
            thisQuote.SBQQ__Status__c = STATUS_DRAFT;
            if(thisQuote.SBQQ__Type__c == TYPE_AMENDMENT){
              setContractId.add(thisQuote.SBQQ__MasterContract__c);
            }
        }
        
        if(setContractId.size() > 0){
            MapofInFlightAmendQuotes = ExistingQuotesRelatedToContract( setContractId );
            system.debug('-------MapofInFlightAmendQuotes'+MapofInFlightAmendQuotes);
        }
       for( SBQQ__Quote__c thisQuote : listNewRecords ){
            if(MapofInFlightAmendQuotes != ''){
               thisQuote.adderror('This Contract currently has an amendment in progress '+ MapofInFlightAmendQuotes);
            }
       }
       
    }

    public void handleBeforeUpdate() {
        if(bypassTrigger) {return;}
        Set<Id> setMultiSiteParentQuoteIds = new Set<Id>();
        Set<Id> setPaymentApprovalIds = new Set<Id>();

        for(SBQQ__Quote__c thisQuote : listNewRecords ){
            setMultiSiteParentQuoteIds.add( thisQuote.qtc_Multi_Site_Parent_Quote__c );
            setPaymentApprovalIds.add( thisQuote.Payments_Approval__c );
        }

        List< SBQQ__Quote__c> listAmendedCancelledQuotes = amendedQuotesCancelledSelector( setMultiSiteParentQuoteIds );
        Map<String, List<SBQQ__Quote__c>> mapListAmendedCancelledQuoteByOriginalQuoteId = ApexUtils.groupBy(listAmendedCancelledQuotes, SBQQ__Quote__c.SBQQ__OriginalQuote__c);
        Map<Id, qtc_PaymentsApproval__c> mapPaymentsApprovalById = paymentsApprovalSelector( setPaymentApprovalIds );

        Map<String,SBQQ__Quote__c> pQuotesMap = new Map<String,SBQQ__Quote__c>();
        
        for( SBQQ__Quote__c thisQuote : listNewRecords ){
            SBQQ__Quote__c oldRecord = mapOldRecords.get( thisQuote.Id );
            List<SBQQ__Quote__c> thisListAmendedCancelledQuote = mapListAmendedCancelledQuoteByOriginalQuoteId.get( thisQuote.qtc_Multi_Site_Parent_Quote__c );

            if( thisQuote.SBQQ__Ordered__c == true 
                && thisQuote.SBQQ__Ordered__c != oldRecord?.SBQQ__Ordered__c
                && !isAEPPChildAndParentValid(thisQuote, thisListAmendedCancelledQuote) ){
                    
                thisQuote.SBQQ__Ordered__c.addError( ERROR_MESSAGE_AE_PP_INVALID );
            }

            setApprovalStatusFieldUpdates( thisQuote, oldRecord, mapPaymentsApprovalById);
            
            if(thisQuote.qtc_Number_of_Sites_with_Payments__c != null && thisQuote?.qtc_Number_of_Sites_with_Payments__c != oldRecord?.qtc_Number_of_Sites_with_Payments__c) {
                pQuotesMap.put(thisQuote.Id,thisQuote);
            }
        }
        //ATG 08-25-2021 Deprecated class and moved logic to QCP
        // CPQQuoteLinePackageTotalHelper.handleBeforeUpdate(listNewRecords);

        if(pQuotesMap.size()>0){ 
            CPQNCRPaymentSitesTriggerHandler.handleBeforeQuoteUpdate(pQuotesMap);
        }
        
        
    }

    public void handleAfterUpdate(){
        if(bypassTrigger) {return;}
        submitQuoteForApproval( listNewRecords );
        try{
            syncFulfillmentOrders();
        } catch( DmlException ex){
            log('syncFulfillmentOrders', ex);
        } finally {
            commitLogs();
        }

    }

    
    private static void setApprovalStatusFieldUpdates( SBQQ__Quote__c thisQuote, SBQQ__Quote__c oldRecord, Map<Id, qtc_PaymentsApproval__c> mapPaymentsApprovalById){
       
        // Updated to Draft from another status
        if ( oldRecord.SBQQ__Status__c != STATUS_DRAFT && thisQuote.SBQQ__Status__c == STATUS_DRAFT ) {
            try {
                thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_DRAFT ).getRecordTypeId();
             
            }
             catch (Exception e) {}
        }    
         // Recalled, update to Quote - Draft
        else if ( thisQuote.ApprovalStatus__c != oldRecord.ApprovalStatus__c && thisQuote.ApprovalStatus__c == STATUS_RECALLED  ) {
            try {
                thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_DRAFT ).getRecordTypeId();
                thisQuote.qtcApprovalStatusManual__c = '';
                //Below line added by Dharmendra on 8th Jun 2021 - SFCPQBLG-267
                thisQuote.qtc_Legal_Document_Status__c = '';
                thisQuote.qtc_EligibleForERP__c = null;
                thisQuote.qtc_UnlockQuote__c = FALSE;
                thisQuote.qtc_Order_Authorization_Accepted_Date__c = null;
                thisQuote.qtc_Order_Authorization_Sent_Date__c = null;
                if(thisQuote.TechnicalReviewStatus__c == 'Manually Completed'){
                  thisQuote.TechnicalReviewStatus__c = '';
                }
                qtc_PaymentsApproval__c thisPaymentApproval = mapPaymentsApprovalById.get( thisQuote.Payments_Approval__c );
                if( thisPaymentApproval?.ApprovalStatus__c == PAYMENT_APPROVAL_STATUS_APPROVED ){
                    thisQuote.SBQQ__Status__c = STATUS_APPROVED_PAYMENTS_TEAM;
                }
                else {
                    thisQuote.SBQQ__Status__c = STATUS_DRAFT;
                }
            }
            catch (Exception e) {}
        }
         // Rejected, update to Quote - Draft
        else if ( thisQuote.ApprovalStatus__c != oldRecord.ApprovalStatus__c &&  thisQuote.ApprovalStatus__c == STATUS_REJECTED  ) {
            try {
                thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_DRAFT ).getRecordTypeId();
                thisQuote.qtcApprovalStatusManual__c = '';

                qtc_PaymentsApproval__c thisPaymentApproval = mapPaymentsApprovalById.get( thisQuote.Payments_Approval__c );
                if( thisPaymentApproval?.ApprovalStatus__c == PAYMENT_APPROVAL_STATUS_APPROVED ){
                    thisQuote.SBQQ__Status__c = STATUS_APPROVED_PAYMENTS_TEAM;
                }
                else {
                    thisQuote.SBQQ__Status__c = STATUS_DRAFT;
                }
            }
            catch (Exception e) {}
        }
        // CLASSIC - Quote is submitted for approval, update to Quote - In Review
        else if ( thisQuote.ApprovalStatus__c != oldRecord.ApprovalStatus__c && thisQuote.ApprovalStatus__c == STATUS_PENDING ) {
            try {
                thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_IN_PROGRESS ).getRecordTypeId();
                thisQuote.SBQQ__Status__c = STATUS_IN_REVIEW;
               
            }
            catch (Exception e) {}
        }
        // LIGHTNING - Quote is submitted for approval, update to Quote - In Review
        else if (thisQuote.qtcApprovalStatusManual__c != oldRecord.qtcApprovalStatusManual__c && thisQuote.qtcApprovalStatusManual__c == STATUS_PENDING ) {
            try {
                thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_IN_PROGRESS ).getRecordTypeId();
                thisQuote.SBQQ__Status__c = STATUS_IN_REVIEW;                    
            }
            catch (Exception e)
            {
                thisQuote.qtcApprovalError__c = e.getMessage();
            }
        }
        // Quote is approved, update to Quote - Approved
        else if ( thisQuote.ApprovalStatus__c != oldRecord.ApprovalStatus__c && thisQuote.ApprovalStatus__c == STATUS_APPROVED ){
         
            try {
                thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_APPROVED ).getRecordTypeId();
                thisQuote.SBQQ__Status__c = STATUS_APPROVED;
             
            }
            catch (Exception e) {}
        }
    }

    private static void submitQuoteForApproval(List<SBQQ__Quote__c> listNewQuoteRecords){
        if (listNewQuoteRecords.size() == 1) {
            SBQQ__Quote__c thisQuote = listNewQuoteRecords[0];

            if (    thisQuote.ApprovalStatus__c != STATUS_PENDING 
                    && thisQuote.ApprovalStatus__c != STATUS_APPROVED
                    && thisQuote.qtcApprovalStatusManual__c == STATUS_PENDING) {
                System.debug('Submitting Quote for Approval');
                try 
                {
                    SBAA.ApprovalAPI.submit(thisQuote.id, SBAA__Approval__c.Quote__c);
                }
                catch (Exception e)
                {
                    thisQuote.qtcApprovalError__c = e.getStackTraceString();
                    thisQuote.qtcApprovalStatusManual__c = 'Error';
                    thisQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( RECORD_TYPE_DRAFT ).getRecordTypeId();
                    thisQuote.SBQQ__Status__c = STATUS_DRAFT; 
                    System.debug('ERROR SUBMITTING: ' + e.getStackTraceString());
                    update thisQuote;
                }
            }

        }
    }

    private void syncFulfillmentOrders(){
        List<SBQQ__Quote__c> listQuotesToSync = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c thisQuote : listNewRecords){
            SBQQ__Quote__c oldQuote = mapOldRecords.get( thisQuote.Id );
            if( thisQuote.SBQQ__Type__c == TYPE_AMENDMENT ){
                
                if( thisQuote.qtc_SyncFulfillmentOrderDateTime__c != oldQuote.qtc_SyncFulfillmentOrderDateTime__c
                    && oldQuote.qtc_SyncFulfillmentOrderDateTime__c == null 
                    && (thisQuote.AutoPay_Setup__c == 'True' || thisQuote.AutoPay_Setup__c == 'Manual')){
                        listQuotesToSync.add( thisQuote );
                    
                }
            }
            else {
                if(thisQuote.qtc_SyncFulfillmentOrderDateTime__c != null 
                    && thisQuote.qtc_SyncFulfillmentOrderDateTime__c != oldQuote.qtc_SyncFulfillmentOrderDateTime__c 
                    && (thisQuote.AutoPay_Setup__c == 'True' || thisQuote.AutoPay_Setup__c == 'Manual')){
                    listQuotesToSync.add( thisQuote );
                }
            }
        }
        if( !listQuotesToSync.isEmpty() ){
            FulfillmentOrderService syncService = new FulfillmentOrderService( listQuotesToSync );
            syncService.run();
        }
    }

    public static List< SBQQ__Quote__c> amendedQuotesCancelledSelector( Set<Id> setOriginalQuoteIds){
        if( setOriginalQuoteIds.isEmpty() ){
            return null;
        }
        return [    SELECT Id, qtc_Cancelled__c, SBQQ__Ordered__c, SBQQ__Type__c, SBQQ__OriginalQuote__c
                    FROM SBQQ__Quote__c
                    WHERE SBQQ__OriginalQuote__c IN : setOriginalQuoteIds
                        AND SBQQ__Type__c = :TYPE_AMENDMENT
                        AND SBQQ__Ordered__c = true
                        AND qtc_Cancelled__c = true];
    }
    public static Map<Id, qtc_PaymentsApproval__c> paymentsApprovalSelector(Set<Id> setPaymentsApprovalId){
        return new Map<Id, qtc_PaymentsApproval__c>( [SELECT Id, ApprovalStatus__c FROM qtc_PaymentsApproval__c WHERE Id IN :setPaymentsApprovalId]);
    }

    public static Boolean isAEPPChildAndParentValid(SBQQ__Quote__c thisQuote, List<SBQQ__Quote__c> listCancelledQuotes){
        Boolean isValid = true;
        if( thisQuote.qtc_Multi_Site__c == true
            && thisQuote.qtc_Multi_Site_Type__c == MULTI_SITE_TYPE_AE_PP
            && thisQuote.qtc_Multi_Site_Relationship__c == MULTI_SITE_RELATIONSHIP_CHILD
            && thisQuote.qtc_Payments_Type__c != PAYMENT_TYPE_NO_PAYMENT
            && listCancelledQuotes != null
            && !listCancelledQuotes.isEmpty()){

            isValid  = false;
            
        }
        return isValid;
    }
   
     public static string ExistingQuotesRelatedToContract(Set<Id> setContractids){
       Map<id,set<string>> quotesRelatedtoContract = new Map<id,set<string>>();
       string quoteName = '';
       set<string>contractids = new set<string>();
       for(SBQQ__Quote__c Qute: [SELECT Id,Name,SBQQ__Status__c ,(select id,SBQQ__Quote__c, SBQQ__Contracted__c from SBQQ__Orders__r where SBQQ__Contracted__c = false ),qtc_Cancelled__c,SBQQ__MasterContract__c,Deliver_To_Site__c, SBQQ__Ordered__c, SBQQ__Type__c, SBQQ__OriginalQuote__c
                    FROM SBQQ__Quote__c
                    WHERE  SBQQ__Type__c = :TYPE_AMENDMENT
                          
                          AND SBQQ__MasterContract__c IN: setContractids  AND SBQQ__Status__c!='Expired']){
                            if(Qute.SBQQ__Orders__r.size() > 0){          
                                contractids.add(Qute.Name);
                               
                                quotesRelatedtoContract.put(Qute.SBQQ__MasterContract__c,contractids);
                            }
                              else if(Qute.SBQQ__Orders__r.size() == 0 && Qute.SBQQ__Ordered__c == false){
                                  contractids.add(Qute.Name);
                               
                                  quotesRelatedtoContract.put(Qute.SBQQ__MasterContract__c,contractids);
                              }
            
            
        }
        system.debug('-------quotesRelatedtoContract'+quotesRelatedtoContract);
        for(id cnId : quotesRelatedtoContract.keyset()){
            
            if(quotesRelatedtoContract.get(cnId).size() > 0){
                set<string> temp = quotesRelatedtoContract.get(cnId);
                for(string s:temp){
                   quoteName = s;
                    break;
                    
                }
            }
        }
         system.debug('-------quoteName'+quoteName);
        return quoteName;
       
     }


}