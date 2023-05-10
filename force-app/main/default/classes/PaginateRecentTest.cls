@isTest
public class PaginateRecentTest{
public static testMethod void TestPaginateRecent() {
PaginateRecent controller = new PaginateRecent(10,10);
controller.totalPageRecent=6;
controller.updateNumbersRecent();
controller.totalPageRecent=7;
controller.pageNumRecent=3;
controller.updateNumbersRecent();
controller.pageNumRecent=7;
controller.updateNumbersRecent();
controller.totalPageRecent=10;
system.assertEquals(controller.totalPageRecent,10);
controller.pageNumRecent=3;
controller.updateNumbersRecent();
controller.pageNumRecent=4;
controller.updateNumbersRecent();
controller.decrementRecent();
controller.incrementRecent();
system.assertEquals(controller.pageNumRecent,4);
}
}