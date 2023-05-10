@isTest
public class PaginateTopAllTimeTest{
public static testMethod void TestPaginateTopAllTime() {
PaginateTopAllTime controller = new PaginateTopAllTime(10,10);
controller.totalPageTopAllTime=6;
controller.updateNumbersTopAllTime();
controller.totalPageTopAllTime=7;
controller.pageNumTopAllTime=3;
controller.updateNumbersTopAllTime();
controller.pageNumTopAllTime=7;
controller.updateNumbersTopAllTime();
controller.totalPageTopAllTime=10;
controller.pageNumTopAllTime=3;
controller.updateNumbersTopAllTime();
controller.pageNumTopAllTime=4;
controller.updateNumbersTopAllTime();
controller.decrementTopAllTime();
controller.incrementTopAllTime();
system.assertEquals(controller.pageNumTopAllTime,4);
}
}