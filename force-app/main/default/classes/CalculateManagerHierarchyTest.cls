@isTest(SeeAllData = false)
private class CalculateManagerHierarchyTest {
    
    static testMethod void myTest() {
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 1', Quicklook_ID__c = 'test1234', Global_ID__c = '123456789', Manager_Global_ID__c = '231453671', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 2', Quicklook_ID__c = 'test4567', Global_ID__c = '231453671', Manager_Global_ID__c = '121212121', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 3', Quicklook_ID__c = 'test7890', Global_ID__c = '121212121', Manager_Global_ID__c = '222222222', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 4', Quicklook_ID__c = 'test0123', Global_ID__c = '222222222', Manager_Global_ID__c = '231453674', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 5', Quicklook_ID__c = 'test0012', Global_ID__c = '231453674', Manager_Global_ID__c = '231453677', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 6', Quicklook_ID__c = 'test1212', Global_ID__c = '231453677', Manager_Global_ID__c = '231453678', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 7', Quicklook_ID__c = 'test1312', Global_ID__c = '231453678', Manager_Global_ID__c = '231453679', inActive__c = false));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 8', Quicklook_ID__c = 'test1313', Global_ID__c = '231453679', Manager_Global_ID__c = '231453670', inActive__c = false));
        insert ncrEmp;
        
        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];
        
        List < User > u = new List < User > ();
        u.add(new User(alias = 'standt1', email = 'standarduser111@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test1234', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453678', Manager_Global_ID__c = '231453671', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        
        u.add(new User(alias = 'standt2', email = 'standarduser111@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 222', Quicklook_Id__c = 'test4567', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser111@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453671', Manager_Global_ID__c = '121212121', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        insert u;
        
        Test.startTest();
        CalculateManagerHierarchy c = new CalculateManagerHierarchy();
        Database.executeBatch(c);
        Test.stopTest();
        user userObj = [select id,Area_VP__c from user where Quicklook_Id__c='test4567'];
        System.assert(userObj.Area_VP__c=='Test Record 4');
    }
    
    static testMethod void myTestSecond() {
        
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 1', Quicklook_ID__c = 'test1234', Global_ID__c = '123456789', Manager_Global_ID__c = '231453671'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 2', Quicklook_ID__c = 'test4567', Global_ID__c = '231453671', Manager_Global_ID__c = '121212121'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 3', Quicklook_ID__c = 'test7890', Global_ID__c = '121212121', Manager_Global_ID__c = '222222222'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 4', Quicklook_ID__c = 'test0123', Global_ID__c = '222222222', Manager_Global_ID__c = '231453674'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 5', Quicklook_ID__c = 'test0012', Global_ID__c = '231453674', Manager_Global_ID__c = '231453677'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 6', Quicklook_ID__c = 'test1212', Global_ID__c = '231453677', Manager_Global_ID__c = '231453678'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 7', Quicklook_ID__c = 'test1312', Global_ID__c = '231453678', Manager_Global_ID__c = '231453679'));
        ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record 8', Quicklook_ID__c = 'test1313', Global_ID__c = '231453679', Manager_Global_ID__c = '231453670'));
        insert ncrEmp;
        
        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];
        
        List < User > u = new List < User > ();
        u.add(new User(alias = 'standt10', email = 'standarduser123@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test1234', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453678', Manager_Global_ID__c = '231453671', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test121', Region_VP_QuickLook__c = 'Test121', Division_VP_QuickLook__c = 'Test121', isActive = True));
        
        u.add(new User(alias = 'standt11', email = 'standarduser124@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 222', Quicklook_Id__c = 'test4567', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser111@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453671', Manager_Global_ID__c = '121212121', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test121', Region_VP_QuickLook__c = 'Test121', Division_VP_QuickLook__c = 'Test121', isActive = True));
        
        u.add(new User(alias = 'standt12', email = 'standarduser125@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 333', Quicklook_Id__c = 'test7890', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser123@.ncr.com' + System.now().getTime() + '.com', global_id__c = '121212121', Manager_Global_ID__c = '222222222', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test121', Region_VP_QuickLook__c = 'Test121', Division_VP_QuickLook__c = 'Test121', isActive = True));
        
        u.add(new User(alias = 'standt13', email = 'standarduser126@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 444', Quicklook_Id__c = 'test0123', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser124@.ncr.com' + System.now().getTime() + '.com', global_id__c = '222222222', Manager_Global_ID__c = '231453674', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test121', Region_VP_QuickLook__c = 'Test121', Division_VP_QuickLook__c = 'Test121', isActive = True));
        
        u.add(new User(alias = 'standt14', email = 'standarduser127@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 555', Quicklook_Id__c = 'test0124', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser125@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453674', Manager_Global_ID__c = '231453677', Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test121', Region_VP_QuickLook__c = 'Test121', Division_VP_QuickLook__c = 'Test121', isActive = True));
        
        insert u;
        
        Test.startTest();
        CalculateManagerHierarchy c1 = new CalculateManagerHierarchy();
        Database.executeBatch(c1);
        Test.stopTest();
        user userObj = [select id,Area_VP__c from user where Quicklook_Id__c='test4567'];
        System.assert(userObj.Area_VP__c=='Test Record 4');
    }
    
    static testMethod void myTest1() {
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        Integer globalId = 123456;
        Integer managerId = 234567;
        for(Integer i=1 ; i<10; i++){
            ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record' + i, Quicklook_ID__c = 'test123'+i, Global_ID__c = String.ValueOF(globalId), Manager_Global_ID__c = String.valueOf(managerId), inActive__c = false));            
            globalId = managerId;
            managerId++;
        }
        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];
        
        List < User > u = new List < User > ();
        
        u.add(new User(alias = 'standt', email = 'standarduser111@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test12', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '123456', Manager_Global_ID__c = '1234567', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        
        insert ncrEmp;
        insert u;
        Test.startTest();
        CalculateManagerHierarchy c1 = new CalculateManagerHierarchy();
        Database.executeBatch(c1);
        Test.stopTest();
        user userObj = [select id,Area_VP__c from user where Quicklook_Id__c='test12'];
        System.assert(userObj.Area_VP__c=='Test Record5');
    }
    
    static testMethod void myTes2() {
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        Integer globalId = 123456;
        Integer managerId = 234567;
        for(Integer i=1 ; i<9; i++){
            ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record' + i, Quicklook_ID__c = 'test123'+i, Global_ID__c = String.ValueOF(globalId), Manager_Global_ID__c = String.valueOf(managerId), inActive__c = false));            
            globalId = managerId;
            managerId++;
        }
        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];
        
        List < User > u = new List < User > ();
        
        u.add(new User(alias = 'standt', email = 'standarduser111@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test12', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '123456', Manager_Global_ID__c = '1234567', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        
        insert ncrEmp;
        insert u;
        Test.startTest();
        CalculateManagerHierarchy c1 = new CalculateManagerHierarchy();
        Database.executeBatch(c1);
        Test.stopTest();
        user userObj = [select id,Area_VP__c from user where Quicklook_Id__c='test12'];
        System.assert(userObj.Area_VP__c=='Test Record4');
    }
    
    static testMethod void myTes3() {
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        Integer globalId = 123456;
        Integer managerId = 234567;
        for(Integer i=1 ; i<4; i++){
            ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record' + i, Quicklook_ID__c = 'test123'+i, Global_ID__c = String.ValueOF(globalId), Manager_Global_ID__c = String.valueOf(managerId), inActive__c = false));            
            globalId = managerId;
            managerId++;
        }
        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];
        
        List < User > u = new List < User > ();
        
        u.add(new User(alias = 'standt', email = 'standarduser111@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test12', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '123456', Manager_Global_ID__c = '1234567', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        
        insert ncrEmp;
        insert u;
        Test.startTest();
        CalculateManagerHierarchy c1 = new CalculateManagerHierarchy();
        Database.executeBatch(c1);
        Test.stopTest();
        user userObj = [select id,Area_VP__c from user where Quicklook_Id__c='test12'];
        System.assert(userObj.Area_VP__c=='Test Record 1');
    }
    
    static testMethod void myTes4() {
        List < NCR_Employee_Detail__c > ncrEmp = new List < NCR_Employee_Detail__c > ();
        Integer globalId = 123456;
        Integer managerId = 234567;
        for(Integer i=1 ; i<2; i++){
            ncrEmp.add(new NCR_Employee_Detail__c(User_Name__c = 'Test Record' + i, Quicklook_ID__c = 'test123'+i, Global_ID__c = String.ValueOF(globalId), Manager_Global_ID__c = String.valueOf(managerId), inActive__c = false));            
            globalId = managerId;
            managerId++;
        }
        Profile p = [SELECT id from Profile WHERE Id = '00e70000000sR8W'];
        
        List < User > u = new List < User > ();
        
        u.add(new User(alias = 'standt', email = 'standarduser111@ncr.com',
                       emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test12', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                       username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '123456', Manager_Global_ID__c = '1234567', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        
        insert ncrEmp;
        insert u;
        Test.startTest();
        CalculateManagerHierarchy c1 = new CalculateManagerHierarchy();
        Database.executeBatch(c1);
        Test.stopTest();
        user userObj = [select id,Area_VP__c from user where Quicklook_Id__c='test12'];
        System.assert(userObj.Area_VP__c=='Test Record 1');
    }
}