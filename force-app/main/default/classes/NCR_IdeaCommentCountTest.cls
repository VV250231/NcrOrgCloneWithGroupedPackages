@isTest(seealldata=true)
public class NCR_IdeaCommentCountTest{

    static testmethod void test() {
        Id communityid;
        user u;
        try{
        communityid = [select id from Community where Name='IdeaExchange' limit 1].id;
        u = [select id from user where name='Ian Abramsky'limit 1];
        }
        catch(exception e){
            System.debug('Error: '+e.getMessage());
        }
        
        Idea i = new Idea();
        ideacomment ic=new ideacomment();
        
        system.runas(u){        
        
        i.title='test';
        i.body='test';
        i.communityid=communityid;
        i.Di_Idea_Product_Manager_Name__c='Lindsey Speranza';
        i.counter__c=2;
        insert i;
       
        
        ic.CommentBody='Test';
        ic.ideaid=i.id;
        insert ic;
        }
        
        
        idea idea=[select id,counter__c,Di_Idea_Product_Manager_Name__c from idea where id=:i.id limit 1];
                        
        Test.startTest();
        system.assertequals(idea.counter__c,2);
        Test.stopTest();
        
        
        delete ic;
        
      
   }
}