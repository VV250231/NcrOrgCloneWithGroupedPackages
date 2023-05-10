public with sharing class PRM_YOYchartController {
    @AuraEnabled(cacheable=true)
    public static  List<ChartWrap> getYoyDetails2(String AccId){
        
        List<ChartWrap> chartWrapList = new List<ChartWrap>();
        ChartWrap chartWrapRec;        
        
        Integer currentYear = System.Today().year();
        //This set contains current and previous year
        Set<String> yearSet = new Set<String>();
        yearSet.add(currentYear+'');
        yearSet.add((currentYear-1)+'');
        Map<String,Partner_Revenue__c> yearToPartnerRevMap = new Map<String,Partner_Revenue__c>();
        //Commenting 1st half and 2nd half part due to EBA_SF-2022
        //Fetching the growthRebateHalf from the custom setting
       /* String gRHalf;
        Partner_Dashboard_Configuration__c growthRebateCustSett = [SELECT X1st_Half__c, X2nd_Half__c FROM Partner_Dashboard_Configuration__c LIMIT 1];
        if(growthRebateCustSett != NULL){
            gRHalf = (growthRebateCustSett.X2nd_Half__c == TRUE ? '2nd Half solution revenue' : '1st Half solution revenue');
        }*/
        //System.debug('gRHalf : '+gRHalf);
        List<Partner_Revenue__c> partnerRevenueList;
        if(AccId != NULL){
            partnerRevenueList = [Select Year__c, Total_Solution_Revenue__c /*First_Half__c, Second_Half__c*/
                                  from Partner_Revenue__c where Partner_Account__c =:AccId AND Year__c IN :yearSet ORDER BY Year__c ASC LIMIT 2];
            
            for (Partner_Revenue__c pr : partnerRevenueList) {
                if (pr.Year__c != null) {
                    yearToPartnerRevMap.put(pr.Year__c,pr);
                }
            }
            
            for (integer i = currentYear; i >= currentYear -1; i--) {
                chartWrapRec = new ChartWrap();
                if (yearToPartnerRevMap.containsKey(string.valueOf(i))) {
                    Partner_Revenue__c pr = yearToPartnerRevMap.get(String.valueOf(i));
                    chartWrapRec.year = pr.Year__c;
                    chartWrapRec.color = (Integer.valueOf(pr.Year__c) == System.Today().year() ? 'rgb(84,185,72)' : 'rgb(100,108,100)');
                    chartWrapRec.dataValue = pr.Total_Solution_Revenue__c; 
                    //chartWrapRec.dataValue =(gRHalf != '1st Half solution revenue' ? pr.Second_Half__c : pr.First_Half__c);
                    //chartWrapRec.growthRebateHalf = gRHalf;
                    chartWrapRec.growthRebateHalf = 'YTD';
                    chartWrapList.add(chartWrapRec);
                } else {                    
                    chartWrapRec.year = (string.valueOf(i)) + '';
                    chartWrapRec.color = (Integer.valueOf(chartWrapRec.year) == currentYear ? 'rgb(84,185,72)' : 'rgb(100,108,100)');
                    chartWrapRec.dataValue = 0;
                    chartWrapList.add(chartWrapRec);
                }
            }
        }
        
        return chartWrapList;
    }
    
    public class ChartWrap{
        public ChartWrap(){
             System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement
        }
        @AuraEnabled
        public String year;
        @AuraEnabled
        public String color;
        @AuraEnabled
        public Decimal dataValue;
        @AuraEnabled
        public String growthRebateHalf;
        
        
    }
    //1518
   @AuraEnabled(cacheable=true)
 
    public static Partner_Revenue__c SubsSites(String AccId){
            String currentYear = System.Today().year()+'';
        Partner_Revenue__c [] pr = [Select id,Subscription_Sites__c, Traditional_Sites__c from Partner_Revenue__c where Partner_Account__c =:AccId AND Year__c =:currentYear];
        //Check
        if(!pr.isempty()){
            return pr[0];
        }
        else{
            return null;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
	public static PartnerPieChartInfo GetRevenueDetailsbyTypeData(String accId) {
    Double hw = 0;
    Double sw = 0;
    Double ts = 0;
   // Double saas = 0;
    Double ps = 0;
	Double Rsw=0;
    Double Rps=0;
    String accountId = accId;
    Partner_Revenue__c partnerRevenue;
    String currentYear = String.valueOf(Date.today().year());
    if (accountId != null && currentYear != null) {
        List<Partner_Revenue__c> partnerRevenueList = [SELECT Hardware__c, Software__c, TS__c,Year__c,  Professional_Services__c,
                                                       Recurring_SW__c,Recurring_PS__c
                                                        FROM Partner_Revenue__c 
                                                        WHERE Year__c =: currentYear  AND Partner_Account__c =: accountId/* order by createdDate DESC limit 1*/];
        if (partnerRevenueList.size() > 0) {
            partnerRevenue = partnerRevenueList[0];
        }
    } 

    PartnerPieChartInfo objNewPartnerPieChartInfo =  new PartnerPieChartInfo();
    objNewPartnerPieChartInfo.hw = partnerRevenue.Hardware__c;
    objNewPartnerPieChartInfo.sw = partnerRevenue.Software__c;
    objNewPartnerPieChartInfo.ts = partnerRevenue.TS__c;
    //objNewPartnerPieChartInfo.saas = partnerRevenue.SaaS__c;
    objNewPartnerPieChartInfo.ps = partnerRevenue.Professional_Services__c;
    objNewPartnerPieChartInfo.Rsw= partnerRevenue.Recurring_SW__c;
    objNewPartnerPieChartInfo.Rps = partnerRevenue.Recurring_PS__c;
    


    return objNewPartnerPieChartInfo;


}

public class PartnerPieChartInfo {
    @AuraEnabled       
    public double hw;
    @AuraEnabled
    public double sw;
    @AuraEnabled
    public double  ts;
    /*@AuraEnabled
    public double saas;*/
    @AuraEnabled
    public double ps;
    @AuraEnabled
    public double Rsw;
    @AuraEnabled
    public double Rps;
    
}
    
}