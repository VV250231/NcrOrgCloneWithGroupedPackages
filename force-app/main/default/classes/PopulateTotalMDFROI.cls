// This class is designed to Populate Current Year MDF Related Revenue (CY_MDF_ROI__c), which is being used in 
// MDF Dashboard.

public  class PopulateTotalMDFROI{
    public static void PopulateTotalROIfromPFROI(List<Partner_Fund_ROI__c> pfROIlist){
        Set<String> PartnerAcIds = new Set<String>();
        Map<String,Integer> AcIdMdfCYSumMap;
        List<Account> acList;
        for(Partner_Fund_ROI__c pfroi : pfROIlist){
            if(pfroi.Revenue_Year__c != NULL && pfroi.Revenue_Year__c == String.valueOf(System.Today().year())){
                PartnerAcIds.add(pfroi.Partner_Account__c);                
		}
		}
            if(!PartnerAcIds.isEmpty()){
                AcIdMdfCYSumMap = new Map<String,Integer>();
                for(AggregateResult ar : [Select Partner_Account__c, SUM(Current_Revenue_earned__c) revSum FROM Partner_Fund_ROI__c WHERE Partner_Account__c in:PartnerAcIds GROUP BY Partner_Account__c]){
                    AcIdMdfCYSumMap.put(String.valueOf(ar.get('Partner_Account__c')),Integer.valueOf(ar.get('revSum')));
                }
            }
            if(AcIdMdfCYSumMap.keySet().size() != 0){
                acList = new List<Account>();
                for(Account a : [Select CY_MDF_ROI__c from Account WHERE id in:AcIdMdfCYSumMap.keySet()]){
                    a.CY_MDF_ROI__c = AcIdMdfCYSumMap.get(a.Id);
                    acList.add(a);
                }
            }
            
            if(!acList.isEmpty()){
                database.update(acList);
            }
        
    }
    /*public static void PopulateTotalROIonPartnerRev(List<Partner_Revenue__c> PartRevList){
        Set<String> PRYears = new Set<String>();
        Set<String> PRAcIds = new Set<String>();
        map<String, Partner_Revenue__c> PartnerAccountMap =new map<String, Partner_Revenue__c>();
        for(Partner_Revenue__c pr:PartRevList){
            if(pr.Year__c != NULL){
                PRYears.add(pr.Year__c);
                PRAcIds.add(pr.Partner_Account__c);
                PartnerAccountMap.put(pr.Partner_Account__c,pr);
            }
        }
        if(PRYears.size()!=0 && PRAcIds.size() != 0){
            for(AggregateResult ar : [Select Partner_Account__c,SUM(Current_Revenue_earned__c)revSum from Partner_Fund_ROI__c where Partner_Account__c in:PRAcIds 
                                      AND Revenue_Year__c in:PRYears group by Partner_Account__c]){
                                          PartnerAccountMap.get(string.valueOf(ar.get('Partner_Account__c'))).Total_MDF_ROI__c = Integer.valueOf(ar.get('revSum'));
                                      }
        }
    }*/
    
}