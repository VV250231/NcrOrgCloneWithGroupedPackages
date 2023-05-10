/*
##################################################################################################
# Project Name..........: Sales Reporting                                                                     
# File..................: CalculateRegionHierarchyTest.cls                                                        
# Version...............: 41.0 
# Created by............: Ravikant Maurya                                                                   
# Created Date..........: 15-01-2018                                                                               
# Last Modified by......: Ravikant Maurya
# Last Modified Date....: 15-01-2018 
# Description...........: The test class is written to test the CalculateRegionHierarchy Trigger.
################################################################################################
*/
@isTest
public class CalculateRegionHierarchyTest {
     static testMethod void runUnitTest() {
         String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
         Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
         insert s;
         
         String profileName = '04 NSC UI Administrator';
         Profile userProfile;
         List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name =: profileName LIMIT 1];
            if (profiles.size() > 0) {
               userProfile = profiles[0];
            }
         String usrname = uniqueName + '@test' + orgId + '.org';
         User us              =  new User();
         us.Profileid         = userProfile.Id;
         us.Username          = usrname;
         us.Email             = usrname;
         us.Alias             = 'alias';           
         us.FirstName         = 'Fname';
         us.LastName          = 'lname';
         us.LocaleSidKey      = 'ar';
         us.LanguageLocaleKey = 'de';
         us.TimeZoneSidKey    = 'Africa/Cairo';
         us.EmailEncodingKey  = 'Big5';
         us.CurrencyIsoCode   = 'AUD';
         us.Quicklook_ID__c   = 'sm25066';
         us.Sales_Org_Code__c   = '126232';    
         insert us;
         
         User u = [select id from user where Username = :usrname ];
         System.assert(u.Id!=null);
     }    
}