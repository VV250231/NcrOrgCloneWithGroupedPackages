/*
##################################################################################################
# Class Name............................:NCR_ThemeDetailExt                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class NCR_ThemeDetailExt {  
    
    public List<Idea> similarIdeasList {get;set;}  
     
    public List<IdeaWrapper> ideaWrappers;
    public String themeId{get;set;}
    public String newIdeaTitle {get;set;}
    public Idea newIdea {get;set;}
    String communityId;
    public IdeaTheme themeRec {get;set;}
    
    
    public NCR_ThemeDetailExt() {
        similarIdeasList = new List<Idea>();
        themeRec = new IdeaTheme();
        themeId = ApexPages.currentPage().getParameters().get('Id');
        List<IdeaTheme> themes = [SELECT Id, Title, Description, DI_Line_of_Business__c, DI_Category__c, Status FROM IdeaTheme WHERE Id =: themeId];
        themeRec = themes[0];
        
        newIdea = new Idea(); 
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        if (netWorks.size() > 0) {
            List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
            if(zones.size() > 0)
                communityId = zones[0].Id;    
        }
        
    }
    
    public void searchTitle() {
        similarIdeasList.clear();   
        List<List<sObject>> searchResultList = new List<List<sObject>>();
        if (newIdeaTitle.length() > 2) {
            searchResultList = [FIND : newIdeaTitle IN ALL FIELDS RETURNING idea(id,title, Di_Idea_Category__c,Di_Idea_Channel__c,Di_Idea_Line_of_Business__c, VoteTotal)];
            if (searchResultList.size() > 0) {
                similarIdeasList.addAll((List<Idea>) searchResultList[0]);
            }
         }
    }
    
    String favRecId;
    public String getFavRecId() {
        List<Di_Idea_Favorites__c> favTheme = [SELECT ID FROM Di_Idea_Favorites__c WHERE DI_Idea_Theme__c =: themeId AND User__c =: UserInfo.getUserId()];
        if (favTheme.size() > 0) {
            favRecId = favTheme[0].ID;
        }
        return favRecId;
    }
    
    public PageReference processVote() {
        String parentId = ApexPages.currentPage().getParameters().get('pId').escapeHTML4();
        String voteType = 'Up';
        
        Vote newVote = new Vote();
        newVote.ParentId = parentId;
        newVote.Type = voteType;
        insert newVote;
        
        PageReference pr = Page.NCR_ThemeDetail;
        pr.getParameters().put('id',themeId.escapeHTML4());
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference addThemeToFavList() {
        Di_Idea_Favorites__c fav = new Di_Idea_Favorites__c();
        fav.DI_Idea_Theme__c     = themeId.escapeHTML4();
        fav.User__c              = UserInfo.getUserId();
        Insert fav;
        PageReference pr = Page.NCR_ThemeDetail;
        pr.getParameters().put('id',themeId.escapeHTML4());
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference removeFromFavList() {
        String favId = ApexPages.currentPage().getParameters().get('favId');
        List<Di_Idea_Favorites__c> favTheme = [SELECT ID FROM Di_Idea_Favorites__c WHERE Id = : favId];
        if (favTheme.size() > 0)
            delete favTheme;
        PageReference pr = Page.NCR_ThemeDetail;
        pr.getParameters().put('id',themeId.escapeHTML4());
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference addIdeaToFavList() {
        String ideaId = ApexPages.currentPage().getParameters().get('ideaRecId').escapeHTML4();
        Di_Idea_Favorites__c fav = new Di_Idea_Favorites__c();
        fav.Di_Idea__c = ideaId;
        fav.User__c = UserInfo.getUserId();
        Insert fav;
        PageReference pr = Page.NCR_ThemeDetail;
        pr.getParameters().put('id',themeId.escapeHTML4());
        pr.setRedirect(true);
        return pr;
    }
    
    public List<IdeaWrapper> getIdeaWrappers() {
        if (ideaWrappers == null) {
            ideaWrappers = new List<IdeaWrapper>();
            for (Idea ideaRec : [SELECT Id, Title, Body, VoteTotal, CreatedBy.Name,CreatedById, CreatedDate,CreatedBy.pics__c, FI_Name__c,CreatedBy.Title,
                                 (SELECT Id, ParentId, Type FROM Votes WHERE CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'),
                                 (SELECT Id, Di_Idea__c FROM Idea_Favorites__r WHERE User__c =: UserInfo.getUserId())
                                 FROM Idea WHERE IdeaThemeID =: themeId ORDER BY CreatedDate DESC]) {
                IdeaWrapper wrapper = new IdeaWrapper(ideaRec);
                ideaWrappers.add(wrapper);
            }
        }
        return ideaWrappers;
    }
    
    public String defaultAvatar {
        get {
            string imgLink;
            if (defaultAvatar == null) {
                 SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
                 imgLink = sl.Link__c + sl.Name;
            }
            return imgLink;
        }
    }
    
    public PageReference saveIdea() {
        
        newIdea.Title = newIdeaTitle;
        newIdea.IdeaThemeID = themeId.escapeHTML4();
        newIdea.communityId = communityId;
        insert newIdea;
        PageReference pr = Page.NCR_ThemeDetail;
        pr.getParameters().put('id',themeId.escapeHTML4());
        pr.setRedirect(true);
        return pr;
    }
    
    public class IdeaWrapper {
        public String ideaId {get;set;}
        public String ideaTitle {get;set;}
        public String ideaBody {get;set;}
        public String fiName {get;set;}
        public String createdByName {get;set;}
        public String createdByPic {get;set;}
        public boolean isCurrentUserVotedForIdea {get;set;}
        public boolean isFavoriteIdea {get;set;}
        public String favoriteRecId {get;set;}
        public Decimal voteTotal {get;set;}
        public DateTime createdDate {get;set;}
        public String createdByTitle {get;set;}
        public ideaWrapper(Idea idea) {
            this.ideaId = idea.Id;
            this.ideaTitle = idea.Title;
            this.ideaBody = idea.Body != null ? idea.Body.stripHtmlTags().abbreviate(150) : idea.Body;
            this.fiName = idea.FI_Name__c;
            this.createdByName = idea.CreatedBy.Name;
            this.createdByTitle = idea.CreatedBy.Title;
            this.createdByPic = idea.CreatedBy.pics__c;
            this.createdDate = idea.CreatedDate;
            this.voteTotal = idea.VoteTotal;
            this.isCurrentUserVotedForIdea = idea.votes.size() > 0 ? true : false;
            this.isFavoriteIdea = idea.Idea_Favorites__r.size() > 0 ? true : false;
            this.favoriteRecId = idea.Idea_Favorites__r.size() > 0 ? idea.Idea_Favorites__r[0].Id : null;
        }
    }
}