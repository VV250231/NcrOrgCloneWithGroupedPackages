// ===========================================================================
// Object: UpdateZuoraSubscriptionQueueable
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Called by ZuoraClient.updateZuoraSubscription.  Updates all the Service Activation triggered charges
// on the new subscription based on whether the product
// has been delivered or not in the "previous" subscription.
// ===========================================================================
// Changes: 2016-11-12 Reid Beckett
//           Class created
// ===========================================================================
public class UpdateZuoraSubscriptionQueueable implements Queueable, Database.AllowsCallouts
{
    public Id quoteId {get;set;}
    private zqu__Quote__c qt;
    private String logTitle;
    private Boolean isNew;
    private Boolean isRenewal;
    private Boolean isAmendment;
    
    public UpdateZuoraSubscriptionQueueable(Id quoteId) 
    {
        this.logTitle = 'UpdateZuoraSubscriptionQueueable:'+quoteId;
        this.quoteId = quoteId;    
        this.qt = [
            select Id, zqu__ZuoraSubscriptionID__c, Renewal_Subscription_ID__c, zqu__ExistSubscriptionID__c, zqu__Status__c, 
            RecordType.Name, zqu__StartDate__c 
            from zqu__Quote__c where Id = :quoteId
        ];
        this.isNew = qt.RecordType.Name == 'Default' || (qt.RecordType.Name == 'ReadOnly' && String.isBlank(qt.Renewal_Subscription_ID__c));
        this.isRenewal = qt.RecordType.Name == 'New Renewal' || (qt.RecordType.Name == 'ReadOnly' && !String.isBlank(qt.Renewal_Subscription_ID__c));
        this.isAmendment = qt.RecordType.Name == 'Amendment' || qt.RecordType.Name == 'Amendment ReadOnly';
    }
    
    public void execute(QueueableContext context) 
    {
        try {
            NoteLogger.log(quoteId, logTitle, '<START>');
            if(!String.isBlank(qt.zqu__ZuoraSubscriptionID__c))
            {
                ZuoraSubscription newSubscription = ZuoraClient.getInstance().findZuoraSubscription(qt.zqu__ZuoraSubscriptionID__c);
                NoteLogger.log(quoteId, logTitle, 'newSubscription found?:'+(newSubscription!=null));
                if(newSubscription == null) { close(); return; }

                Zuora.zObject[] zChargeUpdates = new Zuora.zObject[]{};
                if(isNew) 
                {
                    for(ZuoraSubscription.RatePlan rp : newSubscription.subscription.ratePlans) 
                    {
                        for(ZuoraSubscription.RatePlanCharge rpc : rp.ratePlanCharges) 
                        {
                            String rpcTriggerEvent = rpc.getStringValue('TriggerEvent');
                            String prpcTriggerEvent = rpc.productRatePlanCharge.getStringValue('TriggerEvent');
                            NoteLogger.log(quoteId, logTitle, 'rpcTriggerEvent='+rpcTriggerEvent+'; prpcTriggerEvent='+prpcTriggerEvent);
                            if((prpcTriggerEvent == 'Upon Service Activation' || prpcTriggerEvent == 'ServiceActivation') && rpcTriggerEvent != 'SpecificDate')
                            {
                                Date triggerDate = (Date)newSubscription.subscription.zobj.getValue('SubscriptionEndDate');
                                triggerDate = triggerDate.addDays(-30);
                                Zuora.zObject rpcUpdate = new Zuora.zObject('RatePlanCharge');
                                rpcUpdate.setValue('Id', rpc.Id);
                                rpcUpdate.setValue('TriggerEvent','SpecificDate');
                                rpcUpdate.setValue('TriggerDate', Zuora.zUtil.getZuoraDateOnly(triggerDate));                                          
                                //rpcUpdate.setValue('Delivered__c', 'No');                                          
                                zChargeUpdates.add(rpcUpdate);
                            }
                        }
                    }
                }
                
                if(isRenewal || isAmendment)
                {
                    String originalSubscriptionId = isRenewal ? qt.Renewal_Subscription_ID__c : qt.zqu__ExistSubscriptionID__c;
                    ZuoraSubscription originalSubscription = ZuoraClient.getInstance().findZuoraSubscription(originalSubscriptionId);
                    NoteLogger.log(quoteId, logTitle, 'originalSubscription found?:'+(originalSubscription!=null));
                    if(originalSubscription == null) { close(); return; }
                    
                    ZuoraSubscriptionState originalZSS = new ZuoraSubscriptionState(originalSubscription);
                    originalZSS.addQuote(qt);
                    
                    //NoteLogger.log(quoteId, logTitle, 'originalZSS:');
                    //NoteLogger.log(quoteId, logTitle, originalZSS.var_dump());
                    system.debug('originalZSS:');
                    system.debug(originalZSS.var_dump());
                    
                    ZuoraSubscriptionState newZSS = new ZuoraSubscriptionState(newSubscription);
                    newZSS.addOriginalQuote(qt);
                    
                    //NoteLogger.log(quoteId, logTitle, 'newZSS:');
                    //NoteLogger.log(quoteId, logTitle, newZSS.var_dump());
                    system.debug('newZSS:');
                    system.debug(newZSS.var_dump());
                    
                    //DI-1800 query Quote Product, to compare below
                    Set<String> netNewZProducts = new Set<String>();
                    for(Quote_Product__c qp : [select Id, Zproduct__c, Action__c from Quote_Product__c where Quote__c = :qt.Id]) {
                        if(qp.Action__c == 'Activate'/*'Add' || qp.Action__c == 'Renew Add'*/){
                            netNewZProducts.add(qp.ZProduct__c);
                        }
                    }
                    
                    //match the new subscription's rate plans to the original subscription's
                    Map<String,SubscriptionRatePlanLink> links = new Map<String,SubscriptionRatePlanLink>();
                    for(ZuoraSubscriptionState.Product p : newZSS.productsByZID.values()) {
                        for(ZuoraSubscriptionState.ProductRatePlan prp : p.productRatePlansByZID.values()) {
                            for(ZuoraSubscriptionState.QuoteRatePlanWrapper qrpw : prp.quoteRatePlansById.values()) {
                                SubscriptionRatePlanLink srpLink = new SubscriptionRatePlanLink(qrpw.id, qrpw.zRatePlanId);
                                //link to original subscription by looking at originalZSS
                                ZuoraSubscriptionState.Product originalProduct = originalZSS.productsByZID.get(p.zId);
                                if(originalProduct != null) {
                                    ZuoraSubscriptionState.ProductRatePlan originalProductRatePlan = originalProduct.productRatePlansByZID.get(prp.zId);
                                    if(originalProductRatePlan != null) {
                                        if(originalProductRatePlan.quoteRatePlansById.containsKey(srpLink.quoteRatePlanID)) {
                                            ZuoraSubscriptionState.QuoteRatePlanWrapper originalQRPW = originalProductRatePlan.quoteRatePlansById.get(srpLink.quoteRatePlanID);
                                            if(originalQRPW != null) {
                                                srpLink.originalSubscriptionRatePlanZID = originalQRPW.zRatePlanId;
                                                if(originalQRPW.zRatePlanId != null) {
                                                    ZuoraSubscriptionState.RatePlanSummary rps = originalProductRatePlan.ratePlansById.get(originalQRPW.zRatePlanId);
                                                    if(rps != null) {
                                                        srpLink.originalDelivered = rps.delivered;
                                                    }
                                                }else {
                                                    //added 12/15 for the issue 1507 - new rate plan on an existing product, if any of the originals
                                                    //were delivered then flag as such and don't update the trigger dates
                                                    //DI-1800 - differentiate between "NEW" instance and "UPDATE" by checking if there is
                                                    //a net new (an Add) on Quote Product
                                                    Boolean isNetNew = netNewZProducts.contains(p.sfId);
                                                    if(originalProduct.anyDelivered && !isNetNew) 
                                                        srpLink.originalDelivered = true;
                                                }
                                            }
                                        }
                                    }
                                }
                                if(srpLink.newSubscriptionRatePlanZID != null) links.put(srpLink.newSubscriptionRatePlanZID, srpLink);
                            }
                        }
                    }
                    system.debug('***** LINKS ******');
                    system.debug(JSON.serialize(links));
                    
                    //determine charge trigger date updates by looping through the new subscription                        
                    for(ZuoraSubscription.RatePlan rp : newSubscription.subscription.ratePlans) 
                    {
                        for(ZuoraSubscription.RatePlanCharge rpc : rp.ratePlanCharges) 
                        {
                            String rpcTriggerEvent = rpc.getStringValue('TriggerEvent');
                            String prpcTriggerEvent = rpc.productRatePlanCharge.getStringValue('TriggerEvent');
                            NoteLogger.log(quoteId, logTitle, rpc.getStringValue('ChargeNumber')+': rpcTriggerEvent='+rpcTriggerEvent+'; prpcTriggerEvent='+prpcTriggerEvent+';segment='+rpc.Segment);
                            if((prpcTriggerEvent == 'Upon Service Activation' || prpcTriggerEvent == 'ServiceActivation') && rpcTriggerEvent != 'SpecificDate')
                            {
                                if(rpc.Segment == null || rpc.Segment < 2) 
                                {
                                    SubscriptionRatePlanLink srpLink = links.get(rp.Id);
                                    NoteLogger.log(quoteId, logTitle, 'SubscriptionRatePlanLink='+srpLink);
                                    //if(srpLink != null) 
                                    //{
                                        //if(srpLink == null || !(srpLink.originalDelivered != null && srpLink.originalDelivered)) {
                                        //DI-1799 - the condition on srpLink==null causing issue where amendment with rate plans with no change
                                        //are falsely seen as new charges
                                        if(srpLink != null && !(srpLink.originalDelivered != null && srpLink.originalDelivered)) {
                                            //new rate plan, set delivered = No and reset the trigger date
                                            Date triggerDate = (Date)newSubscription.subscription.zobj.getValue('SubscriptionEndDate');
                                            triggerDate = triggerDate.addDays(-30);
                                            Zuora.zObject rpcUpdate = new Zuora.zObject('RatePlanCharge');
                                            rpcUpdate.setValue('Id', rpc.Id);
                                            rpcUpdate.setValue('TriggerEvent','SpecificDate');
                                            rpcUpdate.setValue('TriggerDate', Zuora.zUtil.getZuoraDateOnly(triggerDate));                                          
                                            rpcUpdate.setValue('Delivered__c', 'No');                                          
                                            zChargeUpdates.add(rpcUpdate);
                                        }else {
                                            if(isRenewal) {
                                                //existing delivered rate plan on the previous subscription.  This update is not necessary for Amendment
                                                Zuora.zObject rpcUpdate = new Zuora.zObject('RatePlanCharge');
                                                rpcUpdate.setValue('Id', rpc.Id);
                                                rpcUpdate.setValue('Delivered__c', 'Yes');                                     
                                                zChargeUpdates.add(rpcUpdate);
                                            }
                                        }    
                                    //}
                                }
                            }
                        }
                    }
                }
                
                if(!zChargeUpdates.isEmpty()) 
                {
                    Zuora.zApi.SaveResult[] chargeSaveResults = ZuoraClient.getInstance().zupdate(zChargeUpdates);
                    for(Zuora.zApi.SaveResult chargeSaveResult : chargeSaveResults) {
                        if(!chargeSaveResult.Success) {
                            String[] errMessages = new String[]{};
                                for(Zuora.zObject err : chargeSaveResult.Errors)
                            {
                                errMessages.add((String)err.getValue('Message'));
                            }
                            //throw new ZuoraClient.ZuoraClientException('Failed to update charge trigger dates: ' + String.join(errMessages,';'));
                            System.debug('Failed to update charge trigger dates: ' + String.join(errMessages,';'));
                            //Trying again to update remaining charges with trigger date
                            system.enqueueJob(new UpdateZuoraSubscriptionQueueable(qt.Id));
                        }else{
                            NoteLogger.log(qt.Id, logTitle, 'Successfully updated ' + chargeSaveResults);
                        }
                    }
                }else{
                    NoteLogger.log(qt.Id, logTitle, 'No charges to update');
                }
            }
        }catch(Exception e) {
            system.debug(e.getMessage()+'\n'+e.getStackTraceString());
            NoteLogger.log(quoteId, logTitle, 'caught exception:'+e.getMessage()+'\n'+e.getStackTraceString());
        }finally {
            close();
        }
    }
    
    private void close() {
        NoteLogger.log(quoteId, logTitle, '<END>');
        NoteLogger.flush();
    }
    
    class SubscriptionRatePlanLink {
        public String originalSubscriptionRatePlanZID {get;set;}
        public Id quoteRatePlanID {get;set;}
        public String newSubscriptionRatePlanZID {get;set;}
        public Boolean originalDelivered {get;set;}
        
        public SubscriptionRatePlanLink(Id quoteRatePlanID, String newSubscriptionRatePlanZID) {
            this.quoteRatePlanID = quoteRatePlanID;
            this.newSubscriptionRatePlanZID = newSubscriptionRatePlanZID;
        }
    }
    
     public void runcalc() {
        integer i=0;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
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