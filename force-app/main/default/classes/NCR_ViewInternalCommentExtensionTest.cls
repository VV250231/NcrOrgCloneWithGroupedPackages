@isTest(SeeAllData=true)
public class NCR_ViewInternalCommentExtensionTest {
    public static testMethod void testNCR_ViewInternalCommentExtension(){
        Idea idea1 = new Idea();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        Idea i = new Idea();
        i.title='test';
        i.body='test';
        i.communityid=community.id;
        insert i;
        idea1 =   [select id, createdbyid from idea where id=: i.id];
        
        PageReference pageRef = Page.NCR_ViewInternalComment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', idea1.id);
        
        ApexPages.StandardController stdIdea = new ApexPages.StandardController(idea1);
        NCR_ViewInternalCommentExtension controller = new NCR_ViewInternalCommentExtension(stdIdea);
        controller.getidea2();
        controller.getcomments();
        
        Di_Idea_Internal_Comments__c comment = new Di_Idea_Internal_Comments__c();
        comment.Di_Idea_IdeaId__c = idea1.id;
        comment.Di_Idea_CommentBody__c = 'hi';
        insert comment;
        
        controller.getcomments();
        controller.newCommentValue='';
        controller.insertComment();
        controller.newCommentValue='test';
        controller.insertComment();
        Di_Idea_Internal_Comments__c newIdeaComment = [select id from Di_Idea_Internal_Comments__c where Di_Idea_IdeaId__c =:idea1.id limit 1];
        System.assert(newIdeaComment.id!=null);
        controller.ideaDetail();
    }
}