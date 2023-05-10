@isTest
public class PRM_DashboardUserAccountProviderTest {
    static testmethod void unitTest1(){
        Account a = PRM_TestRecordsFactory.createPartnerAccount('suffix', new Map<String,String>());
        system.runAs([Select Id from User WHERE Name = 'Soup User' LIMIT 1][0]){
            insert a;
            PRM_DashboardUserAccountProvider.getAccountListforCams();
        }
        Contact c0 = PRM_TestRecordsFactory.createPartnerContact(a.Id, 'suffix', new Map<String,String>());
        insert c0;
        User u0 = PRM_TestRecordsFactory.createPartnerUser(c0.Id, 'test', new Map<String,String>());
        insert u0;
        Contact c = PRM_TestRecordsFactory.createPartnerContact(a.Id, 'suffix', new Map<String,String>());
        //c.Partner_User__c = [SELECT Id FROM USER WHERE Profile.Name = 'IPT Partner Community Login User' LIMIT 1].Id;
        c.Partner_User__c = u0.Id;
        insert c;
        String AccId1 = PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        PRM_DashboardUserAccountProvider.getAccountListforCams();
        c.Partner_User__c = UserInfo.getUserId();
        update c;
        User u = PRM_TestRecordsFactory.createPartnerUser(c.Id, 'sx', new Map<String,String>());
        u.ManagerId = UserInfo.getUserId();
        insert u;
        System.assertNotEquals(u.id, null,'User Should not be null');
        PRM_DashboardUserAccountProvider.getOwnedUsers();
        PRM_DashboardUserAccountProvider.getOwnedAccounts(a.Id);
        PRM_DashboardUserAccountProvider.dashboardVisibility();
        PRM_DashboardUserAccountProvider.getDashboardVisibility();
        //Testing prmGenericDataHelper method
        prmGenericDataHelper.getCurrentUserAccountData();
        PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        prmGenericDataHelper.setNPSScore(a.Id);
    }
    @isTest
    public static void Test2(){        
        //Creating an account.
        
        Account a = PRM_TestRecordsFactory.createPartnerAccount('suffix', new Map<String,String>());
        system.runAs([Select Id,Name, ContactId, Contact.AccountId FROM User WHERE Name = 'Soup User' LIMIT 1][0]){
            System.assertEquals(a.Account_Region__c, 'CLA','Account Region should be EMEA');
            insert a; 
        }
        
        Contact c = PRM_TestRecordsFactory.createPartnerContact(a.Id, 'suffix', new Map<String,String>());
        insert c;
        User u = PRM_TestRecordsFactory.createPartnerUser(c.Id, 'sx', new Map<String,String>());
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Hospitality SMB Partner Manager' Limit 1];
        u.ProfileId = portalProfile.Id;
        u.Quicklook_ID__c = 'sg174216';
        Test.startTest();
        insert u;
        System.assertNotEquals(portalProfile, null,'Portal Profile Should not be null');
        
        List<Partner_Revenue__c> prmrevrecord = new List<Partner_Revenue__c>();
        prmrevrecord = PRM_TestRecordsFactory.partnerRevenueList(a.Id);
        Insert prmrevrecord;
        system.runAs(u){
            PRM_DashboardUserAccountProvider.getDashboardVisibility();
            
        } 
        Test.stopTest();
    } 
    @isTest
    public static void Test3(){
        Account a = PRM_TestRecordsFactory.createPartnerAccount('suffix', new Map<String,String>());
        system.runAs([Select Id from User WHERE Name = 'Soup User' LIMIT 1][0]){
            insert a;
            System.assertEquals(a.LOB__c, 'FINANCIAL','LOB Should be FINANCIAL');
            PRM_DashboardUserAccountProvider.getAccountListforCams();
        }
        
        Contact c0 = PRM_TestRecordsFactory.createPartnerContact(a.Id, 'suffix', new Map<String,String>());
        insert c0;
        User u0 = PRM_TestRecordsFactory.createPartnerUser(c0.Id, 'test', new Map<String,String>());
        insert u0;
        Contact c = PRM_TestRecordsFactory.createPartnerContact(a.Id, 'suffix', new Map<String,String>());
        // c.Partner_User__c = [SELECT Id FROM USER WHERE Profile.Name = 'IPT Partner Community Login User' LIMIT 1].Id;
        c.Partner_User__c = u0.Id;
        insert c;
        String AccId1 = PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        PRM_DashboardUserAccountProvider.getAccountListforCams();
        // c.Partner_User__c = '0050g0000063uQZAAY';  
        c.Partner_User__c =  UserInfo.getUserId();
        update c;
        User u = PRM_TestRecordsFactory.createPartnerUser(c.Id, 'sx', new Map<String,String>());
        //u.ManagerId = UserInfo.getUserId();
        insert u;
        System.assertNotEquals(u.id, null,'User Should not be null');
        PRM_DashboardUserAccountProvider.getOwnedUsers();
        PRM_DashboardUserAccountProvider.getOwnedAccounts(a.Id);
        PRM_DashboardUserAccountProvider.dashboardVisibility();
        PRM_DashboardUserAccountProvider.getDashboardVisibility();
        //Testing prmGenericDataHelper method
        prmGenericDataHelper.getCurrentUserAccountData();
        PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        prmGenericDataHelper.setNPSScore(a.Id);
    }
}