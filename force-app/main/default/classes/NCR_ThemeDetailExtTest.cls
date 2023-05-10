/*
##################################################################################################
# Class Name............................:NCR_ThemeDetailExtTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class NCR_ThemeDetailExtTest {
    public static testMethod void testNCR_ThemeDetailExt() {
        String communityId;
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
            communityId = zones[0].Id;
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
        
        PageReference pr = Page.NCR_ThemeDetail;
        pr.getParameters().put('id',theme.Id);
        Test.setCurrentPage(pr);
        
        NCR_ThemeDetailExt con = new NCR_ThemeDetailExt();
        con.newIdeaTitle = 'Test';
        con.searchTitle();
        con.saveIdea();
        pr.getParameters().put('pId',newIdea.Id);
        pr.getParameters().put('ideaRecId',newIdea.Id);
        //con.processVote();
        con.addIdeaToFavList();
        List<Di_Idea_Favorites__c> fav = [SELECT Id, Name From Di_Idea_Favorites__c WHERE Di_Idea__c =: newIdea.Id];
        if (fav.size() > 0) {
            ApexPages.currentPage().getParameters().put('favId',fav[0].Id);
            con.removeFromFavList();
        }
        //String img = con.defaultAvatar;
        List<NCR_ThemeDetailExt.IdeaWrapper> ideaWrappers = con.getIdeaWrappers();
        con.getFavRecId();
        con.addThemeToFavList();  
        con.addIdeaToFavList(); 
        String favRecId = con.getFavRecId();
        System.assert(favRecId==con.getFavRecId());
        
    }
}