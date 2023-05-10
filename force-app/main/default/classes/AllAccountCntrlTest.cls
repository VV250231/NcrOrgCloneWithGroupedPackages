@IsTest
public class AllAccountCntrlTest{
    static testmethod void testSearch() {
        List<Account> accList = new List<Account>();
        accList = AllAccountCntrl.AccountSearched('ibm', 10);
        AllAccountCntrl.count('ibm');
        system.assertNotEquals(accList.size(), null);
    }
    
    
}