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
private class updateCampaignActivityOwnerUtilTest {
    
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
        us.Quicklook_ID__c='sz250665';
        insert us;
        
        List<Campaign_Activity__c> campList = new List<Campaign_Activity__c>();
        //Create Campaign activity under that.
        Campaign_Activity__c campAct = new Campaign_Activity__c();
        campAct.Assign_to__c = us.Id ;
        campAct.Campaign_Name__c = 'campaign3031';
        campAct.Status__c = 'Open';
        campAct.Subject__c='Validate this Account';
        
        campList.add(campAct);
        insert campList;
        updateCampaignActivityOwnerUtil.updateOwner(null,null,campList);
        Campaign_Activity__c caObj = [select OwnerId,Assign_to__c from Campaign_Activity__c where id=:campAct.id];
        System.assert(caObj.Assign_to__c==caObj.OwnerId);
    }      
}