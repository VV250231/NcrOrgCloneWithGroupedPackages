public with sharing class OpenHelpDeskHierarchy {

    @AuraEnabled(cacheable =true)
    public static List<HelpDeskWrapper> getHelpDeskCases(String accountID) {  
        Set<Id> allAccountIds = findChildAccountIds(new Set<Id>{accountID});
        
        List<HelpDeskWrapper> hdWrapList = new List<HelpDeskWrapper>();
        List<Open_Help_Desk_Case__c> getHelpDesk = new List<Open_Help_Desk_Case__c>();
        
        
        List<Account> accist = [SELECT Id, RecordType.Name FROM ACCOUNT WHERE Id = :accountID LIMIT 1];
        getHelpDesk = [SELECT Id, Name, OwnerId, priority_code__c, Account_Master_Lookup__r.Region__c, more_then_24_hours__c, less_then_24_hours__c, gems_customer_name__c, customer_nbr__c, Unique_ID__c,Account_Master_Lookup__c, Account_Master_Lookup__r.RecordType.Name FROM Open_Help_Desk_Case__c where Account_Master_Lookup__c IN :allAccountIds ORDER BY priority_code__c ASC ];
        
        if(!accist.isEmpty()) {
            String accRecordType = accist.get(0).RecordType.Name;
            
            if(accRecordType.equalsIgnoreCase(System.Label.RT_Acc_Enterprise)) {
                hdWrapList = processsHelpDeskByRegion(getHelpDesk); 
            } else {
                hdWrapList = processsHelpDeskByPriority(getHelpDesk);    
            }
        } 
        return hdWrapList;
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

    public static List<HelpDeskWrapper> processsHelpDeskByPriority(List<Open_Help_Desk_Case__c> helpDeskCases) {
        List<HelpDeskWrapper> hdWrapList = new List<HelpDeskWrapper>();
        Set <Decimal> priority=new Set<Decimal>(); 
        List<Open_Help_Desk_Case__c> oh = new List<Open_Help_Desk_Case__c>();
        
        for (Open_Help_Desk_Case__c gh: helpDeskCases) {
            if(priority.contains(gh.priority_code__c))  {
                for(Open_Help_Desk_Case__c ohh:oh){
                    if(ohh.priority_code__c==gh.priority_code__c) {
                        ohh.more_then_24_hours__c=ohh.more_then_24_hours__c+gh.more_then_24_hours__c;
                        ohh.less_then_24_hours__c=ohh.less_then_24_hours__c+gh.less_then_24_hours__c;
                    }
                }  
            } else {
                oh.add(gh);
                priority.add(gh.priority_code__c);
            }         
        }

        if (!oh.isEmpty()) {
            HelpDeskWrapper hdWrap = new HelpDeskWrapper();  
            hdWrap.Region = '';
            hdWrap.isSummaryView = false;
            hdWrap.HelpDeskCasesList = oh;
            hdWrapList.add(hdWrap);
        }
        return hdWrapList;
    } 
    
    public static List<HelpDeskWrapper> processsHelpDeskByRegion(List<Open_Help_Desk_Case__c> helpDeskCases) {
        Map<String, HelpDeskWrapper> regionAndHelpDeskMap = new Map<String, HelpDeskWrapper>();
        
        for(Open_Help_Desk_Case__c gh: helpDeskCases) {
            HelpDeskWrapper helpDeskWrap = regionAndHelpDeskMap.get(gh.Account_Master_Lookup__r.Region__c);
            
            if(helpDeskWrap != NULL) {
                helpDeskWrap.updateHelpDeskList(gh);        
            } else {
                regionAndHelpDeskMap.put(gh.Account_Master_Lookup__r.Region__c, new HelpDeskWrapper(gh.Account_Master_Lookup__r.Region__c,true, gh));
            }
        } 
        return regionAndHelpDeskMap.values();
    }
    
    public class HelpDeskWrapper {       
        @AuraEnabled
        public String Region;
        @AuraEnabled
        public Boolean isSummaryView;
        @AuraEnabled
        public List<Open_Help_Desk_Case__c> HelpDeskCasesList;
        
        public HelpDeskWrapper() {
            System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
        }
        
        public HelpDeskWrapper(String Region, Boolean isSummaryView, Open_Help_Desk_Case__c oh) {
            this.Region = Region;
            this.isSummaryView = isSummaryView;
            this.HelpDeskCasesList = new List<Open_Help_Desk_Case__c>{oh};
        }
        
        public void updateHelpDeskList(Open_Help_Desk_Case__c oh) {
            Boolean match = false;
            
            if(HelpDeskCasesList != null) {
                for(Open_Help_Desk_Case__c c : HelpDeskCasesList) {
                    if (c.priority_code__c == oh.priority_code__c) {
                        match = true;
                        c.more_then_24_hours__c = c.more_then_24_hours__c+ oh.more_then_24_hours__c;
                        c.less_then_24_hours__c = c.less_then_24_hours__c+ oh.less_then_24_hours__c; 
                        break;
                    }    
                } 
            }
            
            if(!match) {
                this.HelpDeskCasesList.add(oh);     
            }
        }
    }
}