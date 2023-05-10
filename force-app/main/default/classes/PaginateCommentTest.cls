@isTest
public class PaginateCommentTest{
public static testMethod void TestPaginateComment() {
PaginateComment controller = new PaginateComment(10,10);
controller.totalPageComment=6;
system.assertEquals(controller.totalPageComment,6);
controller.updateNumbersComment();
controller.totalPageComment=7;
controller.pageNumComment=3;
controller.updateNumbersComment();
controller.pageNumComment=7;
controller.updateNumbersComment();
controller.totalPageComment=10;
controller.pageNumComment=3;
controller.updateNumbersComment();
controller.pageNumComment=4;
controller.updateNumbersComment();
controller.decrementComment();
controller.incrementComment();
system.assertEquals(controller.pageNumComment,4);
}
}