@isTest
public class PRM_PopulateTAMCmpControllerTest {

    static testmethod void testPopulateTAMCmpController()
    {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        system.runas(TestRecordsFactory.getUser())
        {
            insert accounts; 
        }
        //insert accounts;
        
        String teamMemberRole = 'Account Manager';
        String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';
        
        List<AccountTeamMember> members = new list<AccountTeamMember>();
        
        
        members.add(New AccountTeamMember(AccountId = accounts[0].id, TeamMemberRole = teamMemberRole, UserId= UserInfo.getUserId()));
        
        
        insert members;
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = acC.Id);
        insert con;
        
        Partner_Opportunity__c obj = new Partner_Opportunity__c();
        obj.Partner_Account__c = accounts[0].id;
        insert obj;
        
        PRM_PopulateTAMCmpController.getTAMvalues(obj.Id);
        PRM_PopulateTAMCmpController.updatePartnerOpp(obj.Id, UserInfo.getName());
        
    }
}