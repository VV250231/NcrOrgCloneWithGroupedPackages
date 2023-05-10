@isTest
  Public class DI_StatusUpdateTest{
    static testMethod void TestDI_StatusUpdate(){
   
 /* Profile p = [SELECT Id FROM Profile WHERE Name = '61 DI Community Members'];

            User u = new User(
              Alias = 'testu',
              Email = 'old@gmail.com',
              EmailEncodingKey = 'UTF-8',
              LastName = 'Test',
              LanguageLocaleKey = 'en_US',
              LocaleSidKey = 'en_US',
              TimeZoneSidKey='America/Los_Angeles',
              ProfileId = p.Id,
              UserName='sume@gmail.com',
              Quicklook_ID__c = 'test',
              title = 'new'
              );*/
  
   
    Community c=[select id from community limit 1]; 
   
    ideatheme ith=new ideatheme();
        ith.title='abc';
        ith.DI_Owner__c =userinfo.getUserid();
        ith.DI_Co_owner__c = userinfo.getUserid();
        ith.Status = 'Accepting Ideas';
        ith.Communityid=c.id;
    insert ith;
    System.assert(ith.id!=null); 
    system.assertEquals(ith.title,'abc');
    Di_Idea_Favorites__c obj = new Di_Idea_Favorites__c();
        obj.DI_Idea_Theme__c = ith.id;
        obj.User__c = userinfo.getUserid();
    insert obj;
	System.assert(obj.id!=null);    
    ith.Status = 'Closed';
    update ith;
    
    
    
   
    }

  }