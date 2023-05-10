public with sharing class OpenDispatchesHierarchyHandler {

    @AuraEnabled(cacheable =true)
    public static List<DispatchRegionWrapper> getDispatch (String accountID) {        
           /*List<APL_Account_Open_Dispatches__c> getDispatches = new List<APL_Account_Open_Dispatches__c>();
           getDispatches = [SELECT Id, Name, customer_number__c, country_code__c, priority_code__c, SLA_Category__c, source_nbr_country_cd__c, CurrentDateTime_DST__c, Unique_ID__c, resp_date_time_expected_gmt__c FROM APL_Account_Open_Dispatches__c where Account_Master_Lookup__c =: accountID ORDER BY priority_code__c ASC NULLS LAST];*/     
           Set<Id> allAccountIds = findChildAccountIds(new Set<Id>{accountID});
          
           List<DispatchRegionWrapper> dispatchRegionWrapList = new List<DispatchRegionWrapper>();

            List<Account> accist = [SELECT Id, RecordType.Name,Region__c FROM ACCOUNT WHERE Id = :accountID LIMIT 1];
            
            if(!accist.isEmpty()) {
                String accRecordType = accist.get(0).RecordType.Name;
              
                if(accRecordType.equalsIgnoreCase(System.Label.RT_Acc_Enterprise)) {
                                                            
                    Map<String, DispatchRegionWrapper> regionDispatchMap = new Map<String, DispatchRegionWrapper>();
                    List<AggregateResult> aggResult = [Select count(Id) recordcount,Account_Master_Lookup__r.Region__c Region,Priority_code__c , SLA_Category__c 
                                                       from APL_Account_Open_Dispatches__c where Account_Master_Lookup__c 
                                                       IN :allAccountIds 
                                                       group by SLA_Category__c, priority_code__c,Account_Master_Lookup__r.Region__c  
                                                       ORDER BY priority_code__c ASC ];    
                    System.debug('$$$$$$' + aggResult);
                    for (AggregateResult agg: aggResult) {
                        String region = (String)agg.get('Region');
                        system.debug('region: '+region);
                        DispatchRegionWrapper tempRegionWrapper = regionDispatchMap.get(region);                
                        if (tempRegionWrapper == null) {
                            tempRegionWrapper = new DispatchRegionWrapper(Region, true, (String)agg.get('Priority_code__c'), (String)agg.get('SLA_Category__c'), (Integer)agg.get('recordcount'));    
                            regionDispatchMap.put(Region, tempRegionWrapper);
                        } else {
                            tempRegionWrapper.updateDispatchList((String)agg.get('Priority_code__c'), (String)agg.get('SLA_Category__c'), (Integer)agg.get('recordcount'));    
                        }
                    }

                    dispatchRegionWrapList = regionDispatchMap.values();
                } else {
                    Map<String, DispatchWrapper> prioritySLACatMap = new Map<String, DispatchWrapper>();
                    

                    List<AggregateResult> aggResult = [Select count(Id) recordcount, Priority_code__c , SLA_Category__c from APL_Account_Open_Dispatches__c where Account_Master_Lookup__c IN :allAccountIds  group by SLA_Category__c, priority_code__c  ORDER BY priority_code__c ASC ];     
                    
                    for (AggregateResult agg: aggResult) {
                        String priority = (String)agg.get('Priority_code__c'); 
                        DispatchWrapper tempDptchWrap = prioritySLACatMap.get(priority);
                        
                        if(tempDptchWrap == NULL) {
                            tempDptchWrap = new DispatchWrapper(priority);
                            prioritySLACatMap.put(priority, tempDptchWrap);
                        }
                        tempDptchWrap.updateDispatchSLACount((String)agg.get('SLA_Category__c'), (Integer)agg.get('recordcount'));
                    }
                    
                    DispatchRegionWrapper  drw = new DispatchRegionWrapper();
                    drw.Region = '';
                    drw.isSummaryView = false;
                    drw.dispatchList = prioritySLACatMap.values();
                    dispatchRegionWrapList = new List<DispatchRegionWrapper>{drw};
                }
            } 

           return dispatchRegionWrapList;
            //return  prioritySLACatMap.values();
    } 

    public static Set<Id> findChildAccountIds(Set<Id> parentAccIds) {
        Set<Id> outputAccIds = new Set<Id>();
        outputAccIds.addAll(parentAccIds);

        Map<Id, Account> accountMap = new  Map<Id, Account>([SELECT Id, Name, ParentId FROM Account where ParentId IN :parentAccIds]);

        if(!accountMap.isEmpty()) {
            Set<Id> childAcctIds = findChildAccountIds(accountMap.keySet());

            if (childAcctIds != null && !childAcctIds.isEmpty()) {
                outputAccIds.addAll(childAcctIds);
            }
        }
        return outputAccIds;
    }

    
    public class DispatchWrapper {
        @AuraEnabled
        public String Priority{get;set;}        
        @AuraEnabled
        public Integer MeetSLACount{get;set;}        
        @AuraEnabled
        public Integer OutsideSLACount{get;set;}
        
        public DispatchWrapper() {}
        
        public DispatchWrapper(String Priority) {
            this.Priority = Priority;
            this.MeetSLACount  = 0;
            this.OutsideSLACount = 0;
        }
        
        public void updateDispatchSLACount(String SLA_Category, Integer RecordCount) {
            if (SLA_Category == 'Open Call Within SLA') {
                this.MeetSLACount = RecordCount;
                
            } else if (SLA_Category == 'Open Call Outside SLA' ) {
                this.OutsideSLACount = RecordCount;
              
            }
        }
    }

    public class DispatchRegionWrapper {
        @AuraEnabled
        public String Region{get;set;}     
        @AuraEnabled
        public Boolean isSummaryView{get;set;}  
        @AuraEnabled
        public List<DispatchWrapper> dispatchList{get;set;}

        Map<String, DispatchWrapper>  priorityMap;

        public DispatchRegionWrapper() {}

        public DispatchRegionWrapper(String Region,Boolean isSummaryView, String Priority, String SLA_Category, Integer RecordCount) {
            this.Region = Region;
            this.isSummaryView = isSummaryView;
            this.dispatchList = new List<DispatchWrapper>();
            this.priorityMap = new Map<String, DispatchWrapper>();

            DispatchWrapper dw = new DispatchWrapper(Priority);
            dw.updateDispatchSLACount(SLA_Category, RecordCount);
            this.dispatchList.add(dw);
            this.priorityMap.put(Priority, dw);
        } 

        public void updateDispatchList(String Priority, String SLA_Category, Integer RecordCount) {
            DispatchWrapper dw  = this.priorityMap.get(Priority);
            if(dw == null) {
                dw = new DispatchWrapper(Priority);
                this.dispatchList.add(dw);
                this.priorityMap.put(Priority, dw);
            }
            dw.updateDispatchSLACount(SLA_Category, RecordCount);
        }

    }
    
 }