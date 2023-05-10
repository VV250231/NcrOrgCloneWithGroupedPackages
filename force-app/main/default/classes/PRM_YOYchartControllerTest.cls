@isTest
public class PRM_YOYchartControllerTest {
    @isTest
    public static void getYoyDetailsTest(){
        
        //Creating an account.
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);  
        
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];
      System.assertEquals(accountUsere.id!=null, true);        
        System.runAS(accountUsere){
            Insert accountRecord;
        } 
        // Creating a Contact
        List<Partner_Revenue__c> partnerRevenueList = new List<Partner_Revenue__c>();
        
        partnerRevenueList = PRM_TestRecordsFactory.partnerRevenueList(accountRecord.Id);
        Insert partnerRevenueList;
        
        Partner_Dashboard_Configuration__c partnerDashboardConfiguration = new Partner_Dashboard_Configuration__c(Name ='2020');
        partnerDashboardConfiguration.X1st_Half__c = true;
        partnerDashboardConfiguration.X2nd_Half__c = false;
        Insert partnerDashboardConfiguration;
        
        Test.startTest();
        PRM_YOYchartController.getYoyDetails2(accountRecord.Id);        
        Test.stopTest(); 
        
    }
    
    @isTest
    public static void getYoyDetailsTest1(){        
        //Creating an account.
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('TestA',null);  
        
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];
          System.assertEquals(accountUsere.id!=null, true);        
        System.runAS(accountUsere){
            Insert accountRecord;
        } 
        // Creating a Contact 
        Partner_Dashboard_Configuration__c partnerDashboardConfiguration = new Partner_Dashboard_Configuration__c(Name ='2020');
        partnerDashboardConfiguration.X1st_Half__c = true;
        partnerDashboardConfiguration.X2nd_Half__c = false;
        Insert partnerDashboardConfiguration;
        
        Test.startTest();
        PRM_YOYchartController.getYoyDetails2(accountRecord.Id);        
        Test.stopTest(); 
        
    }
     
    @isTest
    public static void getYoyDetailsTest2(){        
        //Creating an account.
        
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('TestAB',null);  
        
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];
        System.assertEquals(accountUsere.id!=null, true);        
        System.runAS(accountUsere){
            Insert accountRecord;
        } 
        // Creating a Contact 
        Partner_Dashboard_Configuration__c partnerDashboardConfiguration = new Partner_Dashboard_Configuration__c(Name ='2020');
        partnerDashboardConfiguration.X1st_Half__c = false;
        partnerDashboardConfiguration.X2nd_Half__c = true;
        Insert partnerDashboardConfiguration;
        
        
        List <Partner_Revenue__c> partnerRevenueList = new List <Partner_Revenue__c>();
        partnerRevenueList.add( new Partner_Revenue__c(
            Direct_Revenue__c=1000, Indirect_Revenue__c=1000, Hardware__c=1000, Software__c=1000, Professional_Services__c=1000,  
            TS__c=1000, Hosted__c=1000, SaaS__c=1000,POSaaS__c=1000,Total_Services_Revenue__c=1000,Solution_from_Net_New_Customers__c=1000,
            Subscription_from_Net_New_Customers__c=1000,First_Half__c=4000,Second_Half__c=4000,Subscription_Sites__c= 100, Traditional_Sites__c= 100,Partner_Account__c=accountRecord.Id, Year__c = '2021'));
        
        Insert partnerRevenueList;  
        
        Test.startTest();
        PRM_YOYchartController.getYoyDetails2(accountRecord.Id);        
        Test.stopTest(); 
        
    }
    @isTest
    public static void SubsSites(){
         //Creating an account.
        
       Account a = PRM_TestRecordsFactory.createPartnerAccount('suffix', new Map<String,String>());
        system.runAs([Select Id from User WHERE Name = 'Soup User' LIMIT 1][0]){
            System.assertEquals(a.id!=null, false);   
        insert a; 
        }
        Contact c = PRM_TestRecordsFactory.createPartnerContact(a.Id, 'suffix', new Map<String,String>());
       c.Partner_User__c = [SELECT Id FROM USER WHERE Profile.Name = 'Hospitality SMB Partner Manager' LIMIT 1].Id;

        insert c;
        String AccId1 = PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        
        PRM_DashboardUserAccountProvider.getAccountListforCams();
        c.Partner_User__c = UserInfo.getUserId();
        update c;
      
        List<Partner_Revenue__c> prmrevrecord = new List<Partner_Revenue__c>();
        
        prmrevrecord = PRM_TestRecordsFactory.partnerRevenueList(a.Id);
        
        Insert prmrevrecord;
        
 
       /* List <Partner_Revenue__c> prmrevrecord = new List <Partner_Revenue__c>();
        prmrevrecord.add( new Partner_Revenue__c(
 Direct_Revenue__c=1000, Indirect_Revenue__c=1000, Hardware__c=1000, Software__c=1000, Professional_Services__c=1000,  
            TS__c=1000, Hosted__c=1000, SaaS__c=1000,POSaaS__c=1000,Total_Services_Revenue__c=1000,Solution_from_Net_New_Customers__c=1000,
            Subscription_from_Net_New_Customers__c=1000,First_Half__c=4000,Second_Half__c=4000,Subscription_Sites__c= 100, Traditional_Sites__c= 100,Partner_Account__c=a.Id, Year__c = String.valueOf(System.today().year())));
        
        Insert prmrevrecord;  */
        
        Test.startTest();
       PRM_DashboardUserAccountProvider.getOwnedUsers();
       PRM_DashboardUserAccountProvider.getOwnedAccounts(a.Id);
        PRM_DashboardUserAccountProvider.dashboardVisibility();
        PRM_DashboardUserAccountProvider.getDashboardVisibility();
        //Testing prmGenericDataHelper method
        prmGenericDataHelper.getCurrentUserAccountData();
        PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        PRM_YOYchartController.SubsSites(a.Id);  
        PRM_YOYchartController.GetRevenueDetailsbyTypeData(a.Id);
       
        Test.stopTest(); 
    }
    }