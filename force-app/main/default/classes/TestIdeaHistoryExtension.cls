@isTest
public class TestIdeaHistoryExtension {
    static testmethod void testIdeaHistoryExtention() {
        Id CommunityId = [select id from community where name=: 'IdeaExchange' limit 1].id;
        Idea Idea = new Idea();
        IdeaComment IdeaComment = new IdeaComment();
        Di_Idea_History__c ih= new Di_Idea_History__c ();
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
            Idea.Di_Idea_Product_Manager_Name__c='Lindsey Speranza';
            insert Idea;
        }
        ih.Di_Idea_OLD_Product_Manager_Name__c='Lindsey';
        ih.Di_Idea_Id__c=[select id from idea where Title=: 'Test' limit 1].id;
        insert ih;
        IdeaComment.CommentBody = 'Idea' ;
        IdeaComment.IdeaId = Idea.Id ;
        insert IdeaComment ;
        Idea idea1=[select id from idea  limit 1];
        PageReference pageRef = Page.NCR_EditIdeaPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', idea1.id);

        ApexPages.StandardController stdIdea = new ApexPages.StandardController(idea1);
        
        IdeaHistoryExtension controller = new IdeaHistoryExtension(stdIdea);
        controller.getIdeaHistoryList();
        controller.back();
        System.assert(controller.back()!=null);
            
       
      }
}