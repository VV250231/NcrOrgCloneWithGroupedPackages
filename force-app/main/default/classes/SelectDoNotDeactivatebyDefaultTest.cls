@isTest(SeeAllData=true)
public class SelectDoNotDeactivatebyDefaultTest {
public static testMethod void SelectDoNotDeactivatebyDefault() {
Account a = new Account(name = 'test');
     system.runas(TestRecordsFactory.getUser())
        {
            insert a; 
        }
contact c = new contact(lastname='test',email='test@test.com',accountid=a.id) ;
insert c;
Profile p = new Profile();
p = [select id from profile where name =: '61 DI Community Members'] ;
User newUser = new User();
newUser.lastname = 'test' ;
newUser.email = 'test@test.com' ;
newUser.Username = 'devadmindevadmin@ncr.com.production';
newUser.ProfileId = p.id ;
newUser.CommunityNickname = 'test' ;
newUser.FederationIdentifier='zz000000' ;
newUser.Quicklook_ID__c='zz000000' ;
newUser.contactid=c.id ;
//newUser
newUser.Alias = 'zz000000' ;
newUser.TimeZoneSidKey = 'America/New_York' ;
newUser.LocaleSidKey = 'en_US' ;
newUser.EmailEncodingKey = 'UTF-8' ;
newUser.LanguageLocaleKey = 'en_US' ;

insert newUser ;
system.assert(newUser!=null);
}
}