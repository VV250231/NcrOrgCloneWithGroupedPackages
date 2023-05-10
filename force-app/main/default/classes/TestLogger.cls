/*
##################################################################################################
# Project Name..........: Easy Button                                                                     
# File..................: TestLogger.cls                                                        
# Version...............: 32.0 
# Created by............: Puneet Bhatia                                                                   
# Created Date..........: 23-02-2015                                                                               
# Last Modified by......: Puneet Bhatia
# Last Modified Date....: 23-02-2015 
# Description...........: The test class is written to test the Logger Class.
################################################################################################
*/
@isTest
private class TestLogger   {  
    static testMethod void loggerTest() {
    
        // create new account object
        Account a  = new Account (name = 'Test Acc',
                                      LOB__c='FINANCIAL', 
                                      Master_Customer_Number__c = 'TEST000012', 
                                      Account_Country_Code__c = 'US',
                                      CurrencyIsoCode = 'USD', 
                                      Active_Account__c = true);
        System.runAs(TestRecordsFactory.getUser()){
          insert a;
        }
        
        Account a1 = new Account();
        a1.name = 'test-acc';
        a1.industry = 'HOSPITALITY:CHANNEL';
        a1.Account_Country_Code__c = 'US';
        insert a1;
        
        Opportunity o = new Opportunity();
        o.accountid = a1.id;
        o.name = 'test';
        o.closedate = system.today();
        o.stagename = 'Analyzing';
        o.Channel_Office__c = a1.id;
        insert o;
        
        zqu__Quote__c q = new zqu__Quote__c();
        q.name = 'test-quote';
        q.zqu__Account__c = a1.id ;
        q.zqu__Opportunity__c = o.id;
        q.zqu__Status__c = 'QA Processing Complete';
        q.Rebill__c = false; 
        q.Provisioning_Not_Required__c = false;
        q.Sales_Comp_Status__c = 'Complete';
        q.Provisioning_Status__c = 'Complete';
        q.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
        insert q;
        
        System.assert(a.Id != null, true);
         
       
        
        
         
        
        
        OppQuoteLinkageController.OppSearchRequest searchReq = new OppQuoteLinkageController.OppSearchRequest();
        searchReq.custNumber = 'TEST000012';
        searchReq.accCountryCode = 'US';
        searchReq.offerPortfolio = 'Financial Self Service';
        searchReq.oppName = 'Test Opp'; 
        searchReq.oppNameOPR = OppQuoteLinkageController.COMPARISON_OPR.EQUALS;
        searchReq.oppNumber = '1234';
        searchReq.oppNumberOPR = OppQuoteLinkageController.COMPARISON_OPR.EQUALS;
        
        OppQuoteLinkageController.OppSearchResponse searchRes = new OppQuoteLinkageController.OppSearchResponse('SUCCESS', 'No Record Found');
                 
       
        
        Logger.logSearchCall(NULL, JSON.serialize(searchRes));
        Logger.logSearchCall(JSON.serialize(searchReq), JSON.serialize(searchRes));
        Logger.logSearchCall(JSON.serialize(searchReq), 'test response');
        Logger.logSOUPGetQuotes('test');
        
        zqu__Quote__c zquote =  [select zqu__Number__c, Provisioning_Status__c , Status_Details__c , zqu__StartDate__c from zqu__Quote__c where id =: q.id LIMIT 1];
        Logger.logProvisioningUpdate(zquote.id, zquote.zqu__Number__c, zquote.Provisioning_Status__c , zquote.Status_Details__c, zquote.zqu__StartDate__c, 'success');
        
    }
    
     class CustomException extends Exception {} 
}