@isTest
public class PaginateMyIdeasTest{
public static testMethod void TestPaginateMyIdeas() {
PaginateMyIdeas controller = new PaginateMyIdeas(10,10);
controller.totalPageMyIdeas=6;
controller.updateNumbersMyIdeas();
controller.totalPageMyIdeas=7;
controller.pageNumMyIdeas=3;
controller.updateNumbersMyIdeas();
controller.pageNumMyIdeas=7;
controller.updateNumbersMyIdeas();
controller.totalPageMyIdeas=10;
system.assertEquals(controller.totalPageMyIdeas,10);
controller.pageNumMyIdeas=3;
controller.updateNumbersMyIdeas();
controller.pageNumMyIdeas=4;
controller.updateNumbersMyIdeas();
controller.decrementMyIdeas();
controller.incrementMyIdeas();
system.assertEquals(controller.pageNumMyIdeas,4);
}
}