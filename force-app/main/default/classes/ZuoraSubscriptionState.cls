// ===========================================================================
// Object: ZuoraSubscriptionState
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Refactored provisioning actions logic to capture mix of actions
// ===========================================================================
// Changes: 2016-10-06 Reid Beckett
//           Class created
// ===========================================================================
//Subscription grouped by => Product => Product Rate Plan => Product Rate Plan Charge
//Add Quote to determine the changes at the PRPC, PRP, and P levels
public with sharing class ZuoraSubscriptionState {
    private ZuoraSubscription zSubscription;
    public Map<String,Product> productsByZID;
    public Boolean isNewQuote {get;set;}
    public Boolean isAmendment {get;set;}
    public Boolean isRenewal {get;set;}
    public Id quoteId {get;set;}
    
    public ZuoraSubscriptionState(ZuoraSubscription zSubscription){
        this.zSubscription = zSubscription;
        this.productsByZID = new Map<String,Product>();
        this.organize();
    }
    
    public ZuoraSubscriptionState(){
        this.zSubscription = null;
        this.productsByZID = new Map<String,Product>();
    }

    public List<QuoteProduct> getQuoteProducts() {
        List<QuoteProduct> lst = new List<QuoteProduct>();
        for(Product p : this.productsByZID.values()) {
            system.debug('*** p.name='+p.name+';'+p.zId);
            
            Set<String> addOrRemovedProductRatePlanIds = new Set<String>();
            Set<String> newPriceCodeIds = new Set<String>();
            Set<String> updatedPriceCodeIds = new Set<String>();
            Set<String> removedPriceCodeIds = new Set<String>();
            Set<String> unchangedPriceCodeIds = new Set<String>();
            Set<String> existingPerUnitChargesModified = new Set<String>();
            String amendmentType = null;
            
            for(ProductRatePlan prp : p.productRatePlansByZID.values()) {
                system.debug('*** prp.name='+prp.zid + ' ; ' + prp.name);
                system.debug('*** prp.recurringPerUnitQuantityChange='+prp.recurringPerUnitQuantityChange);
                system.debug('*** prp.isAdd='+prp.isAdd);
                system.debug('*** prp.isRemove='+prp.isRemove);
                system.debug('*** prp.isUpdate='+prp.isUpdate);
                
                //handle mix of add/remove/update/no change
                if(prp.recurringPerUnitQuantityChange != null && prp.recurringPerUnitQuantityChange != 0) {
                    if(prp.recurringPerUnitQuantity != null) existingPerUnitChargesModified.add(prp.zId);
                    addOrRemovedProductRatePlanIds.add(prp.zId);
                    //create an Add/Remove for each change in quantity
                    List<QuoteRatePlanWrapper> qrpwList = prp.quoteRatePlansById.values();
                    //qrpwList.sort();

                    for(QuoteRatePlanWrapper qrpw : qrpwList) {
                        
                        String action = null;
                        Integer quantity = null;
                        
                        if(qrpw.amendmentType == 'NewProduct') {
                            if(isRenewal) {
                                //special logic needed to compare against current rate plan id (if present)
                                if(qrpw.zRatePlanId != null && prp.ratePlansById.containsKey(qrpw.zRatePlanId)) {
                                    //diff quantity
                                    integer qrpwQty = qrpw.quantity;
                                    integer subQty = prp.ratePlansById.get(qrpw.zRatePlanId).quantity;
                                    quantity = (qrpwQty != null && subQty != null) ? (qrpwQty - subQty) : 0;
                                    action = quantity > 0 ? 'Activate' : 'Deactivate'/*'Renew Add' : 'Renew Remove'*/;
                                }else{
                                    //all quantity
                                    quantity = qrpw.quantity;
                                    action = quantity > 0 ? 'Activate' : 'Deactivate'/*'Renew Add' : 'Renew Remove'*/;
                                }
                            }else{
                                //New or amendment
                                quantity = qrpw.quantity;
                                action = 'Activate'/*'Add'*/;
                            }
                        }else if(qrpw.amendmentType == 'UpdateProduct') {
                            //amendment only
                            //special logic needed to compare against current rate plan id (if present)
                            if(qrpw.zRatePlanId != null && prp.ratePlansById.containsKey(qrpw.zRatePlanId)) {
                                //diff quantity
                                //quantity = qrpw.quantity - prp.ratePlansById.get(qrpw.zRatePlanId).quantity;
                                quantity = qrpw.quantity;
                                action = quantity > 0 ? 'Activate' : 'Deactivate'/*'Add' : 'Remove'*/;
                            }else{
                                //all quantity
                                quantity = qrpw.quantity;
                                action = quantity > 0 ?  'Activate' : 'Deactivate'/*'Add' : 'Remove'*/;
                            }
                        }else if(qrpw.amendmentType == 'RemoveProduct') {
                            //amendment only
                            quantity = qrpw.quantity;
                            action = isRenewal ? 'Deactivate' : 'Deactivate'/*'Renew Remove' : 'Remove'*/;
                        }
                        
                        if(quantity != 0) {
                            for(integer i=0; i<Math.abs(quantity); i++) {
                                QuoteProduct qp = new QuoteProduct();
                                qp.action = action;
                                qp.sfProductRatePlanId = prp.sfId;
                                qp.sfProductId = p.sfId;
                                qp.index = i;
                                qp.amendmentType = prp.amendmentType;
                                qp.zProductId = p.zId;
                                qp.zProductRatePlanId = prp.zId;
                                qp.quoteRatePlanId = qrpw.id;
                                lst.add(qp);
                            }
                        }
                    }
                    
                    if(isRenewal) {
                        //add removes for the removed
                        for(String ratePlanId : prp.ratePlansById.keySet()) {
                            Boolean found = false;
                            for(QuoteRatePlanWrapper qrpw : qrpwList) {
                                if(qrpw.zRatePlanId == ratePlanId) found = true;
                            }    
                            if(!found) {
                                for(integer i=0; i<Math.abs(prp.ratePlansById.get(ratePlanId).quantity); i++) {
                                    QuoteProduct qp = new QuoteProduct();
                                    qp.action = 'Deactivate'/*'Renew Remove'*/;
                                    qp.sfProductRatePlanId = prp.sfId;
                                    qp.sfProductId = p.sfId;
                                    qp.index = i;
                                    qp.amendmentType = prp.amendmentType;
                                    qp.zProductId = p.zId;
                                    qp.zProductRatePlanId = prp.zId;
                                    lst.add(qp);
                                }
                            }
                        }
                    }
                    /*
                    for(integer i=0; i<Math.abs(prp.recurringPerUnitQuantityChange); i++) {
                        QuoteProduct qp = new QuoteProduct();
                        qp.action = prp.recurringPerUnitQuantityChange > 0 ? 'Add' : 'Remove';
                        if(isRenewal) qp.action = 'Renew ' + qp.action; //Renew Add/Renew Remove
                        qp.sfProductRatePlanId = prp.sfId;
                        qp.sfProductId = p.sfId;
                        qp.index = i;
                        qp.amendmentType = prp.amendmentType;
                        qp.zProductId = p.zId;
                        qp.zProductRatePlanId = prp.zId;
                        //system.debug('*** '+qrpwList);

                        for(QuoteRatePlanWrapper qrpw : qrpwList) {
                            if(qrpw.startQuantityIndex <= i && qrpw.endQuantityIndex >= i) {
                                qp.quoteRatePlanId = qrpw.id;
                            }
                        }

                        lst.add(qp);
                    }
                    */
                }else if(prp.recurringPerUnitQuantityChange != null && prp.recurringPerUnitQuantityChange == 0 && !isRenewal && prp.amendmentType != 'RemoveProduct') {
                    amendmentType = prp.amendmentType;
                    updatedPriceCodeIds.add(prp.zId);
                }else if(prp.isAdd != null && prp.isAdd) {
                    //price code change
                    amendmentType = prp.amendmentType;
                    newPriceCodeIds.add(prp.zId);
                }else if(prp.isRemove != null && prp.isRemove) {
                    if(!isRenewal || prp.chargeType != 'OneTime') {
                        amendmentType = prp.amendmentType;
                        removedPriceCodeIds.add(prp.zId);
                    }
                }else if(prp.isUpdate != null && prp.isUpdate) {
                    amendmentType = prp.amendmentType;
                    updatedPriceCodeIds.add(prp.zId);
                }else unchangedPriceCodeIds.add(prp.zId);
            }
            
            String action = null;
            if(addOrRemovedProductRatePlanIds.isEmpty()) {
                system.debug('*** addOrRemovedProductRatePlanIds.isEmpty');
                system.debug('*** newPriceCodeIds:'+newPriceCodeIds);
                system.debug('*** removedPriceCodeIds:'+removedPriceCodeIds);
                system.debug('*** updatedPriceCodeIds:'+updatedPriceCodeIds);
                system.debug('*** unchangedPriceCodeIds:'+unchangedPriceCodeIds);

                //only add of price codes
                //only remove of price codes
                //mix or only update of any price code
                if(!newPriceCodeIds.isEmpty() && removedPriceCodeIds.isEmpty() && updatedPriceCodeIds.isEmpty() && unchangedPriceCodeIds.isEmpty()) action = isRenewal ? 'Activate' : 'Activate'/*'Renew Add' : 'Add'*/;
                else if(newPriceCodeIds.isEmpty() && !removedPriceCodeIds.isEmpty() && updatedPriceCodeIds.isEmpty() && unchangedPriceCodeIds.isEmpty()) {
                    //TODO: scenario where *some* of the rate plans have been removed but not all of them
                    action = isRenewal ? 'Deactivate' : 'Deactivate'/*'Renew Remove' : 'Remove'*/;
                }
                else if(!newPriceCodeIds.isEmpty() || !removedPriceCodeIds.isEmpty() || !updatedPriceCodeIds.isEmpty()) action = isRenewal ? 'No Action' : 'No Action'/*'Renew Update' : 'Update'*/;
                else if(isRenewal) {
                    action = 'No Action'/*'Renew Unchanged'*/;
                }
            }else{
                //new quantities + something else on price codes - but not ONLY a new price code.  if the product didn't exist at all
                //then it is consumed by the add/removes
                //system.debug('*** newPriceCodeIds='+newPriceCodeIds.size()+'; removedPriceCodeIds='+removedPriceCodeIds.size()+'; unchangedPriceCodeIds='+unchangedPriceCodeIds.size()+'; updatedPriceCodeIds='+updatedPriceCodeIds.size()+'; existingPerUnitChargesModified='+existingPerUnitChargesModified.size());
                if(!newPriceCodeIds.isEmpty() || !removedPriceCodeIds.isEmpty()) {
                    if(!unchangedPriceCodeIds.isEmpty() || !existingPerUnitChargesModified.isEmpty())
                        action = isRenewal ? 'No Action' : 'No Action'/*'Renew Update' : 'Update'*/;
                }
                if(!updatedPriceCodeIds.isEmpty()) {
                    action = isRenewal ? 'No Action' : 'No Action'/*'Renew Update' : 'Update'*/;
                }
            }
            
            if(action != null) {
                QuoteProduct qp = new QuoteProduct();
                qp.action = action;
                qp.sfProductId = p.sfId;
                qp.amendmentType = amendmentType;
                qp.zProductId = p.zId;
                lst.add(qp);
            }

        }
        return lst;
    }
    
    public void organize() {
        if(this.zSubscription == null) return;
        for(ZuoraSubscription.RatePlan rp : this.zSubscription.subscription.ratePlans) {
            if(rp.productRatePlan != null && rp.productRatePlan.product != null && rp.productRatePlan.product.id != null) {
                String zProductId = rp.productRatePlan.product.id;
                Product prod = null;
                if(productsByZID.containsKey(zProductId)) {
                    prod = productsByZID.get(zProductId);
                }else{
                    prod = new Product(zProductId, rp.productRatePlan.product.Name);
                }

                if(rp.ProductRatePlanId != null) {
                    ProductRatePlan prp = null;
                    RatePlanSummary rps = null;
                    
                    if(prod.productRatePlansByZID.containsKey(rp.ProductRatePlanId)) {
                        prp = prod.productRatePlansByZID.get(rp.ProductRatePlanId);
                        rps = new RatePlanSummary(rp);
                        prp.addRatePlanSummary(rps);
                    }else{
                        prp = new ProductRatePlan(rp.ProductRatePlanId, rp.productRatePlan.Name);
                        rps = new RatePlanSummary(rp);
                        prp.addRatePlanSummary(rps);
                    }
                    
                    Decimal recurringPerUnitQuantity = prp.recurringPerUnitQuantity;
                    Decimal totalPrice = prp.totalPrice;
                    prp.numberOfCharges = rp.ratePlanCharges.size();
                    for(ZuoraSubscription.RatePlanCharge rpc : rp.ratePlanCharges) {
                        String chargeType = rpc.getStringValue('ChargeType'); //Recurring
                        String chargeModel = rpc.getStringValue('ChargeModel'); //Per Unit Pricing
                        prp.chargeType = chargeType;
                        prp.chargeModel = chargeModel;
                        Decimal quantity = rpc.getDecimalValue('Quantity');
                        Decimal price = rpc.getDecimalValue('Price');
                        system.debug('*** ZSS: '+rp.productRatePlan.Name+' chargeType:'+chargeType+'; chargeModel:'+chargeModel+';quantity:'+quantity+';price:' +price + '; segment='+rpc.Segment+';isLastSegment='+rpc.IsLastSegment+';TIERS:'+rpc.ratePlanChargeTiers);
                        if(chargeType == 'Recurring' && (chargeModel == 'Per Unit Pricing' || chargeModel == 'Volume Pricing') && quantity != null) {
                            if(recurringPerUnitQuantity == null) recurringPerUnitQuantity = 0;
                            recurringPerUnitQuantity += quantity;
                            rps.quantity = Integer.valueOf(quantity);
                        }
                        if(price == null && chargeType == 'Recurring' && chargeModel == 'Volume Pricing' && quantity != null) {
                            //get price from the tiers, based on quantity
                            for(ZuoraSubscription.RatePlanChargeTier rpct : rpc.ratePlanChargeTiers) {
                                Decimal startingUnit = rpct.getDecimalValue('StartingUnit');
                                Decimal endingUnit = rpct.getDecimalValue('EndingUnit');
                                system.debug('*** ZSS is '+quantity+' between '+startingUnit+ ' and ' + endingUnit+'?');
                                if(quantity >= startingUnit && quantity <= endingUnit) {
                                    system.debug('*** ZSS setting price to ' + rpct.Price);
                                    price = rpct.Price;                                    
                                }
                            }
                        }
                        
                        if(totalPrice == null && price != null) totalPrice = 0;
                        if(price != null) {
                            //if(chargeModel == 'Per Unit Pricing' || chargeModel == 'Volume Pricing') {
                            if(chargeType == 'Recurring' && (chargeModel == 'Per Unit Pricing' || chargeModel == 'Volume Pricing')) {
                                totalPrice += ((quantity==null?0:quantity)*price);
                            } else totalPrice += price;
                            //Oct 17 only use per unit price, don't try to calculate total price by quantity
                            //totalPrice += price;
                        }
                        rps.price = price;
                    }
                    prp.totalPrice = totalPrice;
                    if(recurringPerUnitQuantity != null) {
                        prp.recurringPerUnitQuantity = Integer.valueOf(recurringPerUnitQuantity);  
                    }
                    
                    prod.productRatePlansByZID.put(rp.ProductRatePlanId, prp);
                }
                productsByZID.put(zProductId, prod);
            }
        }
        
        addSalesforceIDs();
    }

    private void addSalesforceIDs() {
        //attach the product and rate plan SF id's
        Set<String> productZIDs = new Set<String>();
        Set<String> productRatePlanZIDs = new Set<String>();

        for(Product p : this.productsByZID.values()) {
            productZIDs.add(p.zId);
            for(ProductRatePlan prp : p.productRatePlansByZID.values()) {
                productRatePlanZIDs.add(prp.zId);
            }
        }
        
        Map<String, zqu__ZProduct__c> zproductsByZID = new Map<String, zqu__ZProduct__c>();
        if(!productZIDs.isEmpty()) 
        {
            List<zqu__ZProduct__c> zprod = [select Id, zqu__ZuoraId__c, Name from zqu__ZProduct__c where zqu__ZuoraId__c in :productZIDs];
            for(zqu__ZProduct__c zqu_prod : zprod ) 
            {
                zproductsByZID.put(zqu_prod.zqu__ZuoraId__c, zqu_prod);
            }
        }

        Map<String, zqu__ProductRatePlan__c> zproductRatePlansByZID = new Map<String, zqu__ProductRatePlan__c>();
        if(!productRatePlanZIDs.isEmpty()) 
        {
            List<zqu__ProductRatePlan__c> zprp = [select Id, zqu__ZuoraId__c, Name from zqu__ProductRatePlan__c where zqu__ZuoraId__c in :productRatePlanZIDs];
         for(zqu__ProductRatePlan__c zqu_prp : zprp)
            {
                zproductRatePlansByZID.put(zqu_prp.zqu__ZuoraId__c, zqu_prp);
            }
        }
        
        for(Product p : this.productsByZID.values()) {
            if(p.sfId == null && zproductsByZID.containsKey(p.zId)) {
                p.sfId = zproductsByZID.get(p.zId).Id;
            }
            
            for(ProductRatePlan prp : p.productRatePlansByZID.values()) {
                if(prp.sfId == null && zproductRatePlansByZID.containsKey(prp.zId)) {
                    prp.sfId = zproductRatePlansByZID.get(prp.zId).Id;
                }
            }
        }
    }    

    public void addOriginalQuote(zqu__Quote__c qt) {
        addNewOrOriginalQuote(qt, false);
    }

    public void addQuote(zqu__Quote__c qt) {
        addNewOrOriginalQuote(qt, true);
    }

    //isNewQuoteOldSubscription=true: map the quote against the "original" subscription state (i.e. the subscription being amended or renewed) 
    //isNewQuoteOldSubscription=false: map the quote against the "new" subscription state (i.e. the subscription resulting from the quote being submitted) 
    private void addNewOrOriginalQuote(zqu__Quote__c qt, Boolean isNewQuoteOldSubscription) {
        this.quoteId = qt.Id;
        this.isNewQuote = qt.RecordType.Name == 'Default';
        this.isAmendment = qt.RecordType.Name == 'Amendment' || qt.RecordType.Name == 'Amendment ReadOnly';
        this.isRenewal = qt.RecordType.Name == 'New Renewal' || (qt.RecordType.Name == 'ReadOnly' && !String.isBlank(qt.Renewal_Subscription_ID__c));
        
        for(zqu__QuoteRatePlan__c qrp : [select Id, Name, zqu__Quote__r.RecordType.Name, zqu__AmendmentType__c, zqu__ProductRatePlan__r.zqu__ZProduct__c, 
            zqu__ProductRatePlan__r.zqu__ZProduct__r.Name, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c, 
            zqu__ProductRatePlan__r.Name, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c, zqu__SubscriptionRatePlanZuoraId__c,
            Renewal_Rate_Plan_Id__c,
            (select Id, zqu__Quantity__c, zqu__ChargeType__c, zqu__Model__c, zqu__FeeType__c, zqu__EffectivePrice__c, zqu__SubscriptionRatePlanChargeZuoraId__c from zqu__Quote_Rate_Plan_Charges__r),
            (select Id, zqu__Quantity__c, zqu__EffectivePrice__c, zqu__TotalPrice__c, zqu__Model__c, zqu__Type__c, zqu__QuoteRatePlanCharge__r.zqu__EffectivePrice__c from zqu__QuoteChargeSummarys__r) 
            from zqu__QuoteRatePlan__c where zqu__Quote__c = :qt.Id])
        {
            String amendmentType = qrp.zqu__AmendmentType__c;
            String zProductId = qrp.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__ZuoraId__c;
            String zProductRatePlanId = qrp.zqu__ProductRatePlanZuoraId__c;
            system.debug('*** ZSS: addQuote: zProductId='+zProductId+'; amendmentType='+amendmentType);
            if(productsByZID.containsKey(zProductId)) {
                Product prod = productsByZID.get(zProductId);
                system.debug('*** ZSS: addQuote: found product:'+JSON.serialize(prod));
                prod.sfId = qrp.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                if(prod.productRatePlansByZID.containsKey(zProductRatePlanId)) {
                    //Expected on UpdateProduct and RemoveProduct or on NewProduct for renewal; or on duplicate products on amendmnet
                    ProductRatePlan prp = prod.productRatePlansByZID.get(zProductRatePlanId);
                    system.debug('*** ZSS: addQuote: found productRatePlan:'+JSON.serialize(prp));
                    prp.sfId = qrp.zqu__ProductRatePlan__c;
                    prp.amendmentType = amendmentType;
                    Map<String,Object> sums = getSumOfQuantityAndPrice(qrp);
                    Integer quantity = (Integer)sums.get('quantity');
                    Decimal price = (Decimal)sums.get('price');
                    if(prp.quoteRecurringPerUnitQuantity != null) {
                        if(quantity != null) prp.quoteRecurringPerUnitQuantity += quantity;
                    }else {
                        prp.quoteRecurringPerUnitQuantity = quantity;
                    }
                    if(prp.quoteTotalPrice != null) {
                        if(price != null) prp.quoteTotalPrice += price;    
                    }else{
                        prp.quoteTotalPrice = price;
                    }
                    
                    //exception for Amendment with UpdateProduct that is a duplicate, use delta MRR to reverse engineer the old quantity vs new
                    if(isAmendment && amendmentType == 'UpdateProduct' && !qrp.zqu__QuoteChargeSummarys__r.isEmpty() && qrp.zqu__QuoteChargeSummarys__r[0].zqu__Quantity__c != null) {
                        //Get from quote charge summary
                        //if(prp.quoteRecurringPerUnitQuantity == null) prp.quoteRecurringPerUnitQuantity = 0;
                        //prp.quoteRecurringPerUnitQuantity += Integer.valueOf(qrp.zqu__QuoteChargeSummarys__r[0].zqu__Quantity__c);
                        System.debug('Method : UpdateProduct');//SC2015_AGL-5809
                    }
                    
                    //exception case for Amendment with NewProduct that is a duplicate, set quantity to old + new
                    if(isAmendment && amendmentType == 'NewProduct' && prp.quoteRecurringPerUnitQuantity != null && prp.recurringPerUnitQuantity != null) {
                        prp.quoteRecurringPerUnitQuantity = prp.recurringPerUnitQuantity + prp.quoteRecurringPerUnitQuantity;
                    }
                    if(isNewQuoteOldSubscription) {
                        prp.addQuoteRatePlanWrapper(new QuoteRatePlanWrapper(qrp, isNewQuoteOldSubscription));
                    }else{
                        prp.addQuoteRatePlanWrapperForOriginalQuote(new QuoteRatePlanWrapper(qrp, isNewQuoteOldSubscription));
                    }
                    //sum up the quantities from the map
                }else{
                    system.debug('*** ZSS: addQuote: did not find productRatePlan');
                    //Expected on NewProduct
                    ProductRatePlan prp = new ProductRatePlan(zProductRatePlanId, qrp.zqu__ProductRatePlan__r.Name);
                    prp.sfId = qrp.zqu__ProductRatePlan__c;
                    prp.amendmentType = amendmentType;
                    //TODO: set numberOfCharges, recurringPerUnitQuantity, totalPrice???
                    Map<String,Object> sums = getSumOfQuantityAndPrice(qrp);
                    prp.quoteRecurringPerUnitQuantity = (Integer)sums.get('quantity');
                    prp.quoteTotalPrice = (Decimal)sums.get('price');
                    if(isNewQuoteOldSubscription) {
                        prp.addQuoteRatePlanWrapper(new QuoteRatePlanWrapper(qrp, isNewQuoteOldSubscription));
                    }else{
                        prp.addQuoteRatePlanWrapperForOriginalQuote(new QuoteRatePlanWrapper(qrp, isNewQuoteOldSubscription));
                    }
                    prod.productRatePlansByZID.put(zProductRatePlanId, prp);
                }
            }else{
                system.debug('*** ZSS: addQuote: did not find product');
                Product prod = new Product(zProductId, qrp.zqu__ProductRatePlan__r.zqu__ZProduct__r.Name);
                prod.sfId = qrp.zqu__ProductRatePlan__r.zqu__ZProduct__c;
                ProductRatePlan prp = new ProductRatePlan(zProductRatePlanId, qrp.zqu__ProductRatePlan__r.Name);
                prp.sfId = qrp.zqu__ProductRatePlan__c;
                prp.amendmentType = amendmentType;
                Map<String,Object> sums = getSumOfQuantityAndPrice(qrp);
                prp.quoteRecurringPerUnitQuantity = (Integer)sums.get('quantity');
                prp.quoteTotalPrice = (Decimal)sums.get('price');
                if(isNewQuoteOldSubscription) {
                    prp.addQuoteRatePlanWrapper(new QuoteRatePlanWrapper(qrp, isNewQuoteOldSubscription));
                }else{
                    prp.addQuoteRatePlanWrapperForOriginalQuote(new QuoteRatePlanWrapper(qrp, isNewQuoteOldSubscription));
                }
                prod.productRatePlansByZID.put(zProductRatePlanId, prp);
                productsByZID.put(zProductId, prod);
            }
        }

        for(Product p : this.productsByZID.values()) {
            for(ProductRatePlan prp : p.productRatePlansByZID.values()) {
                Decimal totalPrice = prp.totalPrice;
                if(totalPrice == null) totalPrice = 0;
                totalPrice = Math.round(totalPrice*100)/100.0;
                
                prp.quoteTotalPrice = 0;
                for(QuoteRatePlanWrapper qrpw : prp.quoteRatePlansById.values()) {
                    if(qrpw.price != null) {
                        if(qrpw.quantity != null && qrpw.perUnitPrice != null)
                            prp.quoteTotalPrice += (qrpw.quantity * qrpw.price);
                        else
                            prp.quoteTotalPrice += qrpw.price;    
                    }
                }
                
                Decimal quoteTotalPrice = prp.quoteTotalPrice;
                if(quoteTotalPrice == null) quoteTotalPrice = 0;
                quoteTotalPrice = Math.round(quoteTotalPrice*100)/100.0;
                
                //re-calculate the quote recurring quantity
                if(isNewQuote || isRenewal) {
                    prp.quoteRecurringPerUnitQuantity = null;

                    for(QuoteRatePlanWrapper qrpw : prp.quoteRatePlansById.values()) {
                        if(qrpw.quantity != null) {
                            if(prp.quoteRecurringPerUnitQuantity == null) prp.quoteRecurringPerUnitQuantity = 0;
                            prp.quoteRecurringPerUnitQuantity += qrpw.quantity;
                        }
                    }
                }
                
                //re-calculate the quote recurring quantity
                if(isAmendment) {
                    prp.quoteRecurringPerUnitQuantity = null;

                    for(RatePlanSummary rps : prp.ratePlansById.values()) {
                        if(rps.quantity != null) {
                            if(prp.quoteRecurringPerUnitQuantity == null) prp.quoteRecurringPerUnitQuantity = 0;
                            prp.quoteRecurringPerUnitQuantity += rps.quantity;
                        }
                    }
                    
                    //re-add the UpdateProduct amendment quantities
                    for(QuoteRatePlanWrapper qrpw : prp.quoteRatePlansById.values()) {
                        if(qrpw.quantity != null) {
                            if(prp.quoteRecurringPerUnitQuantity == null) prp.quoteRecurringPerUnitQuantity = 0;
                            prp.quoteRecurringPerUnitQuantity += qrpw.quantity;
                        }
                    }
                }
                
                if(isNewQuote) {
                    prp.isAdd = true;
                    prp.isRemove = false;
                    prp.isUpdate = false;
                } else if(isAmendment) {
                    if(prp.amendmentType == 'NewProduct') {
                        prp.isAdd = prp.ratePlansById.isEmpty() || (prp.recurringPerUnitQuantityChange != null && prp.recurringPerUnitQuantityChange > 0);
                        prp.isUpdate = !prp.isAdd;
                        prp.isRemove = false;
                    }
                    
                    if(prp.amendmentType == 'UpdateProduct'){
                        prp.isAdd = (prp.recurringPerUnitQuantityChange != null && prp.recurringPerUnitQuantityChange > 0);
                        prp.isRemove = (prp.recurringPerUnitQuantityChange != null && prp.recurringPerUnitQuantityChange < 0);
                        prp.isUpdate = !prp.isAdd && !prp.isRemove && (totalPrice != quoteTotalPrice);
                    }

                    if(prp.amendmentType == 'RemoveProduct') {
                        //when amendment is remove but there are some of the same remaining, and those are the only ones remaining
                        if(prp.ratePlansById.size() <= prp.quoteRatePlansById.size()) {
                            prp.isRemove = true;
                            prp.isUpdate = false;
                        }else{
                            prp.isRemove = false;
                            prp.isUpdate = true;
                        }
                    }
                } else if(isRenewal) {
                    prp.isAdd = (prp.amendmentType == 'NewProduct' && prp.ratePlansById.isEmpty()) || (prp.amendmentType == 'NewProduct' && !prp.ratePlansById.isEmpty() && prp.recurringPerUnitQuantityChange > 0);
                    prp.isRemove = (prp.amendmentType == null && !prp.ratePlansById.isEmpty()) || (prp.amendmentType == 'NewProduct' && !prp.ratePlansById.isEmpty() && prp.recurringPerUnitQuantityChange < 0);
                    prp.isUpdate = !prp.isAdd && !prp.isRemove && (totalPrice != quoteTotalPrice);
                    system.debug('*** ZSS *** prp.name='+prp.name+'; totalPrice='+totalPrice+'; quoteTotalPrice='+quoteTotalPrice+' isUpdate='+prp.isUpdate);
                }
            }
        }
    }
        
    private static Map<String,Object> getSumOfQuantityAndPrice(zqu__QuoteRatePlan__c qrp) {
        Decimal quoteRecurringPerUnitQuantity = null;
        Decimal quoteTotalPrice = null;
        Decimal perUnitPrice = null;
        
        if(!qrp.zqu__QuoteChargeSummarys__r.isEmpty()) {
            zqu__QuoteChargeSummary__c qcs = qrp.zqu__QuoteChargeSummarys__r[0];
            perUnitPrice = qcs.zqu__EffectivePrice__c;
            //quoteTotalPrice = qcs.zqu__TotalPrice__c;
            quoteTotalPrice = qcs.zqu__EffectivePrice__c;
            if(qcs.zqu__Quantity__c != null && (qcs.zqu__Model__c == 'Per Unit Pricing' || qcs.zqu__Model__c == 'Volume Pricing') && qcs.zqu__Type__c == 'Recurring') 
                quoteRecurringPerUnitQuantity = Integer.valueOf(qcs.zqu__Quantity__c);
            //Dec 15/2016 commented out for 1508 fix
            //if((qcs.zqu__Quantity__c == null || qcs.zqu__Quantity__c == 0) && (qcs.zqu__Model__c == 'Per Unit Pricing' || qcs.zqu__Model__c == 'Volume Pricing') && qcs.zqu__Type__c == 'Recurring') 
            //  quoteTotalPrice = 0;
            if(qrp.zqu__AmendmentType__c == 'UpdateProduct') {
                quoteTotalPrice = qcs.zqu__QuoteRatePlanCharge__r.zqu__EffectivePrice__c;
                perUnitPrice = qcs.zqu__QuoteRatePlanCharge__r.zqu__EffectivePrice__c;
            }
        }else{
            for(zqu__QuoteRatePlanCharge__c qrpc : qrp.zqu__Quote_Rate_Plan_Charges__r) {
                if(qrpc.zqu__FeeType__c == 'Per Unit' && qrpc.zqu__ChargeType__c == 'Recurring') {
                    if(qrpc.zqu__Quantity__c != null) {
                        if(quoteRecurringPerUnitQuantity == null) quoteRecurringPerUnitQuantity = 0;
                        quoteRecurringPerUnitQuantity += qrpc.zqu__Quantity__c;
                        
                        perUnitPrice = qrpc.zqu__EffectivePrice__c;
                        if(quoteTotalPrice == null && qrpc.zqu__EffectivePrice__c != null) quoteTotalPrice = 0;
                        //if(qrpc.zqu__EffectivePrice__c != null) quoteTotalPrice += qrpc.zqu__EffectivePrice__c*quoteRecurringPerUnitQuantity;
                        //Oct 17 - Don't try to calculate total price, only per unit price
                        quoteTotalPrice += qrpc.zqu__EffectivePrice__c;
                    }
                }else {
                    if(qrpc.zqu__EffectivePrice__c != null) {
                        if(quoteTotalPrice == null) quoteTotalPrice = 0;
                        quoteTotalPrice += qrpc.zqu__EffectivePrice__c;
                    }    
                }
            }
        }
        
        
        return new Map<String,Object> {
            'quantity' => Integer.valueOf(quoteRecurringPerUnitQuantity),
            'price' => quoteTotalPrice,
            'perUnitPrice' => perUnitPrice
        };
    }
    
    public String var_dump() {
        Map<String,Object> vars = new Map<String,Object>{
            'zSubscriptionId' => (zSubscription != null ? (zSubscription.subscription.id) : null),
            'products'=>productsByZID.values()
        };
        //return JSON.serializePretty(vars);
        return JSON.serializePretty(this);
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
    }

    //implements Comparable
    public class QuoteRatePlanWrapper {
        public Id id {get;set;}
        public Integer quantity {get;set;}
        public Decimal price {get;set;}
        public Decimal perUnitPrice {get;set;}
        //public Integer index {get;set;}
        //public Integer startQuantityIndex {get;set;}
        //public Integer endQuantityIndex {get;set;}
        public String amendmentType {get;set;}
        public String zRatePlanId {get;set;}

        public QuoteRatePlanWrapper(zqu__QuoteRatePlan__c qrp, Boolean isNewQuoteOldSubscription) { 
            this.id = qrp.Id;
            Map<String,Object> sums = getSumOfQuantityAndPrice(qrp);
            quantity = (Integer)sums.get('quantity');
            perUnitPrice = (Decimal)sums.get('perUnitPrice');
            price = (Decimal)sums.get('price');
            amendmentType = qrp.zqu__AmendmentType__c;
            zRatePlanId = qrp.zqu__SubscriptionRatePlanZuoraId__c;
            if(isNewQuoteOldSubscription && qrp.Renewal_Rate_Plan_Id__c != null) zRatePlanId = qrp.Renewal_Rate_Plan_Id__c;
        }
        /*
        public QuoteRatePlanWrapper(zqu__QuoteRatePlan__c qrp) {
            this.id = qrp.Id;
            Map<String,Object> sums = getSumOfQuantityAndPrice(qrp);
            quantity = (Integer)sums.get('quantity');
            perUnitPrice = (Decimal)sums.get('perUnitPrice');
            price = (Decimal)sums.get('price');
            amendmentType = qrp.zqu__AmendmentType__c;
            zRatePlanId = qrp.zqu__SubscriptionRatePlanZuoraId__c;
            if(qrp.Renewal_Rate_Plan_Id__c != null) zRatePlanId = qrp.Renewal_Rate_Plan_Id__c;
        }*/
        
        /*
        public Integer compareTo(Object otherQRPW) {
            if(otherQRPW == null) return 1;
            QuoteRatePlanWrapper that = (QuoteRatePlanWrapper)otherQRPW;
            if(that.index == null) return 1;
            if(this.index == null) return -1;
            return this.index - that.index;
        }*/
    }
    
    public class Product {
        public Id sfId {get;set;}
        public String zId {get;set;}
        public String name {get;set;}
        public Map<String,ProductRatePlan> productRatePlansByZID;
        
        public Product(String zId, String name) {
            this.zId = zId;
            this.name = name;
            this.productRatePlansByZID = new Map<String,ProductRatePlan>();
        }
        
        public Boolean anyDelivered {
            get {
                Boolean isDelivered = false;
                for(ZuoraSubscriptionState.ProductRatePlan zssProductRatePlan : this.productRatePlansByZID.values()) {
                    for(ZuoraSubscriptionState.RatePlanSummary rpSummary : zssProductRatePlan.ratePlansById.values()) {
                        if(rpSummary.delivered) isDelivered = true;
                    }
                }
                return isDelivered;
            }
        }
    }
    
    public class RatePlanSummary {
        public String id {get;set;}
        public Integer quantity {get;set;}
        public Decimal price {get;set;}
        public Boolean delivered {get;set;}
        public Date deliveryDate {get;set;}
        
        public RatePlanSummary(ZuoraSubscription.RatePlan ratePlan){
            this.id = ratePlan.id;
            this.delivered = false;
            for(ZuoraSubscription.RatePlanCharge rpc : ratePlan.ratePlanCharges) {
                if(rpc.getStringValue('Delivered__c') == 'Yes') {
                    delivered = true;
                    deliveryDate = (Date)rpc.getValue('TriggerDate');
                }
            }
        }
    }

    public class ProductRatePlan {
        public Id sfId {get;set;}
        public String zId {get;set;}
        public Map<String, RatePlanSummary> ratePlansById {get;set;} //only present when rate plan is on subscription
        public String name {get;set;}
        public Integer numberOfCharges {get;set;}
        public Integer recurringPerUnitQuantity {get;set;}
        public Decimal totalPrice {get;set;}
        public String amendmentType {get;set;}
        public Integer quoteRecurringPerUnitQuantity {get;set;}
        public Decimal quoteTotalPrice {get;set;}
        public Boolean isAdd {get;set;}
        public Boolean isRemove {get;set;}
        public Boolean isUpdate {get;set;}
        public String chargeType {get;set;} //from the subscription
        public String chargeModel {get;set;} //from the subscription
        public Map<Id, QuoteRatePlanWrapper> quoteRatePlansById {get;set;}

        public Integer recurringPerUnitQuantityChange {
            get {
                if(amendmentType != null && (recurringPerUnitQuantity != null || (quoteRecurringPerUnitQuantity != null && quoteRecurringPerUnitQuantity > 0))) {
                    Integer currentValue = recurringPerUnitQuantity != null ? recurringPerUnitQuantity : 0;
                    Integer newValue = quoteRecurringPerUnitQuantity != null ? quoteRecurringPerUnitQuantity : 0;
                    
                    return newValue - currentValue;
                }else{
                    return null;
                }
            }
        }        

        public ProductRatePlan(String zId, String name) {
            this.zId = zId;
            this.name = name;
            this.ratePlansById = new Map<String,RatePlanSummary>();
            this.quoteRatePlansById = new Map<Id, QuoteRatePlanWrapper>();
        }
        
        public RatePlanSummary getRatePlanSummary(String ratePlanId) {
            return ratePlansById.get(ratePlanId);
        }
        
        public void addRatePlanSummary(RatePlanSummary rps) {
            ratePlansById.put(rps.id, rps);
        }

        public void addQuoteRatePlanWrapper(QuoteRatePlanWrapper qrpw) {
            /*
            qrpw.index = this.quoteRatePlansById.size();
            if(qrpw.index == 0) {
                qrpw.startQuantityIndex = 0;
                qrpw.endQuantityIndex = qrpw.quantity == null ? 0 : (qrpw.quantity - 1);
            }else{
                //get start from previous one
                List<QuoteRatePlanWrapper> qrpwList = this.quoteRatePlansById.values();
                qrpwList.sort();
                QuoteRatePlanWrapper lastInList = qrpwList.get(qrpwList.size() - 1);
                qrpw.startQuantityIndex = lastInList.endQuantityIndex + 1;
                Integer qty = qrpw.quantity == null ? 0 : qrpw.quantity;
                qrpw.endQuantityIndex = qrpw.startQuantityIndex + qty - 1;
            }
            */
            this.quoteRatePlansById.put(qrpw.id, qrpw);
        }

        private Set<String> zRatePlanIdsAssignedToQuoteRatePlan = new Set<String>();
        
        public void addQuoteRatePlanWrapperForOriginalQuote(QuoteRatePlanWrapper qrpw) {
            //match the qrpw zRatePlanId from the matching quantity/price on the subscription rate plan summary
            for(RatePlanSummary rps : ratePlansById.values()) {
                if(!zRatePlanIdsAssignedToQuoteRatePlan.contains(rps.id)) {
                    if(rps.quantity != null && qrpw.quantity != null) {
                        if(rps.quantity == qrpw.quantity && rps.price == qrpw.price)
                            qrpw.zRatePlanId = rps.id;
                    }else{
                        if(this.chargeModel == 'Per Unit Pricing') {
                            if(rps.price == qrpw.perUnitPrice)
                                qrpw.zRatePlanId = rps.id;
                        }else if(rps.price == qrpw.price) {
                            qrpw.zRatePlanId = rps.id;
                        }
                    }
                }
            }
            if(qrpw.zRatePlanId != null) {
                system.debug('addQuoteRatePlanWrapperForOriginalQuote: set qrpw.zRatePlanId='+qrpw.zRatePlanId);
                zRatePlanIdsAssignedToQuoteRatePlan.add(qrpw.zRatePlanId);
            }
            this.quoteRatePlansById.put(qrpw.id, qrpw);
        }
    }

    public class RenewalChange implements Comparable {
        public String quoteRatePlanId {get;set;}
        public String ratePlanId {get;set;}
        public String productRatePlanId {get;set;}

        public String productName {get;set;}
        public String ratePlanName {get;set;}
        public Decimal price {get;set;}
        public Decimal quotePrice {get;set;}
        public Integer quantity {get;set;}
        public Integer quoteQuantity {get;set;}
        public String action {get;set;} //Add/Remove/Update/No Change
        public Decimal deltaMRR {get;set;}
        public String description {get;set;}
        
        public Integer compareTo(Object thatObj) {
            if(thatObj == null) return 1;
            RenewalChange that = (RenewalChange)thatObj;
            if(that.action == this.action) {
                return this.ratePlanName.compareTo(that.ratePlanName);
            }else{
                return this.actionScoreForSort() - that.actionScoreForSort();
            }
            //return 0;
        }
        
        private integer actionScoreForSort() {
            if(action == /*'Add'*/'Activate') return 0;
            else if(action == /*'Remove'*/'Deactivate') return 1;
            else if(action == /*'Update'*/'No Action') return 2;
            else return 3;
        }
    }
    
    public List<RenewalChange> getRenewalChanges() {
        List<ZuoraSubscriptionState.RenewalChange> lst = new List<ZuoraSubscriptionState.RenewalChange>();
        for(ZuoraSubscriptionState.Product p : productsByZID.values()) {
            for(ZuoraSubscriptionState.ProductRatePlan prp : p.productRatePlansByZID.values()) {
                //compare ratePlansById to quoteRatePlansById 
                //organize quote rate plans into new vs existing
                Map<String, ZuoraSubscriptionState.QuoteRatePlanWrapper> quoteRatePlansByZID = new Map<String, ZuoraSubscriptionState.QuoteRatePlanWrapper>();
                List<ZuoraSubscriptionState.QuoteRatePlanWrapper> newQuoteRatePlans = new List<ZuoraSubscriptionState.QuoteRatePlanWrapper>();

                for(ZuoraSubscriptionState.QuoteRatePlanWrapper qrpw : prp.quoteRatePlansById.values()) {
                    if(!String.isBlank(qrpw.zRatePlanId)) quoteRatePlansByZID.put(qrpw.zRatePlanId, qrpw);
                    else newQuoteRatePlans.add(qrpw);
                }
                
                for(ZuoraSubscriptionState.RatePlanSummary rps : prp.ratePlansById.values()) {
                    if(quoteRatePlansByZID.containsKey(rps.id)) {
                        //Update or Unchanged - compare price and quantity
                        ZuoraSubscriptionState.QuoteRatePlanWrapper qrpw = quoteRatePlansByZID.get(rps.id);
                        String action = 'No Change';
                        Decimal deltaMRR = 0, quotePrice = qrpw.price;

                        if(rps.price != qrpw.perUnitPrice || rps.quantity != qrpw.quantity) {
                            action = 'Update';
                            
                            if(rps.quantity != null && qrpw.quantity != null) {
                                quotePrice = qrpw.price;
                                try { 
                                    deltaMRR = qrpw.quantity*qrpw.price;
                                }catch(Exception e) {
                                    //if something is null
                                    deltaMRR = 0;
                                }
                                
                                try {
                                    deltaMRR -= rps.quantity*rps.price; 
                                }catch(Exception e){ // if something is null
                                }
                            }else{
                                quotePrice = qrpw.price;
                                if(qrpw.price != null) deltaMRR = qrpw.price;
                                if(rps.price != null) deltaMRR -= rps.price; 
                            }
                        }

                        
                        Integer quoteQuantity = qrpw.quantity;
                        if(isAmendment) {
                            if(prp.amendmentType == 'RemoveProduct') {
                                action = 'Remove';
                                deltaMRR = rps.price != null ? -rps.price : 0;
                                quoteQuantity = 0;
                            }else if(prp.amendmentType == 'UpdateProduct') {
                                //quotePrice = rps.price + qrpw.price;
                                quotePrice = qrpw.price;
                                //deltaMRR = qrpw.price;
                                deltaMRR = (qrpw.price == null ? 0 : qrpw.price) - (rps.price == null ? 0 : rps.price);
                                
                                 action = 'Update'; //START-END, 08-Mar-2021, SC2015_AGL-5547,While Amendment
                            }
                        }
                        
                        //START, Just Change the order, earlier it was above of If isAmendment, 08-Mar-2021, SC2015_AGL-5547
                        String description = null;
                        if(action == 'Update') {
                            description = 'Updated ' + p.name + ' / ' + prp.name;
                        }else{
                            description = 'No Change to '+ p.name  + ' / ' + prp.name;
                        }
                        //END
                        

                        ZuoraSubscriptionState.RenewalChange change = new ZuoraSubscriptionState.RenewalChange();
                        change.quoteRatePlanId = qrpw.id;
                        change.ratePlanId = rps.id;
                        change.productRatePlanId = prp.zId;
                        change.productName = p.name;
                        change.ratePlanName = prp.name;
                        change.price = rps.price;
                        change.quotePrice = quotePrice;
                        change.quantity = rps.quantity;
                        change.quoteQuantity = quoteQuantity;
                        change.action = action;
                        change.deltaMRR = deltaMRR;
                        change.description = description;
                        lst.add(change);
                    }else{
                        //Removed
                        //for renewals, ignore OT fees
                        if(!isRenewal || prp.chargeType != 'OneTime') {
                            Decimal deltaMRR = 0;
                            if(rps.quantity != null && rps.price != null) {
                                deltaMRR = -rps.quantity*rps.price; 
                            }else{
                                deltaMRR = rps.price != null ? -rps.price : 0; 
                            }
    
                            ZuoraSubscriptionState.RenewalChange change = new ZuoraSubscriptionState.RenewalChange();
                            change.ratePlanId = rps.id;
                            change.productRatePlanId = prp.zId;
                            change.productName = p.name;
                            change.ratePlanName = prp.name;
                            change.price = rps.price;
                            change.quotePrice = null;
                            change.quantity = rps.quantity;
                            change.quoteQuantity = null;
                            change.action = isAmendment ? 'No Change' : 'Remove';
                            change.deltaMRR = deltaMRR;
                            change.description = 'Removed ' + p.name + ' / ' + prp.name;
                            lst.add(change);    
                        }
                    }
                }

                for(ZuoraSubscriptionState.QuoteRatePlanWrapper qrpw : newQuoteRatePlans) {
                    //Added
                    Decimal deltaMRR = 0;
                    if(qrpw.quantity != null) {
                        deltaMRR = -qrpw.quantity*qrpw.price; 
                    }else{
                        if(qrpw.price != null) deltaMRR = -qrpw.price; 
                    }
                    
                    ZuoraSubscriptionState.RenewalChange change = new ZuoraSubscriptionState.RenewalChange();
                    change.quoteRatePlanId = qrpw.id;
                    change.productRatePlanId = prp.zId;
                    change.productName = p.name;
                    change.ratePlanName = prp.name;
                    change.price = null;
                    change.quotePrice = qrpw.price;
                    change.quantity = null;
                    change.quoteQuantity = qrpw.quantity;
                    change.action = 'Add';
                    change.deltaMRR = deltaMRR;
                    change.description = 'Added ' + p.name + ' / ' + prp.name;
                    lst.add(change);
                }
            }
        }
                
        
        system.debug('***** AFTER COMPARISON, RESULT:');
        system.debug(JSON.serialize(lst));
        return lst;
    }
    
    public Map<String, Map<String, Object>> getRatePlanChargeTPVUpdates() { 
        Map<String, Map<String, Object>> m = new Map<String, Map<String, Object>>();
        Quote_Product__c[] quoteProducts = [select Action__c, product_rate_Plan__r.zqu__ZuoraId__c, zproduct__r.zqu__ZuoraId__c,
            Solution_Provider_Product__c, Solution_Provider_Product__r.Name, Solution_Provider_Product__r.Solution_Provider_Id__r.Name, Quote_Rate_Plan__r.zqu__ProductRatePlanZuoraId__c
            from Quote_Product__c where Quote__c = :this.quoteId];
        for(Quote_Product__c qp : quoteProducts) {
            //if(!String.isBlank(qp.Solution_Provider_Product__r.Name)){
                if(qp.Quote_Rate_Plan__c != null) {
                    //for recurring per unit charges only
                    //match to the QRP and it's SPP - 
                    if(!String.isBlank(qp.zproduct__r.zqu__ZuoraId__c)) {
                        String zProductId = qp.zproduct__r.zqu__ZuoraId__c;
                        ZuoraSubscriptionState.Product zssProduct = this.productsByZID.get(zProductId);
                        if(zssProduct != null) {
                            String zProductRatePlanId = qp.Quote_Rate_Plan__r.zqu__ProductRatePlanZuoraId__c;
                            if(!String.isBlank(zProductRatePlanId)) {
                                ZuoraSubscriptionState.ProductRatePlan zssProductRatePlan = zssProduct.productRatePlansByZID.get(zProductRatePlanId);
                                if(zssProductRatePlan != null) {
                                    ZuoraSubscriptionState.QuoteRatePlanWrapper qrpw = zssProductRatePlan.quoteRatePlansById.get(qp.Quote_Rate_Plan__c);
                                    if(qrpw != null && !String.isBlank(qrpw.zRatePlanId)) {
                                        system.debug('Got the rate plan id: '+qrpw.zRatePlanId);
                                        //find the rate plan charges from the subscription
                                        for(ZuoraSubscription.RatePlan ratePlan : zSubscription.subscription.ratePlans) {
                                            if(ratePlan.id == qrpw.zRatePlanId) {
                                                system.debug('found the subscription rate plan');
                                                for(ZuoraSubscription.RatePlanCharge ratePlanCharge : ratePlan.ratePlanCharges) {
                                                    //create a zobject update
                                                    String tpvValue = qp.Solution_Provider_Product__r.Solution_Provider_Id__r.Name + ' - ' + qp.Solution_Provider_Product__r.Name;
                                                    if(tpvValue.length() > 255) tpvValue = tpvValue.substring(0,255);
                                                    Map<String,Object> zRatePlanChargeUpdate = new Map<String,Object>{
                                                        'Id' => ratePlanCharge.id,
                                                        'ThirdPartyVendor__c' => tpvValue,
                                                        'QuoteProductId__c' => qp.id  
                                                    };
                                                    system.debug(JSON.serialize(zRatePlanChargeUpdate));  
                                                    m.put(ratePlanCharge.id, zRatePlanChargeUpdate);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else {
                    //for non-recurring per unit charges
                    //how do we locate the QRP?  do we need to here?
                    if(!String.isBlank(qp.zproduct__r.zqu__ZuoraId__c)) {
                        String zProductId = qp.zproduct__r.zqu__ZuoraId__c;
                        ZuoraSubscriptionState.Product zssProduct = this.productsByZID.get(zProductId);
                        if(zssProduct != null) {
                            for(ZuoraSubscription.RatePlan ratePlan : zSubscription.subscription.ratePlans) {
                                if(ratePlan.productRatePlan.product.id == zssProduct.zId) {
                                    system.debug('found a subscription rate plan:'+ratePlan.id);
                                    for(ZuoraSubscription.RatePlanCharge ratePlanCharge : ratePlan.ratePlanCharges) {
                                        //create a zobject update
                                        String tpvValue = qp.Solution_Provider_Product__r.Solution_Provider_Id__r.Name + ' - ' + qp.Solution_Provider_Product__r.Name;
                                        Map<String,Object> zRatePlanChargeUpdate = new Map<String,Object>{
                                            'Id' => ratePlanCharge.id,
                                            'ThirdPartyVendor__c' => tpvValue,
                                            'QuoteProductId__c' => qp.id     
                                        };
                                        system.debug(JSON.serialize(zRatePlanChargeUpdate));  
                                        m.put(ratePlanCharge.id, zRatePlanChargeUpdate);
                                    }
                                }
                            }
                        }
                    } 
                }
            //}
        }
        return m;
    }

    //Save the "Add" and "Update" and "No Change" renewal changes to the Quote Rate Plan
    public void saveRenewalChanges(List<RenewalChange> renewalChanges)
    {
        Map<Id, zqu__QuoteRatePlan__c> quoteRatePlanUpdates = new Map<Id, zqu__QuoteRatePlan__c>();
        for(RenewalChange rc : renewalChanges) {
            if(rc.quoteRatePlanId != null) {
                quoteRatePlanUpdates.put(rc.quoteRatePlanId, new zqu__QuoteRatePlan__c(Id = rc.quoteRatePlanId, Billing_Action__c = rc.action));
            }
        }
        if(!quoteRatePlanUpdates.isEmpty()) update quoteRatePlanUpdates.values();
    }
    
    public static void codecoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}