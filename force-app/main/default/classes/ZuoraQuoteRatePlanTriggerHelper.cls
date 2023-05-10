/**************************************
Author ...............: Sanjay Pandit
Date Created .........: 22-Sep-2020
Last Modified By .....:
Last Modified Date ...: 
Description ..........: SC2015_AGL-5787, Trigger Consolidation  
***************************************/
public with sharing class ZuoraQuoteRatePlanTriggerHelper {
    Set<ID> zQuoteIds = new Set<ID>();
    
	//defaults the Product Id on the Quote Rate Plan object after the creation of Quote.
    public void onBeforeInsertdefaultProductId(List<zqu__QuoteRatePlan__c> listQuoteRatePlan){
        Set<Id> quoteId = new  Set<Id>();
        for(zqu__QuoteRatePlan__c var : listQuoteRatePlan)
        {
            quoteId.add(var.zqu__Quote__c);
        }
        
        list<zqu__quote__c> listofNewQuotes = [Select Id, Name, zqu__Number__c, zqu__SubscriptionType__c, zqu__ExistSubscriptionID__c from zqu__quote__c where Id IN :quoteId ];
        
        set<String> setOfExistingExistSubscriptionRPID = new set<String>();
        
        if(!listofNewQuotes.isEmpty())
        {
            for(zqu__QuoteRatePlan__c Temp : listQuoteRatePlan){
                for(zqu__quote__c TempQuote : listofNewQuotes){
                    system.debug('the value of formula field' + Temp.ListMarketProductIdsfromProduct__c);
                    if(TempQuote.Id == Temp.zqu__Quote__c && (Temp.zqu__AmendmentType__c == 'NewProduct' ||  Temp.zqu__AmendmentType__c == 'Original') && Temp.ListMarketProductIdsfromProduct__c != null){
                        List<String> PrimaryProductId = new List<String>();
                        PrimaryProductId = Temp.ListMarketProductIdsfromProduct__c.split(';');
                        Temp.MarketProductId__c = PrimaryProductId.get(0);
                    }
                    else{
                        system.debug('Adding values in the Exisiting Sub Id...');
                        if(Temp.zqu__SubscriptionRatePlanZuoraId__c != null){
                            setOfExistingExistSubscriptionRPID.add(Temp.zqu__SubscriptionRatePlanZuoraId__c);
                        }
                    }
                }
            }
        }
        if(!setOfExistingExistSubscriptionRPID.isEmpty())
        {
            system.debug('before the Query on SRP...');
            List<zuora__SubscriptionRatePlan__c> listOfExistingSubs= [Select Id, Name, Zuora__Subscription__c, MarketProductId__c,  Zuora__External_Id__c, Zuora__OriginalSubscriptionRatePlanId__c from zuora__SubscriptionRatePlan__c where Zuora__External_Id__c IN :setOfExistingExistSubscriptionRPID and Zuora__Subscription__c != null];
            if(!listOfExistingSubs.isEmpty())
            {
                for(zqu__QuoteRatePlan__c Temp : listQuoteRatePlan){
                    if(Temp.zqu__AmendmentType__c != 'NewProduct' /*&& Temp.zqu__AmendmentType__c != 'Original'*/){
                        for(zuora__SubscriptionRatePlan__c varSRP: listOfExistingSubs){
                            if( Temp.zqu__SubscriptionRatePlanZuoraId__c == varSRP.Zuora__External_Id__c){
                                if(varSRP.MarketProductId__c != null){
                                    Temp.MarketProductId__c = varSRP.MarketProductId__c;    
                                }
                                else{
                                    if(Temp.ListMarketProductIdsfromProduct__c != null){
                                        List<String> PrimaryProductId = new List<String>();
                                        PrimaryProductId = Temp.ListMarketProductIdsfromProduct__c.split(';');
                                        Temp.MarketProductId__c = PrimaryProductId.get(0);
                                    }   
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void OnAfterDeleteCalcACVandUpdateOLIs(List<zqu__QuoteRatePlan__c> listQuoteRatePlanOld)
    {
        for (zqu__QuoteRatePlan__c zRatePlan : listQuoteRatePlanOld) {
            if (zRatePlan.zqu__Quote__c != null) {
                zQuoteIds.add(zRatePlan.zqu__Quote__c);
            }    
        } 
        if(!zQuoteIds.isEmpty()) new ZuoraChargeUtil().calcACVFromQuote(zQuoteIds); 
    }
    
    public void OnAfterUndeleteCalcACVandUpdateOLIs(List<zqu__QuoteRatePlan__c> listQuoteRatePlanNew)
    {
        for (zqu__QuoteRatePlan__c zRatePlan : listQuoteRatePlanNew) {
            if (zRatePlan.zqu__Quote__c != null) {
                zQuoteIds.add(zRatePlan.zqu__Quote__c);
            }    
        }
        if(!zQuoteIds.isEmpty()) new ZuoraChargeUtil().calcACVFromQuote(zQuoteIds);  
    }
    
    public void OnAfterUpdateCalcACVandUpdateOLIs(List<zqu__QuoteRatePlan__c> listQuoteRatePlanNew,Map<Id, zqu__QuoteRatePlan__c> mapOldQuoteRatePlan)
    {
        for (zqu__QuoteRatePlan__c zRatePlan : listQuoteRatePlanNew) {
            if (zRatePlan.zqu__Quote__c != null && mapOldQuoteRatePlan.get(zRatePlan.id).MarketProductId__c != zRatePlan.MarketProductId__c && String.isNotBlank(zRatePlan.MarketProductId__c ) && ( zRatePlan.zqu__AmendmentType__c != 'Original' || String.isNotBlank(zRatePlan.zqu__AmendmentType__c))) {
                zQuoteIds.add(zRatePlan.zqu__Quote__c);
            }    
        }
        if(!zQuoteIds.isEmpty()) new ZuoraChargeUtil().calcACVFromQuote(zQuoteIds);  
    }
}