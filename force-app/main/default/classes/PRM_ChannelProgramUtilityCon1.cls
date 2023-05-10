public Class PRM_ChannelProgramUtilityCon1 { 

    public Map<Id,Map<String,ChannelProgramLevel>> channelProgramLabelMap = new Map<Id,Map<String,ChannelProgramLevel>>();
    public Map<Id,Map<Integer,ChannelProgramLevel>> channelProgramRankMap = new Map<Id,Map<Integer,ChannelProgramLevel>>();
    public Map<String,Channel_Level_Revenue_Information__c> keyToChannelLevelRevInfo = new Map<String,Channel_Level_Revenue_Information__c>();


    public PRM_ChannelProgramUtilityCon1(Set<String> channelProgramIds) {
        List<ChannelProgram> channelProgramList = [SELECT Id, Name, Category, IsActive,(SELECT Id, ProgramId, Name, Rank FROM ChannelProgramLevels ORDER BY Rank ASC) FROM ChannelProgram WHERE Id IN : channelProgramIds];
        
        for (ChannelProgram cp : channelProgramList) {
            if (! channelProgramLabelMap.containsKey(cp.Id)) {
                channelProgramLabelMap.put(cp.Id, new Map<String,ChannelProgramLevel>());
            }
            
            if (! channelProgramRankMap.containsKey(cp.Id)) {
                channelProgramRankMap.put(cp.Id, new Map<Integer,ChannelProgramLevel>());
            }
            
            for (ChannelProgramLevel cpl : cp.ChannelProgramLevels) {
                channelProgramLabelMap.get(cp.Id).put(cpl.Name, cpl);
                channelProgramRankMap.get(cp.Id).put(cpl.Rank, cpl);
            }
        }

        for (Channel_Level_Revenue_Information__c levelInfoRec : [SELECT Name,LevelRevenueKey__c, Channel_Program_Level__c,Channel_Program_Level__r.Name, Industry__c, Solution__c, Threshold_Revenue__c, Percent_Revenue_Net_New_Customer__c FROM Channel_Level_Revenue_Information__c ]) {
            keyToChannelLevelRevInfo.put(levelInfoRec.LevelRevenueKey__c,levelInfoRec);
        }
    }


    /* If channel program has next level to passed level in parameters returns it's name else return null.
    */
    public String getNextLevel(String channelProgramId, String channelProgramLevel) {
        String nextLevel;
        if (channelProgramLabelMap.containsKey(channelProgramId)) {
            if (channelProgramLabelMap.get(channelProgramId).containsKey(channelProgramLevel)) {
                Integer rank = channelProgramLabelMap.get(channelProgramId).get(channelProgramLevel).Rank;
                Integer nextRank = rank + 1;
                
                if (channelProgramRankMap.containsKey(channelProgramId)) {
                    if (channelProgramRankMap.get(channelProgramId).containsKey(nextRank)) {
                        nextLevel = channelProgramRankMap.get(channelProgramId).get(nextRank).Name;
                        
                    } else {
                        return null;
                    }
                } else {
                    return null; 
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
        
        return nextLevel;
    }
	/* Fore Futrue Use
    public String getPreviousLevel(String channelProgramId, String channelProgramLevel) {
        String previousLevel;
        if (channelProgramLabelMap.containsKey(channelProgramId)) {
            if (channelProgramLabelMap.get(channelProgramId).containsKey(channelProgramLevel)) {
                Integer rank = channelProgramLabelMap.get(channelProgramId).get(channelProgramLevel).Rank;
                Integer previousRank = rank - 1;
                
                if (channelProgramRankMap.containsKey(channelProgramId)) {
                    if (channelProgramRankMap.get(channelProgramId).containsKey(previousRank)) {
                        previousLevel = channelProgramRankMap.get(channelProgramId).get(previousRank).Name;
                    } else {
                        return null;
                    }
                } else {
                    return null; 
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
        
        return previousLevel;
    }
	*/

    public LevelInformation getLevelInformation(String partnerProgramLevel, String industry, String solution) {
        String key;
        LevelInformation levelInfoObj;
        
        if (!String.isBlank(partnerProgramLevel) && !String.isBlank(industry)) {
            key = partnerProgramLevel + industry;
            
        } else {
            return null;
        }
        
        if(solution != null) {
            key = key + solution;
        }
        
        key = key.toUpperCase();
        System.debug('###key'+key);
        system.debug('###keyset'+keyToChannelLevelRevInfo.keyset());
        
        if (keyToChannelLevelRevInfo.containsKey(key)) {
            Channel_Level_Revenue_Information__c levelInfoRec = keyToChannelLevelRevInfo.get(key);
            levelInfoObj = new LevelInformation();
            levelInfoObj.Name = levelInfoRec.Channel_Program_Level__r.Name;
            levelInfoObj.thresholdRevenue = levelInfoRec.Threshold_Revenue__c;
            levelInfoObj.percentRevenueNetNewCustomer = levelInfoRec.Percent_Revenue_Net_New_Customer__c; 
        } else {
            return null;
        }
        
        return levelInfoObj;
    }



    public class LevelInformation {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public Decimal thresholdRevenue ;
        @AuraEnabled
        public String percentRevenueNetNewCustomer;
        
    }

}