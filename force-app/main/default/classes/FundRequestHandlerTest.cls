@isTest
public class FundRequestHandlerTest {
    
    @isTest
    public static void beforeInsertHandlerTest(){
        Account acc = new Account();
        acc.Name='Teat';
        acc.Industry='RETAIL:PUBLIC SECTOR';
        acc.LOB__c = 'RETAIL';
        acc.Partner_Type__c = 'Solution Provider';
        acc.Account_Region__c ='EMEA';
        system.runas(TestRecordsFactory.getUser())
        {
            insert acc; 
        }
         
        List<SFDC_MDF__c> fundList = new List <SFDC_MDF__c>();
        SFDC_MDF__c fund = new SFDC_MDF__c();
        fund.Account__c=acc.Id;
        fund.Name='Fund Request test';
        fund.Activity_Date__c = Date.today()+39;
        fund.End_Date__c =Date.today()+139;
        fundList.add(fund);
        Insert fundList;
        
        Test.startTest();
        FundRequestHandler.beforeInsertHandler(fundList);
         for(SFDC_MDF__C fund1:fundList){
            system.assertEquals(acc.Partner_Type__c, fund1.Account_Partner_Type__c);
        }
        Test.stopTest();
        
        
    }
}