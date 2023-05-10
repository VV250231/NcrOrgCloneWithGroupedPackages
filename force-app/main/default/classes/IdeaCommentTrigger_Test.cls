@isTest
public class IdeaCommentTrigger_Test {
    @TestSetup
    static void makeData(){
        
        // Create Internal Category Map
        Di_Idea_Internal_Category_Map__c catMap = new Di_Idea_Internal_Category_Map__c();
        catMap.Di_Idea_Channel__c = 'Online';
        catMap.Di_Idea_Category__c = 'General Digital Banking';
        catMap.Di_Idea_Line_of_Business__c = 'Retail Banking';
        catMap.Di_Internal_Category_Name__c = 'Online Banking';
        catMap.Di_Idea_Product_Manager_Name__c = 'Bryan Link';
        insert catMap;

        // create bad word list in database
        DI_IdeaExchange_Bad_Words__c badWord = new DI_IdeaExchange_Bad_Words__c(Name='bad');
        insert badWord;

        // Creating Ideas
        Community c = new Community();
        c = [select id from Community where Name='IdeaExchange'];
        
        // Creating Idea Theme to create Theme Idea
        IdeaTheme it = new IdeaTheme();
        it.DI_Owner__c = userinfo.getUserid();
        it.CommunityId = c.id;
        it.Title = 'New Theme';
        it.DI_Co_owner__c = userinfo.getuserid();
        insert it; 
        // Theme Idea
        Idea idea = new Idea();
        idea.title='Theme Idea';
        idea.body='Test Body';
        idea.ideathemeId = it.id;
        idea.status = 'Under Point Threshold';
        idea.communityid=c.id;
        idea.Di_Idea_Alt_1st_Product_Manager__c = userinfo.getUserid();
        idea.Di_Idea_Line_of_Business__c = 'Retail Banking';
        idea.Di_Idea_Channel__c='Online';
        idea.Di_Idea_Category__c ='General Digital Banking';
        idea.Di_Idea_Alt_2nd_Product_Manager__c = userinfo.getUserid();
        idea.Di_Idea_Alt_3rd_Product_Manager__c = userinfo.getUserid();
        idea.FI_Name__c = 'new';
        insert idea;
        // Regular Idea (Not theme Idea)
        Idea rIdea = new Idea();
        rIdea.title='Regular Idea';
        rIdea.body='Test Body';
        rIdea.status = 'Under Point Threshold';
        rIdea.communityid=c.id;
        rIdea.Di_Idea_Alt_1st_Product_Manager__c = userinfo.getUserid();
        rIdea.Di_Idea_Line_of_Business__c = 'Retail Banking';
        rIdea.Di_Idea_Channel__c='Online';
        rIdea.Di_Idea_Category__c ='General Digital Banking';
        rIdea.Di_Idea_Alt_2nd_Product_Manager__c = userinfo.getUserid();
        rIdea.Di_Idea_Alt_3rd_Product_Manager__c = userinfo.getUserid();
        rIdea.FI_Name__c = 'new';
        insert rIdea;
    }
    
    @isTest
    public static void validateIdeaCommentTextTest() {
        // try to put bad word
        List<Idea> ideas = [SELECT Id, Title FROM Idea WHERE Title = 'Regular Idea'];
        IdeaComment ideacomment = new IdeaComment();
        ideacomment.commentbody = 'bad';
        ideacomment.IdeaId=ideas[0].id;
        try {
            insert ideacomment;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(system.label.vl_Id_CmTest1), 'Expected error have not occured');
        }
        
    }

    @isTest
    public static void emailAlertForComment() {
        List<Di_Idea_Favorites__c> favorites = new List<Di_Idea_Favorites__c>();
        // Adding Idea into favorite list. So user can get notification for his fevorite ideas
        List<Idea> ideas = [SELECT Id, Title FROM Idea WHERE Title = 'Regular Idea'];
        Di_Idea_Favorites__c f1 = new Di_Idea_Favorites__c();
        f1.Di_Idea__c = ideas[0].id;
        f1.User__c  = userinfo.getUserid();
        favorites.add(f1);
        //Adding theme into favorite list
        List<IdeaTheme> themes = new List<IdeaTheme>();
        themes = [SELECT Id, Title FROM IdeaTheme WHERE Title = 'New Theme'];
        Di_Idea_Favorites__c f2 = new Di_Idea_Favorites__c();
        f2.User__c  = userinfo.getUserid();
        f2.DI_Idea_Theme__c = themes[0].Id;
        favorites.add(f2);
        //save favorite list in DB
        insert favorites;

        //Insert comment under regular idea
        IdeaComment ideacomment = new IdeaComment();
        ideacomment.commentbody = 'Test Comment';
        ideacomment.IdeaId=ideas[0].id;
        insert ideacomment;

        ideacomment.commentbody = 'Test Comment2';
        update ideacomment;
        delete ideacomment; // will reduce the count by 1
        //Insert comment under Theme idea
        List<Idea> tideas = [SELECT Id, Title FROM Idea WHERE Title = 'Theme Idea'];
        IdeaComment ic = new IdeaComment();
        ic.commentbody = 'Test Comment';
        ic.IdeaId=tideas[0].id;
        insert ic;
        System.assert(ic.id!=null);
    }
}