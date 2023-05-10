/*
*    @description:    Controller for NCR_HomePage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August , 2015
*/
public class NCR_HomePageController {

    /*public NCR_HomePageController(ApexPages.StandardController controller) {} commented empty block statement */
    
    /** START -- for HomePage   **/
    public String noRecentIdeasHome {get;set;}      //render error message when there are no recent ideas on HomePage
    public User currentUser {get;set;}              //render current user
    public String defaultAvatar {get;set;}          //render default avatar from admin platform
    public String newUrl {get;set;}
    public string dfDomain{get;set;}
    /** END -- for HomePage **/         
    
    public List<recentIdeasWrapper> recentWrapperList {get;set;}
    public List<popularIdeasWrapper> popularWrapperList {get;set;}
    
    public list<Integer> featSize{get;set;}
    
    public NCR_HomePageController() { 
        newUrl = 'https://aplogin.digitalinsight.com'; 
        recentWrapperList = new List<recentIdeasWrapper>();
        recentWrapperList = populateRecentWrapper();
        popularWrapperList = new List<popularIdeasWrapper>();
        popularWrapperList = populatePopularWrapper();
        
        currentUser = [SELECT id,DI_Fi_Domain__c FROM User WHERE id =: UserInfo.getUserId()];
        dfDomain = currentUser.DI_Fi_Domain__c;
        //replaces http to https
        if(dfDomain != null){
            if(!dfDomain.toLowerCase().contains('https')){
                dfDomain = dfDomain.toLowerCase().replace('http','https');
            }
            
        }
        /** START -- for HomePage   **/        
        //display error message if there are no recent ideas
        if(getRecentIdeas().size() == 0) {
            noRecentIdeasHome = 'No Records Found.';
        } else {
            noRecentIdeasHome = '';
        }  
        
        //get default avatar
        SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
        defaultAvatar = sl.Link__c + sl.Name;
        /** END -- for HomePage **/ 
        
         
        integer listSize = [select count() from Idea where Di_Idea_Featured_Flag__c = true ];
        featsize = new list<integer>();
        for(integer count = 1; count < listSize;count ++){
            featsize.add(count);            
        }
        featsize.sort();
        
        
    }   //end of constructor
    
    
    
    /** START -- for HomePage   **/
    /*
    *    @description:    get the first three of featured ideas.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<Idea> getFeaturedIdeas() {
        // [select id , Body, Title, CreatedBy.Name,Di_Idea_Featured_Image__c from Idea where Di_Idea_Featured_Flag__c = true ORDER BY CreatedDate DESC LIMIT 3];
        return [select id , Body, Title, CreatedBy.Name,Di_Idea_Featured_Image__c, CreatedBy.ProfileId, CreatedBy.Title, CreatedBy.DI_Fi_Name__c from Idea where Di_Idea_Featured_Flag__c = true ORDER BY CreatedDate DESC];
    }
    
    /*
    *    @description:    get the first two of the recent ideas.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<Idea> getRecentIdeas() {
        list<idea> tempIdeaList = new list<idea>();
        for(idea tempA :[select id, Status , Body, Title, CreatedBy.Name, Di_Idea_Featured_Image__c, CreatedDate, CreatedById, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, VoteTotal, CreatedBy.pics__c,CreatedBy.ProfileId, CreatedBy.Title, CreatedBy.DI_Fi_Name__c, Di_Idea_Channel__c  from Idea where createddate = LAST_N_DAYS:60 ORDER BY  CreatedDate desc]){
            tempA.Body = tempA.Body.stripHtmlTags();
        tempIdeaList.add(tempA);    
        }
        return tempIdeaList;
    }
    
    /*
    *    @description:    get popular ideas.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<Idea> getPopularIdeas() {
        list<idea> tempIdeaList = new list<idea>();
        for(idea tempA :[select id, Body , Status , Title , VoteScore, CreatedBy.Name, Di_Idea_Featured_Image__c, CreatedDate, CreatedById, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, VoteTotal, CreatedBy.pics__c, CreatedBy.ProfileId, CreatedBy.Title, CreatedBy.DI_Fi_Name__c, Di_Idea_Channel__c from Idea ORDER BY VoteScore desc limit 2]){
        
        tempA.Body = tempA.Body.stripHtmlTags();
        tempIdeaList.add(tempA);    
        }
        return tempIdeaList;
    }
    
    /*
    *    @description:    action for the View All Recent Ideas Link.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public PageReference getViewAllRecent() {
        PageReference gotorecord = new PageReference('/apex/NCR_viewallpage?selectTab=Recent');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    /*
    *    @description:    action for the View All Popular Ideas Link.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public PageReference getViewAllPopular() {
        PageReference gotorecord = new PageReference('/apex/NCR_viewallpage?selectTab=Popular');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    /** END -- for HomePage **/
    
    
    /*
    *    @description:    pagination for recent ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /****** RECENT ******/
    public class recentIdeasWrapper {
        public Id idRecent {get;set;}
        public String titleRecent {get;set;}
        public String bodyRecent {get;set;}
        public String fImageRecent {get;set;}
        public Id createdByIdRecent {get;set;}
        public String createdByNameRecent {get;set;}
        public DateTime createdDateRecent {get;set;}
        public String lobRecent {get;set;}
        public String categoryRecent {get;set;}
        public Boolean isFaveRecent {get;set;}
        public Decimal totalVotesRecent {get;set;}
        public String statRecent {get;set;}
        public String createdByProfileIdRecent {get;set;}
        public String createdByTitleRecent {get;set;}
        public String createdByDiFiNameRecent {get;set;}
        public String diIdeaChannelRecent {get;set;}
        
        public recentIdeasWrapper(Id idRecent, String titleRecent, String bodyRecent, String fImageRecent, Id createdByIdRecent, String createdByNameRecent, DateTime createdDateRecent, String lobRecent, String categoryRecent, Boolean isFaveRecent, Decimal totalVotesRecent, String statRecent,String createdByProfileIdRecent,String createdByTitleRecent,String createdByDiFiNameRecent, String diIdeaChannelRecent) {
            this.idRecent = idRecent;
            this.titleRecent = titleRecent;
            this.bodyRecent = bodyRecent;
            this.fImageRecent = fImageRecent;
            this.createdByIdRecent = createdByIdRecent;
            this.createdByNameRecent = createdByNameRecent;
            this.createdDateRecent = createdDateRecent;
            this.lobRecent = lobRecent;
            this.categoryRecent = categoryRecent;
            this.isFaveRecent = isFaveRecent;
            this.totalVotesRecent = totalVotesRecent;
            this.statRecent = statRecent;
            this.createdByProfileIdRecent = createdByProfileIdRecent;
            this.createdByTitleRecent = createdByTitleRecent;
            this.createdByDiFiNameRecent = createdByDiFiNameRecent;
            this.diIdeaChannelRecent = diIdeaChannelRecent;
        }
    }
    
    public List<recentIdeasWrapper> populateRecentWrapper() {       
        List<recentIdeasWrapper> customWrapperList = new List<recentIdeasWrapper>();
        Set<id> ideaIds = new Set<id>();
        for(Idea a : getRecentIdeas()) {
            ideaIds.add(a.id);
        }
        
        Boolean isFavorite;
        Map<id, Boolean> mapFavorite = new Map<Id, Boolean>();
        List<Di_Idea_Favorites__c> faveList = [SELECT id, Di_Idea__c FROM Di_Idea_Favorites__c WHERE Di_Idea__c IN: ideaIds AND User__c =: UserInfo.getUserId()];
        if(faveList.size() > 0) {
            for(Di_Idea_Favorites__c fave : faveList) {
                isFavorite = true;
                mapFavorite.put(fave.Di_Idea__c, isFavorite);
            }
        }
        
        for(Idea a : getRecentIdeas()) {
            if(mapFavorite.size() > 0) {
                customWrapperList.add(new recentIdeasWrapper(a.id, a.Title, a.Body, a.CreatedBy.pics__c, a.CreatedById, a.CreatedBy.Name, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, mapFavorite.get(a.id), a.VoteTotal, a.Status, a.CreatedBy.ProfileId, a.CreatedBy.Title, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
            } else {
                isFavorite = false;
                customWrapperList.add(new recentIdeasWrapper(a.id, a.Title, a.Body, a.CreatedBy.pics__c, a.CreatedById, a.CreatedBy.Name, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, isFavorite, a.VoteTotal, a.Status,  a.CreatedBy.ProfileId, a.CreatedBy.Title, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
            }
        }
        return customWrapperList;
    } 
    
    /*
    *    @description:    pagination for popular ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /****** POPULAR ******/
    public class PopularIdeasWrapper {
        public Id idPopular {get;set;}
        public String titlePopular {get;set;}
        public String bodyPopular {get;set;}
        public String fImagePopular {get;set;}
        public Id createdByIdPopular {get;set;}
        public String createdByNamePopular {get;set;}
        public DateTime createdDatePopular {get;set;}
        public String lobPopular {get;set;}
        public String categoryPopular {get;set;}
        public Boolean isFavePopular {get;set;}
        public Decimal totalVotesPopular {get;set;}
        public String statPopular {get;set;}
        public String createdByProfileIdPopular {get;set;}
        public String createdByTitlePopular {get;set;}
        public String createdByDiFiNamePopular {get;set;}
        public String diIdeaChannelPopular {get;set;}
        
        public PopularIdeasWrapper(Id idPopular, String titlePopular, String bodyPopular, String fImagePopular, Id createdByIdPopular, String createdByNamePopular, DateTime createdDatePopular, String lobPopular, String categoryPopular, Boolean isFavePopular, Decimal totalVotesPopular, String statPopular, String createdByProfileIdPopular, String createdByTitlePopular, String createdByDiFiNamePopular, String diIdeaChannelPopular ) {
            this.idPopular = idPopular;
            this.titlePopular = titlePopular;
            this.bodyPopular = bodyPopular;
            this.fImagePopular = fImagePopular;
            this.createdByIdPopular = createdByIdPopular;
            this.createdByNamePopular = createdByNamePopular;
            this.createdDatePopular = createdDatePopular;
            this.lobPopular = lobPopular;
            this.categoryPopular = categoryPopular;
            this.isFavePopular = isFavePopular;
            this.totalVotesPopular = totalVotesPopular;
            this.statPopular = statPopular;
            this.createdByProfileIdPopular = createdByProfileIdPopular;
            this.createdByTitlePopular = createdByTitlePopular;
            this.createdByDiFiNamePopular = createdByDiFiNamePopular;
            this.diIdeaChannelPopular = diIdeaChannelPopular  ;
        }
    }
    
    public List<PopularIdeasWrapper> populatePopularWrapper() {     
        List<PopularIdeasWrapper> customWrapperList = new List<PopularIdeasWrapper>();
        Set<id> ideaIds = new Set<id>();
        for(Idea a : getPopularIdeas()) {
            ideaIds.add(a.id);
        }
        
        Boolean isFavorite;
        Map<id, Boolean> mapFavorite = new Map<Id, Boolean>();
        List<Di_Idea_Favorites__c> faveList = [SELECT id, Di_Idea__c FROM Di_Idea_Favorites__c WHERE Di_Idea__c IN: ideaIds AND User__c =: UserInfo.getUserId()];
        if(faveList.size() > 0) {
            for(Di_Idea_Favorites__c fave : faveList) {
                isFavorite = true;
                mapFavorite.put(fave.Di_Idea__c, isFavorite);
            }
        }
        
        for(Idea a : getPopularIdeas()) {
            if(mapFavorite.size() > 0) {
                customWrapperList.add(new PopularIdeasWrapper(a.id, a.Title, a.Body, a.CreatedBy.pics__c, a.CreatedById, a.CreatedBy.Name, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, mapFavorite.get(a.id), a.VoteTotal, a.Status, a.CreatedBy.Id, a.CreatedBy.Title, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c ));
            } else {
                isFavorite = false;
                customWrapperList.add(new PopularIdeasWrapper(a.id, a.Title, a.Body, a.CreatedBy.pics__c, a.CreatedById, a.CreatedBy.Name, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, isFavorite, a.VoteTotal, a.Status, a.CreatedBy.Id, a.CreatedBy.Title, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
            }
        }
        return customWrapperList;
    }
    
    /*
    *    @description:    action for adding idea to favorites from recent ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id recentIdeaId {get;set;}
    public pageReference insertToMyFavorites() {        
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = recentIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_HomePage');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    /*
    *    @description:    action for deleting idea to favorites from recent.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id RecentFaveIdeaId {get;set;}
    public pageReference deleteToMyFavoritesRecent() {     
        Di_Idea_Favorites__c fvr = [SELECT id, Di_Idea__c, User__c FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: RecentFaveIdeaId AND User__c =: UserInfo.getUserId()];
        delete fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_HomePage');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    /*
    *    @description:    action for adding idea to favorites from popular.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id PopularIdeaId {get;set;}
    public pageReference insertToMyFavoritesPopular() {     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = PopularIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_HomePage');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    /*
    *    @description:    action for deleting idea to favorites from popular.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id PopularFaveIdeaId {get;set;}
    public pageReference deleteToMyFavoritesPopular() {     
        Di_Idea_Favorites__c fvr = [SELECT id, Di_Idea__c, User__c FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: PopularFaveIdeaId AND User__c =: UserInfo.getUserId()];
        delete fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_HomePage');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
}