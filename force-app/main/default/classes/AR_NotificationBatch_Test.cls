@isTest
public class AR_NotificationBatch_Test {
    @isTest
    public static void testArNotification() {
        Account a = TestRecordsFactory.createAccount();
        Account aa=[Select id, Country_with_Master_customer_Number__c from Account WHERE Id =: a.Id LIMIT 1];
        //Breakup
        Credit_Detail_Break_Up__c cdb = new Credit_Detail_Break_Up__c();
        cdb.Aging_31_60__c=10;
        cdb.Aging_31__c=10;
        cdb.Aging_61_90__c=20;
        cdb.Aging_91_180__c=10;
        cdb.Aging_181_360__c=30;
        cdb.Aging_360__c=10;
        cdb.Classification_Invoice_Type__c='Other';
        cdb.Customer_Balance__c=100;
        cdb.Industry__c='Hospitality';
        cdb.Not_Due_1_360_Days__c=10;
        cdb.Not_Due_360_Days__c=10;
        cdb.On_Hold__c='NO';
        cdb.Unique_ID_Credit_Detail__c=aa.Country_with_Master_customer_Number__c;
        cdb.Unique_ID__c=aa.Country_with_Master_customer_Number__c;
        
        DateTime dt1 = DateTime.Now().addDays(-2);
        
        cdb.CreatedDate = dt1;
        cdb.LastModifiedDate = dt1;
        
        Insert cdb;
        system.assertEquals(cdb.Unique_ID_Credit_Detail__c,aa.Country_with_Master_customer_Number__c);
        system.debug('&&&^^^'+cdb);
        Test.startTest();
        Credit_Detail_Clean rollup = new Credit_Detail_Clean(true);
        ID batchprocessid = Database.executeBatch(rollup);
        
        List<Credit_Detail_Break_Up__c> cdbRec= [SELECT id, Credit_Detail__c FROM Credit_Detail_Break_Up__c WHERE Id=:cdb.Id];
        if (cdbRec.size() > 0 && cdbRec[0].Credit_Detail__c  != null) {
            Credit_Detail__c cd = [SELECT Id, Last_Notification_Date__c,Is_Record_freeze_for_Notification__c FROM Credit_Detail__c WHERE Id=:cdbRec[0].Credit_Detail__c];
            cd.Last_Notification_Date__c = System.today()-20;
            cd.Is_Record_freeze_for_Notification__c = true;
            cd.iPaaS_Update_Successful__c = true;
            update cd;
        }
        AR_NotificationBatch batch = new AR_NotificationBatch();
        batch.failureCounter=1;
        Database.executeBatch(batch); 
        
        AR_Batch arBatch = new AR_Batch();
        Database.executeBatch(arBatch); 
        Test.stopTest();
        
    }
    
    @isTest
    public static void testschedule() {
        Test.StartTest();
        Schedule_AR_NotificationBatch testsche = new Schedule_AR_NotificationBatch();
        String sch = '0 0 23 * * ?';
        String jobId =system.schedule('Test status Check', sch, testsche );
        //system.schedule('Test status Check', sch, testsche );
        
        Schedule_AR_Batch testschedule = new Schedule_AR_Batch();
        String schdu = '0 0 23 * * ?';
        String jobId1 =system.schedule('ArBatch status Check', schdu, testschedule );
//system.schedule('ArBatch status Check', schdu, testschedule );
 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];  
        System.assertEquals(schdu, ct.CronExpression); 
        
        Test.stopTest();
      




    }
}