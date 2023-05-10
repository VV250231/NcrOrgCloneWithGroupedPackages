public class PriceBookBatch implements Database.Batchable<SObject>, Database.Stateful {
    list<CurrencyType> crncyList; 
    list<PriceBook2> pbList;
    public Database.queryLocator start(Database.BatchableContext bc) {
        crncyList = [SELECT ISOCode FROM CurrencyType WHERE IsActive=TRUE];
        
        pbList = [SELECT id, name, IsStandard FROM PriceBook2 WHERE (IsActive=TRUE AND id=:GlobalVariable.pricebookId) OR IsStandard=TRUE];  
        System.debug(GlobalVariable.pricebookId + 'AAAA');
        System.debug(pbList.size() > 0);
        return Database.getqueryLocator([SELECT Id from Product2 where isActive= true and product_type__c = 'Topline']);
    }
    
    public void execute(Database.BatchableContext bc, List<Product2> prdList) {
        // get active currencies
        
        Map<Id, Set<String>> glblCurrency=new Map<Id, Set<String>>();
        Map<Id, Set<String>> stdCurrency=new Map<Id, Set<String>>();
        List<PricebookEntry> updatePBELst = new List<PricebookEntry>();
        
        // get all available PBEs of product
        List <PriceBookEntry> allPbe=[Select id, isActive, CurrencyIsoCode, PriceBook2.IsStandard, Product2Id from PriceBookEntry where Product2Id IN :prdList] ;
        // activate available PBEs
        for(PricebookEntry pbe:allPbe){
            if(pbe.IsActive == false) {
                pbe.IsActive=true;  
                updatePBELst.add(pbe);
            }
            
            // adding to currency set to avoid creation of available PBEs
            if(pbe.priceBook2.IsStandard){
                Set<String> currSet = stdCurrency.get(pbe.Product2Id);
                if (currSet == NULL) {
                    currSet = new Set<String>();
                    currSet.add(pbe.CurrencyIsoCode);
                    stdCurrency.put(pbe.Product2Id, currSet);
                } else {
                    currSet.add(pbe.CurrencyIsoCode);
                }
            }else{
                Set<String> currSet = glblCurrency.get(pbe.Product2Id);
                if (currSet == NULL) {
                    currSet = new Set<String>();
                    currSet.add(pbe.CurrencyIsoCode);
                    glblCurrency.put(pbe.Product2Id, currSet);
                } else {
                    currSet.add(pbe.CurrencyIsoCode);
                }
            }
        }
        
        List <PriceBookEntry> std=new List<PriceBookEntry>();
        List <PriceBookEntry> glbl=new List<PriceBookEntry>();
        
        for(Product2 p : prdList) {				   
            // Create pricebookentries
            for(CurrencyType c:crncyList){                          
                for(PriceBook2 pb:pbList){
                    if(pb.IsStandard==true){
                        // there is not already std PBE of the currency then create PBE
                        Set<String> stdCurrSet = stdCurrency.get(p.Id);
                        if(stdCurrSet!= NULL && !(stdCurrSet.contains(c.IsoCode))){
                            PriceBookEntry pbe=new PriceBookEntry();
                            pbe.CurrencyIsoCode=c.IsoCode;
                            pbe.isActive=true;
                            pbe.Product2Id=p.id;
                            pbe.UnitPrice=0;
                            pbe.UseStandardPrice=false; 
                            pbe.Pricebook2Id=pb.id;
                            std.add(pbe);
                        }
                    }
                    else{
                        // there is not already global PBE of the currency then create PBE
                        Set<String> gblCurrSet = glblCurrency.get(p.Id);
                        if(gblCurrSet != NULL && !(gblCurrSet.contains(c.IsoCode))){
                            PriceBookEntry pbe=new PriceBookEntry();
                            pbe.CurrencyIsoCode=c.IsoCode;
                            pbe.isActive=true;
                            pbe.Product2Id=p.id;
                            pbe.UnitPrice=0;
                            pbe.UseStandardPrice=false; 
                            pbe.Pricebook2Id=pb.id;
                            glbl.add(pbe);
                        }
                    }
                }
            }    
        }
        
        update updatePBELst;
        insert std;
        insert glbl;
        
        
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
}