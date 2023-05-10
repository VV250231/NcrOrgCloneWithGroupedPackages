public with sharing class OpenDispatchesHandler {
    @AuraEnabled//(cacheable =true)
        public static List<DispatchWrapper> getDispatch (String accountID) {        
           /*List<APL_Account_Open_Dispatches__c> getDispatches = new List<APL_Account_Open_Dispatches__c>();
           getDispatches = [SELECT Id, Name, customer_number__c, country_code__c, priority_code__c, SLA_Category__c, source_nbr_country_cd__c, CurrentDateTime_DST__c, Unique_ID__c, resp_date_time_expected_gmt__c FROM APL_Account_Open_Dispatches__c where Account_Master_Lookup__c =: accountID ORDER BY priority_code__c ASC NULLS LAST];*/
            
            //List<DispatchWrapper> disptchLst = new List<DispatchWrapper>();
            Map<String, DispatchWrapper> prtySLACatMap = new Map<String, DispatchWrapper>();
            
            List<AggregateResult> aggResult = [Select count(Id) recordcount, Priority_code__c , SLA_Category__c  from APL_Account_Open_Dispatches__c where Account_Master_Lookup__c =: accountID  group by SLA_Category__c, priority_code__c ORDER BY priority_code__c ASC ];
            
            for (AggregateResult agg: aggResult) {
                String prty = (String)agg.get('Priority_code__c'); 
                DispatchWrapper tempDptchWrap = prtySLACatMap.get(prty);
                
                if(tempDptchWrap == NULL) {
                    tempDptchWrap = new DispatchWrapper(prty);
                    prtySLACatMap.put(prty, tempDptchWrap);
                }
                tempDptchWrap.updateDispatchSLACount((String)agg.get('SLA_Category__c'), (Integer)agg.get('recordcount'));
            }
            return prtySLACatMap.values();
    } 
    
    public class DispatchWrapper {
        @AuraEnabled
        public String Priority{get;set;}        
        @AuraEnabled
        public Integer MeetSLACount{get;set;}        
        @AuraEnabled
        public Integer OutsideSLACount{get;set;}
        
        /*public DispatchWrapper() {} commented empty statement block */
        
        public DispatchWrapper(String Priority) {
            this.Priority = Priority;
            this.MeetSLACount  = 0;
            this.OutsideSLACount = 0;
        }
        
        public void updateDispatchSLACount(String SLA_Category, Integer recCount) {
            if (SLA_Category == 'Open Call Within SLA') {
                this.MeetSLACount = recCount;
                
            } else if (SLA_Category == 'Open Call Outside SLA' ) {
                this.OutsideSLACount = recCount;
              
            }
        }
    }
    
 }