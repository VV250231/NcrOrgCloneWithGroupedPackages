@isTest
public class groomNcrPaymentSiteRecordsTest {
	public static testMethod void Test_PopulateOCRBookDateFieldsSecondMethod(){
        Account act=TestRecordsFactory.createAccount('Test456');
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(act);
        
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        PaySite.Opportunity__c = opp.Id;        
        insert PaySite;
        
        Opportunity Opp1 = [Select Id, Opportunity_Number__c from Opportunity where id=:opp.Id LIMIT 1];
        String response = '[{"merchantClaimURL":"https://merchantapp.io:443/ncralohapfintegration/Merchant/Claim/758cb569-aeb0-4370-ba03-a48ca9a62043","administratorURL":"https://merchantapp.io:443/ncralohapfintegration/CoBrands/MerchantUW?applicationId=136396","merchantApplicationId":"136396","externalMerchantApplicationId":"e2d83032f3ea4250841c521d7e18a070/790ce820ea974c308caefbcb4bf2f4e5","infiniceptApplicationId":"c40f4dbf-ba35-4237-a8c2-1dd8de4af385","status":30,"statusMessage":"Submission successful.","organizationId":"e2d83032-f3ea-4250-841c-521d7e18a070","siteId":"790ce820-ea97-4c30-8cae-fbcb4bf2f4e5","externalMerchantId":"ATL864","externalStoreId":"1234","cobrand":"ncralohapfintegration"}]';
        JPLogs__c jplog = new JPLogs__c(name=opp1.Opportunity_Number__c + '-OutBound',Type__c ='OutBound', Status__c='Success', Response__c = response);
        insert jplog;
        
        Test.startTest();
       		Database.executeBatch(new groomNcrPaymentSiteRecords(),1); 
        Test.stopTest();
        
    }
}