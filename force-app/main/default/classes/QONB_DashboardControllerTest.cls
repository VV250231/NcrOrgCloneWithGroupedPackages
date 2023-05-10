@isTest
public class QONB_DashboardControllerTest {
    public static testMethod void testGetAccount(){
        Account acc = new Account(Name = 'Test Account');
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;
         }
        
        AccountTeamMember atm=new AccountTeamMember();
        atm.accountId=acc.id;
        atm.userId=UserInfo.getUserId();
        atm.TeamMemberRole='Account Manager';
        atm.AccountAccessLevel='Edit';
        insert atm;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.today();
        opp.StageName = 'prospecting';
        opp.AccountId = acc.Id;
        opp.Amount = 10000;
        insert opp;
         test.startTest();
        QuBy_Detail__c	quote = new QuBy_Detail__c(Quote_Number__c = '1234562',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250563',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'New',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'IMPORT ISSUE',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote;
        
         QuBy_Detail__c	quote1 = new QuBy_Detail__c(Quote_Number__c = '1234563',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250563',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'Config Error',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote1;
        
         QuBy_Detail__c	quote2 = new QuBy_Detail__c(Quote_Number__c = '1234564',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250564',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'In Progress',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'INCORRECT SUBMISSION',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote2;
        
              QuBy_Detail__c	quote3 = new QuBy_Detail__c(Quote_Number__c = '1234565',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250565',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Approval Required',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'DUPLICATE QUOTE',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote3;
        
        QuBy_Detail__c	quote4 = new QuBy_Detail__c(Quote_Number__c = '1234566',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250566',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'LACK OF INFORMATION',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote4;
        
         QuBy_Detail__c	quote5 = new QuBy_Detail__c(Quote_Number__c = '1234567',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250567',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Returned',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'PROCESSED',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote5;
       system.assertEquals(quote3.QuickLook_ID__c,'rm250565');
             QuBy_Detail__c	quote6 = new QuBy_Detail__c(Quote_Number__c = '1234569',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250569',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'CUSTOMER CREDIT HOLD',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote6;
        
         QuBy_Detail__c	quote7 = new QuBy_Detail__c(Quote_Number__c = '1234570',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250570',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'Incorrect Submission',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote7;
        
        QuBy_Detail__c	quote8 = new QuBy_Detail__c(Quote_Number__c = '1234571',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250571',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'DUPLICATE QUOTE',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote8;
         
         test.stopTest();
         
        
        
        QONB_DashboardController.getAccount();
        QONB_DashboardController.getstatusDashboardCount(acc.Id);
        system.assertEquals(quote1.QuickLook_ID__c,'rm250563');
        system.assertEquals(quote2.QuickLook_ID__c,'rm250564');
       
    } 
        
    public static testMethod void testGetAccount2(){
        Account acc = new Account(Name = 'Test Account');
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;
         }
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.today();
        opp.StageName = 'prospecting';
        opp.AccountId = acc.Id;
        opp.Amount = 10000;
        insert opp;
        
         QuBy_Detail__c	quote3 = new QuBy_Detail__c(Quote_Number__c = '1234565',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250565',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'DUPLICATE QUOTE',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote3;
        
        QuBy_Detail__c	quote4 = new QuBy_Detail__c(Quote_Number__c = '1234566',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250566',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'Config Error',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote4;
        
        QuBy_Detail__c	quote5 = new QuBy_Detail__c(Quote_Number__c = '1234567',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250567',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'INCORRECT SUBMISSION',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote5;
        system.assertEquals(quote4.Order_Not_Booked_Reason_Status__c,'Config Error');

       
        
        
        
        QONB_DashboardController.getAccount();
        QONB_DashboardController.getstatusDashboardCount(acc.Id);
        
       
    } 
    
    public static testMethod void testGetAccount3(){
        Account acc = new Account(Name = 'Test Account');
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;
         }
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.today();
        opp.StageName = 'prospecting';
        opp.AccountId = acc.Id;
        opp.Amount = 10000;
        insert opp;
        
         QuBy_Detail__c	quote3 = new QuBy_Detail__c(Quote_Number__c = '1234565',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250565',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'PROCESSED',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote3;
        
        QuBy_Detail__c	quote4 = new QuBy_Detail__c(Quote_Number__c = '1234566',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250566',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'REJECTED',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote4;
        
        QuBy_Detail__c	quote5 = new QuBy_Detail__c(Quote_Number__c = '1234567',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250567',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'ACKNOWLEDGED STILL SHOWING OPEN',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote5;
        
       
        
        
        
        QONB_DashboardController.getAccount();
        QONB_DashboardController.getstatusDashboardCount(acc.Id);
        system.assertNotEquals(acc.id,null,'Account ID is null');
       
    }
    
    public static testMethod void testGetAccount4(){
        Account acc = new Account(Name = 'Test Account');
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;
         }
        
        
         Account acc1 = new Account(Name = 'Test Account123');
        System.runAs(TestRecordsFactory.getUser()){
            insert acc1;
         }
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.today();
        opp.StageName = 'prospecting';
        opp.AccountId = acc.Id;
        opp.Amount = 10000;
        insert opp;
        test.startTest();
         QuBy_Detail__c	quote3 = new QuBy_Detail__c(Quote_Number__c = '1234565',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250565',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'CUSTOMER',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote3;
        
        QuBy_Detail__c	quote4 = new QuBy_Detail__c(Quote_Number__c = '1234566',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250566',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'OTHER',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote4;
        
        QuBy_Detail__c	quote5 = new QuBy_Detail__c(Quote_Number__c = '1234567',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250567',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'CUSTOMER CREDIT HOLD',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc.Id);
        insert quote5;
        
       QuBy_Detail__c	quoteAcc1 = new QuBy_Detail__c(Quote_Number__c = '1934565',Opportunity_No__c = '12345',Opportunity__c = opp.Id,Annuity_Quote_Status__c = 'Config Error',
                                    QuickLook_ID__c = 'rm250565',Solution_Modification_Date__c = System.now(),Solution_Quote_Status__c = 'Processing',Financial_Call_Off__c = 'off',
                                    Return_Reason__c = 'defect',Return_Comment__c = 'Not Working',Organization_Action_Owner__c = 'CUSTOMER',Order_Not_Booked_Reason_Status__c = 'CUSTOMER',
                                    Order_Not_Booked_Pending_Reason__c = 'DOCUMENT MISSING', Account__c = acc1.Id);
        insert quoteAcc1;
        
        
        
        QONB_DashboardController.getAccount();
        QONB_DashboardController.getstatusDashboardCount(acc.Id);
        system.assertNotEquals(acc.id,null,'Account ID is null');
        SortingUtils SU = new SortingUtils();
        
        //SortingUtils.SortingWrapper sortingwp = new SortingUtils.SortingWrapper(acc);
        List<SortingUtils.SortingWrapper> results = new List<SortingUtils.SortingWrapper>();
         //for(Account acc :  lstacc) {
            results.add(new SortingUtils.SortingWrapper(acc));
            results.add(new SortingUtils.SortingWrapper(acc1));
        //} 
        results.sort();
       test.stopTest();
 
       
    } 
}