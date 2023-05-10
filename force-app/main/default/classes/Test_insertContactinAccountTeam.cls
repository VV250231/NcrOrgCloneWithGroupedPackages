@isTest
Public  class Test_insertContactinAccountTeam {
    static testMethod void test_insertContactinAccountTeam_Method() {
        
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
            system.assertNotEquals(Usr.Id,null);
        Account ac =  TestRecordsFactory.createAccount('123432111','HOSPITALITY:TSR','NAMER SMB');
        ac.Partnership_Status__c = 'Active';
        Update ac;
        Account ac1 =  TestRecordsFactory.createAccount('1234321111','HOSPITALITY:TSR','NAMER SMB');
        ac1.Partnership_Status__c = 'Active';
        Update ac1;
        Account ra =  TestRecordsFactory.createAccount('1234321','HOSPITALITY:TSR','NAMER SMB');
        Account ra1 =  TestRecordsFactory.createAccount('1234321Ra','HOSPITALITY:TSR','NAMER SMB');
       ra1.CDM_Account_Type__c='End Customer';
        
        Contact cn =  TestRecordsFactory.createContact(ac);
        ra.CDM_Account_Type__c = 'End Customer';
        
        System.runAs(usr){
            update ra;
            update ra1;
        }    
        
        cdm_Account_Relationship__c c = new cdm_Account_Relationship__c(Account__c = ac.Id ,Name='End Customer',Relationship_Type__c ='End Customer - Partner',Related_Account__c=ra.Id);
        cdm_Account_Relationship__c c1 = new cdm_Account_Relationship__c(Account__c = ac1.Id ,Name='End Customer',Relationship_Type__c ='End Customer - Partner',Related_Account__c=ra1.Id);
        c1.Relationship_Code__c='End Customer';
        system.debug(c.Related_Account_AccountType__c);
        insert c;
        insert c1;
        Profile pf= [Select Id from profile where Name='Hospitality SMB Partner Manager'];
        List<User> uList = new List<user>();
        User userList = new User();
        
        userList.LastName = 'Test1';
        userList.IsActive = true;
        userList.Email = 'Test@test1.com';
        userList.Username = 'Test@test1.com' + System.currentTimeMillis();
        //  userList.CompanyName = 'TEST';
        userList.Title = 'title';
        userList.Quicklook_ID__c='tt250287';
        userList.FederationIdentifier ='tt250287';
        // userList.ContactId = '0037000000U47qkAAB';
        userList.Alias = 'alias';
        userList.TimeZoneSidKey = 'America/Los_Angeles';
        userList.EmailEncodingKey = 'UTF-8';
        userList.LanguageLocaleKey = 'en_US';
        userList.LocaleSidKey = 'en_US';
        userList.ProfileId = pf.id;
        //userList.Incentive_Plan__c='SCP';
        userList.IsActive = true;
        userList.Manager_Global_ID__c='1234';
        userList.Job_Code__c='test';
        userList.Global_ID__c='1234';
        userList.Sales_Org_Code__c='123Test';
        userList.ContactId = cn.id;
        userList.CPQ_Pilot__c =  true;
        uList.add(userList);
        insert uList;
        test.startTest();
        System.runAs(Usr) {
                  uList[0].CPQ_Pilot__c =  false;
            	update uList[0];
                AccountTeamMember atm=new AccountTeamMember(Accountid=ac.id, TeamMemberRole='Channel Partner', UserId=uList[0].id);
                Id siteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Site).getRecordTypeId();
                insert atm;
                Account s=new account(name='site');
                s.ParentId=ac.id;
                s.Active_Account__c=true;
                s.RecordTypeId=siteRecTypeId;
                insert s;
                uList[0].CPQ_Pilot__c =  true;
            	update uList[0];
                
             }
        
        cn.Partner_User__c	= userList.id;
       
        update cn;
        
        c.Name='End Customer1';
        c.Relationship_Type__c ='End Customer - Partner1';
        

		update c;
        
        Delete c1;
        
        test.stopTest();
        
        
        
        
    }}