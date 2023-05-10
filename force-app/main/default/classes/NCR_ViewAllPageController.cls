/*
*    @description:    Controller for NCR_ViewAllPage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 13, 2015
*/
public class NCR_ViewAllPageController {
    /*** NOTE: Comment == All Ideas ***/
    
    /** START -- for ViewAllPage    **/ 
    //selected filters
    public String selectedRecentLineOfBusiness {get;set;}   //render selected line of business for recent 
    public String selectedRecentCategory {get;set;}         //render selected category for recent  
    public String selectedRecentIdeaStatus {get;set;}       //render selected idea status for recent
    public String selectedPopularLineOfBusiness {get;set;}  //render selected line of business for Popular 
    public String selectedPopularCategory {get;set;}        //render selected category for Popular  
    public String selectedPopularIdeaStatus {get;set;}      //render selected idea status for Popular
    public String selectedTopAllTimeLineOfBusiness {get;set;}   //render selected line of business for TopAllTime 
    public String selectedTopAllTimeCategory {get;set;}         //render selected category for TopAllTime  
    public String selectedTopAllTimeIdeaStatus {get;set;}       //render selected idea status for TopAllTime
    public String selectedAllTimeLineOfBusiness {get;set;}  //render selected line of business for AllTime 
    public String selectedAllTimeCategory {get;set;}        //render selected category for AllTime  
    public String selectedAllTimeIdeaStatus {get;set;}      //render selected idea status for AllTime
    public String selectedCommentLineOfBusiness {get;set;}  //render selected line of business for Comment 
    public String selectedCommentCategory {get;set;}        //render selected category for Comment  
    public String selectedCommentIdeaStatus {get;set;}      //render selected idea status for Comment
    public String selectedSearchResultCategory {get;set;}        //render selected category for SearchResult  
    //error messages
    public String noRecentIdeasView {get;set;}              //render error message when there are no recent ideas on ViewAllPage
    public String noPopularIdeasView {get;set;}             //render error message when there are no popular ideas on ViewAllPage
    public String noTopAllTimeIdeasView {get;set;}              //render error message when there are no TopAllTime ideas on ViewAllPage
    public String noCommentIdeasView {get;set;}             //render error message when there are no comments on ViewAllPage 
    public String noSearchResultIdeasView {get;set;}        //render error message when there are no search results ideas on ViewAllPage
     public Boolean SubscriberCheck {get;set;}
     public Boolean SubscriberCheckrecent {get;set;}
     public Boolean SubscriberCheckTop {get;set;}
     public Boolean SubscriberCheckAllIdeas {get;set;}
     
     
     
     public Boolean ShowSubscription {get;set;}
    public Boolean ShowSubscription1 {get;set;}
    public Boolean ShowSubscriptionrecent {get;set;}
    public Boolean ShowSubscription1recent {get;set;}
    public Boolean ShowSubscriptionTop {get;set;}
    public Boolean ShowSubscription1Top {get;set;}
    public Boolean ShowSubscriptionAllIdeas {get;set;}
    public Boolean ShowSubscription1AllIdeas {get;set;}
       
                
    public String selectedTab {get;set;}                    //render selected tab
    public String searchItemValue {get;set;}                //render searched value
    public String defaultAvatar {get;set;}                  //render default avatar from admin platform
    public User currentUser {get;set;}                      //render current user
    public Boolean isValChanged {get;set;}                  //render if filters are changed
    public Boolean showSearchResults {get;set;}                  //render if there are searchresults
    public String newUrl {get;set;}
    public Integer pNum {get;set;}
    public string Num2{get;set;}
    /** END -- for ViewAllPage  **/ 
    
    public NCR_ViewAllPageController() {
        isValChanged = false;   //filters aren't changed on load
        currentUser = [SELECT id FROM User WHERE id =: UserInfo.getUserId()];   //get current user
        selectedTab = ApexPages.currentPage().getParameters().get('selectTab'); //set selectedTab
        
        newUrl = 'https://aplogin.digitalinsight.com';
       if((ApexPages.currentPage().getParameters().get('pNum') !=null && ApexPages.currentPage().getParameters().get('pNum') !='')){
             pNum = Integer.valueof(ApexPages.currentPage().getParameters().get('pNum'));            
        }
         if(selectedTab=='Popular'){
             if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && string.isblank(ApexPages.currentPage().getParameters().get('num')) && string.isblank(ApexPages.currentPage().getParameters().get('line')) ){
                 ShowSubscription1=true;            
            }
            if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && !string.isblank(ApexPages.currentPage().getParameters().get('num')) ){
                 ShowSubscription=true;   
                ShowSubscription1=false;             
            }
         }
         if(selectedTab=='Recent'){
             if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && string.isblank(ApexPages.currentPage().getParameters().get('num')) && string.isblank(ApexPages.currentPage().getParameters().get('line')) ){
                 ShowSubscription1recent=true;            
            }
            if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && !string.isblank(ApexPages.currentPage().getParameters().get('num')) ){
                 ShowSubscriptionrecent=true;   
                ShowSubscription1recent=false;           
            }
         }
          if(selectedTab=='TopAllTime'){
             if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && string.isblank(ApexPages.currentPage().getParameters().get('num')) && string.isblank(ApexPages.currentPage().getParameters().get('line')) ){
                 ShowSubscription1Top=true;            
            }
            if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && !string.isblank(ApexPages.currentPage().getParameters().get('num')) ){
                 ShowSubscriptionTop=true;   
                ShowSubscription1Top=false;           
            }
         }
         if(selectedTab=='AllIdeas'){
             if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && string.isblank(ApexPages.currentPage().getParameters().get('num')) && string.isblank(ApexPages.currentPage().getParameters().get('line')) ){
                 ShowSubscription1AllIdeas=true;            
            }
            if(!string.isblank(ApexPages.currentPage().getParameters().get('Cat')) && !string.isblank(ApexPages.currentPage().getParameters().get('num')) ){
                 ShowSubscriptionAllIdeas=true;   
                ShowSubscription1AllIdeas=false;           
            }
         }
         
        //set selectedTab to Recent if there are no selectedTab
        if(selectedTab == null || selectedTab=='') {
            selectedTab = 'Recent';
        } else {            
            selectedTab = ApexPages.currentPage().getParameters().get('selectTab');
        }    
        
        //get default avatar
        SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
        defaultAvatar = sl.Link__c + sl.Name;
        
        loadFiltersFromOtherPage();     //load filters from other pages
                
        /** START -- display error messages when there are no records found on page load    **/
            //display error message if there are no recent ideas
            if(getAllRecentIdeas().size() == 0) {
                noRecentIdeasView = 'No Records Found.';
            } else {
                noRecentIdeasView = '';
            }
            
            //display error message if there are no popular ideas
            if(getAllPopularIdeas().size() == 0) {
                noPopularIdeasView = 'No Records Found.';
            } else {
                noPopularIdeasView = '';
            }
            
            //display error message if there are no TopAllTime ideas
            if(getAllTopAllTimeIdeas().size() == 0) {
                noTopAllTimeIdeasView = 'No Records Found.';
            } else {
                noTopAllTimeIdeasView = '';
            }
            
            //display error message if there are no comments/all ideas
            if(getAllCommentIdeas().size() == 0) {
                noCommentIdeasView = 'No Records Found.';
            } else {
                noCommentIdeasView = '';
            }
        /** END -- display error messages when there are no records found on page load    **/   
        
        /** START -- for PAGINATION  **/
            loadRecentPagination();
            loadPopularPagination();
            loadTopAllTimePagination();
            loadCommentPagination();
            if(ApexPages.currentPage().getParameters().get('searchItemVal') != null && ApexPages.currentPage().getParameters().get('searchItemVal') != '') {
                searchItemValue = ApexPages.currentPage().getParameters().get('searchItemVal'); //set searched value
                showSearchResults = true;
                //selectedTab = 'AllIdeas';
                if(getAllSearchResultIdeas().size() == 0) {
                    noSearchResultIdeasView = 'No Records Found.';
                } else {
                    noSearchResultIdeasView = '';
                }
                loadSearchResultPagination();
            } else {
                searchItemValue = ' ';
                showSearchResults = false;
            }
        /** END -- for PAGINATION  **/
    }
    
    
    
    
    
      
    
    
    
    
    /**********     LOAD TAB PAGINATIONS ON PAGE LOAD   **********/
    /*
    *    @description:    action for loading recent ideas pagination.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadRecentPagination() {
        system.debug('\n\n*****ENTER loadRecentPagination*****\n\n');
            /*****  RECENT  *****/           
            //Get the data we need to paginate
            List<RecentClass> resultsListRecent = populateDataRecent();
             
            //Set the page size
            Integer pageSizeRecent = 5;
             
            //Create a new instance of Paginate passing in the overall size of
            //the list of data and the page size you want
            this.paginaterRecent = new PaginateRecent(resultsListRecent.size(), pageSizeRecent);
     
            //These lists hold the data
            this.fullRecentList = new List<List<RecentClass>>();
            this.RecentList = new List<RecentClass>();
             
            //Break out the full list into a list of lists
            if(resultsListRecent.size() > 0){
                List<RecentClass> tempcc = new List<RecentClass>();        
                Integer i = 0;
                for(RecentClass cc : resultsListRecent){
                    tempcc.add(cc);
                    i++;
                    if(i == pageSizeRecent){
                        this.fullRecentList.add(tempcc);
                        tempcc = new List<RecentClass>();
                        i = 0;
                    }
                }
                if(!tempcc.isEmpty()){
                    this.fullRecentList.add(tempcc);
                }
                 
                //Gets the correct list of data to show on the page
                this.RecentList = this.fullRecentList.get(this.paginaterRecent.indexRecent);
            }
    }
    
    /*
    *    @description:    action for loading popular ideas pagination.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadPopularPagination() {
        system.debug('\n\n*****ENTER loadPopularPagination*****\n\n');
            /*****  POPULAR  *****/           
            //Get the data we need to paginate
            List<PopularClass> resultsListPopular = populateDataPopular();
             
            //Set the page size
            Integer pageSizePopular = 5;
             
            //Create a new instance of Paginate passing in the overall size of
            //the list of data and the page size you want
            this.paginaterPopular = new PaginatePopular(resultsListPopular.size(), pageSizePopular);
     
            //These lists hold the data
            this.fullPopularList = new List<List<PopularClass>>();
            this.PopularList = new List<PopularClass>();
             
            //Break out the full list into a list of lists
            if(resultsListPopular.size() > 0){
                List<PopularClass> tempcc = new List<PopularClass>();        
                Integer i = 0;
                for(PopularClass cc : resultsListPopular){
                    tempcc.add(cc);
                    i++;
                    if(i == pageSizePopular){
                        this.fullPopularList.add(tempcc);
                        tempcc = new List<PopularClass>();
                        i = 0;
                    }
                }
                if(!tempcc.isEmpty()){
                    this.fullPopularList.add(tempcc);
                }
                 
                //Gets the correct list of data to show on the page
                this.PopularList = this.fullPopularList.get(this.paginaterPopular.indexPopular);
            }
    }
    
    /*
    *    @description:    action for loading TopAllTime ideas pagination.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadTopAllTimePagination() {
        system.debug('\n\n*****ENTER loadTopAllTimePagination*****\n\n');
            /*****  TopAllTime  *****/           
            //Get the data we need to paginate
            List<TopAllTimeClass> resultsListTopAllTime = populateDataTopAllTime();
             
            //Set the page size
            Integer pageSizeTopAllTime = 5;
             
            //Create a new instance of Paginate passing in the overall size of
            //the list of data and the page size you want
            this.paginaterTopAllTime = new PaginateTopAllTime(resultsListTopAllTime.size(), pageSizeTopAllTime);
     
            //These lists hold the data
            this.fullTopAllTimeList = new List<List<TopAllTimeClass>>();
            this.TopAllTimeList = new List<TopAllTimeClass>();
             
            //Break out the full list into a list of lists
            if(resultsListTopAllTime.size() > 0){
                List<TopAllTimeClass> tempcc = new List<TopAllTimeClass>();        
                Integer i = 0;
                for(TopAllTimeClass cc : resultsListTopAllTime){
                    tempcc.add(cc);
                    i++;
                    if(i == pageSizeTopAllTime){
                        this.fullTopAllTimeList.add(tempcc);
                        tempcc = new List<TopAllTimeClass>();
                        i = 0;
                    }
                }
                if(!tempcc.isEmpty()){
                    this.fullTopAllTimeList.add(tempcc);
                }
                 
                //Gets the correct list of data to show on the page
                this.TopAllTimeList = this.fullTopAllTimeList.get(this.paginaterTopAllTime.indexTopAllTime);
            }
    }
        
    /*
    *    @description:    action for loading Comment/All ideas pagination.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadCommentPagination() {
        system.debug('\n\n*****ENTER loadCommentPagination*****\n\n');
            /*****  Comment  *****/           
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
    }
    
    /*
    *    @description:    action for loading SearchResult ideas pagination.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadSearchResultPagination() {
        system.debug('\n\n*****ENTER loadSearchResultPagination*****\n\n');
            /*****  SearchResult  *****/           
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
        
    
    
    
    /**********     SET PICKLIST VALUES WHEN THERE ARE FILTERS ON PAGE LOAD **********/
    /*
    *    @description:    action for loading filters from other pages on page load.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void loadFiltersFromOtherPage() {
        system.debug('\n\n*****ENTER loadFiltersFromOtherPage*****\n\n');
        if(ApexPages.currentPage().getParameters().get('selectTab') != null) {
            if(ApexPages.currentPage().getParameters().get('selectTab') == 'Recent') {
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    if(ApexPages.currentPage().getParameters().get('cat') == 'General Business Banking' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'ACH and Wires' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Entitlements' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Third Party Product Integration' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Positive Pay' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions')
                       // ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                       //ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts')
                    {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Business Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'Promotion Suite' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Web Center' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Purchase Rewards' || 
                              //ApexPages.currentPage().getParameters().get('cat') == 'Online Account Opening' || 
                              //ApexPages.currentPage().getParameters().get('cat') == 'Other')
                              ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed')
                    {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Consumer Relationship';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Payments' ||
                              ApexPages.currentPage().getParameters().get('cat') == 'Bill Pay' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'External Funds Transfer' || 
                              // ApexPages.currentPage().getParameters().get('cat') == 'Pop Money' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Person to Person Payments' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Internal Transfers' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') 
                              
                              {
                                  selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                                  selectedRecentLineOfBusiness = 'Money Movement';
                              } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Admin Platform' ||
                                        ApexPages.currentPage().getParameters().get('cat') == 'Admin User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Data & Reporting' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'SSO and API Solutions' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Security & Authentication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Account Opening' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Digital Communication - Chat, Messaging, Chatbot ' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Online Forms' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'End User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Branding and Flexibility' ||
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Admin Platform User Management and Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Create Your Own/SSO and API Integration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Interfaces' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Other' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Idea Exchange') {
                                            selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                                            selectedRecentLineOfBusiness = 'Platform Solutions';
                                        } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Retail Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'General Digital Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Money Management' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Online Statements' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Card Management' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Financial Wellness' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Authentication & Settings' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Transfers' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Check/Deposit Imaging') {
                                                      selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                                                      selectedRecentLineOfBusiness = 'Retail Banking';
                    } 
                    //else if(ApexPages.currentPage().getParameters().get('cat') == 'Authentication and Settings') 
                    else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') {
                        //selectedRecentCategory = 'Authentication & Settings';
                        selectedRecentCategory = 'User Profile Settings';

                        selectedRecentLineOfBusiness = 'Retail Banking';
                    }   //end of (if cat == values) in Recent
                    else if(ApexPages.currentPage().getParameters().get('cat') == 'All') {
                       selectedRecentLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                    } 
                }  
                if(ApexPages.currentPage().getParameters().get('line')!=null) {
                    selectedRecentLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                }
                if(ApexPages.currentPage().getParameters().get('stat')!=null) {
                    selectedRecentIdeaStatus = ApexPages.currentPage().getParameters().get('stat');
                }
                //end of (if cat != null) in Recent  
            /*
                if(ApexPages.currentPage().getParameters().get('lob') == 'Business Banking') {
                    selectedRecentCategory = 'ACH and Wires';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Consumer Relationship') {
                    selectedRecentCategory = 'Online Account Opening';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Money Movement') {
                    selectedRecentCategory = 'Bill Pay';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Platform Solutions') {
                    selectedRecentCategory = 'Admin Platform User Management and Security';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Retail Banking') {
                    selectedRecentCategory = 'Alerts';
                }   //end of (if lob == values) in if selectedTab != null*/
                getAllRecentIdeas();
                loadRecentPagination();
            } else if(ApexPages.currentPage().getParameters().get('selectTab') == 'Popular') {
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    if(ApexPages.currentPage().getParameters().get('cat') == 'General Business Banking' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'ACH and Wires' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'Entitlements' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'Third Party Product Integration' ||
                        ApexPages.currentPage().getParameters().get('cat') == ' Customer Support' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                        ApexPages.currentPage().getParameters().get('cat') == 'Positive Pay' || 
                        //ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                        //ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts'
                         ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') {
                            selectedPopularCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedPopularLineOfBusiness = 'Business Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'Promotion Suite' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Web Center' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Purchase Rewards' || 
                                //ApexPages.currentPage().getParameters().get('cat') == 'Online Account Opening' || 
                                //ApexPages.currentPage().getParameters().get('cat') == 'Other'
                                ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') {
                            selectedPopularCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedPopularLineOfBusiness = 'Consumer Relationship';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Payments' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Person to Person Payments' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Internal Transfers' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Bill Pay' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'External Funds Transfer' || 
                                //ApexPages.currentPage().getParameters().get('cat') == 'Pop Money'||
                                ApexPages.currentPage().getParameters().get('cat') =='Client Services Developed Solutions') {
                            selectedPopularCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedPopularLineOfBusiness = 'Money Movement';
                                } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Admin Platform' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Admin User Support' ||
                                          ApexPages.currentPage().getParameters().get('cat') == 'Branding and Flexibility' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Data & Reporting' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'SSO and API Solutions' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Interfaces' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Security & Authentication' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Account Opening' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Digital Communication - Chat, Messaging, Chatbot' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Online Forms' || 
                                          ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' || 
                                          //ApexPages.currentPage().getParameters().get('cat') == 'End User Support' || 
                                          //ApexPages.currentPage().getParameters().get('cat') == 'Admin Platform User Management and Security' || 
                                          //ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                                          //ApexPages.currentPage().getParameters().get('cat') == 'Create Your Own/SSO and API Integration' || 
                                          //ApexPages.currentPage().getParameters().get('cat') == 'Security' || 
                                          //ApexPages.currentPage().getParameters().get('cat') == 'Other' || 
                                          
                                          ApexPages.currentPage().getParameters().get('cat') == 'Idea Exchange') {
                                              selectedPopularCategory = ApexPages.currentPage().getParameters().get('cat');
                                              selectedPopularLineOfBusiness = 'Platform Solutions';
                                          } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Retail Banking' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'General Digital Banking' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' ||
                                                    ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings' ||
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Money Management' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Online Statements' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Card Managementt' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Financial Wellness' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                                                    // ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Authentication & Settings' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                                                    // ApexPages.currentPage().getParameters().get('cat') == 'Transfers' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Online Statements' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                                    // ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                                                    //ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                                    ApexPages.currentPage().getParameters().get('cat') == 'Check/Deposit Imaging') {
                                                        selectedPopularCategory = ApexPages.currentPage().getParameters().get('cat');
                                                        selectedPopularLineOfBusiness = 'Retail Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') 

                    //else if(ApexPages.currentPage().getParameters().get('cat') == 'Authentication and Settings') 
                    {
                        //selectedPopularCategory = 'Authentication & Settings';
                        selectedPopularCategory = 'User Profile Settings';

                        selectedPopularLineOfBusiness = 'Retail Banking';
                    }   
                    else if(ApexPages.currentPage().getParameters().get('cat') == 'All') {
                    selectedPopularCategory = 'All';
                       selectedPopularLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                       
                    } 
                    //end of (if cat == values) in Popular
                }   
                if(ApexPages.currentPage().getParameters().get('line')!=null) {
                    selectedPopularLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                }
                if(ApexPages.currentPage().getParameters().get('stat')!=null) {
                    selectedPopularIdeaStatus = ApexPages.currentPage().getParameters().get('stat');
                }
                //end of (if cat != null) in Popular 
            /*
                if(ApexPages.currentPage().getParameters().get('lob') == 'Business Banking') {
                    selectedPopularCategory = 'ACH and Wires';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Consumer Relationship') {
                    selectedPopularCategory = 'Online Account Opening';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Money Movement') {
                    selectedPopularCategory = 'Bill Pay';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Platform Solutions') {
                    selectedPopularCategory = 'Admin Platform User Management and Security';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Retail Banking') {
                    selectedPopularCategory = 'Alerts';
                }   //end of (if lob == values) in if selectedTab != null*/
                getAllPopularIdeas();
                loadPopularPagination();
            } else if(ApexPages.currentPage().getParameters().get('selectTab') == 'TopAllTime') {
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    if(ApexPages.currentPage().getParameters().get('cat') == 'General Business Banking' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'ACH and Wires' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Entitlements' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Third Party Product Integration' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Positive Pay' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions')
                    {
                            selectedTopAllTimeCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedTopAllTimeLineOfBusiness = 'Business Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'Promotion Suite' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Web Center' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Purchase Rewards' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions')
                                //ApexPages.currentPage().getParameters().get('cat') == 'Other') 
                                {
                            selectedTopAllTimeCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedTopAllTimeLineOfBusiness = 'Consumer Relationship';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Payments' ||
                              ApexPages.currentPage().getParameters().get('cat') == 'Bill Pay' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'External Funds Transfer' || 
                              // ApexPages.currentPage().getParameters().get('cat') == 'Pop Money' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Person to Person Payments' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Internal Transfers' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') 
 {
                            selectedTopAllTimeCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedTopAllTimeLineOfBusiness = 'Money Movement';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Admin Platform' ||
                                        ApexPages.currentPage().getParameters().get('cat') == 'Admin User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Data & Reporting' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'SSO and API Solutions' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Security & Authentication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Account Opening' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Digital Communication - Chat, Messaging, Chatbot ' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Online Forms' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'End User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Branding and Flexibility' ||
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Admin Platform User Management and Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Create Your Own/SSO and API Integration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Interfaces' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Other' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Idea Exchange')
 {
                            selectedTopAllTimeCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedTopAllTimeLineOfBusiness = 'Platform Solutions';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Retail Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'General Digital Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Money Management' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Online Statements' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Card Management' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Financial Wellness' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Authentication & Settings' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Transfers' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Check/Deposit Imaging')										 {
                            selectedTopAllTimeCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedTopAllTimeLineOfBusiness = 'Retail Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') 
                    //else if(ApexPages.currentPage().getParameters().get('cat') == 'Authentication and Settings') 
                    {
                        //selectedTopAllTimeCategory = 'Authentication & Settings';
                        selectedTopAllTimeCategory = 'User Profile Settings';
                        selectedTopAllTimeLineOfBusiness = 'Retail Banking';
                    }   
                    else if(ApexPages.currentPage().getParameters().get('cat') == 'All') {
                       selectedTopAllTimeLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                    }
                    
                    //end of (if cat == values) in TopAllTime
                }   //end of (if cat != null) in TopAllTime 
                if(ApexPages.currentPage().getParameters().get('line')!=null) {
                    selectedTopAllTimeLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                }
                if(ApexPages.currentPage().getParameters().get('stat')!=null) {
                    selectedTopAllTimeIdeaStatus = ApexPages.currentPage().getParameters().get('stat');
                }
                
            } else if(ApexPages.currentPage().getParameters().get('selectTab') == 'AllIdeas') {
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    if(ApexPages.currentPage().getParameters().get('cat') == 'General Business Banking' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'ACH and Wires' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Entitlements' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Third Party Product Integration' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Positive Pay' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions'){
                            selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedCommentLineOfBusiness = 'Business Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'Promotion Suite' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Web Center' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Purchase Rewards' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') {
                            selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedCommentLineOfBusiness = 'Consumer Relationship';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Payments' ||
                              ApexPages.currentPage().getParameters().get('cat') == 'Bill Pay' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'External Funds Transfer' || 
                              // ApexPages.currentPage().getParameters().get('cat') == 'Pop Money' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Person to Person Payments' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Internal Transfers' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions')  {
                            selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedCommentLineOfBusiness = 'Money Movement';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Admin Platform' ||
                                        ApexPages.currentPage().getParameters().get('cat') == 'Admin User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Data & Reporting' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'SSO and API Solutions' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Security & Authentication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Account Opening' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Digital Communication - Chat, Messaging, Chatbot ' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Online Forms' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'End User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Branding and Flexibility' ||
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Admin Platform User Management and Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Create Your Own/SSO and API Integration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Interfaces' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Other' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Idea Exchange') {
                            selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedCommentLineOfBusiness = 'Platform Solutions';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Retail Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'General Digital Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Money Management' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Online Statements' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Card Management' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Financial Wellness' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Authentication & Settings' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Transfers' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Check/Deposit Imaging')										 {
                            selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                            selectedCommentLineOfBusiness = 'Retail Banking';
                    } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') 
                    //else if(ApexPages.currentPage().getParameters().get('cat') == 'Authentication and Settings') 
                    {
                        //selectedCommentCategory = 'Authentication & Settings';
                        selectedCommentCategory = 'User Profile Settings';
                        selectedCommentLineOfBusiness = 'Retail Banking';
                    }   
                    else if(ApexPages.currentPage().getParameters().get('cat') == 'All') {
                       selectedCommentLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                    }
                    
                    //end of (if cat == values) in Comment
                }   //end of (if cat != null) in Comment
                if(ApexPages.currentPage().getParameters().get('line')!=null) {
                    selectedCommentLineOfBusiness = ApexPages.currentPage().getParameters().get('line');
                }
                if(ApexPages.currentPage().getParameters().get('stat')!=null) {
                    selectedCommentIdeaStatus = ApexPages.currentPage().getParameters().get('stat');
                }
            /*
                if(ApexPages.currentPage().getParameters().get('lob') == 'Business Banking') {
                    selectedCommentCategory = 'ACH and Wires';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Consumer Relationship') {
                    selectedCommentCategory = 'Online Account Opening';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Money Movement') {
                    selectedCommentCategory = 'Bill Pay';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Platform Solutions') {
                    selectedCommentCategory = 'Admin Platform User Management and Security';
                } else if(ApexPages.currentPage().getParameters().get('lob') == 'Retail Banking') {
                    selectedCommentCategory = 'Alerts';
                }   //end of (if lob == values) in if selectedTab != null*/
                getAllCommentIdeas();
                loadCommentPagination();                
            }   //end of (if selectedTab == Recent or Popular or Top All-Time or All Ideas)
        } else {
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                if(ApexPages.currentPage().getParameters().get('cat') == 'General Business Banking' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'ACH and Wires' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Entitlements' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Third Party Product Integration' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Positive Pay' || 
                       ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Business Banking';
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'Promotion Suite' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Web Center' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Purchase Rewards' || 
                                ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Consumer Relationship';
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Payments' ||
                              ApexPages.currentPage().getParameters().get('cat') == 'Bill Pay' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'External Funds Transfer' || 
                              // ApexPages.currentPage().getParameters().get('cat') == 'Pop Money' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Person to Person Payments' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Internal Transfers' || 
                              ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions') 
 {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Money Movement';
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Admin Platform' ||
                                        ApexPages.currentPage().getParameters().get('cat') == 'Admin User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Data & Reporting' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'SSO and API Solutions' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Security & Authentication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Account Opening' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Digital Communication - Chat, Messaging, Chatbot ' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Online Forms' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutions' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'End User Support' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Branding and Flexibility' ||
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Admin Platform User Management and Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Reporting' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Create Your Own/SSO and API Integration' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Interfaces' || 
                                        // ApexPages.currentPage().getParameters().get('cat') == 'Security' || 
                                        //ApexPages.currentPage().getParameters().get('cat') == 'Other' || 
                                        ApexPages.currentPage().getParameters().get('cat') == 'Idea Exchange')
 {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Platform Solutions';
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'General Retail Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Alerts & Communication' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'General Digital Banking' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Customer Support' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Money Management' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Online Statements' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Remote Deposit' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Shared Access' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Card Management' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Financial Wellness' ||
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Client Services Developed Solutionst' ||
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Deposit Accounts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Other Accounts' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Authentication & Settings' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Alerts' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Transfers' || 
                                                  // ApexPages.currentPage().getParameters().get('cat') == 'Registration' || 
                                                  //ApexPages.currentPage().getParameters().get('cat') == 'Web/Direct Connect' || 
                                                  ApexPages.currentPage().getParameters().get('cat') == 'Check/Deposit Imaging')										 {
                        selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
                        selectedRecentLineOfBusiness = 'Retail Banking';
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') 
                //else if(ApexPages.currentPage().getParameters().get('cat') == 'Authentication and Settings') 
                {
                   // selectedRecentCategory = 'Authentication & Settings';
                    selectedRecentCategory = 'User Profile Settings';
                    selectedRecentLineOfBusiness = 'Retail Banking';
                }   //end of (if cat == values) in if selectedTab==null
            }   //end of (if cat != null) in if selectedTab==null
            /*
            if(ApexPages.currentPage().getParameters().get('lob') == 'Business Banking') {
                selectedRecentCategory = 'ACH and Wires';
            } else if(ApexPages.currentPage().getParameters().get('lob') == 'Consumer Relationship') {
                selectedRecentCategory = 'Online Account Opening';
            } else if(ApexPages.currentPage().getParameters().get('lob') == 'Money Movement') {
                selectedRecentCategory = 'Bill Pay';
            } else if(ApexPages.currentPage().getParameters().get('lob') == 'Platform Solutions') {
                selectedRecentCategory = 'Admin Platform User Management and Security';
            } else if(ApexPages.currentPage().getParameters().get('lob') == 'Retail Banking') {
                selectedRecentCategory = 'Alerts';
            }   //end of (if lob == values) in if selectedTab == null*/
            getAllRecentIdeas();
            loadRecentPagination();
            
            system.debug('\n\n*****loadFiltersFromOtherPage | selectedTab == null | selectedTab = ' + selectedTab);
            system.debug('\n\n*****loadFiltersFromOtherPage | paginaterRecent.totalPageRecent = ' + paginaterRecent.totalPageRecent);
        }   //end of (if selectedTab != null)
    }
    
    
    
    
    /**********     SET LINE OF BUSINESS PICKLIST VALUES    **********/
    /*
    *    @description:    get line of business values.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getLineOfBusinessValues() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All'));               
       Schema.DescribeFieldResult fieldResult = Idea.Di_Idea_Line_of_Business__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
       for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    /*
    *    @description:    get line of business values.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getLineOfBusinessValuesPopular() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All'));               
       Schema.DescribeFieldResult fieldResult = Idea.Di_Idea_Line_of_Business__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
       for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }
       return options;
    }
    
    public Boolean  getSubscription() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedPopularLineOfBusiness AND DI_SubscriptionCategory__c=:selectedPopularCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheck=true;
       }
       else SubscriberCheck=false;
       return SubscriberCheck;
    }
    public Boolean  getSubscriptionTop() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedTopAllTimeLineOfBusiness AND DI_SubscriptionCategory__c=:selectedTopAllTimeCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheckTop=true;
       }
       else SubscriberCheckTop=false;
       return SubscriberCheckTop;
    }
    public Boolean  getSubscriptionAllIdeas() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedCommentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedCommentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheckAllIdeas=true;
       }
       else SubscriberCheckAllIdeas=false;
       return SubscriberCheckAllIdeas;
    }
    
     public PageReference SubscribeAllIdeas() {
       
        DI_IdeaSubscription__c newVote = new DI_IdeaSubscription__c();
        newVote.DI_LineOfBusiness__c = selectedCommentLineOfBusiness.escapeHTML4();
        newVote.DI_SubscriptionCategory__c = selectedCommentCategory.escapeHTML4();
        newVote.DI_UserId__c=userinfo.getuserid();
        newVote.DI_UserName__c=userinfo.getuserid();
        insert newVote;
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=AllIdeas');
        gotorecord.getParameters().put('cat',selectedCommentCategory.escapeHTML4());
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    public Boolean  getSubscription1AllIdeas() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedCommentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedCommentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheckAllIdeas=false;
           
       }
       else SubscriberCheckAllIdeas=true;
       return SubscriberCheckAllIdeas;
    }
    public PageReference Subscribe1AllIdeas() {
       
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedCommentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedCommentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
            
        delete subscriberList[0];
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=AllIdeas');
        gotorecord.getParameters().put('cat',selectedCommentCategory.escapeHTML4());
        gotorecord.getParameters().put('num',selectedCommentLineOfBusiness.escapeHTML4());
        gotorecord.setRedirect(true);
        return gotorecord;
        } 
    public Boolean  getSubscription1Top() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedTopAllTimeLineOfBusiness AND DI_SubscriptionCategory__c=:selectedTopAllTimeCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheckTop=false;
           
       }
       else SubscriberCheckTop=true;
       return SubscriberCheckTop;
    }
    public Boolean  getSubscriptionRecent() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedRecentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedRecentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheckrecent=true;
       }
       else SubscriberCheckrecent=false;
       return SubscriberCheckrecent;
    }
    public Boolean  getSubscription1Recent() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedRecentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedRecentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheckrecent=false;
           
       }
       else SubscriberCheckrecent=true;
       return SubscriberCheckrecent;
    }
    public PageReference SubscribeRecent() {
       
        DI_IdeaSubscription__c newVote = new DI_IdeaSubscription__c();
        newVote.DI_LineOfBusiness__c = ((selectedRecentLineOfBusiness!=null)?selectedRecentLineOfBusiness.escapeHTML4():null);
        newVote.DI_SubscriptionCategory__c = selectedRecentCategory.escapeHTML4();
        newVote.DI_UserId__c=userinfo.getuserid();
        newVote.DI_UserName__c=userinfo.getuserid();
        insert newVote;
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=Recent');
        gotorecord.getParameters().put('cat',selectedRecentCategory.escapeHTML4());
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    public PageReference SubscribeTop() {
       
        DI_IdeaSubscription__c newVote = new DI_IdeaSubscription__c();
        newVote.DI_LineOfBusiness__c = selectedTopAllTimeLineOfBusiness.escapeHTML4();
        newVote.DI_SubscriptionCategory__c = selectedTopAllTimeCategory.escapeHTML4();
        newVote.DI_UserId__c=userinfo.getuserid();
        newVote.DI_UserName__c=userinfo.getuserid();
        insert newVote;
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=TopAllTime');
        gotorecord.getParameters().put('cat',selectedTopAllTimeCategory.escapeHTML4());
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    public PageReference Subscribe1Top() {
       
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedTopAllTimeLineOfBusiness AND DI_SubscriptionCategory__c=:selectedTopAllTimeCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
            
        delete subscriberList[0];
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=TopAllTime');
        gotorecord.getParameters().put('cat',selectedTopAllTimeCategory.escapeHTML4());
        gotorecord.getParameters().put('num',selectedTopAllTimeLineOfBusiness.escapeHTML4());
        gotorecord.setRedirect(true);
        return gotorecord;
        } 
    
    public PageReference Subscribe1Recent() {
       
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedRecentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedRecentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
            
        delete subscriberList[0];
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=Recent');
        gotorecord.getParameters().put('cat',selectedRecentCategory.escapeHTML4());
        gotorecord.getParameters().put('num',((selectedRecentLineOfBusiness!=null)?selectedRecentLineOfBusiness.escapeHTML4():null));
        gotorecord.setRedirect(true);
        return gotorecord;
        } 
    
     public Boolean  getSubscription1() {
       list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedPopularLineOfBusiness AND DI_SubscriptionCategory__c=:selectedPopularCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           SubscriberCheck=false;
           
       }
       else SubscriberCheck=true;
       return SubscriberCheck;
    }
    
    public PageReference Subscribe() {
       
        DI_IdeaSubscription__c newVote = new DI_IdeaSubscription__c();
        newVote.DI_LineOfBusiness__c = ((selectedPopularLineOfBusiness!=null)?selectedPopularLineOfBusiness.escapeHTML4():null);
        newVote.DI_SubscriptionCategory__c = selectedPopularCategory.escapeHTML4();
        newVote.DI_UserId__c=userinfo.getuserid();
        newVote.DI_UserName__c=userinfo.getuserid();
        insert newVote;
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=Popular');
        gotorecord.getParameters().put('cat',selectedPopularCategory.escapeHTML4());
        gotorecord.setRedirect(true);
        return gotorecord;
    }

 public PageReference Subscribe1() {
       
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedPopularLineOfBusiness AND DI_SubscriptionCategory__c=:selectedPopularCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
            
        delete subscriberList[0];
            
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=Popular');
        gotorecord.getParameters().put('cat',selectedPopularCategory.escapeHTML4());
        gotorecord.getParameters().put('num',((selectedPopularLineOfBusiness!=null)?selectedPopularLineOfBusiness.escapeHTML4():null));
        gotorecord.setRedirect(true);
        return gotorecord;
        } 
        
    /*
    *    @description:    get line of business values.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getLineOfBusinessValuesTopAllTime() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All'));               
       Schema.DescribeFieldResult fieldResult = Idea.Di_Idea_Line_of_Business__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
       for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }
       return options;
    }
    
    /*
    *    @description:    get line of business values comment.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getLineOfBusinessValuesComment() {
           List<SelectOption> options = new List<SelectOption>();
           options.add(new SelectOption('', 'All'));               
           Schema.DescribeFieldResult fieldResult = Idea.Di_Idea_Line_of_Business__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
           for( Schema.PicklistEntry f : ple) {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }
           return options;
    }
    
    
    
    
    /**********     SET CATEGORY PICKLIST VALUES    **********/
    /*
    *    @description:    get category values for recent tab.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getCategoryValues() {
       List<SelectOption> options = new List<SelectOption>();
       
       if(ApexPages.currentPage().getParameters().get('cat') != null && (ApexPages.currentPage().getParameters().get('selectTab') == 'Recent' || ApexPages.currentPage().getParameters().get('selectTab') == '' || ApexPages.currentPage().getParameters().get('selectTab') == null)) {
           options.add(new SelectOption('', 'All'));   
           //options.add(new SelectOption(ApexPages.currentPage().getParameters().get('cat'), ApexPages.currentPage().getParameters().get('cat')));
       } else {
           options.add(new SelectOption('', 'All'));    
       }
       
       if(selectedRecentLineOfBusiness == 'Business Banking') {
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
       } else if(selectedRecentLineOfBusiness == 'Consumer Relationship') {
           options.add(new SelectOption('Promotion Suite', 'Promotion Suite'));
            options.add(new SelectOption('Web Center', 'Web Center'));
            options.add(new SelectOption('Purchase Rewards', 'Purchase Rewards'));
              options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
            //options.add(new SelectOption('Online Account Opening', 'Online Account Opening'));
           // options.add(new SelectOption('Other', 'Other'));
       } else if(selectedRecentLineOfBusiness == 'Money Movement') {
            options.add(new SelectOption('General Payments', 'General Payments'));
            options.add(new SelectOption('Bill Pay', 'Bill Pay'));
            options.add(new SelectOption('External Funds Transfer', 'External Funds Transfer'));
            //options.add(new SelectOption('Pop Money', 'Pop Money'));
            options.add(new SelectOption('Person to Person Payments', 'Person to Person Payments'));
            options.add(new SelectOption('Internal Transfers', 'Internal Transfers'));
            options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
       } else if(selectedRecentLineOfBusiness == 'Platform Solutions') {
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
       } else if(selectedRecentLineOfBusiness == 'Retail Banking') {
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
       } else if (selectedRecentLineOfBusiness == 'Theme Idea') {
           options.add(new SelectOption('DI Labs','DI Labs'));
           options.add(new SelectOption('Design','Design'));
           options.add(new SelectOption('Events','Events'));
           options.add(new SelectOption('Functionality','Functionality'));
           options.add(new SelectOption('Industry Research','Industry Research'));
       }
       options.sort();
       return options;
    }
    
    /*
    *    @description:    get category values for popular tab.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getPopularCategoryValues() {
       List<SelectOption> options = new List<SelectOption>();
       
       if(ApexPages.currentPage().getParameters().get('cat') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'Popular') {
           options.add(new SelectOption('', 'All'));    
           //options.add(new SelectOption(ApexPages.currentPage().getParameters().get('cat'), ApexPages.currentPage().getParameters().get('cat')));
       } else {
           options.add(new SelectOption('', 'All'));    
       }
       
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
           options.add(new SelectOption('DI Labs','DI Labs'));
           options.add(new SelectOption('Design','Design'));
           options.add(new SelectOption('Events','Events'));
           options.add(new SelectOption('Functionality','Functionality'));
           options.add(new SelectOption('Industry Research','Industry Research'));
       }
       options.sort();
       return options;
    }
    
    /*
    *    @description:    get category values for TopAllTime tab.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getTopAllTimeCategoryValues() {
       List<SelectOption> options = new List<SelectOption>();
       
       if(ApexPages.currentPage().getParameters().get('cat') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'TopAllTime') {
           options.add(new SelectOption('', 'All'));    
           //options.add(new SelectOption(ApexPages.currentPage().getParameters().get('cat'), ApexPages.currentPage().getParameters().get('cat')));
       } else {
           options.add(new SelectOption('', 'All'));    
       }
       
       if(selectedTopAllTimeLineOfBusiness == 'Business Banking') {
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
       } else if(selectedTopAllTimeLineOfBusiness == 'Consumer Relationship') {
          options.add(new SelectOption('Promotion Suite', 'Promotion Suite'));
            options.add(new SelectOption('Web Center', 'Web Center'));
            options.add(new SelectOption('Purchase Rewards', 'Purchase Rewards'));
              options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
            //options.add(new SelectOption('Online Account Opening', 'Online Account Opening'));
           // options.add(new SelectOption('Other', 'Other'));
       } else if(selectedTopAllTimeLineOfBusiness == 'Money Movement') {
            options.add(new SelectOption('General Payments', 'General Payments'));
            options.add(new SelectOption('Bill Pay', 'Bill Pay'));
            options.add(new SelectOption('External Funds Transfer', 'External Funds Transfer'));
            //options.add(new SelectOption('Pop Money', 'Pop Money'));
            options.add(new SelectOption('Person to Person Payments', 'Person to Person Payments'));
            options.add(new SelectOption('Internal Transfers', 'Internal Transfers'));
            options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
       } else if(selectedTopAllTimeLineOfBusiness == 'Platform Solutions') {
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
       } else if(selectedTopAllTimeLineOfBusiness == 'Retail Banking') {
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
       } else if (selectedTopAllTimeLineOfBusiness == 'Theme Idea') {
           options.add(new SelectOption('DI Labs','DI Labs'));
           options.add(new SelectOption('Design','Design'));
           options.add(new SelectOption('Events','Events'));
           options.add(new SelectOption('Functionality','Functionality'));
           options.add(new SelectOption('Industry Research','Industry Research'));
       }
       options.sort();
       return options;
    }
    
    /*
    *    @description:    get category values for Comment tab.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getCommentCategoryValues() {
       List<SelectOption> options = new List<SelectOption>();
       
       if(ApexPages.currentPage().getParameters().get('cat') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'AllIdeas') {
           options.add(new SelectOption('', 'All'));    
           //options.add(new SelectOption(ApexPages.currentPage().getParameters().get('cat'), ApexPages.currentPage().getParameters().get('cat')));
       } else {
           options.add(new SelectOption('', 'All'));    
       }
       
       if(selectedCommentLineOfBusiness == 'Business Banking') {
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
       } else if(selectedCommentLineOfBusiness == 'Consumer Relationship') {
            options.add(new SelectOption('Promotion Suite', 'Promotion Suite'));
            options.add(new SelectOption('Web Center', 'Web Center'));
            options.add(new SelectOption('Purchase Rewards', 'Purchase Rewards'));
              options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
            //options.add(new SelectOption('Online Account Opening', 'Online Account Opening'));
           // options.add(new SelectOption('Other', 'Other'));
       } else if(selectedCommentLineOfBusiness == 'Money Movement') {
           options.add(new SelectOption('General Payments', 'General Payments'));
            options.add(new SelectOption('Bill Pay', 'Bill Pay'));
            options.add(new SelectOption('External Funds Transfer', 'External Funds Transfer'));
            //options.add(new SelectOption('Pop Money', 'Pop Money'));
            options.add(new SelectOption('Person to Person Payments', 'Person to Person Payments'));
            options.add(new SelectOption('Internal Transfers', 'Internal Transfers'));
            options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
       } else if(selectedCommentLineOfBusiness == 'Platform Solutions') {
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
       } else if(selectedCommentLineOfBusiness == 'Retail Banking') {
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
       } else if (selectedCommentLineOfBusiness == 'Theme Idea') {
           options.add(new SelectOption('DI Labs','DI Labs'));
           options.add(new SelectOption('Design','Design'));
           options.add(new SelectOption('Events','Events'));
           options.add(new SelectOption('Functionality','Functionality'));
           options.add(new SelectOption('Industry Research','Industry Research'));
       }
       options.sort();
       return options;
    }
    
    
    
    
    /**********     SET IDEA STATUS PICKLIST VALUES **********/
    /*
    *    @description:    get idea status values.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getIdeaStatusValues() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All')); 
       
       if (selectedRecentLineOfBusiness != 'Theme Idea') {                          
           Schema.DescribeFieldResult fieldResult = Idea.Status.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
           for( Schema.PicklistEntry f : ple) {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }    
       }   
       return options;
    }
    public List<SelectOption> getIdeaStatusValuesPopular() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All'));
       
       if (selectedPopularLineOfBusiness != 'Theme Idea') {
                                  
           Schema.DescribeFieldResult fieldResult = Idea.Status.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
           for( Schema.PicklistEntry f : ple) {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }  
       }     
       return options;
    }
    public List<SelectOption> getIdeaStatusValuesTopAllTime() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All'));  
       if (selectedTopAllTimeLineOfBusiness != 'Theme Idea') {                         
           Schema.DescribeFieldResult fieldResult = Idea.Status.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
           for( Schema.PicklistEntry f : ple) {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }    
       }   
       return options;
    }
    public List<SelectOption> getIdeaStatusValuesComment() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', 'All'));    
       if (selectedCommentLineOfBusiness != 'Theme Idea') {

           Schema.DescribeFieldResult fieldResult = Idea.Status.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
           for( Schema.PicklistEntry f : ple) {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }     
       }  
       return options;
    }
    
    
    
    
    /**********     GET IDEAS LISTS     **********/
    /*
    *    @description:    get all recent ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Idea> getAllRecentIdeas() {
        String selectedRecentDevice;        
        if(isValChanged == true) {      
            if(ApexPages.currentPage().getParameters().get('lob') != null) {
                selectedRecentLineOfBusiness = selectedRecentLineOfBusiness.escapeHTML4();
            }
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                selectedRecentCategory = selectedRecentCategory.escapeHTML4();
            }   
            if(ApexPages.currentPage().getParameters().get('chan') != null && (ApexPages.currentPage().getParameters().get('selectTab') == 'Recent' || ApexPages.currentPage().getParameters().get('selectTab') == '' || ApexPages.currentPage().getParameters().get('selectTab') == null)) {
                selectedRecentIdeaStatus = selectedRecentIdeaStatus.escapeHTML4();
            } 
            if(ApexPages.currentPage().getParameters().get('dev') != null) {
                selectedRecentDevice = selectedRecentDevice;
            }
            if(selectedRecentLineOfBusiness == 'All' || selectedRecentLineOfBusiness == '' || selectedRecentLineOfBusiness == null) {
                selectedRecentCategory  = 'All';
            }
        } else {    
            if(ApexPages.currentPage().getParameters().get('lob') != null) {
                selectedRecentLineOfBusiness = ApexPages.currentPage().getParameters().get('lob');
            }
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                selectedRecentCategory = ApexPages.currentPage().getParameters().get('cat');
            } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') {
                selectedRecentCategory = 'User Profile Settings';
            }
            if(ApexPages.currentPage().getParameters().get('chan') != null && (ApexPages.currentPage().getParameters().get('selectTab') == 'Recent' || ApexPages.currentPage().getParameters().get('selectTab') == '' || ApexPages.currentPage().getParameters().get('selectTab') == null)) {
                selectedRecentIdeaStatus = ApexPages.currentPage().getParameters().get('chan');
            } 
            if(ApexPages.currentPage().getParameters().get('dev') != null) {
                selectedRecentDevice = ApexPages.currentPage().getParameters().get('dev');
            }
        }
    
        List<Idea> recentIdeasViewAllList = new List<Idea>();
        
        String dynamicSearchQuery;
        dynamicSearchQuery = 'SELECT id , Body, Title, CreatedBy.Name,Createdby.Title, Di_Idea_Featured_Image__c, DI_Idea_Line_of_Business__c,Di_Idea_Category__c, Status, CreatedDate, CreatedById, VoteTotal, CreatedBy.pics__c, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c,Di_Idea_Channel__c from Idea where createddate = LAST_N_DAYS:60 ';
        

        if(selectedRecentLineOfBusiness == 'null' || selectedRecentLineOfBusiness == null || selectedRecentLineOfBusiness == '' || selectedRecentLineOfBusiness == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedRecentLineOfBusiness != null || selectedRecentLineOfBusiness  != 'null' || selectedRecentLineOfBusiness != '' || selectedRecentLineOfBusiness != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND DI_Idea_Line_of_Business__c =' + '\'' + selectedRecentLineOfBusiness.escapeHTML4() + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        if(selectedRecentCategory == 'null' || selectedRecentCategory == null || selectedRecentCategory == '' || selectedRecentCategory == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if((selectedRecentCategory != null || selectedRecentCategory != 'null' || selectedRecentCategory != '' || selectedRecentCategory != 'All') && (selectedRecentLineOfBusiness == 'null' || selectedRecentLineOfBusiness == null || selectedRecentLineOfBusiness == '' || selectedRecentLineOfBusiness == 'All')) {
            dynamicSearchQuery = dynamicSearchQuery;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select a Line of Business.'));
        } else if((selectedRecentCategory != null || selectedRecentCategory != 'null' || selectedRecentCategory != '' || selectedRecentCategory != 'All') && (selectedRecentLineOfBusiness != 'null' || selectedRecentLineOfBusiness != null || selectedRecentLineOfBusiness != '' || selectedRecentLineOfBusiness != 'All')) {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Category__c =' + '\'' + selectedRecentCategory + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        if(selectedRecentIdeaStatus == 'null' || selectedRecentIdeaStatus == null || selectedRecentIdeaStatus == '' || selectedRecentIdeaStatus == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedRecentIdeaStatus != null || selectedRecentIdeaStatus != 'null' || selectedRecentIdeaStatus != '' || selectedRecentIdeaStatus != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Status =' + '\'' + selectedRecentIdeaStatus + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        
        if(selectedRecentDevice == 'null' || selectedRecentDevice == null || selectedRecentDevice == '' || selectedRecentDevice == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedRecentDevice != null || selectedRecentDevice != 'null' || selectedRecentDevice != '' || selectedRecentDevice != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c =' + '\'' + selectedRecentDevice + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        
        if(Test.isRunningTest()){
            dynamicSearchQuery = dynamicSearchQuery + ' ORDER BY CreatedDate desc LIMIT 1';
        }
        else
        {
            dynamicSearchQuery = dynamicSearchQuery + ' ORDER BY CreatedDate desc LIMIT 25';
        }
        
        system.debug('***dynamicSearchQuery Recent = ' + dynamicSearchQuery);
        recentIdeasViewAllList = database.query(dynamicSearchQuery);
        return recentIdeasViewAllList;    // [select id , Body, Title, CreatedBy.Name, Di_Idea_Featured_Image__c from Idea where createddate = LAST_N_DAYS:5 ORDER BY CreatedDate desc];
    }
    
    /*
    *    @description:    get all popular ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Idea> getAllPopularIdeas() {
        String selectedPopularDevice;            
        if(isValChanged == true) {      
            if(ApexPages.currentPage().getParameters().get('lob') != null) {
                selectedPopularLineOfBusiness = selectedPopularLineOfBusiness;
            }
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                selectedPopularCategory  = selectedPopularCategory;
            }
            if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'Popular') {
                selectedPopularIdeaStatus  = selectedPopularIdeaStatus.escapeHTML4();
            }
            if(ApexPages.currentPage().getParameters().get('dev') != null) {
                selectedPopularDevice = selectedPopularDevice;
            }
            if(selectedPopularLineOfBusiness == 'All' || selectedPopularLineOfBusiness == '' || selectedPopularLineOfBusiness == null) {
                selectedPopularCategory = 'All';
            }
        } else {     
            if(ApexPages.currentPage().getParameters().get('lob') != null) {
                selectedPopularLineOfBusiness = ApexPages.currentPage().getParameters().get('lob');
            }
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                selectedPopularCategory = ApexPages.currentPage().getParameters().get('cat');
            } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') {
                selectedPopularCategory = 'User Profile Settings';
            }
            if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'Popular') {
                selectedPopularIdeaStatus  = ApexPages.currentPage().getParameters().get('chan');
            }   
            if(ApexPages.currentPage().getParameters().get('dev') != null) {
                selectedPopularDevice = ApexPages.currentPage().getParameters().get('dev');
            }
        }
        
        List<Idea> popularIdeasViewAllList = new List<Idea>();
        
        String dynamicSearchQuery;
        dynamicSearchQuery = 'SELECT id , Body, Title, CreatedBy.Name,Createdby.Title, Di_Idea_Featured_Image__c, DI_Idea_Line_of_Business__c, Di_Idea_Category__c, Status, VoteScore, CreatedDate, CreatedById, VoteTotal, CreatedBy.pics__c, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c, Di_Idea_Channel__c  from Idea WHERE id != null';
                
        /*if(ApexPages.currentPage().getParameters().get('chan') != null) {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c = '+ '\'' + ApexPages.currentPage().getParameters().get('chan') + '\'';
        }*/
        if(selectedPopularLineOfBusiness == 'null' || selectedPopularLineOfBusiness == null || selectedPopularLineOfBusiness == '' || selectedPopularLineOfBusiness == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedPopularLineOfBusiness != null || selectedPopularLineOfBusiness  != 'null' || selectedPopularLineOfBusiness != '' || selectedPopularLineOfBusiness != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND DI_Idea_Line_of_Business__c =' + '\'' + selectedPopularLineOfBusiness + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        if(selectedPopularCategory == 'null' || selectedPopularCategory == null || selectedPopularCategory == '' || selectedPopularCategory == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if((selectedPopularCategory != null || selectedPopularCategory != 'null' || selectedPopularCategory != '' || selectedPopularCategory != 'All') && (selectedPopularLineOfBusiness == 'null' || selectedPopularLineOfBusiness == null || selectedPopularLineOfBusiness == '' || selectedPopularLineOfBusiness == 'All')) {
            dynamicSearchQuery = dynamicSearchQuery;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select a Line of Business.'));
        } else if((selectedPopularCategory != null || selectedPopularCategory != 'null' || selectedPopularCategory != '' || selectedPopularCategory != 'All') && (selectedPopularLineOfBusiness != 'null' || selectedPopularLineOfBusiness != null || selectedPopularLineOfBusiness != '' || selectedPopularLineOfBusiness != 'All')) {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Category__c =' + '\'' + selectedPopularCategory + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        if(selectedPopularIdeaStatus == 'null' || selectedPopularIdeaStatus == null || selectedPopularIdeaStatus == '' || selectedPopularIdeaStatus == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedPopularIdeaStatus != null || selectedPopularIdeaStatus != 'null' || selectedPopularIdeaStatus != '' || selectedPopularIdeaStatus != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Status =' + '\'' + selectedPopularIdeaStatus + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        
        if(selectedPopularDevice == 'null' || selectedPopularDevice == null || selectedPopularDevice == '' || selectedPopularDevice == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedPopularDevice != null || selectedPopularDevice != 'null' || selectedPopularDevice != '' || selectedPopularDevice != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c =' + '\'' + selectedPopularDevice + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        dynamicSearchQuery = dynamicSearchQuery + ' ORDER BY VoteScore desc LIMIT 25';
        system.debug('***dynamicSearchQuery Popular = ' + dynamicSearchQuery);
        popularIdeasViewAllList = database.query(dynamicSearchQuery);
        return popularIdeasViewAllList; //[select id , Body , Status , Title , VoteScore, CreatedBy.Name, Di_Idea_Featured_Image__c from Idea ORDER BY VoteScore desc];
    }    
    
    /*
    *    @description:    get all TopAllTime ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Idea> getAllTopAllTimeIdeas() {
        String selectedTopAllTimeDevice;            
        if(isValChanged == true) {      
            if(ApexPages.currentPage().getParameters().get('lob') != null) {
                selectedTopAllTimeLineOfBusiness = selectedTopAllTimeLineOfBusiness.escapeHTML4();
            }
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                selectedTopAllTimeCategory  = selectedTopAllTimeCategory.escapeHTML4();
            }
            if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'TopAllTime') {
                selectedTopAllTimeIdeaStatus  = selectedTopAllTimeIdeaStatus.escapeHTML4();
            }
            if(ApexPages.currentPage().getParameters().get('dev') != null) {
                selectedTopAllTimeDevice = selectedTopAllTimeDevice;
            }
            if(selectedTopAllTimeLineOfBusiness == 'All' || selectedTopAllTimeLineOfBusiness == '' || selectedTopAllTimeLineOfBusiness == null) {
                selectedTopAllTimeCategory = 'All';
            }
        } else {     
            if(ApexPages.currentPage().getParameters().get('lob') != null) {
                selectedTopAllTimeLineOfBusiness = ApexPages.currentPage().getParameters().get('lob');
            }
            if(ApexPages.currentPage().getParameters().get('cat') != null) {
                selectedTopAllTimeCategory = ApexPages.currentPage().getParameters().get('cat');
            } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') {
                selectedTopAllTimeCategory = 'User Profile Settings';
            }
            if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'TopAllTime') {
                selectedTopAllTimeIdeaStatus  = ApexPages.currentPage().getParameters().get('chan');
            }   
            if(ApexPages.currentPage().getParameters().get('dev') != null) {
                selectedTopAllTimeDevice = ApexPages.currentPage().getParameters().get('dev');
            }
        }
        
        List<Idea> TopAllTimeIdeasViewAllList = new List<Idea>();
        
        String dynamicSearchQuery;
        dynamicSearchQuery = 'SELECT id , Body, Title, CreatedBy.Name,Createdby.Title, Di_Idea_Featured_Image__c, DI_Idea_Line_of_Business__c, Di_Idea_Category__c, Status, VoteScore, CreatedDate, CreatedById, VoteTotal, CreatedBy.pics__c, CreatedBy.profileId, CreatedBy.DI_Fi_Name__c, Di_Idea_Channel__c from Idea WHERE id != null';
                
        /*if(ApexPages.currentPage().getParameters().get('chan') != null) {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c = '+ '\'' + ApexPages.currentPage().getParameters().get('chan') + '\'';
        }*/
        if(selectedTopAllTimeLineOfBusiness == 'null' || selectedTopAllTimeLineOfBusiness == null || selectedTopAllTimeLineOfBusiness == '' || selectedTopAllTimeLineOfBusiness == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedTopAllTimeLineOfBusiness != null || selectedTopAllTimeLineOfBusiness  != 'null' || selectedTopAllTimeLineOfBusiness != '' || selectedTopAllTimeLineOfBusiness != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND DI_Idea_Line_of_Business__c =' + '\'' + selectedTopAllTimeLineOfBusiness + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        if(selectedTopAllTimeCategory == 'null' || selectedTopAllTimeCategory == null || selectedTopAllTimeCategory == '' || selectedTopAllTimeCategory == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if((selectedTopAllTimeCategory != null || selectedTopAllTimeCategory != 'null' || selectedTopAllTimeCategory != '' || selectedTopAllTimeCategory != 'All') && (selectedTopAllTimeLineOfBusiness == 'null' || selectedTopAllTimeLineOfBusiness == null || selectedTopAllTimeLineOfBusiness == '' || selectedTopAllTimeLineOfBusiness == 'All')) {
            dynamicSearchQuery = dynamicSearchQuery;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select a Line of Business.'));
        } else if((selectedTopAllTimeCategory != null || selectedTopAllTimeCategory != 'null' || selectedTopAllTimeCategory != '' || selectedTopAllTimeCategory != 'All') && (selectedTopAllTimeLineOfBusiness != 'null' || selectedTopAllTimeLineOfBusiness != null || selectedTopAllTimeLineOfBusiness != '' || selectedTopAllTimeLineOfBusiness != 'All')) {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Category__c =' + '\'' + selectedTopAllTimeCategory + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        if(selectedTopAllTimeIdeaStatus == 'null' || selectedTopAllTimeIdeaStatus == null || selectedTopAllTimeIdeaStatus == '' || selectedTopAllTimeIdeaStatus == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedTopAllTimeIdeaStatus != null || selectedTopAllTimeIdeaStatus != 'null' || selectedTopAllTimeIdeaStatus != '' || selectedTopAllTimeIdeaStatus != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Status =' + '\'' + selectedTopAllTimeIdeaStatus + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        
        if(selectedTopAllTimeDevice == 'null' || selectedTopAllTimeDevice == null || selectedTopAllTimeDevice == '' || selectedTopAllTimeDevice == 'All') {
            dynamicSearchQuery = dynamicSearchQuery;
        } else if(selectedTopAllTimeDevice != null || selectedTopAllTimeDevice != 'null' || selectedTopAllTimeDevice != '' || selectedTopAllTimeDevice != 'All') {
            dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c =' + '\'' + selectedTopAllTimeDevice + '\'';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        dynamicSearchQuery = dynamicSearchQuery + ' ORDER BY VoteTotal desc Limit 20';
        system.debug('***dynamicSearchQuery TopAllTime = ' + dynamicSearchQuery);
        TopAllTimeIdeasViewAllList = database.query(dynamicSearchQuery );
        return TopAllTimeIdeasViewAllList; //[select id , Body , Status , Title , VoteScore, CreatedBy.Name, Di_Idea_Featured_Image__c from Idea ORDER BY VoteScore desc];
    }    
    
    /*
    *    @description:    get all Comment ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Idea> getAllCommentIdeas() {
        String selectedCommentDevice;
        
        /* SOQL query if user is not searching item from search text box.
         * if in URL 'searchItemVal' parameter is not numll, it means search need to apply.
         * For searching we are using SOSL.
         * If user directly come to ViewAllIdeaPage and clicks on All Idea tab than records will be fetched using SOQL query.
         */
         List<Idea> CommentIdeasViewAllList = new List<Idea>();
        if(ApexPages.currentPage().getParameters().get('searchItemVal') != null && ApexPages.currentPage().getParameters().get('searchItemVal') != '') {
            if(isValChanged == true) {      
                if(ApexPages.currentPage().getParameters().get('lob') != null) {
                    selectedCommentLineOfBusiness = selectedCommentLineOfBusiness.escapeHTML4();
                }
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    selectedCommentCategory  = selectedCommentCategory.escapeHTML4();
                }
                if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'AllIdeas') {
                    selectedCommentIdeaStatus  = selectedCommentIdeaStatus.escapeHTML4();
                }
                if(ApexPages.currentPage().getParameters().get('dev') != null) {
                    selectedCommentDevice = selectedCommentDevice;
                }
                if(selectedCommentLineOfBusiness == 'All' || selectedCommentLineOfBusiness == '' || selectedCommentLineOfBusiness == null) {
                    selectedCommentCategory = 'All';
                }
            } else {     
                if(ApexPages.currentPage().getParameters().get('lob') != null) {
                    selectedCommentLineOfBusiness = ApexPages.currentPage().getParameters().get('lob');
                }
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') {
                    selectedCommentCategory = 'User Profile Settings';
                }
                if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'AllIdeas') {
                    selectedCommentIdeaStatus  = ApexPages.currentPage().getParameters().get('chan');
                }   
                if(ApexPages.currentPage().getParameters().get('dev') != null) {
                    selectedCommentDevice = ApexPages.currentPage().getParameters().get('dev');
                }
            }
            
            
            if(ApexPages.currentPage().getParameters().get('searchItemVal') != null) {
                searchItemValue = ApexPages.currentPage().getParameters().get('searchItemVal');
            }
            
                        
            String dynamicSearchQuery;
            System.debug('###'+searchItemValue+'###'+searchItemValue.length());
            
            dynamicSearchQuery = 'FIND : searchItemValue IN ALL FIELDS RETURNING Idea (id , Body, Title, CreatedBy.Name,Createdby.Title, Di_Idea_Featured_Image__c, DI_Idea_Line_of_Business__c, Di_Idea_Category__c, Status, VoteScore, CreatedDate, CreatedById, VoteTotal, CreatedBy.pics__c, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c, Di_Idea_Channel__c WHERE id != null';
            /*
            if(selectedCommentLineOfBusiness == 'null' || selectedCommentLineOfBusiness == null || selectedCommentLineOfBusiness == '' || selectedCommentLineOfBusiness == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if(selectedCommentLineOfBusiness != null || selectedCommentLineOfBusiness  != 'null' || selectedCommentLineOfBusiness != '' || selectedCommentLineOfBusiness != 'All') {
                dynamicSearchQuery = dynamicSearchQuery + ' AND DI_Idea_Line_of_Business__c =' + '\'' + selectedCommentLineOfBusiness + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            if(selectedCommentCategory == 'null' || selectedCommentCategory == null || selectedCommentCategory == '' || selectedCommentCategory == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if((selectedCommentCategory != null || selectedCommentCategory != 'null' || selectedCommentCategory != '' || selectedCommentCategory != 'All') && (selectedCommentLineOfBusiness == 'null' || selectedCommentLineOfBusiness == null || selectedCommentLineOfBusiness == '' || selectedCommentLineOfBusiness == 'All')) {
                dynamicSearchQuery = dynamicSearchQuery;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select a Line of Business.'));
            } else if((selectedCommentCategory != null || selectedCommentCategory != 'null' || selectedCommentCategory != '' || selectedCommentCategory != 'All') && (selectedCommentLineOfBusiness != 'null' || selectedCommentLineOfBusiness != null || selectedCommentLineOfBusiness != '' || selectedCommentLineOfBusiness != 'All')) {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Category__c =' + '\'' + selectedCommentCategory + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            if(selectedCommentIdeaStatus == 'null' || selectedCommentIdeaStatus == null || selectedCommentIdeaStatus == '' || selectedCommentIdeaStatus == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if(selectedCommentIdeaStatus != null || selectedCommentIdeaStatus != 'null' || selectedCommentIdeaStatus != '' || selectedCommentIdeaStatus != 'All') {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Status =' + '\'' + selectedCommentIdeaStatus + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            
            
            if(selectedCommentDevice == 'null' || selectedCommentDevice == null || selectedCommentDevice == '' || selectedCommentDevice == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if(selectedCommentDevice != null || selectedCommentDevice != 'null' || selectedCommentDevice != '' || selectedCommentDevice != 'All') {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c =' + '\'' + selectedCommentDevice + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            */
            dynamicSearchQuery = dynamicSearchQuery + ' LIMIT 200)';
            system.debug('***dynamicSearchQuery Comment = ' + dynamicSearchQuery);
            List<List<sObject>> searchIdeaList = new List<List<sObject>>(); 
            if(searchItemValue == null || searchItemValue.length() == 1) {
                return CommentIdeasViewAllList ;
            }
            searchIdeaList = search.query(dynamicSearchQuery);
            if (searchIdeaList.size() > 0) {
              CommentIdeasViewAllList = (List<Idea>)searchIdeaList[0];
            }
        } else {
                if(isValChanged == true) {      
                if(ApexPages.currentPage().getParameters().get('lob') != null) {
                    selectedCommentLineOfBusiness = selectedCommentLineOfBusiness.escapeHTML4();
                }
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    selectedCommentCategory  = selectedCommentCategory.escapeHTML4();
                }
                if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'AllIdeas') {
                    selectedCommentIdeaStatus  = selectedCommentIdeaStatus.escapeHTML4();
                }
                if(ApexPages.currentPage().getParameters().get('dev') != null) {
                    selectedCommentDevice = selectedCommentDevice.escapeHTML4();
                }
                if(selectedCommentLineOfBusiness == 'All' || selectedCommentLineOfBusiness == '' || selectedCommentLineOfBusiness == null) {
                    selectedCommentCategory = 'All';
                }
            } else {     
                if(ApexPages.currentPage().getParameters().get('lob') != null) {
                    selectedCommentLineOfBusiness = ApexPages.currentPage().getParameters().get('lob');
                }
                if(ApexPages.currentPage().getParameters().get('cat') != null) {
                    selectedCommentCategory = ApexPages.currentPage().getParameters().get('cat');
                } else if(ApexPages.currentPage().getParameters().get('cat') == 'User Profile Settings') {
                    selectedCommentCategory = 'User Profile Settings';
                }
                if(ApexPages.currentPage().getParameters().get('chan') != null && ApexPages.currentPage().getParameters().get('selectTab') == 'AllIdeas') {
                    selectedCommentIdeaStatus  = ApexPages.currentPage().getParameters().get('chan');
                }   
                if(ApexPages.currentPage().getParameters().get('dev') != null) {
                    selectedCommentDevice = ApexPages.currentPage().getParameters().get('dev');
                }
            }
            
            
            if(ApexPages.currentPage().getParameters().get('searchItemVal') != null) {
                searchItemValue = ApexPages.currentPage().getParameters().get('searchItemVal');
            }
                    
            String dynamicSearchQuery;
            dynamicSearchQuery = 'SELECT id , Body, Title, CreatedBy.Name,Createdby.Title, Di_Idea_Featured_Image__c, DI_Idea_Line_of_Business__c, Di_Idea_Category__c, Status, VoteScore, CreatedDate, CreatedById, VoteTotal, CreatedBy.pics__c, CreatedBy.ProfileId, CreatedBy.DI_Fi_Name__c, Di_Idea_Channel__c from Idea WHERE id != null';
                    
            /*if(ApexPages.currentPage().getParameters().get('chan') != null) {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c = '+ '\'' + ApexPages.currentPage().getParameters().get('chan') + '\'';
            }*/
            
            /* ----- implementing SOSL query section in this methods so commenting below code on Feb 26, 2016 ---
             
            if(ApexPages.currentPage().getParameters().get('searchItemVal') != null) {
                List<String> partsList = new List<String>();
                List<String> parts = searchItemValue.split(' ');
                for(String s : parts) {
                    s = ' ' + s + ' ';
                    String s2 = s.replaceAll(' ', '%');
                    if(s2.length() > 2) {
                        partsList.add(s2);
                    } else {}
                }
                dynamicSearchQuery = dynamicSearchQuery + ' AND Title LIKE: partsList';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            */
            
            if(selectedCommentLineOfBusiness == 'null' || selectedCommentLineOfBusiness == null || selectedCommentLineOfBusiness == '' || selectedCommentLineOfBusiness == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if(selectedCommentLineOfBusiness != null || selectedCommentLineOfBusiness  != 'null' || selectedCommentLineOfBusiness != '' || selectedCommentLineOfBusiness != 'All') {
                dynamicSearchQuery = dynamicSearchQuery + ' AND DI_Idea_Line_of_Business__c =' + '\'' + selectedCommentLineOfBusiness + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            if(selectedCommentCategory == 'null' || selectedCommentCategory == null || selectedCommentCategory == '' || selectedCommentCategory == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if((selectedCommentCategory != null || selectedCommentCategory != 'null' || selectedCommentCategory != '' || selectedCommentCategory != 'All') && (selectedCommentLineOfBusiness == 'null' || selectedCommentLineOfBusiness == null || selectedCommentLineOfBusiness == '' || selectedCommentLineOfBusiness == 'All')) {
                dynamicSearchQuery = dynamicSearchQuery;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please select a Line of Business.'));
            } else if((selectedCommentCategory != null || selectedCommentCategory != 'null' || selectedCommentCategory != '' || selectedCommentCategory != 'All') && (selectedCommentLineOfBusiness != 'null' || selectedCommentLineOfBusiness != null || selectedCommentLineOfBusiness != '' || selectedCommentLineOfBusiness != 'All')) {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Category__c =' + '\'' + selectedCommentCategory + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            if(selectedCommentIdeaStatus == 'null' || selectedCommentIdeaStatus == null || selectedCommentIdeaStatus == '' || selectedCommentIdeaStatus == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if(selectedCommentIdeaStatus != null || selectedCommentIdeaStatus != 'null' || selectedCommentIdeaStatus != '' || selectedCommentIdeaStatus != 'All') {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Status =' + '\'' + selectedCommentIdeaStatus + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            
            
            if(selectedCommentDevice == 'null' || selectedCommentDevice == null || selectedCommentDevice == '' || selectedCommentDevice == 'All') {
                dynamicSearchQuery = dynamicSearchQuery;
            } else if(selectedCommentDevice != null || selectedCommentDevice != 'null' || selectedCommentDevice != '' || selectedCommentDevice != 'All') {
                dynamicSearchQuery = dynamicSearchQuery + ' AND Di_Idea_Channel__c =' + '\'' + selectedCommentDevice + '\'';
            } else {
                dynamicSearchQuery = dynamicSearchQuery;
            }
            
            dynamicSearchQuery = dynamicSearchQuery + ' ORDER BY CreatedDate desc LIMIT 200';
            system.debug('***dynamicSearchQuery Comment = ' + dynamicSearchQuery);
            CommentIdeasViewAllList = database.query(dynamicSearchQuery);
        }
        
        return CommentIdeasViewAllList; //[select id , Body , Status , Title , VoteScore, CreatedBy.Name, Di_Idea_Featured_Image__c from Idea ORDER BY VoteScore desc];
    }
    
    /*
    *    @description:    get all search results ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Idea> getAllSearchResultIdeas() {
        if(ApexPages.currentPage().getParameters().get('searchItemVal') != null) {
            searchItemValue = ApexPages.currentPage().getParameters().get('searchItemVal');
        }
        
        List<Idea> searchResultIdeasViewAllList = new List<Idea>();
        
        if (searchItemValue == null || searchItemValue.length() == 1 ) {
            return searchResultIdeasViewAllList;
        }
        
        String dynamicSearchQuery;
        dynamicSearchQuery = 'SELECT id , Body, Title, CreatedBy.Name,Createdby.Title, Di_Idea_Featured_Image__c, DI_Idea_Line_of_Business__c, Di_Idea_Category__c, Status, VoteScore, CreatedDate, CreatedById, VoteTotal, CreatedBy.pics__c, Di_Idea_Channel__c from Idea WHERE id != null';
                        
        if(searchItemValue != null) {
            List<String> partsList = new List<String>();
            List<String> parts = searchItemValue.split(' ');
            for(String s : parts) {
                s = ' ' + s + ' ';
                String s2 = s.replaceAll(' ', '%');
                if(s2.length() > 2) {
                    partsList.add(s2);
                } /*else {} commented empty block statement */
            }
            dynamicSearchQuery = dynamicSearchQuery + ' AND Title LIKE: partsList';
        } else {
            dynamicSearchQuery = dynamicSearchQuery;
        }
        
        dynamicSearchQuery = dynamicSearchQuery + ' ORDER BY VoteScore desc LIMIT 20';
        system.debug('***dynamicSearchQuery Search Result = ' + dynamicSearchQuery);
        searchResultIdeasViewAllList = database.query(dynamicSearchQuery);
        return searchResultIdeasViewAllList;
    }    
    
    
    
    
    /**********     SET LINE OF BUSINESS VALUES ON CLICK OF STATUS LINE LINKS   **********/        
    /*
    *    @description:    set line of business value recent.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference gotoSetLOBRecent() {
        system.debug('\n\n*****ENTER gotoSetLOBRecent*****\n\n');
        String addToURL;
        if(selectedRecentCategory == 'General Business Banking' || 
            selectedRecentCategory == 'ACH and Wires' || 
            selectedRecentCategory == 'Entitlements' || 
            selectedRecentCategory == 'Third Party Product Integration' || 
            //selectedRecentCategory == 'Deposit Accounts' || 
            //selectedRecentCategory == 'Other Accounts' ||
			selectedRecentCategory == 'Customer Support' ||
			selectedRecentCategory == 'Remote Deposit' ||
			selectedRecentCategory == 'Reporting' ||
			selectedRecentCategory == 'Alerts' ||
			selectedRecentCategory == 'Positive Pay' ||
			selectedRecentCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Business%20Banking';
        } else if(selectedRecentCategory == 'Promotion Suite' || 
                    selectedRecentCategory == 'Web Center' || 
                    selectedRecentCategory == 'Purchase Rewards' || 
                    //selectedRecentCategory == 'Online Account Opening' || 
                    //selectedRecentCategory == 'Other' ||
					selectedRecentCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(selectedRecentCategory == 'General Payments' || 
                    selectedRecentCategory == 'Bill Pay' || 
                    selectedRecentCategory == 'External Funds Transfer' || 
                    //selectedRecentCategory == 'Pop Money' ||
					selectedRecentCategory == 'Person to Person Payments' ||
					selectedRecentCategory == 'Internal Transfers' ||
					selectedRecentCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Money%20Movement';
                    } else if(selectedRecentCategory == 'General Admin Platform' || 
                              //selectedRecentCategory == 'End User Support' || 
                              selectedRecentCategory == 'Branding and Flexibility' || 
                              //selectedRecentCategory == 'Admin Platform User Management and Security' || 
                              //selectedRecentCategory == 'Reporting' || 
                              //selectedRecentCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedRecentCategory == 'Interfaces' || 
                              //selectedRecentCategory == 'Security' || 
                              //selectedRecentCategory == 'Other' || 
                              selectedRecentCategory == 'Idea Exchange' ||
                              
                              selectedRecentCategory == 'Admin User Support' || 
                              selectedRecentCategory == 'Data & Reporting' || 
                              selectedRecentCategory == 'SSO and API Solutions ' || 
                              selectedRecentCategory == 'Security & Authentication' || 
                              selectedRecentCategory == 'Idea Exchange' || 
                              selectedRecentCategory == 'Alerts & Communication' || 
                              selectedRecentCategory == 'Account Opening' || 
                              selectedRecentCategory == 'Registration' || 
                              selectedRecentCategory == 'Web/Direct Connect' || 
                              selectedRecentCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedRecentCategory == 'Online Forms' || 
                              selectedRecentCategory == 'Client Services Developed Solutions')
                    {
                        addToURL = '&lob=Platform%20Solutions';
                    } else if(selectedRecentCategory == 'General Retail Banking' || 
                              //selectedRecentCategory == 'General Digital Banking' || 
                              selectedRecentCategory == 'Alerts & Communication' || 
                              selectedRecentCategory == 'User Profile Settings' || 
                              selectedRecentCategory == 'Check/Deposit Imaging' ||
                              selectedRecentCategory == 'Customer Support' || 
                              selectedRecentCategory == 'Money Management' || 
                              selectedRecentCategory == 'Online Statements' ||
                              selectedRecentCategory == 'Remote Deposit' ||
                              selectedRecentCategory == 'Shared Access' || 
                              selectedRecentCategory == 'Card Management' ||  
                              
                              //selectedRecentCategory == 'Deposit Accounts' || 
                              //selectedRecentCategory == 'Other Accounts' || 
                              //selectedRecentCategory == 'Authentication & Settings' || 
                              //selectedRecentCategory == 'Alerts' || 
                              //selectedRecentCategory == 'Transfers' || 
                              //selectedRecentCategory == 'Online Statements' || 
                              //selectedRecentCategory == 'Registration' || 
                              
                              
                              //selectedRecentCategory == 'Web/Direct Connect' || 
                              //selectedRecentCategory == 'Check/Deposit Imaging' ||
                              selectedRecentCategory == 'Financial Wellness' ||
                              selectedRecentCategory == 'Client Services Developed Solutions') 
                        
                    {
                        addToURL = '&lob=Retail%20Banking';
        } else {
            addToURL = '';
        }
        
        if(ApexPages.currentPage().getParameters().get('selectTab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('selectTab');
        } else {
            selectedTab = 'AllIdeas';
        }
    
        if(selectedRecentCategory == 'User Profile Settings') {
            String categoryReplacement = 'User Profile Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + selectedRecentCategory + addToURL + '&selectTab=AllIdeas');
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }    
        
    /*
    *    @description:    set line of business value popular.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference gotoSetLOBPopular() {
        system.debug('\n\n*****ENTER gotoSetLOBPopular*****\n\n');
        String addToURL;
        if(selectedPopularCategory == 'General Business Banking' || 
            selectedPopularCategory == 'ACH and Wires' || 
            selectedPopularCategory == 'Entitlements' || 
            selectedPopularCategory == 'Third Party Product Integration' || 
            //selectedPopularCategory == 'Deposit Accounts' || 
            //selectedPopularCategory == 'Other Accounts' ||
			selectedPopularCategory == 'Customer Support' ||
			selectedPopularCategory == 'Remote Deposit' ||
			selectedPopularCategory == 'Reporting' ||
			selectedPopularCategory == 'Alerts' ||
			selectedPopularCategory == 'Positive Pay' ||
			selectedPopularCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Business%20Banking';
        } else if(selectedPopularCategory == 'Promotion Suite' || 
                    selectedPopularCategory == 'Web Center' || 
                    selectedPopularCategory == 'Purchase Rewards' || 
                    //selectedPopularCategory == 'Online Account Opening' || 
                    //selectedPopularCategory == 'Other' ||
					selectedPopularCategory == 'Client Services Developed Solutions')  {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(selectedPopularCategory == 'General Payments' || 
                    selectedPopularCategory == 'Bill Pay' || 
                    selectedPopularCategory == 'External Funds Transfer' || 
                    //selectedPopularCategory == 'Pop Money' ||
					selectedPopularCategory == 'Person to Person Payments' ||
					selectedPopularCategory == 'Internal Transfers' ||
					selectedPopularCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Money%20Movement';
                    } else if(selectedPopularCategory == 'General Admin Platform' || 
                              //selectedPopularCategory == 'End User Support' || 
                              selectedPopularCategory == 'Branding and Flexibility' || 
                              //selectedPopularCategory == 'Admin Platform User Management and Security' || 
                              //selectedPopularCategory == 'Reporting' || 
                              //selectedPopularCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedPopularCategory == 'Interfaces' || 
                              //selectedPopularCategory == 'Security' || 
                              //selectedPopularCategory == 'Other' || 
                              selectedPopularCategory == 'Idea Exchange' ||
                              
                              selectedPopularCategory == 'Admin User Support' || 
                              selectedPopularCategory == 'Data & Reporting' || 
                              selectedPopularCategory == 'SSO and API Solutions ' || 
                              selectedPopularCategory == 'Security & Authentication' || 
                              selectedPopularCategory == 'Idea Exchange' || 
                              selectedPopularCategory == 'Alerts & Communication' || 
                              selectedPopularCategory == 'Account Opening' || 
                              selectedPopularCategory == 'Registration' || 
                              selectedPopularCategory == 'Web/Direct Connect' || 
                              selectedPopularCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedPopularCategory == 'Online Forms' || 
                              selectedPopularCategory == 'Client Services Developed Solutions')
                    {
                        addToURL = '&lob=Platform%20Solutions';
                    } else if(selectedPopularCategory == 'General Retail Banking' || 
                              //selectedPopularCategory == 'General Digital Banking' || 
                              selectedPopularCategory == 'Alerts & Communication' || 
                              selectedPopularCategory == 'User Profile Settings' || 
                              selectedPopularCategory == 'Check/Deposit Imaging' ||
                              selectedPopularCategory == 'Customer Support' || 
                              selectedPopularCategory == 'Money Management' || 
                              selectedPopularCategory == 'Online Statements' ||
                              selectedPopularCategory == 'Remote Deposit' ||
                              selectedPopularCategory == 'Shared Access' || 
                              selectedPopularCategory == 'Card Management' ||  
                              
                              //selectedPopularCategory == 'Deposit Accounts' || 
                              //selectedPopularCategory == 'Other Accounts' || 
                              //selectedPopularCategory == 'Authentication & Settings' || 
                              //selectedPopularCategory == 'Alerts' || 
                              //selectedPopularCategory == 'Transfers' || 
                              //selectedPopularCategory == 'Online Statements' || 
                              //selectedPopularCategory == 'Registration' || 
                              
                              
                              //selectedPopularCategory == 'Web/Direct Connect' || 
                              //selectedPopularCategory == 'Check/Deposit Imaging' ||
                              selectedPopularCategory == 'Financial Wellness' ||
                              selectedPopularCategory == 'Client Services Developed Solutions') 

                    {
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
    
        if(selectedPopularCategory == 'User Profile Settings') {
            String categoryReplacement = 'User Profile Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + selectedPopularCategory + addToURL + '&selectTab=AllIdeas');
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }
        
    /*
    *    @description:    set line of business value TopAllTime.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference gotoSetLOBTopAllTime() {
        system.debug('\n\n*****ENTER gotoSetLOBTopAllTime*****\n\n');
        String addToURL;
        if(selectedTopAllTimeCategory == 'General Business Banking' || 
            selectedTopAllTimeCategory == 'ACH and Wires' || 
            selectedTopAllTimeCategory == 'Entitlements' || 
            selectedTopAllTimeCategory == 'Third Party Product Integration' || 
            //selectedTopAllTimeCategory == 'Deposit Accounts' || 
            //selectedTopAllTimeCategory == 'Other Accounts' ||
			selectedTopAllTimeCategory == 'Customer Support' ||
			selectedTopAllTimeCategory == 'Remote Deposit' ||
			selectedTopAllTimeCategory == 'Reporting' ||
			selectedTopAllTimeCategory == 'Alerts' ||
			selectedTopAllTimeCategory == 'Positive Pay' ||
			selectedTopAllTimeCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Business%20Banking';
        } else if(selectedTopAllTimeCategory == 'Promotion Suite' || 
                    selectedTopAllTimeCategory == 'Web Center' || 
                    selectedTopAllTimeCategory == 'Purchase Rewards' || 
                    //selectedTopAllTimeCategory == 'Online Account Opening' || 
                    //selectedTopAllTimeCategory == 'Other' ||
					selectedTopAllTimeCategory == 'Client Services Developed Solutions')  {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(selectedTopAllTimeCategory == 'General Payments' || 
                    selectedTopAllTimeCategory == 'Bill Pay' || 
                    selectedTopAllTimeCategory == 'External Funds Transfer' || 
                    //selectedTopAllTimeCategory == 'Pop Money' ||
					selectedTopAllTimeCategory == 'Person to Person Payments' ||
					selectedTopAllTimeCategory == 'Internal Transfers' ||
					selectedTopAllTimeCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Money%20Movement';
                    } else if(selectedTopAllTimeCategory == 'General Admin Platform' || 
                              //selectedTopAllTimeCategory == 'End User Support' || 
                              selectedTopAllTimeCategory == 'Branding and Flexibility' || 
                              //selectedTopAllTimeCategory == 'Admin Platform User Management and Security' || 
                              //selectedTopAllTimeCategory == 'Reporting' || 
                              //selectedTopAllTimeCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedTopAllTimeCategory == 'Interfaces' || 
                              //selectedTopAllTimeCategory == 'Security' || 
                              //selectedTopAllTimeCategory == 'Other' || 
                              selectedTopAllTimeCategory == 'Idea Exchange' ||
                              
                              selectedTopAllTimeCategory == 'Admin User Support' || 
                              selectedTopAllTimeCategory == 'Data & Reporting' || 
                              selectedTopAllTimeCategory == 'SSO and API Solutions ' || 
                              selectedTopAllTimeCategory == 'Security & Authentication' || 
                              selectedTopAllTimeCategory == 'Idea Exchange' || 
                              selectedTopAllTimeCategory == 'Alerts & Communication' || 
                              selectedTopAllTimeCategory == 'Account Opening' || 
                              selectedTopAllTimeCategory == 'Registration' || 
                              selectedTopAllTimeCategory == 'Web/Direct Connect' || 
                              selectedTopAllTimeCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedTopAllTimeCategory == 'Online Forms' || 
                              selectedTopAllTimeCategory == 'Client Services Developed Solutions')
                    {
                        addToURL = '&lob=Platform%20Solutions';
                    } else if(selectedTopAllTimeCategory == 'General Retail Banking' || 
                              //selectedTopAllTimeCategory == 'General Digital Banking' || 
                              selectedTopAllTimeCategory == 'Alerts & Communication' || 
                              selectedTopAllTimeCategory == 'User Profile Settings' || 
                              selectedTopAllTimeCategory == 'Check/Deposit Imaging' ||
                              selectedTopAllTimeCategory == 'Customer Support' || 
                              selectedTopAllTimeCategory == 'Money Management' || 
                              selectedTopAllTimeCategory == 'Online Statements' ||
                              selectedTopAllTimeCategory == 'Remote Deposit' ||
                              selectedTopAllTimeCategory == 'Shared Access' || 
                              selectedTopAllTimeCategory == 'Card Management' ||  
                              
                              //selectedTopAllTimeCategory == 'Deposit Accounts' || 
                              //selectedTopAllTimeCategory == 'Other Accounts' || 
                              //selectedTopAllTimeCategory == 'Authentication & Settings' || 
                              //selectedTopAllTimeCategory == 'Alerts' || 
                              //selectedTopAllTimeCategory == 'Transfers' || 
                              //selectedTopAllTimeCategory == 'Online Statements' || 
                              //selectedTopAllTimeCategory == 'Registration' || 
                              
                              
                              //selectedTopAllTimeCategory == 'Web/Direct Connect' || 
                              //selectedTopAllTimeCategory == 'Check/Deposit Imaging' ||
                              selectedTopAllTimeCategory == 'Financial Wellness' ||
                              selectedTopAllTimeCategory == 'Client Services Developed Solutions') 
                        
                    {
                        addToURL = '&lob=Retail%20Banking';
                    } else {
            addToURL = '';
        }
        
        String selectedTab;
        if(ApexPages.currentPage().getParameters().get('selectTab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('selectTab');
        } else {
            selectedTab = 'TopAllTime';
        }
    
        if(selectedTopAllTimeCategory == 'User Profile Settings') {
            String categoryReplacement = 'User Profile Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + selectedTopAllTimeCategory + addToURL + '&selectTab=AllIdeas');
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }
        
    /*
    *    @description:    set line of business value Comment.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference gotoSetLOBComment() {
        system.debug('\n\n*****ENTER gotoSetLOBComment*****\n\n');
        String addToURL;
        if(selectedCommentCategory == 'General Business Banking' || 
            selectedCommentCategory == 'ACH and Wires' || 
            selectedCommentCategory == 'Entitlements' || 
            selectedCommentCategory == 'Third Party Product Integration' || 
            //selectedCommentCategory == 'Deposit Accounts' || 
            //selectedCommentCategory == 'Other Accounts' ||
			selectedCommentCategory == 'Customer Support' ||
			selectedCommentCategory == 'Remote Deposit' ||
			selectedCommentCategory == 'Reporting' ||
			selectedCommentCategory == 'Alerts' ||
			selectedCommentCategory == 'Positive Pay' ||
			selectedCommentCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Business%20Banking';
        } else if(selectedCommentCategory == 'Promotion Suite' || 
                    selectedCommentCategory == 'Web Center' || 
                    selectedCommentCategory == 'Purchase Rewards' || 
                    //selectedCommentCategory == 'Online Account Opening' || 
                    //selectedCommentCategory == 'Other' ||
					selectedCommentCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(selectedCommentCategory == 'General Payments' || 
                    selectedCommentCategory == 'Bill Pay' || 
                    selectedCommentCategory == 'External Funds Transfer' || 
                    //selectedCommentCategory == 'Pop Money' ||
					selectedCommentCategory == 'Person to Person Payments' ||
					selectedCommentCategory == 'Internal Transfers' ||
					selectedCommentCategory == 'Client Services Developed Solutions'){
                addToURL = '&lob=Money%20Movement';
                    } else if(selectedCommentCategory == 'General Admin Platform' || 
                              //selectedCommentCategory == 'End User Support' || 
                              selectedCommentCategory == 'Branding and Flexibility' || 
                              //selectedCommentCategory == 'Admin Platform User Management and Security' || 
                              //selectedCommentCategory == 'Reporting' || 
                              //selectedCommentCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedCommentCategory == 'Interfaces' || 
                              //selectedCommentCategory == 'Security' || 
                              //selectedCommentCategory == 'Other' || 
                              selectedCommentCategory == 'Idea Exchange' ||
                              
                              selectedCommentCategory == 'Admin User Support' || 
                              selectedCommentCategory == 'Data & Reporting' || 
                              selectedCommentCategory == 'SSO and API Solutions ' || 
                              selectedCommentCategory == 'Security & Authentication' || 
                              selectedCommentCategory == 'Idea Exchange' || 
                              selectedCommentCategory == 'Alerts & Communication' || 
                              selectedCommentCategory == 'Account Opening' || 
                              selectedCommentCategory == 'Registration' || 
                              selectedCommentCategory == 'Web/Direct Connect' || 
                              selectedCommentCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedCommentCategory == 'Online Forms' || 
                              selectedCommentCategory == 'Client Services Developed Solutions')
                    {
                        addToURL = '&lob=Platform%20Solutions';
                    } else if(selectedCommentCategory == 'General Retail Banking' || 
                              //selectedCommentCategory == 'General Digital Banking' || 
                              selectedCommentCategory == 'Alerts & Communication' || 
                              selectedCommentCategory == 'User Profile Settings' || 
                              selectedCommentCategory == 'Check/Deposit Imaging' ||
                              selectedCommentCategory == 'Customer Support' || 
                              selectedCommentCategory == 'Money Management' || 
                              selectedCommentCategory == 'Online Statements' ||
                              selectedCommentCategory == 'Remote Deposit' ||
                              selectedCommentCategory == 'Shared Access' || 
                              selectedCommentCategory == 'Card Management' ||  
                              
                              //selectedCommentCategory == 'Deposit Accounts' || 
                              //selectedCommentCategory == 'Other Accounts' || 
                              //selectedCommentCategory == 'Authentication & Settings' || 
                              //selectedCommentCategory == 'Alerts' || 
                              //selectedCommentCategory == 'Transfers' || 
                              //selectedCommentCategory == 'Online Statements' || 
                              //selectedCommentCategory == 'Registration' || 
                              
                              
                              //selectedCommentCategory == 'Web/Direct Connect' || 
                              //selectedCommentCategory == 'Check/Deposit Imaging' ||
                              selectedCommentCategory == 'Financial Wellness' ||
                              selectedCommentCategory == 'Client Services Developed Solutions') 
                    {
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
    
        if(selectedCommentCategory == 'User Profile Settings') {
            String categoryReplacement = 'User Profile Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + selectedCommentCategory + addToURL + '&selectTab=AllIdeas');
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }
        
    /*
    *    @description:    set line of business value SearchResult.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference gotoSetLOBSearchResult() {
        system.debug('\n\n*****ENTER gotoSetLOBSearchResult*****\n\n');
        String addToURL;
        if(selectedSearchResultCategory == 'General Business Banking' || 
            selectedSearchResultCategory == 'ACH and Wires' || 
            selectedSearchResultCategory == 'Entitlements' || 
            selectedSearchResultCategory == 'Third Party Product Integration' || 
            //selectedSearchResultCategory == 'Deposit Accounts' || 
            //selectedSearchResultCategory == 'Other Accounts' ||
			selectedSearchResultCategory == 'Customer Support' ||
			selectedSearchResultCategory == 'Remote Deposit' ||
			selectedSearchResultCategory == 'Reporting' ||
			selectedSearchResultCategory == 'Alerts' ||
			selectedSearchResultCategory == 'Positive Pay' ||
			selectedSearchResultCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Business%20Banking';
        } else if(selectedSearchResultCategory == 'Promotion Suite' || 
                    selectedSearchResultCategory == 'Web Center' || 
                    selectedSearchResultCategory == 'Purchase Rewards' || 
                    //selectedSearchResultCategory == 'Online Account Opening' || 
                    //selectedSearchResultCategory == 'Other' ||
					selectedSearchResultCategory == 'Client Services Developed Solutions')  {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(selectedSearchResultCategory == 'General Payments' || 
                    selectedSearchResultCategory == 'Bill Pay' || 
                    selectedSearchResultCategory == 'External Funds Transfer' || 
                    //selectedSearchResultCategory == 'Pop Money' ||
					selectedSearchResultCategory == 'Person to Person Payments' ||
					selectedSearchResultCategory == 'Internal Transfers' ||
					selectedSearchResultCategory == 'Client Services Developed Solutions') {
                addToURL = '&lob=Money%20Movement';
                    } else if(selectedSearchResultCategory == 'General Admin Platform' || 
                              //selectedSearchResultCategory == 'End User Support' || 
                              selectedSearchResultCategory == 'Branding and Flexibility' || 
                              //selectedSearchResultCategory == 'Admin Platform User Management and Security' || 
                              //selectedSearchResultCategory == 'Reporting' || 
                              //selectedSearchResultCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedSearchResultCategory == 'Interfaces' || 
                              //selectedSearchResultCategory == 'Security' || 
                              //selectedSearchResultCategory == 'Other' || 
                              selectedSearchResultCategory == 'Idea Exchange' ||
                              
                              selectedSearchResultCategory == 'Admin User Support' || 
                              selectedSearchResultCategory == 'Data & Reporting' || 
                              selectedSearchResultCategory == 'SSO and API Solutions ' || 
                              selectedSearchResultCategory == 'Security & Authentication' || 
                              selectedSearchResultCategory == 'Idea Exchange' || 
                              selectedSearchResultCategory == 'Alerts & Communication' || 
                              selectedSearchResultCategory == 'Account Opening' || 
                              selectedSearchResultCategory == 'Registration' || 
                              selectedSearchResultCategory == 'Web/Direct Connect' || 
                              selectedSearchResultCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedSearchResultCategory == 'Online Forms' || 
                              selectedSearchResultCategory == 'Client Services Developed Solutions')
                    {
                        addToURL = '&lob=Platform%20Solutions';
                    } else if(selectedSearchResultCategory == 'General Retail Banking' || 
                              //selectedSearchResultCategory == 'General Digital Banking' || 
                              selectedSearchResultCategory == 'Alerts & Communication' || 
                              selectedSearchResultCategory == 'User Profile Settings' || 
                              selectedSearchResultCategory == 'Check/Deposit Imaging' ||
                              selectedSearchResultCategory == 'Customer Support' || 
                              selectedSearchResultCategory == 'Money Management' || 
                              selectedSearchResultCategory == 'Online Statements' ||
                              selectedSearchResultCategory == 'Remote Deposit' ||
                              selectedSearchResultCategory == 'Shared Access' || 
                              selectedSearchResultCategory == 'Card Management' ||  
                              
                              //selectedSearchResultCategory == 'Deposit Accounts' || 
                              //selectedSearchResultCategory == 'Other Accounts' || 
                              //selectedSearchResultCategory == 'Authentication & Settings' || 
                              //selectedSearchResultCategory == 'Alerts' || 
                              //selectedSearchResultCategory == 'Transfers' || 
                              //selectedSearchResultCategory == 'Online Statements' || 
                              //selectedSearchResultCategory == 'Registration' || 
                              
                              
                              //selectedSearchResultCategory == 'Web/Direct Connect' || 
                              //selectedSearchResultCategory == 'Check/Deposit Imaging' ||
                              selectedSearchResultCategory == 'Financial Wellness' ||
                              selectedSearchResultCategory == 'Client Services Developed Solutions')  {
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
    
        if(selectedSearchResultCategory == 'User Profile Settings') {
            String categoryReplacement = 'User Profile Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + selectedSearchResultCategory + addToURL + '&selectTab=' + selectedTab);
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }
    
    
    
    
    /**********     METHODS FOR CHANGING PICKLIST VALUES - FILTER - RECENT TAB  **********/
    /*
    *    @description:    action for recent ideas line of business filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String defaultRecentLOBCat {get;set;}
    public void changeRecentLineOfBusiness() {
        system.debug('\n\n*****ENTER changeRecentLineOfBusiness*****\n\n');
        isValChanged = true;
        if(selectedRecentLineOfBusiness == 'Business Banking') {
            defaultRecentLOBCat = 'ACH and Wires';
            selectedRecentCategory = 'All';
        } else if(selectedRecentLineOfBusiness == 'Consumer Relationship') {
            //defaultRecentLOBCat = 'Online Account Opening';
			defaultRecentLOBCat = 'Account Opening';
            selectedRecentCategory = 'All';
        } else if(selectedRecentLineOfBusiness == 'Money Movement') {
            defaultRecentLOBCat = 'Bill Pay';
            selectedRecentCategory = 'All';
        } else if(selectedRecentLineOfBusiness == 'Platform Solutions') {
            //defaultRecentLOBCat = 'Admin Platform User Management and Security';
			defaultRecentLOBCat = 'Security & Authentication';
            selectedRecentCategory = 'All';
        } else if(selectedRecentLineOfBusiness == 'Retail Banking') {
            //defaultRecentLOBCat = 'Alerts';
			defaultRecentLOBCat = 'Alerts & Communication';
            selectedRecentCategory = 'All';
        }
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedRecentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedRecentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1recent=false;
           
       }
       else ShowSubscriptionrecent=false; 
       
       if(selectedRecentLineOfBusiness=='All' || string.isblank(selectedRecentLineOfBusiness) || string.isblank(selectedRecentCategory) || selectedRecentCategory=='All'){
           ShowSubscriptionrecent=false;
           ShowSubscription1recent=false;
       }
        getAllRecentIdeas();
        loadRecentPagination();
        Num2='1';
        if(getAllRecentIdeas().size() == 0) {
            noRecentIdeasView = 'No Records Found.';
        } else {
            noRecentIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for recent ideas category filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changeRecentCategory() {
        system.debug('\n\n*****ENTER changeRecentCategory*****\n\n');
        isValChanged = true;
        Num2='1';
        if(selectedRecentCategory == 'General Business Banking' || 
            selectedRecentCategory == 'ACH and Wires' || 
            selectedRecentCategory == 'Entitlements' || 
            selectedRecentCategory == 'Third Party Product Integration' || 
            //selectedRecentCategory == 'Deposit Accounts' || 
            //selectedRecentCategory == 'Other Accounts' ||
			selectedRecentCategory == 'Customer Support' ||
			selectedRecentCategory == 'Remote Deposit' ||
			selectedRecentCategory == 'Reporting' ||
			selectedRecentCategory == 'Alerts' ||
			selectedRecentCategory == 'Positive Pay' ||
			selectedRecentCategory == 'Client Services Developed Solutions') {
                selectedRecentLineOfBusiness = 'Business Banking';
        } else if(selectedRecentCategory == 'Promotion Suite' || 
                    selectedRecentCategory == 'Web Center' || 
                    selectedRecentCategory == 'Purchase Rewards' || 
                    //selectedRecentCategory == 'Online Account Opening' || 
                    //selectedRecentCategory == 'Other' ||
					selectedRecentCategory == 'Client Services Developed Solutions')  {
                selectedRecentLineOfBusiness = 'Consumer Relationship';
        } else if(selectedRecentCategory == 'General Payments' || 
                    selectedRecentCategory == 'Bill Pay' || 
                    selectedRecentCategory == 'External Funds Transfer' || 
                    //selectedRecentCategory == 'Pop Money' ||
					selectedRecentCategory == 'Person to Person Payments' ||
					selectedRecentCategory == 'Internal Transfers' ||
					selectedRecentCategory == 'Client Services Developed Solutions'){
                selectedRecentLineOfBusiness = 'Money Movement';
                    } else if(selectedRecentCategory == 'General Admin Platform' || 
                              //selectedRecentCategory == 'End User Support' || 
                              selectedRecentCategory == 'Branding and Flexibility' || 
                              //selectedRecentCategory == 'Admin Platform User Management and Security' || 
                              //selectedRecentCategory == 'Reporting' || 
                              //selectedRecentCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedRecentCategory == 'Interfaces' || 
                              //selectedRecentCategory == 'Security' || 
                              //selectedRecentCategory == 'Other' || 
                              selectedRecentCategory == 'Idea Exchange' ||
                              
                              selectedRecentCategory == 'Admin User Support' || 
                              selectedRecentCategory == 'Data & Reporting' || 
                              selectedRecentCategory == 'SSO and API Solutions ' || 
                              selectedRecentCategory == 'Security & Authentication' || 
                              selectedRecentCategory == 'Idea Exchange' || 
                              selectedRecentCategory == 'Alerts & Communication' || 
                              selectedRecentCategory == 'Account Opening' || 
                              selectedRecentCategory == 'Registration' || 
                              selectedRecentCategory == 'Web/Direct Connect' || 
                              selectedRecentCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedRecentCategory == 'Online Forms' || 
                              selectedRecentCategory == 'Client Services Developed Solutions')
                        
                    {
                        selectedRecentLineOfBusiness = 'Platform Solutions';
                    } else if(selectedRecentCategory == 'General Retail Banking' || 
                              //selectedRecentCategory == 'General Digital Banking' || 
                              selectedRecentCategory == 'Alerts & Communication' || 
                              selectedRecentCategory == 'User Profile Settings' || 
                              selectedRecentCategory == 'Check/Deposit Imaging' ||
                              selectedRecentCategory == 'Customer Support' || 
                              selectedRecentCategory == 'Money Management' || 
                              selectedRecentCategory == 'Online Statements' ||
                              selectedRecentCategory == 'Remote Deposit' ||
                              selectedRecentCategory == 'Shared Access' || 
                              selectedRecentCategory == 'Card Management' ||  
                              
                              //selectedRecentCategory == 'Deposit Accounts' || 
                              //selectedRecentCategory == 'Other Accounts' || 
                              //selectedRecentCategory == 'Authentication & Settings' || 
                              //selectedRecentCategory == 'Alerts' || 
                              //selectedRecentCategory == 'Transfers' || 
                              //selectedRecentCategory == 'Online Statements' || 
                              //selectedRecentCategory == 'Registration' || 
                              
                              
                              //selectedRecentCategory == 'Web/Direct Connect' || 
                              //selectedRecentCategory == 'Check/Deposit Imaging' ||
                              selectedRecentCategory == 'Financial Wellness' ||
                              selectedRecentCategory == 'Client Services Developed Solutions') 
                    {
                        selectedRecentLineOfBusiness = 'Retail Banking';
                    } 
list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedRecentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedRecentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1recent=false;
           
       }
       else ShowSubscriptionrecent=false;       
        getAllRecentIdeas();
        loadRecentPagination();
        if(getAllRecentIdeas().size() == 0) {
            noRecentIdeasView = 'No Records Found.';
        } else {
            noRecentIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for recent ideas status filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changeRecentStatus() {
        system.debug('\n\n*****ENTER changeRecentStatus*****\n\n');
        isValChanged = true;
        Num2='1';
        getAllRecentIdeas();
        loadRecentPagination();
        if(getAllRecentIdeas().size() == 0) {
            noRecentIdeasView = 'No Records Found.';
        } else {
            noRecentIdeasView = '';
        }
    }
    
    
    
    
    /**********     METHODS FOR CHANGING PICKLIST VALUES - FILTER - POPULAR TAB **********/
    /*
    *    @description:    action for popular ideas line of business filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String defaultPopularLOBCat {get;set;}
    public void changePopularLineOfBusiness() {
        system.debug('\n\n*****ENTER changePopularLineOfBusiness*****\n\n');
        isValChanged = true;
        if(selectedPopularLineOfBusiness == 'Business Banking') {
            defaultPopularLOBCat = 'ACH and Wires';
            selectedPopularCategory = 'All';
        } else if(selectedPopularLineOfBusiness == 'Consumer Relationship') {
            //defaultPopularLOBCat = 'Online Account Opening';
            defaultPopularLOBCat = 'Account Opening';
            selectedPopularCategory = 'All';
        } else if(selectedPopularLineOfBusiness == 'Money Movement') {
            defaultPopularLOBCat = 'Bill Pay';
            selectedPopularCategory = 'All';
        } else if(selectedPopularLineOfBusiness == 'Platform Solutions') {
            //defaultPopularLOBCat = 'Admin Platform User Management and Security';
             defaultPopularLOBCat = 'Security & Authentication';
            selectedPopularCategory = 'All';
        } else if(selectedPopularLineOfBusiness == 'Retail Banking') {
            //defaultPopularLOBCat = 'Alerts';
           defaultPopularLOBCat = 'Alerts & Communication';
            selectedPopularCategory = 'All';
        }
        Num2='1';
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedPopularLineOfBusiness AND DI_SubscriptionCategory__c=:selectedPopularCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1=false;
           
       }
       else ShowSubscription=false; 
       
       if(selectedPopularLineOfBusiness=='All' || string.isblank(selectedPopularLineOfBusiness) || string.isblank(selectedPopularCategory) || selectedPopularCategory=='All'){
           ShowSubscription=false;
           ShowSubscription1=false;
       }
        getAllPopularIdeas();
        loadPopularPagination();
        if(getAllPopularIdeas().size() == 0) {
            noPopularIdeasView = 'No Records Found.';
        } else {
            noPopularIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for popular ideas category filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changePopularCategory() {
        system.debug('\n\n*****ENTER changePopularCategory*****\n\n');
        isValChanged = true;
        if(selectedPopularCategory == 'General Business Banking' || 
            selectedPopularCategory == 'ACH and Wires' || 
            selectedPopularCategory == 'Entitlements' || 
            selectedPopularCategory == 'Third Party Product Integration' || 
            //selectedPopularCategory == 'Deposit Accounts' || 
            //selectedPopularCategory == 'Other Accounts' ||
			selectedPopularCategory == 'Customer Support' ||
			selectedPopularCategory == 'Remote Deposit' ||
			selectedPopularCategory == 'Reporting' ||
			selectedPopularCategory == 'Alerts' ||
			selectedPopularCategory == 'Positive Pay' ||
			selectedPopularCategory == 'Client Services Developed Solutions') {
                selectedPopularLineOfBusiness = 'Business Banking';
        } else if(selectedPopularCategory == 'Promotion Suite' || 
                    selectedPopularCategory == 'Web Center' || 
                    selectedPopularCategory == 'Purchase Rewards' || 
                    //selectedPopularCategory == 'Online Account Opening' || 
                    //selectedPopularCategory == 'Other' ||
					selectedPopularCategory == 'Client Services Developed Solutions')  {
                selectedPopularLineOfBusiness = 'Consumer Relationship';
        } else if(selectedPopularCategory == 'General Payments' || 
                    selectedPopularCategory == 'Bill Pay' || 
                    selectedPopularCategory == 'External Funds Transfer' || 
                    //selectedPopularCategory == 'Pop Money' ||
					selectedPopularCategory == 'Person to Person Payments' ||
					selectedPopularCategory == 'Internal Transfers' ||
					selectedPopularCategory == 'Client Services Developed Solutions') {
                selectedPopularLineOfBusiness = 'Money Movement';
                    } else if(selectedPopularCategory == 'General Admin Platform' || 
                              //selectedPopularCategory == 'End User Support' || 
                              selectedPopularCategory == 'Branding and Flexibility' || 
                              //selectedPopularCategory == 'Admin Platform User Management and Security' || 
                              //selectedPopularCategory == 'Reporting' || 
                              //selectedPopularCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedPopularCategory == 'Interfaces' || 
                              //selectedPopularCategory == 'Security' || 
                              //selectedPopularCategory == 'Other' || 
                              selectedPopularCategory == 'Idea Exchange' ||
                              
                              selectedPopularCategory == 'Admin User Support' || 
                              selectedPopularCategory == 'Data & Reporting' || 
                              selectedPopularCategory == 'SSO and API Solutions ' || 
                              selectedPopularCategory == 'Security & Authentication' || 
                              selectedPopularCategory == 'Idea Exchange' || 
                              selectedPopularCategory == 'Alerts & Communication' || 
                              selectedPopularCategory == 'Account Opening' || 
                              selectedPopularCategory == 'Registration' || 
                              selectedPopularCategory == 'Web/Direct Connect' || 
                              selectedPopularCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedPopularCategory == 'Online Forms' || 
                              selectedPopularCategory == 'Client Services Developed Solutions'){
                                  selectedPopularLineOfBusiness = 'Platform Solutions';
                              } else if(
                                  selectedPopularCategory == 'General Retail Banking' || 
                                  //selectedPopularCategory == 'General Digital Banking' || 
                                  selectedPopularCategory == 'Alerts & Communication' || 
                                  selectedPopularCategory == 'User Profile Settings' || 
                                  selectedPopularCategory == 'Check/Deposit Imaging' ||
                                  selectedPopularCategory == 'Customer Support' || 
                                  selectedPopularCategory == 'Money Management' || 
                                  selectedPopularCategory == 'Online Statements' ||
                                  selectedPopularCategory == 'Remote Deposit' ||
                                  selectedPopularCategory == 'Shared Access' || 
                                  selectedPopularCategory == 'Card Management' ||  
                                  
                                  //selectedPopularCategory == 'Deposit Accounts' || 
                                  //selectedPopularCategory == 'Other Accounts' || 
                                  //selectedPopularCategory == 'Authentication & Settings' || 
                                  //selectedPopularCategory == 'Alerts' || 
                                  //selectedPopularCategory == 'Transfers' || 
                                  //selectedPopularCategory == 'Online Statements' || 
                                  //selectedPopularCategory == 'Registration' || 
                                  
                                  
                                  //selectedPopularCategory == 'Web/Direct Connect' || 
                                  //selectedPopularCategory == 'Check/Deposit Imaging' ||
                                  selectedPopularCategory == 'Financial Wellness' ||
                                  selectedPopularCategory == 'Client Services Developed Solutions') 
                                  
                              {
                                  selectedPopularLineOfBusiness = 'Retail Banking';
                              }
        Num2='1';
         list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedPopularLineOfBusiness AND DI_SubscriptionCategory__c=:selectedPopularCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1=false;
           
       }
       else ShowSubscription=false;
        getAllPopularIdeas();
        loadPopularPagination();
        if(getAllPopularIdeas().size() == 0) {
            noPopularIdeasView = 'No Records Found.';
        } else {
            noPopularIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for popular ideas status filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changePopularStatus() {
        system.debug('\n\n*****ENTER changePopularStatus*****\n\n');
        isValChanged = true;
        Num2='1';
        getAllPopularIdeas();
        loadPopularPagination();
        if(getAllPopularIdeas().size() == 0) {
            noPopularIdeasView = 'No Records Found.';
        } else {
            noPopularIdeasView = '';
        }
    }
    
    
    
    
    /**********     METHODS FOR CHANGING PICKLIST VALUES - FILTER - TOP ALL TIME TAB **********/
    /*
    *    @description:    action for TopAllTime ideas line of business filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String defaultTopAllTimeLOBCat {get;set;}
    public void changeTopAllTimeLineOfBusiness() {
        system.debug('\n\n*****ENTER changeTopAllTimeLineOfBusiness*****\n\n');
        isValChanged = true;
        if(selectedTopAllTimeLineOfBusiness == 'Business Banking') {
            defaultTopAllTimeLOBCat = 'ACH and Wires';
            selectedTopAllTimeCategory = 'All';
        } else if(selectedTopAllTimeLineOfBusiness == 'Consumer Relationship') {
            //defaultTopAllTimeLOBCat = 'Online Account Opening';
            defaultTopAllTimeLOBCat = 'Account Opening';
            selectedTopAllTimeCategory = 'All';
        } else if(selectedTopAllTimeLineOfBusiness == 'Money Movement') {
            defaultTopAllTimeLOBCat = 'Bill Pay';
            selectedTopAllTimeCategory = 'All';
        } else if(selectedTopAllTimeLineOfBusiness == 'Platform Solutions') {
            //defaultTopAllTimeLOBCat = 'Admin Platform User Management and Security';
            defaultTopAllTimeLOBCat = 'Security & Authentication';
            selectedTopAllTimeCategory = 'All';
        } else if(selectedTopAllTimeLineOfBusiness == 'Retail Banking') {
            //defaultTopAllTimeLOBCat = 'Alerts';
            defaultTopAllTimeLOBCat = 'Alerts & Communication';
            selectedTopAllTimeCategory = 'All';
        }
        Num2='1';
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedTopAllTimeLineOfBusiness AND DI_SubscriptionCategory__c=:selectedTopAllTimeCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1Top=false;
           
       }
       else ShowSubscriptionTop=false; 
       
       if(selectedTopAllTimeLineOfBusiness=='All' || string.isblank(selectedTopAllTimeLineOfBusiness) || string.isblank(selectedTopAllTimeCategory) || selectedTopAllTimeCategory=='All'){
           ShowSubscriptionTop=false;
           ShowSubscription1Top=false;
       }
        getAllTopAllTimeIdeas();
        loadTopAllTimePagination();
        if(getAllTopAllTimeIdeas().size() == 0) {
            noTopAllTimeIdeasView = 'No Records Found.';
        } else {
            noTopAllTimeIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for TopAllTime ideas category filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changeTopAllTimeCategory() {
        system.debug('\n\n*****ENTER changeTopAllTimeCategory*****\n\n');
        isValChanged = true;
        if(selectedTopAllTimeCategory == 'General Business Banking' || 
            selectedTopAllTimeCategory == 'ACH and Wires' || 
            selectedTopAllTimeCategory == 'Entitlements' || 
            selectedTopAllTimeCategory == 'Third Party Product Integration' || 
            //selectedTopAllTimeCategory == 'Deposit Accounts' || 
            //selectedTopAllTimeCategory == 'Other Accounts' ||
			selectedTopAllTimeCategory == 'Customer Support' ||
			selectedTopAllTimeCategory == 'Remote Deposit' ||
			selectedTopAllTimeCategory == 'Reporting' ||
			selectedTopAllTimeCategory == 'Alerts' ||
			selectedTopAllTimeCategory == 'Positive Pay' ||
			selectedTopAllTimeCategory == 'Client Services Developed Solutions') {
                selectedTopAllTimeLineOfBusiness = 'Business Banking';
        } else if(selectedTopAllTimeCategory == 'Promotion Suite' || 
                    selectedTopAllTimeCategory == 'Web Center' || 
                    selectedTopAllTimeCategory == 'Purchase Rewards' || 
                    //selectedTopAllTimeCategory == 'Online Account Opening' || 
                    //selectedTopAllTimeCategory == 'Other' ||
					selectedTopAllTimeCategory == 'Client Services Developed Solutions')  {
                selectedTopAllTimeLineOfBusiness = 'Consumer Relationship';
        } else if(selectedTopAllTimeCategory == 'General Payments' || 
                    selectedTopAllTimeCategory == 'Bill Pay' || 
                    selectedTopAllTimeCategory == 'External Funds Transfer' || 
                    //selectedTopAllTimeCategory == 'Pop Money' ||
					selectedTopAllTimeCategory == 'Person to Person Payments' ||
					selectedTopAllTimeCategory == 'Internal Transfers' ||
					selectedTopAllTimeCategory == 'Client Services Developed Solutions') {
                selectedTopAllTimeLineOfBusiness = 'Money Movement';
                    } else if(selectedTopAllTimeCategory == 'General Admin Platform' || 
                              //selectedTopAllTimeCategory == 'End User Support' || 
                              selectedTopAllTimeCategory == 'Branding and Flexibility' || 
                              //selectedTopAllTimeCategory == 'Admin Platform User Management and Security' || 
                              //selectedTopAllTimeCategory == 'Reporting' || 
                              //selectedTopAllTimeCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedTopAllTimeCategory == 'Interfaces' || 
                              //selectedTopAllTimeCategory == 'Security' || 
                              //selectedTopAllTimeCategory == 'Other' || 
                              selectedTopAllTimeCategory == 'Idea Exchange' ||
                              
                              selectedTopAllTimeCategory == 'Admin User Support' || 
                              selectedTopAllTimeCategory == 'Data & Reporting' || 
                              selectedTopAllTimeCategory == 'SSO and API Solutions ' || 
                              selectedTopAllTimeCategory == 'Security & Authentication' || 
                              selectedTopAllTimeCategory == 'Idea Exchange' || 
                              selectedTopAllTimeCategory == 'Alerts & Communication' || 
                              selectedTopAllTimeCategory == 'Account Opening' || 
                              selectedTopAllTimeCategory == 'Registration' || 
                              selectedTopAllTimeCategory == 'Web/Direct Connect' || 
                              selectedTopAllTimeCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedTopAllTimeCategory == 'Online Forms' || 
                              selectedTopAllTimeCategory == 'Client Services Developed Solutions')
                    {
                        selectedTopAllTimeLineOfBusiness = 'Platform Solutions';
                    } else if(selectedTopAllTimeCategory == 'General Admin Platform' || 
                              //selectedTopAllTimeCategory == 'End User Support' || 
                              selectedTopAllTimeCategory == 'Branding and Flexibility' || 
                              //selectedTopAllTimeCategory == 'Admin Platform User Management and Security' || 
                              //selectedTopAllTimeCategory == 'Reporting' || 
                              //selectedTopAllTimeCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedTopAllTimeCategory == 'Interfaces' || 
                              //selectedTopAllTimeCategory == 'Security' || 
                              //selectedTopAllTimeCategory == 'Other' || 
                              selectedTopAllTimeCategory == 'Idea Exchange' ||
                              
                              selectedTopAllTimeCategory == 'Admin User Support' || 
                              selectedTopAllTimeCategory == 'Data & Reporting' || 
                              selectedTopAllTimeCategory == 'SSO and API Solutions ' || 
                              selectedTopAllTimeCategory == 'Security & Authentication' || 
                              selectedTopAllTimeCategory == 'Idea Exchange' || 
                              selectedTopAllTimeCategory == 'Alerts & Communication' || 
                              selectedTopAllTimeCategory == 'Account Opening' || 
                              selectedTopAllTimeCategory == 'Registration' || 
                              selectedTopAllTimeCategory == 'Web/Direct Connect' || 
                              selectedTopAllTimeCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedTopAllTimeCategory == 'Online Forms' || 
                              selectedTopAllTimeCategory == 'Client Services Developed Solutions')
                    {
                        selectedTopAllTimeLineOfBusiness = 'Retail Banking';
                    }
        Num2='1';
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedTopAllTimeLineOfBusiness AND DI_SubscriptionCategory__c=:selectedTopAllTimeCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1Top=false;
           
       }
       else ShowSubscriptionTop=false;
        getAllTopAllTimeIdeas();
        loadTopAllTimePagination();
        if(getAllTopAllTimeIdeas().size() == 0) {
            noTopAllTimeIdeasView = 'No Records Found.';
        } else {
            noTopAllTimeIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for TopAllTime ideas status filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changeTopAllTimeStatus() {
        system.debug('\n\n*****ENTER changeTopAllTimeStatus*****\n\n');
        isValChanged = true;
        Num2='1';
        getAllTopAllTimeIdeas();
        loadTopAllTimePagination();
        if(getAllTopAllTimeIdeas().size() == 0) {
            noTopAllTimeIdeasView = 'No Records Found.';
        } else {
            noTopAllTimeIdeasView = '';
        }
    }
    
    
    
    
    /**********     METHODS FOR CHANGING PICKLIST VALUES - FILTER - ALL IDEAS TAB   **********/
    /*
    *    @description:    action for Comment ideas line of business filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String defaultCommentLOBCat {get;set;}
    public void changeCommentLineOfBusiness() {
        system.debug('\n\n*****ENTER changeCommentLineOfBusiness*****\n\n');
        isValChanged = true;
        Num2='1';
        if(selectedCommentLineOfBusiness == 'Business Banking') {
            defaultCommentLOBCat = 'ACH and Wires';
            //selectedCommentCategory = 'ACH and Wires';
            selectedCommentCategory = 'All';
        } else if(selectedCommentLineOfBusiness == 'Consumer Relationship') {
            //defaultCommentLOBCat = 'Online Account Opening';
             defaultCommentLOBCat = 'Account Opening';
            //selectedCommentCategory = 'Online Account Opening';
            selectedCommentCategory = 'All';
        } else if(selectedCommentLineOfBusiness == 'Money Movement') {
            defaultCommentLOBCat = 'Bill Pay';
            //selectedCommentCategory = 'Bill Pay';
            selectedCommentCategory = 'All';
        } else if(selectedCommentLineOfBusiness == 'Platform Solutions') {
            //defaultCommentLOBCat = 'Admin Platform User Management and Security';
            defaultCommentLOBCat = 'Security & Authentication';
            //selectedCommentCategory = 'Admin Platform User Management and Security';
            selectedCommentCategory = 'All';
        } else if(selectedCommentLineOfBusiness == 'Retail Banking') {
            //defaultCommentLOBCat = 'Alerts';
            defaultCommentLOBCat = 'Alerts & Communication';
            //selectedCommentCategory = 'Alerts';
            selectedCommentCategory = 'All';
        }
        list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedCommentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedCommentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1AllIdeas=false;
           
       }
       else ShowSubscriptionAllIdeas=false; 
       
       if(selectedCommentLineOfBusiness=='All' || string.isblank(selectedCommentLineOfBusiness) || string.isblank(selectedCommentCategory) || selectedCommentCategory=='All'){
           ShowSubscriptionAllIdeas=false;
           ShowSubscription1AllIdeas=false;
       }
        getAllCommentIdeas();
        loadCommentPagination();
        if(getAllCommentIdeas().size() == 0) {
            noCommentIdeasView = 'No Records Found.';
        } else {
            noCommentIdeasView = '';
        }
    }
    
    /*
    *    @description:    action for Comment ideas category filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changeCommentCategory() {
        system.debug('\n\n*****ENTER changeCommentCategory*****\n\n');
        system.debug('selectedCommentCategory = ' + selectedCommentCategory);
        isValChanged = true;
        Num2='1';
        if(selectedCommentCategory == 'General Business Banking' || 
            selectedCommentCategory == 'ACH and Wires' || 
            selectedCommentCategory == 'Entitlements' || 
            selectedCommentCategory == 'Third Party Product Integration' || 
            //selectedCommentCategory == 'Deposit Accounts' || 
            //selectedCommentCategory == 'Other Accounts' ||
			selectedCommentCategory == 'Customer Support' ||
			selectedCommentCategory == 'Remote Deposit' ||
			selectedCommentCategory == 'Reporting' ||
			selectedCommentCategory == 'Alerts' ||
			selectedCommentCategory == 'Positive Pay' ||
			selectedCommentCategory == 'Client Services Developed Solutions') {
                selectedCommentLineOfBusiness = 'Business Banking';
        } else if(selectedCommentCategory == 'Promotion Suite' || 
                    selectedCommentCategory == 'Web Center' || 
                    selectedCommentCategory == 'Purchase Rewards' || 
                    //selectedCommentCategory == 'Online Account Opening' || 
                    //selectedCommentCategory == 'Other' ||
					selectedCommentCategory == 'Client Services Developed Solutions')  {
                selectedCommentLineOfBusiness = 'Consumer Relationship';
        } else if(selectedCommentCategory == 'General Payments' || 
                    selectedCommentCategory == 'Bill Pay' || 
                    selectedCommentCategory == 'External Funds Transfer' || 
                    //selectedCommentCategory == 'Pop Money' ||
					selectedCommentCategory == 'Person to Person Payments' ||
					selectedCommentCategory == 'Internal Transfers' ||
					selectedCommentCategory == 'Client Services Developed Solutions') {
                selectedCommentLineOfBusiness = 'Money Movement';
                    } else if(selectedCommentCategory == 'General Admin Platform' || 
                              //selectedCommentCategory == 'End User Support' || 
                              selectedCommentCategory == 'Branding and Flexibility' || 
                              //selectedCommentCategory == 'Admin Platform User Management and Security' || 
                              //selectedCommentCategory == 'Reporting' || 
                              //selectedCommentCategory == 'Create Your Own/SSO and API Integration' || 
                              selectedCommentCategory == 'Interfaces' || 
                              //selectedCommentCategory == 'Security' || 
                              //selectedCommentCategory == 'Other' || 
                              selectedCommentCategory == 'Idea Exchange' ||
                              
                              selectedCommentCategory == 'Admin User Support' || 
                              selectedCommentCategory == 'Data & Reporting' || 
                              selectedCommentCategory == 'SSO and API Solutions ' || 
                              selectedCommentCategory == 'Security & Authentication' || 
                              selectedCommentCategory == 'Idea Exchange' || 
                              selectedCommentCategory == 'Alerts & Communication' || 
                              selectedCommentCategory == 'Account Opening' || 
                              selectedCommentCategory == 'Registration' || 
                              selectedCommentCategory == 'Web/Direct Connect' || 
                              selectedCommentCategory == 'Digital Communication - Chat, Messaging, Chatbot' || 
                              selectedCommentCategory == 'Online Forms' || 
                              selectedCommentCategory == 'Client Services Developed Solutions') {
                                  selectedCommentLineOfBusiness = 'Platform Solutions';
                              } else if(selectedCommentCategory == 'General Retail Banking' || 
                                        //selectedCommentCategory == 'General Digital Banking' || 
                                        selectedCommentCategory == 'Alerts & Communication' || 
                                        selectedCommentCategory == 'User Profile Settings' || 
                                        selectedCommentCategory == 'Check/Deposit Imaging' ||
                                        selectedCommentCategory == 'Customer Support' || 
                                        selectedCommentCategory == 'Money Management' || 
                                        selectedCommentCategory == 'Online Statements' ||
                                        selectedCommentCategory == 'Remote Deposit' ||
                                        selectedCommentCategory == 'Shared Access' || 
                                        selectedCommentCategory == 'Card Management' ||  
                                        
                                        //selectedCommentCategory == 'Deposit Accounts' || 
                                        //selectedCommentCategory == 'Other Accounts' || 
                                        //selectedCommentCategory == 'Authentication & Settings' || 
                                        //selectedCommentCategory == 'Alerts' || 
                                        //selectedCommentCategory == 'Transfers' || 
                                        //selectedCommentCategory == 'Online Statements' || 
                                        //selectedCommentCategory == 'Registration' || 
                                        
                                        
                                        //selectedCommentCategory == 'Web/Direct Connect' || 
                                        //selectedCommentCategory == 'Check/Deposit Imaging' ||
                                        selectedCommentCategory == 'Financial Wellness' ||
                                        selectedCommentCategory == 'Client Services Developed Solutions') 
                              {
                                  selectedCommentLineOfBusiness = 'Retail Banking';
                              }
         list<DI_IdeaSubscription__c> subscriberList=[select id from DI_IdeaSubscription__c where (DI_LineOfBusiness__c=:selectedCommentLineOfBusiness AND DI_SubscriptionCategory__c=:selectedCommentCategory AND DI_UserName__c=:userinfo.getuserid()) limit 1 ];
      
       if(subscriberList.isempty())
       {
           ShowSubscription1AllIdeas=false;
           
       }
       else ShowSubscriptionAllIdeas=false;
        getAllCommentIdeas();
        loadCommentPagination();
        if(getAllCommentIdeas().size() == 0) {
            noCommentIdeasView = 'No Records Found.';
        } else {
            noCommentIdeasView = '';
        }
        system.debug('selectedCommentCategory = ' + selectedCommentCategory);
        system.debug('selectedCommentLineOfBusiness = ' + selectedCommentLineOfBusiness);
    }
    
    /*
    *    @description:    action for Comment ideas status filter.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public void changeCommentStatus() {
        system.debug('\n\n*****ENTER changeCommentStatus*****\n\n');
        isValChanged = true;
        Num2='1';
        getAllCommentIdeas();
        loadCommentPagination();
        if(getAllCommentIdeas().size() == 0) {
            noCommentIdeasView = 'No Records Found.';
        } else {
            noCommentIdeasView = '';
        }
    }
    
    
    
    
    /**********     PAGINATIONS     **********/
    /*
    *    @description:    pagination for recent ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  RECENT  *****/
    public PaginateRecent paginaterRecent {get;set;}
    public List<RecentClass> RecentList{get;set;}
    public List<List<RecentClass>> fullRecentList{get;set;}
    
    
    public PageReference previousPageRecent(){
        Num2 = Apexpages.currentPage().getParameters().get('selectedPageRecent');
        
        this.paginaterRecent.decrementRecent();
        return changeDataRecent();
    }
     
    public PageReference nextPageRecent(){
        Num2 = Apexpages.currentPage().getParameters().get('selectedPageRecent');
        this.paginaterRecent.incrementRecent();
        return changeDataRecent();
    }
 
    public PageReference updatePageRecent(){
        Num2 = Apexpages.currentPage().getParameters().get('selectedPageRecent');
        selectedTab = 'Recent';
        this.paginaterRecent.updateNumbersRecent();
        return changeDataRecent();
    }
     
    public PageReference changeDataRecent(){
        this.RecentList = this.fullRecentList.get(this.paginaterRecent.indexRecent);
        return null;
    }
     
    public List<RecentClass> populateDataRecent(){
        List<RecentClass> customClassList = new List<RecentClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getAllRecentIdeas()) {
            ideaIds.add(a.id);
        }
          List<Vote> vList = new List<Vote>();
        
        //List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN: ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        if(Test.isRunningTest()){
            vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        }
        else
        {
           vList = getaccountvote(ideaIds);
        }
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
        
        for(Idea a : getAllRecentIdeas()) {
            if(mapFavorite.size() > 0) {
                if(mapIdea.size() > 0) {
                    customClassList.add(new RecentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                } else {
                    disableVoting = false;
                    customClassList.add(new RecentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                }
            } else {
                isFavorite = false;
                if(mapIdea.size() > 0) {
                    customClassList.add(new RecentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                } else {
                    disableVoting = false;
                    customClassList.add(new RecentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                }
            }
        }
        return customClassList;
    }
     
    public class RecentClass{
        public String titleRecent{get;set;}
        public String bodyRecent{get;set;}
        public String fIMageRecent {get;set;}
        public id idRecent {get;set;}
        public String cNameRecent {get;set;}
        public Boolean disableVoteRecent {get;set;}
        public String lobRecent {get;set;}
        public String catRecent {get;set;}
        public String statRecent {get;set;}
        public Id createdByIdRecent {get;set;}
        public DateTime createdDateRecent {get;set;}
        public Decimal totalVotesRecent {get;set;}
        public Boolean isFaveRecent {get;set;}
        public string cTitleRecent {get;set;}
        public String createdByProfileIdRecent {get;set;}
        public String createdByDiFiNameRecent {get;set;}
        public String diIdeaChannelRecent {get;set;}
        
        public RecentClass(String titleRecent, String bodyRecent, String fIMageRecent, Id idRecent, String cNameRecent, Boolean disableVoteRecent, String lobRecent, String catRecent, String statRecent, Id createdByIdRecent, DateTime createdDateRecent, Decimal totalVotesRecent, Boolean isFaveRecent,String cTitleRecent, String createdByProfileIdRecent,String createdByDiFiNameRecent, String diIdeaChannelRecent ){
            this.titleRecent = titleRecent;
            if(bodyRecent!= null){
            this.bodyRecent = bodyRecent.stripHtmlTags().abbreviate(150);
            }else{
                this.bodyRecent = bodyRecent;
            }
            this.fIMageRecent = fIMageRecent;
            this.idRecent = idRecent;
            this.cNameRecent = cNameRecent;
            this.disableVoteRecent = disableVoteRecent;
            this.lobRecent = lobRecent;
            this.catRecent = catRecent;
            this.statRecent = statRecent;
            this.createdByIdRecent = createdByIdRecent;
            this.createdDateRecent = createdDateRecent;
            this.totalVotesRecent = totalVotesRecent;
            this.isFaveRecent = isFaveRecent;
            this.cTitleRecent = cTitleRecent;
            this.createdByProfileIdRecent = createdByProfileIdRecent;
            this.createdByDiFiNameRecent = createdByDiFiNameRecent;
            this.diIdeaChannelRecent = diIdeaChannelRecent ;
        }
    }
     
    /*
    *    @description:    pagination for popular ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  POPULAR  *****/
    public PaginatePopular paginaterPopular {get;set;}
    public List<PopularClass> PopularList{get;set;}
    public List<List<PopularClass>> fullPopularList{get;set;}
    
    
    public PageReference previousPagePopular(){
        this.paginaterPopular.decrementPopular();
        return changeDataPopular();
    }
     
    public PageReference nextPagePopular(){
        this.paginaterPopular.incrementPopular();
        return changeDataPopular();
    }
 
    public PageReference updatePagePopular(){
        Num2 = Apexpages.currentPage().getParameters().get('selectedPagePopular');
        selectedTab = 'Popular';
        this.paginaterPopular.updateNumbersPopular();
        return changeDataPopular();
    }
     
    public PageReference changeDataPopular(){
        this.PopularList = this.fullPopularList.get(this.paginaterPopular.indexPopular);
        return null;
    }
    
    
      public list<vote> getaccountvote(set<id> IdeaIds){
        
        list<id> acid = new list<id>();
        for( user u : [select AccountId from user where id =: UserInfo.getUserId()])
        {
            acid.add(u.accountid);
        }
        list<id> cid =new list<id>();
        
        for (user c : [select id from user where AccountId in :acid])
        {
            cid.add(c.id);
            
        }
        return [select id,ParentId, Type from vote  WHERE ParentId IN: IdeaIds AND CreatedById in : cid AND Parent.Type = 'Idea' ];
    }
     
    public List<PopularClass> populateDataPopular(){
        List<PopularClass> customClassList = new List<PopularClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getAllPopularIdeas()) {
            ideaIds.add(a.id);
        }
        
        //List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
         List<Vote> vList = new List<Vote>();
        
        if(Test.isRunningTest()){
            vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        }
        else
        {
           vList = getaccountvote(ideaIds);
        }
        
        
        Boolean disableVoting;
        
        for(Vote v : vList) {
            if(v.id != null) {
                //system.debug('########accountvotesize'+getaccountvote(v.id).size());
                
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
        
        for(Idea a : getAllPopularIdeas()) {
            if(mapFavorite.size() > 0) {
                //system.debug('####size'+ popularVoteIdeaId);
                //System.debug('countsizeaccount'+ getaccountvote().size());
                if(mapIdea.size() > 0 ) {
                    customClassList.add(new PopularClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c,a.Di_Idea_Channel__c));
                } else {
                    disableVoting = false;
                    customClassList.add(new PopularClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                }
            } else {
                isFavorite = false;
                //system.debug('####size'+ popularVoteIdeaId);
                //System.debug('countsizeaccount'+ getaccountvote().size());
                if(mapIdea.size() > 0 ) {
                    customClassList.add(new PopularClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                } else {
                    disableVoting = false;
                    customClassList.add(new PopularClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                }
            }
        }
        return customClassList;
    }
     
    public class PopularClass{
        public String titlePopular{get;set;}
        public String bodyPopular{get;set;}
        public String fIMagePopular {get;set;}
        public id idPopular {get;set;}
        public String cNamePopular {get;set;}
        public Boolean disableVotePopular {get;set;}
        public String lobPopular {get;set;}
        public String catPopular {get;set;}
        public String statPopular {get;set;}
        public Id createdByIdPopular {get;set;}
        public DateTime createdDatePopular {get;set;}
        public Decimal totalVotesPopular {get;set;}
        public Boolean isFavePopular {get;set;}
        public string cTitlePopular {get;set;}
        public String createdByProfileIdPopular {get;set;}
        public String createdByDiFiNamePopular {get;set;}
        public String diIdeaChannelPopular {get;set;}
        
        
        public PopularClass(String titlePopular, String bodyPopular, String fIMagePopular, Id idPopular, String cNamePopular, Boolean disableVotePopular, String lobPopular, String catPopular, String statPopular, Id createdByIdPopular, DateTime createdDatePopular, Decimal totalVotesPopular, Boolean isFavePopular, String cTitlePopular, String createdByProfileIdPopular,String createdByDiFiNamePopular, String diIdeaChannelPopular ){
            this.titlePopular = titlePopular;
            if(bodyPopular != null){
            this.bodyPopular = bodyPopular.stripHtmlTags().abbreviate(150);
            }else{
                this.bodyPopular = bodyPopular;
            }
            this.fIMagePopular = fIMagePopular;
            this.idPopular = idPopular;
            this.cNamePopular = cNamePopular;
            this.disableVotePopular = disableVotePopular;
            this.lobPopular = lobPopular;
            this.catPopular = catPopular;
            this.statPopular = statPopular;
            this.createdByIdPopular = createdByIdPopular;
            this.createdDatePopular = createdDatePopular;
            this.totalVotesPopular = totalVotesPopular;
            this.isFavePopular = isFavePopular;
            this.cTitlePopular = cTitlePopular;
            this.createdByProfileIdPopular = createdByProfileIdPopular;
            this.createdByDiFiNamePopular = createdByDiFiNamePopular;
            this.diIdeaChannelPopular  = diIdeaChannelPopular ;
        }
    }
     
    /*
    *    @description:    pagination for TopAllTime ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  TopAllTime  *****/
    public PaginateTopAllTime paginaterTopAllTime {get;set;}
    public List<TopAllTimeClass> TopAllTimeList{get;set;}
    public List<List<TopAllTimeClass>> fullTopAllTimeList{get;set;}
    
    
    public PageReference previousPageTopAllTime(){
        this.paginaterTopAllTime.decrementTopAllTime();
        return changeDataTopAllTime();
    }
     
    public PageReference nextPageTopAllTime(){
        this.paginaterTopAllTime.incrementTopAllTime();
        return changeDataTopAllTime();
    }
 
    public PageReference updatePageTopAllTime(){
        Num2 = Apexpages.currentPage().getParameters().get('selectedPageTopAllTime');
        selectedTab = 'TopAllTime';
        this.paginaterTopAllTime.updateNumbersTopAllTime();
        return changeDataTopAllTime();
    }
     
    public PageReference changeDataTopAllTime(){
        this.TopAllTimeList = this.fullTopAllTimeList.get(this.paginaterTopAllTime.indexTopAllTime);
        return null;
    }
     
    public List<TopAllTimeClass> populateDataTopAllTime(){
        List<TopAllTimeClass> customClassList = new List<TopAllTimeClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getAllTopAllTimeIdeas()) {
            ideaIds.add(a.id);
        }
        
        //List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
         List<Vote> vList = new List<Vote>();
        
        if(Test.isRunningTest()){
            vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        }
        else
        {
            vList = getaccountvote(ideaIds);
        }        
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
        
        for(Idea a : getAllTopAllTimeIdeas()) {
            if(mapFavorite.size() > 0) {
                if(mapIdea.size() > 0) {
                    customClassList.add(new TopAllTimeClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                } else {
                    disableVoting = false;
                    customClassList.add(new TopAllTimeClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                }
            } else {
                isFavorite = false;
                if(mapIdea.size() > 0) {
                    customClassList.add(new TopAllTimeClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                } else {
                    disableVoting = false;
                    customClassList.add(new TopAllTimeClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.profileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c));
                }
            }
        }
        return customClassList;
    }
     
    public class TopAllTimeClass{
        public String titleTopAllTime{get;set;}
        public String bodyTopAllTime{get;set;}
        public String fIMageTopAllTime {get;set;}
        public id idTopAllTime {get;set;}
        public String cNameTopAllTime {get;set;}
        public Boolean disableVoteTopAllTime {get;set;}
        public String lobTopAllTime {get;set;}
        public String catTopAllTime {get;set;}
        public String statTopAllTime {get;set;}
        public Id createdByIdTopAllTime {get;set;}
        public DateTime createdDateTopAllTime {get;set;}
        public Decimal totalVotesTopAllTime {get;set;}
        public Boolean isFaveTopAllTime {get;set;}
        public string cTitleTopAllTime {get;set;}
        public String createdByProfileIdAllTime {get;set;}
        public String createdByDiFiNameAllTime {get;set;}
        public String diIdeaChannelAllTime {get;set;}
         
        public TopAllTimeClass(String titleTopAllTime, String bodyTopAllTime, String fIMageTopAllTime, Id idTopAllTime, String cNameTopAllTime, Boolean disableVoteTopAllTime, String lobTopAllTime, String catTopAllTime, String statTopAllTime, Id createdByIdTopAllTime, DateTime createdDateTopAllTime, Decimal totalVotesTopAllTime, Boolean isFaveTopAllTime, string cTitleTopAllTime, String createdByProfileIdAllTime, String createdByDiFiNameAllTime, String diIdeaChannelAllTime){
            this.titleTopAllTime = titleTopAllTime;
            
            //this.bodyTopAllTime = bodyTopAllTime.stripHtmlTags().abbreviate(150);
            if(bodyTopAllTime != null){
            this.bodyTopAllTime = bodyTopAllTime.stripHtmlTags().abbreviate(150);
            }else{
                this.bodyTopAllTime = bodyTopAllTime;
            }
            this.fIMageTopAllTime = fIMageTopAllTime;
            this.idTopAllTime = idTopAllTime;
            this.cNameTopAllTime = cNameTopAllTime;
            this.disableVoteTopAllTime = disableVoteTopAllTime;
            this.lobTopAllTime = lobTopAllTime;
            this.catTopAllTime = catTopAllTime;
            this.statTopAllTime = statTopAllTime;
            this.createdByIdTopAllTime = createdByIdTopAllTime;
            this.createdDateTopAllTime = createdDateTopAllTime;
            this.totalVotesTopAllTime = totalVotesTopAllTime;
            this.isFaveTopAllTime = isFaveTopAllTime;
            this.cTitleTopAllTime = cTitleTopAllTime;
            this.createdByProfileIdAllTime = createdByProfileIdAllTime ;
            this.createdByDiFiNameAllTime  = createdByDiFiNameAllTime ;
            this.diIdeaChannelAllTime = diIdeaChannelAllTime;
        }
    }
        
    /*
    *    @description:    pagination for Comment ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  Comment  *****/
    public PaginateComment paginaterComment {get;set;}
    public List<CommentClass> CommentList{get;set;}
    public List<List<CommentClass>> fullCommentList{get;set;}
    
    
    public PageReference previousPageComment(){
        this.paginaterComment.decrementComment();
        return changeDataComment();
    }
     
    public PageReference nextPageComment(){
        this.paginaterComment.incrementComment();
        return changeDataComment();
    }
 
    public PageReference updatePageComment(){
        Num2 = Apexpages.currentPage().getParameters().get('selectedPageComment');
        selectedTab = 'AllIdeas';
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
        for(Idea a : getAllCommentIdeas()) {
            ideaIds.add(a.id);
        }
          List<Vote> vList = new List<Vote>();
        
        //List<Vote> vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        if(Test.isRunningTest()){
            vList = [SELECT id, ParentId, Type FROM Vote WHERE ParentId IN:ideaIds AND CreatedById =: UserInfo.getUserId() AND Parent.Type = 'Idea'];
        }
        else
        {
           vList = getaccountvote(ideaIds);
        }
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
        
        for(Idea a : getAllCommentIdeas()) {
            if(mapFavorite.size() > 0) {
                if(mapIdea.size() > 0) {
                    customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c,a.Di_Idea_Channel__c ));
                } else {
                    disableVoting = false;
                    customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c ));
                }
            } else {
                isFavorite = false;
                if(mapIdea.size() > 0) {
                    customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c ));
                } else {
                    disableVoting = false;
                    customClassList.add(new CommentClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title, a.CreatedBy.ProfileId, a.CreatedBy.DI_Fi_Name__c, a.Di_Idea_Channel__c ));
                }
            }
        }
        return customClassList;
    }
     
    public class CommentClass{
        public String titleComment{get;set;}
        public String bodyComment{get;set;}
        public String fIMageComment {get;set;}
        public id idComment {get;set;}
        public String cNameComment {get;set;}
        public Boolean disableVoteComment {get;set;}
        public String lobComment {get;set;}
        public String catComment {get;set;}
        public String statComment {get;set;}
        public Id createdByIdComment {get;set;}
        public DateTime createdDateComment {get;set;}
        public Decimal totalVotesComment {get;set;}
        public Boolean isFaveComment {get;set;}
        public string cTitleComment {get;set;}
        public String createdByProfileIdComment {get;set;}
        public String createdByDiFiNameComment {get;set;}
        public String diIdeaChannel {get;set;}
         
        public CommentClass(String titleComment, String bodyComment, String fIMageComment, Id idComment, String cNameComment, Boolean disableVoteComment, String lobComment, String catComment, String statComment, Id createdByIdComment, DateTime createdDateComment, Decimal totalVotesComment, Boolean isFaveComment, string cTitleComment, String createdByProfileIdComment, String createdByDiFiNameComment, String diIdeaChannel ){
            this.titleComment = titleComment;
            
            if(bodyComment != null){
                this.bodyComment = bodyComment.stripHtmlTags().abbreviate(150);
            }else{
                this.bodyComment = bodyComment;
            }
            
            this.fIMageComment = fIMageComment;
            this.idComment = idComment;
            this.cNameComment = cNameComment;
            this.disableVoteComment = disableVoteComment;
            this.lobComment = lobComment;
            this.catComment = catComment;
            this.statComment = statComment;
            this.createdByIdComment = createdByIdComment;
            this.createdDateComment = createdDateComment;
            this.totalVotesComment = totalVotesComment;
            this.isFaveComment = isFaveComment;
            this.cTitleComment = cTitleComment;
            this.createdByProfileIdComment = createdByProfileIdComment;
            this.createdByDiFiNameComment = createdByDiFiNameComment;
            this.diIdeaChannel = diIdeaChannel ;
        }
    }    
        
    /*
    *    @description:    pagination for SearchResult ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    /*****  SearchResult  *****/
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
     
    public List<SearchResultClass> populateDataSearchResult(){
        List<SearchResultClass> customClassList = new List<SearchResultClass>();
        Map<Id, Boolean> mapIdea = new Map<Id, Boolean>();
        Set<Id> ideaIds = new Set<Id>();
        for(Idea a : getAllSearchResultIdeas()) {
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
        
        for(Idea a : getAllSearchResultIdeas()) {
            if(mapFavorite.size() > 0) {
                if(mapIdea.size() > 0) {
                    customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title));
                } else {
                    disableVoting = false;
                    customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, mapFavorite.get(a.id),a.CreatedBy.Title));
                }
            } else {
                isFavorite = false;
                if(mapIdea.size() > 0) {
                    customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, mapIdea.get(a.id), a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title));
                } else {
                    disableVoting = false;
                    customClassList.add(new SearchResultClass(a.Title, a.Body, a.CreatedBy.pics__c, a.id, a.CreatedBy.Name, disableVoting, a.Di_Idea_Line_of_Business__c, a.Di_Idea_Category__c, a.Status, a.CreatedById, a.CreatedDate, a.VoteTotal, isFavorite,a.CreatedBy.Title));
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
        public String lobSearchResult {get;set;}
        public String catSearchResult {get;set;}
        public String statSearchResult {get;set;}
        public Id createdByIdSearchResult {get;set;}
        public DateTime createdDateSearchResult {get;set;}
        public Decimal totalVotesSearchResult {get;set;}
        public Boolean isFaveSearchResult {get;set;}
        public string cTitleSearchResult {get;set;}
         
        public SearchResultClass(String titleSearchResult, String bodySearchResult, String fIMageSearchResult, Id idSearchResult, String cNameSearchResult, Boolean disableVoteSearchResult, String lobSearchResult, String catSearchResult, String statSearchResult, Id createdByIdSearchResult, DateTime createdDateSearchResult, Decimal totalVotesSearchResult, Boolean isFaveSearchResult,string cTitleSearchResult){
            this.titleSearchResult = titleSearchResult;
            
            if(bodySearchResult != null){
                this.bodySearchResult = bodySearchResult.stripHtmlTags().abbreviate(150);
            }else{
                this.bodySearchResult = bodySearchResult;
            }
            
            this.fIMageSearchResult = fIMageSearchResult;
            this.idSearchResult = idSearchResult;
            this.cNameSearchResult = cNameSearchResult;
            this.disableVoteSearchResult = disableVoteSearchResult;
            this.lobSearchResult = lobSearchResult;
            this.catSearchResult = catSearchResult;
            this.statSearchResult = statSearchResult;
            this.createdByIdSearchResult = createdByIdSearchResult;
            this.createdDateSearchResult = createdDateSearchResult;
            this.totalVotesSearchResult = totalVotesSearchResult;
            this.isFaveSearchResult = isFaveSearchResult;
            this.cTitleSearchResult = cTitleSearchResult;
        }
    }    
    
    
    
    
    /**********     METHODS FOR ADDING/DELETING FAVORITES - RECENT      **********/
    /*
    *    @description:    action for adding recent idea to favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id recentIdeaId {get;set;}
    public Id recentIdeaCreatedById {get;set;}      //not used
    public pageReference insertToMyFavoritesRecent() { 
        system.debug('\n\n*****ENTER insertToMyFavoritesRecent*****\n\n');     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = recentIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
        
    /*
    *    @description:    action for deleting idea to recent.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavoritesRecent() {
        system.debug('\n\n*****ENTER deleteToMyFavoritesRecent*****\n\n');
        Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: recentIdeaId AND User__c =: UserInfo.getUserId() LIMIT 1];
        delete deleteFave;

        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    
    
    
    /**********     METHODS FOR ADDING/DELETING FAVORITES - POPULAR     **********/
    /*
    *    @description:    action for adding popular idea to favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id popularIdeaId {get;set;}
    public Id popularIdeaCreatedById {get;set;}     //not used
    public pageReference insertToMyFavoritesPopular() {
        system.debug('\n\n*****ENTER insertToMyFavoritesPopular*****\n\n');     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = popularIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=Popular');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
        
    /*
    *    @description:    action for deleting idea to popular.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavoritesPopular() {
        system.debug('\n\n*****ENTER deleteToMyFavoritesPopular*****\n\n'); 
        Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: popularIdeaId AND User__c =: UserInfo.getUserId() LIMIT 1];
        delete deleteFave;

        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=Popular');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    
    
    
    /**********     METHODS FOR ADDING/DELETING FAVORITES - TOP ALL TIME     **********/
    /*
    *    @description:    action for adding TopAllTime idea to favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id TopAllTimeIdeaId {get;set;}
    public Id TopAllTimeIdeaCreatedById {get;set;}     //not used
    public pageReference insertToMyFavoritesTopAllTime() {
        system.debug('\n\n*****ENTER insertToMyFavoritesTopAllTime*****\n\n');     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = TopAllTimeIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=TopAllTime');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
        
    /*
    *    @description:    action for deleting idea to TopAllTime.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavoritesTopAllTime() {
        system.debug('\n\n*****ENTER deleteToMyFavoritesTopAllTime*****\n\n'); 
        Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: TopAllTimeIdeaId AND User__c =: UserInfo.getUserId() LIMIT 1];
        delete deleteFave;

        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=TopAllTime');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    
    
    
    /**********     METHODS FOR ADDING/DELETING FAVORITES - COMMENT/ALL IDEAS       **********/
    /*
    *    @description:    action for adding Comment idea to favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id commentIdeaId {get;set;}
    public Id commentIdeaCreatedById {get;set;}     //not used
    public pageReference insertToMyFavoritesComment() { 
        system.debug('\n\n*****ENTER insertToMyFavoritesComment*****\n\n');     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = commentIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=AllIdeas');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
        
    /*
    *    @description:    action for deleting idea to Comment.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavoritesComment() {
        system.debug('\n\n*****ENTER deleteToMyFavoritesComment*****\n\n');  
        Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: commentIdeaId AND User__c =: UserInfo.getUserId() LIMIT 1];
         delete deleteFave;

        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?selectTab=AllIdeas');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    
    
    
    /**********     METHODS FOR ADDING/DELETING FAVORITES - SEARCHRESULT      **********/
    /*
    *    @description:    action for adding SearchResult idea to favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Id SearchResultIdeaId {get;set;}
    public Id SearchResultIdeaCreatedById {get;set;}      //not used
    public pageReference insertToMyFavoritesSearchResult() { 
        system.debug('\n\n*****ENTER insertToMyFavoritesSearchResult*****\n\n');     
        Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
        fvr.Di_Idea__c = SearchResultIdeaId;
        fvr.User__c = UserInfo.getUserId();
        insert fvr;
        
        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.getParameters().put('SelectTab', selectedTab);
        gotorecord.getParameters().put('SearchItemVal', SearchItemValue);
        gotorecord.setRedirect(true);
        
        return gotorecord;
    }
        
    /*
    *    @description:    action for deleting idea to SearchResult.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavoritesSearchResult() {
        system.debug('\n\n*****ENTER deleteToMyFavoritesSearchResult*****\n\n');
        Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: SearchResultIdeaId AND User__c =: UserInfo.getUserId() LIMIT 1];
        delete deleteFave;

        PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage');
        if(Num2 != null){
            gotorecord.getParameters().put('pnum', string.valueof(Num2));
        }
        gotorecord.getParameters().put('SelectTab', selectedTab);
        gotorecord.getParameters().put('SearchItemVal', SearchItemValue);
        gotorecord.setRedirect(true);
        return gotorecord;
    }
    
    
    
    
    /**********     METHODS FOR VOTING ON SELECTED IDEAS        **********/
    /*
    *    @description:    action for voting a recent idea.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public id recentVoteIdeaId {get;set;}
    public void voteUpRecent() {
        system.debug('\n\n*****ENTER voteUpRecent*****\n\n'); 
        if(recentVoteIdeaId != null) {
            Vote newVote = new Vote();
                newVote.ParentId = recentVoteIdeaId;
                newVote.Type = 'Up';
            insert newVote;
        } /*else {

        } commented empty block statement */
        loadRecentPaginationWithFilter();
    } 
    
    /*
    *    @description:    action for voting popular idea.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public id popularVoteIdeaId {get;set;}
    public void voteUpPopular() {
        system.debug('\n\n*****ENTER voteUpPopular*****\n\n'); 
        if(popularVoteIdeaId != null) {
            Vote newVote = new Vote();
                newVote.ParentId = popularVoteIdeaId;
                newVote.Type = 'Up';
            insert newVote;
        } /*else {

        } commented empty block statement */
        loadPopularPaginationWithFilter();
    }
    
    /*
    *    @description:    action for voting TopAllTime idea.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public id TopAllTimeVoteIdeaId {get;set;}
    public void voteUpTopAllTime() {
        system.debug('\n\n*****ENTER voteUpTopAllTime*****\n\n'); 
        if(TopAllTimeVoteIdeaId != null) {
            Vote newVote = new Vote();
                newVote.ParentId = TopAllTimeVoteIdeaId;
                newVote.Type = 'Up';
            insert newVote;
        } /*else {

        } commented empty block statement */
        loadTopAllTimePaginationWithFilter();
    }
    
    /*
    *    @description:    action for voting a Comment idea.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public id CommentVoteIdeaId {get;set;}
    public void voteUpComment() {
        system.debug('\n\n*****ENTER voteUpComment*****\n\n'); 
        if(CommentVoteIdeaId != null) {
            Vote newVote = new Vote();
                newVote.ParentId = CommentVoteIdeaId;
                newVote.Type = 'Up';
            insert newVote;
        } /*else {

        } commented empty block statement */
        loadCommentPaginationWithFilter();
    } 
    
    /*
    *    @description:    action for voting SearchResult idea.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public id SearchResultVoteIdeaId {get;set;}
    public void voteUpSearchResult() {
        system.debug('\n\n*****ENTER voteUpSearchResult*****\n\n'); 
        if(SearchResultVoteIdeaId != null) {
            Vote newVote = new Vote();
                newVote.ParentId = SearchResultVoteIdeaId;
                newVote.Type = 'Up';
            insert newVote;
        } /*else {

        } commented empty block statement */
        loadSearchResultPagination();
    }
    
    
    
    
    /**********     METHODS FOR RELOADING PAGINATIONS - AFTER FILTERS       **********/    
    /*
    *    @description:    action for reloading recent ideas pagination after selecting filters.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String currentRecentLOB {get;set;}
    public String currentRecentCat {get;set;}
    public String currentRecentStat {get;set;}
    public Integer totalRecentNum {get;set;}
    public void loadRecentPaginationWithFilter() {
        system.debug('\n\n*****ENTER loadRecentPaginationWithFilter*****\n\n'); 
        if(currentRecentLOB != null) {
            selectedRecentLineOfBusiness = currentRecentLOB;
        }
        if(currentRecentCat != null) {
            selectedRecentCategory = currentRecentCat;
        }
        if(currentRecentStat != null) {
            selectedRecentIdeaStatus = currentRecentStat;
        }
        getAllRecentIdeas();
        populateDataRecent();
        loadRecentPagination();
            totalRecentNum = paginaterRecent.totalPageRecent;
    }
   
    /*
    *    @description:    action for reloading popular ideas pagination after selecting filters.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String currentPopularLOB {get;set;}
    public String currentPopularCat {get;set;}
    public String currentPopularStat {get;set;}
    public Integer totalPopularNum {get;set;}
    public void loadPopularPaginationWithFilter() {
        system.debug('\n\n*****ENTER loadPopularPaginationWithFilter*****\n\n'); 
        if(currentPopularLOB != null) {
            selectedPopularLineOfBusiness = currentPopularLOB;
        }
        if(currentPopularCat != null) {
            selectedPopularCategory = currentPopularCat;
        }
        if(currentPopularStat != null) {
            selectedPopularIdeaStatus = currentPopularStat;
        }
        getAllPopularIdeas();
        populateDataPopular();
        loadPopularPagination();
            totalPopularNum = paginaterPopular.totalPagePopular;
    }
   
    /*
    *    @description:    action for reloading TopAllTime ideas pagination after selecting filters.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String currentTopAllTimeLOB {get;set;}
    public String currentTopAllTimeCat {get;set;}
    public String currentTopAllTimeStat {get;set;}
    public Integer totalTopAllTimeNum {get;set;}
    public void loadTopAllTimePaginationWithFilter() {
        system.debug('\n\n*****ENTER loadTopAllTimePaginationWithFilter*****\n\n'); 
        if(currentTopAllTimeLOB != null) {
            selectedTopAllTimeLineOfBusiness = currentTopAllTimeLOB;
        }
        if(currentTopAllTimeCat != null) {
            selectedTopAllTimeCategory = currentTopAllTimeCat;
        }
        if(currentTopAllTimeStat != null) {
            selectedTopAllTimeIdeaStatus = currentTopAllTimeStat;
        }
        getAllTopAllTimeIdeas();
        populateDataTopAllTime();
        loadTopAllTimePagination();
            totalTopAllTimeNum = paginaterTopAllTime.totalPageTopAllTime;
    }
   
    /*
    *    @description:    action for reloading comment/all ideas ideas pagination after selecting filters.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String currentCommentLOB {get;set;}
    public String currentCommentCat {get;set;}
    public String currentCommentStat {get;set;}
    public Integer totalCommentNum {get;set;}
    public void loadCommentPaginationWithFilter() {
        system.debug('\n\n*****ENTER loadCommentPaginationWithFilter*****\n\n'); 
        if(currentCommentLOB != null) {
            selectedCommentLineOfBusiness = currentCommentLOB;
        }
        if(currentCommentCat != null) {
            selectedCommentCategory = currentCommentCat;
        }
        if(currentCommentStat != null) {
            selectedCommentIdeaStatus = currentCommentStat;
        }
        getAllCommentIdeas();
        populateDataComment();
        loadCommentPagination();
            totalCommentNum = paginaterComment.totalPageComment;
    }
   
    /*
    *    @description:    action for reloading SearchResult ideas pagination after voting.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Integer totalSearchResultNum {get;set;}
    public void loadSearchResultPaginationWithFilter() {
        system.debug('\n\n*****ENTER loadSearchResultPaginationWithFilter*****\n\n'); 
        getAllSearchResultIdeas();
        populateDataSearchResult();
        loadSearchResultPagination();   
            totalSearchResultNum = paginaterSearchResult.totalPageSearchResult;
    }
    
    public void test(){
        
        System.debug('JED           ' + selectedTab);
        
    }
    
}