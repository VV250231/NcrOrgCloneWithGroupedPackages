@isTest
public class LeadNotificationBatchTestClass {
    public static String CRON_EXP = '0 0 0 15 6 ? 2025';
    @isTest
    public static void testLeadNotificationBatchApex(){
       // User u =[Select id,email from User where id =:UserInfo.getUserId()];
        Lead ld = new Lead(LastName ='TestLead12',LeadOwnerManage__c='tt250288@ncr.com', Company = 'NCR',Industry__c ='Hospitality',SubIndustry__c='Airlines',Country__c='AUSTRIA',Email='ddd_unique@zzz.com',
                           Status='Qualified',Lead_Stage__c='MQL',Lead_Qualified_DateTime__c=System.now().addHours(-169),LeadType__c='Chat',LeadSource__c='Paid - Display');
        Lead ld1 = new Lead(LastName ='TestLead11',LeadOwnerManage__c='t1t250288@ncr.com', Company = 'NCR',Industry__c ='Hospitality',SubIndustry__c='Airlines',Country__c='AUSTRIA',Email='ddd_unique@zzz.com',
                            Status='Qualified',Lead_Stage__c='MQL',Lead_Qualified_DateTime__c=System.now().addHours(-169),LeadType__c='Chat',LeadSource__c='Paid - Display');
        insert ld;
        insert ld1;
        
        Lead ld2 = new Lead(Lead_Qualified_DateTime__c=System.now().addHours(-169),id=ld1.id);
        string ld2JSON=JSON.serialize(ld2);
        lead ld2Obj = (lead) JSON.deserialize(ld2JSON, lead.class );
        update ld2Obj;
        
        Test.startTest();
        LeadSchdeuleApexNotifcationClass obj1 = new LeadSchdeuleApexNotifcationClass();
        System.schedule('ScheduledApexTest', CRON_EXP, obj1);
        Test.stopTest();
        lead ldd = [select Lead_Qualified_DateTime__c from lead where id=:ld2.id];
        System.assert(ldd.Lead_Qualified_DateTime__c!=null);
    }
}