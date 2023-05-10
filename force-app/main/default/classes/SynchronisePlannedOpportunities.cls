public with sharing class SynchronisePlannedOpportunities {
    
    /*public String[] STAGES_OF_INTEREST = new String[] {
        'Target Qualified' ,
            'Requirements',
            'Evidence', 
            'Acquisition', 
            'Verbal Order',
            'Closed Won'
            };*/
                
    public List<String> getOpptyStages() {
    	List<String> stages = new List<String>();
        
        for(Schema.PicklistEntry ple : Opportunity.StageName.getDescribe().getPicklistValues()) {
            String stageName = ple.getValue();
            
            if(!stageName.containsIgnoreCase('NonFunnel')) {
            	stages.add(stageName);
        	}
        }
        return stages;
    }
    public void createAccountOpportunities(Set<Id> accountIds, Date startDate, Date endDate, Set<Id> onlyInclude) {
        
        Id defaultSolutionId = getDefaultSolutionId();
        List<String> STAGES_OF_INTEREST = getOpptyStages();
        System.debug('Oppty stages');
        System.debug(STAGES_OF_INTEREST);
        System.debug(onlyInclude);
        System.debug(accountIds);
        
        if (defaultSolutionId != null) {
            String query = 
                'select id, accountid ' +
                'from opportunity ' + 
                'where ' + 
                'accountid in :accountids ' + 
                (onlyInclude != null && onlyInclude.size() > 0 ? 'and id in :onlyInclude ' : ' ') +
                'and stagename in :STAGES_OF_INTEREST ' + 
                'and id not in (select altf__opportunity__c from altf__account_opportunity__c where altf__account__c in :accountIds) ' +
                getDateRangeFilter(startDate, endDate)
                ;
            
            
            System.debug(query);
            
            List<Opportunity> opps = Database.query(String.escapeSingleQuotes(query));
            
            List<ALTF__Account_Opportunity__c> accOpps = new List<ALTF__Account_Opportunity__c>();
            
            for (Opportunity opp : opps) {
                if (opp.accountid != null) {
                    accOpps.add(new ALTF__Account_Opportunity__c(
                        ALTF__Account__c = opp.accountid,  
                        ALTF__Opportunity__c = opp.id,
                        ALTF__Solution__c = defaultSolutionId
                    ));
                }
            }
            
            insert accOpps;            
        }
    }
    
    
    private Id getDefaultSolutionId() {
        List<ALTF__Solution__c> sols = [select id from ALTF__Solution__c where Name = 'Products Unassigned'];
        
        if (sols != null && sols.size() == 1) {
            return sols.get(0).id;
        }
        
        return null;
    }
    
    
    private String getDateRangeFilter(Date startDate, Date endDate) {
        String dateRange = '';
        
        if (startDate != null || endDate != null) {
            dateRange = 'and (';
            
            if (startDate != null) {
                dateRange = dateRange + ' CloseDate > :startDate ' + (endDate != null ? ' and ' : '') ;                
            }
            
            if (endDate != null) {
                dateRange = dateRange + ' CloseDate < :endDate ';                
            }
            
            dateRange = dateRange + ') ';
        }
        
        String openFilter = '(IsClosed = False ' + dateRange + ') ';
        String wonFilter = dateRange != '' ? '(IsClosed = True and IsWon = True ' + dateRange + ')' : '';
        
        return 'and (' + openFilter + (wonFilter != '' ? 'OR ' + wonFilter : '') + ')';
    }
}