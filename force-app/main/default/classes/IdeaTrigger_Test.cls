@isTest
public class IdeaTrigger_Test {
    @TestSetup
    static void makeData() {
        // Fetch user record from setup object user.
        User bryan, brett;
        for (User u : [SELECT Id, Name, Email FROM User WHERE Name IN ('Bryan Link','Brett Conoly') AND Profile.Name = '60 DI Product Managers']) {
            if (u.name == 'Bryan Link') {
                bryan = u;
            } else if (u.name == 'Brett Conoly') {
                brett = u;
            }
        }

    }

    @isTest
    public static void fillInternalMappingTest() {
        createInternalMapping();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        Idea idea = new Idea();
        idea.title='test';
        idea.body='test';
        idea.communityid=community.id;
        idea.Di_Idea_Channel__c='Online';
        idea.Di_Idea_Line_of_Business__c='Retail Banking';
        idea.Di_Idea_Category__c='General Digital Banking';
        insert idea;
        List<Idea> ideas = new List<Idea>();
        ideas = [SELECT Id,Di_Idea_Product_Manager_Name__c,Di_Internal_Category_Name__c FROM Idea WHERE Id =: idea.Id];
        System.assertEquals('Bryan Link',ideas[0].Di_Idea_Product_Manager_Name__c , 'Product Manager not found');
        System.assertEquals('Online Banking',ideas[0].Di_Internal_Category_Name__c, 'Internal Category not found');
        
    }
   
    @isTest 
    public static void updateProdMangEmailTest() {
        // Fetch user record from setup object user.
        User bryan, brett;
        for (User u : [SELECT Id, Name, Email FROM User WHERE Name IN ('Bryan Link','Brett Conoly') AND Profile.Name = '60 DI Product Managers']) {
            if (u.name == 'Bryan Link') {
                bryan = u;
            } else if (u.name == 'Brett Conoly') {
                brett = u;
            }
        }
        createInternalMapping();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        Idea idea = new Idea();
        idea.title='test';
        idea.body='test';
        idea.communityid=community.id;
        idea.Di_Idea_Channel__c='Online';
        idea.Di_Idea_Line_of_Business__c='Retail Banking';
        idea.Di_Idea_Category__c='General Digital Banking';
        insert idea;

        idea.Di_Idea_Product_Manager_Name__c = 'Brett Conoly';
        update idea;
        List<Idea> ideas = new List<Idea>();
        ideas = [SELECT Id,Di_Idea_Product_Manager_Name__c,Di_Idea_Product_Manager_Email__c,Di_Internal_Category_Name__c FROM Idea WHERE Id =: idea.Id];
        System.assertEquals(brett.Email, ideas[0].Di_Idea_Product_Manager_Email__c, 'Brett email not set'); 
    }

    @isTest
    public static void createIdeaHistoryTest() {
        // Fetch user record from setup object user.
        User bryan, brett;
        for (User u : [SELECT Id, Name, Email FROM User WHERE Name IN ('Bryan Link','Brett Conoly') AND Profile.Name = '60 DI Product Managers']) {
            if (u.name == 'Bryan Link') {
                bryan = u;
            } else if (u.name == 'Brett Conoly') {
                brett = u;
            }
        }
        createInternalMapping();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        System.assertNotEquals(community, null,'community should not be null');
        Idea idea = new Idea();
        idea.title='test';
        idea.body='test';
        idea.communityid=community.id;
        idea.Di_Idea_Channel__c='Online';
        idea.Di_Idea_Line_of_Business__c='Retail Banking';
        idea.Di_Idea_Category__c='General Digital Banking';
        insert idea;

        idea.Di_Idea_Product_Manager_Name__c = 'Brett Conoly';
        idea.Di_Idea_Alt_1st_Product_Manager__c = UserInfo.getUserId();
        idea.Di_Idea_Alt_2nd_Product_Manager__c = UserInfo.getUserId();
        idea.Di_Idea_Alt_3rd_Product_Manager__c = UserInfo.getUserId();
        idea.Di_Idea_Category__c = 'General Business Banking';
        idea.Di_Idea_Channel__c = 'Mobile';
        idea.Di_Idea_DI_Release_Date__c =  '1-01-16';
        idea.Di_Idea_DI_Release_Number__c = '123456';
        idea.Di_Idea_Due_Date__c = System.now()+1;
        idea.Di_Idea_Featured_Flag__c = true;
        idea.Di_Idea_Featured_Image__c = 'www.domyimage.com';
        idea.Body = 'Changed Body';
        idea.Di_Internal_Category_Name__c = 'Alerts';
        idea.Di_Idea_Jira_Number__c = '123';
        idea.Di_Idea_Line_of_Business__c='Consumer Relationship';
        idea.Di_Idea_SLA_Status__c = 'SLA 2 Voilated';
        idea.Title = 'Changed Title';
        update idea;
    }

    
    @isTest
    public static void subscriptionMailTest(){
        Test.StartTest();
        // Suscribe for lob and category
        DI_IdeaSubscription__c ic = new DI_IdeaSubscription__c();
        ic.DI_LineOfBusiness__c='Retail Banking';
        ic.DI_SubscriptionCategory__c='General Digital Banking';
        ic.name='test';
        ic.DI_UserName__c=UserInfo.getUserId();
        System.assertNotEquals(ic, null,'ic should not be null');
        insert ic;

        // Create Idea of above Lob and Category to get email notification.
        createInternalMapping();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        Idea idea = new Idea();
        idea.title='test';
        idea.body='test';
        idea.communityid=community.id;
        idea.Di_Idea_Channel__c='Online';
        idea.Di_Idea_Line_of_Business__c='Retail Banking';
        idea.Di_Idea_Category__c='General Digital Banking';
        insert idea;
        Test.stopTest();

    }

    @isTest
    public static void DI_UpdateFieldsTest(){
        Community c = new Community();
        c = [select id from Community where Name='IdeaExchange'];
        ideatheme ith = new ideatheme();
        ith.title = 'abc';
        ith.Communityid = c.id;
        System.assertNotEquals(c, null,'Community should not be null');

        insert ith;

        idea i=new idea();
        i.CommunityId=c.id;
        i.title='xyz';
        i.ideathemeid=ith.id;
        insert i;
    }

    @isTest
    public static void validateIdeaTextTest() {
        DI_IdeaExchange_Bad_Words__c badWord = new DI_IdeaExchange_Bad_Words__c(Name='bad');
        insert badWord;
        Test.StartTest();
        Community community = new Community();
        community = [select id from Community where Name='IdeaExchange'];
        Idea idea = new Idea();
        idea.title='bad';
        idea.body='bad';
        idea.communityid=community.id;
        idea.Di_Idea_Channel__c='Online';
        idea.Di_Idea_Line_of_Business__c='Retail Banking';
        idea.Di_Idea_Category__c='General Digital Banking';
        try {
            insert idea;
        } catch (Exception e) {
            System.assert(e.getMessage().contains(system.label.Vld_id_txt1), e.getMessage());
        }
        Test.stopTest();
    }

    static void createInternalMapping() {
        // Create Internal Category Map
        Di_Idea_Internal_Category_Map__c catMap = new Di_Idea_Internal_Category_Map__c();
        catMap.Di_Idea_Channel__c = 'Online';
        catMap.Di_Idea_Category__c = 'General Digital Banking';
        catMap.Di_Idea_Line_of_Business__c = 'Retail Banking';
        catMap.Di_Internal_Category_Name__c = 'Online Banking';
        catMap.Di_Idea_Product_Manager_Name__c = 'Bryan Link';
        insert catMap;
    }
}