@isTest
public class BPMCommunityUserCreationHandlerTest {
    @isTest
    public static void unitTest(){
        Account acc = TestRecordsFactory.createAccount();
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.LastName='Test';
        con.FirstName='Test';
        con.Email='tt100100@ncr.com';
        con.AccountId=acc.Id;
        con.Quicklook_ID__c='tt100100';
        con.IsBPMCommunityUser__c=true;
        conList.add(con);
        insert conList;
        System.assert(con.Id!=null);
    }
}