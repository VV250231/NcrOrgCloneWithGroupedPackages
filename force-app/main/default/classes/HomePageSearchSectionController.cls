/*
*    @description:    Controller for NCR_HomePageSearchSection component.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 13, 2015
*/
public class HomePageSearchSectionController {

    /** START -- for HomePageSearchSection  **/
    public String SearchItem {get;set;}             //render entered text on searchbox
    public String noSearchResults {get;set;}        //render error message when there are no results
    public Boolean showResults {get;set;}           //render Search Results section show/hide option
    public List<Idea> SearchIdeas {get;set;}        //render result of searched ideas
    public User currentUser {get;set;}              //render current user id
    /** END -- for HomePageSearchSection    **/
    
    public HomePageSearchSectionController() {
        /** START -- for HomePageSearchSection  **/
        showResults = false;
        noSearchResults = '';
        currentUser = [SELECT id, Name FROM User WHERE id =: UserInfo.getUserId()];
        loadPaginationSearchResult();
        /** END -- for HomePageSearchSection    **/ 
    }
    
    
    
       
    /** START -- for HomePageSearchSection  **/    
    /*
    *    @description:    action for search button.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference doSearch() {
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?searchItemVal=' + SearchItem + '&selectTab=AllIdeas');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    /*
    public void doSearch() {
        showResults = true;
        SearchIdeas = new List<Idea>();
        //getSearchedIdeasList();
        
       if(SearchItem.length() > 0){
           String searchStr1 = '*'+SearchItem+'*';
           String searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING  Idea (id, Body, Title, CreatedById, CreatedBy.Name, Di_Idea_Featured_Image__c, VoteTotal, Di_Idea_Line_of_Business__c, Di_Idea_Channel__c, Di_Idea_Category__c, CreatedDate, CreatedBy.SmallPhotoURL,  Status)';
           List<List <sObject>> searchList = search.query(searchQuery);
           SearchIdeas = ((List<Idea>)searchList[0]);
           populateDataSearchResult();
           loadPaginationSearchResult();
           system.debug('***SearchResultList = ' + SearchResultList);
           
           if(SearchIdeas.size() == 0){
               noSearchResults = 'Sorry, no results returned with matching string.';
               //apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, no results returned with matching string.'));
               return;
           } else {
               noSearchResults = '';
           }
           
       }
           populateDataSearchResult();
           loadPaginationSearchResult();
           system.debug('***paginaterSearchResult.totalPageSearchResult = ' + paginaterSearchResult.totalPageSearchResult);
    }*/
    
    /*
    *    @description:    action for the post idea button.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public PageReference PostNewIdea() {
        PageReference gotorecord = new PageReference('/apex/NCR_PostIdeapage2');
        gotorecord.setRedirect(true);
        return gotorecord;
    }
     
    /*
    *    @description:    load SearchResult pagination.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadPaginationSearchResult() {
        //Get the data we need to paginate
        List<SearchResultClass> resultsListSearchResult = populateDataSearchResult();
         
        //Set the page size
        Integer pageSizeSearchResult = 5;
         
        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginaterSearchResult = new PaginateSearchResult(resultsListSearchResult.size(), pageSizeSearchResult);
 
        //These lists hold the data
        this.fullSearchResultList = new List<List<SearchResultClass>>();
        this.SearchResultList = new List<SearchResultClass>();
         
        //Break out the full list into a list of lists
        if(resultsListSearchResult.size() > 0){
            List<SearchResultClass> tempcc = new List<SearchResultClass>();        
            Integer i = 0;
            for(SearchResultClass cc : resultsListSearchResult){
                tempcc.add(cc);
                i++;
                if(i == pageSizeSearchResult){
                    this.fullSearchResultList.add(tempcc);
                    tempcc = new List<SearchResultClass>();
                    i = 0;
                }
            }
            if(!tempcc.isEmpty()){
                this.fullSearchResultList.add(tempcc);
            }
             
            //Gets the correct list of data to show on the page
            this.SearchResultList = this.fullSearchResultList.get(this.paginaterSearchResult.indexSearchResult);
        }
    }  
    /** END -- for HomePageSearchSection    **/
    
    public List<Idea> getSearchedIdeasList() {
        return[SELECT id, Title, Body, CreatedDate, CreatedBy.Name, Di_Idea_Featured_Image__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c, VoteTotal, CreatedBy.SmallPhotoUrl, CreatedById, Status FROM Idea WHERE Title LIKE : '%' + SearchItem + '%'];
    }
    
    /** START -- for PAGINATION    **/
    /*
    *    @description:    pagination for the search results.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */       
        /*****  Search Results  *****/
        public PaginateSearchResult paginaterSearchResult {get;set;}
        public List<SearchResultClass> SearchResultList{get;set;}
        public List<List<SearchResultClass>> fullSearchResultList{get;set;}
        
        
        public PageReference previousPageSearchResult(){
            this.paginaterSearchResult.decrementSearchResult();
            return changeDataSearchResult();
        }
         
        public PageReference nextPageSearchResult(){
            this.paginaterSearchResult.incrementSearchResult();
            return changeDataSearchResult();
        }
     
        public PageReference updatePageSearchResult(){
            this.paginaterSearchResult.updateNumbersSearchResult();
            return changeDataSearchResult();
        }
         
        public PageReference changeDataSearchResult(){
            this.SearchResultList = this.fullSearchResultList.get(this.paginaterSearchResult.indexSearchResult);
            return null;
        }
        
        public List<Idea> getsampleideas() {
            return[SELECT id, Title, Body, CreatedDate, CreatedBy.Name, Di_Idea_Featured_Image__c, Di_Idea_Line_of_Business__c, Di_Idea_Category__c, Di_Idea_Channel__c, VoteTotal, CreatedBy.SmallPhotoURL, CreatedById, Status from idea];
        }
         
        public List<SearchResultClass> populateDataSearchResult(){
            List<SearchResultClass> customClassList = new List<SearchResultClass>();
            Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
            Set<Id> ideaIds = new Set<Id>();
            
            if(SearchItem != null) {
                for(Idea a : SearchIdeas) {
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
                
                for(Idea a : SearchIdeas) {
                    if(mapFavorite.size() > 0) {
                        if(mapIdea.size() > 0) {
                            customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id), a.CreatedById, a.Status));
                        } else {
                            disableVoting = false;
                            customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, mapFavorite.get(a.id), a.CreatedById, a.Status));
                        }
                    } else {
                        isFavorite = false;
                        if(mapIdea.size() > 0) {
                            customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, isFavorite, a.CreatedById, a.Status));
                        } else {
                            disableVoting = false;
                            customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.SmallPhotoURL, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.CreatedDate, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Di_Idea_Channel__c, a.VoteTotal, isFavorite, a.CreatedById, a.Status));
                        }
                    }
                }
            } 
            return customClassList;
        }
         
        public class SearchResultClass{
            public String titleSearchResult{get;set;}
            public String bodySearchResult{get;set;}
            public String fIMageSearchResult {get;set;}
            public id idSearchResult {get;set;}
            public String cNameSearchResult {get;set;}
            public Boolean disableVoteSearchResult {get;set;}
            public DateTime createdDateSearchResult {get;set;}
            public String lobSearchResult {get;set;}
            public String categorySearchResult {get;set;}
            public String channelSearchResult {get;set;}
            public Decimal totalVoteSearchResult {get;set;}
            public Boolean isFaveSearchResult {get;set;}
            public Id createdByIdSearchResult {get;set;}
            public String statusSearchResult {get;set;}
             
            public SearchResultClass(String titleSearchResult, String bodySearchResult, String fIMageSearchResult, Id idSearchResult, String cNameSearchResult, Boolean disableVoteSearchResult, DateTime createdDateSearchResult, String lobSearchResult, String categorySearchResult, String channelSearchResult, Decimal totalVoteSearchResult, Boolean isFaveSearchResult, Id createdByIdSearchResult, String statusSearchResult){
                this.titleSearchResult = titleSearchResult;
                this.bodySearchResult = bodySearchResult;
                this.fIMageSearchResult = fIMageSearchResult;
                this.idSearchResult = idSearchResult;
                this.cNameSearchResult = cNameSearchResult;
                this.disableVoteSearchResult = disableVoteSearchResult;
                this.createdDateSearchResult = createdDateSearchResult;
                this.lobSearchResult = lobSearchResult;
                this.categorySearchResult = categorySearchResult;
                this.channelSearchResult = channelSearchResult;
                this.totalVoteSearchResult = totalVoteSearchResult;
                this.isFaveSearchResult = isFaveSearchResult;
                this.createdByIdSearchResult = createdByIdSearchResult;
                this.statusSearchResult = statusSearchResult;
            }
        }    
            
        /*
        *    @description:    action for adding idea to favorites from the SearchResults.
        *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
        */
        public Id SearchResultIdeaId {get;set;}
        public pageReference insertToMyFavoritesSearchResult() {     
            Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
            fvr.Di_Idea__c = SearchResultIdeaId;
            fvr.User__c = UserInfo.getUserId();
            insert fvr;
            
            PageReference gotorecord = new PageReference('/apex/NCR_MyProfilePage');
            gotorecord.setRedirect(true);
            return gotorecord;
        }
        /*
        *    @description:    action for delete idea functionality for SearchResults.
        *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
        */
        Idea deleteIdeaIdSearchResult;
        public pageReference deleteFavoritesSearchResult() {
            deleteIdeaIdSearchResult = [SELECT id FROM Idea WHERE id =: SearchResultIdeaId];
            delete deleteIdeaIdSearchResult;
            PageReference gotorecord = new PageReference('/apex/NCR_HomePage');
            gotorecord.setRedirect(true);
            return gotorecord;
            //return null;
        }
    /** END -- for PAGINATION    **/
}