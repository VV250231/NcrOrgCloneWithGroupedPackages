/*
*    @description:    Controller for NCR_HomePageSidebar component.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 13, 2015
*/
public class NCR_HomePageSidebarController {
    /** START -- for HomePageSidebar    **/    
    public Integer myIdeasCount {get;set;}          //render total number of my ideas
    public Integer myReplies {get;set;}             //render total number of my replies
    public Integer myFavoritesCount {get;set;}      //render total number of my favorites
    public Integer mycommentsCount {get;set;}       //render total number of my comments
    public Integer myTeamCount {get;set;}           //render total number of my team
    public String defaultAvatar {get;set;}          //render default avatar from admin platform
    public String newUrl {get;set;}
    public Integer SubscriptionCount {get;set;}
    public String urlVal {get;set;}
    public String Tab{get;set;}
      /** END -- for HomePageSidebar  **/
    
    public NCR_HomePageSidebarController() {
        
         
         if(!(Apexpages.currentPage().getUrl().contains('NCR_Homepage')))
         {
            urlVal='NCR_ViewAllPage';
            if((ApexPages.currentPage().getParameters().get('selectTab') !=null)){
            Tab= ApexPages.currentPage().getParameters().get('selectTab');            
          }
         }
         if(Apexpages.currentPage().getUrl().contains('NCR_Homepage'))
         {
            urlVal='NCR_Homepage';
         }
        /** START -- for HomePageSidebar    **/
        if(getCountIdeasList() > 0) { myIdeasCount = getCountIdeasList(); } else { myIdeasCount = 0; }
        if(getCountRepliesList() > 0) { myReplies = getCountRepliesList(); } else { myReplies = 0; }
        if(getCountFavoritesList() > 0) { myFavoritesCount = getCountFavoritesList(); } else { myFavoritesCount = 0; }
        if(getCountCommentsList() > 0) { mycommentsCount = getCountCommentsList(); } else { mycommentsCount = 0; }
        if(getCountTeamList() > 0) { myTeamCount = getCountTeamList(); } else { myTeamCount = 0; }
        if(getSubscriptionCount() > 0) { SubscriptionCount = getSubscriptionCount(); } else { SubscriptionCount = 0; }
        
        //get default avatar
        SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
        defaultAvatar = sl.Link__c + sl.Name;
        
        newUrl = 'https://aplogin.digitalinsight.com';
        /** END -- for HomePageSidebar  **/
    }
    
    /** START -- for HomePageSidebar    **/ 
    /*
    *    @description:    get count of my ideas.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public Integer getCountIdeasList() {
        List<IdeaReputation> myIdeaReputation = new List<IdeaReputation>();
        myIdeaReputation = [SELECT IdeaCount FROM IdeaReputation WHERE UserId =: UserInfo.getUserId() AND Context.name = 'IdeaExchange' LIMIT 1];
        Integer myIdeasTotal;
        if(myIdeaReputation.size() > 0) {
            myIdeasTotal = myIdeaReputation[0].IdeaCount;
        }
        return myIdeasTotal;
    }
     
    /*
    *    @description:    get count of my replies.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public Integer getCountRepliesList() {
        /*IdeaReputation myIdeaReputation = new IdeaReputation();
        myIdeaReputation = [SELECT CommentsReceivedCount FROM IdeaReputation WHERE UserId =: UserInfo.getUserId() AND Context.name = 'IdeaExchange' LIMIT 1];
        Integer myRepliesTotal = myIdeaReputation.CommentsReceivedCount;
        return myRepliesTotal;*/
        List <idea> MyIdeaList    =   new List <idea> ();
        List <id> MyIdeaidList    =   new List <id> ();
        List <id> MyIdeaidList2    =   new List <id> ();
        MyIdeaList =  [SELECT  id , title FROM Idea WHERE createdbyId =: UserInfo.getUserId()] ;
        for(idea i : MyIdeaList) {
            MyIdeaidList.add(i.id);
        }
        List <IdeaComment> MyIdeaCommentList    =   new List <IdeaComment> ();
        MyIdeaCommentList = [SELECT id , IdeaId FROM IdeaComment WHERE  IdeaId IN : MyIdeaIdList ];
        //for(IdeaComment ic : MyIdeaCommentList) {
        //    MyIdeaidList2.add(ic.IdeaId);
        //}
        return [SELECT count() FROM IdeaComment WHERE  IdeaId IN : MyIdeaIdList];
    }
     
    /*
    *    @description:    get count of my favorites.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public Integer getCountFavoritesList() {
        List<Di_Idea_Favorites__c> ideaFavoritesList = [select id , Di_Idea__c , Di_Idea__r.title, User__c from Di_Idea_Favorites__c where User__c =: UserInfo.getUserId()];
        /*
        List<Id> newListOfIdeas = new List<Id>();
        
        for(Di_Idea_Favorites__c fave : ideaFavoritesList) {
            newListOfIdeas.add(fave.Di_Idea__c);
        }
        
        return[SELECT count() FROM Idea WHERE id IN: newListOfIdeas];
        */
        return ideaFavoritesList.size();
    }
     
    /*
    *    @description:    get count of my comments.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public Integer getCountCommentsList() {
        List<IdeaReputation> myIdeaReputation = new List<IdeaReputation>();
        myIdeaReputation = [SELECT CommentCount FROM IdeaReputation WHERE UserId =: UserInfo.getUserId() AND Context.name = 'IdeaExchange' LIMIT 1];
        if(myIdeaReputation.size() > 0) {
            Integer myCommentsTotal = myIdeaReputation[0].CommentCount;
            return myCommentsTotal;
        } else {
            return 0;
        }
    }
  public Integer getSubscriptionCount() {
      Integer count;
      List<aggregateResult> results=[select count(id),DI_LineOfBusiness__c,DI_SubscriptionCategory__c,DI_UserName__c  from DI_IdeaSubscription__c where  DI_UserName__c=:userInfo.getuserid() group by DI_LineOfBusiness__c,DI_SubscriptionCategory__c,DI_UserName__c];
      
      List<DI_Idea_Exchange_Daily_Digest__c> subscribers = [SELECT DI_User__c, DI_Subscribe_for_daily_digest__c,DI_New_Theme_Alert__c FROM DI_Idea_Exchange_Daily_Digest__c WHERE DI_User__c =: UserInfo.getUserId() LIMIT 1];
      
      count = results.size();
      if (subscribers.size() > 0) {
          if (subscribers[0].DI_Subscribe_for_daily_digest__c == true)
              count+=1;
          if (subscribers[0].DI_New_Theme_Alert__c == true)
              count+=1;
      }
            
      return count;
    }
 
    /*
    *    @description:    get count of my team.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public Integer getCountTeamList() {
        Integer Count=0;
        if (Userinfo.getUserType()=='Standard') {   
            User usr = new User();
            usr = [select managerid from user where id =: userInfo.getUserId()] ;
            Map <id,User> Members = new Map <id,User> ([select id from user where managerid =: usr.managerid]);
            List <IdeaReputation> MyTeam = new List <IdeaReputation> ();
            MyTeam = [SELECT UserId , IdeaCount FROM IdeaReputation WHERE UserId IN : Members.keySet() AND Context.name = 'IdeaExchange' ];
                for(IdeaReputation i : MyTeam) {
                    Count += i.IdeaCount;
                }
        } else if (Userinfo.getUserType()!='Standard') {
            List <User> Members = [select AccountId from user where id =: userInfo.getUserId()];
            List <Id> accid = new List<id>();
                for(User u : Members) {
                    accid.add(u.Accountid);
                }
            List <IdeaReputation> MyTeam = [SELECT UserId , IdeaCount FROM IdeaReputation WHERE User.Accountid IN : accid AND Context.name = 'IdeaExchange' ];
                for(IdeaReputation i : MyTeam) {
                    Count += i.IdeaCount;
                }
        }        
        return count;
    }
     
    /*
    *    @description:    get the top collaborator's name and points.
    *    @author:         Abhishek Srivastava(Abhishek.Srivastava2@ncr.com)
    */
    public List<IdeaReputation> getTopCollaborators() {
        return[SELECT ReputationLevel , Score ,  UserId , User.name, User.SmallPhotoURL, User.pics__c, CommentCount , CommentsReceivedCount , IdeaCount  , User.Di_Account__c FROM IdeaReputation WHERE Context.name = 'IdeaExchange' AND User.Profile.Name = '61 DI Community Members'and User.Di_Account__c != '04423' order by Score desc limit 6];
    }
    /** END -- for HomePageSidebar  **/
    
    /*
     * show top 7 recently created Idea Theme*
     * */
    public List<IdeaTheme> ideaThemes = new List<IdeaTheme>();
    
    public List<IdeaTheme> getThemes() {
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        if (netWorks.size() > 0) {
            List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
            if(zones.size() > 0) {
                ideaThemes = [SELECT Id, Title, Featured_Image__c, Status, CommunityId FROM IdeaTheme WHERE CommunityId =: zones[0].Id AND Status = 'Accepting Ideas' ORDER BY CreatedDate DESC LIMIT 7];
            }
        }
        return ideaThemes;
    }
    
}