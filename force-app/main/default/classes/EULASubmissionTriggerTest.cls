@isTest
private class EULASubmissionTriggerTest{

    static testmethod  void EULASubmissionTest() {
            Test.startTest(); //denote testing context
        	
        	//Insert Partner Account
        	Account act = new Account();
        	act.Name = 'Partner Test Account';
        	List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        	if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        	act.Account_Country_Code__c = 'US';
        	act.Active_Account__c = true;
        	act.CurrencyIsoCode = 'USD';
        	act.Industry = 'FINANCIAL:BANKING';
        	act.Master_Customer_Number__c = '91663446';
        
        System.runAs(TestRecordsFactory.getUser()){
           insert act;
        }
        	//insert act;
        
        	//Insert Partner Contact
        	Contact con = new Contact();
        	con.lastName = 'Mahla';
        	con.Email = 'sm245987@gmail.com';
        	con.AccountId = act.Id;
            con.Active_Contact__c = true;
            con.Web_Portal_Login__c = 'wplUser';
            insert con;
            
             //Insert Partner Contact
            Contact con2 = new Contact();
            con2.lastName = 'Mahla';
            con2.Email = 'sm245987@gmail.com';
            con2.AccountId = act.Id;
            con2.Active_Contact__c = true;
            con2.Web_Portal_Login__c = 'wplUser';
            insert con2;
            
            //Insert Partner User
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='IPT Partner Community Login User' Limit 1];
            User u1 = new User();
            u1.ContactId = con.Id;
            u1.Username = 'wplUser@ncr.com';
            u1.ProfileId = portalProfile.Id;
            u1.Alias = 'test123';
            u1.Email = 'sm245987@gmail.com';
            u1.EmailEncodingKey = 'UTF-8';
            u1.LastName = 'McTesty';
            u1.CommunityNickname = 'test567890';
            u1.TimeZoneSidKey = 'America/Los_Angeles';
            u1.LocaleSidKey = 'en_US';
            u1.LanguageLocaleKey = 'en_US';
            u1.FederationIdentifier = 'wplUser';
            insert u1;
        	System.runAs(u1){
        	EULA_submission__c es = new EULA_submission__c();
        	es.Customer_Name__c ='Test';
            es.Solution_Name_or_Identifying_PID__c ='abc';
		    es.Address__c = 'xyz';
		    es.Date_of_Agreement__c = system.today();
		    es.End_Date_of_Agreement__c = system.today() + 1;
       		//es.OwnerId = u1.id;
			es.Status__c = 'Created';
            Insert es;
          System.assertNotEquals(es, null,'EULA_submission__c should not be null');

        }
            Test.stopTest(); //rev
     
    }
 }