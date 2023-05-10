@isTest
public class PaginateRepliesTest{
public static testMethod void TestPaginateReplies() {
PaginateReplies controller = new PaginateReplies(10,10);
controller.totalPageReplies=6;
controller.updateNumbersReplies();
controller.totalPageReplies=7;
controller.pageNumReplies=3;
controller.updateNumbersReplies();
controller.pageNumReplies=7;
controller.updateNumbersReplies();
controller.totalPageReplies=10;
controller.pageNumReplies=3;
controller.updateNumbersReplies();
controller.pageNumReplies=4;
system.assertEquals(controller.pageNumReplies,4);
controller.updateNumbersReplies();
controller.decrementReplies();
controller.incrementReplies();
system.assertEquals(controller.pageNumReplies,4);
}
}