@isTest
public class caseToLeadConversionTest {
    @isTest
    private static void testContactEmail(){
        Contact con = new Contact(LastName='Test',Email='test@test.com');
        insert con;
          System.assertNotEquals(con.id, null,'Contact not found'); 
        caseToLeadConversion.searchExistingLead(con.Email);
        caseToLeadConversion.searchExistingContact(con.Email);
    }
}