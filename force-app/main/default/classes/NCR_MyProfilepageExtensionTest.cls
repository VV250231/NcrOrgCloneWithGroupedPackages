@isTest(SeeAllData=true)
public class NCR_MyProfilepageExtensionTest {
public static testMethod void testNCR_MyProfilepageExtension(){
PageReference pageRef = Page.NCR_MyProfilepage;
Test.setCurrentPage(pageRef);
Id CommunityId = [select id from community where name=: 'IdeaExchange' limit 1].id;
Idea Idea = new Idea();
IdeaComment IdeaComment = new IdeaComment();
Profile pr = new Profile();
pr=[select id from profile where name='System Administrator'];
User testUser = new User(FirstName='test', LastName='User',email='ncrtestuser@ncr.com',Alias='testuser',username='ncrtestuser@ncr.com',profileid=pr.id, LocaleSidKey='en_US',LanguageLocaleKey='en_US',EmailEncodingKey='UTF-8',TimezoneSidKey='America/New_York',CurrencyIsoCode='USD',Quicklook_ID__c='xx000000');
System.runAs(testUser)
{
Idea.Title = 'test';
Idea.Body = 'test';
Idea.CommunityId = CommunityId;
Idea.Di_Idea_Channel__c = 'Online';
Idea.Di_Idea_Category__c = 'External Funds Transfer';
Idea.Di_Idea_Line_of_Business__c = 'Money Movement';
insert Idea;    
    
IdeaComment.CommentBody = 'Idea' ;
IdeaComment.IdeaId = Idea.Id ;
insert IdeaComment ;

ApexPages.StandardController stdUser = new ApexPages.StandardController(testUser);
NCR_MyProfilepageExtension controller = new NCR_MyProfilepageExtension(stdUser);
/* controller.getProfileMyIdeas(); */
controller.getMyComments();
controller.getProfileComments();
controller.populateDataMyIdeas();
controller.insertToMyFavoritesMyIdeas();
controller.insertToMyFavoritesComment();
controller.deleteToMyFavoritesMyIdeas();
controller.gotoSetLOBAllIdeas();
    List<IdeaComment> iCmt=controller.getMyComments();
            System.assert(iCmt!=null);
}


}
}