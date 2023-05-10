@isTest
public class PaginateSearchResultTest{
public static testMethod void TestPaginateSearchResult() {
PaginateSearchResult controller = new PaginateSearchResult(10,10);
controller.totalPageSearchResult=6;
controller.updateNumbersSearchResult();
controller.totalPageSearchResult=7;
controller.pageNumSearchResult=3;
controller.updateNumbersSearchResult();
controller.pageNumSearchResult=7;
controller.updateNumbersSearchResult();
controller.totalPageSearchResult=10;
controller.pageNumSearchResult=3;
controller.updateNumbersSearchResult();
controller.pageNumSearchResult=4;
controller.updateNumbersSearchResult();
controller.decrementSearchResult();
controller.incrementSearchResult();
system.assertEquals(controller.pageNumSearchResult,4);
}
}