@isTest
private class PRM_RevenueDataControllerTest {
	 @TestSetup static void testDataSetup(){
         User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
         System.runAs(partnerUser){
             Account partnerAccount = PRM_TestRecordsFactory.createPartnerAccount('test', null);
             insert partnerAccount;
             Contact partnerContact = PRM_TestRecordsFactory.createPartnerContact(partnerAccount.Id, '1', null);
             insert partnerContact;   
             List<Partner_Revenue__c> listOfPartnerRev = new List<Partner_Revenue__c>();
             for(Integer i=0; i<5; i++){
                 listOfPartnerRev.add(new Partner_Revenue__c(
                     Direct_Revenue__c=1000, Indirect_Revenue__c=1000, Hardware__c=1000, Software__c=1000, Professional_Services__c=1000,  
                     TS__c=1000, Hosted__c=1000, SaaS__c=1000,POSaaS__c=1000,Total_Services_Revenue__c=1000,Solution_from_Net_New_Customers__c=1000,
                     Subscription_from_Net_New_Customers__c=1000,First_Half__c=4000,Second_Half__c=3000, Partner_Account__c=partnerAccount.Id, 
                     Year__c = String.valueOf(System.today().year()-i)
                 ));
             }
             insert listOfPartnerRev;
         }
     }
    //This method is used to fetch record of the Partner Revenue according to Account Id
    @isTest static void fetchRevenueData() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Integer, Partner_Revenue__c> mapOfPartnerRev = PRM_RevenueDataController.getRevenueList(acc.Id);
        System.assertEquals(5, mapOfPartnerRev.size());
    }
    //This method is used to fetch record of the Partner Revenue when Account Id is Null
    @isTest static void fetchRevenueDataWithoutAccountId() {
        Account acc = new Account(Name='Test Acc');
        Map<Integer, Partner_Revenue__c> mapOfPartnerRev = PRM_RevenueDataController.getRevenueList(acc.Id);
        System.assertEquals(0, mapOfPartnerRev.size());
    }
    //This method is used to fetch record of the Partner Revenue according to Account Id and Selected Year
    @isTest static void fetchRevenueRecord() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String year = String.valueOf(System.today().year());
        List<Partner_Revenue__c> partRevRecord = new List<Partner_Revenue__c>(); 
        partRevRecord.add(PRM_RevenueDataController.getPartnerRevenueByYear(acc.Id, year));
        System.assertEquals(1, partRevRecord.size());
    }
}