@isTest
public class AccountTeamMemberTriggerTest {
    static testMethod void TestCase()
    {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        system.assert(Usr.Id!=null);
        Account a;
        
        System.runAs(Usr) {
            a = new Account(name='Account-11');
            a.Master_Customer_Number__c = 'Test1234';
            a.Subscription_Group__c ='Digital Insight';
            a.DI_Customer__c = 'DI123';
            
            
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingState = 'test';
            a.BillingPostalCode =  '1234';
            
            insert a;
            
            AccountTeamMember atm=new AccountTeamMember(AccountId = a.Id,TeamMemberRole='Digital Strategy Manager',UserId=Usr.Id);
            insert atm;
            AccountTeamMember atm1=new AccountTeamMember(AccountId = a.Id,TeamMemberRole='Channel Account Manager',UserId=Usr.Id);
            insert atm1;
            
            atm.TeamMemberRole='Digital Strategy Manager';
            Update atm1;
            
            
        Test.startTest();
        Database.DeleteResult result = Database.delete(atm1, false);
        Test.stopTest();
       
        
            
        }         
    }        
}