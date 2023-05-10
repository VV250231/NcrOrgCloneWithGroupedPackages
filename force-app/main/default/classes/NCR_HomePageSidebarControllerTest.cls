@isTest(SeeAllData=true)
public class NCR_HomePageSidebarControllerTest {
public static testMethod void testNCR_HomePageSidebarController() {
PageReference pageRef = Page.NCR_Homepage;
Test.setCurrentPage(pageRef);
NCR_HomePageSidebarController controller = new NCR_HomePageSidebarController();
controller.getCountIdeasList();
controller.getCountRepliesList();
controller.getThemes();
List<IdeaTheme> IT=controller.getThemes();
System.assert(IT!=null);
}
}