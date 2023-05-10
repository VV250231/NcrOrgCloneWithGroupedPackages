global class updateMarketProductonQRP implements Database.Batchable<sObject> {
//map of contactid - contact
map<Id, Set<string>> productIdMapSetMarketId = new map<Id, Set<string>>();
map<Id, string> productIdMapPrimaryMarketId = new map<Id, string>();

global updateMarketProductonQRP(map<Id, Set<string>> ProMarketSet, map<Id, string> PriProMarketIdMap) {
this.productIdMapSetMarketId = ProMarketSet;
this.productIdMapPrimaryMarketId = PriProMarketIdMap;
}
global Database.QueryLocator start(Database.BatchableContext BC) {
return DataBase.getQueryLocator([Select Id, Name, zqu__Quote__r.zqu__Status__c, MarketProductId__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c From zqu__QuoteRatePlan__c where zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c IN :productIdMapSetMarketId.keySet() and zqu__Quote__r.zqu__Status__c != 'Sent to Z-Billing' and zqu__Quote__r.zqu__Opportunity__r.StageName NOT IN ('Closed/Booked','Closed/Lost','Closed/Discontinued') and zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c != null]);
}
global void execute(Database.BatchableContext BC,List<zqu__QuoteRatePlan__c> listOfQRPToCheckChunk) {
        If(!listOfQRPToCheckChunk.isEmpty())
        {
            Set<Id> setOfQRPId = new Set<Id>();
            For(zqu__QuoteRatePlan__c Tempvar : listOfQRPToCheckChunk){
                setOfQRPId.add(Tempvar.Id);
            }
            if(!setOfQRPId.isEmpty()){
                List<zqu__QuoteRatePlan__c> listOfQRPToCheck = new List<zqu__QuoteRatePlan__c>();
                listOfQRPToCheck = [Select Id,Name,MarketProductId__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c From zqu__QuoteRatePlan__c where Id IN :setOfQRPId FOR UPDATE];
                if(!listOfQRPToCheck.isEmpty()){
                    //system.debug('Inside 4');
                    List<zqu__QuoteRatePlan__c> ListToUpdateQRP123 = new List<zqu__QuoteRatePlan__c>();
                    for(zqu__QuoteRatePlan__c tempvar: listOfQRPToCheck){
                        //system.debug('Inside 5');
                        if(!productIdMapSetMarketId.isEmpty() && productIdMapSetMarketId.containsKey(tempvar.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c)){
                           // system.debug('Inside 6');
                            Set<String> existing= productIdMapSetMarketId.get(tempvar.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c);
                            if(!existing.contains(tempvar.MarketProductId__c)){
                                //system.debug('Inside 7');
                                tempvar.MarketProductId__c = productIdMapPrimaryMarketId.get(tempvar.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__c);
                                ListToUpdateQRP123.add(tempvar);
                            }
                        }
                    }
                    If(!ListToUpdateQRP123.isEmpty()){
                        update ListToUpdateQRP123;
                    }
                }
            }
        }
}

global void finish(Database.BatchableContext BC) {
    system.debug('Batch Processing Finish..');
}
}