@isTest
public class PaginatePopularTest{
public static testMethod void TestPaginatePopular() {
PaginatePopular controller = new PaginatePopular(10,10);
controller.totalPagePopular=6;
controller.updateNumbersPopular();
controller.totalPagePopular=7;
controller.pageNumPopular=3;
controller.updateNumbersPopular();
controller.pageNumPopular=7;
controller.updateNumbersPopular();
controller.totalPagePopular=10;
system.assertEquals(controller.totalPagePopular,10);
controller.pageNumPopular=3;
controller.updateNumbersPopular();
controller.pageNumPopular=4;
controller.updateNumbersPopular();
controller.decrementPopular();
controller.incrementPopular();
system.assertEquals(controller.pageNumPopular,4);
}
}