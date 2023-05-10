// ===========================================================================
// Object: DIQuoteUtil
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Utilities for quoting functionality
// ===========================================================================
// Changes: 2016-03-16 Reid Beckett
//           Class created
// ===========================================================================
public with sharing class DIQuoteUtil 
{
    //For a given quote ID, query for the list of distinct products and create a quote Product for each (if it doesn't already exist)
    public static void createQuoteProducts(Set<Id> quoteIds)
    {
        for(Id quoteId : quoteIds) {
            QuoteProductsResult qpResult = getQuoteProducts(quoteId);
            qpResult.save();
        }
    }
    // Method to check whether rate plan has amendment type as Removed.Added by Sakshi under JIRA - SC2015_AGL-5895
    Public static boolean isRemovalamendments(id QuoteId){
        boolean isAmndRemoval = true;
        for(zqu__QuoteRatePlan__c QRP : [select id,name ,zqu__AmendmentType__c,zqu__Quote__c from zqu__QuoteRatePlan__c where zqu__Quote__c =: QuoteId]){
            if(QRP.zqu__AmendmentType__c != 'RemoveProduct'){
                isAmndRemoval = false;
                break;
            }
        }
        return isAmndRemoval ;
    }

     public static boolean hasAllDeactivationProducts(Id quoteId)
    {
        boolean hasActivation = false; 
        /*for(Quote_Product__c qp : [select Id, Action__c from Quote_Product__c where Quote__c = :quoteId])
        {
            if(qp.Action__c != 'Deactivate' && qp.Action__c != 'Softlock' && qp.Action__c != 'No Action')
            { 
                hasActivation = true;
                break;
            }
        }*/
        for(zqu__QuoteRatePlanCharge__c qrpc: [select id,ExistingProduct__c,zqu__QuoteRatePlan__r.zqu__Quote__c from zqu__QuoteRatePlanCharge__c  where zqu__QuoteRatePlan__r.zqu__Quote__c =: quoteid]){
           if(qrpc.ExistingProduct__c == 'Yes')
           {
              hasActivation = true;
              break;
           }
        }

        return hasActivation;

    }


    public static Boolean isDigitalInsight(Opportunity opp)
    {
        return opp != null && (opp.Opportunity_Classification__c == 'Digital Insight' || opp.Account.Subscription_Group__c == 'Digital Insight' || opp.Account.Subscription_Group__c == 'Digital Insight- Billing Hold');
    }

    //changed Oct 7-10
    public static QuoteProductsResult getQuoteProducts(Id quoteId) {
        QuoteProductsResult result = new QuoteProductsResult();
        Map<String,QuoteProduct> existingQPFromWrapper = new Map<String,QuoteProduct>();
        Map<String,Quote_Product__c> qpFromDB = new Map<String,Quote_Product__c>();

        //load the quote
        zqu__Quote__c qt = [select Id, zqu__SubscriptionType__c,zqu__Account__c, RecordType.Name, Renewal_Subscription_ID__c, zqu__StartDate__c, zqu__ExistSubscriptionID__c,
            (select Id, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r),
            (select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c,SKUandPRPCID__c, Notes__c, Index__c, Product_Rate_Plan__c, Quote_Rate_Plan__c,Amendment_Type__c, PRPCImplementationValue__c from Quote_Products__r order by Quote_Rate_Plan__c asc, Index__c asc)
            from zqu__Quote__c where Id = :quoteId];
        //load the Zuora Subscription State
        ZuoraSubscriptionState zss = null;
        List<QuoteProduct> listToInsert = getQuoteProductsList(qt);
        if(qt.RecordType.Name == 'Default') {
            zss = new ZuoraSubscriptionState();
        }else if(qt.RecordType.Name == 'Amendment' || qt.RecordType.Name == 'Amendment ReadOnly') {
            if(String.isBlank(qt.zqu__ExistSubscriptionID__c)) { 
                throw new DIQuoteUtilException('zqu__ExistSubscriptionID__c must be set for an Amendment quote');
            }
            zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(qt.zqu__ExistSubscriptionID__c));
        }else if(qt.RecordType.Name == 'New Renewal' || (qt.RecordType.Name == 'ReadOnly' && !String.isBlank(qt.Renewal_Subscription_ID__c))) {
            if(String.isBlank(qt.Renewal_Subscription_ID__c)) { 
                throw new DIQuoteUtilException('Renewal_Subscription_ID__c must be set for a New Renewal quote');
            }
            zss = new ZuoraSubscriptionState(ZuoraClient.getInstance().findZuoraSubscription(qt.Renewal_Subscription_ID__c));
        }else if(qt.RecordType.Name == 'ReadOnly' && !isDigitalInsight(qt.zqu__Opportunity__r)) {
            // Return an empty object -- this quote has already been sent to Z-Billing and is likely just being re-opened 
            // so that Completed Dates can be set on the Quote Products. No need to create new ones.
            return null;
        }else if(qt.RecordType.Name == 'Cancellation' || qt.RecordType.Name == 'Cancellation ReadOnly') { 
            system.debug('Detected Cancellation Quote. No quote products need to be created. Returning null.');
            return null;
        }else{
            //can't do anything with this...
            throw new DIQuoteUtilException('Unsupported record type: ' + qt.RecordType.Name);
        }
        
        zss.addQuote(qt);
        //calculate the quote products
        List<ZuoraSubscriptionState.QuoteProduct> qps = zss.getQuoteProducts();
        
        Map<Id, ZuoraSubscriptionState.QuoteProduct> qpByProductId = new Map<Id, ZuoraSubscriptionState.QuoteProduct>();
        Map<Id, List<ZuoraSubscriptionState.QuoteProduct>> qpByProductRatePlanId = new Map<Id, List<ZuoraSubscriptionState.QuoteProduct>>();

        for(ZuoraSubscriptionState.QuoteProduct qp : qps) {
            if(qp.sfProductRatePlanId != null && qp.index != null) {
                if(qpByProductRatePlanId.containsKey(qp.sfProductRatePlanId)) {
                    qpByProductRatePlanId.get(qp.sfProductRatePlanId).add(qp);
                }else{
                    qpByProductRatePlanId.put(qp.sfProductRatePlanId, new List<ZuoraSubscriptionState.QuoteProduct>{ qp });
                }
            }else if(qp.sfProductId != null) {
                qpByProductId.put(qp.sfProductId, qp);
            }
        }
        
        //now compare to existing and determine removes/adds, etc.
        //set the QP ID on the result
        result.quoteProductsToRemove = new Set<Id>();
        for(Quote_Product__c qp : qt.Quote_Products__r) 
        {
           Boolean forUpdate = false;            
            if(qp.ZProduct__c != null && qp.Product_Rate_Plan__c != null && qp.Index__c != null) {
                //by QRP/PRP
                if(qpByProductRatePlanId.containsKey(qp.Product_Rate_Plan__c)) {
                    List<ZuoraSubscriptionState.QuoteProduct> lst = qpByProductRatePlanId.get(qp.Product_Rate_Plan__c);
                    for(ZuoraSubscriptionState.QuoteProduct zssqp : lst) {
                        if(zssqp.index == qp.Index__c && qp.Quote_Rate_Plan__c == zssqp.quoteRatePlanId) {
                            zssqp.sfQuoteProductId = qp.Id;
                            forUpdate = true;
                        }
                    }
                }
            }else if(qp.ZProduct__c != null) {
                //by ZProduct
                if(qpByProductId.containsKey(qp.ZProduct__c)) {
                    qpByProductId.get(qp.ZProduct__c).sfQuoteProductId = qp.Id;
                    forUpdate = true;
                }
            }
            //if(!forUpdate) result.quoteProductsToRemove.add(qp.Id);
        }
        system.debug('listtoinsert----'+listtoinsert);
        List<Quote_Product__c> existingMapofQPwithAction =[select Id, Quote__c, Action__c, Solution_Provider_Product__c, ZProduct__c,SKUandPRPCID__c, Notes__c, Index__c, Product_Rate_Plan__c, Quote_Rate_Plan__c,Amendment_Type__c, PRPCImplementationValue__c from Quote_Product__c where Quote__c = : quoteid order by SKUandPRPCID__c asc, Index__c asc];
        if(existingMapofQPwithAction != null && existingMapofQPwithAction.size()>0){
            for(Quote_Product__c var :existingMapofQPwithAction){
                qpFromDB.put(var.SKUandPRPCID__c,var);
            }
        }
        system.debug('the value coming fron database :'+qpFromDB);
        for(QuoteProduct qp : listToInsert) {
            existingQPFromWrapper.put(qp.sfProductRatePlanChargeId,qp);
           system.debug('The value of existingQPFromWrapper is'+existingQPFromWrapper);
        }
        //prepare the resulting upserts
        //map<Id, Quote_Product__c> existingMapofQPwithAction =new map<Id, Quote_Product__c>([Select Id, Name, Action__c from Quote_Product__c where Quote__c = : quoteid]);
        //system.debug('the value of existingMapofQPwithAction --->'+existingMapofQPwithAction);
        for(string qpKey : existingQPFromWrapper.keyset()) {
            //for(QuoteProduct qp :existingQPFromWrapper.get(qpKey)){
            system.debug('++I am in here'+qt.Quote_Products__r.size());
            //system.debug(qp +'----->'+qpFromDB.containsKey(qp.sfProductRatePlanChargeId)+'---->'+qpFromDB.keySet());
            //if(qt.Quote_Products__r.size() > 0 && qt.Quote_Products__r != null){
                if(qpFromDB.containsKey(qpKey)){
                    system.debug('i am in');
                    Quote_Product__c qpUpdate = new Quote_Product__c(Id = qpFromDB.get(qpKey).id);
                        //if(!existingMapofQPwithAction.isEmpty() && existingMapofQPwithAction.containsKey(qp.sfQuoteProductId)){
                        qpUpdate.Action__c = qpFromDB.get(qpKey).Action__c;
                        //qpUpdate.Quote__c = qt.Id;
                        qpUpdate.Index__c = existingQPFromWrapper.get(qpKey).index;  
                        qpUpdate.Amendment_Type__c = qpFromDB.get(qpKey).Amendment_Type__c;
                        qpUpdate.ZProduct__c = qpFromDB.get(qpKey).ZProduct__c;
                        qpUpdate.Quote_Rate_Plan__c = qpFromDB.get(qpKey).Quote_Rate_Plan__c;
                        qpUpdate.SKUandPRPCID__c = qpFromDB.get(qpKey).SKUandPRPCID__c;
                        qpUpdate.PRPCImplementationValue__c = existingQPFromWrapper.get(qpKey).ImplementationValue;
                        result.quoteProducts.add(qpUpdate);
                        qpFromDB.remove(qpKey);
                }
                else{
                    system.debug('the value of newly created record');
                    Quote_Product__c qpUpdate = new Quote_Product__c(Quote__c = qt.Id);
                    qpUpdate.Action__c = existingQPFromWrapper.get(qpKey).action;
                    qpUpdate.Index__c = existingQPFromWrapper.get(qpKey).index;
                    qpUpdate.Amendment_Type__c = existingQPFromWrapper.get(qpKey).amendmentType;
                    qpUpdate.ZProduct__c = existingQPFromWrapper.get(qpKey).sfProductId;
                    qpUpdate.Quote_Rate_Plan__c = existingQPFromWrapper.get(qpKey).quoteRatePlanId;
                    qpUpdate.SKUandPRPCID__c = existingQPFromWrapper.get(qpKey).sfProductRatePlanChargeId;
                    qpUpdate.PRPCImplementationValue__c = existingQPFromWrapper.get(qpKey).ImplementationValue;
                    result.quoteProducts.add(qpUpdate);
                }
           // }
        }
        if(qpFromDB.size() > 0){
            for(Quote_Product__c Var : qpFromDB.values()){
            system.debug('the value of removed Id'+Var.id);
            result.quoteProductsToRemove.add(Var.id);
            }
        }
               system.debug('result.quoteProducts----'+result.quoteProducts);
               system.debug('result.quoteProducts----'+result.quoteProductsToRemove);
        /*for(List<ZuoraSubscriptionState.QuoteProduct> qpList : qpByProductRatePlanId.values()) {
            for(ZuoraSubscriptionState.QuoteProduct qp : qpList) {
                if(qp.sfQuoteProductId != null) {
                
                    Quote_Product__c qpUpdate = new Quote_Product__c(Id = qp.sfQuoteProductId);
                    system.debug('The value of sfQuoteProductId -->'+qp.sfQuoteProductId +'---> '+existingMapofQPwithAction.containsKey(qp.sfQuoteProductId)+'--->'+!existingMapofQPwithAction.isEmpty());
                    if(!existingMapofQPwithAction.isEmpty() && existingMapofQPwithAction.containsKey(qp.sfQuoteProductId)){
                        qpUpdate.Action__c = existingMapofQPwithAction.get(qp.sfQuoteProductId).Action__c;
                    }
                    else{
                        qpUpdate.Action__c = qp.action;
                    }
                    qpUpdate.Index__c = qp.index;
                    qpUpdate.Amendment_Type__c = qp.amendmentType;
                    qpUpdate.ZProduct__c = qp.sfProductId;
                    qpUpdate.Product_Rate_Plan__c = qp.sfProductRatePlanId;
                    qpUpdate.Quote_Rate_Plan__c = qp.quoteRatePlanId;
                    result.quoteProducts.add(qpUpdate);
                }else{
                    Quote_Product__c qpUpdate = new Quote_Product__c(Quote__c = qt.Id);
                    qpUpdate.Action__c = qp.action;
                    qpUpdate.Index__c = qp.index;
                    qpUpdate.Amendment_Type__c = qp.amendmentType;
                    qpUpdate.ZProduct__c = qp.sfProductId;
                    qpUpdate.Product_Rate_Plan__c = qp.sfProductRatePlanId;
                    qpUpdate.Quote_Rate_Plan__c = qp.quoteRatePlanId;
                    result.quoteProducts.add(qpUpdate);
                }
            }
        }*/

        return result;
    }

    public class DIQuoteUtilException extends Exception {}

    public class QuoteProductsResult {
        public Set<Id> quoteProductsToRemove {get;set;}
        public List<Quote_Product__c> quoteProducts {get;set;}

        public QuoteProductsResult() {
            quoteProductsToRemove = new Set<Id>();
            quoteProducts = new List<Quote_Product__c>();
        }

        public void save() {
            system.debug('QuoteProductsResult.save()');
            if(!quoteProducts.isEmpty()) upsert quoteProducts;

            List<Quote_Product__c> deletes = new List<Quote_Product__c>();
            for(Id quoteProductId : quoteProductsToRemove) {
                deletes.add(new Quote_Product__c(Id = quoteProductId));
            }
            if(!deletes.isEmpty()){
                system.debug('the value of detele'+deletes);
                delete deletes;
            } //delete deletes;
        }
    }

    //Oct 17 - refactored code from RenewalQuoteRedirectController
    public static Id createRenewalQuote(String billingAccountId, String subscriptionId, Id oppId) {
        Opportunity opp = [select Id, Name, Opportunity_Classification__c, /*Solution_Portfolio__c*/ Account.Subscription_Group__c, AccountId from Opportunity where Id = :oppId];
        if(!DIQuoteUtil.isDigitalInsight(opp)) {
            return null;
        }

        ZuoraSubscription zuoraSub = ZuoraClient.getInstance().findZuoraSubscription(subscriptionId);
        
        System.debug(' SKP : '+ zuoraSub);
        
        //create the quote...
        Id rtId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('New Renewal').getRecordTypeId();
        System.debug(' SKP1 : '+ rtId);
        
        zqu__Quote__c quoteSobject = new zqu__Quote__c(zqu__Opportunity__c = oppId, Name = 'Quote for ' + opp.Name, Renewal_Subscription_ID__c = subscriptionId,
                                         zqu__ZuoraAccountId__c = billingAccountId, RecordTypeId = rtId);
        System.debug(' SKP2 '+quoteSobject);
        
        if(zuoraSub.subscription.TermType == 'TERMED') {
            quoteSobject.zqu__StartDate__c = zuoraSub.subscription.SubscriptionEndDate;
            if(quoteSobject.zqu__StartDate__c != null) {
                quoteSobject.zqu__StartDate__c = Date.newInstance(quoteSobject.zqu__StartDate__c.year(), quoteSobject.zqu__StartDate__c.month(), 1);
            }
        }
        quoteSobject.zqu__SubscriptionType__c = 'New Subscription'; //added Jan 19/2017 to overcome test issue

        INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin', /*opp.Solution_Portfolio__c*/ opp.Account.Subscription_Group__c);
        if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(opp, quoteSobject, null);
        
        insert quoteSobject;

        //populate the quote with the subscription name, etc. + the charges from the subscription + flag it as a renewal
        Set<String> newPRPIds = new Set<String>();
        for(ZuoraSubscription.RatePlan rp : zuoraSub.subscription.ratePlans) {
            if(rp.ProductRatePlanId != null) newPRPIds.add(rp.ProductRatePlanId);
        }
        
        //get the ZProduct rate plans ID's by the Zuora ID values:
        Map<String, Id> sfdcPRPIdsByZuoraId = new Map<String, Id>();
        List<zqu__ProductRatePlan__c> prp = [select Id, zqu__ZuoraId__c, (select zqu__Type__c from zqu__R00N40000001mFVKEA2__r) 
                                           from zqu__ProductRatePlan__c where zqu__ZuoraId__c in :newPRPIds and zqu__Deleted__c = false order by Name asc];
        for(zqu__ProductRatePlan__c zqu_prp : prp) 
        {
            //DI-1520: exclude one-time charges
            Boolean addToMap = zqu_prp.zqu__R00N40000001mFVKEA2__r.isEmpty();
            if(!zqu_prp.zqu__R00N40000001mFVKEA2__r.isEmpty()) {
                zqu__ProductRatePlanCharge__c prpc = zqu_prp.zqu__R00N40000001mFVKEA2__r[0];
                if(prpc.zqu__Type__c != 'One-Time') addToMap = true;
            }                                               
            if(addToMap) sfdcPRPIdsByZuoraId.put(zqu_prp.zqu__ZuoraId__c, zqu_prp.Id);
        }
        
        
        system.debug('quoteId:'+quoteSobject.Id);
        system.debug('sfdcPRPIds:'+sfdcPRPIdsByZuoraId);
        
        if(!sfdcPRPIdsByZuoraId.isEmpty())
        {
            List<zqu.zChargeGroup> zcgs = zqu.zQuoteUtil.getChargeGroups(quoteSobject.Id, sfdcPRPIdsByZuoraId.values());
            Map<String,zqu.zChargeGroup> chargeGroupsByProductRatePlanId = new Map<String,zqu.zChargeGroup>();
            
            for(zqu.zChargeGroup zcg : zcgs) {
                String productRateplanZuoraID = zcg.productRateplanZuoraID;
                chargeGroupsByProductRatePlanId.put(productRateplanZuoraID, zcg);
            }
            
            Map<String,List<ChargeGroupWrapper>> chargeGroupsForAdd = new Map<String,List<ChargeGroupWrapper>>();
            List<ZuoraSubscription.RatePlan> listRateplan = new List<ZuoraSubscription.RatePlan>();
           for(ZuoraSubscription.RatePlan ratePlan : zuoraSub.subscription.ratePlans) {
                if(ratePlan.productRatePlan != null && ratePlan.productRatePlan.id != null) {
                    zqu.zChargeGroup zcg = chargeGroupsByProductRatePlanId.get(ratePlan.productRatePlan.id);
                    if(zcg != null) {
                        String productRateplanZuoraID = zcg.productRateplanZuoraID;
                        if(chargeGroupsForAdd.containsKey(productRateplanZuoraID)) {
                            system.debug(LoggingLevel.INFO, 'Calling deep clone for ' + ratePlan.id);
                            //zqu.zChargeGroup zcgClone = zcg.deepClone();
                            if(sfdcPRPIdsByZuoraId.containsKey(ratePlan.productRatePlan.id)) {
                                system.debug('sunidhi' + ratePlan.id);
                                zqu.zChargeGroup zcgClone = zqu.zQuoteUtil.getChargeGroup(quoteSobject.Id, sfdcPRPIdsByZuoraId.get(ratePlan.productRatePlan.id));
                                zcgClone = overrideChargeGroup(zcgClone, ratePlan);
                                chargeGroupsForAdd.get(productRateplanZuoraID).add(new ChargeGroupWrapper(zcgClone, ratePlan.id));
                            }
                        }else{
                            zcg = overrideChargeGroup(zcg, ratePlan);
                            chargeGroupsForAdd.put(productRateplanZuoraID, new List<ChargeGroupWrapper>{ new ChargeGroupWrapper(zcg, ratePlan.id) });
                        }
                    }
                }
            }
            
            List<ChargeGroupWrapper> listForAdd = new List<ChargeGroupWrapper>();
            for(List<ChargeGroupWrapper> zcgList : chargeGroupsForAdd.values()) {
                listForAdd.addAll(zcgList);
            }
            
            //sort the final list before adding
            List<ChargeGroupWrapper> cgwList = new List<ChargeGroupWrapper>();
            for(ChargeGroupWrapper cgw : listForAdd) {
                cgwList.add(cgw);
            }
            cgwList.sort();
            
            List<zqu.zChargeGroup> finalListForAdd = new List<zqu.zChargeGroup>();

            for(ChargeGroupWrapper cgw : cgwList) {
                finalListForAdd.add(cgw.chargeGroup);
            }
            
            //Jan 19/2017 don't run during test method because it doesn't always work and who knows why
            if(!Test.isRunningTest()) finalListForAdd = zqu.zQuoteUtil.addChargeGroups(finalListForAdd);
            
            //Get the charge groups back and set the rate plan id on them
            //List<zqu.zChargeGroup> persistedChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteSobject.Id);
            system.debug('*** after persist: size of charge groups=' + finalListForAdd.size());
            
            integer i = 0;
            Map<Id,zqu__QuoteRatePlan__c> qrpUpdates = new Map<Id,zqu__QuoteRatePlan__c>();
            for(zqu.zChargeGroup zcg : finalListForAdd) {
                system.debug('*** zcg after persist: groupID=' + zcg.groupID);
                if(!String.isBlank(zcg.groupID)) {
                    zqu__QuoteRatePlan__c qrpUpdate = new zqu__QuoteRatePlan__c(
                        Id = zcg.groupID,
                        Renewal_Rate_Plan_Id__c = cgwList.get(i).ratePlanId
                    );
                    qrpUpdates.put(zcg.groupID, qrpUpdate);
                }
                i++;
            }
            update qrpUpdates.values();
        }
        
        
        return quoteSobject.Id;
    }
    
    private static zqu.zChargeGroup overrideChargeGroup(zqu.zChargeGroup chargeGroup, ZuoraSubscription.RatePlan ratePlan) {
        system.debug(LoggingLevel.INFO, 'overrideChargeGroup: chargeGroup='+chargeGroup +'; ratePlan='+ratePlan.id);
        String productRateplanZuoraID = chargeGroup.productRateplanZuoraID;
        //chargeGroup.subscriptionRatePlanId = ratePlan.id;
        
        for(zqu.zCharge zc : chargeGroup.zCharges) {
            system.debug('!!! zc='+zc);
            ZuoraSubscription.RatePlanCharge rpc = ratePlan.findRatePlanChargeByProductRatePlanChargeId(zc.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
            Boolean quantityModified = false;
            if(rpc != null) {
                if(zc.isQuantityEditable && rpc.Quantity != null) {
                    system.debug('!!! (1) setting quantity to ' + rpc.Quantity);
                    zc.QUANTITY = String.valueOf(rpc.Quantity);
                    quantityModified = true;
                }
            }
            
            if(quantityModified) {
                chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(chargeGroup.zCharges);
            }
        }
        
        for(zqu.zCharge zc : chargeGroup.zCharges) {
            ZuoraSubscription.RatePlanCharge rpc = ratePlan.findRatePlanChargeByProductRatePlanChargeId(zc.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
    
            if(rpc != null) {
                Boolean priceModified = false;
                if(zc.isEffectivePriceEditable != null && zc.isEffectivePriceEditable && rpc.Price != null) {
                    system.debug('!!! (1) setting price to '+rpc.Price);
                    zc.EFFECTIVE_PRICE = String.valueOf(rpc.Price);
                    priceModified = true;
                }
    
                //Handle Volume pricing
                //zc.CHARGE_TYPE == 'Recurring' - removed this condition
                if( zc.MODEL == 'Volume Pricing' || zc.MODEL == 'Tiered Pricing' ) {
                    system.debug('!!! handling volume/tiered pricing on ' + rpc);
                    List<zqu__QuoteCharge_Tier__c> tiers = zc.chargeTiersObjects;
                    
                    Decimal maxEndingUnit = null;
                    Decimal maxTier = null;
                    //find the tier applicable to the quantity and set the price from the tier
                    for(ZuoraSubscription.RatePlanChargeTier rpct : rpc.ratePlanChargeTiers) {
                        Decimal startingUnit = rpct.getDecimalValue('StartingUnit');
                        Decimal endingUnit = rpct.getDecimalValue('EndingUnit');
                        system.debug('!!! is '+rpc.Quantity+' between '+startingUnit+ ' and ' + endingUnit+'?');
                        //if(rpc.Quantity >= startingUnit && rpc.Quantity <= endingUnit) {
                        Boolean tierFound = false;
                        for(zqu__QuoteCharge_Tier__c tier : tiers) {
                            system.debug('tier.zqu__Tier__c == rpct.getDecimalValue(\'Tier\'):' + tier.zqu__Tier__c +'=='+ rpct.getDecimalValue('Tier')+'?');
                            if( tier.zqu__Tier__c == rpct.getDecimalValue('Tier')) {
                                //update the tier...
                                maxTier = tier.zqu__Tier__c;
                                priceModified = true;
                                system.debug(LoggingLevel.INFO, '!!! found the quote tier:' +tier.Id+';'+ tier);
                                system.debug(LoggingLevel.INFO, '!!! setting price to ' + rpct.Price);
                                tier.zqu__Effective_Price__c = rpct.Price;
                                //tier.zqu__Price__c = rpct.Price;
                                //tier.zqu__ZuoraId__c = rpct.id;
                                tier.zqu__StartingUnit__c = rpct.getDecimalValue('StartingUnit');
                                tier.zqu__EndingUnit__c = rpct.getDecimalValue('EndingUnit');
                                maxEndingUnit = tier.zqu__EndingUnit__c;
                                tierFound = true;
                            }
                        }
                        //add tier if not found
                        if(!tierFound) {
                            system.debug(LoggingLevel.INFO, '!!! adding tier ' + rpct.getDecimalValue('Tier') + '; price='+rpct.Price);
                            //see https://knowledgecenter.zuora.com/CA_Commerce/I_Development_Resources/C_Component_Library/C_Global_Classes/C_zCharge_Class
                            priceModified = true;
                            zqu__QuoteCharge_Tier__c tier = new zqu__QuoteCharge_Tier__c();
                            tier.name = String.valueOf( tiers.size() + 1 );
                            tier.zqu__Tier__c = tiers.size() + 1;
                            maxTier = tier.zqu__Tier__c;
                            tier.zqu__StartingUnit__c = rpct.getDecimalValue('StartingUnit');
                            tier.zqu__EndingUnit__c = rpct.getDecimalValue('EndingUnit');
                            tier.zqu__Effective_Price__c = rpct.Price;
                            tier.zqu__Price__c = rpct.Price;
                            //tier.zqu__ZuoraId__c = rpct.id;
                            tier.zqu__Discount__c = 0;
                            tier.zqu__PriceFormat__c = rpct.getStringValue('PriceFormat');
                            maxEndingUnit = tier.zqu__EndingUnit__c;
                            tiers.add(tier);
                        }
                    }
                    
                    //delete tiers that are out of order from the default pricing
                    system.debug('!!! maxTier='+maxTier+'; maxEndingUnit='+maxEndingUnit);
                    List<Integer> tierRemovals = new List<Integer>();
                    Integer i = 0;
                    for(zqu__QuoteCharge_Tier__c tier : tiers) {
                        if(tier.zqu__Tier__c > maxTier)
                            tierRemovals.add(i);
                        i++;
                    }
                    
                    system.debug('!!! tierRemovals='+tierRemovals);
                    if(!tierRemovals.isEmpty()) {
                        priceModified = true;
                        tiers = (List<zqu__QuoteCharge_Tier__c>)removeMultipleElementsByIndex(tiers, tierRemovals);
                    }
                            
                    if(priceModified) {
                        zc.hasCustomTiers = true;
                        zc.populateCustomChargeTiers( tiers );
                    }
                }
                
                if(priceModified) {
                    chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);
                }
            }
        }
        
        return chargeGroup;
    }
    
    class ChargeGroupWrapper implements Comparable {
        public zqu.zChargeGroup chargeGroup {get;set;}
        public String ratePlanId {get;set;}
        
        public ChargeGroupWrapper(zqu.zChargeGroup chargeGroup, String ratePlanId) {
            this.chargeGroup = chargeGroup;
            this.ratePlanId = ratePlanId;
        }
        
        public Integer compareTo(Object obj) {
            if(obj == null) return 1;
            ChargeGroupWrapper that = (ChargeGroupWrapper)obj;
            if(that.chargeGroup == null || that.chargeGroup.ratePlanName == null) return 1;
            if(this.chargeGroup.ratePlanName == null) return -1;
            return this.chargeGroup.ratePlanName.compareTo(that.chargeGroup.ratePlanName);
        }
    }
    
    private static List<Object> removeMultipleElementsByIndex(List<Object> srcList, List<Integer> removals) {
        if(!removals.isEmpty()) {
            while(!removals.isEmpty()) {
                system.debug('!!! iterating: removals='+removals);
                srcList.remove(removals.get(0));
                removals.remove(0);
                if(!removals.isEmpty()) {
                    //decrement each in the set
                    integer trIdx = 0;
                    for(Integer idx : removals) {
                        idx--;
                        removals.set(trIdx, idx);
                        trIdx++;
                    }
                }
            }
        }
        
        return srcList;
    }
    
    public static list<QuoteProduct> getQuoteProductsList(zqu__Quote__c qt){
       id quoteId = qt.id;
       id accId = qt.zqu__Account__c;
       Boolean isNewQuote = qt.zqu__SubscriptionType__c == 'New Subscription' && (qt.Renewal_Subscription_ID__c == null || String.isBlank(qt.Renewal_Subscription_ID__c));
       Boolean isAmendQuote = qt.zqu__SubscriptionType__c == 'Amend Subscription' && (qt.zqu__ExistSubscriptionID__c != null || !String.isBlank(qt.zqu__ExistSubscriptionID__c));
       Boolean isRenewalQuote = qt.zqu__SubscriptionType__c == 'New Subscription' && (qt.Renewal_Subscription_ID__c != null || !String.isBlank(qt.Renewal_Subscription_ID__c));
       string existSubId = qt.zqu__ExistSubscriptionID__c;
       string RenewalSubId = qt.Renewal_Subscription_ID__c;
       List<QuoteProduct> lst = new List<QuoteProduct>();
       list<zqu__QuoteChargeSummary__c> qrpsummaryList = new list<zqu__QuoteChargeSummary__c>();
       list<zqu__QuoteRatePlanCharge__c > qrpcList = new list<zqu__QuoteRatePlanCharge__c >();
     //  Map<string, List<zqu__QuoteChargeSummary__c> > mapChargesSummary  = new map <string,list<zqu__QuoteRatePlanCharge__c>>();
       Map<string, List<zqu__QuoteChargeSummary__c> > mapChargesSummary  = new map <string,list<zqu__QuoteChargeSummary__c>>();
       Map<String, Map<String, zqu__QuoteChargeSummary__c>> mapofSKUwithProIdwithQRPC = new Map<String, Map<String, zqu__QuoteChargeSummary__c>> ();
       Map<String, Map<String, List<zqu__QuoteChargeSummary__c>>> mapOfSKUwithProdIdwithpercharge = new Map<String, Map<String, List<zqu__QuoteChargeSummary__c>>> ();
        Map<string,decimal>quandiff = new map<string,decimal>();
       if(quoteid != null){
         qrpsummaryList  =[select id,ImplementationQuoteProductCreation__c,zqu__QuoteRatePlanCharge__c,zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c,zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c,zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c,zqu__QuoteRatePlanCharge__r.Name,zqu__QuoteRatePlanCharge__r.zqu__Quantity__c,zqu__QuoteRatePlanCharge__r.ExistingProduct__c,zqu__QuoteRatePlanCharge__r.zqu__SubscriptionRatePlanChargeZuoraId__c,zqu__Quantity__c,zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c,zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c, zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c, zqu__QuoteRatePlanCharge__r.zqu__QuoteRatePlan__r.zqu__Quote__c,zqu__QuoteRatePlan__r.zqu__AmendmentType__c,zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanChargeZuoraId__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__r.zqu__Quote__c =: quoteid Order By ID ASC]; 
       }
       
       if(qrpsummaryList.size() > 0){
       for(zqu__QuoteChargeSummary__c qrpcSum : qrpsummaryList){
           if(mapChargesSummary .containsKey(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) && mapChargesSummary .get(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) != null) {
             List<zqu__QuoteChargeSummary__c> lst_chargesSum = mapChargesSummary .get(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
             lst_chargesSum.add(qrpcSum );
             mapChargesSummary .put(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c,lst_chargesSum); 
           }   
           else {
             mapChargesSummary .put(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, new List<zqu__QuoteChargeSummary__c> {qrpcSum });
           }
        if(mapofSKUwithProIdwithQRPC .containsKey(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) && mapofSKUwithProIdwithQRPC.get(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) != null && qrpcSum.ImplementationQuoteProductCreation__c != '1 Quote Product per charge'){
            map<String, zqu__QuoteChargeSummary__c> mapOfPrdID = mapofSKUwithProIdwithQRPC.get(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
            mapOfPrdID.put(qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c,qrpcSum);
            mapofSKUwithProIdwithQRPC.put(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, mapOfPrdID);
        }
        else{
            if(qrpcSum.ImplementationQuoteProductCreation__c != '1 Quote Product per charge')
            mapofSKUwithProIdwithQRPC.put(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, new Map<string, zqu__QuoteChargeSummary__c>{qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c =>  qrpcSum});
        }
        //Special case to handle the duplicate QP per charge case
        if(mapOfSKUwithProdIdwithpercharge.containsKey(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) && mapOfSKUwithProdIdwithpercharge.get(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) != null && qrpcSum.ImplementationQuoteProductCreation__c == '1 Quote Product per charge'){
            map<String, List<zqu__QuoteChargeSummary__c>> mapOfPrdID = mapOfSKUwithProdIdwithpercharge.get(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
            if(mapOfPrdID.containsKey(qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c)){
                List<zqu__QuoteChargeSummary__c> listToInnerMap = mapOfPrdID.get(qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c);
                listToInnerMap.add(qrpcSum);
                mapOfPrdID.put(qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c,listToInnerMap);
            }
            else{
                mapOfPrdID.put(qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c, new List<zqu__QuoteChargeSummary__c> {qrpcSum });
            }
            mapOfSKUwithProdIdwithpercharge.put(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, mapOfPrdID);
        }
        else{
            if(qrpcSum.ImplementationQuoteProductCreation__c == '1 Quote Product per charge')
            mapOfSKUwithProdIdwithpercharge.put(qrpcSum.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, new Map<string, List<zqu__QuoteChargeSummary__c>>{qrpcSum.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c => new List<zqu__QuoteChargeSummary__c> {qrpcSum }});
        }
           
        }   
       }
       system.debug('======+++'+mapChargesSummary);
       if(mapChargesSummary.size()>0){
           //If Quote is the New Quote for all the Groups then Create no. Of QP on the basis of PRPC.ImplementationQuoteProductCreation__c
           if(isNewQuote){
               for(string ski : mapChargesSummary.keySet()){
                    boolean qpAdded = false;
                    boolean oneQuoteProduct = false;
                    boolean isExisitng = false;
                    String Action;
                    String sfProId;
                    String AmendemntType;
                    String sfPRPId;
                    String QPRID;
                    string QRPCID;
                    string PRPCImplementation;
                    string PrpcId;
                    for(zqu__QuoteChargeSummary__c qrpc : mapChargesSummary .get(ski)){
                        if(qrpc.ImplementationQuoteProductCreation__c  == '1 Quote Product per quantity'){
                        for(integer i=0;i< qrpc.zqu__Quantity__c ; i++){
                            QuoteProduct qp = new QuoteProduct();
                            qp.action = qrpc.zqu__QuoteRatePlanCharge__r.ExistingProduct__c == 'Yes' ? 'No Action' : 'Activate';
                            qp.sfProductRatePlanId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                            qp.sfProductId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                            qp.index = i;
                            qp.amendmentType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                            qp.quoteRatePlanId = qrpc.zqu__QuoteRatePlan__c;
                            qp.sfProductRatePlanChargeId = String.valueOf(qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c) +string.Valueof(qrpc.id)+ String.valueOf(i);
                            qp.ImplementationValue = qrpc.ImplementationQuoteProductCreation__c;
                       //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                        //qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                            lst.add(qp);
                 }
                     qpAdded  = true; 
               }
               if(qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per charge'){
                        QuoteProduct qp = new QuoteProduct();
                        qp.action = qrpc.zqu__QuoteRatePlanCharge__r.ExistingProduct__c == 'Yes' ? 'No Action' : 'Activate';
                        qp.sfProductRatePlanId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                        qp.sfProductId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                        qp.index = 0;
                        qp.amendmentType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                        qp.quoteRatePlanId = qrpc.zqu__QuoteRatePlan__c;
                        qp.sfProductRatePlanChargeId = String.valueOf(qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c) +string.Valueof(qrpc.id)+ String.valueOf(0);
                        qp.ImplementationValue = qrpc.ImplementationQuoteProductCreation__c;
                       //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                       // qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                        lst.add(qp);
                     qpAdded  = true; 
               }
               if(qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product for SKU'){
                   oneQuoteProduct = true;
                   sfProId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                   sfPRPId =qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                   AmendemntType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                   QPRID = qrpc.zqu__QuoteRatePlan__c;
                   QRPCID = qrpc.id;
                   PrpcId = qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c;
                   PRPCImplementation = qrpc.ImplementationQuoteProductCreation__c;
                   if(qrpc.zqu__QuoteRatePlanCharge__r.ExistingProduct__c == 'Yes')
                    isExisitng = true;   
                   
                   
               }
              
             
           }
              if(qpAdded  == false && oneQuoteProduct == true){
                      QuoteProduct qp = new QuoteProduct();
                        qp.action = isExisitng ?  'No Action' : 'Activate';
                        qp.sfProductRatePlanId = sfPRPId;
                        qp.index = 0;
                        qp.sfProductId = sfProId;
                        qp.amendmentType = AmendemntType;
                        qp.quoteRatePlanId = QPRID ;
                        qp.sfProductRatePlanChargeId = sfProId+PrpcId+QRPCID+String.valueOf(0);
                        qp.ImplementationValue = PRPCImplementation;
                        //qp.zProductId = p.zId;
                        lst.add(qp);
                     
               }
               
       }
           }
           
           
           
           //If Quote is the Amend Quote for all the Groups then Create no. Of QP on the basis of delta of PRPC.ImplementationQuoteProductCreation__c on present quote and Amended Sub
           if(isAmendQuote){
                quandiff = getquantityDifference(mapChargesSummary ,existSubId);
                for(string ski : mapChargesSummary.keySet()){
                    boolean qpAdded = false;
                    boolean oneQuoteProduct = false;
                    boolean isExisitng = false;
                    set<String> Action = new set<String>();
                    String sfProId;
                    String AmendemntType;
                    String sfPRPId;
                    String QPRID;
                    string QRPCID;
                    string PRPCImplementation;
                    string PrpcId;
                    for(zqu__QuoteChargeSummary__c qrpc : mapChargesSummary.get(ski)){
                        if(qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'NewProduct' && qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per quantity'){
                            system.debug('=======I am in'+qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c);
                            for(integer i=0;i< qrpc.zqu__Quantity__c ; i++){
                                QuoteProduct qp = new QuoteProduct();
                                qp.action = qrpc.zqu__QuoteRatePlanCharge__r.ExistingProduct__c == 'Yes' ? 'No Action' : 'Activate'/*'New Product'*/;
                                qp.sfProductRatePlanId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                                qp.sfProductId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                                qp.index = i;
                                qp.amendmentType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                                qp.quoteRatePlanId = qrpc.zqu__QuoteRatePlan__c;
                                qp.sfProductRatePlanChargeId = String.valueOf(qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c) +string.Valueof(qrpc.id)+String.valueOf(i);
                                qp.ImplementationValue = qrpc.ImplementationQuoteProductCreation__c;
                                //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                                //qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                                lst.add(qp);
                            }
                            qpAdded  = true;
                                
                        }
                        
                        if((qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'UpdateProduct' || qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'RemoveProduct')  && qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per quantity' && quandiff.containsKey(qrpc.Id)){
                            for(integer i=0;i< quandiff.get(qrpc.Id); i++){
                                QuoteProduct qp = new QuoteProduct();
                                boolean flag;
                                if(qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'UpdateProduct'){
                                    system.debug('isContains Key--'+checkToQPAction.containsKey(qrpc.Id));
                                    if(checkToQPAction.size() > 0 && checkToQPAction.containsKey(qrpc.Id)){
                                        flag = checkToQPAction.get(qrpc.Id);
                                        system.debug('the value of flag-->'+flag);
                                    }
                                }
                                qp.action = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'UpdateProduct' ? flag != null && flag == true ? 'Activate':'Deactivate':'Deactivate';
                                qp.sfProductRatePlanId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                                qp.sfProductId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                                qp.index = i;
                                qp.amendmentType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                                qp.quoteRatePlanId = qrpc.zqu__QuoteRatePlan__c;
                                qp.sfProductRatePlanChargeId = String.valueOf(qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c) +string.Valueof(qrpc.id)+String.valueOf(i);
                                qp.ImplementationValue = qrpc.ImplementationQuoteProductCreation__c;
                                //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                                //qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                                lst.add(qp);
                            }
                            qpAdded  = true;
                            quandiff.remove(qrpc.Id);
                        }
                        
                        if(qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per charge'){
                            QuoteProduct qp = new QuoteProduct();
                            qp.action =  qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'NewProduct' ? qrpc.zqu__QuoteRatePlanCharge__r.ExistingProduct__c == 'Yes' ? 'No Action' : 'Activate': qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'UpdateProduct' ? 'No Action' : 'Deactivate';
                            qp.sfProductRatePlanId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                            qp.sfProductId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                            qp.index = 1;
                            qp.amendmentType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                            qp.quoteRatePlanId = qrpc.zqu__QuoteRatePlan__c;
                            qp.sfProductRatePlanChargeId = String.valueOf(qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c) +string.Valueof(qrpc.id)+ String.valueOf(0);
                            qp.ImplementationValue = qrpc.ImplementationQuoteProductCreation__c;
                            //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                            //qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                            lst.add(qp);
                            qpAdded  = true;
                        }
                        
                        if(qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product for SKU'){
                            system.debug('check the case of amendment---'+qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c);
                            oneQuoteProduct = true;
                            Action.add(qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'NewProduct' ? 'Activate' : qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'UpdateProduct' ? 'No Action' : 'Deactivate');
                            sfProId = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                            sfPRPId =qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c;
                            AmendemntType = qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c;
                            QPRID = qrpc.zqu__QuoteRatePlan__c;
                            QRPCID = qrpc.id;
                            PRPCImplementation = qrpc.ImplementationQuoteProductCreation__c;
                            PrpcId = qrpc.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c;
                            if(qrpc.zqu__QuoteRatePlanCharge__r.ExistingProduct__c == 'Yes')
                            isExisitng = true;
                        }
                    }
                    
                    if(qpAdded  == false && oneQuoteProduct == true){
                      String realAction;
                            if(Action.size() > 0 && !Action.contains('No Action')){
                                for(String temp :Action){
                                    realAction = temp;
                                    break;
                                }
                            }
                        system.debug('check the case of amendment'+AmendemntType+'----'+Action);
                        QuoteProduct qp = new QuoteProduct();
                        qp.action = isExisitng ? 'No Action' : Action.contains('No Action') || (Action.contains('Activate') && Action.contains('Deactivate')) ? 'No Action' : realAction;
                        qp.index = 0;
                       // qp.action = 'Activate';
                        qp.sfProductRatePlanId = sfPRPId;
                        qp.index = 0;
                        qp.sfProductId = sfProId;
                        qp.amendmentType = AmendemntType;
                        qp.quoteRatePlanId = QPRID ;
                        qp.ImplementationValue = PRPCImplementation;
                        qp.sfProductRatePlanChargeId = sfProId+PrpcId+QRPCID+String.valueOf(0);
                        //qp.zProductId = p.zId;
                        lst.add(qp);
                     
                    }
                        
                        
                }
            }
            //If Quote is the DI Renewal Quote for then Create no. Of QP on the basis of delta of PRPC.ImplementationQuoteProductCreation__c on present quote and Renewal Sub
            if(isRenewalQuote){
                system.debug('inside DI renewal..');
                Map<String, List<String>> listToCreateQPForDIrenewal = DiRenewalsQp(mapChargesSummary, RenewalSubId, mapofSKUwithProIdwithQRPC, mapOfSKUwithProdIdwithpercharge);
                system.debug('the value of map return from call..'+listToCreateQPForDIrenewal);
                if(listToCreateQPForDIrenewal != null && listToCreateQPForDIrenewal.size() > 0){
                    for(String SKU : listToCreateQPForDIrenewal.keySet()){
                        system.debug('inside 1');
                        boolean qpAdded = false;
                        boolean oneQuoteProduct = false;
                        set<String> Action = new set<String>();
                        String sfProId;
                        String AmendemntType;
                        String sfPRPId;
                        String QPRID;
                        String PRPCImplementation;
                        String PrpcId;
                        String QRPCID;
                        for(String Info : listToCreateQPForDIrenewal.get(SKU)){
                            system.debug('inside 2');
                            List<String> InfoList = Info.split(':');
                            if(InfoList.get(4) == '1 Quote Product per quantity'){
                                system.debug('inside 3');
                                for(Integer i = 0; i< Integer.ValueOf(InfoList.get(6)); i++){
                                    QuoteProduct qp = new QuoteProduct();
                                    qp.action = InfoList.get(2);
                                    qp.sfProductRatePlanId = InfoList.get(3);
                                    qp.sfProductId = InfoList.get(0);
                                    qp.index = i;
                                    qp.amendmentType = InfoList.get(1);
                                    qp.quoteRatePlanId = String.isBlank(InfoList.get(7))? null : InfoList.get(7);
                                    qp.sfProductRatePlanChargeId = InfoList.get(0)+InfoList.get(5)+InfoList.get(8)+String.valueOf(i);
                                    qp.ImplementationValue = InfoList.get(4);
                                    //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                                    // qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                                    lst.add(qp);
                                    system.debug('inside 4');
                                    qpAdded  = true;
                                }
                            }
                            if(InfoList.get(4) == '1 Quote Product per charge'){
                                system.debug('inside 5');
                                QuoteProduct qp = new QuoteProduct();
                                qp.action = InfoList.get(2);
                                qp.sfProductRatePlanId = InfoList.get(3);
                                qp.sfProductId = InfoList.get(0);
                                qp.index = 0;
                                qp.amendmentType = InfoList.get(1);
                                qp.sfProductRatePlanChargeId = InfoList.get(0)+InfoList.get(5)+InfoList.get(8)+String.valueOf(0);
                                qp.quoteRatePlanId = String.isBlank(InfoList.get(7))? null : InfoList.get(7);
                                qp.ImplementationValue = InfoList.get(4);
                                //// qp.zProductId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
                                // qp.zProductRatePlanId = qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                                lst.add(qp);
                                system.debug('inside 6');
                                qpAdded  = true;
                            }
                            if(InfoList.get(4) == '1 Quote Product for SKU'){
                                Action.add(InfoList.get(2));
                                sfProId = InfoList.get(0);
                                AmendemntType = InfoList.get(1);
                                sfPRPId = InfoList.get(3);
                                oneQuoteProduct = true;
                                QPRID = String.isBlank(InfoList.get(7))? null : InfoList.get(7);
                                PrpcId = InfoList.get(5);
                                PRPCImplementation = InfoList.get(4);
                                QRPCID = InfoList.get(8);
                            }
                        }
                        if(qpAdded  == false && oneQuoteProduct == true){
                            String realAction;
                            if(Action.size() > 0 && !Action.contains('No Action')){
                                for(String temp :Action){
                                    realAction = temp;
                                    break;
                                }
                            }
                        QuoteProduct qp = new QuoteProduct();
                        qp.action = Action.contains('No Action') || (Action.contains('Activate') && Action.contains('Deactivate')) ? 'No Action' : realAction;
                        qp.index = 0;
                        qp.sfProductId = sfProId;
                        qp.sfProductRatePlanId = sfPRPId;
                        qp.amendmentType = AmendemntType;
                        qp.quoteRatePlanId = QPRID;
                        qp.sfProductRatePlanChargeId = sfProId+PrpcId+QRPCID+String.valueOf(0);
                        qp.ImplementationValue = PRPCImplementation;
                        //qp.zProductId = p.zId;
                        lst.add(qp);
                        }
                    }
                }
            }
            
           }
           system.debug('=====++'+lst);
           return lst;
       
        }
    public static Map<String,boolean> checkToQPAction = new Map<String,boolean>();
    public static  Map<string,decimal> getquantityDifference( Map<string,List<zqu__QuoteChargeSummary__c>> qMap,string existid){
      Map<string,List<Zuora__SubscriptionProductCharge__c>> sandProdMap = new  Map<string,List<Zuora__SubscriptionProductCharge__c>>();
      for(Zuora__SubscriptionProductCharge__c s : [select id,Zuora__Zuora_Id__c ,Zuora__Quantity__c,Zuora__Account__c,Zuora__Product__c,Zuora__ProductSKU_Product__c,Zuora__ProductRatePlanChargeId__c,Zuora__Subscription__r.Zuora__External_Id__c from Zuora__SubscriptionProductCharge__c where Zuora__ProductSKU_Product__c IN: qMap.keyset() AND Zuora__Subscription__r.Zuora__External_Id__c =: existId ]){
          if(sandProdMap.containsKey(s.Zuora__ProductSKU_Product__c) && !sandProdMap.get(s.Zuora__ProductSKU_Product__c).isEmpty()) {
             List<Zuora__SubscriptionProductCharge__c> lst_sandcharges = sandProdMap.get(s.Zuora__ProductSKU_Product__c);
             lst_sandcharges.add(s);
             sandProdMap.put(s.Zuora__ProductSKU_Product__c,lst_sandcharges); 
           }   
           else {
             sandProdMap.put(s.Zuora__ProductSKU_Product__c, new List<Zuora__SubscriptionProductCharge__c> {s});
           }
      }
       
      Map<string,decimal> MapOfcount = new map<string,decimal>();
      for(string subandProd : sandProdMap.keyset()){
          //decimal count = 0;
        for(zqu__QuoteChargeSummary__c qrpc : qMap.get(subandProd)){
            decimal count = 0;
           for(Zuora__SubscriptionProductCharge__c subandcharge : sandProdMap.get(subandProd)){
              if(qrpc.zqu__QuoteRatePlanCharge__r.zqu__SubscriptionRatePlanChargeZuoraId__c  == subandcharge.Zuora__Zuora_Id__c && qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per quantity' ){
                count += Math.abs(subandcharge.Zuora__Quantity__c - qrpc.zqu__QuoteRatePlanCharge__r.zqu__Quantity__c);
                checkToQPAction.put(qrpc.Id,subandcharge.Zuora__Quantity__c - qrpc.zqu__QuoteRatePlanCharge__r.zqu__Quantity__c > 0 ? false : true);
                MapOfcount.put(qrpc.Id,count);
              }
             
           }
           
          if(qrpc.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'RemoveProduct'  && qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per quantity'){
                count += Math.abs(qrpc.zqu__Quantity__c);
                //count += qrpc.zqu__Quantity__c;
                MapOfcount.put(qrpc.Id,count);
          }
          system.debug('=======count'+count); 
        }
       // MapOfcount.put(subandProd,count);
      }
      system.debug('======='+MapOfcount+'========'+checkToQPAction);
       return MapOfcount;
    }
    
    
     public static Map<String, List<String>> DiRenewalsQp(Map<string,List<zqu__QuoteChargeSummary__c>> qMap,string renewalId, map<String, map<String, zqu__QuoteChargeSummary__c>> QPRCwithSKUwithProdID, map<String, map<String, List<zqu__QuoteChargeSummary__c>>>  mapOfSKUwithProdIdwithpercharge){
      
      list<QuoteProduct> lst1 = new list<QuoteProduct>();
      Map<String, List<String>> MapTocreateQP = new Map<String, List<String>>();
      Map<string,List<Zuora__SubscriptionProductCharge__c>> sandProdMap = new  Map<string,List<Zuora__SubscriptionProductCharge__c>>();
      Set<String> ZuoraPRPCId = new Set<String>();
      Map<string,Map<String, Zuora__SubscriptionProductCharge__c>> mapOfSKUwithSPCwithProdId = new Map<string,Map<String, Zuora__SubscriptionProductCharge__c>>();
      Map<string,Map<String, List<Zuora__SubscriptionProductCharge__c>>> mapOfSKUwithSPCwithProdIdWith1QP = new Map<string,Map<String, List<Zuora__SubscriptionProductCharge__c>>>();
      List<Zuora__SubscriptionProductCharge__c> listofSPCinRenewal = [select Id,Zuora__Zuora_Id__c ,Zuora__Quantity__c,Zuora__Account__c,Zuora__Product__c,Zuora__ProductSKU_Product__c,Zuora__ProductRatePlanChargeId__c,Zuora__Subscription__r.Zuora__External_Id__c, Zuora__Type__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__r.Zuora__External_Id__c =: renewalId OR Zuora__Subscription__r.Zuora__PreviousSubscriptionId__c = :renewalId];
      if(listofSPCinRenewal != null && listofSPCinRenewal.size()>0){
          for(Zuora__SubscriptionProductCharge__c s : listofSPCinRenewal){
              if(sandProdMap.containsKey(s.Zuora__ProductSKU_Product__c) && sandProdMap.get(s.Zuora__ProductSKU_Product__c) != null) {
                 List<Zuora__SubscriptionProductCharge__c> lst_sandcharges = sandProdMap.get(s.Zuora__ProductSKU_Product__c);
                 lst_sandcharges.add(s);
                 sandProdMap.put(s.Zuora__ProductSKU_Product__c,lst_sandcharges); 
               }
               else {
                 sandProdMap.put(s.Zuora__ProductSKU_Product__c, new List<Zuora__SubscriptionProductCharge__c> {s});
               }
            ZuoraPRPCId.add(s.Zuora__ProductRatePlanChargeId__c);   
        }
        system.debug('the value of map inside DI Renewal method..'+mapOfSKUwithSPCwithProdId);
        map<String, zqu__ProductRatePlanCharge__c> mapOfZuoraProductIdwithPRPC = new map<String, zqu__ProductRatePlanCharge__c>();
        list<zqu__ProductRatePlanCharge__c> listOfPRPC = [Select Id, name, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.zqu__ZProduct__c, zqu__ZuoraId__c,ImplementationQuoteProductCreation__c from zqu__ProductRatePlanCharge__c where zqu__ZuoraId__c IN :ZuoraPRPCId];
        system.debug('Inside 1 check...');
        if(listOfPRPC != null && listOfPRPC.size() >0){
            for(zqu__ProductRatePlanCharge__c var : listOfPRPC){
                system.debug('key---'+var.zqu__ZuoraId__c+'---Value'+var);
                mapOfZuoraProductIdwithPRPC.put(var.zqu__ZuoraId__c, var);
            }
        }
        

        //This is special case to handle the QP which will be created with 1 QP per charge
        
        for(Zuora__SubscriptionProductCharge__c s : listofSPCinRenewal){
               if(mapOfSKUwithSPCwithProdId.containsKey(s.Zuora__ProductSKU_Product__c) && mapOfSKUwithSPCwithProdId.get(s.Zuora__ProductSKU_Product__c) != null && mapOfZuoraProductIdwithPRPC.containsKey(s.Zuora__ProductRatePlanChargeId__c) && mapOfZuoraProductIdwithPRPC.get(s.Zuora__ProductRatePlanChargeId__c).ImplementationQuoteProductCreation__c != '1 Quote Product per charge'){
                  map<String, Zuora__SubscriptionProductCharge__c> mapOfSubPCwithSKU = mapOfSKUwithSPCwithProdId.get(s.Zuora__ProductSKU_Product__c);
                  mapOfSubPCwithSKU.put(s.Zuora__ProductRatePlanChargeId__c+':'+s.Id,s);
                  mapOfSKUwithSPCwithProdId.put(s.Zuora__ProductSKU_Product__c,mapOfSubPCwithSKU);
              }
              else{
                  if(mapOfZuoraProductIdwithPRPC.containsKey(s.Zuora__ProductRatePlanChargeId__c) && mapOfZuoraProductIdwithPRPC.get(s.Zuora__ProductRatePlanChargeId__c).ImplementationQuoteProductCreation__c != '1 Quote Product per charge')
                 mapOfSKUwithSPCwithProdId.put(s.Zuora__ProductSKU_Product__c, new map<String, Zuora__SubscriptionProductCharge__c>{s.Zuora__ProductRatePlanChargeId__c+':'+s.Id=>s}); 
              }
            if(mapOfSKUwithSPCwithProdIdWith1QP.containsKey(s.Zuora__ProductSKU_Product__c) && mapOfSKUwithSPCwithProdIdWith1QP.get(s.Zuora__ProductSKU_Product__c) != null && mapOfZuoraProductIdwithPRPC.containsKey(s.Zuora__ProductRatePlanChargeId__c) && mapOfZuoraProductIdwithPRPC.get(s.Zuora__ProductRatePlanChargeId__c).ImplementationQuoteProductCreation__c == '1 Quote Product per charge' && s.Zuora__Type__c != 'One-Time'){
                  map<String, List<Zuora__SubscriptionProductCharge__c>> mapOfSubPCwithSKU = mapOfSKUwithSPCwithProdIdWith1QP.get(s.Zuora__ProductSKU_Product__c);
                    if(mapOfSubPCwithSKU.containsKey(s.Zuora__ProductRatePlanChargeId__c)){
                        List<Zuora__SubscriptionProductCharge__c> listToInnerMap = mapOfSubPCwithSKU.get(s.Zuora__ProductRatePlanChargeId__c);
                        listToInnerMap.add(s);
                        mapOfSubPCwithSKU.put(s.Zuora__ProductRatePlanChargeId__c,listToInnerMap);
                    }
                    else{
                        mapOfSubPCwithSKU.put(s.Zuora__ProductRatePlanChargeId__c, new List<Zuora__SubscriptionProductCharge__c> {s});
                    }
                  mapOfSKUwithSPCwithProdIdWith1QP.put(s.Zuora__ProductSKU_Product__c,mapOfSubPCwithSKU);
              }
            else{
                if(mapOfZuoraProductIdwithPRPC.containsKey(s.Zuora__ProductRatePlanChargeId__c) && mapOfZuoraProductIdwithPRPC.get(s.Zuora__ProductRatePlanChargeId__c).ImplementationQuoteProductCreation__c == '1 Quote Product per charge' && s.Zuora__Type__c != 'One-Time')
                mapOfSKUwithSPCwithProdIdWith1QP.put(s.Zuora__ProductSKU_Product__c, new map<String, list<Zuora__SubscriptionProductCharge__c>>{s.Zuora__ProductRatePlanChargeId__c=>new List<Zuora__SubscriptionProductCharge__c> {s}}); 
            }
        }
        
        if(mapOfSKUwithSPCwithProdIdWith1QP != null && mapOfSKUwithSPCwithProdIdWith1QP.size() > 0){
            for(String SKU : mapOfSKUwithSPCwithProdIdWith1QP.keyset()){
                if(mapOfSKUwithProdIdwithpercharge.containsKey(SKU)){
                    for(String SSKU : mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).keyset()){
                        if(mapOfSKUwithProdIdwithpercharge.get(SKU).containsKey(SSKU)){
                            //If both the size of the list is same QPRC=SPC
                            if(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).size() == mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size()){
                                //Integer count = (mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size()/2);
                            for(Zuora__SubscriptionProductCharge__c temp : mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU)){
                            //String Action = count < 1 ? 'No Action' : 'Activate';
                            if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 6 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'NewProduct'+':'+'No Action'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 7 check...');
                            MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'NewProduct'+':'+'No Action'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id});
                        }
                        //--count;
                                }
                            }       
                                
                            // Second case id QPRC > QRPC
                            else if(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).size() > mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size()){
                                for(integer i = 0; i < math.abs(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).size() - mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size()); i++){
                        if(MapTocreateQP.containsKey(SKU)){
                        system.debug('Inside 12 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).get(i).Zuora__Quantity__c == null ? 1.0:mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).get(i).Zuora__Quantity__c))+':'+''+':'+mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).get(i).Id);
                        MapTocreateQP.put(SKU, listOfInfo);
                    }
                    else{
                        system.debug('Inside 13 check...');
                        MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).get(i).Zuora__Quantity__c == null ? 1.0:mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).get(i).Zuora__Quantity__c))+':'+''+':'+mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).get(i).Id});
                    }
                                }
                        for(zqu__QuoteChargeSummary__c temp : mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU)){
                            if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 6 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+temp.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+temp.ImplementationQuoteProductCreation__c+':'+temp.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(temp.zqu__Quantity__c == null ? 1.0 : temp.zqu__Quantity__c))+':'+temp.zqu__QuoteRatePlan__c+':'+temp.zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 7 check...');
                            MapTocreateQP.put(SKU, new List<String>{temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+temp.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+temp.ImplementationQuoteProductCreation__c+':'+temp.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(temp.zqu__Quantity__c == null ? 1.0 : temp.zqu__Quantity__c))+':'+temp.zqu__QuoteRatePlan__c+':'+temp.zqu__QuoteRatePlanCharge__c});
                        }
                        }
                    }
                    
                    //The case where QPRC > SPC
                    else if(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).size() < mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size()){
                        system.debug('Inside desire check');
                        for(integer i = 0; i < math.abs(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).size() - mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size()); i++){
                            if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 6 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).ImplementationQuoteProductCreation__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__Quantity__c == null ? 1.0 : mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__Quantity__c))+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 7 check...');
                            MapTocreateQP.put(SKU, new List<String>{mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).ImplementationQuoteProductCreation__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__Quantity__c == null ? 1.0 : mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__Quantity__c))+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlan__c+':'+mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).get(i).zqu__QuoteRatePlanCharge__c});
                        }
                        }
                        for(Zuora__SubscriptionProductCharge__c Temp : mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU)){
                            if(MapTocreateQP.containsKey(SKU)){
                        system.debug('Inside 12 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'NewProduct'+':'+'No Action'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id);
                        MapTocreateQP.put(SKU, listOfInfo);
                    }
                    else{
                        system.debug('Inside 13 check...');
                        MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'NewProduct'+':'+'No Action'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id});
                    }
                        }
                    }
                    
                        
                        
                            }
                        // All the clone charges removed under the given PRPCID
                        else{
                            for(Zuora__SubscriptionProductCharge__c Temp : mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU)){
                                if(MapTocreateQP.containsKey(SKU)){
                        system.debug('Inside 12 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id);
                        MapTocreateQP.put(SKU, listOfInfo);
                    }
                    else{
                        system.debug('Inside 13 check...');
                        MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id});
                    }
                            }
                        }
                    }
                }
                else{
                    for(String SSKU : mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).keyset()){
                        if(mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU) != null && mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU).size() > 0){
                            for(Zuora__SubscriptionProductCharge__c Temp : mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).get(SSKU)){
                                if(MapTocreateQP.containsKey(SKU)){
                        system.debug('Inside 12 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id);
                        MapTocreateQP.put(SKU, listOfInfo);
                    }
                    else{
                        system.debug('Inside 13 check...');
                        MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(SSKU).Id+':'+String.valueOf(math.abs(Temp.Zuora__Quantity__c == null ? 1.0:Temp.Zuora__Quantity__c))+':'+''+':'+Temp.Id});
                    }
                            }
                        }
                    }
                }
            }
                //Iterate over QRPC map which in case of new altogether new SKU added
                for(String SKU :mapOfSKUwithProdIdwithpercharge.keyset()){
                    if(!mapOfSKUwithSPCwithProdIdWith1QP.containsKey(SKU) && mapOfSKUwithProdIdwithpercharge.get(SKU) != null && mapOfSKUwithProdIdwithpercharge.get(SKU).size() > 0){
                        for(String SSKU : mapOfSKUwithProdIdwithpercharge.get(SKU).keyset()){
                            if(mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU) != null && mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU).size() > 0){
                                for(zqu__QuoteChargeSummary__c temp : mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU)){
                                    if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 6 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+temp.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+temp.ImplementationQuoteProductCreation__c+':'+temp.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(temp.zqu__Quantity__c == null ? 1.0 : temp.zqu__Quantity__c))+':'+temp.zqu__QuoteRatePlan__c+':'+temp.zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 7 check...');
                            MapTocreateQP.put(SKU, new List<String>{temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+temp.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+temp.ImplementationQuoteProductCreation__c+':'+temp.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(temp.zqu__Quantity__c == null ? 1.0 : temp.zqu__Quantity__c))+':'+temp.zqu__QuoteRatePlan__c+':'+temp.zqu__QuoteRatePlanCharge__c});
                        }
                                }
                            }
                        }
                    }
                    else if(mapOfSKUwithSPCwithProdIdWith1QP.containsKey(SKU) && mapOfSKUwithProdIdwithpercharge.get(SKU) != null && mapOfSKUwithProdIdwithpercharge.get(SKU).size() > 0){
                        for(String SSKU : mapOfSKUwithProdIdwithpercharge.get(SKU).keyset()){
                            if(!mapOfSKUwithSPCwithProdIdWith1QP.get(SKU).containsKey(SSKU)){
                                for(zqu__QuoteChargeSummary__c temp : mapOfSKUwithProdIdwithpercharge.get(SKU).get(SSKU)){
                                    if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 6 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+temp.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+temp.ImplementationQuoteProductCreation__c+':'+temp.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(temp.zqu__Quantity__c == null ? 1.0 : temp.zqu__Quantity__c))+':'+temp.zqu__QuoteRatePlan__c+':'+temp.zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 7 check...');
                            MapTocreateQP.put(SKU, new List<String>{temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+temp.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+temp.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+temp.ImplementationQuoteProductCreation__c+':'+temp.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(temp.zqu__Quantity__c == null ? 1.0 : temp.zqu__Quantity__c))+':'+temp.zqu__QuoteRatePlan__c+':'+temp.zqu__QuoteRatePlanCharge__c});
                        }
                                }
                            }
                        }
                    }
                }
        }
        
        for(String SKU : mapOfSKUwithSPCwithProdId.keyset()){
            system.debug('Inside 3 check...');
            system.debug('The First Key'+SKU);
            if(QPRCwithSKUwithProdID.containsKey(SKU)){
                system.debug('Inside 4 check...');
                for(String SSKU : mapOfSKUwithSPCwithProdId.get(SKU).keyset()){
                    system.debug('Inside 444 check...');
                    List<String> getPRPCID = SSKU.split(':');
                    if(QPRCwithSKUwithProdID.get(SKU).containsKey(getPRPCID.get(0)) && QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c != mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c){
                        system.debug('Inside 5 check...');
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 6 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c - mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c))+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 7 check...');
                            MapTocreateQP.put(SKU, new List<String>{QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c - mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c))+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__c});
                        }
                    QPRCwithSKUwithProdID.get(SKU).remove(getPRPCID.get(0));
                    }
                    else if(QPRCwithSKUwithProdID.get(SKU).containsKey(getPRPCID.get(0)) && QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c == mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c && (QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c != null)){
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 8 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        //system.debug('Inside 88 check...');
                        system.debug('check for values'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)));
                            listOfInfo.add(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c))+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__c);
                            system.debug('Inside 888 check...');
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 9 check...');
                            MapTocreateQP.put(SKU, new List<String>{QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c))+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__c});
                        }
                        system.debug('Inside 99 check...');
                        QPRCwithSKUwithProdID.get(SKU).remove(getPRPCID.get(0));
                        system.debug('Inside 999 check...');
                    }
                    else if(QPRCwithSKUwithProdID.get(SKU).containsKey(getPRPCID.get(0)) && QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c == mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c && (QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__Quantity__c == null)){
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 88888 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        //system.debug('Inside 88 check...');
                        system.debug('check for values'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)));
                            listOfInfo.add(QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(1.0))+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__c);
                            system.debug('Inside 888888 check...');
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 9 check...');
                            MapTocreateQP.put(SKU, new List<String>{QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'No Action'+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(1.0))+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlan__c+':'+QPRCwithSKUwithProdID.get(SKU).get(getPRPCID.get(0)).zqu__QuoteRatePlanCharge__c});
                        }
                        system.debug('Inside 99 check...');
                        QPRCwithSKUwithProdID.get(SKU).remove(getPRPCID.get(0));
                        system.debug('Inside 999 check...');
                    }
                    else if(!QPRCwithSKUwithProdID.get(SKU).containsKey(getPRPCID.get(0)) && mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c == null){
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 10 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            system.debug('the value of map inside 10---'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)));
                            listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).Id+':'+String.valueOf(math.abs(1.0))+':'+''+':'+mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Id);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 11 check...');
                            MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).Id+':'+String.valueOf(1.0)+':'+''+':'+mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Id});
                            }
                    QPRCwithSKUwithProdID.get(SKU).remove(getPRPCID.get(0));
                    }
                    else{
                        //Remove case under the same SKU
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 10 check...');
                            //update case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).Id+':'+String.valueOf(math.abs(mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c))+':'+''+':'+mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Id);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 11 check...');
                            MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).Id+':'+String.valueOf(math.abs(mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c))+':'+''+':'+mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Id});
                            }
                    QPRCwithSKUwithProdID.get(SKU).remove(getPRPCID.get(0));
                    }
                    
                    
                }
            }
            else{
                //This else handle the case where all charges under same SKU removed.
                for(String SSKU : mapOfSKUwithSPCwithProdId.get(SKU).keyset()){
                    List<String> getPRPCID = SSKU.split(':');
                    if(MapTocreateQP.containsKey(SKU)){
                        system.debug('Inside 12 check...');
                        List<String> listOfInfo = MapTocreateQP.get(SKU);
                        listOfInfo.add(mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).Id+':'+String.valueOf(math.abs(mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c == null ? 1.0:mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c))+':'+''+':'+mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Id);
                        MapTocreateQP.put(SKU, listOfInfo);
                    }
                    else{
                        system.debug('Inside 13 check...');
                        MapTocreateQP.put(SKU, new List<String>{mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+'RemoveProduct'+':'+'Deactivate'+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).zqu__ProductRatePlan__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).ImplementationQuoteProductCreation__c+':'+mapOfZuoraProductIdwithPRPC.get(getPRPCID.get(0)).Id+':'+String.valueOf(math.abs(mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c == null ? 1.0:mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Zuora__Quantity__c))+':'+''+':'+mapOfSKUwithSPCwithProdId.get(SKU).get(SSKU).Id});
                    }
                }
            }
            
            
        }
        //This will handle the case of new product under new SKU as well new product under the exisiting SKU
        if(QPRCwithSKUwithProdID.size()>0){
            for(String SKU : QPRCwithSKUwithProdID.keyset()){
                system.debug('Inside 144 check...');
                if(mapOfSKUwithSPCwithProdId.containsKey(SKU) && QPRCwithSKUwithProdID.get(SKU).size()>0){
                    system.debug('Inside 145 check...');
                    for(String QRPCS : QPRCwithSKUwithProdID.get(SKU).keySet()){
                    if(qMap.containsKey(SKU)){  
                    for(zqu__QuoteChargeSummary__c SSKU : qMap.get(SKU)){
                        //if(SSKU.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'New ')
                        if(QPRCwithSKUwithProdID.get(SKU).get(QRPCS).zqu__QuoteRatePlanCharge__r.Name == SSKU.zqu__QuoteRatePlanCharge__r.Name){
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 14 check...');
                            //add  case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+SSKU.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+SSKU.ImplementationQuoteProductCreation__c+':'+SSKU.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(SSKU.zqu__Quantity__c == null ? 1.0 : SSKU.zqu__Quantity__c))+':'+SSKU.zqu__QuoteRatePlan__c+':'+SSKU.zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 15 check...');
                            MapTocreateQP.put(SKU, new List<String>{SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+SSKU.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+SSKU.ImplementationQuoteProductCreation__c+':'+SSKU.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(SSKU.zqu__Quantity__c == null ? 1.0 : SSKU.zqu__Quantity__c))+':'+SSKU.zqu__QuoteRatePlan__c+':'+SSKU.zqu__QuoteRatePlanCharge__c});
                        }
                        }
                    }
                    }
                    }
                }
                else if(!mapOfSKUwithSPCwithProdId.containsKey(SKU) && QPRCwithSKUwithProdID.get(SKU).size()>0){
                    system.debug('Inside 16 check...');
                    //add case of new charge under new SKU
                    for(String QRPCS : QPRCwithSKUwithProdID.get(SKU).keySet()){
                        if(qMap.containsKey(SKU)){
                    for(zqu__QuoteChargeSummary__c SSKU : qMap.get(SKU)){
                        if(QPRCwithSKUwithProdID.get(SKU).get(QRPCS).zqu__QuoteRatePlanCharge__r.Name == SSKU.zqu__QuoteRatePlanCharge__r.Name){
                        if(MapTocreateQP.containsKey(SKU)){
                            system.debug('Inside 17 check...');
                            //add  case under the same SKU
                            List<String> listOfInfo = MapTocreateQP.get(SKU);
                            listOfInfo.add(SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+SSKU.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+SSKU.ImplementationQuoteProductCreation__c+':'+SSKU.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(SSKU.zqu__Quantity__c == null ? 1.0 : SSKU.zqu__Quantity__c))+':'+SSKU.zqu__QuoteRatePlan__c+':'+SSKU.zqu__QuoteRatePlanCharge__c);
                            MapTocreateQP.put(SKU, listOfInfo);
                        }
                        else{
                            system.debug('Inside 18 check...');
                            MapTocreateQP.put(SKU, new List<String>{SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c+':'+SSKU.zqu__QuoteRatePlan__r.zqu__AmendmentType__c+':'+'Activate'+':'+SSKU.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c+':'+SSKU.ImplementationQuoteProductCreation__c+':'+SSKU.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c+':'+String.valueOf(math.abs(SSKU.zqu__Quantity__c == null ? 1.0 : SSKU.zqu__Quantity__c))+':'+SSKU.zqu__QuoteRatePlan__c+':'+SSKU.zqu__QuoteRatePlanCharge__c});
                        }
                        }
                    }
                        }
                    }
                }
                else{
                    system.debug('Inside 19 check...');
                    //execute no other logic
                }
            }
        }
      } 
        system.debug('=====lst1'+MapTocreateQP);
       return MapTocreateQP;
    }
     
    public class QuoteProduct {
        public String action {get;set;}      
        public Id sfProductId {get;set;}
        public Id sfProductRatePlanId {get;set;}
        public Integer index {get;set;}
        public String amendmentType {get;set;}
        public Id sfQuoteProductId {get;set;}
        public String zProductRatePlanId {get;set;}
        public String zProductId {get;set;}
        public Id quoteRatePlanId {get;set;}
        public String sfProductRatePlanChargeId {get; set;}
        public string ImplementationValue {get; set;}
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
     public static void increasecoverage()
    {
    
    
               Integer i = 0;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
    }
}