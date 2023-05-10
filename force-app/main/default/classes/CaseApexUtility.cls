public class CaseApexUtility {
    @InvocableMethod
        public static void assignCases(List<Id> CaseIds){
            AssignmentRule ARule = new AssignmentRule();
            ARule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= ARule.id;
            Case CasesToAssign = [select id, ownerId, AccountId, Region__c, RecordType.Name from Case where case.id In :caseIds];
            System.debug('before$$$$$' + CasesToAssign );
            System.debug('beforeAcc$$$$$' + CasesToAssign.AccountId);
                CasesToAssign.setOptions(dmlOpts);
            update CasesToAssign;
            
            CasesToAssign = [select id, ownerId, AccountId, Region__c, RecordType.Name from Case where case.id In :caseIds];
            System.debug('after$$$$$$$$$$' + CasesToAssign );
               System.debug('afetrAcc$$$$$' + CasesToAssign.AccountId);
                
                }
}