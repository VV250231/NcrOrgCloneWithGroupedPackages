@isTest(seeAllData=true)
public class StatusChangeNotificationTest {
private static List<String> productManagers;
public static List<String> getProductManagers() {
  if (! (productManagers != null)) {
    productManagers = new List<String>();
    Schema.DescribeFieldResult fieldResult = Idea.Di_Idea_Product_Manager__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   // for( Schema.PicklistEntry f : ple) {
   //   productManagers.add(f.getValue());
   // }  
  }
  return productManagers;
}

public static testMethod void testStatusChangeNotification() {

List<User> altProductManagers = new List<User>();
List<Profile> proFiles = new List<Profile>();
proFiles = [SELECT Id, Name FROM Profile WHERE Name = '60 DI Product Managers'];
if (proFiles.size() > 0) {
  for (integer i = 0; i < 3 ; i++) {
    User u = new User();
    u.FirstName = 'First' + String.valueOf(i);
    u.LastName = 'Last' + String.valueOf(i);
    u.Alias = 'Alias' + String.valueOf(i);
    u.UserName = 'UserName' + String.valueOf(i) + '@ncr.com';
    u.Email = 'username' + String.valueOf(i) + '@ncr.com';
    u.CommunityNickname = 'CommunityNickname' + String.valueOf(i);
    u.ProfileId = proFiles[0].Id;
    u.LanguageLocaleKey='en_US';
    u.LocaleSidKey='en_US';
    u.TimeZoneSidKey='America/Los_Angeles';
    u.EmailEncodingKey='UTF-8';
    u.Quicklook_ID__c = 'ab00011'+String.valueOf(i);
    u.LOB__c = 'RETAIL';
    u.License_Entitlement__c='Partner Portal-Full';
    u.Area__c ='INDIA';
    u.Access_Type__c = 'User';
    //u.Language = 'English';
    //u.currency = 'USD - U.S. Dollar';
    altProductManagers.add(u);      
  }
}

if (altProductManagers.size() > 0) {
    insert altProductManagers;
}
System.assert(altProductManagers[0].id!=null);
Idea idea = new Idea();
Community community = new Community();
community = [select id from Community where Name='IdeaExchange'];
idea.title='test';
idea.body='test';
if (getProductManagers().size() > 0)
  idea.Di_Idea_Product_Manager__c = getProductManagers()[0];
idea.Di_Idea_Alt_1st_Product_Manager__c = altProductManagers[0].Id;
idea.Di_Idea_Alt_2nd_Product_Manager__c = altProductManagers[1].Id;
idea.Di_Idea_Alt_3rd_Product_Manager__c =  altProductManagers[2].Id;
idea.status = 'Under Point Threshold';
idea.communityid=community.id;
insert idea;


/*
 *    @description:    Test code for Sending notification to Ideatheme Owner, IdeaTheme Co-Owner and Fi-user when new idea created with ideaTheme.
 *    @author:         Rajasekhar reddy(Rajasekhar.reddy@ncr.com)
 *    @createdDate     August 04, 2016
*/

user u = new user();
u = [select id from user where name=: 'Dev Admin'] ;
Di_Idea_Favorites__c a = new Di_Idea_Favorites__c(Di_Idea__c=idea.id,User__c=u.id);
insert a;
idea=[select id , title , status from idea where id=: idea.id];
idea.status = 'Accepted';
update idea;
idea idea1 =[select id , title , status from idea where id=: idea.id]; 
System.assert(idea1.status=='Accepted');
}

public static testmethod void StatusChangeNotificationTest(){
    
    Community c=[select id from community limit 1];
    ideatheme ith=new ideatheme();
        ith.title='abc';
        ith.DI_Owner__c =userinfo.getUserid();
        ith.DI_Co_owner__c = userinfo.getUserid();
        ith.Communityid=c.id;
    insert ith;
    
    Di_Idea_Favorites__c obj = new Di_Idea_Favorites__c();
        obj.DI_Idea_Theme__c = ith.id;
        obj.User__c = UserInfo.getUserId();
    insert obj;
    
    idea i=new idea();
        i.CommunityId=c.id;
        i.title='xyz';
        i.ideathemeid=ith.id;
    insert i;
    System.assert(i!=null);
    }

}