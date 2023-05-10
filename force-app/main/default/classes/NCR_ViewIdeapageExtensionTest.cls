@isTest(seeAllData=true)
public class NCR_ViewIdeapageExtensionTest {
    public static testMethod void testNCR_ViewIdeapageExtension(){
        PageReference pageRef = Page.NCR_ViewIdeapage;
        Test.setCurrentPage(pageRef);
        Idea idea = new Idea();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        Idea i = new Idea();
        i.title='test';
        i.body='test';
        i.communityid=community.id;
        insert i;
        idea=[select id, createdbyid from idea where id=: i.id];
        id userid=[select id from user limit 1].id;
       // IdeaComment ideaCommentObj = new IdeaComment(IdeaId=idea.id,Commentbody='Testing comment');
       // insert ideaCommentObj;
        IdeaComment ideaCommentObj1 = new IdeaComment(IdeaId=idea.id,Commentbody='Testing comment');
        System.runAs(TestRecordsFactory.getUser()){
                   insert ideaCommentObj1;
        }
        ApexPages.currentPage().getParameters().put('id', idea.id);
        ApexPages.currentPage().getParameters().put('pge', 'NCR_Activitypage');
        ApexPages.currentPage().getParameters().put('SelectTab', 'Recent');
        ApexPages.currentPage().getParameters().put('gb', 'NCR_Homepage');
        ApexPages.currentPage().getParameters().put('mb', 'Recent');
        ApexPages.currentPage().getParameters().put('gl', 'NCR_Homepage');
        ApexPages.currentPage().getParameters().put('ml', 'Popular');
        ApexPages.currentPage().getParameters().put('rtid', userid);
        ApexPages.currentPage().getParameters().put('cat', 'ACH and Wires');
        ApexPages.currentPage().getParameters().put('pNum', '2');
        ApexPages.currentPage().getParameters().put('searchItemVal', 'ACH');
        
        
        
        
        ApexPages.StandardController stdIdea = new ApexPages.StandardController(new Idea(Title='test',body='test',currencyisocode='USD',Di_Idea_Category__c = 'Authentication & Settings'));
        NCR_ViewIdeapageExtension controller = new NCR_ViewIdeapageExtension(stdIdea);
        controller.newCommentValue='test';
        controller.getmyVotesList();
        controller.voteUp();
        controller.insertToMyFavorites();
        controller.getMyFavoriteIdea();
        controller.deleteToMyFavorites();
        controller.insertComment();
        controller.enableEditIdea();
        controller.enableSaveIdea();
        controller.enableDeleteIdea();
        controller.gotoViewAll();
        controller.getStatusValues();
        controller.newIdeaComment = ideaCommentObj1;
        PageReference pageRefenceObj = controller.saveAttachment();
        System.assert(pageRefenceObj!=null);
        controller.disableFavorite=true;
        controller.favoriteValue='Test';
        controller.iUser=true;
        controller.childIdeaSize=1;
        controller.newIdea=i;
        
    }
}