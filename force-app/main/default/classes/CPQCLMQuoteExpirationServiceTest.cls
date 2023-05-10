/********************
* Class Name: CPQCLMQuoteExpirationServiceTest
* Description: This Test class resposible to Test logic to send documents to cancelled at CLM upon quote expiration in CPQ
* Created By: Pankaj Pandey
* Created Date: 16-AUG-2022
* 
* Srno       Date            Description
* 1       16-AUG-2022     	SFCPQBLG-1174
* 
* *******************************************/
@isTest
public with sharing class CPQCLMQuoteExpirationServiceTest {
	@testSetup
    public static void setup(){
        
           Account thisAccount = new Account(name = 'ContractTestAccount',
                                          LOB__c = 'FINANCIAL',
                                          Master_Customer_Number__c = 'SETUPMASTERCONTRACT',
                                          Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                                          Active_Account__c = true,
                                          Primary_Bill_To__c = true,
                                          Bill_To__c = true,
                                          Ship_To__c = true, 
                                          Primary_Ship_To__c = true,
                                          Deliver_To__c = true, 
                                          Primary_Deliver_To__c = true,
                                          CDM_Account_Type__c='LOCAL OFFICE',
                                          CDM_Account_Status__c = 'Active',
                                          industry = 'HOSPITALITY:QSR',
                                          Project_Coordinator_Email__c = 'abc@test.com'
                                         );
        User soupUser = TestRecordsFactory.getUser();
        System.runAs( soupUser ){
            insert thisAccount;
        }
        
        Opportunity thisOpportunity = new Opportunity(
            AccountID = thisAccount.id,
            Name = 'OppQuote Linkage Test Opportunity',
            type = 'Indirect Channel',
            CURRENCYISOCODE = 'USD',
            INVOICE_TRIGGER__C = 'Shipment',
            Expected_Delivery_Date__c = System.TODAY().addDays(30),
            closeDate = System.TODAY(),
            Channel_Office__c= thisAccount.id,
            stagename = 'Prospecting',
            Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price',
            EndCustomerUnknown__c = true,
            Skip_Validation_Rule_for_Lead_Conversion__c = true,
            ForecastCategoryName ='Omitted'
        );
        insert thisOpportunity;
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
                  
            SBQQ__Quote__c thisQuote = new SBQQ__Quote__c(
            CurrencyIsoCode = 'USD',
            SBQQ__Account__c = thisAccount.Id,
            SBQQ__Opportunity2__c = thisOpportunity.Id,
            SBQQ__Primary__c=true,
            SBQQ__SalesRep__c = soupUser.Id,
            qtc_Quote_Name__c = 'test quote name',
            SBQQ__Status__c='Expired');
            
            quotes.add(thisQuote);
             
        insert quotes;
        
        CUSTOMER_DOCUMENT__C doc = new CUSTOMER_DOCUMENT__C(DOCUMENT_TYPE__C = 'AE Order Form',
        DOCUMENT_LINK__C = 'https://na11.springcm.com/atlas/Documents/DocExplorer?aid=10293&Id=e37f23ad-70c2-ec11-9c48-d89d6716196d',
        Document_Status__c = 'Sent for Signature',QUOTE__C = thisQuote.ID,ACCOUNT__C = thisAccount.id,
        NAME = 'Test CPQ TO CLM Quote Expire.');
        insert doc;
        
    }
    
    static testmethod  void testMethods(){
        
        Test.startTest();
        System.schedule('CLM Document Request Test',  '0 0 * * * ?', new CPQCLMQuoteExpirationService(true));
        Test.stopTest();       
        
    }

}