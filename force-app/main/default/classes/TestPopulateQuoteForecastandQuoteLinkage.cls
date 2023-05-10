@IsTest
private class TestPopulateQuoteForecastandQuoteLinkage{

static testmethod void customerProductSetup(){
    Account a = new Account();
    a.name = 'test-acc';
    a.industry = 'HOSPITALITY:CHANNEL';
    a.Account_Country_Code__c = 'US';
    system.runas(TestRecordsFactory.getUser())
        {
            insert a; 
        }
    system.assert(a.id!=null);
    //insert a;
    
    Opportunity o = new Opportunity();
    o.accountid = a.id;
    o.name = 'test';
    o.closedate = system.today();
    o.stagename = 'Analyzing';
    o.Channel_Office__c = a.id;
    insert o;
    
    zqu__Quote__c q = new zqu__Quote__c();
    q.name = 'test-quote';
    q.zqu__Account__c = a.id ;
    q.zqu__Opportunity__c = o.id;
    q.zqu__Status__c = 'QA Processing Complete';
    q.Rebill__c = false; 
    q.Provisioning_Not_Required__c = false;
    q.Sales_Comp_Status__c = 'Complete';
    q.Provisioning_Status__c = 'Complete';
    q.zqu__ZuoraAccountID__c = '2c92c0f9ext1';
    q.zqu__InvoiceOwnerId__c = '2c92c0f9ext1';
    insert q;
        
    Customer_Product_Setup__c obj1 = new Customer_Product_Setup__c();
    obj1.Related_Quote__c = q.Id;
    obj1.ForecastLiveDate__c = Date.today();
    insert obj1;
    
    obj1.ForecastLiveDate__c = Date.today().addDays(1);
    update obj1;
    

}

}