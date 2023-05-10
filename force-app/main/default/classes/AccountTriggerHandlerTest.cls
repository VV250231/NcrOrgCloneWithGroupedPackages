@isTest
private Class AccountTriggerHandlerTest {
  
    static testMethod void runPopulatingIpsfieldsonaccount() {
          User Usr = [Select Id from User Where Name = 'Soup User'];
         List<RecordType> recordTypelst=[Select Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Account' AND Name in('customer','Partner')];  
         list<Account> acclist=new list<Account>();
        System.runAs(Usr){
        List<Theater_Area_Mapping__c> tamLst = new List<Theater_Area_Mapping__c> {new Theater_Area_Mapping__c(Account_Country_Code__c ='US', Theater__c='EMEA', Region__c='EUROPE', Area__c='EUROPE',LOB__c='HOSPITALITY', CDM_SMB_Flag__c=true),
                                                new Theater_Area_Mapping__c(Account_Country_Code__c ='A2', Theater__c='EMEA', Region__c='EUROPE', Area__c='EUROPE',LOB__c='HOSPITALITY', CDM_SMB_Flag__c=false)}; 
      
        insert tamLst;
        IPS_Field_Country_Code__c ipsdata=new IPS_Field_Country_Code__c(Account_Country_Code__c='A2',Corp_Area__c='SOUTH EASTERN EUROPE', Corp_Region__c='EUROPE',Corp_Theater__c='EMEA', IPS_Area__c='EMERGING',IPS_Region__c='EUROPE');
        insert ipsdata;
        List<Account> accLst = new List<Account>();
        Account ac=new Account();
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();//0127000000014kqAAA = r
        ac.Name='Test IPS Fields';
        ac.Account_Country_Code__c='A2';
        ac.MDM_Billing_Location_Country_Code__c = 'A2';
        ac.MDM_Industry_Name__c='HOSPITALITY:TSR';
        ac.Industry = 'HOSPITALITY:TSR';
        ac.RecordTypeId = r;
        ac.Corp_Area__c='';
        accLst.add(ac);    
        Account ac1=new Account();
        ac1.Name='Test IPS Fields';
        ac1.BillingCountry ='US';
        //ac1.Account_Country_Code__c='US'; 
        ac1.MDM_Industry_Name__c='HOSPITALITY:TSR';
        ac1.Industry = 'HOSPITALITY:TSR';
        ac1.CDM_SMB_Flag__c = true;
        ac1.RecordTypeId = r;
        accLst.add(ac1);
        insert accLst;
        Account accObj = [select Corp_Area__c from account where id =: ac.Id];
        System.assert(accObj.Corp_Area__c=='SOUTH EASTERN EUROPE');
        Test.startTest();
            for(integer i=1;i<=100;i++)
          {
               Account a=new account(name='testacc',RecordTypeId=recordTypelst[0].id,Account_Country_Code__c='GR',
                                       Industry = 'HOSPITALITY:TSR',  Master_Customer_Number__c = 'TEST0001' + i, 
                                       Active_Account__c = true);
               acclist.add(a);
          } 
           insert acclist;
        Test.stopTest();
        }
    }
    
   
    static testMethod void testPartnerNonROR() {
          User Usr = [Select Id from User Where Name = 'Soup User'];
        
        System.runAs(Usr){
        Partner_NonROR__c ob=new Partner_NonROR__c();
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();//0127000000014kqAAA
        ob.Master_Customer_Number__c ='222222';
        ob.Country_Code__c = 'AF'; 
        ob.Address1__c = 'permanent address 1';
        ob.Address2__c = 'permanent address 2';
        ob.City__c = 'new test city';
        ob.State__c = 'new test state';
        ob.Zip_Code__c = '12345';
        ob.Website_Address__c = 'www.newtestwebsite.com';
        ob.Telephone__c = '111111112';
        ob.ERP_Country_Code__c = 'AF';
        ob.Application_Referral__c = 'TEST';
        insert ob;
        Account ac=new Account();
        ac.recordtypeid = r;
        ac.Name = 'triggered account';
        ac.CurrencyIsoCode = 'USD';
        ac.Master_Customer_Number__c = '222222';
        ac.Account_Country_Code__c = 'AF'; 
        insert ac;
        Account accObj = [select BillingCity from account where id =:ac.id];
        System.assert(accObj.BillingCity=='new test city');
        ac.BillingCity = null;
        ac.BillingStreet = null;
        ac.BillingState = null;
        ac.BillingCountry = null;
        ac.BillingPostalCode = null;
        ac.Website = null;
        ac.Phone = null;
        ac.Comments__c = null;
        ac.ISO_Country_Code__c = null;
        update ac;
        
        ob.Address1__c = 'new address 1';
        update ob;
    }
    }
    static testMethod void testBlockAccountCreate() {
        /*
        Profile p = [SELECT Id FROM Profile WHERE Id='00e700000013gAKAAY' limit 1];
    
        User u = new User(Alias = 'standt', Email='standarduser@ncr.com',EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,Quicklook_ID__c='ma000000',
        TimeZoneSidKey='America/Los_Angeles', UserName='ma185241@ncr.com.test');
        insert u;
        */
        Id usr = NSCCommonInfoUtil.getIdOf('User_Id'); //Change By Saurav
        user u = [ SELECT id FROM user WHERE id =: usr ];
        
        System.runAs(u){        
            Lead l = new Lead(Company = 'NCR Corporation', FirstName = 'Test', LastName = 'Lead', Status = 'Submitted' );
            insert l;
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.id);
            lc.setConvertedStatus('Qualified');   
            lc.setDoNotCreateOpportunity(true); 
            try{
             Database.LeadConvertResult lcr = Database.convertLead(lc);  
            }
            catch(Exception e){
               System.assert(e.getMessage()!=null) ;
            }
            
            //system.debug( ':::::::::' + lcr.getAccountId() );
           }    
    
    }
    
   @isTest(SeeAllData=true)
   static void testupdateContactForPartnerAccount() {
         User Usr = [Select Id from User Where Name = 'Soup User'];
        
         System.runAs(Usr){
            Account acc;
            //acc = [select Id, RecordTypeID, ispartner, partnership_status__c from Account where RecordTypeId not in ('0127000000014kqAAA','012700000001UVtAAM') and RecordType.Name NOT IN ('Enterprise', 'Site') and isPartner = false and partnership_status__c != 'active' limit 1];
            acc = [select Id, RecordTypeID, ispartner, partnership_status__c from Account where  RecordType.Name NOT IN ('Enterprise', 'Site','Parnter') and isPartner = false and partnership_status__c != 'active' limit 1]; //Change By Saurav
             test.startTest();
            Contact con = new contact();
            Id rtid = NSCCommonInfoUtil.getIdOf('Contact_RecordType_Id');//Change By Saurav
            con.AccountId = acc.Id;
            con.LastName = 'Test';
            con.Level__c = 'Unknown';
            con.Decision_Maker__c = 'Approver';
            con.Portal_user__c = true;
            con.web_portal_login__c = 'Test Login';
            // Adding Record Type Id - changes 9/9/2015
            con.RecordTypeId = rtid;
            //insert con;
            con.AccountId = acc.Id;
            System.debug('ContactID after - '+ con.AccountId);
            //acc.RecordTypeID = '0127000000014kqAAA';
            acc.ispartner = true;
            acc.partnership_status__c = 'active';
            update acc;
            acc.partnership_status__c = 'Pending';
            update acc;
            acc.partnership_status__c = 'Active';
            update acc;
            System.assert(acc.partnership_status__c == 'Active');
            test.stopTest();
        }
   }
    
  /* @isTest(SeeAllData=true)
    static  void blockOwnerShipChangeTest () {
        Id pr = NSCCommonInfoUtil.getIdOf('NSC_Admin_04_UI_Profile');
        Profile p = [SELECT Id FROM Profile WHERE Id =: pr
            limit 1
        ];
        User u = new User(Alias = 'test', Email = 'standarduser@ncr.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing121',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, Quicklook_ID__c = 'ma000000',
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ma185241@ncr.com.test');
        insert u;
        Account acc = TestRecordsFactory.createAccount();
        acc.OwnerId = u.Id;
        try { 
            update acc;
        }
        catch(System.DmlException e)
        {
          System.debug('Error: '+e.getMessage());        }
   } */
    
    /*static testMethod void testUpdateMCN() {
        User Usr = [Select Id from User Where Name = 'Soup User'];
        
        System.runAs(Usr) {  
            list<Account> acclist=new list<Account>();
            Account a;
            List<RecordType> recordTypelst=[Select Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Account' AND Name in('customer','Partner')];       
            Account a1 = new Account(name='TestAccount1',RecordTypeId=recordTypelst[0].Id,Account_Country_Code__c='GR');
            insert a1;
            
            Account a2 = new Account(name='TestAccount2',RecordTypeId=recordTypelst[0].Id,Account_Country_Code__c='GR',AccountRequestRecordType__c = 'Digital Insight Customer Account');
            acclist.add(a2);
            
            for(integer i=1;i<=150;i++)
            {
                a=new account(name='testacc',RecordTypeId=recordTypelst[0].id,Account_Country_Code__c='GR');
                acclist.add(a);
            }        
            insert acclist;
        }     
    }*/
    
    
     static testMethod void testpopulateTheaterArea() {
         
           User Usr = [Select Id from User Where Name = 'Soup User'];
        
         System.runAs(Usr){
            List<User> user = new List<User>();
            Id us = NSCCommonInfoUtil.getIdOf('user_profile_id');
            user = [select u.id from user u where u.Profile.Id =: us];
            User u = user[0];
            System.runAs(Usr){
                Account a = new Account();
                a.name = 'Test';
                insert a;
                a.Account_Country_Code__c = 'US';
                a.MDM_Billing_Location_Country_Code__c = 'US';
                a.Industry = 'RETAILS:GENERAL MERCHANDISE';
                update a;
                a.Industry = 'RETAIL:GENERAL MERCHANDISE';
                update a;
                a.Account_Country_Code__c = 'A3';
                update a;
                System.assert(a.Billing_Theatre__c==null);
            }
     }
     
     }
     /*static testMethod void testUpdateContactRecordType() {
           User Usr = [Select Id from User Where Name = 'Soup User'];
         List<Account> actList = new List<Account>();
         System.runAs(Usr){
         // Get all Active Account RecordTypes that are available to the running user
        Map<String,Id> accountTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
      
        // Get all Active contact RecordTypes that are available to the running user
        Map<String,Id> contactTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Contact.SObjectType);
        
        // Inser Customer Accounts
       
        
        if (accountTypesMap.get('Customer') != null) {
          Account act ;
          for (Integer i = 000 ; i < 100 ; i++) {
            act = new Account();
            act.Name = 'Test Acc' + String.valueOf(i);
            act.RecordTypeId = accountTypesMap.get('Customer');
            act.LOB__c = 'FINANCIAL';
            act.Master_Customer_Number__c = 'TEST000' + String.valueOf(i);
            act.Account_Country_Code__c = 'US';
            act.MDM_Billing_Location_Country_Code__c ='01';
            act.CurrencyIsoCode = 'USD';
            act.Active_Account__c = true;
            actList.add(act);
          } 
        }
         
        if (actList.size() > 0) {
          insert actList;
          
          // Insert #100 contacts with first account
          List<Contact> conList = new List<Contact>();
          Contact con ;
          for (Integer i = 0; i < 20 ; i++) {
            con = new Contact();
            con.LastName = 'LastName'+String.valueOf(i);
            con.AccountId = actList[0].Id;
            con.Email = 'test.email'+String.valueOf(i)+'@domain.com';
            con.Decision_Maker__c = 'Decision Maker';
            con.Level__c = 'Entry-Level Manager';
            con.Business_Function__c = 'Customer Support/Service';
            con.Primary_Language__c  = 'English US';
            con.Survey_Flag__c = 'Yes'; // Relationship Survey
            conList.add(con);
          }
          
          // Insert #1 contact with each other accounts
          integer j = 100;
          for (Integer i = 1; i < 20 ; i++) {
            
            con = new Contact();
            con.LastName = 'LastName'+String.valueOf(j);
            con.AccountId = actList[i].Id;
            con.Email = 'test.email'+String.valueOf(j)+'@domain.com';
            con.Decision_Maker__c = 'Decision Maker';
            con.Level__c = 'Entry-Level Manager';
            con.Business_Function__c = 'Customer Support/Service';
            con.Primary_Language__c  = 'English US';
            con.Survey_Flag__c = 'Yes'; // Relationship Survey
            conList.add(con);
            j++;
          }
          
          if (conList.size() > 0) {
            insert conList;
          }
          
          // Update Account Record type from customer to partner
          Set<Id> actIdSet = new Set<Id>();
          for (Account act : actList) {
            actIdSet.add(act.Id);
          }
          
          actList.clear();
          actList = [SELECT Id, RecordTypeId,Industry FROM Account WHERE Id IN : actIdSet ];
          for (Account act : actList) {
            act.RecordTypeId = accountTypesMap.get('Partner');
            act.Industry = 'FINANCIAL:BANKING';
          }
          
          if (actList.size() > 0) {
            update actList;
          }
        }
         }
     }*/
     
      static testMethod void testUpdatePrimaryContact() {
          
  User Usr = [Select Id from User Where Name = 'Soup User'];
        system.assertNotEquals(Usr.Id,null);
          System.runAs(Usr){
          
            Account a = new Account(name='Account-1', CDM_Account_Status__c = 'Active');
            insert a;
            Contact c = new Contact(Lastname = 'Smith', Firstname = 'Joe', AccountId = a.Id);
            insert c;
            
            a.Primary_Contact__c = c.Id;
            a.Primary_Contact_is_Partner_Signatory__c = TRUE;
            update a;
            
            //checkbox on contact should get set
            System.assert([Select Partner_Primary_Contact__c from Contact where Id = :c.Id].Partner_Primary_Contact__c);
        
            Contact c1 = new Contact(Lastname = 'Jones', Firstname = 'Johnny', AccountId = a.Id);
            insert c1;
            insert new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=c1.id);
             Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
             Opportunity opp = TestRecordsFactory.createSimpleOpportunity(a);
              
            a.Credit_Application_Status__c ='In Process';  
            a.Primary_Contact__c = c1.Id;
            a.Primary_Contact_is_Partner_Signatory__c = FALSE;
            update a;
        
            //checkbox on contact c should get unchecked
            System.assertEquals(false, [Select Partner_Primary_Contact__c from Contact where Id = :c.Id].Partner_Primary_Contact__c);
        
            //checkbox on contact c1 should get set
            System.assert([Select Partner_Primary_Contact__c from Contact where Id = :c1.Id].Partner_Primary_Contact__c);
      }
}



    static testMethod void tesOwnerUpdate() {
          AccountTriggerHandler accHandler = new AccountTriggerHandler();
          User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
            system.assertNotEquals(Usr.Id,null);
            Account a;
            
              System.runAs(Usr) {
                a = new Account(name='Account-1');
                a.Master_Customer_Number__c = 'Test1234';
                a.Subscription_Group__c ='Digital Insight';
                a.DI_Customer__c = 'DI123';
                a.CDM_Account_Status__c = 'Active';
                  
                a.BillingStreet = 'test';
                a.BillingCity = 'test';
                a.BillingState = 'test';
                a.BillingPostalCode =  '1234';
               
                insert a;
                
                Contact c1 = new Contact(Lastname = 'Jones', Firstname = 'Johnny', AccountId = a.Id, Portal_user__c=  true, web_portal_login__c ='Jones' );
                insert c1;
                  
                AccountTeamMember atm=new AccountTeamMember(AccountId = a.Id,TeamMemberRole='Digital Strategy Manager',UserId=Usr.Id);
                insert atm;
                
              }
              
              
             
              accHandler.updateContactsForPartnerAccts(new Set<Id>{a.Id});
              accHandler.UpdateContactRecordTypeFromAcct(new Set<Id>{a.Id});
             
             String newOwnerId = UserInfo.getUserId();
            Sales_Org__c so = TestRecordsFactory.createSalesOrg();
        
              System.runAs(Usr) {
                a.CDM_Source_SOC__c = so.Sales_Org_Code__c;
                a.Industry = 'FINANACIAL:BANKING';
                a.Account_Country_Code__c = 'US';  
                a.Account_CDM_ID__c = 'test';
                a.MDM_Data_Source_Code__c = 'CDM';
                a.Use_Default_Sales_Org_Code__c = true;
                update a;
             }
        
           Test.startTest(); 
             a.ownerId = newOwnerId;
             a.UpdateByLeadConversion__c = 'Y';
             update a;
             delete a;
             Test.stopTest();
          
             accHandler.syncToServiceNow(new List<Account> {a});
       }
       
       
        public static testMethod void testUpdateSalesOrgCode() {
            User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
            system.assertNotEquals(Usr.Id,null);
            
            NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
            insert nscNotification; 
            Id s =NSCCommonInfoUtil.getIdOf('Sales_ownerId');
            Sales_Org__c org1 = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='12345', ownerId= s , isPrimary__c =true);
            insert org1;
            
            cdm_Default_Sales_Org__c dfltSlsOrg = new cdm_Default_Sales_Org__c(Industry__c = 'RET',Operating_Unit__c = 'US', Default_Global_Sales_Org_Code__c='123456');
            insert dfltSlsOrg;
            
            Account a;
             
            System.runAs(Usr) {
                 a = new Account(name='Account-1');
                 a.MDM_Data_Source_Code__c = 'CDM';
                 a.Use_Default_Sales_Org_Code__c = true;
                 a.Account_Country_Code__c = 'US';
                 a.Industry = 'RETAIL:GENERAL MERCHANDISE';
                 insert a;
                
                 Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
                 Opportunity opp = TestRecordsFactory.createSimpleOpportunity(a);
              
                 a.Global_Sales_Org_Code__c = '12345';
                 update a;     
             }
        }
     public static testMethod void testSiteShare() {
            User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
            system.assertNotEquals(Usr.Id,null);
            Account a;             
            System.runAs(Usr) {
                 a = new Account(name='Account-1');
                 a.MDM_Data_Source_Code__c = 'CDM';
                 a.Use_Default_Sales_Org_Code__c = true;
                 a.Account_Country_Code__c = 'US';
                 a.Industry = 'RETAIL:GENERAL MERCHANDISE';
                 insert a;
                List <User> u=TestRecordsFactory.createUsers(TestRecordsFactory.getProfile('System Administrator').id, 'test', 1) ;
                AccountTeamMember atm=new AccountTeamMember(Accountid=a.id, TeamMemberRole='Channel Partner', UserId=u[0].id);
                Id siteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Site).getRecordTypeId();
                insert atm;
                Account s=new account(name='site');
                s.ParentId=a.id;
                s.Active_Account__c=true;
                s.RecordTypeId=siteRecTypeId;
                insert s;
                
                s.name='site2';
                s.AutoPay_Setup__c='True';
                s.Bill_To__c=true;
                update s;
                
                
             }
        }
    
    
}