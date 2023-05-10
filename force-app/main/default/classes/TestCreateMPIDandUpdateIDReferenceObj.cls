/*
 test class for the createMPIDandUpdateIDReferenceObj Trigger
*/
@isTest(SeeAllData=true)

public class TestCreateMPIDandUpdateIDReferenceObj  {
    public static testMethod void test() 
    {   
        Test.startTest();
        Marketing_Program__c mp = new Marketing_Program__c();
        mp.name='TestMP';
        mp.Offer_Portfolio__c='Self Service Banking';
        mp.ID__c='test0';
        mp.Active__c=true;
        insert mp;
        Marketing_Program__c mp1 = [Select id,name from Marketing_Program__c where name='TestMP'];
        mp1.name='TestMP1';
        update mp1;
        Marketing_Program__c mp2 = [Select id,Industry__c from Marketing_Program__c where name='TestMP1'];
        mp2.Industry__c='TestMP1';
        update mp2;
        Marketing_Program__c mp3 = [Select id,Industry__c,Name,MarketingProgram_OfferPortfolio__c from Marketing_Program__c where name='TestMP1'];
        System.assertEquals(mp3.MarketingProgram_OfferPortfolio__c, mp3.Name+mp3.Industry__c);
        Test.stopTest();
    }
}