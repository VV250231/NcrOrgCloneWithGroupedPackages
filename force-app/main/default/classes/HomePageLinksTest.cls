@IsTest
public class HomePageLinksTest {
    static testmethod void testSearch() {
        List <homepagelink__mdt> hml =HomePageLinks.fetchLinks();
        System.assert(hml!=null);
        
    }
    
    
}