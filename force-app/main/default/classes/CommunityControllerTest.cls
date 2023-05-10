@isTest
public class CommunityControllerTest {
public static testMethod void CommunityController() {

CommunitiesLandingController std = new CommunitiesLandingController();
    PageReference pgObj = std.forwardToStartPage();
    System.assert(pgObj==null);
   }
}