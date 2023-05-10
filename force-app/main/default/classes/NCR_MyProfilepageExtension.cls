/*
*    @description:    Controller for NCR_MyProfilepage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 13, 2015
*/
public class NCR_MyProfilepageExtension {
    
    public User currentUser {get;set;}
    public User loggedinUser {get;set;}
    public String noProfileMyIdeas {get;set;}
    public String noProfileMyComments {get;set;}
    public Decimal currentUserScore {get;set;}
    public String defaultAvatar {get;set;}
    public String newUrl {get;set;}
    public String retUrl {get;set;} 
    public String retid {get;set;} 
    public boolean rendBack{get;set;}
      public String tab{get;set;}
    public String urlVal{get;set;}
    
    public NCR_MyProfilepageExtension(ApexPages.StandardController controller) {
        rendBack = false;
        //get returl
        retUrl='/apex/';
        if((ApexPages.currentPage().getParameters().get('pge') !=null)){
            retUrl = retUrl + ApexPages.currentPage().getParameters().get('pge').escapeHTML4(); 
            rendBack = true;
        }
        if((ApexPages.currentPage().getParameters().get('selectedTab') !=null)){
            retUrl = retUrl + '?SelectTab=' + ApexPages.currentPage().getParameters().get('selectedTab').escapeHTML4();            
            rendBack = true;
        }
        if((ApexPages.currentPage().getParameters().get('pNum') !=null)){
            retUrl = retUrl +'&pNum=' +ApexPages.currentPage().getParameters().get('pNum').escapeHTML4();            
        }
        
        if(ApexPages.currentPage().getParameters().get('id') != null) {
        retid=ApexPages.currentPage().getParameters().get('id');
            currentUser = [SELECT id, Name FROM User WHERE id =: ApexPages.currentPage().getParameters().get('id')];
        } else {
            currentUser = [SELECT id, Name FROM User WHERE id =: UserInfo.getUserId()];
        }
         if(Apexpages.currentPage().getUrl().contains('NCR_ViewAllPage'))
         {
            urlVal='NCR_ViewAllPage';
         }
         if(Apexpages.currentPage().getUrl().contains('NCR_Homepage'))
         {
            urlVal='NCR_Homepage';
         }
         
         if(ApexPages.currentPage().getParameters().get('selectedTab')!=null)
         {
              tab=ApexPages.currentPage().getParameters().get('selectedTab');
         }
        loggedinUser = [SELECT id, Name FROM User WHERE id =: UserInfo.getUserId()];
        
        list<IdeaReputation> irScore = [SELECT Score FROM IdeaReputation WHERE UserId =: currentUser.id LIMIT 1];
                if(!irScore.isempty()){
                currentUserScore = irScore[0].Score;
                }
                else currentUserScore=0.0;
        
        if(getProfileMyIdeas().size() > 0) {
            noProfileMyIdeas = '';
        } else {
            noProfileMyIdeas = 'No Records Found.';
        }
        if(getMyComments().size() > 0) {
            noProfileMyComments = '';
        } else {
            noProfileMyComments = 'No Records Found.';
        }
        
        //get default avatar
        SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
        defaultAvatar = sl.Link__c + sl.Name;
        
        newUrl = 'https://aplogin.digitalinsight.com';        
        
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
            system.debug('CommentList = ' + this.CommentList);
            
        /** END -- for PAGINATION  **/ 
        
        
    }
    
        
    /*
    *    @description:    get my ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Idea> getProfileMyIdeas() {
        Id currentUserId;
        if(ApexPages.currentPage().getParameters().get('id') != null) {
            currentUserId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
        }
        return[SELECT id, Title, Body, CreatedDate, CreatedBy.Name, Di_Idea_Featured_Image__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c, VoteTotal, CreatedBy.pics__c, CreatedById, Status, CreatedBy.Title, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c FROM Idea WHERE CreatedById =: currentUserId ORDER BY CreatedDate DESC];
    }
    
        
    /*
    *    @description:    get comments.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<IdeaComment> getMyComments() {       
        Id currentUserId;
        if(ApexPages.currentPage().getParameters().get('id') != null) {
            currentUserId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
        }
        
        Set<Id> IdeaList = new Set<Id>();
        for(Idea i : [select id from idea where createdbyid !=: currentUserId]) {
            IdeaList.add(i.id);
        }
        
        Set<Id> allIdeasList = new Set<Id>();
        for(Idea i : [SELECT id FROM Idea order by LastModifiedDate desc limit 1000]) {
            allIdeasList.add(i.id);
        }
        
        List<IdeaComment> icList = new List<IdeaComment>();
        icList = [SELECT id, IdeaId, CommentBody, CreatorName, CreatedBy.pics__c, 
                  Idea.Title, Idea.Di_Idea_Line_of_Business__c, Idea.Di_Idea_Category__c, Idea.Status, 
                  Idea.Di_Idea_Channel__c, Idea.VoteTotal, CreatedById, CreatedDate, CreatedBy.Title, 
                  CreatedBy.ProfileId,CreatedBy.DI_Fi_Name__c  FROM 
                  IdeaComment WHERE CreatedById =: currentUserId AND IdeaId IN: allIdeasList ];
        return icList;
    }
    public List <Idea> getProfileComments() {
        List <idea> IdeaList    =   new List <idea> ();
        List <id> IdeaidList    =   new List <id> ();
        List <id> IdeaidList2    =   new List <id> ();
        List <IdeaComment> MyIdeaCommentList = new List <IdeaComment> ();
                
        Id currentUserId;
        if(ApexPages.currentPage().getParameters().get('id') != null) {
            currentUserId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
        }
        
        IdeaList = [select id from idea where createdbyid !=: currentUserId];
        
        for( Idea i : IdeaList) {
            IdeaidList2.add(i.id);
        }
        
        MyIdeaCommentList = [SELECT id , IdeaId FROM IdeaComment WHERE  createdbyid =: currentUserId AND IdeaId IN : IdeaidList2]  ;
        for(IdeaComment ic : MyIdeaCommentList) {
            IdeaidList.add(ic.IdeaId);
        }
        return[SELECT  id, Title, Body, CreatedDate, CreatedBy.Name, Di_Idea_Featured_Image__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c, VoteTotal, CreatedBy.pics__c, CreatedById, Status FROM Idea WHERE id IN : IdeaidList];
    }
    
    
    
    /** START -- for PAGINATION    **/    
    /*
    *    @description:    pagination for comments.
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
            for(Idea a : getProfileComments()) {
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
        
            Boolean isFavorite;
            Map<id, Boolean> mapFavorite = new Map<Id, Boolean>();
            List<Di_Idea_Favorites__c> faveList = [SELECT id, Di_Idea__c FROM Di_Idea_Favorites__c WHERE Di_Idea__c IN: ideaIds AND User__c =: UserInfo.getUserId()];
            if(faveList.size() > 0) {
                for(Di_Idea_Favorites__c fave : faveList) {
                    isFavorite = true;
                    mapFavorite.put(fave.Di_Idea__c, isFavorite);
                }
            }
            
            for(IdeaComment a : getMyComments()) {
                customClassList.add(new CommentClass(a.Idea.Title, a.CommentBody, a.Createdby.pics__c, a.IdeaId, a.CreatorName, false, a.CreatedDate, a.Idea.Di_Idea_Line_of_Business__c, a.Idea.Di_Idea_Category__c, a.Idea.Di_Idea_Channel__c, a.Idea.VoteTotal, false, a.CreatedById, a.Idea.Status, a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
            }
            
            
            /*
            for(Idea a : getProfileComments()) {
                if(mapFavorite.size() > 0) {
                    if(mapIdea.size() > 0) {
                        customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id), a.CreatedById, a.Status));
                    } else {
                        disableVoting = false;
                        customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id), a.CreatedById, a.Status));
                    }
                } else {
                    isFavorite = false;
                    if(mapIdea.size() > 0) {
                        customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, isFavorite, a.CreatedById, a.Status));
                    } else {
                        disableVoting = false;
                        customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, isFavorite, a.CreatedById, a.Status));
                    }
                }*/
                
                /*
                if(mapIdea.size() > 0) {
                    customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal));
                } else {
                    disableVoting = false;
                    customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, disableVoting, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal));
                }*/
            //}
            return customClassList;
        }
         
        public class CommentClass{
            public String titleComment{get;set;}
            public String bodyComment{get;set;}
            public String fIMageComment {get;set;}
            public id idComment {get;set;}
            public String cNameComment {get;set;}
            public Boolean disableVoteComment {get;set;}
            public DateTime createdDateComment {get;set;}
            public String lobComment {get;set;}
            public String categoryComment {get;set;}
            public String channelComment {get;set;}
            public Decimal totalVoteComment {get;set;}
            public Boolean isFaveComment {get;set;}
            public Id createdByIdComment {get;set;}
            public String statusComment {get;set;}
            public String createdByTitleComment {get;set;}
            public String createdByProIdComment {get;set;}
            public String createdByFiNameComment {get;set;}
             
            public CommentClass(String titleComment, String bodyComment, String fIMageComment, Id idComment, String cNameComment, Boolean disableVoteComment, DateTime createdDateComment, String lobComment, String categoryComment, String channelComment, Decimal totalVoteComment, Boolean isFaveComment, Id createdByIdComment, String statusComment, String createdByTitleComment, String createdByProIdComment , String createdByFiNameComment) {
                this.titleComment = titleComment;
                this.bodyComment = bodyComment;
                this.fIMageComment = fIMageComment;
                this.idComment = idComment;
                this.cNameComment = cNameComment;
                this.disableVoteComment = disableVoteComment;
                this.createdDateComment = createdDateComment;
                this.lobComment = lobComment;
                this.categoryComment = categoryComment;
                this.channelComment = channelComment;
                this.totalVoteComment = totalVoteComment;
                this.isFaveComment = isFaveComment;
                this.createdByIdComment = createdByIdComment;
                this.statusComment = statusComment;
                this.createdByTitleComment = createdByTitleComment ;
                this.createdByProIdComment = createdByProIdComment ;
                this.createdByFiNameComment = createdByFiNameComment ;
            }
        }    
        
        
        
            
    /*
    *    @description:    pagination for my ideas.
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
            for(Idea a : getProfileMyIdeas()) {
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
        
            Boolean isFavorite;
            Map<id, Boolean> mapFavorite = new Map<Id, Boolean>();
            List<Di_Idea_Favorites__c> faveList = [SELECT id, Di_Idea__c FROM Di_Idea_Favorites__c WHERE Di_Idea__c IN: ideaIds AND User__c =: UserInfo.getUserId()];
            if(faveList.size() > 0) {
                for(Di_Idea_Favorites__c fave : faveList) {
                    isFavorite = true;
                    mapFavorite.put(fave.Di_Idea__c, isFavorite);
                }
            }
            
            for(Idea a : getProfileMyIdeas()) {
                if(mapFavorite.size() > 0) {
                    if(mapIdea.size() > 0) {
                        customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id), a.CreatedById, a.Status,a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
                    } else {
                        disableVoting = false;
                        customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id), a.CreatedById, a.Status, a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
                    }
                } else {
                    isFavorite = false;
                    if(mapIdea.size() > 0) {
                        customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, isFavorite, a.CreatedById, a.Status, a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
                    } else {
                        disableVoting = false;
                        customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, isFavorite, a.CreatedById, a.Status, a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c));
                    }
                }
                
                /*
                if(mapIdea.size() > 0) {
                    customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id)));
                } else {
                    disableVoting = false;
                    customClassList.add(new MyIdeasClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, disableVoting, a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal));
                }*/
            }
            return customClassList;
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
            public Decimal totalVoteMyIdeas {get;set;}
            public Boolean isFaveMyIdeas {get;set;}
            public Id createdByIdMyIdeas {get;set;}
            public String statusMyIdeas {get;set;}
            public String createdByTitle {get;set;}
            public String createdByProId {get;set;}
            public String createdByFiName {get;set;}
             
            public MyIdeasClass(String titleMyIdeas, String bodyMyIdeas, String fIMageMyIdeas, Id idMyIdeas, String cNameMyIdeas, Boolean disableVoteMyIdeas, DateTime createdDateMyIdeas, String lobMyIdeas, String categoryMyIdeas, String channelMyIdeas, Decimal totalVoteMyIdeas, Boolean isFaveMyIdeas, Id createdByIdMyIdeas, String statusMyIdeas, String createdByTitle, String createdByProId , String createdByFiName){
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
                this.totalVoteMyIdeas = totalVoteMyIdeas;
                this.isFaveMyIdeas = isFaveMyIdeas;
                this.createdByIdMyIdeas = createdByIdMyIdeas;
                this.statusMyIdeas = statusMyIdeas;
                this.createdByTitle = createdByTitle ;
                this.createdByProId = createdByProId ;
                this.createdByFiName = createdByFiName ;
            }
        }    
    /** END -- for PAGINATION    **/
        
    /*
    *    @description:    action for adding idea to favorites from the my ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id MyIdeasIdeaId {get;set;}
    public pageReference insertToMyFavoritesMyIdeas() {     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = MyIdeasIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_MyProfilePage?id=' + currentUser.id);
        gotorecord.setRedirect(true);
        return gotorecord;
    }
        
    /*
    *    @description:    action for deleting idea to recent.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavoritesMyIdeas() {
        Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: MyIdeasIdeaId AND User__c =: UserInfo.getUserId() LIMIT 1];
        delete deleteFave;

        PageReference gotorecord = new PageReference('/apex/NCR_MyProfilePage?id=' + currentUser.id);
        gotorecord.setRedirect(true);
        return gotorecord;
    }
        
    /*
    *    @description:    action for adding idea to favorites from the comments.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id CommentIdeaId {get;set;}
    public pageReference insertToMyFavoritesComment() {     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = CommentIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_MyProfilePage');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    /*
    *    @description:    set line of business value recent.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String selectedCategory {get;set;}
    public pageReference gotoSetLOBAllIdeas() {
        String addToURL;
        if(selectedCategory == 'General Business Banking' || 
            selectedCategory == 'ACH and Wires' || 
            selectedCategory == 'Entitlements' || 
            selectedCategory == 'Third Party Product Integration' || 
            selectedCategory == 'Deposit Accounts' || 
            selectedCategory == 'Other Accounts') {
                addToURL = '&lob=Business%20Banking';
        } else if(selectedCategory == 'Promotion Suite' || 
                    selectedCategory == 'Web Center' || 
                    selectedCategory == 'Purchase Rewards' || 
                    selectedCategory == 'Online Account Opening' || 
                    selectedCategory == 'Other') {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(selectedCategory == 'General Payments' || 
                    selectedCategory == 'Bill Pay' || 
                    selectedCategory == 'External Funds Transfer' || 
                    selectedCategory == 'Pop Money') {
                addToURL = '&lob=Money%20Movement';
        } else if(selectedCategory == 'General Admin Platform' || 
                    selectedCategory == 'End User Support' || 
                    selectedCategory == 'Branding and Flexibility' || 
                    selectedCategory == 'Admin Platform User Management and Security' || 
                    selectedCategory == 'Reporting' || 
                    selectedCategory == 'Create Your Own/SSO and API Integration' || 
                    selectedCategory == 'Interfaces' || 
                    selectedCategory == 'Security' || 
                    selectedCategory == 'Other' || 
                    selectedCategory == 'Idea Exchange') {
                addToURL = '&lob=Platform%20Solutions';
        } else if(selectedCategory == 'General Digital Banking' || 
                    selectedCategory == 'Deposit Accounts' || 
                    selectedCategory == 'Other Accounts' || 
                    selectedCategory == 'Authentication & Settings' || 
                    selectedCategory == 'FinanceWorks' || 
                    selectedCategory == 'Alerts' || 
                    selectedCategory == 'Transfers' || 
                    selectedCategory == 'Online Statements' || 
                    selectedCategory == 'Registration' || 
                    selectedCategory == 'Shared Access' || 
                    selectedCategory == 'Remote Deposit' || 
                    selectedCategory == 'Customer Support' || 
                    selectedCategory == 'Web/Direct Connect' || 
                    selectedCategory == 'Check/Deposit Imaging') {
                addToURL = '&lob=Retail%20Banking';
        } else {
            addToURL = '';
        }
        
        String selectedTab;
        if(ApexPages.currentPage().getParameters().get('selectTab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('selectTab');
        } else {
            selectedTab = 'AllIdeas';
        }
    
        if(selectedCategory == 'Authentication & Settings') {
            String categoryReplacement = 'Authentication and Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + selectedCategory + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }
    
}