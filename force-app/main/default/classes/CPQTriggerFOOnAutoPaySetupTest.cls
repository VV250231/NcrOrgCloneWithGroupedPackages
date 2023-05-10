@isTest
public class CPQTriggerFOOnAutoPaySetupTest {
    private static Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();
    
    @isTest
    static void updateQuoteToSyncFulfillmentOrderTest(){
        
         Opportunity thisOpportunity;
        Account thisAccount = new Account(name = 'ContractTestAccount',
            LOB__c = 'FINANCIAL',
            Master_Customer_Number__c = 'MCN1',
            Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
            Active_Account__c = true,
            Project_Coordinator_Email__c = 'abc@test.com'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert thisAccount;
        

            thisOpportunity = new Opportunity(
                AccountID = thisAccount.id,
                Name = 'OppQuote Linkage Test Opportunity',
                type = 'Indirect Channel',
                CURRENCYISOCODE = 'USD',
                INVOICE_TRIGGER__C = 'Shipment',
                Expected_Delivery_Date__c = System.TODAY().addDays(30),
                closeDate = System.TODAY(),
                stagename = 'Prospecting',
                Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
                EndCustomerUnknown__c = true,
                Skip_Validation_Rule_for_Lead_Conversion__c = true,
                ForecastCategoryName ='Omitted',
                CPQ__c = true
            );
            insert thisOpportunity;
        }
         User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account testAccount = new Account(
                RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = thisAccount.Id,
                CDM_Account_Type__c = 'Site',
        		AutoPay_Setup__c = 'True');
        System.runAs( Usr ){
            insert testAccount;
        }
        SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true,
            qtc_Bill_To_Site__c = testAccount.id,
          	qtc_Legal_Document_Status__c = 'Completed'
        );
        insert thisQuote;
        
        Test.startTest();
        List<String>  accIds = new List<String>();
        accIds.add(testAccount.id);
        CPQTriggerFOOnAutoPaySetup.updateQuoteToSyncFulfillmentOrder(accIds);
        Test.stopTest();
    }

}