@isTest
public class BatchUtilTest {

    @testSetup
    public static void setupData(){
        List<Contact> contactList=new List<Contact>();
        for(Integer i=0;i<10;i++)
        {
            contactList.add(new Contact(lastname='Contact'+i));
            contactList.add(new Contact(lastname='Save'+i));
        }
        insert contactList; 	
    }
    
    @isTest
    public static void executebatchWithSharingAtUserLevel()
    {
       System.assertEquals(20,[Select id from contact].size());
        Test.startTest();
        BatchUtil bat=new BatchUtil();
        bat.setObject('Contact');
        bat.setcondition('id !=null');
        bat.setBatchSize(10);
        bat.setLimit('10');
        bat.runAtUserLevel(true);
        bat.setWithSharing(true);
        bat.setAllOrNone(false);
        bat.setIsSchedule(true);
        bat.executeBatch();
        Test.stopTest();
        System.assertEquals(10,[Select id from contact Limit 10].size());
    }
    
    @isTest
    public static void executebatchWithoutSharingAtUserLevel()
    {
        System.assertEquals(10,[Select id from contact  Limit 10].size());
        Test.startTest();
        BatchUtil bat=new BatchUtil();
        bat.setIsSchedule(false);
        bat.setObject('Contact');
        bat.setcondition('id !=null');
        bat.setBatchSize(10);
        bat.setLimit('10');
        bat.runAtSystemLevel(true);
        bat.setWithoutSharing(true);
        bat.setAllOrNone(false);
        bat.setCronExp('0 15 10 15 *');
        bat.executeBatch();
        Test.stopTest();
        System.assertEquals(10,[Select id from contact Limit 10].size());
    }
    
     @isTest
    public static void executebatchWithtSharingAtUserLevel()
    {
        System.assertEquals(10,[Select id from contact  Limit 10].size());
        Test.startTest();
        BatchUtil bat=new BatchUtil();
        bat.setIsSchedule(false);
        bat.setObject('Contact');
        bat.setcondition('id !=null');
        bat.setBatchSize(10);
        bat.setLimit('10');
        bat.runAtSystemLevel(true);
        bat.setWithoutSharing(false);
        bat.setAllOrNone(false);
        bat.setCronExp('0 15 10 15 *');
        bat.executeBatch();
        Test.stopTest();
        System.assertEquals(10,[Select id from contact Limit 10].size());
    }
    
    @isTest
    public static void executebatchWithoutSharingIsSchedule()
    {
        System.assertEquals(10,[Select id from contact  Limit 10].size());
        Test.startTest();
        BatchUtil bat=new BatchUtil();
        bat.setIsSchedule(true);
        bat.setObject('Contact');
        bat.setcondition('id !=null');
        bat.setBatchSize(10);
        bat.setLimit('10');
        bat.runAtSystemLevel(true);
        bat.setWithoutSharing(true);
        bat.setAllOrNone(false);
        bat.setCronExp('0 15 10 15 *');
        bat.executeBatch();
        Test.stopTest();
        System.assertEquals(10,[Select id from contact Limit 10].size());
    }
    
     public static testMethod void testschedule() {
        Test.StartTest();
        RecordDeletionWithSharingSchedule runjob = new RecordDeletionWithSharingSchedule('Select id from contact  Limit 1',true);
        String sch = '0 0 0,4,8,12,16,20 * * ?';
        system.schedule('RecordDeletionWithSharingSchedule', sch, runjob );
        Test.stopTest();
    }
    
    public static testMethod void testschedule2() {
        Test.StartTest();
        RecordDeletionWithoutSharingSchedule runjob = new RecordDeletionWithoutSharingSchedule('Select id from contact  Limit 1',true);
        String sch = '0 0 0,4,8,12,16,20 * * ?';
        system.schedule('RecordDeletionWithoutSharingSchedule', sch, runjob );
        Test.stopTest();
    }
}