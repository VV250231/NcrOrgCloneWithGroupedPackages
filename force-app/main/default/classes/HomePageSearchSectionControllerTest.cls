@isTest(SeeAllData=true)
public class HomePageSearchSectionControllerTest {
    public static testMethod void testHomePageSearchSectionController() {
        
        Idea idea = new Idea();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        idea.title='test';
        idea.body='test';
        idea.communityid=community.id;
        insert idea;
        
        
        HomePageSearchSectionController controller = new HomePageSearchSectionController();
        controller.SearchItem = 'test';
        List<Idea> IdeaList = new List<Idea>();
        IdeaList = [Select Title, Body, CreatedBy.SmallPhotoURL, id, CreatedBy.Name, CreatedDate, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c, VoteTotal, CreatedById, Status from Idea];
        controller.SearchIdeas = IdeaList;
        System.assert(controller.doSearch()!=null);
        controller.PostNewIdea();
        controller.loadPaginationSearchResult();
        controller.getSearchedIdeasList();
        controller.populateDataSearchResult();
        controller.insertToMyFavoritesSearchResult();
        controller.SearchResultIdeaId = idea.id;
        controller.deleteFavoritesSearchResult();
        /*controller.nextPageSearchResult();
        controller.updatePageSearchResult();
        controller.changeDataSearchResult();
        controller.getsampleideas();*/
    }
}