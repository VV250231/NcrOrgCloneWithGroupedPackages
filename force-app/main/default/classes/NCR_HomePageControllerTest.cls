@isTest(SeeAllData=true)
public class NCR_HomePageControllerTest {
public static testMethod void testNCR_HomePageController() {
PageReference pageRef = Page.NCR_Homepage;
Test.setCurrentPage(pageRef);
NCR_HomePageController controller = new NCR_HomePageController();
Idea a=[select id, Status,Title,CreatedDate from idea limit 1];
NCR_HomePageController.recentIdeasWrapper recentIdeasWrapperobj=new NCR_HomePageController.recentIdeasWrapper(a.id, 'abc', 'bodyRecent', 'fImageRecent',a.Id, 'createdByNameRecent', Datetime.now(), 'lobRecent', 'categoryRecent', true, 2.0, 'statRecent','createdByProfileIdRecent','createdByTitleRecent','createdByDiFiNameRecent', 'diIdeaChannelRecent');
controller.getFeaturedIdeas();
controller.getRecentIdeas();
controller.getPopularIdeas();
controller.getViewAllRecent();
controller.getViewAllPopular();
controller.populateRecentWrapper();
controller.populatePopularWrapper();
controller.insertToMyFavorites();
controller.insertToMyFavoritesPopular();
List<Idea> i=controller.getFeaturedIdeas();
System.assert(i!=null);
}
}