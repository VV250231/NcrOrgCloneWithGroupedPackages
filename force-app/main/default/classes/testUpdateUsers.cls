@isTest(SeeAllData=true)
public class testUpdateUsers{
    public static testMethod void test(){
        
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        Profile chaterProfile = [SELECT Id FROM Profile WHERE Name = '90 Chatter Free' Limit 1]; 
        User usr = new User();
        usr.Username = 'sysAdmin@ncr.com1';
        usr.UserRole= role ;
        usr.ProfileId = chaterProfile.id;
        usr.Alias = 'admin121';
        usr.Email = 'sm245977@gmail.com';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LastName = 'systemAdmin';
        usr.CommunityNickname = 'adminUser1';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.LanguageLocaleKey = 'en_US';
        usr.FederationIdentifier='sm12xx36';
        usr.Quicklook_ID__c = 'sm12xx35';
       
        insert usr;
        
     
        
        User usr1 = new User();
        usr1.Username = 'sysAdmin@ncr.com2';
        usr1.UserRole= role ;
        usr1.ProfileId = adminProfile.Id;
        usr1.Alias = 'admin122';
        usr1.Email = 'sm245977@gmail1.com';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.LastName = 'systemAdmin2';
        usr1.CommunityNickname = 'xyzNamecom';
        usr1.TimeZoneSidKey = 'America/Los_Angeles';
        usr1.LocaleSidKey = 'en_US';
        usr1.LanguageLocaleKey = 'en_US';
        usr1.Quicklook_ID__c='sm12xx36';
        usr1.FederationIdentifier='sm12xx36';
        
       
        insert usr1;
        System.assertNotEquals(usr1.id, null,'User Record Should not be null');
        
        
        Try {
        User usr2 = new User();
        usr2.Username = 'sysAdmin@ncr.com3';
        usr2.UserRole= role ;
        usr2.ProfileId = adminProfile.Id;
        usr2.Alias = 'admin123';
        usr2.Email = 'sm245977@gmail.com';
        usr2.EmailEncodingKey = 'UTF-8';
        usr2.LastName = 'systemAdmin';
        usr2.CommunityNickname = 'adminUse3';
        usr2.TimeZoneSidKey = 'America/Los_Angeles';
        usr2.LocaleSidKey = 'en_US';
        usr2.LanguageLocaleKey = 'en_US';
        usr2.FederationIdentifier = 'admin333';
        usr2.FederationIdentifier=null;
        usr2.Quicklook_ID__c='s0m03600';
        
        insert usr2; 
        
        }
        catch (Exception ex) {
            System.debug('Error '+ex.getMessage());
        }
    }
    
    
    Public Static TestMethod void Method1(){
         // User u1 = [Select ID From User Where Id =: '00570000003i3u3AAA'];
        System.runAs (TestRecordsFactory.getUser() ) {
            Account act = PRM_TestRecordsFactory.createPartnerAccount('1',null);
            insert act;
            Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id,'1',null);
            insert con;
            User partnerUser = PRM_TestRecordsFactory.createPartnerUser(con.Id, '1', null);
            insert partnerUser;
            System.assertNotEquals(partnerUser.id, null,'PartnerUser Record Should not be null');
        }
    }
  
}