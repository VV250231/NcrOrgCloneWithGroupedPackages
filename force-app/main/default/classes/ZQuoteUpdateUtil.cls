// ===========================================================================
// Object: ZQuoteUpdateUtil
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: When an amendment quote is created, it is linked to a specific Zuora
// subscription version.  when the subscription gets amended by another quote or process
// the quote must be updated to match the current subscription version.
// ===========================================================================
// Changes: 2017-04-26 Reid Beckett
//           Class created
// ===========================================================================
public with sharing class ZQuoteUpdateUtil 
{
    public static Boolean DEBUG_MODE = false;
    
    @future(callout=true)
    public static void updateQuoteFuture(Set<Id> quoteIds) {
        for(Id quoteId : quoteIds){
            try{
                updateQuote(quoteId);
            }catch(Exception e){
                system.debug('Exception updating quote ' + quoteId + ':');
                system.debug(e.getMessage());
                system.debug(e.getStackTraceString());
            }
        }
    }
    
    public static void updateQuote(Id quoteId) {
        //update these fields from the current subscription:
        //zqu__SubscriptionTermEndDate__c, zqu__SubscriptionTermStartDate__c, 
        //zqu__SubscriptionVersion__c, zqu__Subscription_Name__c, zqu__Subscription_Term_Type__c, zqu__ExistSubscriptionID__c
        //1) Query the subscription, grab the OriginalID.
        //2) If the subscription is the latest, do nothing. (Status = Active)
        //3) if not latest, query for latest using Original ID (Status != Active)
        //4) Update quote from latest
        zqu__Quote__c[] qts = [select Id, RecordType.Name, zqu__ExistSubscriptionID__c from zqu__Quote__c where Id = :quoteId];
        if(qts.isEmpty()) throw new ZQuoteUpdateException('Quote not found');
        
        zqu__Quote__c qt = qts.get(0);
        
        if(qt.RecordType.Name != 'Amendment') throw new ZQuoteUpdateException('Quote update can only be performed on an amendment quote before it is updated as Sent to Z-Billing');
        if(String.isBlank(qt.zqu__ExistSubscriptionID__c)) throw new ZQuoteUpdateException('This quote is an amendment, but it does not have the Exist Subscription ID populated');
        
        ZuoraSubscription zsub = ZuoraClient.getInstance().findZuoraSubscription(qt.zqu__ExistSubscriptionID__c);
        if(zsub == null) throw new ZQuoteUpdateException('Subscription not found');
        String subscriptionStatus = zsub.subscription.getStringValue('Status');
        
        if(subscriptionStatus != 'Active') {
            String originalID = zsub.subscription.getStringValue('OriginalId');
            
            String zoql = 'select Id, Name, Version, Status, TermStartDate, TermEndDate, TermType from Subscription where OriginalId = \''+originalID+'\'';
            Zuora.ZObject[] zsubs = ZuoraClient.getInstance().zquery(zoql);
            if(zsubs.isEmpty()) throw new ZQuoteUpdateException('Could not find the active subscription for the original ID: ' + originalID);
            
            //sort by version and find the active one
            SubscriptionWrapper[] allSubscriptions = new SubscriptionWrapper[]{};
            SubscriptionWrapper activeSubscription = null;
            Decimal quoteSubscriptionVersion = null;
            
            for(Zuora.zObject zsubscription : zsubs) {
                SubscriptionWrapper subWrapper = new SubscriptionWrapper(zsubscription);
                allSubscriptions.add(subWrapper);   
                if(subWrapper.status == 'Active') activeSubscription = subWrapper;
                if(subWrapper.id == qt.zqu__ExistSubscriptionID__c) quoteSubscriptionVersion = subWrapper.subscriptionVersion;
            }
            
            //sort by version descending
            allSubscriptions.sort();
            system.debug('after subscription sort:');
            for(SubscriptionWrapper swrap : allSubscriptions) {
                system.debug(swrap.subscriptionVersion + ':'+swrap.id);
            }
            
            if(activeSubscription == null) throw new ZQuoteUpdateException('Could not find the active subscription for the original ID: ' + originalID);
            
            Zuora.zObject activeZSub = activeSubscription.zsubscription;
            
            qt.zqu__ExistSubscriptionID__c = activeSubscription.id;
            qt.zqu__SubscriptionVersion__c = activeSubscription.subscriptionVersion;
            qt.zqu__Subscription_Term_Type__c = activeSubscription.termType;
            qt.zqu__SubscriptionTermStartDate__c = activeSubscription.termStartDate;
            qt.zqu__SubscriptionTermEndDate__c = activeSubscription.termEndDate;
            
            system.debug('setting zqu__ExistSubscriptionID__c='+qt.zqu__ExistSubscriptionID__c);
            system.debug('setting zqu__SubscriptionVersion__c='+qt.zqu__SubscriptionVersion__c);
            system.debug('setting zqu__Subscription_Term_Type__c='+qt.zqu__Subscription_Term_Type__c);
            system.debug('setting zqu__SubscriptionTermStartDate__c='+qt.zqu__SubscriptionTermStartDate__c);
            system.debug('setting zqu__SubscriptionTermEndDate__c='+qt.zqu__SubscriptionTermEndDate__c);
            
            zqu__QuoteRatePlan__c[] quoteRatePlans = [select Id, zqu__ProductRatePlanZuoraId__c, zqu__SubscriptionRatePlanZuoraId__c from zqu__QuoteRatePlan__c where zqu__Quote__c = :quoteId and zqu__SubscriptionRatePlanZuoraId__c != null];
            if(!quoteRatePlans.isEmpty()) {
                
                Map<String, String> ratePlanIdsByAmendedRatePlanIds = new Map<String,String>();
                
                Set<String> amendmendedSubscriptionIds = new Set<String>();
                for(SubscriptionWrapper swrap : allSubscriptions) {
                    if(swrap.subscriptionVersion > quoteSubscriptionVersion) {
                        amendmendedSubscriptionIds.add(swrap.id);
                    }
                }
                
                Map<String,Zuora.zObject[]> ratePlansBySubscriptionId = findRatePlansBySubscriptionIds(amendmendedSubscriptionIds);
                for(SubscriptionWrapper swrap : allSubscriptions) {
                    if(swrap.subscriptionVersion > quoteSubscriptionVersion) {
                        amendmendedSubscriptionIds.add(swrap.id);
                    }
                }
                
                for(zqu__QuoteRatePlan__c qrp : quoteRatePlans) {
                    system.debug('matching qrp on '+qrp.zqu__SubscriptionRatePlanZuoraId__c+' by product ' + qrp.zqu__ProductRatePlanZuoraId__c);
                    Boolean matched = false;
                    for(SubscriptionWrapper swrap : allSubscriptions) {
                        if(!matched && ratePlansBySubscriptionId.containsKey(swrap.id)) {
                            for(Zuora.zObject zRatePlan : ratePlansBySubscriptionId.get(swrap.id)) {
                                //IF THERE ARE MULTIPLE MATCHES ON SAME PRODUCT, WE HAVE NO WAY OF KNOWING WHICH
                                //IS INTENDED TO UPDATE or REMOVE
                                String productRatePlanId = (String)zRatePlan.getValue('ProductRatePlanId');
                                if(!matched && productRatePlanId == qrp.zqu__ProductRatePlanZuoraId__c){
                                    matched = true;
                                    system.debug('set ' + qrp.zqu__SubscriptionRatePlanZuoraId__c + ' to ' + (String)zRatePlan.getValue('Id'));
                                    qrp.zqu__SubscriptionRatePlanZuoraId__c = (String)zRatePlan.getValue('Id');
                                }
                            }
                        }
                    }
                }
                if(!DEBUG_MODE) update quoteRatePlans;
            }
            
            if(!DEBUG_MODE) update qt;
        }
    }
    
    private static Map<String,Zuora.zObject[]> findRatePlansBySubscriptionIds(Set<String> subscriptionIds){
        if(subscriptionIds == null || subscriptionIds.isEmpty()) return new Map<String,Zuora.zObject[]>();
        String zoql = 'select Id, AmendmentId, AmendmentSubscriptionRatePlanId, SubscriptionId, ProductRatePlanId from RatePlan where ' + ZuoraClient.generateOrClause('SubscriptionId', new List<String>(subscriptionIds));
        system.debug(zoql);
        Map<String,Zuora.zObject[]> m = new Map<String,Zuora.zObject[]>();
        for(Zuora.zObject zobj : ZuoraClient.getInstance().zquery(zoql)){
            String subscriptionId = (String)zobj.getValue('SubscriptionId');
            if(!m.containsKey(subscriptionId)) m.put(subscriptionId, new Zuora.zObject[]{ zobj });
            else m.get(subscriptionId).add(zobj);
        }        
        return m;
    }

    public class ZQuoteUpdateException extends Exception {
        
    }
    
    class SubscriptionWrapper implements Comparable {
        public Zuora.zObject zsubscription;
        public String id;
        public String originalId;
        public Decimal subscriptionVersion;
        public String status;
        public String termType;
        public Date termStartDate;
        public Date termEndDate;
        
        public SubscriptionWrapper(Zuora.zObject zsub) {
            this.zsubscription = zsub;
            this.id = (String)zsub.getValue('Id');
            this.originalId = (String)zsub.getValue('OriginalId');
            this.subscriptionVersion = (Decimal)zsub.getValue('Version');
            this.status = (String)zsub.getValue('Status');
            this.termType = (String)zsub.getValue('TermType');
            this.termStartDate = (Date)zsub.getValue('TermStartDate');
            this.termEndDate = (Date)zsub.getValue('TermEndDate');
        }

        public Integer compareTo(Object thatObj) {
            if(thatObj == null) return -1;
            SubscriptionWrapper that = (SubscriptionWrapper)thatObj;
            
            return Integer.valueOf(that.subscriptionVersion - this.subscriptionVersion);
        }
    }
}