public without sharing class PRM_DoughnutChartCon {
    @AuraEnabled(cacheable=true)
    public static DoughnutChartInfo getDoughnutChartData(String accId){
        
        String accountId = accId;
        Set<String> retailSolutions = new Set<String>();
        Set<String> bankingSolutions = new Set<String>();
        Set<String> hospitalitySolutions = new Set<String>();
        DoughnutChartInfo doughnutChartData = new DoughnutChartInfo();
        Double YTD_Solution_Revenue = 0;
        List<Account> actList;
        actList = [SELECT Id, Name, Partner_Program_Level__c,ChannelProgramName, Retail_Products_Authorized_to_Resell__c,
                   Other_Products_Authorized_to_Resell__c, Financial_Products_Authorized_to_Resell__c, Partner_Industry__c,
                   Partner_Program_Industry__c, Counterpoint__c FROM Account WHERE Id =: accountId LIMIT 1];
        System.debug('***actList'+actList);
        
        if (actList.size()>0) {
            
            system.debug('###'+actList[0].ChannelProgramName);
            List<ChannelProgram>  channelProgList = [SELECT Id, Name FROM ChannelProgram WHERE Name =: actList[0].ChannelProgramName];
            
            system.debug('###'+channelProgList);
            if (channelProgList.size() > 0) {
                Set<String> channelProgramIds = new Set<String>();
                for(ChannelProgram cp: channelProgList) {
                    channelProgramIds.add(cp.Id);
                }
                String currentYear = String.valueOf(Date.today().year());
                System.debug('***currentYear'+currentYear);
                Partner_Revenue__c partnerRevenue = getYearRevenue(accountId,currentYear);
                System.debug('***partnerRevenue'+partnerRevenue);
                if (partnerRevenue != null) {
                    doughnutChartData.YTD_Solution_Revenue = partnerRevenue;
                    YTD_Solution_Revenue = partnerRevenue.Total_Solution_Revenue__c;
                }
                PRM_ChannelProgramUtilityCon1 utilObj = new PRM_ChannelProgramUtilityCon1(channelProgramIds);
                
                String solution;
                if (actList[0].Counterpoint__c) {
                    solution = 'counterpoint';
                }
                system.debug('***'+solution);
                PRM_ChannelProgramUtilityCon1.LevelInformation currentTL = utilObj.getLevelInformation(actList[0].Partner_Program_Level__c,actList[0].Partner_Program_Industry__c,solution);
                System.debug('***currentTL'+currentTL);
                if (currentTL != null) {
                    doughnutChartData.currentLevel = new TierLevel(currentTL.Name,currentTL.thresholdRevenue,currentTL.thresholdRevenue > YTD_Solution_Revenue ? currentTL.thresholdRevenue - YTD_Solution_Revenue:0);
                    System.debug('###'+doughnutChartData.currentLevel);
                }
                
                String nextLevel;
                nextLevel = utilObj.getNextLevel(channelProgList[0].Id,actList[0].Partner_Program_Level__c);
                system.debug('***nextLevel'+nextLevel);
                PRM_ChannelProgramUtilityCon1.LevelInformation nextTL = utilObj.getLevelInformation(nextLevel,actList[0].Partner_Program_Industry__c,solution);
                System.debug('***nextTL'+nextTL);
                if (nextTL != null) {
                    doughnutChartData.nextLevel = new TierLevel(nextTL.Name,nextTL.thresholdRevenue,nextTL.thresholdRevenue > YTD_Solution_Revenue ? nextTL.thresholdRevenue - YTD_Solution_Revenue:0);
                    System.debug('###'+doughnutChartData.nextLevel);
                }
                String nextToNextLevel;
                nextToNextLevel = utilObj.getNextLevel(channelProgList[0].Id,nextLevel);
                system.debug('***nextToNextLevel'+nextToNextLevel);
                PRM_ChannelProgramUtilityCon1.LevelInformation nextToNextTL = utilObj.getLevelInformation(nextToNextLevel,actList[0].Partner_Program_Industry__c,solution);
                System.debug('***nextToNextTL'+nextToNextTL);
                if(nextToNextTL != null) {
                    doughnutChartData.nextToNextLevel = new TierLevel(nextToNextTL.Name,nextToNextTL.thresholdRevenue,nextToNextTL.thresholdRevenue > YTD_Solution_Revenue ? nextToNextTL.thresholdRevenue - YTD_Solution_Revenue : 0);
                    System.debug('###'+doughnutChartData.nextToNextLevel);
                }
            } else {
                return null;
            }
        } else {
            return null;
        }      
        
        return doughnutChartData;
    }
    
    public static Partner_Revenue__c getYearRevenue(String accountId, String currentYear ){
        Partner_Revenue__c partnerRevenue;
        if (accountId != null && currentYear != null) {
            List<Partner_Revenue__c> partnerRevenueList = [SELECT Id, Name, Total_Solution_Revenue__c, Min_total_revenue_for_next_tier__c, Year__c, Revenue_to_Target__c,Partner_Account__c
                                                           FROM Partner_Revenue__c 
                                                           WHERE Year__c =: currentYear  AND Partner_Account__c =: accountId order by createdDate DESC limit 1];
            if (partnerRevenueList.size() > 0) {
                partnerRevenue = partnerRevenueList[0];
            }
        } 
        return partnerRevenue;
    }
    
    
    
    public class DoughnutChartInfo {
        @AuraEnabled       
        public Partner_Revenue__c YTD_Solution_Revenue;
        @AuraEnabled
        public TierLevel currentLevel;
        @AuraEnabled
        public TierLevel nextLevel;
        @AuraEnabled
        public TierLevel nextToNextLevel;
    }
    
    public class TierLevel {
        @AuraEnabled
        public String tierLevelName;
        @AuraEnabled
        public Decimal minRevenue ;
        @AuraEnabled
        public Decimal targetToMinRevenue;
        
        public tierLevel (String tierLevelName) {
            this.tierLevelName = tierLevelName;
        }   
        
        public tierLevel (String tierLevelName, Decimal minRevenue) {
            this.tierLevelName = tierLevelName;
            this.minRevenue = minRevenue;
        }
        
        public tierLevel (String tierLevelName, Decimal minRevenue, Decimal targetToMinRevenue) {
            this.tierLevelName = tierLevelName;
            this.minRevenue = minRevenue;
            this.targetToMinRevenue = targetToMinRevenue;
        }              
    }
}