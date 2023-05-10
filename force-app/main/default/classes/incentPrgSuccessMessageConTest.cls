@isTest
public class incentPrgSuccessMessageConTest {
    public static testMethod void testMessage() {
        PageReference pageRef = Page.incentive_program_success_message;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('Referer', 'Incentivetest');
        ApexPages.CurrentPage().GetParameters().put('message', 'test');
        incentPrgSuccessMessageCon con = new incentPrgSuccessMessageCon();
        System.assert(con!=null);
    }
}