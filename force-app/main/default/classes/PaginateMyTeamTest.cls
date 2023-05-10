@isTest
public class PaginateMyTeamTest{
public static testMethod void TestPaginateMyTeam() {
PaginateMyTeam controller = new PaginateMyTeam(10,10);
controller.totalPageMyTeam=6;
controller.updateNumbersMyTeam();
controller.totalPageMyTeam=7;
controller.pageNumMyTeam=3;
controller.updateNumbersMyTeam();
controller.pageNumMyTeam=7;
controller.updateNumbersMyTeam();
controller.totalPageMyTeam=10;
system.assertEquals(controller.totalPageMyTeam,10);
controller.pageNumMyTeam=3;
controller.updateNumbersMyTeam();
controller.pageNumMyTeam=4;
controller.updateNumbersMyTeam();
controller.decrementMyTeam();
controller.incrementMyTeam();
system.assertEquals(controller.pageNumMyTeam,4);
}
}