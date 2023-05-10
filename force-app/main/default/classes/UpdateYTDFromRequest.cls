public without sharing class UpdateYTDFromRequest {
    
    public static void UpdateYTDDataOnAccount(List<SFDC_MDF__c> FundRequestList){
        Set<String> AccountIdset;
        Map<String,Integer> AcFundRequestedYTDMap;
        Map<String,Integer> AcFundClaimedYTDMap;
        Integer CurrentYear = Integer.valueOf(System.today().year());
        
        if(!FundRequestList.isEmpty()){
            AccountIdset = new Set<String>();
            for(SFDC_MDF__c fr: FundRequestList){
                if(fr.Account__c != NULL){
                    AccountIdset.add(fr.Account__c);
                } 
            }
            if(!AccountIdset.isEmpty()){
                AcFundRequestedYTDMap = new Map<String,Integer>();
                AcFundClaimedYTDMap = new Map<String,Integer>();
                for(AggregateResult ar: [Select Account__c, SUM(Total_NCR_Estimated_Participation__c)FundReqYTD,
                                         SUM(Total_NCR_Approved__c)FunClaimedYTD from SFDC_MDF__c
                                         where Account__c in:AccountIdset AND Year_of_Submission__c =:CurrentYear
                                         GROUP BY Account__c]){
                                             AcFundRequestedYTDMap.put(String.valueOf(ar.get('Account__c')),Integer.valueOf(ar.get('FundReqYTD')));
                                             AcFundClaimedYTDMap.put(String.ValueOf(ar.get('Account__c')),Integer.valueOf(ar.get('FunClaimedYTD')));
                                         }
            }
            if(!AccountIdset.isEmpty()){
                List<Account> acList = [Select Funds_Requested_YTD__c, Funds_Claimed_YTD__c from Account WHERE id in:AccountIdset];
                for(Account a : aclist){
                    a.Funds_Requested_YTD__c = AcFundRequestedYTDMap.get(a.Id);
                    a.Funds_Claimed_YTD__c = AcFundClaimedYTDMap.get(a.Id);
                }
                if(!acList.isEmpty()){
                    database.update(acList);
                }
            }
        }    
    }
    
    @auraEnabled(cacheable=true)
    public static account SendCurrentPartnerAccount(String accId){ //Enable this method top take params
        if(accId!=NULL){
            Account a = [SELECT Funds_Claimed_YTD__c,Funds_Requested_YTD__c,ROI_on_MDF_Activities__c,Account_Region__c,Partner_Industry__c
                         ,Partner_Program_Level__c,LOB__c FROM Account WHERE id=:accId LIMIT 1];
            return a;
        } else{
            return NULL;
        }
    }
    @auraEnabled(cacheable = true)
    public static Integer AveragePartnerUse(String accId){ //Enable this method top take params
        Integer TotalFundsClaimed = 0;
        Integer TotalPartners = 0;
        Account a = SendCurrentPartnerAccount(accId);
        
        for(AggregateResult ar:[Select COUNT(id)totalAccounts,SUM(Funds_Claimed_YTD__c)totalClaimed FROM Account WHERE Account_Region__c = :a.Account_Region__c AND
                                         LOB__c = :a.LOB__c AND Partner_Program_Level__c = : a.Partner_Program_Level__c
                                         GROUP BY Partner_Program_Level__c] ){
                                     TotalFundsClaimed =+ Integer.valueOf(ar.get('totalClaimed'));
                                     TotalPartners =+ Integer.valueOf(ar.get('totalAccounts'));
                                 }
        if(TotalFundsClaimed !=0 && TotalPartners != 0){
            return  TotalFundsClaimed/TotalPartners;
        }else{
            return NULL;
        }
    }
}