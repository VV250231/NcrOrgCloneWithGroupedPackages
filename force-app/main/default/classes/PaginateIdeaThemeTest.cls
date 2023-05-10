@isTest
public class PaginateIdeaThemeTest{
    public static testMethod void TestPaginateIdeaTheme() {
        PaginateIdeaTheme controller = new PaginateIdeaTheme(10,10);
        controller.totalPage =6;
        controller.updateNumbers();
        controller.totalPage =7;
        controller.pageNum =3;
        controller.updateNumbers();
        controller.pageNum =7;
        controller.updateNumbers();
        controller.totalPage =10;
        controller.pageNum =3;
        controller.updateNumbers();
        controller.pageNum =4;
       
        controller.updateNumbers();
        controller.decrement();
        controller.increment();
         system.assertEquals(controller.pageNum ,4);
    }
}