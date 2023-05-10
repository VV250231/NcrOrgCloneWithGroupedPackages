@isTest(SeeAllData = false)
private class CreateSLSUserTest {

    static testMethod void myTest() {
        Test.startTest();

        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];

        List < User > u = new List < User > ();
        u.add(new User(alias = 'standt1', email = 'standarduser111@ncr.com',
            emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'testSOR1', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453678', Manager_Global_ID__c = '231453671', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));

        u.add(new User(alias = 'standt2', email = 'standarduser111@ncr.com',
            emailencodingkey = 'UTF-8', lastname = 'Test Record 222', Quicklook_Id__c = 'testSOR2', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = 'standarduser111@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453671', Manager_Global_ID__c = '121212121', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        insert u;

        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 1', Quicklook_ID__c = 'test1234', Global_ID__c = '123456789', Manager_Global_ID__c = '231453671', inActive__c = false, job_family__c = 'SLS - Pre Sales Engineer'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 2', Quicklook_ID__c = 'test4567', Global_ID__c = '231453671', Manager_Global_ID__c = '121212121', inActive__c = false, job_family__c = 'SLS - Inside Sales', Incentive_Plan__c = 'SCP'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 3', Quicklook_ID__c = 'test7890', Global_ID__c = '121212121', Manager_Global_ID__c = '222222222', inActive__c = false, job_family__c = 'SLS - Account Executive', Incentive_Plan__c = 'SCP'));

        insert ncrEmp;
        
        NSC_Support_Error_Notification__c obj = new NSC_Support_Error_Notification__c(Name = 'NSC Job Failure', ToEmailAddresses__c = 'test@test.com');
        insert obj;
        System.assert(obj.id!=null);

        CreateSLSUser c = new CreateSLSUser();
        Database.executeBatch(c);
		

    }
}