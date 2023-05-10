public class HomePageLinks {
     @AuraEnabled
    public static List <homepagelink__mdt> fetchLinks()
    {
        List <homepagelink__mdt> hml=[Select DeveloperName, Sort_Order__c, MasterLabel, Link__c from homepagelink__mdt order by Sort_Order__c];
		return hml;
    }

}