@isTest
public class listViewControllerTest {
    public static void createTestData(){
        String CurrentUserId=UserInfo.getUserId();
        Group grp = new group(name='test1',type='Queue');
        insert grp;
        GroupMember gm = new GroupMember(UserOrGroupId =CurrentUserId,GroupId=grp.id);
        insert gm;
        system.debug('gm=='+gm);
    }
    @isTest
    public static void unitTest(){
        createTestData();
        Test.startTest();
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CX Case').getRecordTypeId();  
        Case caseObj = new Case(status = 'Open', origin = 'Call', recordTypeId = CaseRecordTypeId, description = 'Test Description');
        User u1 = TestRecordsFactory.getUser();
        System.runAs(u1){
            insert caseObj;
        }
        List<Case> caseList = listViewController.getCaseList();
        // listViewController.getCaseList() is returning follow up case record, therefore case list size is zero
        System.assert(caseList.size()==0);
        Test.stopTest();
    }
}