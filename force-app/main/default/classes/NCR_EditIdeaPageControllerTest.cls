@isTest(SeeAllData=true)
public class NCR_EditIdeaPageControllerTest {
public static testMethod void testNCR_EditIdeaPageController() {
Idea idea1 = new Idea();
idea1=[select id from idea limit 1];
PageReference pageRef = Page.NCR_EditIdeaPage;
Test.setCurrentPage(pageRef);
ApexPages.currentPage().getParameters().put('id', idea1.id);



ApexPages.StandardController stdIdea = new ApexPages.StandardController(idea1);
NCR_EditIdeaPageController controller = new NCR_EditIdeaPageController(stdIdea);

controller.searchTitle();
pageReference prObj = controller.updateNewIdea();
    System.assert(prObj!=null);
}
}