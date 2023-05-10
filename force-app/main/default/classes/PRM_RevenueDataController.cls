public with sharing class PRM_RevenueDataController {
    /*
     Returns list of all the records 
    **/
    @AuraEnabled
    public static Map<Integer,Partner_Revenue__c> getRevenueList(String accountId) {
        List<Partner_Revenue__c> partnerRevenueList =[SELECT Id, Direct_Revenue__c, Indirect_Revenue__c, Hardware__c, Software__c, Professional_Services__c,  
            TS__c,Recurring_SW__c,Recurring_PS__c, Hosted__c, SaaS__c, POSaaS__c, Min_Total_Revenue_to_Platinum__c, Total_Services_Revenue__c, Total_Solution_Revenue__c, 
            Total_Subscription_Revenue__c, Total_Revenue__c, First_Half__c, Second_Half__c, Partner_Account__c, Year__c 
            FROM Partner_Revenue__c WHERE Partner_Account__c =: accountId LIMIT 5];

        Map<Integer,Partner_Revenue__c> revenueMap = new Map<Integer,Partner_Revenue__c>();
        for(Partner_Revenue__c revenueRecord : partnerRevenueList){
            if(revenueRecord.Year__c != null){
                revenueMap.put(Integer.valueOf(revenueRecord.Year__c),revenueRecord);
            }
        }
        return revenueMap;
    }
   /*EBA_SF-1593 added fields for the fetching quota and YTD Order field for Revenue Performance Chart for only HOSPitality SMB Partner Manager*/
    @AuraEnabled(cacheable=true)
    public static Partner_Revenue__c getPartnerRevenueByYear(String accountId, String year){
        System.debug(accountId);
        System.debug(year);
        List<Partner_Revenue__c> partnerRevenueRecordList = [SELECT Id, Min_Total_Revenue_to_Platinum__c,Direct_Revenue__c,Hardware__c,Hosted__c,
                            Indirect_Revenue__c, Min_total_revenue_for_next_tier__c,Net_New_Customer_Revenue__c, First_Half__c, Second_Half__c,
                            Partner_Account__c,Percent_of_Total_Rev_Net_New_Cust__c,POSaaS__c,Professional_Services__c,Revenue_to_Target__c,
                            SaaS__c,Software__c,Solution_from_Net_New_Customers__c,Subscription_from_Net_New_Customers__c,
                            Total_Revenue__c,Total_Services_Revenue__c,Total_Solution_Revenue__c,Total_Subscription_Revenue__c,TS__c,Year__c,Quota__c,Order_YTD__c,
                            Recurring_SW__c,Recurring_PS__c                                
                            FROM Partner_Revenue__c 
                            WHERE Year__c=: year AND Partner_Account__c=: accountId
                            LIMIT 1];
        Partner_Revenue__c partnerRevenueRecord;
        if(partnerRevenueRecordList.size() > 0)
            partnerRevenueRecord = partnerRevenueRecordList[0];
        return partnerRevenueRecord;
    }
}