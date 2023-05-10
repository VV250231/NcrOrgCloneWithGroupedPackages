// ===========================================================================
// Object: ZuoraClient
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Implementation of IZuoraClient
// ===========================================================================
// Changes: 2016-04-29 Reid Beckett
//           Class created
// ===========================================================================
public with sharing virtual class ZuoraClient implements IZuoraClient 
{
    public static final String ZOQL_findSubscriptionById = 'select Id,Name, OriginalId, ContractEffectiveDate, ServiceActivationDate, CreatedDate, TermType, InitialTerm, RenewalTerm, Version, PreviousSubscriptionId, TermStartDate, SubscriptionEndDate, AutoRenew from Subscription where Id = {0}';
    public static final String ZOQL_findRatePlansBySubscriptionId = 'select Id,Name,ProductRatePlanId, SubscriptionId, AmendmentId from RatePlan where SubscriptionId = {0}';
    public static final String ZOQL_findRatePlanChargesByRatePlanIds = 'SELECT Id,Name,ProductRatePlanChargeId,ChargeModel,ChargeType,UOM,Quantity,ChargedThroughDate,EffectiveStartDate,EffectiveEndDate,RatePlanId,ChargeNumber,CreatedDate,MRR,Price,TriggerEvent,TriggerDate,BillingPeriod,Segment,IsLastSegment,Delivered__c,id FROM RatePlanCharge WHERE {0}';
    public static final String ZOQL_findRatePlanChargesByRatePlanIdsWithoutPrice = 'SELECT Id,Name,ProductRatePlanChargeId,ChargeModel,ChargeType,UOM,Quantity,ChargedThroughDate,EffectiveStartDate,EffectiveEndDate,RatePlanId,ChargeNumber,CreatedDate,MRR,TriggerEvent,TriggerDate,BillingPeriod,Segment,IsLastSegment,Delivered__c,id FROM RatePlanCharge WHERE {0}';
    public static final String ZOQL_findProductRatePlansById = 'select Id, Name, Description, ProductId from ProductRatePlan where {0}';
    public static final String ZOQL_findProductRatePlanChargesByProductRatePlanId = 'select Id, ProductRatePlanId, ChargeModel, TriggerEvent, BillingPeriod from ProductRatePlanCharge where {0}';
    public static final String ZOQL_findProducts = 'select Id, Name, SKU, Description from Product where {0}';
    public static final String ZOQL_findRatePlanChargeTiersByRatePlanChargeIds = 'SELECT Id,Price,Tier,StartingUnit,EndingUnit,RatePlanChargeId,PriceFormat FROM RatePlanChargeTier WHERE {0}';
    private static final Integer MAX_UPDATE_BATCH_SIZE = 50; //the max number of objects to send to zupdate call
    private static final Integer MILLISECONDS_PER_HOUR = 3600000;

    private static Zuora.zApi zuoraApi;
    public static ZuoraClient instance;
    
    public static ZuoraClient getInstance() 
    {
            if(instance == null) {
            if(Test.isRunningTest()) instance = new ZuoraMockClient();
            else instance = new ZuoraClient();
            }
        return instance;
    }

    //singleton instance of the zApi, to ensure single login
    private static Zuora.zApi getZuoraAPIInstance() 
    {
        if(zuoraApi == null) {
            try {
                zuoraApi = new Zuora.zApi();
                if(!Test.isRunningTest()) zuoraApi.zlogin();
            }catch(Exception e){
                throw new ZuoraClientException(e.getMessage());        
            }
        }
        return zuoraApi;
    }

    private Zuora.zObject findSubscription(String zuoraSubscriptionId)
    {
        String zoql = String.format(ZOQL_findSubscriptionById, new String[]{ enquote(zuoraSubscriptionId) });
        Zuora.zObject[] zsubs;
        if(DIProvisioningController.isfirstTime == null || DIProvisioningController.isfirstTime == true)
        zsubs = zquery(zoql);
        if(zsubs == null || zsubs.isEmpty()) return null;
        return zsubs[0];
    }

    private Zuora.zObject[] findRatePlans(String zuoraSubscriptionId)
    {
        String zoql = String.format(ZOQL_findRatePlansBySubscriptionId, new String[]{ enquote(zuoraSubscriptionId) });
        return zquery(zoql);
    }

    private Zuora.zObject[] findRatePlanCharges(Set<String> ratePlanIds)
    {
        String zoql = String.format(ZOQL_findRatePlanChargesByRatePlanIds, new String[]{generateOrClause('RatePlanId', new List<String>(ratePlanIds))});
        return zquery(zoql);
    }

    private Zuora.zObject[] findRatePlanChargesWithoutPrice(Set<String> ratePlanIds)
    {
        String zoql = String.format(ZOQL_findRatePlanChargesByRatePlanIdsWithoutPrice, new String[]{generateOrClause('RatePlanId', new List<String>(ratePlanIds))});
        return zquery(zoql);
    }

    private Zuora.zObject[] findRatePlanChargeTiers(Set<String> ratePlanChargeIds)
    {
        String zoql = String.format(ZOQL_findRatePlanChargeTiersByRatePlanChargeIds, new String[]{generateOrClause('RatePlanChargeId', new List<String>(ratePlanChargeIds))});
        return zquery(zoql);
    }

    private Zuora.zObject[] findProductRatePlans(Set<String> productRatePlanIds)
    {
        String zoql = String.format(ZOQL_findProductRatePlansById, new String[]{generateOrClause('Id', new List<String>(productRatePlanIds))});
        return zquery(zoql);
    }

    private Zuora.zObject[] findProductRatePlanCharges(Set<String> productRatePlanIds)
    {
        String zoql = String.format(ZOQL_findProductRatePlanChargesByProductRatePlanId, new String[]{generateOrClause('ProductRatePlanId', new List<String>(productRatePlanIds))});
        return zquery(zoql);
    }

    private Zuora.zObject[] findProducts(Set<String> productIds)
    {
        String zoql = String.format(ZOQL_findProducts, new String[]{generateOrClause('Id', new List<String>(productIds))});
        return zquery(zoql);
    }

    public ZuoraSubscription findZuoraSubscription(String zuoraSubscriptionId)
    {
        return findZuoraSubscription(zuoraSubscriptionId, true);
    }

    public ZuoraSubscription findZuoraSubscription(String zuoraSubscriptionId, Boolean withPrice)
    {
        Zuora.zObject zsub = findSubscription(zuoraSubscriptionId);
        if(zsub == null) return null;
        ZuoraSubscription zuoraSubscription = new ZuoraSubscription(zsub);

        Set<String> ratePlanIds = new Set<String>();
        Set<String> productRatePlanIds = new Set<String>();
        for(Zuora.zObject zrp : findRatePlans(zuoraSubscription.subscription.id))
        {
            system.debug('*** findRatePlans: Found '+zrp.getValue('Id'));
            ZuoraSubscription.RatePlan rp = new ZuoraSubscription.RatePlan(zrp);
            zuoraSubscription.subscription.ratePlans.add(rp);
            ratePlanIds.add(rp.id);
            productRatePlanIds.add(rp.ProductRatePlanId);
        }

        //TODO: query non-volume & tiered with price
        //Zuora.zObject[] charges = withPrice ? findRatePlanCharges(ratePlanIds) : findRatePlanChargesWithoutPrice(ratePlanIds);
        Set<String> ratePlanChargeIds = new Set<String>();
        Map<String,String> ratePlansByRatePlanChargeId = new Map<String,String>();
        Zuora.zObject[] charges = findRatePlanCharges(ratePlanIds);
        for(Zuora.zObject zrpc : charges)
        {
            ZuoraSubscription.RatePlanCharge rpc = new ZuoraSubscription.RatePlanCharge(zrpc);
            system.debug('*** '+rpc.id+'; rpc.IsLastSegment='+rpc.IsLastSegment+'; rpc.Segment='+rpc.Segment);
            if(rpc.IsLastSegment == null || rpc.IsLastSegment) {
                ratePlanChargeIds.add(rpc.id);
                ZuoraSubscription.RatePlan rp = zuoraSubscription.subscription.findRatePlanById(rpc.RatePlanId);
                system.debug('*** BEFORE rp='+rp);
                if(rp != null) rp.ratePlanCharges.add(rpc);
                system.debug('*** BEFORE rp.ratePlanCharges='+rp.ratePlanCharges);
                ratePlansByRatePlanChargeId.put(rpc.id, rpc.RatePlanId);
            }
        }
        
        //query volume & tiered charges without price
        Zuora.zObject[] charges2 = findRatePlanChargesWithoutPrice(ratePlanIds);
        for(Zuora.zObject zrpc : charges2)
        {
            ZuoraSubscription.RatePlanCharge rpc = new ZuoraSubscription.RatePlanCharge(zrpc);
            system.debug('*** '+rpc.id+'; rpc.IsLastSegment='+rpc.IsLastSegment+'; rpc.Segment='+rpc.Segment);
            if(rpc.IsLastSegment == null || rpc.IsLastSegment) {
                ratePlanChargeIds.add(rpc.id);
                ZuoraSubscription.RatePlan rp = zuoraSubscription.subscription.findRatePlanById(rpc.RatePlanId);
                if(rp != null && !rp.containsRatePlanCharge(rpc.id)) rp.ratePlanCharges.add(rpc);
                ratePlansByRatePlanChargeId.put(rpc.id, rpc.RatePlanId);
            }
        }
        
        Zuora.zObject[] chargeTiers = findRatePlanChargeTiers(ratePlanChargeIds);
        for(Zuora.zObject chargeTier : chargeTiers) {
            ZuoraSubscription.RatePlanChargeTier rpct = new ZuoraSubscription.RatePlanChargeTier(chargeTier);
            String ratePlanId = ratePlansByRatePlanChargeId.get(rpct.RatePlanChargeId);
            if(ratePlanId != null) {
                ZuoraSubscription.RatePlan rp = zuoraSubscription.subscription.findRatePlanById(ratePlanId);
                if(rp != null) {
                    for(ZuoraSubscription.RatePlanCharge rpc : rp.ratePlanCharges) {
                        if(rpc.id == rpct.RatePlanChargeId) {
                            rpc.ratePlanChargeTiers.add(rpct);
                        }
                    }                    
                }
            }
        }


        Set<String> productIds = new Set<String>();
        Map<String, ZuoraSubscription.ProductRatePlan> productRatePlansMap = new Map<String, ZuoraSubscription.ProductRatePlan>();
        for(Zuora.zObject zprp : findProductRatePlans(productRatePlanIds))
        {
            ZuoraSubscription.ProductRatePlan prp = new ZuoraSubscription.ProductRatePlan(zprp);
            productIds.add((String)zprp.getValue('ProductId'));
            productRatePlansMap.put(prp.id, prp);
        }

        Map<String, ZuoraSubscription.Product> productsMap = new Map<String, ZuoraSubscription.Product>();
        for(Zuora.zObject zprod : findProducts(productIds))
        {
            ZuoraSubscription.Product prod = new ZuoraSubscription.Product(zprod);
            productsMap.put(prod.id, prod);
        }

        for(ZuoraSubscription.ProductRatePlan prp : productRatePlansMap.values()) 
        {
            if(productsMap.containsKey(prp.ProductId))
            {
                prp.product = productsMap.get(prp.ProductId);
            }
        }

        Map<String, ZuoraSubscription.ProductRatePlanCharge> productRatePlanChargesMap = new Map<String, ZuoraSubscription.ProductRatePlanCharge>();
        for(Zuora.zObject zprpc : findProductRatePlanCharges(productRatePlanIds))
        {
            ZuoraSubscription.ProductRatePlanCharge prpc = new ZuoraSubscription.ProductRatePlanCharge(zprpc);
            productRatePlanChargesMap.put(prpc.id, prpc);
            if(productRatePlansMap.containsKey(prpc.ProductRatePlanId)) {
                productRatePlansMap.get(prpc.ProductRatePlanId).productRatePlanCharges.add(prpc);
            }
        }

        for(ZuoraSubscription.RatePlan rp : zuoraSubscription.subscription.ratePlans)
        {
            if(rp.ProductRatePlanId != null && productRatePlansMap.containsKey(rp.ProductRatePlanId)) {
                rp.productRatePlan = productRatePlansMap.get(rp.ProductRatePlanId);
    
                system.debug('*** AFTER rp='+rp);
                system.debug('*** AFTER rp.ratePlanCharges='+rp.ratePlanCharges);
                for(ZuoraSubscription.RatePlanCharge rpc : rp.ratePlanCharges)
                {
                    if(rpc.ProductRatePlanChargeId != null && productRatePlanChargesMap.containsKey(rpc.ProductRatePlanChargeId)) {
                        rpc.productRatePlanCharge = productRatePlanChargesMap.get(rpc.ProductRatePlanChargeId);
                    }
                }
            }   
        }

        return zuoraSubscription;
    }

    //update the zuora subscription from the quote id - this future method performs all the post-quote submit Zuora updates necessary
    @future(callout=true)
    public static void updateZuoraSubscription(Id quoteId) 
    {
        zqu__Quote__c qt = [select Id, zqu__ZuoraSubscriptionID__c, Renewal_Subscription_ID__c, zqu__ExistSubscriptionID__c, zqu__Status__c, RecordType.Name, zqu__StartDate__c from zqu__Quote__c where Id = :quoteId];
        String logTitle = 'updateZuoraSubscription: ' + qt.zqu__ZuoraSubscriptionID__c;
        try {
            ZuoraClient.getInstance().updateZuoraSubscription(qt);
            NoteLogger.log(qt.Id, logTitle, 'updateZuoraSubscription completed successfully');
        } catch(ZuoraClientException e) {
            NoteLogger.log(qt.Id, logTitle, e.getMessage() + '\n' + e.getStackTraceString());
        }

        /*
        String logTitle2 = 'updateZuoraSubscriptionChargeTriggerDates: ' + qt.zqu__ZuoraSubscriptionID__c;
        try {
            ZuoraClient.getInstance().updateZuoraSubscriptionChargeTriggerDates(qt);    
            NoteLogger.log(qt.Id, logTitle2, 'updateZuoraSubscriptionChargeTriggerDates completed successfully');
        } catch(ZuoraClientException e) {
            NoteLogger.log(qt.Id, logTitle2, e.getMessage() + '\n' + e.getStackTraceString());
        }
        */
        
        String logTitle3 = 'updateZuoraSubscriptionChargeTPVs: ' + qt.zqu__ZuoraSubscriptionID__c;
        try {
            ZuoraClient.getInstance().updateZuoraSubscriptionChargeTPVs(qt);    
            NoteLogger.log(qt.Id, logTitle3, 'updateZuoraSubscriptionChargeTPVs completed successfully');
        } catch(ZuoraClientException e) {
            NoteLogger.log(qt.Id, logTitle3, e.getMessage() + '\n' + e.getStackTraceString());
        } finally {
            NoteLogger.flush();
        }
        
        //queuable job to update the charge trigger dates
        system.enqueueJob(new UpdateZuoraSubscriptionQueueable(qt.Id));
    }

    public void updateZuoraSubscription(zqu__Quote__c qt) 
    {
        String logTitle = 'updateZuoraSubscription: ' + qt.zqu__ZuoraSubscriptionID__c;
        if(String.isBlank(qt.zqu__ZuoraSubscriptionID__c)) throw new ZuoraClientException('Quote has not been assigned a Zuora Subscription ID');
        if(qt.zqu__Status__c=='New') throw new ZuoraClientException('Quote has not been sent to Z-Billing yet');
        if(String.isBlank(qt.Renewal_Subscription_ID__c)) {
            NoteLogger.log(qt.Id, logTitle, 'Nothing to update');
            return;
        }

        String errors = '';
        //DI 1318: for Renewals
        //if effective date on the quote is < the existing subscription's contract effective date then cancel
        //as of the effective date of the quote.
        Zuora.zObject zsubRec = findSubscription(qt.Renewal_Subscription_ID__c);
        Date subscriptionEndDate = (Date)zsubRec.getValue('SubscriptionEndDate');
        Date quoteStartDate = qt.zqu__StartDate__c;
        
        if(quoteStartDate != null && subscriptionEndDate != null && quoteStartDate < subscriptionEndDate) {
            //create cancel amendment effective on quoteStartDate...
            Zuora.Zapi.AmendResult amendResult = cancelSubscription(qt.Renewal_Subscription_ID__c, quoteStartDate);
            if(!amendResult.Success) {
                String[] messages = new String[]{};
                for(Zuora.zObject err : amendResult.Errors)
                {
                    messages.add((String)err.getValue('Message'));
                }
                errors += 'Failed to cancel subscription: ' + String.join(messages,';');
            }
        }
        
        if(errors != '') throw new ZuoraClientException(errors);

        /*
        Zuora.zObject zsub = new Zuora.zObject('Subscription');
        zsub.setValue('Id', qt.zqu__ZuoraSubscriptionID__c);
        zsub.setValue('OriginalSubscriptionID__c', qt.Renewal_Subscription_ID__c);
        List<Zuora.zApi.SaveResult> saveResults = zupdate(new List<Zuora.zObject>{zsub});
        if(saveResults.isEmpty()) throw new ZuoraClientException('Failed to update subscription');
        Zuora.zApi.SaveResult saveResult = saveResults[0];
        if(!saveResult.Success) {
            String[] messages = new String[]{};
            for(Zuora.zObject err : saveResult.Errors)
            {
                messages.add((String)err.getValue('Message'));
            }
            if(errors != '') errors += '\n';
            errors += 'Failed to update subscription: ' + String.join(messages,';');
        }
        
        if(errors != '') throw new ZuoraClientException(errors);
        */
    }
    
    private Zuora.Zapi.AmendResult cancelSubscription(String subscriptionId, Date effectiveDate) {
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Automatic Cancellation for early renewal');
        amendment.setValue('Type', 'Cancellation');
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('ContractEffectiveDate', Zuora.zUtil.getZuoraDateOnly(effectiveDate));
        amendment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateOnly(effectiveDate));
        amendment.setValue('Description', 'Automatic Cancellation for early renewal');

        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        amendRequest.amendments = new List<Zuora.zObject> {amendment};

        amendRequest.amendOptions = new Zuora.zApi.AmendOptions();
        amendRequest.amendOptions.GenerateInvoice = false;
        amendRequest.amendOptions.ProcessPayments = false;

        return zamend( new list<Zuora.zApi.AmendRequest> { amendRequest } );
    }

/*    
    public void updateZuoraSubscriptionChargeTriggerDates(zqu__Quote__c qt) 
    {
        if(String.isBlank(qt.zqu__ZuoraSubscriptionID__c)) throw new ZuoraClientException('Quote has not been assigned a Zuora Subscription ID');
        if(qt.zqu__Status__c=='New') throw new ZuoraClientException('Quote has not been sent to Z-Billing yet');
        
        Boolean isNew = qt.RecordType.Name == 'Default' || (qt.RecordType.Name == 'ReadOnly' && String.isBlank(qt.Renewal_Subscription_ID__c));
        Boolean isRenewal = qt.RecordType.Name == 'New Renewal' || (qt.RecordType.Name == 'ReadOnly' && !String.isBlank(qt.Renewal_Subscription_ID__c));
        Boolean isAmendment = qt.RecordType.Name == 'Amendment' || qt.RecordType.Name == 'Amendment ReadOnly';

        String logTitle = 'updateZuoraSubscriptionChargeTriggerDates: ' + qt.zqu__ZuoraSubscriptionID__c;
        NoteLogger.log(qt.Id, logTitle, qt.Id+': isNew='+isNew+'; isRenewal='+isRenewal+'; isAmendment='+isAmendment);
        
        //Update subscription charges trigger dates
        //TODO: DI-1350
        //Renewals:
        //  if Renew Add or Renew Unchanged and !Delivered, then set to SED-1month
        //  else set to CED/SAD (the default)
        //Amendments:
        //  if Add or !Delivered, then set to SED-1month
        //  else set to CED/SAD (the default)
        //  
        //Mid-term Annual fees, align date to the trigger date in the old subscription.  I.e. Jun 1/2016....set to Jun 1/2023 when the
        //subscription is renewing on Jan 1/2023

        Set<String> productAdds = new Set<String>();
        Set<String> productUpdates = new Set<String>();
        Map<String, List<Quote_Product__c>> productRatePlanAdds = new Map<String, List<Quote_Product__c>>();
        
        String subscriptionId = qt.zqu__ZuoraSubscriptionID__c; //new subscription
        
        ZuoraSubscription fullZuoraSub = ZuoraClient.getInstance().findZuoraSubscription(subscriptionId);
        ZuoraSubscription existingZuoraSub = null;
        ZuoraSubscriptionState zss = null;
        
        if(isRenewal || isAmendment) {
            //must look at old subscription here vs the quote
            //Load the quote products to get the action
            for(Quote_Product__c qp : [select Action__c, product_rate_Plan__r.zqu__ZuoraId__c, zproduct__r.zqu__ZuoraId__c,
                                       Quote_Rate_Plan__r.Renewal_Rate_Plan_Id__c
                                       from Quote_Product__c where Quote__c = :qt.Id])
            {
                if(qp.Action__c != null && qp.Action__c.contains('Add')) {
                    if((!isRenewal || qp.Quote_Rate_Plan__r.Renewal_Rate_Plan_Id__c == null) && qp.product_rate_Plan__r.zqu__ZuoraId__c != null) {
                        if(productRatePlanAdds.containsKey(qp.product_rate_Plan__r.zqu__ZuoraId__c))
                            productRatePlanAdds.get(qp.product_rate_Plan__r.zqu__ZuoraId__c).add(qp);
                        else
                            productRatePlanAdds.put(qp.product_rate_Plan__r.zqu__ZuoraId__c, new List<Quote_Product__c>{ qp });
                    }
                    else if(qp.zproduct__r.zqu__ZuoraId__c != null && qp.product_rate_plan__c == null) 
                        productAdds.add(qp.zproduct__r.zqu__ZuoraId__c);
                } else if(qp.Action__c != null && qp.Action__c.contains('Update')) {
                    if(qp.zproduct__r.zqu__ZuoraId__c != null)
                        productUpdates.add(qp.zproduct__r.zqu__ZuoraId__c);
                }
            }
            
            NoteLogger.log(qt.Id, logTitle, 'productRatePlanAdds='+JSON.serializePretty(productRatePlanAdds));
            NoteLogger.log(qt.Id, logTitle, 'productAdds='+JSON.serializePretty(productAdds));
            NoteLogger.log(qt.Id, logTitle, 'productUpdates='+JSON.serializePretty(productUpdates));
            
            if(!productUpdates.isEmpty()) {
                //load the previous subscription to determine what has been delivered or not
                String zSubId = isRenewal ? qt.Renewal_Subscription_ID__c : qt.zqu__ExistSubscriptionID__c;
                existingZuoraSub = ZuoraClient.getInstance().findZuoraSubscription(zSubId);
                zss = new ZuoraSubscriptionState(existingZuoraSub);
            }
        }
        
        Zuora.zObject[] zChargeUpdates = new Zuora.zObject[]{};
        for(ZuoraSubscription.RatePlan rp : fullZuoraSub.subscription.ratePlans) {
            String productRatePlanId = null;
            String productId = null;

            if(rp.productRatePlan != null) {
                productRatePlanId = rp.productRatePlan.id;
                productId = rp.productRatePlan.ProductId;
            }
            
            for(ZuoraSubscription.RatePlanCharge rpc : rp.ratePlanCharges) {
                //system.debug(rpc.Id + ' : ' + rpc.zobj.getValue('TriggerEvent') + ' ' + rpc.zobj.getValue('TriggerDate') + ';' + rpc.productRatePlanCharge.zobj.getValue('TriggerEvent'));
                if(rpc.productRatePlanCharge != null)
                {
                    String rpcTriggerEvent = rpc.getStringValue('TriggerEvent');
                    String prpcTriggerEvent = rpc.productRatePlanCharge.getStringValue('TriggerEvent');
                    NoteLogger.log(qt.Id, logTitle, 'rpcTriggerEvent='+rpcTriggerEvent+'; prpcTriggerEvent='+prpcTriggerEvent);
                    Boolean isDelivered = false;
                    
                    if((prpcTriggerEvent == 'Upon Service Activation' || prpcTriggerEvent == 'ServiceActivation') && rpcTriggerEvent != 'SpecificDate')
                    {
                        //if Segment > 1 then we avoid this error: Cannot change the trigger date for the charge that has multiple segments.
                        //i.e. if any amendments have occurred on the charge
                        //DI-1350 - determine whether to update or not based on 
                        //and whether this is an Add
                        Boolean updateChargeTriggerDate = false;
                        if(isNew) updateChargeTriggerDate = true;
                        else if(isRenewal || isAmendment) {
                            if(rpc.Segment == null || rpc.Segment < 2) {
                                //adds
                                if((productId != null && productAdds.contains(productId)) || (productRatePlanId != null && productRatePlanAdds.containsKey(productRatePlanId))) {
                                    //TODO: check that the QP.QRP.Renewal_Rate_Plan_Id__c is null so we are only updating trigger date
                                    //on undelivered (i.e. new) charges, or that this is an increase in quantity on the same charge
                                    for(Quote_Product__c qp : productRatePlanAdds.get(productRatePlanId)) {
                                        if(qp.Quote_Rate_Plan__r.Renewal_Rate_Plan_Id__c == null) {
                                            updateChargeTriggerDate = true;
                                        }
                                    }
                                }
                                
                                //update
                                if(productId != null && productUpdates.contains(productId) && !updateChargeTriggerDate) {
                                    //review old subscription charges
                                    ZuoraSubscriptionState.Product zssProduct = zss.productsByZID.get(productId);
                                    if(zssProduct != null) {
                                        isDelivered = zssProduct.anyDelivered;
                                    }
                                    if(!isDelivered) updateChargeTriggerDate = true;
                                    else{
                                        NoteLogger.log(qt.Id, logTitle, 'Skipping update because there are charges delivered for '+productId);
                                    }
                                }

                            }else{
                                NoteLogger.log(qt.Id, logTitle, 'Skipping because there are multiple segments.  Segment='+rpc.Segment);
                            }    
                        }
                        
                        if(updateChargeTriggerDate && !isDelivered) {
                            Date triggerDate = (Date)fullZuoraSub.subscription.zobj.getValue('SubscriptionEndDate');
                            triggerDate = triggerDate.addDays(-30);
                            Zuora.zObject rpcUpdate = new Zuora.zObject('RatePlanCharge');
                            rpcUpdate.setValue('Id', rpc.Id);
                            rpcUpdate.setValue('TriggerEvent','SpecificDate');
                            rpcUpdate.setValue('TriggerDate', Zuora.zUtil.getZuoraDateOnly(triggerDate));  
                            zChargeUpdates.add(rpcUpdate);
                        }
                    }
                }
            }
        }
        if(!zChargeUpdates.isEmpty()) {
            Zuora.zApi.SaveResult[] chargeSaveResults = ZuoraClient.getInstance().zupdate(zChargeUpdates);
            for(Zuora.zApi.SaveResult chargeSaveResult : chargeSaveResults) {
                if(!chargeSaveResult.Success) {
                    String[] errMessages = new String[]{};
                    for(Zuora.zObject err : chargeSaveResult.Errors)
                    {
                        errMessages.add((String)err.getValue('Message'));
                    }
                    throw new ZuoraClientException('Failed to update charge trigger dates: ' + String.join(errMessages,';'));
                }else{
                    NoteLogger.log(qt.Id, logTitle, 'Successfully updated ' + chargeSaveResults);
                }
            }
        }else{
            NoteLogger.log(qt.Id, logTitle, 'No charges to update');
        }
    }
*/
    public void updateZuoraSubscriptionChargeTPVs(zqu__Quote__c qt)
    {
        String subId = qt.zqu__ZuoraSubscriptionID__c;
        String logTitle = 'updateZuoraSubscriptionChargeTPVs: ' + subId;
        
        ZuoraSubscription zuoraSubscription = ZuoraClient.getInstance().findZuoraSubscription(subId);
        ZuoraSubscriptionState zssOnOriginal = new ZuoraSubscriptionState(zuoraSubscription);
        zssOnOriginal.addOriginalQuote(qt);
        system.debug(zssOnOriginal.var_dump());
        Map<String, Map<String,Object>> zchargeUpdates = zssOnOriginal.getRatePlanChargeTPVUpdates();
        if(!zchargeUpdates.isEmpty()) {
            List<Zuora.zObject> zchargeUpdatesLst = new List<Zuora.zObject>();
            for(Map<String,Object> zcu : zchargeUpdates.values()) {
                Zuora.zObject rpcUpdate = new Zuora.zObject('RatePlanCharge');
                rpcUpdate.setValue('Id', (String)zcu.get('Id'));
                rpcUpdate.setValue('ThirdPartyVendor__c', (String)zcu.get('ThirdPartyVendor__c'));
                zchargeUpdatesLst.add(rpcUpdate);
            }
            
            Zuora.zApi.SaveResult[] chargeSaveResults = ZuoraClient.getInstance().zupdate(zchargeUpdatesLst);
            integer i = 0;
            for(Zuora.zApi.SaveResult chargeSaveResult : chargeSaveResults) {
                if(!chargeSaveResult.Success) {
                    String[] errMessages = new String[]{};
                    for(Zuora.zObject err : chargeSaveResult.Errors)
                    {
                        errMessages.add((String)err.getValue('Message'));
                    }
                    throw new ZuoraClientException('Failed to update charge TPV: ' + zchargeUpdatesLst[i].getValue('Id') + ': ' + String.join(errMessages,';'));
                }else{
                    NoteLogger.log(qt.Id, logTitle, 'Successfully updated charge TPV:' + zchargeUpdatesLst[i].getValue('Id') + ': ' + zchargeUpdatesLst[i].getValue('ThirdPartyVendor__c'));
                }
                i++;
            }
        }
    }

        @future(callout=true)
        public static void updateZuoraAccount(Id quoteId)
        {
            zqu__Quote__c qt = [select Id, zqu__ZuoraSubscriptionID__c, zqu__ZuoraAccountID__c, zqu__Account__c, zqu__Account__r.DI_Customer__c, 
            zqu__Account__r.DPV_Interface__r.Solution_Provider_Product__c,
            zqu__Status__c from zqu__Quote__c where Id = :quoteId];
            String logTitle = 'updateZuoraAccount: ' + qt.zqu__ZuoraAccountID__c;
            try {
                ZuoraClient.getInstance().updateZuoraAccount(qt);
                NoteLogger.log(qt.Id, logTitle, 'updateZuoraAccount completed successfully');
            } catch(ZuoraClientException e) {
                NoteLogger.log(qt.Id, logTitle, e.getMessage() + '\n' + e.getStackTraceString());
            } finally {
                NoteLogger.flush();
            }
        }

        public void updateZuoraAccount(zqu__Quote__c qt) {

/*
DI-1147
We expect that when a quote is submitted on a *new* account (Zuora account does not yet exist), that a trigger in Salesforce 
will sync the Account.DI_Customer__c to the newly created Zuora account's Account.diNumber__c field.

DI-1148
We expect that when a quote is submitted on an existing Zuora account, that a trigger in Salesforce will sync the 
Account.DPV_Interface__r.Solution_Provider_Product__c to the Zuora account's Account.DPVCode__c field.
*/              
            if(qt.zqu__Status__c == 'Sent to Z-Billing' && !String.isBlank(qt.zqu__ZuoraAccountID__c) && 
                !String.isBlank(qt.zqu__ZuoraSubscriptionID__c) && !String.isBlank(qt.zqu__ZuoraAccountID__c)) {
                
                boolean sendUpdate = false;
                
                //DI-1147
            Zuora.zObject zAccount = new Zuora.zObject('Account');
            zAccount.setValue('Id', qt.zqu__ZuoraAccountID__c);
                if(!String.isBlank(qt.zqu__Account__r.DI_Customer__c)) 
                {
                zAccount.setValue('diNumber__c', qt.zqu__Account__r.DI_Customer__c);
                sendUpdate = true;
                }

                //DI-1148
                if(!String.isBlank(qt.zqu__Account__r.DPV_Interface__r.Solution_Provider_Product__c))
                {
                zAccount.setValue('DPVCode__c', qt.zqu__Account__r.DPV_Interface__r.Solution_Provider_Product__c);
                sendUpdate = true;
                }

                if(sendUpdate) 
                {
                Zuora.zApi.SaveResult[] saveResults = zupdate(new Zuora.zObject[]{ zAccount });
                if(!saveResults[0].Success) 
                {
                    String[] errMessages = new String[]{};
                    for(Zuora.zObject err : saveResults[0].Errors)
                    {
                        errMessages.add((String)err.getValue('Message'));
                    }
                    throw new ZuoraClientException('Failed to update zuora account: ' + String.join(errMessages,';'));
                }
                }
            }
        }

    public class ZuoraMockClient extends ZuoraClient implements IZuoraClient 
    {
        public Map<String, List<Zuora.zObject>> data {get;set;}
        public ZuoraMockClient()
        {
            this.data = new Map<String, List<Zuora.zObject>>();
        }
        
        public void addData(String ztype, Zuora.zObject zobject)
        {
            if(!this.data.containsKey(ztype.toLowerCase())) this.data.put(ztype.toLowerCase(), new List<Zuora.zObject>{zobject});
            else this.data.get(ztype.toLowerCase()).add(zobject);
        }
        
        public Zuora.zObject get(String ztype, Integer arrayIndex) {
            if(this.data.containsKey(ztype.toLowerCase())) {
                if(this.data.get(ztype.toLowerCase()).size() > arrayIndex) return this.data.get(ztype.toLowerCase())[arrayIndex];
            }
            return null;
        }

        public Zuora.zObject getFirst(String ztype) {
            return get(ztype, 0);
        }

        //mock implementation of zquery
        public override List<Zuora.ZObject> zquery(string zoql) 
        {
            super.zquery(zoql);//for test coverage
            system.debug('zquery: ' + zoql);
            if(String.isBlank(zoql)) return new List<Zuora.zObject>();
            for(String table : data.keySet()) 
            {
                if(zoql.toLowerCase('en').contains(' from ' + table + ' '))
                {
                    List<Zuora.zObject> results = new List<Zuora.zObject>();
                    for(Zuora.zObject zobj : data.get(table)) 
                    {
                        results.add(zobj);
                    }
                    system.debug('returning ' + results.size() + ' results');
                    return results;
                }
            }
            system.debug('no match, returning 0 results');
            return new List<Zuora.zObject>();
        }

        public override List<Zuora.zApi.SaveResult> zupdate(List<Zuora.ZObject> zobjects)
        {
            super.zupdate(zobjects);
            List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
            for(Zuora.zObject zobj : zobjects){
                Zuora.zApi.SaveResult saveResult = new Zuora.zApi.SaveResult();
                saveResult.Success = true;
                results.add(saveResult);
            }
            return results;
        }

        public override Zuora.zApi.AmendResult zamend(List<Zuora.zApi.AmendRequest> requests)
        {
            super.zamend(requests);
            Zuora.zApi.AmendResult amendResult = new Zuora.zApi.AmendResult();
            amendResult.Success = true;
            return amendResult;
        }

    }
    
    //zquery implementation
    public virtual List<Zuora.ZObject> zquery(string zoql)
    {
        List<Zuora.zObject> results = Test.isRunningTest() ? new List<Zuora.zObject>() : getZuoraAPIInstance().zquery(zoql);
        zlogger();
        return results;
    }

    //zamend implementation
    public virtual Zuora.zApi.AmendResult zamend(List<Zuora.zApi.AmendRequest> requests)
    {
        try
        {
            System.Debug('*** zcallout, amend: ' + requests);
            Zuora.zApi.AmendResult result = (!Test.isRunningTest()) ? getZuoraAPIInstance().zamend(requests) : new Zuora.zApi.AmendResult();
            return result;
        }
        finally
        {
            zlogger();
        }
    }    
    
    @future (callout=true)  
    public static void activateSubscription(string subscriptionId, Datetime serviceActivationDate)
    {
        try {
            ZuoraClient.getInstance().activateSubscriptionCall(subscriptionId, serviceActivationDate);
            //NoteLogger.log(subscriptionId, logTitle, 'activateSubscription completed successfully');
        } catch(ZuoraClientException e) {
            //NoteLogger.log(subscriptionId, logTitle, e.getMessage() + '\n' + e.getStackTraceString());
        } finally {
                        //NoteLogger.flush();
                        }
    }
    
    //Sets the service activation date for a provided subscription. 
    public void activateSubscriptionCall(string subscriptionId, Datetime serviceActivationDate)
    {  
        //Correct for timezone offset
        TimeZone tz = System.UserInfo.getTimeZone();        
        serviceActivationDate = serviceActivationDate.addHours(tz.getOffSet(serviceActivationDate)/-MILLISECONDS_PER_HOUR);
        
        Zuora.zObject zsub = new Zuora.zObject('Subscription');
        zsub.setValue('Id', subscriptionId);
        zsub.setValue('ServiceActivationDate', serviceActivationDate.format('yyyy-MM-dd'));                      
        List<Zuora.zApi.SaveResult> saveResults = zupdate(new List<Zuora.zObject>{zsub});
        
        //should we handle errors here ?        
        //If the date is before the contract effective date "The Service Activation Date must be later than the Contract Effective Date."
        //If past the subscription end date? "The Service Activation Date cannot be later than the end of the current subscription term (05/15/2023)."
        //Subscription already active "Can not update this subscripton's service activation date, because there are some charges have been invoiced."
        //Bad subscription ID "invalid id for update"
    }
    
    //zupdate implementation
    public virtual List<Zuora.zApi.SaveResult> zupdate(List<Zuora.ZObject> zobjects)
    {
        try {
            if(zobjects == null) return null;
            List<Zuora.zApi.SaveResult> fullResults = new List<Zuora.zApi.SaveResult>();
            List<List<Zuora.zObject>> batches = new List<List<Zuora.zObject>>();
            if(zobjects.size() > MAX_UPDATE_BATCH_SIZE) {
                for(integer i=0; i<zobjects.size();i++) {
                    if(Math.mod(i, MAX_UPDATE_BATCH_SIZE) == 0) {
                        batches.add(new List<Zuora.zObject>{ zobjects[i] });
                    }else{
                        batches.get(i/MAX_UPDATE_BATCH_SIZE).add(zobjects[i]);
                    }
                }
            }else{
                batches.add(zobjects);
            }
            for(List<Zuora.zObject> batch : batches)
            {
                system.debug('**** batch size='+batch.size());
                List<Zuora.zApi.SaveResult> results = (!Test.isRunningTest()) ? getZuoraAPIInstance().zupdate(batch) : new List<Zuora.zApi.SaveResult>();
                fullResults.addAll(results);    
            }
            return fullResults; 
        } finally {
            zlogger();
        }   
    }

    private static String enquote(String s)
    {
        return '\'' + s + '\'';
    }
    
    private static void zlogger()
    {
        system.debug( '*** zlogger = ' + (Zuora.zApi.currentLogger != null ? Zuora.zApi.currentLogger.toString() : 'n/a') );
    }

    //generate an OR clause from a list of values
    public static String generateOrClause(String filterField, List<String> filterValues) 
    {
        if (filterValues == null || filterValues.isEmpty()) return '';
        else {
            string prefix = filterField + ' = \'';
            return prefix + String.join(filterValues, '\' OR ' + prefix) + '\'';
        }
    }
    //Exception class
    public class ZuoraClientException extends Exception {}
}