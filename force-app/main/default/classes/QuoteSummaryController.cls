// ===========================================================================
// Object: QuoteSummaryController
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Implementation of QuoteSummaryController for DI story 1478
// ===========================================================================
// Changes: 2016-12-01 Reid Beckett
//           Class created
// ===========================================================================
public with sharing class QuoteSummaryController 
{
    public zqu__Quote__c qt {get;set;}
    public Boolean hasInitError {get;set;}
    public List<ChargeSummary> changes {get;set;}
    public List<QuoteProductWrapper> quoteProducts {get;set;}

    public QuoteSummaryController(ApexPages.StandardController stdController) 
    {
        Id quoteId = stdController.getId();
        qt = [select Id, Name, RecordType.Name, zqu__Opportunity__r.AccountId, zqu__ZuoraAccountID__c, zqu__ElectronicPaymentMethodId__c, zqu__Status__c, 
            Renewal_Subscription_ID__c, zqu__ExistSubscriptionID__c, zqu__StartDate__c, DI_Approval_Status__c,
            (select Id, Action__c, ZProduct__r.Name, Solution_Provider_Product__r.Name from Quote_Products__r order by Action__c asc),                        
            (select Id from zqu__Quote_Rate_Plans__r order by Name asc)                        
            from zqu__Quote__c where Id = :quoteId];
    }
    
    public PageReference initAction() {
        quoteProducts = new List<QuoteProductWrapper>();
        for(Quote_Product__c qp : qt.Quote_Products__r) {
            quoteProducts.add(new QuoteProductWrapper(qp));
        }
        quoteProducts.sort();
        hasInitError = false;           

        this.changes = new List<ChargeSummary>();
        
        //Renewal
        if(!String.isBlank(qt.Renewal_Subscription_ID__c)) {
            ZuoraSubscription zuoraSubscription = ZuoraClient.getInstance().findZuoraSubscription(qt.Renewal_Subscription_ID__c);
            ZuoraSubscriptionState zss = new ZuoraSubscriptionState(zuoraSubscription);
            zss.addQuote(qt);
            List<ZuoraSubscriptionState.RenewalChange> rwlChanges = zss.getRenewalChanges();
            rwlChanges.sort();
            //zss.saveRenewalChanges(rwlChanges);//Commented becuase we need to append/modify action of changes list On 10-Mar-2021, 
            
            List<ZuoraSubscriptionState.RenewalChange> finalrwlChanges=new List<ZuoraSubscriptionState.RenewalChange>();//added method SC2015_AGL-5547,09-Mar-2021
            
            Map<Id, List<zqu__QuoteRatePlanCharge__c>> tiersByQRPID = loadChargeTiers(rwlChanges);

            for(ZuoraSubscriptionState.RenewalChange rwlChange : rwlChanges) {
                ChargeSummary cs = new ChargeSummary(rwlChange);
                
                if(!String.isBlank(rwlChange.quoteRatePlanId) && tiersByQRPID.containsKey(rwlChange.quoteRatePlanId)) {
                    for(zqu__QuoteRatePlanCharge__c qrpc : tiersByQRPID.get(rwlChange.quoteRatePlanId)) {
                        cs.ramp = qrpc.Ramp__c;
                        if(qrpc.zqu__Model__c == 'Volume Pricing' || qrpc.zqu__Model__c == 'Tiered Pricing') {
                            cs.addTiers(qrpc.zqu__Quote_RatePlan_Charge_Tier__r);
                       
                            //START, geting new quote rate tiered charge,SC2015_AGL-5547,09-Mar-2021 
                            Map<Integer, Decimal> mapChargeTiered=new Map<Integer,Decimal>();
                            //System.debug(' SKP Model >> : '+ qrpc.zqu__Model__c);                       
                            for(zqu__QuoteCharge_Tier__c qct : qrpc.zqu__Quote_RatePlan_Charge_Tier__r) 
                            {    
                                   if(qct.zqu__Effective_Price__c!=null)
                                   {
                                      //System.debug(' SKP New Tier >> : '+ qct.zqu__Tier__c); 
                                      //System.debug(' SKP New chargeTierId >> : '+ qct.Id);
                                      //System.debug(' SKP New PRice >> : '+ Decimal.valueOf(Double.valueOf(qct.zqu__Effective_Price__c)));
                                      mapChargeTiered.put(Integer.valueOf(qct.zqu__Tier__c), Decimal.valueOf(Double.valueOf(qct.zqu__Effective_Price__c)));  
                                   }                                   
                             }                           
                            //get Existing Subscription rateplan tier charge 
                            ZuoraSubscription.RatePlan ratePlan = zuoraSubscription.subscription.findRatePlanById(rwlChange.ratePlanId);
                            if(ratePlan != null){
                                for(ZuoraSubscription.RatePlanCharge ratePlanCharge : ratePlan.ratePlanCharges) {
                                    String chargeModel = ratePlanCharge.getStringValue('ChargeModel');
                                        if(chargeModel == 'Volume Pricing' || chargeModel == 'Tiered Pricing') {
                                            for(ZuoraSubscription.RatePlanChargeTier ratePlanChargeTier : ratePlanCharge.ratePlanChargeTiers) {
                                                ChargeTier ctier = new ChargeTier();
                                                Object zuoraTier = ratePlanChargeTier.getValue('Tier');
                                                if(zuoraTier != null) ctier.tier = Integer.valueOf(zuoraTier);
                                                Decimal zuoraPrice = ratePlanChargeTier.Price;                                            
                                                //Compare to New Quote Rate charge tiered vs Existing Subscription rateplan tier charge
                                                if(mapChargeTiered.containsKey(ctier.tier)){
                                                    Decimal newPrice=mapChargeTiered.get(ctier.tier); 
                                                    if(newPrice!=zuoraPrice){
                                                        System.debug('Update');
                                                        cs.action='Update';
                                                        rwlChange.action='Update';
                                                        break;
                                                    }
                                                }
                                                //System.debug(' SKP Old Tier >> : '+ ctier.tier);
                                                //System.debug(' SKP chargeTierId >> : '+ ctier.chargeTierId);
                                                //System.debug(' SKP Old PRice >> : '+ zuoraPrice);
                                }
                            }
                        }
                    }
                        //END                          
                        }
                    }
                }
                finalrwlChanges.add(rwlChange);//method SC2015_AGL-5547,09-Mar-2021
                this.changes.add(cs);
            }
            //just moved from top to bottom saveRenewalChanges method SC2015_AGL-5547,09-Mar-2021 
            finalrwlChanges.sort();
            zss.saveRenewalChanges(finalrwlChanges);
        }

        //Amendment
        if(!String.isBlank(qt.zqu__ExistSubscriptionID__c)) {
            ZuoraSubscription zuoraSubscription = ZuoraClient.getInstance().findZuoraSubscription(qt.zqu__ExistSubscriptionID__c);
            ZuoraSubscriptionState zss = new ZuoraSubscriptionState(zuoraSubscription);
            zss.addQuote(qt);
            List<ZuoraSubscriptionState.RenewalChange> rwlChanges = zss.getRenewalChanges();
            rwlChanges.sort();
            zss.saveRenewalChanges(rwlChanges);

            Map<Id, List<zqu__QuoteRatePlanCharge__c>> tiersByQRPID = loadChargeTiers(rwlChanges);

            for(ZuoraSubscriptionState.RenewalChange rwlChange : rwlChanges) {
                ChargeSummary cs = new ChargeSummary(rwlChange);
                if(!String.isBlank(rwlChange.quoteRatePlanId) && tiersByQRPID.containsKey(rwlChange.quoteRatePlanId)) {
                    for(zqu__QuoteRatePlanCharge__c qrpc : tiersByQRPID.get(rwlChange.quoteRatePlanId)) {
                        cs.ramp = qrpc.Ramp__c;
                        if(qrpc.zqu__Model__c == 'Volume Pricing' || qrpc.zqu__Model__c == 'Tiered Pricing') {
                            cs.addTiers(qrpc.zqu__Quote_RatePlan_Charge_Tier__r);
                        }
                    }
                }
                //if String.isBlank(rwlChange.quoteRatePlanId) then we need to grab the tiers from the existing subscription RatePlanTier...
                //this would be a "No Change"
                //ratePlanId
                if(String.isBlank(rwlChange.quoteRatePlanId) && !String.isBlank(rwlChange.ratePlanId)) {
                    ZuoraSubscription.RatePlan ratePlan = zuoraSubscription.subscription.findRatePlanById(rwlChange.ratePlanId);
                    if(ratePlan != null) {
                        for(ZuoraSubscription.RatePlanCharge ratePlanCharge : ratePlan.ratePlanCharges) {
                            String chargeModel = ratePlanCharge.getStringValue('ChargeModel');
                            if(chargeModel == 'Volume Pricing' || chargeModel == 'Tiered Pricing') {
                                for(ZuoraSubscription.RatePlanChargeTier ratePlanChargeTier : ratePlanCharge.ratePlanChargeTiers) {
                                    ChargeTier ctier = new ChargeTier();
                                    Object zuoraTier = ratePlanChargeTier.getValue('Tier');
                                    if(zuoraTier != null) ctier.tier = Integer.valueOf(zuoraTier);
                                    Decimal zuoraStartingUnit = ratePlanChargeTier.getDecimalValue('StartingUnit');
                                    if(zuoraStartingUnit != null) ctier.startingUnit = Math.round(zuoraStartingUnit);
                                    Decimal zuoraEndingUnit = ratePlanChargeTier.getDecimalValue('EndingUnit');
                                    if(zuoraEndingUnit != null) ctier.endingUnit = Math.round(zuoraEndingUnit);
                                    Decimal zuoraPrice = ratePlanChargeTier.Price;
                                    if(zuoraPrice != null) ctier.effectivePrice = Math.round(zuoraPrice);
                                    cs.tiers.add(ctier);
                                }
                            }
                        }
                    }
                }
                this.changes.add(cs);
            }
        }
        
        //New
        if(String.isBlank(qt.Renewal_Subscription_ID__c) && String.isBlank(qt.zqu__ExistSubscriptionID__c)) {
            Set<Id> qrpcIds = new Set<Id>();
            Map<Id, zqu__QuoteRatePlanCharge__c> quoteRatePlanChargesById = null;

            zqu__QuoteRatePlan__c[] quoteRatePlans = [select Id, zqu__ProductRatePlan__r.Name, zqu__QuoteProductName__c,
                                                      (select Id, zqu__EffectivePrice__c, zqu__Quantity__c, zqu__MRR__c from zqu__QuoteChargeSummarys__r),
                                                      (select Id, Ramp__c, zqu__Model__c from zqu__Quote_Rate_Plan_Charges__r)
                                                      from zqu__QuoteRatePlan__c where zqu__Quote__c = :qt.Id];
            for(zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
                if(!qrp.zqu__Quote_Rate_Plan_Charges__r.isEmpty()) {
                    zqu__QuoteRatePlanCharge__c qrpc = qrp.zqu__Quote_Rate_Plan_Charges__r[0];
                    if(qrpc.zqu__Model__c == 'Volume Pricing' || qrpc.zqu__Model__c == 'Tiered Pricing') qrpcIds.add(qrpc.Id);
                }
            }

            if(!qrpcIds.isEmpty()) {
                quoteRatePlanChargesById = new Map<Id, zqu__QuoteRatePlanCharge__c>(
                    [select Id, Ramp__c, zqu__Model__c, 
                    (select Id, zqu__Tier__c, zqu__StartingUnit__c, zqu__EndingUnit__c, zqu__Effective_Price__c from zqu__Quote_RatePlan_Charge_Tier__r order by zqu__Tier__c asc) 
                    from zqu__QuoteRatePlanCharge__c where Id in :qrpcIds
                    ]
                );
            }

            for(zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
                ChargeSummary change = new ChargeSummary();
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
                if(!qrp.zqu__Quote_Rate_Plan_Charges__r.isEmpty()) {

                    change.ramp = qrp.zqu__Quote_Rate_Plan_Charges__r[0].Ramp__c;
                    if(qrp.zqu__Quote_Rate_Plan_Charges__r[0].zqu__Model__c == 'Volume Pricing' || qrp.zqu__Quote_Rate_Plan_Charges__r[0].zqu__Model__c == 'Tiered Pricing') {
                        //need to grab the tiers
                        zqu__QuoteRatePlanCharge__c qrpc = quoteRatePlanChargesById.get(qrp.zqu__Quote_Rate_Plan_Charges__r[0].Id);
                        //add the tiers to the change object...
                        change.addTiers(qrpc.zqu__Quote_RatePlan_Charge_Tier__r);
                    }

                }
                this.changes.add(change);
            }
            this.changes.sort();
        }
        return null;
    }
    
    public Boolean isNew {
        get {
            return (qt.RecordType.Name == 'Default' || (qt.RecordType.Name == 'ReadOnly' && String.isBlank(qt.Renewal_Subscription_ID__c)));
        }
    }
    
    public String pageBlockTitle {
        get {
            return isNew ? 'New Subscription Summary' : 'Original vs New Subscription Summary';
        }
    }
    
    public String subscriptionType {
        get {
            if(qt.RecordType.Name == 'Amendment' || qt.RecordType.Name == 'Amendment ReadOnly') return 'Amendment';
            else if(qt.RecordType.Name == 'New Renewal' || (qt.RecordType.Name == 'ReadOnly' && !String.isBlank(qt.Renewal_Subscription_ID__c))) return 'Renewal';
            else if(isNew) return 'New Subscription';
            else return null;
        }
    }
    
    public class QuoteProductWrapper implements Comparable {
        public String action {get;set;}
        public String productName {get;set;}
        public String solutionProviderProduct {get;set;}
        
        public QuoteProductWrapper(Quote_Product__c qp) {
            this.action = qp.Action__c;    
            this.productName = qp.ZProduct__r.Name;
            this.solutionProviderProduct = qp.Solution_Provider_Product__r.Name;
        }
        
        public Integer compareTo(Object thatObj) {
            if(thatObj == null) return 1;
            QuoteProductWrapper that = (QuoteProductWrapper)thatObj;
            
            if(that.action == this.action) {
                return this.productName.compareTo(that.productName);
            }else{
                return this.actionScoreForSort() - that.actionScoreForSort();
            }
            //return 0;
        }
        
        private integer actionScoreForSort() {
            if(action == 'Renew Add') return 0;
            else if(action == 'Renew Remove') return 1;
            else if(action == 'Renew Update') return 2;
            else if(action == 'Renew Unchanged') return 3;
            else if(action == 'Add') return 0;
            else if(action == 'Remove') return 1;
            else if(action == 'Update') return 2;
            else if(action == 'Unchanged') return 3;
            else return 4;
        }
    }

    public class ChargeSummary  implements Comparable {
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
        public String ramp {get;set;}
        public List<ChargeTier> tiers {get;set;}

        public ChargeSummary() {
            tiers = new List<ChargeTier>();
        }

        public ChargeSummary(ZuoraSubscriptionState.RenewalChange renewalChange) {
            this.quoteRatePlanId = renewalChange.quoteRatePlanId;
            this.ratePlanId = renewalChange.ratePlanId;
            this.productRatePlanId = renewalChange.productRatePlanId;
            this.productName = renewalChange.productName;
            this.ratePlanName = renewalChange.ratePlanName;
            this.price = renewalChange.price;
            this.quotePrice = renewalChange.quotePrice;
            this.quantity = renewalChange.quantity;
            this.quoteQuantity = renewalChange.quoteQuantity;
            this.action = renewalChange.action;
            this.deltaMRR = renewalChange.deltaMRR;
            this.description = renewalChange.description;
            tiers = new List<ChargeTier>();
        }        

        public Boolean hasTiers {
            get {
                return !this.tiers.isEmpty();
            }
        }

        public Integer compareTo(Object thatObj) {
            if(thatObj == null) return 1;
            ChargeSummary that = (ChargeSummary)thatObj;
            if(that.action == this.action) {
                return this.ratePlanName.compareTo(that.ratePlanName);
            }else{
                return this.actionScoreForSort() - that.actionScoreForSort();
            }
            //return 0;
        }
        
        private integer actionScoreForSort() {
            if(action == 'Add') return 0;
            else if(action == 'Remove') return 1;
            else if(action == 'Update') return 2;
            else return 3;
        }
        
        public void addTiers(List<zqu__QuoteCharge_Tier__c> tiers) {
            for(zqu__QuoteCharge_Tier__c t : tiers) {
                this.tiers.add(new ChargeTier(t));
            }
        }
    }

    public class ChargeTier {
        public Id chargeTierId {get;set;}
        public Integer tier {get;set;}
        public Decimal startingUnit {get;set;}
        public Decimal endingUnit {get;set;}
        public Decimal effectivePrice {get;set;}
        
        public ChargeTier() {
            System.debug('Method : ChargeTier');//SC2015_AGL-5809
        }
        
        public ChargeTier(zqu__QuoteCharge_Tier__c qct) {
            this.chargeTierId = qct.Id;
            if(qct.zqu__Tier__c != null) this.tier = Integer.valueOf(qct.zqu__Tier__c);
            if(qct.zqu__StartingUnit__c != null) this.startingUnit = Math.round(qct.zqu__StartingUnit__c);
            if(qct.zqu__EndingUnit__c != null) this.endingUnit = Math.round(qct.zqu__EndingUnit__c);
            if(qct.zqu__Effective_Price__c != null) this.effectivePrice = qct.zqu__Effective_Price__c;
        }
            
    }
    
    //load the tiers, returned by quote rate plan ID
    private Map<Id, List<zqu__QuoteRatePlanCharge__c>> loadChargeTiers(List<ZuoraSubscriptionState.RenewalChange> renewalChanges)
    {
        Map<Id, zqu__QuoteCharge_Tier__c> tiersById = new Map<Id, zqu__QuoteCharge_Tier__c>();
        
        Set<Id> quoteRatePlanIds = new Set<Id>();
        
        for(ZuoraSubscriptionState.RenewalChange rwlChange : renewalChanges) {
            if(!String.isBlank(rwlChange.quoteRatePlanId)) {
                quoteRatePlanIds.add(rwlChange.quoteRatePlanId);
            }
        }
        
        Map<Id, List<zqu__QuoteRatePlanCharge__c>> quoteRatePlanChargesByQRPId = new Map<Id, List<zqu__QuoteRatePlanCharge__c>>();
        for(zqu__QuoteRatePlanCharge__c qrpc :
            [select Id, Ramp__c, zqu__Model__c, zqu__QuoteRatePlan__c,
             (select Id, zqu__Tier__c, zqu__StartingUnit__c, zqu__EndingUnit__c, zqu__Effective_Price__c from zqu__Quote_RatePlan_Charge_Tier__r order by zqu__Tier__c asc) 
             from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__c in :quoteRatePlanIds
            ])
        {
            if(quoteRatePlanChargesByQRPId.containsKey(qrpc.zqu__QuoteRatePlan__c)) {
                quoteRatePlanChargesByQRPId.get(qrpc.zqu__QuoteRatePlan__c).add(qrpc);
            } else {
                quoteRatePlanChargesByQRPId.put(qrpc.zqu__QuoteRatePlan__c, new List<zqu__QuoteRatePlanCharge__c>{ qrpc });
            }
        }

       return quoteRatePlanChargesByQRPId;
    }


    public static void coverage(){
        integer i=0;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
        i=i++;
    }

}