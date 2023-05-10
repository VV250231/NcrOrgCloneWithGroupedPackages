public class PRM_PopulateTAMCmpController 
{
    @AuraEnabled
    public static TAMDetails getTAMvalues(String recId) 
    {
        Partner_Opportunity__c objPO = [ Select Id, Partner_Account__c, TAM__c from Partner_Opportunity__c where Id=:recId];
        List<String> lstTeamMemberName = new List<String>{'--None--'};
        if(String.isBlank(objPO.TAM__c))
        {
            List<AccountTeamMember> lstAccountTeamMember = [Select User.Name, UserId, Title, TeamMemberRole, SystemModstamp, PhotoUrl, OpportunityAccessLevel, Id, 
                                                            ContactAccessLevel, CaseAccessLevel, AccountId, AccountAccessLevel From AccountTeamMember where AccountId =: objPO.Partner_Account__c];
            
            
           
            
            for(AccountTeamMember objAccountTeamMember : lstAccountTeamMember)
            {
                lstTeamMemberName.add(objAccountTeamMember.User.Name);
            }
        }
        
        TAMDetails objTAMDetails = new TAMDetails();
        objTAMDetails.lstTAMName = lstTeamMemberName;
        System.debug('----------objPO.TAM__c------'+objPO.TAM__c);
        objTAMDetails.isPopulated = String.isBlank(objPO.TAM__c);
        
        return objTAMDetails;
        
    }
    
    @AuraEnabled
    public static void updatePartnerOpp(String recId, String selectedTAM) 
    {
        Partner_Opportunity__c objPO = [ Select Id, Partner_Account__c, TAM__c from Partner_Opportunity__c where Id=:recId];
        List<AccountTeamMember> lstAccountTeamMember = [Select User.Name, UserId, Title, TeamMemberRole, SystemModstamp, PhotoUrl, OpportunityAccessLevel, Id, 
                                                            ContactAccessLevel, CaseAccessLevel, AccountId, AccountAccessLevel 
                                                            From AccountTeamMember where AccountId =: objPO.Partner_Account__c and User.Name =: selectedTAM];
           
        if(!lstAccountTeamMember.isEmpty())
        {
           
            System.debug('=============lstAccountTeamMember[0]======='+lstAccountTeamMember[0]);
            objPO.TAM__c =  lstAccountTeamMember[0].UserId;
            
            System.debug('=============UserId======='+objPO.TAM__c);
             System.debug('=============User record======='+[Select Id, Name from User where Id=:objPO.TAM__c]);
            
            update objPO;
        }
    }
    
    public class TAMDetails
    {
        @AuraEnabled
        public List<String> lstTAMName;
        
        @AuraEnabled
        public Boolean isPopulated;
    }
}