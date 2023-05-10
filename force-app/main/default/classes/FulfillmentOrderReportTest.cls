@isTest(SeeAllData=false)
public class FulfillmentOrderReportTest {
@testSetup
    static void setup(){
        List<qtc_FulfillmentOrder__c> fulfillmentOrders = new List<qtc_FulfillmentOrder__c>();
        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
        for(Integer i=1; i<10;i++){
            Opportunity o = new Opportunity();
            Contact ct = new Contact(FirstName = 'Sanskar', LastName='Shukla'+i, Email = 'Sanskar.Shukla'+i+'@ncr.com');
            insert ct;
            System.debug('got Contact in test:'+ i + ' --->' + ct);
            Map<String,String> fieldApiNameToFieldValue = new Map<String,String>();
            Account at = new Account(Name = 'Test Account 2', Primary_Contact__c = ct.Id);
            System.debug('got Account in test:'+ i + ' --->' + at);
            insert at;
            
            SBQQ__Quote__c qt = new SBQQ__Quote__c(SBQQ__Partner__c = at.Id, qtc_Channel_Local_Office_Record_Type__c = 'PARTNER');
            insert qt;
            qtc_FulfillmentOrder__c ld = new qtc_FulfillmentOrder__c(qtc_Quote__c = qt.Id, qtc_OrderStartDate__c = Date.newInstance(2016, 12, 9));
            insert ld;
            ld.qtc_Quote__r = qt;
            update ld;

            fulfillmentOrders.add(ld);
        }
        System.debug('Pseudo Order :' + fulfillmentOrders);
        }
    }
    static testmethod void testFulfillmentOrderReportScheduleJob(){
        String sch = '0 5 12 10 2 ?';
        Test.startTest();
        String jobId = System.Schedule('ScheduleFulfillmentOrderReportTest', sch, new FulfillmentOrderReport());
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Fulfillment_Order_Reports_For_Channel'];
        List<qtc_FulfillmentOrder__c> fulfillmentOrders = [SELECT qtc_Quote__r.SBQQ__Partner__r.Primary_Contact__c, qtc_Quote__r.SBQQ__Partner__r.Primary_Contact__r.Email FROM qtc_FulfillmentOrder__c Where qtc_Quote__r.qtc_Channel_Local_Office_Record_Type__c = 'PARTNER' AND qtc_Quote__r.SBQQ__Ordered__c = false AND qtc_OrderStartDate__c <= THIS_MONTH ORDER BY qtc_Quote__r.SBQQ__Partner__c];
        System.debug('Pseudo Order counts :' + fulfillmentOrders.size());
        Test.stopTest();
        System.debug('testFulfillmentOrderReportScheduleJob :' + fulfillmentOrders);
    }
}