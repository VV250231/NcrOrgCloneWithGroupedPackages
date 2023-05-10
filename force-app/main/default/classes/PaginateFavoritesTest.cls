@isTest
public class PaginateFavoritesTest{
public static testMethod void TestPaginateFavorites() {
PaginateFavorites controller = new PaginateFavorites(10,10);
controller.totalPageFavorites=6;
controller.updateNumbersFavorites();
controller.totalPageFavorites=7;
controller.pageNumFavorites=3;
controller.updateNumbersFavorites();
controller.pageNumFavorites=7;
controller.updateNumbersFavorites();
controller.totalPageFavorites=10;
controller.pageNumFavorites=3;
controller.updateNumbersFavorites();
controller.pageNumFavorites=4;
controller.updateNumbersFavorites();
controller.decrementFavorites();
controller.incrementFavorites();
System.assertEquals(controller.pageNumFavorites,4);
}
}