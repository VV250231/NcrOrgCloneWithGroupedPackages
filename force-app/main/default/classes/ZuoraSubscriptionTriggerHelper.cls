/**************************************
Author ...............: Sanjay Pandit
Date Created .........: 23-Sep-2020
Last Modified By .....:
Last Modified Date ...: 
Description ..........: SC2015_AGL-5787, Trigger Consolidation  
***************************************/
public with sharing class ZuoraSubscriptionTriggerHelper {
    
    //populate QuoteID On Subscription
    public void onBeforeInserUpdateQuoteIDOnSubscription(List<Zuora__Subscription__c> zuoraSubsListNew)
    {
        List<String> SubscriptionIDs = New List<String>();
        Map<String, Id> QuoteMap = New map<String, Id>();
        List<zqu__Quote__c> Quotes = New List<zqu__Quote__c>();
        for(Zuora__Subscription__c Subscription : zuoraSubsListNew){
            SubscriptionIDs.add(Subscription.Zuora__Zuora_Id__c);
        }
        Quotes = [Select Id , zqu__ZuoraSubscriptionID__c from zqu__Quote__c where zqu__ZuoraSubscriptionID__c IN : SubscriptionIDs];
        
        for( zqu__Quote__c Quote : Quotes ){
            QuoteMap.put(Quote.zqu__ZuoraSubscriptionID__c, Quote.ID);
        }
        for(Zuora__Subscription__c Subscription : zuoraSubsListNew){
            Subscription.QuoteId__c = QuoteMap.get(Subscription.Zuora__Zuora_Id__c);
        }
    }
    
    //UpdateSubscriptionChargesInZuora
    public void onAfterInsertUpdateSubscriptionChargesInZuora(List<Zuora__Subscription__c> zuoraSubsListNew){
        Set<String> zQuoteNumber = new Set<String>();
        Set<String> setSubscriptionId = new Set<String>(); // for story SC2015_AGL-4362
        
        for(Zuora__Subscription__c  objZuoraSubs : zuoraSubsListNew){
            setSubscriptionId.add(objZuoraSubs.id); // for story SC2015_AGL-4362
            zQuoteNumber.add(objZuoraSubs.Zuora__QuoteNumber__c);
        }
        if((zQuoteNumber != null && zQuoteNumber.size()> 0) || (setSubscriptionId != null && setSubscriptionId.size() > 0)){  
            FutureClassForQuotes.updateSubscriptionChargesOfZuora(zQuoteNumber,setSubscriptionId);
        }
    }
    
    //SubscriptionTrigger
    public void onAfterDeleteSubscriptionTrigger(List<Zuora__Subscription__c> zuoraSubsListOld){
        if(ZuoraOptions__c.getInstance().Update_Quotes_on_Subscription_Sync__c){
            Set<String> zuoraIds = new Set<String>();
            
            for(Zuora__Subscription__c zsub : zuoraSubsListOld) {
                if(!String.isBlank(zsub.Zuora__Zuora_Id__c)) zuoraIds.add(zsub.Zuora__Zuora_Id__c);
            }
            Set<Id> quoteIds = new Set<Id>();
            
            for(zqu__Quote__c qt : [select Id from zqu__Quote__c where zqu__Status__c = 'New' and Exist_Subscription_ID_External_ID__c in :zuoraIds]) {
                quoteIds.add(qt.Id);
            }
            if(!quoteIds.isEmpty()) ZQuoteUpdateUtil.updateQuoteFuture(quoteIds);
        }   
    }
}