@isTest
public class CalculateDiscountRoleTest {
    @testSetUp
    public static void testUserData(){
        Profile p= [Select Id from profile where Name='04 NSC UI Administrator'];
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
        List < User > u1 = new List < User > ();
        List < User > u2 = new List < User > ();
        Id mid = TestRecordsFactory.getUser().id;
        System.debug('UserDetails'+mid);
        u1.add(new User(alias = 'standt1', email = 'standarduser111@ncr.com',Discount_Role__c = 'RVP',
                        emailencodingkey = 'UTF-8', lastname = 'Test Record 1', Quicklook_Id__c = 'test1234', languagelocalekey = 'en_US',
                        localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                        username = 'standarduser121@.ncr.com' + System.now().getTime() + '.com', global_id__c = '231453678', /*Manager_Global_ID__c = '231453671',*/ Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        u1.add(new User(alias = 'standt3', email = 'standarduser111@ncr.com',Discount_Role__c = 'AD',
                        emailencodingkey = 'UTF-8', lastname = 'Test Record 3', Quicklook_Id__c = 'test2345', languagelocalekey = 'en_US',
                        localesidkey = 'en_US', profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
                        username = 'standarduser122@.ncr.com' + System.now().getTime() + '.com', global_id__c = '222222222', /*Manager_Global_ID__c = '231453671',*/ Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Division_VP__c = 'Test Division', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        insert u1;
    }
    @isTest
    public static void batchTest(){
        List < User > u2 = new List < User > ();
        Profile pf= [Select Id from profile where Name='02 NSC Administrator'];
        User u =[Select id,IsActive,ManagerId,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where lastname = 'Test Record 1'];
        NCR_Employee_Detail__c ncr =[Select id , Global_ID__c from NCR_Employee_Detail__c where Global_ID__c='231453671'];
        u2.add(new User(alias = 'standt2', email = 'standarduser111@ncr.com',Discount_Role__c = 'AD',
                        emailencodingkey = 'UTF-8', lastname = 'Test Record 222', Quicklook_Id__c = 'test4567', languagelocalekey = 'en_US',
                        localesidkey = 'en_US', profileid = pf.Id, timezonesidkey = 'America/Los_Angeles',
                        username = 'standarduser111@.ncr.com' + System.now().getTime() + '.com',ManagerId=u.id, global_id__c = ncr.Global_ID__c, Manager_Global_ID__c = u.global_id__c, Division_VP__c = 'Test Division', Region_VP__c = 'Region Test', Area_VP__c = 'Area Test', Area_VP_QuickLook__c = 'Test1234', Region_VP_QuickLook__c = 'Test1235', Division_VP_QuickLook__c = 'Test1236', isActive = True));
        insert u2;
        
        User u3 =[Select id,IsActive,ManagerId,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where lastname = 'Test Record 3'];
        u3.Discount_Role__c = 'RVP';
        update u3;
        system.assert(u3.id!=null);
        system.assertEquals(u3.Discount_Role__c ,'RVP');
        System.debug('UserDetails'+u.global_id__c);
        System.debug('UserDetails'+u2[0].Manager_Global_ID__c);
        System.debug('UserDetails'+u2[0].ManagerId);
    }
    
    
    @isTest
    public static void batchTest2(){
        User u3 =[Select id,IsActive,ManagerId,ProfileId,Global_ID__c,LocaleSidKey,Alias,ContactId,FederationIdentifier,Quicklook_ID__c,CompanyName,Email,LastName from User where lastname = 'Test Record 3'];
        u3.Discount_Role__c = 'RVP';
        update u3;  
        system.assert(u3.id!=null);
        system.assertEquals(u3.Discount_Role__c ,'RVP');
    }
    
}