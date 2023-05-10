/*
##################################################################################################
# Class Name............................:NCR_IdeaThemeHomePageConTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class NCR_IdeaThemeHomePageConTest {
    public static testMethod void testThemeHomePage() {
        //Insert Theme
        IdeaTheme theme = new IdeaTheme();
        theme.Title = 'Test Theme';
        theme.Description = 'Theme Description';
        theme.DI_Category__c = 'DI Labs';
        theme.Status = 'Accepting Ideas';
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        if (netWorks.size() > 0) {
            List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
            theme.CommunityId = zones[0].Id;
        }
        insert theme;      
        
        // Insert Idea under the theme
        Idea newIdea = new Idea();
        newIdea.title = 'Test Idea';
        newIdea.Body = 'Test Body';
        newIdea.IdeaThemeID = theme.Id;
        if (netWorks.size() > 0) {
            List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
            newIdea.CommunityId = zones[0].Id;
        }
        insert newIdea;
        
        PageReference pr = Page.NCR_IdeaThemeHomePage;
        pr.getParameters().put('category','Design');
        Test.setCurrentPage(pr);

        NCR_IdeaThemeHomePageCon con = new NCR_IdeaThemeHomePageCon();
        con.getThemes();
        con.changeCategory();
        con.subscribe();
        con.getSubscription();
        con.unSubscribe();
        
        con.selectedCategory = 'DI Labs';
        NCR_IdeaThemeHomePageCon.ThemeWithIdeaWrapper obj = con.themeWithIdeaWrappers[0];
        System.assert(obj.ideas.size()>0);
        //List<con.ThemeWithIdeaWrapper> themeWithIdeaWrappers = con.themeWithIdeaWrappers;
    }
}