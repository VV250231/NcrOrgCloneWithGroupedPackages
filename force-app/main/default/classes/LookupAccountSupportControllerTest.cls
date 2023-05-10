@isTest
public class LookupAccountSupportControllerTest {
    @isTest static void TestLookupAccountSupport(){
        Profile pf= [Select Id from profile where Name='04 NSC UI Administrator'];
        List<User> userList = new List<User>();
        for(Integer i=0;i<10;i++){
            User users = new User();
        	users.LastName = 'Test'+i;
        	users.IsActive = true;
        	users.Email = 'Test@test.com';
        	users.Username = 'Test'+i+'@test.com' + System.currentTimeMillis();
        	users.CompanyName = 'TEST';
        	users.Title = 'title';
        	users.Quicklook_ID__c='ta25028'+i;
        	users.FederationIdentifier ='tta25028'+i;
        	users.Alias = 'alias';
        	users.TimeZoneSidKey = 'America/Los_Angeles';
        	users.EmailEncodingKey = 'UTF-8';
        	users.LanguageLocaleKey = 'en_US';
        	users.LocaleSidKey = 'en_US';
        	users.ProfileId = pf.id;
            userList.add(users);
        }
        Test.startTest();
        insert userList;
       	String jsonData = LookupAccountSupportController.searchDB('User','Title','Id,LastName',5,'Title','title','title');
        LookupAccountSupportController.searchDB('Account','Name','Id',5,null,'Name','Name');
        Test.stopTest();
        System.assert(jsonData.length()>0);
    }
}