public class CPQQuotesToExpireRecords {
   
    @AuraEnabled(cacheable=false)
    public static List<SBQQ__Quote__c> retrieveQuotes(String userID){
        
        List<SBQQ__Quote__c> lst = [SELECT ID, NAME,SBQQ__Status__c,qtc_Legal_Document_Status__c,qtc_Status_of_all_Applications__c,format(SBQQ__ExpirationDate__c),format(CreatedDate) FROM SBQQ__Quote__c 
        WHERE SBQQ__Status__c !='Expired' 
        AND ((SBQQ__ExpirationDate__c = NEXT_N_DAYS:7) OR (SBQQ__ExpirationDate__c <= TODAY)) 
        AND SBQQ__Ordered__c = false
        AND (NOT qtc_Legal_Document_Status__c LIKE 'Completed%')
        AND (qtc_Status_of_all_Applications__c != 'ApprovedAndBoarded')
        AND SBQQ__SalesRep__r.Id =: userID
        ];
        
        List<SBQQ__Quote__c> lstNew = new List<SBQQ__Quote__c>();
        Set<Id> resultIds = (new Map<Id,SObject>(lst)).keySet();
        Set<Id> notExpQte = new Set<Id>();
        for(NCR_Payments_Site__c pSite: [Select Quote__r.Id,NCR_Payments_Application_Status__c from NCR_Payments_Site__c where NCR_Payments_Application_Status__c='ApprovedAndBoarded'
                                                   AND Quote__r.Id IN: resultIds]){
                notExpQte.add(pSite.Quote__r.Id);
        }
		
        for(SBQQ__Quote__c qt:lst){
               if(!notExpQte.contains(qt.id)){
                   lstNew.add(qt);
               }
        }
        
        return lstNew;
    }

    @AuraEnabled(cacheable=false)
    public static SBQQ__Quote__c getQuote(String qid){
        SBQQ__Quote__c quote;
        List<SBQQ__Quote__c> lq = [SELECT ID, NAME,SBQQ__Status__c,qtc_Legal_Document_Status__c,qtc_Status_of_all_Applications__c,FORMAT(SBQQ__ExpirationDate__c),FORMAT(CreatedDate) FROM SBQQ__Quote__c where Id =:qid 
        AND SBQQ__Status__c !='Expired' 
        AND ((SBQQ__ExpirationDate__c = NEXT_N_DAYS:7 ) OR (SBQQ__ExpirationDate__c <= TODAY)) 
        AND SBQQ__Ordered__c = false
        AND (NOT qtc_Legal_Document_Status__c LIKE 'Completed%')
        AND (qtc_Status_of_all_Applications__c != 'ApprovedAndBoarded')];
        
        List<SBQQ__Quote__c> lstNew = new List<SBQQ__Quote__c>();
        Set<Id> resultIds = (new Map<Id,SObject>(lq)).keySet();
        Set<Id> notExpQte = new Set<Id>();
        for(NCR_Payments_Site__c pSite: [Select Quote__r.Id,NCR_Payments_Application_Status__c from NCR_Payments_Site__c where NCR_Payments_Application_Status__c='ApprovedAndBoarded'
                                                   AND Quote__r.Id IN: resultIds]){
                notExpQte.add(pSite.Quote__r.Id);
        }
		
        for(SBQQ__Quote__c qt:lq){
               if(!notExpQte.contains(qt.id)){
                   lstNew.add(qt);
               }
        }
        
        if(lstNew.size()>0){
            quote = lstNew.get(0);
        }
        
        return quote;
    }

    
    @AuraEnabled(cacheable=false) 
    public static AQS_CPQ_Flow__c getCustomSettings(){
        return AQS_CPQ_Flow__c.getInstance();
    }


    @AuraEnabled(cacheable=false)
    public static QuoteListWrapper retrieveQuotes1(String userID){
        QuoteListWrapper qlw = new QuoteListWrapper();
        qlw.quotetList = retrieveQuotes(userID);
        if(UserInfo.getUserType()=='Partner' || UserInfo.getUserType()=='PowerPartner'){
            qlw.quoteURL = AQS_CPQ_Flow__c.getInstance().qtc_Community_URL__c;
        } else {
            qlw.quoteURL = AQS_CPQ_Flow__c.getInstance().AQS_URL__c;
        }
        return qlw;
    }
}