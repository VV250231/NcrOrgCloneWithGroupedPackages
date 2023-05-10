/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CampaignActivityTriggerTest {

    static testMethod void campActOwnerChangeTest() {
        
        //Fetch Profile
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //Creat a user
        User us =  new User();
        us.Profileid = p.id;
        us.Email = 's.mahla@ncr.com';
        us.Alias= 'sm250665';
        us.Username = 's@ncr.com';
        us.FirstName ='Fname';
        us.LastName = 'lname';
        us.LocaleSidKey= 'ar';
        us.LanguageLocaleKey= 'de';
        us.TimeZoneSidKey= 'Africa/Cairo';
        us.EmailEncodingKey = 'Big5';
        us.CurrencyIsoCode= 'AUD';
        us.Quicklook_ID__c='sq250665';
        insert us;
        
        //create another user
        User us1 =  new User();
        us1.Profileid = p.id;
        us1.Email = 'ss.mahla@ncr.com';
        us1.Alias= 'ss250665';
        us1.Username = 'ss@ncr.com';
        us1.FirstName ='Fname1';
        us1.LastName = 'lname1';
        us1.LocaleSidKey= 'ar';
        us1.LanguageLocaleKey= 'de';
        us1.TimeZoneSidKey= 'Africa/Cairo';
        us1.EmailEncodingKey = 'Big5';
        us1.CurrencyIsoCode= 'AUD';
        us1.Quicklook_ID__c='ss250665';
        insert us1;
        User u = TestRecordsFactory.getUser();
        System.runAs(u){
        //create new account
        Account a = new Account(name = 'account');
        a.OwnerId = us.Id ;
        insert a;
        }
        //Create Campaign activity under that.
        Campaign_Activity__c campAct = new Campaign_Activity__c();
        campAct.Assign_to__c = us.Id ;
        campAct.Campaign_Name__c = 'campaign3031';
        campAct.Status__c = 'Open';
        campAct.Subject__c='Validate this Account';
        insert campAct ;
        
        Campaign_Activity__c campObj = [select Assign_to__c,OwnerId from Campaign_Activity__c where id=:campAct.id ];
        System.assert(campObj.Assign_to__c==campObj.OwnerId);
        
        
        CheckRecursive.run = true;
        //Change Assign to
        campAct.Assign_to__c = us1.Id ;
        update campAct;
        
        system.debug('UserId:'+us.Id+'AssignToId:'+campAct.Assign_to__c+'CampActOwner:'+campAct.OwnerId);
        
        //System.assert(campAct.OwnerId == Us.Id);
        
    }
}