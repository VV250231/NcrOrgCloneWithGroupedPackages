public with sharing class PRM_MarketCaptureProgramController {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<MarketCaptureProgram>> getMarketShareCaptureMap(){
        String currentIndustrys=  getCurrentUserIndustry();
        System.debug('==== Current Industrys ==== : '+currentIndustrys);
        Map<String,List<MarketCaptureProgram>> marketShareCaptureMap = new Map<String,List<MarketCaptureProgram>>();
        for(Market_Share_Captures__c marketShareCaptureRecord : [SELECT Id, Name, Description__c, URL__c FROM Market_Share_Captures__c]){
            if(marketShareCaptureRecord != null && marketShareCaptureRecord.Name != null){ 
                if(marketShareCaptureMap.containsKey(marketShareCaptureRecord.Name)){                        
                    List<MarketCaptureProgram> marketCaptureProgramList = new List<MarketCaptureProgram>();
                    MarketCaptureProgram marketCaptureProgram = new MarketCaptureProgram();
                    if(currentIndustrys.contains(marketShareCaptureRecord.Name)){
                        marketCaptureProgram.isClickable = true;
                        marketCaptureProgram.marketShareCapture_Obj =marketShareCaptureRecord ;
                    }else{
                        marketCaptureProgram.isClickable = false;
                        marketCaptureProgram.marketShareCapture_Obj =marketShareCaptureRecord ;
                    }                       
                    marketCaptureProgramList.add(marketCaptureProgram);
                    marketShareCaptureMap.put(marketShareCaptureRecord.Name,marketCaptureProgramList);
                }else{                         
                    MarketCaptureProgram marketCaptureProgram = new MarketCaptureProgram();
                    if(currentIndustrys.contains(marketShareCaptureRecord.Name)){
                        marketCaptureProgram.isClickable = true;
                        marketCaptureProgram.marketShareCapture_Obj =marketShareCaptureRecord ;
                    }else{
                        marketCaptureProgram.isClickable = false;
                        marketCaptureProgram.marketShareCapture_Obj =marketShareCaptureRecord ;
                    }                        
                    marketShareCaptureMap.put(marketShareCaptureRecord.Name, new List<MarketCaptureProgram>{marketCaptureProgram});
                }
            } 
        }
        System.debug('=== market Share Capture Map ==='+marketShareCaptureMap); 
        return marketShareCaptureMap;
    }

    public static String getCurrentUserIndustry(){
        User userRecord = [SELECT Id, Username,ContactId, Account.Partner_Industry__c FROM User Where id=:UserInfo.getUserId()];
        String currentIndustrys = '';
        if(userRecord != null){
            System.debug('==== User Infromation ==== : '+userRecord);
            if(userRecord.Account.Partner_Industry__c != null){
                currentIndustrys = userRecord.Account.Partner_Industry__c.trim();
            }
        }
        return currentIndustrys;
    }
     
    public class MarketCaptureProgram{
        @AuraEnabled
        public Boolean isClickable = false;

        @AuraEnabled 
        public Market_Share_Captures__c marketShareCapture_Obj;
    }
}