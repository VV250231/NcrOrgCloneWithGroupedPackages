public with sharing class QuoteTriggerHandler {
    final string DI_USERS_PROFILE = '62 DI Account Manager';
    
    //update zuora subscription and zuora account and opp when approval status change on quote
    public void UpdateZuoraSubscriptionOnApprovalChange(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> oldMap){
        if(NewQuoteList.size() == 1){
            zqu__Quote__c qt = NewQuoteList[0];
            zqu__Quote__c oldQt = oldMap.get(qt.Id);
            if(oldQt.DI_Approval_Status__c != qt.DI_Approval_Status__c) {
                //when status changed to approved or away from approved
                if(oldQt.DI_Approval_Status__c == 'Approved' || qt.DI_Approval_Status__c == 'Approved') {
                    new ZquoteExtUtil().onApprovalStatusChange(qt);
                }
            }
            if(oldQt.zqu__Status__c != qt.zqu__Status__c && qt.zqu__Status__c == 'Sent to Z-Billing') 
            {
                new QuoteOnSubmitTriggerHandler().onSubmit(qt);
            }
        }
    }
    
    //send a notification to opp sales team when quote stage is changed to rejected
    public void sendMailOnReject(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> oldMap){
        set<id> oppID = new set<id>();
        list <String> toAddresses;
        Map<id,list<string>> oppIdwithAddressMap = new Map<id,list<string>>();
        for(zqu__Quote__c obj : NewQuoteList){
            if(obj.zqu__Opportunity__c != null){
                oppID.add(obj.zqu__Opportunity__c);
            }
        }
        //SC2015_AGL-5809
        //list <OpportunityTeamMember> otmList = [select id, user.name, user.email from OpportunityTeamMember where opportunityid in : oppID];
        list <OpportunityTeamMember> otmList = [select id, user.name, user.email,opportunityid from OpportunityTeamMember where opportunityid in : oppID];
        for(id opid : oppID){
            toAddresses = new list<string>();
            for(OpportunityTeamMember otm : otmList){
                if(opid == otm.opportunityid){
                    toAddresses.add(otm.user.email);
                }
            }
            if(toAddresses != null){
                oppIdwithAddressMap.put(opid, toAddresses);
            }
        }
        for(zqu__Quote__c obj : NewQuoteList){
            if(obj.Quote_Stage__c=='Rejected' && (obj.Quote_Stage__c != oldMap.get(obj.id).Quote_Stage__c)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(oppIdwithAddressMap.get(obj.zqu__Opportunity__c));
                mail.setSubject('Quote : '+' '+ obj.name + ' ' + 'Rejected');
                mail.setPlainTextBody('Opportunity Sales Team-'+'\r\n\r\n'+'Please review quote '+' '+ obj.name + ' ' + 'as it has been rejected for the following reason - '+'\r\n' +'\r\n' +'Reason : '+obj.Status_Details__c+'\r\n' + '\r\n' + 'https://ncr.my.salesforce.com/'+ obj.id + '\r\n\r\n' + 'Regards' + '\r\n' + 'NSC Administrator');
                Messaging.sendEmailResult[] sendTerminatedEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }     
    }
    
    /*==============================================================================
     | Description:  This will be invoked when "Scheduled Class : UpdateSiteonQuote"
     |               changes the main account for a zQuote record
     | Purpose    :  The trigger will call another future class which will
     |               change the connection for others quotes of same opportunity
     *==============================================================================*/
    public void UpdateOldAccountId(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> newMap, Map<id,zqu__Quote__c> oldMap){
        for (zqu__Quote__c Quote: NewQuoteList){
            if (newMap.get(Quote.id).zqu__Account__c != oldMap.get(Quote.id).zqu__Account__c){
                Quote.Old_Account_Id__c = oldMap.get(Quote.id).zqu__Account__c;
                if (!ProcessorControl.inFutureContext){
                    if (Quote.zqu__Opportunity__c != null){
                        UpdateQuoteRelatedObjects.myMethod(Quote.id, Quote.zqu__Account__c, Quote.zqu__Opportunity__c);
                    }
                    if (Quote.zqu__Account__c != null){
                        UpdateQuoteRelatedObjects.FutureMethodUpdateSiteonQuote(Quote.Old_Account_Id__c, Quote.zqu__Account__c, Quote.CreatedById, Quote.OwnerId, Quote.Name, Quote.id);
                    }
                }
            }
        }
    }
    
	//calcQuoteSharingForAccount
    public void afterInsertcalcQuoteSharingForAccount(List<zqu__Quote__c> NewQuoteList){
        Set<Id> FSProfiles = new Set<Id>{[SELECT Id,Name FROM Profile WHERE Name=:DI_USERS_PROFILE LIMIT 1].get(0).Id};
        Map<ID, ID> quoteOwnerIdMap = new Map<ID, ID>();
        Map<Id, Id> quoteAccountIdMap = new  Map<Id, Id>();
        for(zqu__Quote__c quote : NewQuoteList) {
            if(quote.zqu__Account__c != NULL) {
                quoteOwnerIdMap.put(quote.Id, quote.ownerId);    
                quoteAccountIdMap.put(quote.Id, quote.zqu__Account__c);
            }
        }
        if(!quoteOwnerIdMap.IsEmpty()) {
            Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, ProfileId FROM User WHERE Id IN :quoteOwnerIdMap.values()]);
            for(String quoteId : quoteOwnerIdMap.keySet()) {
                String quoteOwnerId = quoteOwnerIdMap.get(quoteId);
                String quoteOwnerProfileId = ownerMap.get(quoteOwnerId).ProfileId ; 
                
                if(!FSProfiles.contains(quoteOwnerProfileId)){
                    quoteAccountIdMap.remove(quoteId );
                } 
            }
        } 
        if(!quoteAccountIdMap.isEmpty()) {
            ZquoteExtUtil.shareQuoteWithAccandAccTeam(quoteAccountIdMap);
        }
    }
    
    //calcQuoteSharingForAccount
    public void afterUpdatecalcQuoteSharingForAccount(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> oldMap){
        Map<Id, Id> quoteAccountIdMap = new  Map<Id, Id>();
        Set<ID> quoteOwnerIds = new Set<ID>();
        
        for(zqu__Quote__c quote :NewQuoteList) {
            if((quote.zqu__Account__c != NULL) && (quote.OwnerId != oldMap.get(quote.Id).OwnerId)) {
                quoteAccountIdMap.put(quote.Id, quote.zqu__Account__c);
                quoteOwnerIds.add(oldMap.get(quote.Id).OwnerId);
                quoteOwnerIds.add(quote.ownerId);
            }
        }
        
        if(!quoteOwnerIds.IsEmpty()) {
            Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, ProfileId, Profile.Name FROM User WHERE Id IN :quoteOwnerIds]);
            for(zqu__Quote__c quote :NewQuoteList) {
                if(quoteAccountIdMap.get(quote.Id) != null) { // if ownerId of qoute has changed
                    String oldOwnerProfile = ownerMap.get(oldMap.get(quote.Id).OwnerId).Profile.Name;
                    String newOwnerProfile = ownerMap.get(quote.ownerId).Profile.Name;
                    // if new owner has same profile and not  DI_USERS_PROFILE, then not share with Account Owner & Team
                    if((oldOwnerProfile == newOwnerProfile)  || (newOwnerProfile != DI_USERS_PROFILE)) {
                        quoteAccountIdMap.remove(quote.Id);
                    } 
                }
            }
        } 
        if(!quoteAccountIdMap.isEmpty()) {
            ZquoteExtUtil.shareQuoteWithAccandAccTeam(quoteAccountIdMap);
        }
    }
    
    //prevent delete when status != New
    public void QuotePreventDelete(List<zqu__Quote__c> OldQuoteList){
        for(zqu__Quote__c q : OldQuoteList){
            if(q.zqu__Status__c != 'New'){
                q.addError(System.Label.QuotePreventDelete);
            }
        }
    }
    
    //Update And Delete opportunity line item from Opportunity
    public void UpdateAndDeleteOLIfromOpp(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> oldMap){
        List<Id> oppIds = new List<Id>();
        Map<Id, Id> quoteOppMap = new Map<Id, Id>();
        for(zqu__Quote__c q : NewQuoteList) {
            if(!q.Is_NCR_Quote__c) {
                if(q.zqu__Primary__c != oldMap.get(q.Id).zqu__Primary__c) {
                    if (q.zqu__Primary__c){
                        quoteOppMap.put(q.Id, q.zqu__Opportunity__c);
                    }else if (q.zqu__Opportunity__c != null){
                        oppIds.add(q.zqu__Opportunity__c);
                    } 
                } 
            }
        }   
        if (!quoteOppMap.isEmpty()) {
            new ZuoraChargeUtil().updateOppLineItems(quoteOppMap, true);
        }
        if(!oppIds.isEmpty()) {
            new ZuoraChargeUtil().deleteOLIsFromOpp(oppIds);
        } 
    }
    
    //make other quote primary on same opportunity
    public void afterDeletePrimaryQuoteOnOpp(List<zqu__Quote__c> OldQuoteList){
        Set<Id> oppIds = new Set<Id>();
        List<zqu__Quote__c> updateQoutes = new List<zqu__Quote__c>();            
        for(zqu__Quote__c q : OldQuoteList) {
            if(!q.Is_NCR_Quote__c) {
                if(q.zqu__Opportunity__c != null && q.zqu__Primary__c) {
                    oppIds.add(q.zqu__Opportunity__c);
                }
            }    
        }
        if(!oppIds.isEmpty()) {
            List<Opportunity> oppList = [SELECT Id, (SELECT Id, zqu__Primary__c FROM zqu__Quotes__r ORDER BY createddate DESC LIMIT 1) FROM Opportunity WHERE Id IN :oppIds];            
            for (Opportunity opp : oppList) {
                if (opp.zqu__Quotes__r != null && opp.zqu__Quotes__r.size() > 0) {
                    zqu__Quote__c qt = opp.zqu__Quotes__r.get(0);
                    qt.zqu__Primary__c = true; 
                    updateQoutes.add(qt);
                    oppIds.remove(opp.Id);
                }
            }
            if(!updateQoutes.isEmpty()) update updateQoutes;
            new ZuoraChargeUtil().deleteOLIsFromOpp(new List<Id>(oppIds));
        }
    }
    
    //update opportunity line items
    public void afterUndeleteupdateOppLineItems(List<zqu__Quote__c> NewQuoteList){
        Map<Id, Id> quoteOppMap = new Map<Id, Id>();
        for(zqu__Quote__c q : NewQuoteList) {
            if(!q.Is_NCR_Quote__c) {
                if(q.zqu__Opportunity__c != null && q.zqu__Primary__c) {
                    quoteOppMap.put(q.Id, q.zqu__Opportunity__c);
                }  
            }  
        } 
        if (!quoteOppMap.isEmpty()) {
            new ZuoraChargeUtil().updateOppLineItems(quoteOppMap, true);
        } 
    }
    
    // This Trigger will handle the Custom Payment Term and Subscription Group changes and show the error accordingly
    //These changes are done due to new CMDM Project
    public void showErrorOnQuoteWizard(List<zqu__Quote__c> NewQuoteList){
        Set<String> listOfBillingId = new Set<String>();
        List<Zuora__CustomerAccount__c> listOfBillingAcc = new List<Zuora__CustomerAccount__c>();
        List<zqu__Quote__c> listOfQuoteWithSameBillingAccount = new List<zqu__Quote__c>();
        set<id> recordTypeIds = new set<id>();
        for(zqu__Quote__c quote : NewQuoteList){
            if(quote.zqu__InvoiceOwnerId__c != null){
                listOfBillingId.add(quote.zqu__InvoiceOwnerId__c );
            }
        }
        list<RecordType> recordtypeList = [Select id, Name from RecordType where SOBJECTTYPE='zqu__Quote__c'];
        for(RecordType RecordId : recordtypeList){
            if( RecordId.Name == 'Default' ){
                recordTypeIds.add(RecordId.Id);
            }
        }
        
        if(listOfBillingId.size() > 0){
            listOfBillingAcc = [SELECT Id,Zuora__AccountNumber__c,Subscription_Group__c,Zuora__Batch__c,Zuora__Zuora_Id__c, Zuora__PurchaseOrderNumber__c FROM Zuora__CustomerAccount__c where Zuora__Zuora_Id__c IN :listOfBillingId];
            listOfQuoteWithSameBillingAccount = [select id,Name,zqu__Number__c,zqu__InvoiceOwnerId__c ,Subscription_Group__c from zqu__Quote__c where zqu__InvoiceOwnerId__c IN: listOfBillingId  and zqu__Status__c != 'Sent to Z-Billing' and  Subscription_Group__c  != Null and RecordTypeId IN : recordTypeIds];
        }
        
        if(listOfBillingAcc.size() > 0){
            for(zqu__Quote__c quote : NewQuoteList){
                if(Trigger.isInsert || (Trigger.isUpdate && quote.zqu__Status__c != 'Sent to Z-Billing')){
                    for(Zuora__CustomerAccount__c temp : listOfBillingAcc){
                        if(quote.zqu__InvoiceOwnerId__c == temp.Zuora__Zuora_Id__c){
                            if(quote.Subscription_Group__c == null && temp.Subscription_Group__c != null){
                                quote.Subscription_Group__c = temp.Subscription_Group__c;
                            }
                            else if(quote.Subscription_Group__c == null && quote.zqu__SubscriptionType__c == 'New Subscription' &&  temp.Subscription_Group__c == null && String.isBlank(temp.Subscription_Group__c)){
                                quote.addError(System.Label.subscriptionGroupError);
                            }
                        }
                    }
                    if(listOfQuoteWithSameBillingAccount.size()>0){
                        for(zqu__Quote__c q :listOfQuoteWithSameBillingAccount){
                            if(quote.zqu__InvoiceOwnerId__c == q.zqu__InvoiceOwnerId__c){
                                if(quote.Subscription_Group__c != null && quote.Subscription_Group__c != q.Subscription_Group__c && quote.Skip_Sub_Group_Warning__c == false){
                                    quote.addError(System.Label.OverrideSubscriptionGroupError + q.zqu__Number__c);
                                }
                            } 
                        }
                    }
                }
            }
        }
    }
    
    //populate Bundle Name, Status, Opportunity Owner Email,Total Amendment One Time Fee, Total Amendment Monthly Fee on Quote object.
    public void beforeInsertUpdateQuoteBundleDetail(List<zqu__Quote__c> NewQuoteList){
        Set<ID> oppIdSet = new Set<ID>();
        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>();
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
        String amendmentRecordTypeId = dsr.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        Map<ID, String> quoteIdSubIdMap = new  Map<ID, String>();
        
        if (Trigger.isInsert) {
            for (zqu__Quote__c zquote : NewQuoteList) {
                if(zquote.zqu__Opportunity__c != NULL) {
                    oppIdSet.add(zquote.zqu__Opportunity__c);
                }
            }
        }
        if(Trigger.isUpdate) {
            for (zqu__Quote__c zquote : NewQuoteList) {
                if(zquote.zqu__Opportunity__c != NULL) {
                    oppIdSet.add(zquote.zqu__Opportunity__c);
                }
                // Calc Amendment Quote Fixed and Monthly Fee
                if(zquote.RecordTypeId == amendmentRecordTypeId && zquote.zqu__ExistSubscriptionID__c != NULL) {
                    quoteIdSubIdMap.put(zquote.Id, zquote.zqu__ExistSubscriptionID__c);
                }
            }
        }
        Map<ID, Map<String, Decimal>> quoteOneTimeandMonthlyMap = new Map<ID, Map<String, Decimal>>();
        if(quoteIdSubIdMap != null && !quoteIdSubIdMap.isEmpty()){
            quoteOneTimeandMonthlyMap = ZquoteExtUtil.calcQuoteOneTimeandMonthlyaFee(quoteIdSubIdMap);
        }
        if(!oppIdSet.isEmpty()) {
            oppMap = new Map<ID, Opportunity>([SELECT Id, Owner.Email FROM Opportunity WHERE Id IN :oppIdSet]);
        }
        for (zqu__Quote__c zquote : NewQuoteList) {
            Opportunity parentOpp = oppMap.get(zquote.zqu__Opportunity__c);
            if(parentOpp != NULL) {  
                zquote.Opportunity_Owner_Email__c = parentOpp.Owner.Email;
            } 
            if(quoteOneTimeandMonthlyMap.size() > 0 && zquote.RecordTypeId == amendmentRecordTypeId && zquote.zqu__ExistSubscriptionID__c != NULL) {
                zquote.Total_Amendment_One_Time_Fee__c = quoteOneTimeandMonthlyMap.get(zquote.Id).get('totalOneTimeFee').setScale(2).toPlainString(); 
                zquote.Total_Amendment_Monthly_Fee__c = quoteOneTimeandMonthlyMap.get(zquote.Id).get('totalMonthlyFee').setScale(2).toPlainString();   
            } 
        }
    }
    
    //populate Bundle Name, Status, Opportunity Owner Email,Total Amendment One Time Fee, Total Amendment Monthly Fee on Quote object.
    public void afterUpdateQuoteBundleDetail(List<zqu__Quote__c> NewQuoteList,Map<id,zqu__Quote__c> newMap, Map<id,zqu__Quote__c> oldMap){
        Set<ID> updatedQuoteIds = new Set<ID>();
        List<zqu__QuoteRatePlanCharge__c> updateQRPCList = new List<zqu__QuoteRatePlanCharge__c>();
        //Set<String> chargetTypeSet = new Set<String>{'One-Time', 'Recurring','Usage'}; 
        for (zqu__Quote__c zquote : NewQuoteList) {
            if (oldMap.get(zquote.Id).BundleNameNew__c != zquote.BundleNameNew__c ) {
                updatedQuoteIds.add(zquote.Id);   
            }
        }
        if(!updatedQuoteIds.isEmpty()) {
            List<zqu__QuoteRatePlanCharge__c> quoteRatePlanChrgList = [SELECT Id, BundleName__c,zqu__ChargeType__c,zqu__QuoteRatePlan__c,zqu__QuoteRatePlan__r.zqu__Quote__c,zqu__ProductRatePlanCharge__r.ExcludefromBundle__c
                                                                       FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__c IN(SELECT Id FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c IN :updatedQuoteIds)];
            if(!quoteRatePlanChrgList.isEmpty()) {
                // check for Bundle Changes on quote and create updated zqu__QuoteRatePlanCharge__c list 
                for(zqu__QuoteRatePlanCharge__c qrpc :quoteRatePlanChrgList) {
                    if(qrpc.zqu__QuoteRatePlan__c != NULL && qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c != NULL && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c)) {
                        zqu__Quote__c parentQuote = newMap.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c);
                        if(qrpc.zqu__ProductRatePlanCharge__r.ExcludefromBundle__c == 'No' && parentQuote.BundleNameNew__c != 'Not a Bundle') /* && chargetTypeSet.contains(qrpc.zqu__ChargeType__c)*/{
                            qrpc.BundleName__c = parentQuote.BundleNameNew__c ;
                            //*** this is commnted for backup in case needed again qrpc.BundleName__c = qrpc.zqu__ChargeType__c != 'Usage'? parentQuote.BundleNameNew__c + ' ' +  qrpc.zqu__ChargeType__c:parentQuote.BundleNameNew__c + ' ' +'Usage Fee';        
                        } else {
                            qrpc.BundleName__c = '';
                        }  
                        updateQRPCList.add(qrpc);
                    }
                }
                if(!updateQRPCList.isEmpty()) {
                    try {
                        update updateQRPCList;
                    }catch(Exception e) {
                        NewQuoteList[0].addError('Quote_ex_' + e.getMessage());
                    }   
                }
            }
        } 
    }
    
    //SC2015_AGL-4659 - Set SAD to correct date when the quote enters an approved status
    public void setServiceActivationDate(List<zqu__Quote__c> NewQuoteList){
        for(zqu__Quote__c quote : NewQuoteList) {
            // Auto Activate Quotes where no implementation action is required on the Quote Products
            if(quoteHasBeenApproved(quote) && quote.Is_NCR_Quote__c) {
                //zqu__QuoteRatePlan__c quote.All_Deactivation_Products__c = quote.All_Deactivation_Quote_Product__c !=0?False:True; //DIQuoteUtil.hasAllDeactivationProducts(quote.Id);
                boolean isExistingProuct = DIQuoteUtil.hasAllDeactivationProducts(quote.Id);
                if(isExistingProuct == true && quote.zqu__Service_Activation_Date__c == null) { 
                    quote.zqu__Service_Activation_Date__c = QuoteActivationDates.getServiceActivationDate(quote, quote.zqu__StartDate__c); 
                    if(quote.zqu__Service_Activation_Date__c < quote.zqu__StartDate__c) {
                        quote.zqu__StartDate__c = quote.zqu__Service_Activation_Date__c; 
                    }
                }
            }
        }
    }
    
    private boolean quoteHasBeenApproved(zqu__quote__c quote) {
        return (quote.zqu__Status__c == 'QA Processing Complete' || quote.zqu__Status__c == 'Not applicable');
    }
    
    //send the eligible quote to Zuora instead of manually hitting the send to z billing button.
    public void AutomateSendToZBilling(List<zqu__Quote__c> NewQuoteList){
        List<id> lstEligibleQuoteIds = new List<id>() ;
        List<zqu__Quote__c > lstQuotesToBeUpdated = new  List<zqu__Quote__c >() ;
        List<zqu__Quote__c > lstQuoteForUpdatingErrorMsg = new List<zqu__Quote__c >();

        //check and collect quote which are elible for sending to z-billing
        for(zqu__Quote__c objZQuotes : NewQuoteList) {
            if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter && (objZQuotes.zqu__Status__c == 'QA Processing Complete' || objZQuotes.zqu__Status__c == 'Not applicable') && objZQuotes.Is_NCR_Quote__c == true &&  String.isNotBlank(objZQuotes.zqu__ZuoraAccountID__c)){  
             
                //updating the quote status with new whcih is required for send it to z - billing
                zqu__Quote__c objTempQuotes = new zqu__Quote__c();
                
                //Added for SC2015_AGL-4530     
                objTempQuotes.ImplementationRequired__c = 'No';
                if(objZQuotes.Set_Implementation_Required__c != 0) {                
                    objTempQuotes.ImplementationRequired__c = 'Yes'; 
                }
                //below code added for SC2015_AGL-5895
                boolean isAmndRemoval = false;
                isAmndRemoval = DIQuoteUtil.isRemovalamendments(objZQuotes.Id);
                //Added for SC2015_AGL-4688
                if(objZQuotes.zqu__SubscriptionType__c == 'Cancel Subscription' || isAmndRemoval ||
                   (objZQuotes.Bill_To_Site_Number__c == null && objZQuotes.Ship_To_Site_Number__c == null && objZQuotes.zqu__Service_Activation_Date__c != null && !isAmndRemoval)) {
                    //setting to 'New' will get picked up in the future class for quotes zbilling and sent to zuora
                    objTempQuotes.zqu__Status__c = 'New' ;
                    objTempQuotes.id = objZQuotes.id ;
                    objTempQuotes.Error_Message_When_Z_Billing_Fail__c = null ;
                    lstQuotesToBeUpdated.add(objTempQuotes); 
                }
            }
        }
   
        // updating the quote status with new whcih is required for send it to z - billing
        if(lstQuotesToBeUpdated != null && lstQuotesToBeUpdated.size() > 0 && lstQuoteForUpdatingErrorMsg.size() == 0) {
            try {
                Database.SaveResult[] lstSaveResult = Database.Update(lstQuotesToBeUpdated, false);
                for(Database.SaveResult objSR : lstSaveResult ) {
                    if(objSR.isSuccess()) {
                        lstEligibleQuoteIds.add(objSR.getId());
                        System.debug('+++ Successfully inserted Quote Id' + objSR.getId());
                    }
                }
            }catch(Exception e) {
                System.debug('+++The following exception has occurred in trigger: ' + e.getMessage());
                System.debug('++++ ***tani Inside Catch print stack trace Demo'+e.getStackTraceString()) ;
            }
        }
        
        // call send to z billing functionality for each quote
        if(lstEligibleQuoteIds != null && lstEligibleQuoteIds.size() > 0) {
            //Calculating ACV of on charges before doing callout
            List<zqu__Quote__c> listTosendACV  = [Select Id, Name from zqu__Quote__c where Id IN :lstEligibleQuoteIds];
            if(listTosendACV != null && listTosendACV.size() > 0){
                QuoteWrapper calACV = new QuoteWrapper(listTosendACV,false);
                calACV.calculateACV();
            }
            FutureClassForQuotesZbilling.sendToZBilling(lstEligibleQuoteIds);
        }
    }
    
    //reporting fields from billing account
    public void ReportingFieldsFromBillingAccount(List<zqu__Quote__c> NewQuoteList){
        
        List<Zuora__CustomerAccount__c> BillTo = new List<Zuora__CustomerAccount__c>();
        List<Zuora__CustomerAccount__c> ShipTo = new List<Zuora__CustomerAccount__c>();
        Map<String , Zuora__CustomerAccount__c> ShipToAccountMap = new Map<String , Zuora__CustomerAccount__c> ();
        Map<String , Zuora__CustomerAccount__c> BillToAccountMap = new Map<String , Zuora__CustomerAccount__c> ();
        List<String> ZuoraAccountIdList = new List<String>();
        List<String> InvoiceOwnerIdList = new List<String>();
        Set<ID> oppIdSet = new Set<ID>();
        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>();
        //ship to : subscription owner : zqu__ZuoraAccountID__c 
        //bill to : invoice owner : zqu__InvoiceOwnerId
    
        if(CheckRecursive.runCopyBillingAccountOnce()) {
            for (zqu__Quote__c Quote : NewQuoteList) {
                if(Quote.zqu__ZuoraAccountID__c != NULL) {
                    ZuoraAccountIdList.add(Quote.zqu__ZuoraAccountID__c);
                }
                if(Quote.zqu__Opportunity__c != NULL){
                    oppIdSet.add(Quote.zqu__Opportunity__c);
                }
                if(Quote.zqu__InvoiceOwnerId__c != NULL) {
                    InvoiceOwnerIdList.add(Quote.zqu__InvoiceOwnerId__c);
                }
            }
            if(ZuoraAccountIdList != null) {
                ShipTo = [select id , name  , Aloha_Key__c , Enterprise_ID__c , ERPSiteNumber__c , NMS_Lead__c , NMS_MID__c , POS_System__c , Reseller_POS_Sales_Rep__c , Zuora__External_Id__c , Address__c , City__c , State__c , Zuora__BillToPostalCode__c from Zuora__CustomerAccount__c where Zuora__External_Id__c IN : ZuoraAccountIdList];
            }
            if(InvoiceOwnerIdList != null) {
                BillTo = [select id , name , Zuora__MRR__c , Zuora__Currency__c , ERPSiteNumber__c , ORGCode__c , Zuora__External_Id__c , Address__c , City__c , State__c , Zuora__BillToPostalCode__c from Zuora__CustomerAccount__c where Zuora__External_Id__c IN : InvoiceOwnerIdList];
            }
            
            if(ShipTo != null) {
                for (Zuora__CustomerAccount__c ShipToAccount : ShipTo) {
                    ShipToAccountMap.put(ShipToAccount.Zuora__External_Id__c, ShipToAccount);
                }
            }
            
            if(BillTo != null) {
                for (Zuora__CustomerAccount__c BillToAccount : BillTo) {
                    BillToAccountMap.put(BillToAccount.Zuora__External_Id__c, BillToAccount);
                }
            }
            if(!oppIdSet.isEmpty()) {
                oppMap = new Map<ID, Opportunity>([SELECT Id, Owner.Email FROM Opportunity WHERE Id IN :oppIdSet]);
            }
            
            for(zqu__Quote__c Quote : NewQuoteList) {
                Opportunity parentOpp = oppMap.get(Quote.zqu__Opportunity__c);
                if(parentOpp != NULL) {
                    Quote.Opportunity_Owner_Email__c = parentOpp.Owner.Email;
                }
                if(BillToAccountMap.keyset().size() != 0) {
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Name != null) {
                        Quote.Reporting_BillTo_Billing_Account_Name__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Name ;
                    } else {
                        Quote.Reporting_BillTo_Billing_Account_Name__c = '' ;
                    }
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Zuora__MRR__c != null) {
                        Quote.Reporting_BillTo_CMRR__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Zuora__MRR__c ;
                    } else {
                        Quote.Reporting_BillTo_CMRR__c = 0 ;
                    }
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Zuora__Currency__c != null) {
                        Quote.Reporting_BillTo_Currency__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Zuora__Currency__c ;
                    } else {
                        Quote.Reporting_BillTo_Currency__c = '' ;
                    }
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).ERPSiteNumber__c != null) {
                        Quote.Reporting_BillTo_ERPSiteNumber__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).ERPSiteNumber__c ;
                    } else {
                        Quote.Reporting_BillTo_ERPSiteNumber__c   = '' ;
                    }
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).ORGCode__c != null) {
                        Quote.Reporting_BillTo_ORGCode__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).ORGCode__c ;
                    } else {
                        Quote.Reporting_BillTo_ORGCode__c = '' ;
                    } 
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Id != null) {
                        Quote.Bill_To_Lookup__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Id ;
                    } else {
                        Quote.Bill_To_Lookup__c = null ;
                    }
                    if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c) != null && BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Address__c != null) {
                        Quote.Reporting_BillToAccountAddress__c = BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Address__c ;
                        if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).City__c != null) {
                            Quote.Reporting_BillToAccountAddress__c = Quote.Reporting_BillToAccountAddress__c + '\n' + BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).City__c;
                        }
                        if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).State__c != null) {
                            Quote.Reporting_BillToAccountAddress__c = Quote.Reporting_BillToAccountAddress__c + ',' + ' ' + BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).State__c;
                        }
                        if(BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Zuora__BillToPostalCode__c != null) {
                            Quote.Reporting_BillToAccountAddress__c = Quote.Reporting_BillToAccountAddress__c + ' ' + BillToAccountMap.get(Quote.zqu__InvoiceOwnerId__c).Zuora__BillToPostalCode__c;
                        }           
                    } else {
                        Quote.Reporting_BillTo_ORGCode__c = '' ;
                    }
                }
                
                if(ShipToAccountMap != null && ShipToAccountMap.size() > 0) {
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Aloha_Key__c != null) {
                        Quote.Reporting_ShipTo_Aloha_Key__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Aloha_Key__c ;
                    } else {
                        Quote.Reporting_ShipTo_Aloha_Key__c = '' ;
                    }        
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Name != null) {
                        Quote.Reporting_ShipTo_Billing_Account_Name__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Name ;
                    } else {
                        Quote.Reporting_ShipTo_Billing_Account_Name__c = '' ;
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Enterprise_ID__c != null) {
                        Quote.Reporting_ShipTo_Enterprise_ID__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Enterprise_ID__c ;
                    } else {
                        Quote.Reporting_ShipTo_Enterprise_ID__c = '' ;
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null &&  ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).ERPSiteNumber__c != null) {
                        Quote.Reporting_ShipTo_ERPSiteNumber__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).ERPSiteNumber__c ;
                    } else {
                        Quote.Reporting_ShipTo_ERPSiteNumber__c =   '' ;
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).NMS_Lead__c != null) {
                        Quote.Reporting_ShipTo_NMS_Lead__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).NMS_Lead__c ;
                    } else {
                        //Quote.Reporting_ShipTo_NMS_Lead__c = null ;
                        System.debug('Method : Reporting_ShipTo_NMS_Lead__c');//SC2015_AGL-5809
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).POS_System__c != null) {
                        Quote.Reporting_ShipTo_NMS_MID__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).NMS_MID__c ;
                    } else {
                        Quote.Reporting_ShipTo_NMS_MID__c = '' ;
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).POS_System__c != null) {
                        Quote.Reporting_ShipTo_POS_System__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).POS_System__c ;
                    } else {
                        Quote.Reporting_ShipTo_POS_System__c = '';
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Reseller_POS_Sales_Rep__c != null) {
                        Quote.Reporting_ShipTo_Reseller_POS_Sales_Rep__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Reseller_POS_Sales_Rep__c ;
                    } else {
                        Quote.Reporting_ShipTo_Reseller_POS_Sales_Rep__c = '' ;
                    }  
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Id != null) {
                        Quote.Ship_To_Lookup__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Id ;
                    } else {
                        Quote.Ship_To_Lookup__c = null;
                    }
                    if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c) != null && ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Address__c != null) {
                        Quote.Reporting_ShipToAccountAddress__c = ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Address__c ;
                        if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).City__c != null) {
                            Quote.Reporting_ShipToAccountAddress__c = Quote.Reporting_ShipToAccountAddress__c + '\n' + ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).City__c;
                        }
                        if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).State__c != null) {
                            Quote.Reporting_ShipToAccountAddress__c = Quote.Reporting_ShipToAccountAddress__c + ',' + ' ' + ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).State__c;
                        }
                        if(ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Zuora__BillToPostalCode__c != null) {
                            Quote.Reporting_ShipToAccountAddress__c = Quote.Reporting_ShipToAccountAddress__c + ' ' + ShipToAccountMap.get(Quote.zqu__ZuoraAccountID__c).Zuora__BillToPostalCode__c;
                        }
                    } else {
                        Quote.Reporting_BillTo_ORGCode__c = '' ;
                    }
                }
            }
        }
    }
    
    //insert quote product when quote is of cancellation type
    public void insertQuoteProduct(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> oldMap){
        Map<String,String> mapZProExSubId = new Map<String,String>(); // map External Zuora ProductId and Existing Sub Id
        Map<String,zqu__Quote__c > mapExSubIdQObj = new Map<String,zqu__Quote__c >(); // existing subscription Id and quote obj
        Map<String,String> mapExZP_SFZP = new Map<String,String>(); // external Zuora Product Id and Salesforce ZProduct Id
        Map<Id,List<Quote_Product__c>> mapQuQP = new  Map<Id,List<Quote_Product__c>>(); // map of quote and Quote product In case of update
        Map<id,zqu__Quote__c > mapQIdQObj = new Map<id,zqu__Quote__c >();
        Map<String,Set<String>> mapEXSid_ZP = new Map<String,Set<String>>();
        List<Quote_Product__c> lstQP = new List<Quote_Product__c>();
        
        for(zqu__Quote__c objQuote : [Select id,zqu__ExistSubscriptionID__c,zqu__SubscriptionType__c,CancellationAction__c,(Select id,name,Action__c,Quote__r.zqu__ExistSubscriptionID__c from Quote_Products__r) from zqu__Quote__c where id in: NewQuoteList and zqu__SubscriptionType__c ='Cancel Subscription']){
            if(String.isNotBlank(objQuote.zqu__ExistSubscriptionID__c)){
                mapExSubIdQObj.put(objQuote.zqu__ExistSubscriptionID__c,objQuote);
                mapQIdQObj.put(objQuote.id,objQuote);
            }
            if(Trigger.isUpdate && objQuote.CancellationAction__c != oldMap.get(objQuote.id).CancellationAction__c && objQuote.Quote_Products__r.size()>0){
                if(!mapQuQP.containsKey(objQuote.id)){
                    mapQuQP.put(objQuote.id,new List<Quote_Product__c>());
                }
                mapQuQP.get(objQuote.id).addAll(objQuote.Quote_Products__r);         
            }
        }
        
        if(mapExSubIdQObj != null && !mapExSubIdQObj.isEmpty() && Trigger.isInsert){
            for(Zuora__SubscriptionProductCharge__c objSPC: [select id,Zuora__Subscription__r.Zuora__External_Id__c,Zuora__Product__r.Zuora__External_Id__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__r.Zuora__External_Id__c in: mapExSubIdQObj.keySet()]){
                if(String.isNotBlank(objSPC.Zuora__Product__r.Zuora__External_Id__c)){
                    mapZProExSubId.put(objSPC.Zuora__Product__r.Zuora__External_Id__c,objSPC.Zuora__Subscription__r.Zuora__External_Id__c);
                } 
                if(!mapEXSid_ZP.containsKey(objSPC.Zuora__Subscription__r.Zuora__External_Id__c)) {
                    mapEXSid_ZP.put(objSPC.Zuora__Subscription__r.Zuora__External_Id__c,new Set<String>());
                }
                mapEXSid_ZP.get(objSPC.Zuora__Subscription__r.Zuora__External_Id__c).add(objSPC.Zuora__Product__r.Zuora__External_Id__c);
            }
        }
        
        // get the id of ZProducts
        if(mapZProExSubId != null && !mapZProExSubId.isEmpty() && Trigger.isInsert){
            for(zqu__ZProduct__c objZP :[select id,zqu__ZuoraId__c from zqu__ZProduct__c where zqu__ZuoraId__c IN : mapZProExSubId.keySet()]){
                mapExZP_SFZP.put(objZP.zqu__ZuoraId__c,objZP.Id);
            }
        }  
        //insert quote product 
        if(mapEXSid_ZP != null && !mapEXSid_ZP.isEmpty()){
            for(String idSub: mapEXSid_ZP.keySet()){
                for(String idZP: mapEXSid_ZP.get(idSub)){
                    Quote_Product__c tempObj = new Quote_Product__c();
                    tempObj.Quote__c = mapExSubIdQObj.get(idSub).id;
                    tempObj.Action__c = mapExSubIdQObj.get(idSub).CancellationAction__c;
                    tempObj.ZProduct__c = mapExZP_SFZP.get(idZP);
                    lstQP.add(tempObj);
                }
            }
        } else if(mapQuQP != null && mapQuQP.values().size()>0 && Trigger.isUpdate){
            for(Id qId: mapQuQP.keySet()){
                for(Quote_Product__c objQP: mapQuQP.get(qId)){
                    Quote_Product__c tempObj = new Quote_Product__c();
                    tempObj.Action__c = mapQIdQObj.get(qId).CancellationAction__c;
                    tempObj.id = objQP.id;
                    lstQP.add(tempObj);
                }
            }
        }
        if(lstQP != null && lstQP.size() >0)    
            upsert lstQP;
    }
    
    //RejectQuoteWhenProvisioningFailsOnPendingRecord
    public void RejectQuoteWhenProvisioningFailsOnPendingRecord(List<zqu__Quote__c> NewQuoteList, Map<id,zqu__Quote__c> oldMap){
        set<id> recID = new set<id>();
        List <ProcessDefinition> ProcessDefinition = new List <ProcessDefinition> () ;
        List <ProcessInstance> ProcessInstanceList = new List <ProcessInstance> ();
        List <ProcessInstanceWorkitem> ProcessInstanceWorkitems = new List <ProcessInstanceWorkitem>();
        for(zqu__Quote__c rec : NewQuoteList){
            if(rec.Sales_Comp_Status__c == 'Pending' && rec.Provisioning_Status__c == 'Failed' && oldMap.get(rec.id).Provisioning_Status__c != 'Failed' ){
                recID.add(rec.id);
            }
        }
        if(recID.size() > 0){
            ProcessDefinition = [SELECT DeveloperName, Id FROM ProcessDefinition where Developername =: 'zuora_approval_process_1'];
            ProcessInstanceList = [ select id , TargetObjectId , Status FROM ProcessInstance WHERE TargetObjectId in : recID and ProcessDefinitionId = : ProcessDefinition[0].Id ];
            if(ProcessInstanceList.size() > 0){
                ProcessInstanceWorkitems = [select id from ProcessInstanceWorkitem where ProcessInstanceid in : ProcessInstanceList ];
            }
            if(ProcessInstanceWorkitems.size()>0) {
                for(ProcessInstanceWorkitem pwi : ProcessInstanceWorkitems) {
                    Approval.ProcessWorkitemRequest req =  new Approval.ProcessWorkitemRequest();
                    req.setComments('Provisioning Failed');
                    req.setAction('Reject');
                    req.setWorkitemId(pwi.Id);
                    Approval.ProcessResult result =  Approval.process(req);
                    system.debug('>>>'+ result );
                }
            }
        }
    }
}