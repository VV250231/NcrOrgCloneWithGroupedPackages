@isTest(SeeAllData=true)
public class NCR_ViewAllPageControllerTest {
    public static testMethod void testNCR_ViewAllPageController() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Recent');
        ApexPages.currentPage().getParameters().put('cat', 'User Profile Settings');    
        ApexPages.currentPage().getParameters().put('cat', 'Promotion Suite');
        Apexpages.currentPage().getParameters().put('selectedPageComment','1');
        ApexPages.currentPage().getParameters().put('pNum','1');
        ApexPages.currentPage().getParameters().put('num','1');
        
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadRecentPagination();
        controller.loadPopularPagination();
        //controller.getaccountvote('234234');    
        controller.loadCommentPagination();
        controller.loadSearchResultPagination();
        controller.loadFiltersFromOtherPage();
        controller.gotoSetLOBComment();
        controller.getLineOfBusinessValues();
        controller.getLineOfBusinessValuesPopular();
        controller.getLineOfBusinessValuesComment();
        controller.getPopularCategoryValues();
        controller.getCategoryValues();
        controller.getCommentCategoryValues();
        controller.getIdeaStatusValues();
        controller.getAllRecentIdeas();
        controller.getAllPopularIdeas();
        controller.getAllCommentIdeas();
        ApexPages.currentPage().getParameters().put('searchItemVal', 'mobile');
        controller.getAllCommentIdeas();
        controller.getAllSearchResultIdeas();
        controller.gotoSetLOBRecent();
        controller.gotoSetLOBPopular();
        controller.gotoSetLOBSearchResult();
        controller.changeRecentCategory();
        controller.changeRecentStatus();
        controller.changePopularLineOfBusiness();
        controller.changePopularCategory();
        controller.changePopularStatus();
        controller.changeCommentLineOfBusiness();
        controller.changeCommentCategory();
        test.starttest();
        
        controller.changeCommentStatus();
        controller.voteUpSearchResult();
        controller.voteUpComment();
        controller.voteUpTopAllTime();
        controller.voteUpPopular();
        controller.voteUpRecent();
       // controller.previousPageComment();
        controller.changeDataTopAllTime();
        controller.updatePageSearchResult();
        controller.changeDataSearchResult();
        controller.nextPageSearchResult();
        //controller.updatePageComment();
        controller.changeTopAllTimeStatus();
        controller.populateDataRecent();
        controller.loadSearchResultPaginationWithFilter();
        test.stoptest();
        //controller.updatePagePopular();
        //controller.changeDataPopular();
        //controller.updatePageComment();
        //controller.changeDataComment();
    }
    public static testMethod void testNCR_ViewAllPageController1() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'TopAllTime');
        ApexPages.currentPage().getParameters().put('cat', 'General Retail Banking');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.changeTopAllTimeCategory();
        controller.SubscribeRecent();
        controller.SubscribeTop();
        controller.Subscribe1Top();
        controller.Subscribe1Recent();
        controller.Subscribe();
        controller.Subscribe1();
    }
    public static testMethod void testNCR_ViewAllPageController2() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Popular');
        ApexPages.currentPage().getParameters().put('cat', 'General Retail Banking');
        ApexPages.currentPage().getParameters().put('searchItemVal','test5645');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        
        Community community = [ SELECT Id FROM Community WHERE Name = 'IdeaExchange' limit 1];
        idea a=new idea();
        a.title='test2343';
        a.CommunityId = community.Id;
        insert a;
        
        controller.recentVoteIdeaId=a.id;
        
        controller.recentIdeaId = a.Id;
        controller.insertToMyFavoritesRecent();
        controller.deleteToMyFavoritesRecent();
        
        controller.popularIdeaId = a.Id;
        controller.insertToMyFavoritesPopular();
        controller.deleteToMyFavoritesPopular();
        
        controller.TopAllTimeIdeaId = a.Id;
        controller.insertToMyFavoritesTopAllTime();
        controller.deleteToMyFavoritesTopAllTime();
        
        controller.commentIdeaId = a.Id;
        controller.insertToMyFavoritesComment();
        controller.deleteToMyFavoritesComment();
        
        controller.SearchResultIdeaId = a.Id;
        controller.insertToMyFavoritesSearchResult();
        controller.deleteToMyFavoritesSearchResult();
        
        controller.recentVoteIdeaId = a.Id;
        //controller.voteUpRecent();
        
        controller.popularVoteIdeaId = a.Id;
        //controller.voteUpPopular();
        
        controller.TopAllTimeVoteIdeaId = a.Id;
        //controller.voteUpTopAllTime();
        
        controller.CommentVoteIdeaId = a.Id;
        //controller.voteUpComment();
        
        controller.SearchResultVoteIdeaId = a.Id;
        System.assertEquals(controller.SearchResultVoteIdeaId, a.Id);
        //controller.voteUpSearchResult();
    }
    public static testMethod void testNCR_ViewAllPageController3() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'Promotion Suite');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
    }
    
    public static testMethod void testNCR_ViewAllPageController4() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Recent');
        ApexPages.currentPage().getParameters().put('cat', 'Idea Exchange');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getCategoryValues();
        controller.changeRecentCategory();
    }
    public static testMethod void testNCR_ViewAllPageController5() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Recent');
        ApexPages.currentPage().getParameters().put('cat', 'Check/Deposit Imaging');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getCategoryValues();
        controller.changeRecentCategory();
    }
    public static testMethod void testNCR_ViewAllPageController6() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Popular');
        ApexPages.currentPage().getParameters().put('cat', 'Promotion Suite');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getPopularCategoryValues();
        controller.gotoSetLOBPopular();
    }
    public static testMethod void testNCR_ViewAllPageController7() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Popular');
        ApexPages.currentPage().getParameters().put('cat', 'Person to Person Payments');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getPopularCategoryValues();
        controller.gotoSetLOBPopular();
    }
    public static testMethod void testNCR_ViewAllPageController8() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Popular');
        ApexPages.currentPage().getParameters().put('cat', 'Idea Exchange');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getPopularCategoryValues();
        controller.gotoSetLOBPopular();
    }
    public static testMethod void testNCR_ViewAllPageController9() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Popular');
        ApexPages.currentPage().getParameters().put('cat', 'Check/Deposit Imaging');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getPopularCategoryValues();
        controller.gotoSetLOBPopular();
    }
    public static testMethod void testNCR_ViewAllPageController10() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'TopAllTime');
        ApexPages.currentPage().getParameters().put('cat', 'Promotion Suite');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.changeTopAllTimeLineOfBusiness();
        controller.gotoSetLOBTopAllTime();
        controller.getTopAllTimeCategoryValues();
        controller.changeTopAllTimeCategory();
    }
    public static testMethod void testNCR_ViewAllPageController11() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'TopAllTime');
        ApexPages.currentPage().getParameters().put('cat', 'Person to Person Payments');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.changeTopAllTimeLineOfBusiness();
        controller.gotoSetLOBTopAllTime();
        controller.getTopAllTimeCategoryValues();
        controller.changeTopAllTimeCategory();
    }
    public static testMethod void testNCR_ViewAllPageController12() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'TopAllTime');
        ApexPages.currentPage().getParameters().put('cat', 'Idea Exchange');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.changeTopAllTimeLineOfBusiness();
        controller.gotoSetLOBTopAllTime();
        controller.getTopAllTimeCategoryValues();
        controller.changeTopAllTimeCategory();
        controller.getIdeaStatusValuesComment();
    }
    public static testMethod void testNCR_ViewAllPageController13() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'Idea Exchange');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    public static testMethod void testNCR_ViewAllPageController14() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'Check/Deposit Imaging');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    public static testMethod void testNCR_ViewAllPageController15() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Recent');
        ApexPages.currentPage().getParameters().put('cat', 'General Business Banking');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getCategoryValues();
        controller.changeRecentCategory();
    }
    public static testMethod void testNCR_ViewAllPageController16() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Recent');
        ApexPages.currentPage().getParameters().put('cat', 'Person to Person Payments');
        ApexPages.currentPage().getParameters().put('line', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('stat', 'stat');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getCategoryValues();
        controller.changeRecentCategory();
    }
    public static testMethod void testNCR_ViewAllPageController17() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'Promotion Suite');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    public static testMethod void testNCR_ViewAllPageController18() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'Popular');
        ApexPages.currentPage().getParameters().put('cat', 'General Business Banking');
        ApexPages.currentPage().getParameters().put('line', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('stat', 'stat');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getPopularCategoryValues();
        controller.gotoSetLOBPopular();
        controller.getIdeaStatusValuesPopular();
    }
    public static testMethod void testNCR_ViewAllPageController19() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'TopAllTime');
        ApexPages.currentPage().getParameters().put('cat', 'General Business Banking');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.changeTopAllTimeLineOfBusiness();
        controller.gotoSetLOBTopAllTime();
        controller.getTopAllTimeCategoryValues();
        controller.getIdeaStatusValuesTopAllTime();
        controller.changeTopAllTimeCategory();
    }
    public static testMethod void testNCR_ViewAllPageController20() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'TopAllTime');
        ApexPages.currentPage().getParameters().put('cat', 'Check/Deposit Imaging');
        ApexPages.currentPage().getParameters().put('line', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('stat', 'stat');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.changeTopAllTimeLineOfBusiness();
        controller.gotoSetLOBTopAllTime();
        controller.getTopAllTimeCategoryValues();
        controller.changeTopAllTimeCategory();
        
    }
    public static testMethod void testNCR_ViewAllPageController21() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'General Business Banking');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
        
    }
    public static testMethod void testNCR_ViewAllPageController22() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'General Business Banking');
        ApexPages.currentPage().getParameters().put('line', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('stat', 'stat');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.getSubscriptionRecent();
        controller.currentRecentLOB='test';
        controller.currentRecentCat='test';
        controller.currentRecentStat='test';
        controller.totalRecentNum=19;
        controller.loadRecentPaginationWithFilter();
        controller.currentPopularLOB='test';
        controller.currentPopularCat='test';
        controller.currentPopularStat='test';
        controller.totalPopularNum=19;
        controller.loadPopularPaginationWithFilter();
        controller.currentTopAllTimeLOB='test';
        controller.currentTopAllTimeCat='test';
        controller.currentTopAllTimeStat='test';
        controller.totalTopAllTimeNum=19;
        controller.loadTopAllTimePaginationWithFilter();
        controller.SubscriberCheck=true;
        controller.SubscriberCheckrecent=true;
        controller.ShowSubscription=true;
        controller.ShowSubscriptionrecent=true;
        controller.SubscriberCheckTop=true;
        controller.SubscriberCheckAllIdeas=true;
        controller.getSubscription1Recent();
        controller.getSubscription1();
        controller.getSubscription();
        controller.getSubscriptionTop();
        controller.getSubscriptionAllIdeas();
        controller.getSubscription1AllIdeas();
        controller.getSubscription1Top();
        controller.currentCommentLOB='Test';
        controller.currentCommentCat='Test';
        controller.defaultPopularLOBCat='Test';
        
        
        
        
        controller.totalCommentNum=9;
        controller.loadCommentPaginationWithFilter();
        controller.defaultCommentLOBCat='Test';
        controller.defaultRecentLOBCat='Test';
        controller.changeRecentLineOfBusiness();
        controller.pNum=1;
        controller.selectedAllTimeLineOfBusiness='Test';
        controller.selectedAllTimeCategory='Test';
        controller.selectedAllTimeIdeaStatus='Test';
        
        
    }
    public static testMethod void testNCR_ViewAllPageController_1() {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectTab', 'AllIdeas');
        ApexPages.currentPage().getParameters().put('cat', 'User Profile Settings');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        String categoryReplacement = 'User Profile Settings';
        PageReference pageRef2 = Page.NCR_ViewAllpage;
        //gotorecord.setRedirect(true);
        //return gotorecord;
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    public static testMethod void testNCR_ViewAllPageController_2()  
    {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('cat', 'Alerts');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    public static testMethod void testNCR_ViewAllPageController_3()  
    {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('cat', 'Web Center');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    
    public static testMethod void testNCR_ViewAllPageController_4()  
    {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('cat', 'General Payments');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    
    public static testMethod void testNCR_ViewAllPageController_5()  
    {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('cat', 'Online Forms');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    public static testMethod void testNCR_ViewAllPageController_6()  
    {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('cat', 'Remote Deposit');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
    
    public static testMethod void testNCR_ViewAllPageController_7()  
    {
        PageReference pageRef = Page.NCR_ViewAllpage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('cat', 'User Profile Settings');
        NCR_ViewAllPageController controller = new NCR_ViewAllPageController();
        controller.loadFiltersFromOtherPage();
        controller.getLineOfBusinessValuesTopAllTime();
        controller.getCommentCategoryValues();
    }
}