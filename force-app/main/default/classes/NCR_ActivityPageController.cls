/*
*    @description:    Controller for NCR_ActivityPage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 13, 2015
*/
public class NCR_ActivityPageController {

    /** START -- for ActivityPage   **/
    public String selectedRow {get;set;}            //render selected row
    public String noMyIdeas {get;set;}              //render error message when there are no my ideas on ActivityPage
    public String noReplies {get;set;}              //render error message when there are no recent ideas on ActivityPage    
    public String noFavorites {get;set;}            //render error message when there are no favorites on ActivityPage 
    public String noFavoriteThemes {get;set;}       //render error message when there are no favorite theme on ActivityPage 
    public String noComments {get;set;}             //render error message when there are no comments on ActivityPage
    public String noMyTeam {get;set;}               //render error message when there are no team on ActivityPage
    public Map<ID, Integer> ideaVote {get;set;}     //render total number of idea votes
    public String defaultAvatar {get;set;}          //render default avatar from admin platform
    public String newUrl {get;set;}
    public String tab{get;set;}
    public String urlVal{get;set;}
    public String retUrl {get;set;}
    public boolean rendBack{get;set;}
    public Boolean SubscriberCheck {get;set;}
    public String selectedPopularLineOfBusiness {get;set;}  
    public String selectedPopularCategory {get;set;}
    /** END -- for ActivityPage **/

    public NCR_ActivityPageController() {
        retUrl='/apex/';
        if(((ApexPages.currentPage().getParameters().get('pge')).escapeHTML4() !=null)){
            retUrl = retUrl + (ApexPages.currentPage().getParameters().get('pge')).escapeHTML4();            
            rendBack = true;
        }
        if(( (ApexPages.currentPage().getParameters().get('tb')).escapeHTML4() !=null) && !(Apexpages.currentPage().getUrl().escapeHTML4()).contains('NCR_Homepage')){
            retUrl = retUrl + '?selectedTab='+ ApexPages.currentPage().getParameters().get('tb').escapeHTML4();            
            rendBack = true;
        }
        if(Apexpages.currentPage().getUrl().contains('NCR_ViewAllPage')) {
            urlVal='NCR_ViewAllPage';
        }
        if(Apexpages.currentPage().getUrl().contains('NCR_Homepage')) {
            urlVal='NCR_Homepage';
        }

        if(ApexPages.currentPage().getParameters().get('tb')!=null) {
            tab=ApexPages.currentPage().getParameters().get('tb');
        }

        /** START -- for ActivityPage   **/
        newUrl = 'https://aplogin.digitalinsight.com';

        selectedRow = ApexPages.currentPage().getParameters().get('selectRow');
        if(selectedRow == null) {
            selectedRow = 'MyIdeas';
        } else {            
            selectedRow = ApexPages.currentPage().getParameters().get('selectRow');
        }
        if(!String.isBlank(ApexPages.currentPage().getParameters().get('num'))){
            SubscriberCheck=true;
        }
        else {
            SubscriberCheck=false;
        }
        //get default avatar
        SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
        defaultAvatar = sl.Link__c + sl.Name;

        if(getActivityMyIdeas().size() == 0) { noMyIdeas = 'No Records Found.'; } else { noMyIdeas = ''; }
        if(getActivityRepliesToMyIdeas().size() == 0) { noReplies = 'No Records Found.'; } else { noReplies = ''; } //replies not yet rendered
        if(getActivityFavorites().size() == 0) { noFavorites = 'No Records Found.'; } else { noFavorites = ''; }    //not yet rendered
        if(getFavoriteIdeaThemes().size() == 0) { noFavoriteThemes = 'No Records Found.'; } else { noFavoriteThemes = ''; }    //not yet rendered
        if(getActivityComments().size() == 0) { noComments = 'No Records Found.'; } else { noComments = ''; }   //not yet rendered
        if(getActivityMyTeam().size() == 0) { noMyTeam = 'No Records Found.'; } else { noMyTeam = ''; }   //still need method

        //count votes of ideas
        ideaVote = new Map<Id, Integer>();
        for(Idea i : [Select Id, (Select Id, ParentId from Votes), Title from Idea]) {
            ideaVote.put(i.id, i.Votes.size());
        }
        /** END -- for ActivityPage **/ 




        /** START -- for PAGINATION  **/
        /*****  MYIDEAS  *****/           
        //Get the data we need to paginate
        List<MyIdeasClass> resultsListMyIdeas = populateDataMyIdeas();

        //Set the page size
        Integer pageSizeMyIdeas = 5;

        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterMyIdeas = new PaginateMyIdeas(resultsListMyIdeas.size(), pageSizeMyIdeas);

        //These lists hold the data
        this.fullMyIdeasList = new List<List<MyIdeasClass>>();
        this.MyIdeasList = new List<MyIdeasClass>();

        //Break out the full list into a list of lists
        if(resultsListMyIdeas.size() > 0){
            List<MyIdeasClass> tempcc = new List<MyIdeasClass>();        
            Integer i = 0;
            for(MyIdeasClass cc : resultsListMyIdeas){
                tempcc.add(cc);
                i++;
                if(i == pageSizeMyIdeas){
                    this.fullMyIdeasList.add(tempcc);
                    tempcc = new List<MyIdeasClass>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullMyIdeasList.add(tempcc);
            }

            //Gets the correct list of data to show on the page
            this.MyIdeasList = this.fullMyIdeasList.get(this.paginaterMyIdeas.indexMyIdeas);
        }





        /*****  REPLIES  *****/           
        //Get the data we need to paginate
        List<RepliesClass> resultsListReplies = populateDataReplies();

        //Set the page size
        Integer pageSizeReplies = 5;

        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterReplies = new PaginateReplies(resultsListReplies.size(), pageSizeReplies);

        //These lists hold the data
        this.fullRepliesList = new List<List<RepliesClass>>();
        this.RepliesList = new List<RepliesClass>();

        //Break out the full list into a list of lists
        if(resultsListReplies.size() > 0){
            List<RepliesClass> tempcc = new List<RepliesClass>();        
            Integer i = 0;
            for(RepliesClass cc : resultsListReplies){
                tempcc.add(cc);
                i++;
                if(i == pageSizeReplies){
                    this.fullRepliesList.add(tempcc);
                    tempcc = new List<RepliesClass>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullRepliesList.add(tempcc);
            }

            //Gets the correct list of data to show on the page
            this.RepliesList = this.fullRepliesList.get(this.paginaterReplies.indexReplies);
        }





        /*****  COMMENT  *****/           
        //Get the data we need to paginate
        List<CommentClass> resultsListComment = populateDataComment();

        //Set the page size
        Integer pageSizeComment = 5;

        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterComment = new PaginateComment(resultsListComment.size(), pageSizeComment);

        //These lists hold the data
        this.fullCommentList = new List<List<CommentClass>>();
        this.CommentList = new List<CommentClass>();

        //Break out the full list into a list of lists
        if(resultsListComment.size() > 0){
            List<CommentClass> tempcc = new List<CommentClass>();        
            Integer i = 0;
            for(CommentClass cc : resultsListComment){
                tempcc.add(cc);
                i++;
                if(i == pageSizeComment){
                    this.fullCommentList.add(tempcc);
                    tempcc = new List<CommentClass>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullCommentList.add(tempcc);
            }

            //Gets the correct list of data to show on the page
            this.CommentList = this.fullCommentList.get(this.paginaterComment.indexComment);
        }





        /*****  FAVORITES  *****/           
        //Get the data we need to paginate
        List<FavoritesClass> resultsListFavorites = populateDataFavorites();

        //Set the page size
        Integer pageSizeFavorites = 5;

        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterFavorites = new PaginateFavorites(resultsListFavorites.size(), pageSizeFavorites);

        //These lists hold the data
        this.fullFavoritesList = new List<List<FavoritesClass>>();
        this.FavoritesList = new List<FavoritesClass>();

        //Break out the full list into a list of lists
        if(resultsListFavorites.size() > 0){
            List<FavoritesClass> tempcc = new List<FavoritesClass>();        
            Integer i = 0;
            for(FavoritesClass cc : resultsListFavorites){
                tempcc.add(cc);
                i++;
                if(i == pageSizeFavorites){
                    this.fullFavoritesList.add(tempcc);
                    tempcc = new List<FavoritesClass>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullFavoritesList.add(tempcc);
            }

            //Gets the correct list of data to show on the page
            this.FavoritesList = this.fullFavoritesList.get(this.paginaterFavorites.indexFavorites);
        }




        /*****  FAVORITE Themes  *****/           
        //Get the data we need to paginate
        List<IdeaThemeInner> resultsListIdeaThemes = populateDataIdeaThemes();

        //Set the page size
        Integer pageSizeFaveIdeaThemes = 5;

        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterIdeaTheme = new PaginateIdeaTheme(resultsListIdeaThemes.size(), pageSizeFaveIdeaThemes);

        //These lists hold the data
        this.fullIdeaThemeList = new List<List<IdeaThemeInner>>();
        this.ideaThemeList = new List<IdeaThemeInner>();

        //Break out the full list into a list of lists
        if(resultsListIdeaThemes.size() > 0){
            List<IdeaThemeInner> tempcc = new List<IdeaThemeInner>();        
            Integer i = 0;
            for(IdeaThemeInner cc : resultsListIdeaThemes){
                tempcc.add(cc);
                i++;
                if(i == pageSizeFaveIdeaThemes){
                    this.fullIdeaThemeList.add(tempcc);
                    tempcc = new List<IdeaThemeInner>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullIdeaThemeList.add(tempcc);
            }

            //Gets the correct list of data to show on the page
            system.debug('@@@'+fullIdeaThemeList);
            this.ideaThemeList =  this.fullIdeaThemeList.get(this.paginaterIdeaTheme.index);
        }
        
        
        


        /*****  MYTEAM  *****/           
        //Get the data we need to paginate
        List<MyTeamClass> resultsListMyTeam = populateDataMyTeam();

        //Set the page size
        Integer pageSizeMyTeam = 5;

        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterMyTeam = new PaginateMyTeam(resultsListMyTeam.size(), pageSizeMyTeam);

        //These lists hold the data
        this.fullMyTeamList = new List<List<MyTeamClass>>();
        this.MyTeamList = new List<MyTeamClass>();

        //Break out the full list into a list of lists
        if(resultsListMyTeam.size() > 0){
            List<MyTeamClass> tempcc = new List<MyTeamClass>();        
            Integer i = 0;
            for(MyTeamClass cc : resultsListMyTeam){
                tempcc.add(cc);
                i++;
                if(i == pageSizeMyTeam){
                    this.fullMyTeamList.add(tempcc);
                    tempcc = new List<MyTeamClass>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullMyTeamList.add(tempcc);
            }

            //Gets the correct list of data to show on the page
            this.MyTeamList = this.fullMyTeamList.get(this.paginaterMyTeam.indexMyTeam);
        }

        /** END -- for PAGINATION  **/ 

    }


    /** Find User is subscribed for Idea Exchange Daily Digest or not **/
    public Boolean getIsUserSubForDailyDigest() {
        List<DI_Idea_Exchange_Daily_Digest__c> subscribers = [SELECT DI_User__c, DI_Subscribe_for_daily_digest__c FROM DI_Idea_Exchange_Daily_Digest__c WHERE DI_User__c =: UserInfo.getUserId() LIMIT 1];
        if (subscribers.size() > 0) {
            return subscribers[0].DI_Subscribe_for_daily_digest__c ;
        }

        return false;
    }

    public Boolean getIsUserSubForNewThemeNot() {
        List<DI_Idea_Exchange_Daily_Digest__c> subscribers = [SELECT DI_User__c, DI_Subscribe_for_daily_digest__c,DI_New_Theme_Alert__c FROM DI_Idea_Exchange_Daily_Digest__c WHERE DI_User__c =: UserInfo.getUserId() LIMIT 1];
        if (subscribers.size() > 0) {
            return subscribers[0].DI_New_Theme_Alert__c ;
        }

        return false;
    }
    /**
    * Registers and Unrgister user for daily email digest.
    * 
    */
    public void processSubScribtion() {
        String requestType = ApexPages.currentPage().getParameters().get('requestType');
        String subscriptionType = ApexPages.currentPage().getParameters().get('subscription');
        List<DI_Idea_Exchange_Daily_Digest__c> subscriber = [SELECT DI_User__c, DI_Subscribe_for_daily_digest__c,DI_New_Theme_Alert__c FROM DI_Idea_Exchange_Daily_Digest__c WHERE DI_User__c =: UserInfo.getUserId() LIMIT 1];
        //If there is no record than insert the record.
        if (! (subscriber.size() > 0)) {
            DI_Idea_Exchange_Daily_Digest__c subscribe = new DI_Idea_Exchange_Daily_Digest__c();
            subscribe.DI_User__c = UserInfo.getUserId();
            if (requestType == 'on') { 
                if (subscriptionType == 'Daily Digest')
                    subscribe.DI_Subscribe_for_daily_digest__c = true;
                else if (subscriptionType == 'New Theme Alert')
                    subscribe.DI_New_Theme_Alert__c = true;
            }
            try {
                insert subscribe;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage() ));
            }
        } else {
            // If record is there than just update the subscibe information only
            if (requestType == 'on') {
                if (subscriptionType == 'Daily Digest')
                    subscriber[0].DI_Subscribe_for_daily_digest__c = true;
                else if (subscriptionType == 'New Theme Alert')
                    subscriber[0].DI_New_Theme_Alert__c = true;
            } else {
                if (subscriptionType == 'Daily Digest')
                    subscriber[0].DI_Subscribe_for_daily_digest__c = false;
                else if (subscriptionType == 'New Theme Alert')
                    subscriber[0].DI_New_Theme_Alert__c = false;
            }

            try {
                update subscriber;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
    }
    
    /** START -- for ActivityPage   **/
    /*
    *    @description:    get current user's photo.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public User getUserPhoto() {
        return[SELECT id, SmallPhotoURL,pics__c FROM User WHERE id =: UserInfo.getUserId()];
    }

    /*
    *    @description:    get my ideas list.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<Idea> getActivityMyIdeas() {
        return[SELECT id, Title, Body, Status, CreatedDate, CreatedBy.Name, 
               Di_Idea_Featured_Image__c, Createdby.pics__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, 
               Di_Idea_Channel__c,VoteTotal, CreatedBy.Title, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c  
               FROM Idea WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC limit 20 ]; //50
    }

    /*
    *    @description:    getreplies to my ideas list.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<IdeaComment> getActivityRepliesToMyIdeas() {
        List <idea> MyIdeaList    =   new List <idea> ();
        List <id> MyIdeaidList    =   new List <id> ();
        List <id> MyIdeaidList2    =   new List <id> ();
        MyIdeaList =  [SELECT  id , title FROM Idea WHERE createdbyId =: UserInfo.getUserId() ORDER BY CreatedDate DESC limit 20] ;
        for(idea i : MyIdeaList) {
            MyIdeaidList.add(i.id);
        }
        return[SELECT id, Createdby.pics__c, CreatorName, CommentBody, IdeaId, Idea.Title, 
               CreatedById, CreatedDate, Idea.Di_Idea_Line_of_Business__c, Idea.Di_Idea_Category__c, 
               Idea.Di_Idea_Channel__c, Idea.Status,Idea.VoteTotal, CreatedBy.Title, CreatedBy.ProfileId, 
               CreatedBy.DI_Fi_Name__c FROM IdeaComment WHERE IdeaId IN : MyIdeaIdList ORDER BY CreatedDate DESC limit 20]; 
    }

    /*
    *    @description:    get favorites.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<Idea> getActivityFavorites() {
        List<Di_Idea_Favorites__c> favoriteList = [select id , Di_Idea__c , Di_Idea__r.title, User__c 
                                                   from Di_Idea_Favorites__c where User__c =: UserInfo.getUserId()];
        List <Id> newList = new List <Id>();        

        for(Di_Idea_Favorites__c fav : favoriteList) {
            newList.add(fav.Di_Idea__c);
        }

        List<Idea> MyFavoritesIdeaList = [SELECT id, Title, Body, Status, CreatedDate, CreatedBy.Name, 
                                          Di_Idea_Featured_Image__c, CreatedBy.pics__c, Di_Idea_Line_of_Business__c, 
                                          Di_Idea_Category__c, Di_Idea_Channel__c,VoteTotal, CreatedBy.Title, 
                                          CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c FROM Idea WHERE id IN : newList];
        return MyFavoritesIdeaList;
    }
    
    
    /*
    *   @description get favorite Ideha Themes
    *   @author      Shiv Shankar (shiv.mahla@ncr.com)
    *
    */
    
    public List<IdeaTheme> getFavoriteIdeaThemes() {
        List<Di_Idea_Favorites__c> favoriteList = [select id , DI_Idea_Theme__c, User__c from Di_Idea_Favorites__c 
                                                   where User__c =: UserInfo.getUserId() AND DI_Idea_Theme__c != null];
        Set<Id> themeIds = new Set<Id>();
        
        for (Di_Idea_Favorites__c fav : favoriteList) {
            themeIds.add(fav.DI_Idea_Theme__c);
        }
        
        List<Network> netWorks = new List<NetWork>(); 
        List<Community> zones = new List<Community>();
        List<IdeaTheme> favIdeaThemes = new List<IdeaTheme>();
        
        netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        
        if (netWorks.size() > 0) {
            zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
        }
        
        if (zones.size() > 0) {
            favIdeaThemes = [SELECT Id, Title, Description, DI_Category__c, DI_Line_of_Business__c, Status, StartDate, EndDate, Featured_Image__c, DI_Co_owner__c, DI_Owner__c FROM IdeaTheme
                WHERE CommunityId =: zones[0].Id AND Id IN : themeIds];
        }
         
        return favIdeaThemes;
    }

    /*
    *    @description:    get comments.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List <IdeaComment> getActivityComments() {
        List <idea> IdeaList    =   new List <idea> ();
        List <id> IdeaidList    =   new List <id> ();
        List <id> IdeaidList2    =   new List <id> ();
        List <IdeaComment> MyIdeaCommentList = new List <IdeaComment> ();
        IdeaList = [select id from idea where createdbyid !=: UserInfo.getUserId() ORDER BY CreatedDate DESC limit 50]; //100

        for( Idea i : IdeaList) {
            IdeaidList2.add(i.id);
        }

        return[SELECT id, Createdby.pics__c, CreatorName, CommentBody, IdeaId, Idea.Title, CreatedById, CreatedDate, 
               Idea.Di_Idea_Line_of_Business__c, Idea.Di_Idea_Category__c, Idea.Di_Idea_Channel__c, 
               Idea.Status,Idea.VoteTotal, CreatedBy.Title, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c 
               FROM IdeaComment WHERE CreatedById =: UserInfo.getUserId() AND IdeaId IN : IdeaidList2 ORDER BY CreatedDate DESC];
    }    

    /*
    *    @description:    get my team list.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List <Idea> getActivityMyTeam() {
        List<Idea> MyTeamList = new List<Idea>();
        if (Userinfo.getUserType()=='Standard') {
            User usr = new User();
            usr = [select managerid from user where id =: userInfo.getUserId()] ;
            Map <id,User> Members = new Map <id,User> ([select id from user where managerid =: usr.managerid LIMIT 300]); //1000
            MyTeamList = [SELECT Id, Body, Title, Status, CreatedBy.Name, Di_Idea_Featured_Image__c, CreatedDate, 
                          CreatedBy.pics__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c,VoteTotal, 
                          CreatedBy.Title, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c FROM Idea 
                          WHERE createdbyid IN : Members.keySet()];
        }
        else if (Userinfo.getUserType()!='Standard') {
            user usr = new user();
            usr = [select AccountId from user where id =: userInfo.getUserId()];
            List <User> Members = [select id from user where accountid = : usr.accountid ];
            List <Id> userid = new List<id>();
            for(User u : Members) {
                userid.add(u.id);
            }
            MyTeamList = [SELECT id, Body, Title, Status, CreatedBy.Name, Di_Idea_Featured_Image__c, CreatedDate, 
                          CreatedBy.pics__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c,VoteTotal, 
                          CreatedBy.Title, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c FROM Idea WHERE CreatedById IN: userid];
        }        
        return MyTeamList;
    }    
    /** END -- for ActivityPage **/


    public PageReference Subscription() {   
        SubscriberCheck=true;
        PageReference gotorecord = new PageReference('/apex/NCR_Activitypage?SelectRow=Subscriptions&pge=NCR_ViewAllPage');
        gotorecord.getParameters().put('num','Open');

        gotorecord.setRedirect(true);
        return gotorecord;
    }  




    /** START -- for PAGINATION    **/ /*
    *    @description:    pagination of my ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */       
    /*****  MYIDEAS  *****/
    public PaginateMyIdeas paginaterMyIdeas {get;set;}
    public  List<MyIdeasClass> MyIdeasList{get;set;}
    public  List<List<MyIdeasClass>> fullMyIdeasList{get;set;}


    public PageReference previousPageMyIdeas(){
        this.paginaterMyIdeas.decrementMyIdeas();
        return changeDataMyIdeas();
    }

    public PageReference nextPageMyIdeas(){
        this.paginaterMyIdeas.incrementMyIdeas();
        return changeDataMyIdeas();
    }

    public PageReference updatePageMyIdeas(){
        this.paginaterMyIdeas.updateNumbersMyIdeas();
        return changeDataMyIdeas();
    }

    public PageReference changeDataMyIdeas(){
        this.MyIdeasList = this.fullMyIdeasList.get(this.paginaterMyIdeas.indexMyIdeas);
        return null;
    }

    public List<MyIdeasClass> populateDataMyIdeas(){
        List<MyIdeasClass> customClassList = new List<MyIdeasClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getActivityMyIdeas()) {
            ideaIds.add(a.id);
        }

        List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId()
                            AND Parent.Type = 'Idea'];
        Boolean disableVoting;

        for(Vote v : vList) {
            if(v.id != null) {
                disableVoting = true;
                mapIdea.put(v.ParentId, disableVoting);
            }                
        }

        for(Idea a : getActivityMyIdeas()) {
            if(mapIdea.size() > 0) {
                customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.Status,string.valueof(a.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            } else {
                disableVoting = false;
                customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.Status,string.valueof(a.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            }
        }
        return customClassList;
    }

    


    public List<SelectOption> getLineOfBusinessValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select Line Of Business'));               
        Schema.DescribeFieldResult fieldResult = Idea.Di_Idea_Line_of_Business__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public void changePopularLineOfBusiness() {
        selectedPopularCategory = 'Select Category';
    }
    public void changePopularCategory() {
        if (selectedPopularCategory == 'General Business Banking' || 
            selectedPopularCategory == 'ACH and Wires' || 
            selectedPopularCategory == 'Entitlements' || 
            selectedPopularCategory == 'Third Party Product Integration' || 
            //selectedPopularCategory == 'Deposit Accounts' || -- EBA_SF-1438
            selectedPopularCategory == 'Customer Support' ||
            selectedPopularCategory == 'Remote Deposit' ||
            selectedPopularCategory == 'Reporting' ||
            selectedPopularCategory == 'Alerts' ||
            selectedPopularCategory == 'Positive Pay' ||
            //selectedPopularCategory == 'Other Accounts' -EBS_SF - 1438
            selectedPopularCategory == 'Client Services Developed Solutions') 
        {
            selectedPopularLineOfBusiness = 'Business Banking';
        } 
        else if (selectedPopularCategory == 'Promotion Suite' || 
                 selectedPopularCategory == 'Web Center' || 
                 selectedPopularCategory == 'Purchase Rewards' || 
                 //Commenting due to EBS_SF - 1438 
                 //selectedPopularCategory == 'Online Account Opening' || 
                 // selectedPopularCategory == 'Other'
                 selectedPopularCategory == 'Client Services Developed Solutions') 
        {
                     selectedPopularLineOfBusiness = 'Consumer Relationship';
                 }
        else if(selectedPopularCategory == 'General Payments' || 
                selectedPopularCategory == 'Bill Pay' || 
                selectedPopularCategory == 'External Funds Transfer' || 
                selectedPopularCategory == 'Person to Person Payments' || 
                selectedPopularCategory == 'Internal Transfers' || 
                //selectedPopularCategory == 'Pop Money'||
                selectedPopularCategory == 'Client Services Developed Solutions') 
        {
                    selectedPopularLineOfBusiness = 'Money Movement';
                }
        
        
        else if(selectedPopularCategory == 'General Admin Platform' || 
                selectedPopularCategory == 'Admin User Support' || 
                // selectedPopularCategory == 'End User Support' || 
                selectedPopularCategory == 'Branding and Flexibility' || 
                selectedPopularCategory == 'Interfaces' || 
                selectedPopularCategory == 'Data & Reporting' || 
                selectedPopularCategory == 'SSO and API Solutions' || 
                selectedPopularCategory == 'Security & Authentication' ||
                selectedPopularCategory == 'Idea Exchange' ||
                selectedPopularCategory == 'Account Opening' ||
                selectedPopularCategory == 'Registration ' || 
                selectedPopularCategory == 'Web/Direct Connect' ||
                selectedPopularCategory == 'Digital Communication - Chat, Messaging, Chatbot ' ||
                selectedPopularCategory == 'Online Forms' ||
                selectedPopularCategory == 'Client Services Developed Solutions' ||
                //selectedPopularCategory == 'Admin Platform User Management and Security' || 
                //selectedPopularCategory == 'Reporting' || 
                // selectedPopularCategory == 'Create Your Own/SSO and API Integration' || 
                //selectedPopularCategory == 'Security' || 
                //selectedPopularCategory == 'Other'
                selectedPopularCategory == 'Alerts & Communication') {
                    selectedPopularLineOfBusiness = 'Platform Solutions';
                } 
        
        
        else if(selectedPopularCategory == 'General Retail Banking' ||
                selectedPopularCategory == 'Alerts & Communication' ||
                selectedPopularCategory == 'User Profile Settings' ||
                selectedPopularCategory == 'Check/Deposit Imaging'||
                //selectedPopularCategory == 'Alerts' || 
                //selectedPopularCategory == 'General Digital Banking' ||
                selectedPopularCategory == 'Customer Support' ||
                selectedPopularCategory == 'Money Management' || 
                selectedPopularCategory == 'Online Statements' || 
                selectedPopularCategory == 'Remote Deposit' || 
                selectedPopularCategory == 'Shared Access' || 
                selectedPopularCategory == 'Financial Wellness' || 
                selectedPopularCategory == 'Client Services Developed Solutions' || 
                //selectedPopularCategory == 'Deposit Accounts' || 
                //selectedPopularCategory == 'Other Accounts' || 
                // selectedPopularCategory == 'Authentication & Settings' || 
                // selectedPopularCategory == ' Alerts & Communication' || 
                // selectedPopularCategory == 'Transfers' || 
                // selectedPopularCategory == 'Registration' || 
                // selectedPopularCategory == 'Customer Support' || 
                //selectedPopularCategory == 'Web/Direct Connect'
                selectedPopularCategory =='Card Management')
        {
            selectedPopularLineOfBusiness = 'Retail Banking';
        }
    }

    public List<SelectOption> getPopularCategoryValues() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('', 'Select Category'));    

        if(selectedPopularLineOfBusiness == 'Business Banking') {
            options.add(new SelectOption('General Business Banking', 'General Business Banking'));
            options.add(new SelectOption('ACH and Wires', 'ACH and Wires'));
            options.add(new SelectOption('Entitlements', 'Entitlements'));
            options.add(new SelectOption('Third Party Product Integration', 'Third Party Product Integration'));
            //options.add(new SelectOption('Deposit Accounts', 'Deposit Accounts'));
            //options.add(new SelectOption('Other Accounts', 'Other Accounts'));
            options.add(new SelectOption('Remote Deposit', 'Remote Deposit'));
             options.add(new SelectOption('Customer Support', 'Customer Support'));
             options.add(new SelectOption('Reporting', 'Reporting'));
             options.add(new SelectOption('Alerts', 'Alerts'));
             options.add(new SelectOption('Positive Pay', 'Positive Pay'));
             options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
        } else if(selectedPopularLineOfBusiness == 'Consumer Relationship') {
            options.add(new SelectOption('Promotion Suite', 'Promotion Suite'));
            options.add(new SelectOption('Web Center', 'Web Center'));
            options.add(new SelectOption('Purchase Rewards', 'Purchase Rewards'));
              options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
            //options.add(new SelectOption('Online Account Opening', 'Online Account Opening'));
           // options.add(new SelectOption('Other', 'Other'));
        } else if(selectedPopularLineOfBusiness == 'Money Movement') {
            options.add(new SelectOption('General Payments', 'General Payments'));
            options.add(new SelectOption('Bill Pay', 'Bill Pay'));
            options.add(new SelectOption('External Funds Transfer', 'External Funds Transfer'));
            //options.add(new SelectOption('Pop Money', 'Pop Money'));
            options.add(new SelectOption('Person to Person Payments', 'Person to Person Payments'));
            options.add(new SelectOption('Internal Transfers', 'Internal Transfers'));
            options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
        } else if(selectedPopularLineOfBusiness == 'Platform Solutions') {
            options.add(new SelectOption('General Admin Platform', 'General Admin Platform'));
            options.add(new SelectOption('Admin User Support', 'Admin User Support'));
            options.add(new SelectOption('Branding and Flexibility', 'Branding and Flexibility'));
            options.add(new SelectOption('Data & Reporting', 'Data & Reporting'));
            options.add(new SelectOption('SSO and API Solutions', 'SSO and API Solutions'));
            options.add(new SelectOption('Interfaces', 'Interfaces'));
            options.add(new SelectOption('Security & Authentication', 'Security & Authentication'));
            options.add(new SelectOption('Idea Exchange', 'Idea Exchange'));
            options.add(new SelectOption('Alerts & Communication', 'Alerts & Communication'));
            options.add(new SelectOption('Account Opening', 'Account Opening'));
            options.add(new SelectOption('Registration', 'Registration'));
            options.add(new SelectOption('Web/Direct Connect', 'Web/Direct Connect'));
            options.add(new SelectOption('Digital Communication - Chat, Messaging, Chatbot ', 'Digital Communication - Chat, Messaging, Chatbot '));
            options.add(new SelectOption('Online Forms', 'Online Forms'));
            options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
            // options.add(new SelectOption('End User Support', 'End User Support'));
            //options.add(new SelectOption('Admin Platform User Management and Security', 'Admin Platform User Management and Security'));
            // options.add(new SelectOption('Reporting', 'Reporting'));
            // options.add(new SelectOption('Create Your Own/SSO and API Integration', 'Create Your Own/SSO and API Integration'));
            //options.add(new SelectOption('Security', 'Security'));
            //options.add(new SelectOption('Other', 'Other'));
        } else if(selectedPopularLineOfBusiness == 'Retail Banking') {
            options.add(new SelectOption('  Alerts & Communication', '  Alerts & Communication'));
            options.add(new SelectOption('Check/Deposit Imaging', 'Check/Deposit Imaging'));
            options.add(new SelectOption('Customer Support', 'Customer Support'));
            options.add(new SelectOption('General Retail Banking', 'General Retail Banking'));
            options.add(new SelectOption('Money Management', 'Money Management'));
            options.add(new SelectOption('Online Statements', 'Online Statements'));
            options.add(new SelectOption('Remote Deposit', 'Remote Deposit'));
            options.add(new SelectOption('Shared Access', 'Shared Access'));
            options.add(new SelectOption('Card Management', 'Card Management'));
            options.add(new SelectOption('Financial Wellness', 'Financial Wellness'));
            options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
            //options.add(new SelectOption('General Digital Banking', 'General Digital Banking'));
            // options.add(new SelectOption('Deposit Accounts', 'Deposit Accounts'));
            //options.add(new SelectOption('Other Accounts', 'Other Accounts'));
            // options.add(new SelectOption('Authentication & Settings', 'Authentication & Settings'));
            // options.add(new SelectOption('Alerts', 'Alerts'));
            // options.add(new SelectOption('Transfers', 'Transfers'));
            //options.add(new SelectOption('Registration', 'Registration'));
            //options.add(new SelectOption('Web/Direct Connect', 'Web/Direct Connect'));
           options.add(new SelectOption('  User Profile Settings', '  User Profile Settings'));

        } else if (selectedPopularLineOfBusiness == 'Theme Idea') {
            options.add(new SelectOption('DI labs', 'DI labs'));
            options.add(new SelectOption('Design', 'Design'));
            options.add(new SelectOption('Events', 'Events'));
            options.add(new SelectOption('Functionality', 'Functionality'));
            options.add(new SelectOption('Industry Research', 'Industry Research'));
        }
        options.sort();
        return options;
    }

    
    public PageReference Subscribe() {

        DI_IdeaSubscription__c newVote = new DI_IdeaSubscription__c();
        newVote.DI_LineOfBusiness__c = selectedPopularLineOfBusiness;
        newVote.DI_SubscriptionCategory__c = selectedPopularCategory;
        newVote.DI_UserId__c=userinfo.getuserid();
        newVote.DI_UserName__c=userinfo.getuserid();
        insert newVote;

        PageReference gotorecord = new PageReference('/apex/NCR_Activitypage?SelectRow=Subscriptions&pge=NCR_ViewAllPage');
        //gotorecord.getParameters().put('num','Open');

        gotorecord.setRedirect(true);
        return gotorecord;
    } 



    /*
    *    @description:    pagination of replies.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  REPLIES  *****/
    public PaginateReplies paginaterReplies {get;set;}
    public  List<RepliesClass> RepliesList{get;set;}
    public  List<List<RepliesClass>> fullRepliesList{get;set;}


    public PageReference previousPageReplies(){
        this.paginaterReplies.decrementReplies();
        return changeDataReplies();
    }

    public PageReference nextPageReplies(){
        this.paginaterReplies.incrementReplies();
        return changeDataReplies();
    }

    public PageReference updatePageReplies(){
        this.paginaterReplies.updateNumbersReplies();
        return changeDataReplies();
    }

    public PageReference changeDataReplies(){
        this.RepliesList = this.fullRepliesList.get(this.paginaterReplies.indexReplies);
        return null;
    }

    public List<RepliesClass> populateDataReplies(){
        List<RepliesClass> customClassList = new List<RepliesClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        
        for(IdeaComment a : getActivityRepliesToMyIdeas()) {
            ideaIds.add(a.id);
        }

        List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        Boolean disableVoting;

        for(Vote v : vList) {
            if(v.id != null) {
                disableVoting = true;
                mapIdea.put(v.ParentId, disableVoting);
            }                
        }

        for(IdeaComment a : getActivityRepliesToMyIdeas()) {
            if(mapIdea.size() > 0) {
                customClassList.add(new RepliesClass(a.CommentBody, a.Createdby.pics__c, a.id, a.CreatorName, mapIdea.get(a.id), a.CreatedDate, a.Idea.Title, a.IdeaId, a.Idea.Di_Idea_Line_of_Business__c, a.Idea.Di_Idea_Category__c, a.Idea.Status, a.Idea.Di_Idea_Channel__c,string.valueof(a.Idea.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            } else {
                disableVoting = false;
                customClassList.add(new RepliesClass(a.CommentBody, a.Createdby.pics__c, a.id, a.CreatorName, disableVoting, a.CreatedDate, a.Idea.Title, a.IdeaId, a.Idea.Di_Idea_Line_of_Business__c, a.Idea.Di_Idea_Category__c, a.Idea.Status, a.Idea.Di_Idea_Channel__c,string.valueof(a.Idea.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            }
        }
        return customClassList;
    }

    






    /*
    *    @description:    pagination of comments.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  COMMENT  *****/
    public PaginateComment paginaterComment {get;set;}
    public  List<CommentClass> CommentList{get;set;}
    public  List<List<CommentClass>> fullCommentList{get;set;}


    public PageReference previousPageComment(){
        this.paginaterComment.decrementComment();
        return changeDataComment();
    }

    public PageReference nextPageComment(){
        this.paginaterComment.incrementComment();
        return changeDataComment();
    }

    public PageReference updatePageComment(){
        this.paginaterComment.updateNumbersComment();
        return changeDataComment();
    }

    public PageReference changeDataComment(){
        this.CommentList = this.fullCommentList.get(this.paginaterComment.indexComment);
        return null;
    }

    public List<CommentClass> populateDataComment(){
        List<CommentClass> customClassList = new List<CommentClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        
        for(IdeaComment a : getActivityComments()) {
            ideaIds.add(a.IdeaId);
        }

        List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        Boolean disableVoting;

        for(Vote v : vList) {
            if(v.id != null) {
                disableVoting = true;
                mapIdea.put(v.ParentId, disableVoting);
            }                
        }

        for(IdeaComment a : getActivityComments()) {
            if(mapIdea.size() > 0) {
                customClassList.add(new CommentClass(a.CommentBody, a.Createdby.pics__c, a.id, a.CreatorName, mapIdea.get(a.id), a.CreatedDate, a.Idea.Title, a.IdeaId, a.Idea.Di_Idea_Line_of_Business__c, a.Idea.Di_Idea_Category__c, a.Idea.Status, a.Idea.Di_Idea_Channel__c,string.valueof(a.idea.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            } else {
                disableVoting = false;
                customClassList.add(new CommentClass(a.CommentBody, a.Createdby.pics__c, a.id, a.CreatorName, disableVoting, a.CreatedDate, a.Idea.Title, a.IdeaId, a.Idea.Di_Idea_Line_of_Business__c, a.Idea.Di_Idea_Category__c, a.Idea.Status, a.Idea.Di_Idea_Channel__c,string.valueof(a.idea.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            }
        }

        return customClassList;
    }

    


    /*
    *    @description:    pagination of favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  FAVORITES  *****/
    public PaginateFavorites paginaterFavorites {get;set;}
    public List<FavoritesClass> FavoritesList{get;set;}
    public List<List<FavoritesClass>> fullFavoritesList{get;set;}


    public PageReference previousPageFavorites(){
        this.paginaterFavorites.decrementFavorites();
        return changeDataFavorites();
    }

    public PageReference nextPageFavorites(){
        this.paginaterFavorites.incrementFavorites();
        return changeDataFavorites();
    }

    public PageReference updatePageFavorites(){
        this.paginaterFavorites.updateNumbersFavorites();
        return changeDataFavorites();
    }

    public PageReference changeDataFavorites(){
        this.FavoritesList = this.fullFavoritesList.get(this.paginaterFavorites.indexFavorites);
        return null;
    }

    public List<FavoritesClass> populateDataFavorites(){
        List<FavoritesClass> customClassList = new List<FavoritesClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getActivityFavorites()) {
            ideaIds.add(a.id);
        }

        List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        Boolean disableVoting;

        for(Vote v : vList) {
            if(v.id != null) {
                disableVoting = true;
                mapIdea.put(v.ParentId, disableVoting);
            }                
        }

        for(Idea a : getActivityFavorites()) {
        if(mapIdea.size() > 0) {
            customClassList.add(new FavoritesClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.Status,String.Valueof(a.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            } else {
                disableVoting = false;
                customClassList.add(new FavoritesClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.Status,String.Valueof(a.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            }
        }
        return customClassList;
    }
    
    
    /*
    *    @description:    pagination of favorite Idea Themes.
    *    @author:         Shiv Shankar Mahla(shiv.mahla@ncr.com)
    */
    /*****  FAVORITE Idea Theme  *****/
    public PaginateIdeaTheme paginaterIdeaTheme {get;set;}
    public List<IdeaThemeInner> ideaThemeList {get;set;}
    public List<List<IdeaThemeInner>> fullIdeaThemeList {get;set;}


    public PageReference previousPageIdeaThemes(){
        this.paginaterIdeaTheme.decrement();
        return changeDataIdeaThemes();
    }

    public PageReference nextPageIdeaThemes(){
        this.paginaterIdeaTheme.increment();
        return changeDataIdeaThemes();
    }

    public PageReference updatePageIdeaThemes(){
        this.paginaterIdeaTheme.updateNumbers();
        return changeDataIdeaThemes();
    }

    public PageReference changeDataIdeaThemes(){
        this.ideaThemeList = this.fullIdeaThemeList.get(this.paginaterIdeaTheme.index);
        return null;
    }

    public List<IdeaThemeInner> populateDataIdeaThemes(){
        List<IdeaThemeInner> customClassList = new List<IdeaThemeInner>();
        Map<Id, Boolean> mapIdeaTheme = new Map<Id, Boolean>();
        Set<Id> ideaThemeIds = new Set<Id>();
        for(IdeaTheme a : getFavoriteIdeaThemes()) {
            customClassList.add(new IdeaThemeInner(a.Id, a.Title, a.Description, a.DI_Category__c, a.DI_Line_of_Business__c, a.Status, a.StartDate, a.EndDate, a.Featured_Image__c, a.DI_Co_owner__c, a.DI_Owner__c));
        }
        
        return customClassList;
    }

   

    public List<DI_IdeaSubscription__c> getSubscriptionList(){
        list<DI_IdeaSubscription__c>SubscriptionList=new list<DI_IdeaSubscription__c>();
        SubscriptionList = [SELECT Id, DI_LineOfBusiness__c, DI_SubscriptionCategory__c, DI_UserName__c FROM DI_IdeaSubscription__c WHERE DI_UserName__c =:userInfo.getuserid() ORDER BY DI_LineOfBusiness__c];

        return SubscriptionList;
    }       




    /*
    *    @description:    pagination of my team.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  MYTEAM  *****/
    public PaginateMyTeam paginaterMyTeam {get;set;}
    public List<MyTeamClass> MyTeamList{get;set;}
    public List<List<MyTeamClass>> fullMyTeamList{get;set;}


    public PageReference previousPageMyTeam(){
        this.paginaterMyTeam.decrementMyTeam();
        return changeDataMyTeam();
    }

    public PageReference nextPageMyTeam(){
        this.paginaterMyTeam.incrementMyTeam();
        return changeDataMyTeam();
    }

    public PageReference updatePageMyTeam(){
        this.paginaterMyTeam.updateNumbersMyTeam();
        return changeDataMyTeam();
    }

    public PageReference changeDataMyTeam(){
        this.MyTeamList = this.fullMyTeamList.get(this.paginaterMyTeam.indexMyTeam);
        return null;
    }

    public List<MyTeamClass> populateDataMyTeam(){
        List<MyTeamClass> customClassList = new List<MyTeamClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getActivityMyTeam()) {
            ideaIds.add(a.id);
        }

        List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        Boolean disableVoting;

        for(Vote v : vList) {
            if(v.id != null) {
                disableVoting = true;
                mapIdea.put(v.ParentId, disableVoting);
            }                
        }

        for(Idea a : getActivityMyTeam()) {
            if(mapIdea.size() > 0) {
                customClassList.add(new MyTeamClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.Status,string.valueof(a.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            } else {
                disableVoting = false;
                customClassList.add(new MyTeamClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.Status,string.valueof(a.VoteTotal), a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            }
        }
        return customClassList;
    }
    

    /** END -- for PAGINATION    **/
    /** END -- for PAGINATION    **/

    public void removeSubscription() {
        String subscriptionRecId = ApexPages.currentPage().getParameters().get('subscriptionId');
        list<DI_IdeaSubscription__c> subscription = [select Id from DI_IdeaSubscription__c where Id =: subscriptionRecId LIMIT 1];
        if (subscription.size() > 0)
            delete subscription;
    }
    
    public class MyIdeasClass{
        public String titleMyIdeas{get;set;}
        public String bodyMyIdeas{get;set;}
        public String fIMageMyIdeas {get;set;}
        public id idMyIdeas {get;set;}
        public String cNameMyIdeas {get;set;}
        public Boolean disableVoteMyIdeas {get;set;}
        public DateTime createdDateMyIdeas {get;set;}
        public String lobMyIdeas {get;set;}
        public String categoryMyIdeas {get;set;}
        public String channelMyIdeas {get;set;}
        public String statusMyIdeas {get;set;}
        public String voteTotal{get;set;}
        public String createdByTitle {get;set;}
        public String createdByProfileId {get;set;}
        public String createdByDiFiName {get;set;}

        public MyIdeasClass(String titleMyIdeas, String bodyMyIdeas, String fIMageMyIdeas, Id idMyIdeas, String cNameMyIdeas, Boolean disableVoteMyIdeas, DateTime createdDateMyIdeas, String lobMyIdeas, String categoryMyIdeas, String channelMyIdeas, String statusMyIdeas, string voteTotal, String createdByTitle, String createdByProfileId, String createdByDiFiName) {
            this.titleMyIdeas = titleMyIdeas;
            this.bodyMyIdeas = bodyMyIdeas;
            this.fIMageMyIdeas = fIMageMyIdeas;
            this.idMyIdeas = idMyIdeas; 
            this.cNameMyIdeas = cNameMyIdeas;
            this.disableVoteMyIdeas = disableVoteMyIdeas;
            this.createdDateMyIdeas = createdDateMyIdeas;
            this.lobMyIdeas = lobMyIdeas;
            this.categoryMyIdeas = categoryMyIdeas;
            this.channelMyIdeas = channelMyIdeas;
            this.statusMyIdeas = statusMyIdeas;
            this.voteTotal = voteTotal;
            this.createdByTitle = createdByTitle;
            this.createdByProfileId = createdByProfileId;
            this.createdByDiFiName = createdByDiFiName;
        }
    }

    public class RepliesClass{
        public String bodyReplies{get;set;}
        public String fIMageReplies {get;set;}
        public id idReplies {get;set;}
        public String cNameReplies {get;set;}
        public Boolean disableVoteReplies {get;set;}
        public DateTime createdDateReplies {get;set;}
        public String ideaTitleReplies{get;set;}
        public id ideaIdReplies{get;set;}
        public String lobReplies {get;set;}
        public String catReplies {get;set;}
        public String statReplies {get;set;}
        public String channelReplies {get;set;}
        public String VoteTotal {get;set;}
        public String createdByTitle {get;set;}
        public String createdByProfileId {get;set;}
        public String createdByDiFiName {get;set;}

        public RepliesClass(String bodyReplies, String fIMageReplies, Id idReplies, String cNameReplies, Boolean disableVoteReplies, DateTime createdDateReplies, String ideaTitleReplies, Id ideaIdReplies, String lobReplies, String catReplies, String statReplies, String channelReplies, String VoteTotal, String createdByTitle, String createdByProfileId, String createdByDiFiName){
            this.bodyReplies = bodyReplies;
            this.fIMageReplies = fIMageReplies;
            this.idReplies = idReplies; 
            this.cNameReplies = cNameReplies;
            this.disableVoteReplies = disableVoteReplies;
            this.createdDateReplies = createdDateReplies;
            this.ideaTitleReplies = ideaTitleReplies;
            this.ideaIdReplies = ideaIdReplies;
            this.lobReplies = lobReplies;
            this.catReplies = catReplies;
            this.statReplies = statReplies;
            this.channelReplies = channelReplies;
            this.VoteTotal = VoteTotal;
            this.createdByTitle = createdByTitle;
            this.createdByProfileId = createdByProfileId;
            this.createdByDiFiName = createdByDiFiName;
        }
    }
    
    public class CommentClass {
        public String bodyComment{get;set;}
        public String fIMageComment {get;set;}
        public id idComment {get;set;}
        public String cNameComment {get;set;}
        public Boolean disableVoteComment {get;set;}
        public DateTime createdDateComment {get;set;}
        public String ideaTitleComment{get;set;}
        public id ideaIdComment{get;set;}
        public String lobComment {get;set;}
        public String catComment {get;set;}
        public String statComment {get;set;}
        public String channelComment {get;set;}
        public String voteTotal {get;set;}
        public String createdByTitle {get;set;}
        public String createdByProfileId {get;set;}
        public String createdByDiFiName {get;set;}

        public CommentClass(String bodyComment, String fIMageComment, Id idComment, String cNameComment, Boolean disableVoteComment, DateTime createdDateComment, String ideaTitleComment, Id ideaIdComment, String lobComment, String catComment, String statComment, String channelComment,String VoteTotal, String createdByTitle, String createdByProfileId, String createdByDiFiName){
            this.bodyComment = bodyComment;
            this.fIMageComment = fIMageComment;
            this.idComment = idComment;
            this.cNameComment = cNameComment;
            this.disableVoteComment = disableVoteComment;
            this.createdDateComment = createdDateComment;
            this.ideaTitleComment = ideaTitleComment;
            this.ideaIdComment = ideaIdComment;
            this.lobComment = lobComment;
            this.catComment = catComment;
            this.statComment = statComment;
            this.channelComment = channelComment;
            this.VoteTotal = voteTotal;
            this.createdByTitle = createdByTitle;
            this.createdByProfileId = createdByProfileId;
            this.createdByDiFiName = createdByDiFiName;
        }
    }
    
    public class FavoritesClass{
        public String titleFavorites{get;set;}
        public String bodyFavorites{get;set;}
        public String fIMageFavorites {get;set;}
        public id idFavorites {get;set;}
        public String cNameFavorites {get;set;}
        public Boolean disableVoteFavorites {get;set;}
        public DateTime createdDateFavorites {get;set;}
        public String lobFavorites {get;set;}
        public String categoryFavorites {get;set;}
        public String channelFavorites {get;set;}
        public String statusFavorites {get;set;}
        public String VoteTotal{get;set;}
        public String createdByTitle {get;set;}
        public String createdByProfileId {get;set;}
        public String createdByDiFiName {get;set;}

        public FavoritesClass(String titleFavorites, String bodyFavorites, String fIMageFavorites, Id idFavorites, String cNameFavorites, Boolean disableVoteFavorites, DateTime createdDateFavorites, String lobFavorites, String categoryFavorites, String channelFavorites, String statusFavorites,String VoteTotal, String createdByTitle, String createdByProfileId, String createdByDiFiName){
            this.titleFavorites = titleFavorites;
            this.bodyFavorites = bodyFavorites;
            this.fIMageFavorites = fIMageFavorites;
            this.idFavorites = idFavorites;
            this.cNameFavorites = cNameFavorites;
            this.disableVoteFavorites = disableVoteFavorites;
            this.createdDateFavorites = createdDateFavorites;
            this.lobFavorites = lobFavorites;
            this.categoryFavorites = categoryFavorites;
            this.channelFavorites = channelFavorites;
            this.statusFavorites = statusFavorites;
            this.VoteTotal = VoteTotal;
            this.createdByTitle = createdByTitle;
            this.createdByProfileId = createdByProfileId;
            this.createdByDiFiName = createdByDiFiName;
        }
    }
    
    public class MyTeamClass{
        public String titleMyTeam{get;set;}
        public String bodyMyTeam{get;set;}
        public String fIMageMyTeam {get;set;}
        public id idMyTeam {get;set;}
        public String cNameMyTeam {get;set;}
        public Boolean disableVoteMyTeam {get;set;}
        public DateTime createdDateMyTeam {get;set;}
        public String lobMyTeam {get;set;}
        public String categoryMyTeam {get;set;}
        public String channelMyTeam {get;set;}
        public String statusMyTeam {get;set;}
        public String VoteTotal {get;set;}
        public String createdByTitle {get;set;}
        public String createdByProfileId {get;set;}
        public String createdByDiFiName {get;set;}

        public MyTeamClass(String titleMyTeam, String bodyMyTeam, String fIMageMyTeam, Id idMyTeam, String cNameMyTeam, Boolean disableVoteMyTeam, DateTime createdDateMyTeam, String lobMyTeam, String categoryMyTeam, String channelMyTeam, String statusMyTeam,String VoteTotal, String createdByTitle, String createdByProfileId, String createdByDiFiName){
            this.titleMyTeam = titleMyTeam;
            this.bodyMyTeam = bodyMyTeam;
            this.fIMageMyTeam = fIMageMyTeam;
            this.idMyTeam = idMyTeam;
            this.cNameMyTeam = cNameMyTeam;
            this.disableVoteMyTeam = disableVoteMyTeam;
            this.createdDateMyTeam = createdDateMyTeam;
            this.lobMyTeam = lobMyTeam;
            this.categoryMyTeam = categoryMyTeam;
            this.channelMyTeam = channelMyTeam;
            this.statusMyTeam = statusMyTeam;
            this.VoteTotal = VoteTotal;
            this.createdByTitle = createdByTitle;
            this.createdByProfileId = createdByProfileId;
            this.createdByDiFiName = createdByDiFiName;
        }
    }
    
    public class IdeaThemeInner {
        public String themeId {get;set;}
        public String title {get;set;}
        public String description {get;set;}
        public String category {get;set;}
        public String lineOfBusiness {get;set;}
        public String status {get;set;}
        public DateTime startDate {get;set;}
        public DateTime endDate {get;set;}
        public String featuredImage {get;set;}
        public String coOwner {get;set;}
        public String owner {get;set;}
        
        public IdeaThemeInner(Id themeId, String title, String description, String category, String lineOfBusiness, String status, DateTime startDate, DateTime endDate, String featuredImage, String coOwner, String owner) {
            this.themeId = (String) themeId;
            this.title = title;
            this.description = description;
            this.category = category;
            this.lineOfBusiness = lineOfBusiness;
            this.status = status;
            this.startDate = startDate;
            this.endDate = endDate;
            this.featuredImage = featuredImage;
            this.coOwner = coOwner;
            this.owner = owner;
        }
    }
}