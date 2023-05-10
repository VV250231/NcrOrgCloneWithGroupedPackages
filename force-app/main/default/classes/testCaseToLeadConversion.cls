@isTest
private class testCaseToLeadConversion {
    
    static testMethod void PopulateCaseFieldsFromPreChatForm(){
        Account a = new Account();
        a.Name = 'Digital Insight';
        a.Master_Customer_Number__c = '4423DI';
        a.FI_Type__c = 'Bank';
        a.FDIC__c = '4423fdic';
        a.DI_Customer__c = '4423';
        a.Tier__c = '5';
        a.Website = 'www.lmgtfy.com?q=agile';
        a.Phone = '818-867-5309';
        a.Fax = '818-597-5310'; 
        a.BillingStreet = '5601 N Lindero Canyon Rd'; 
        a.BillingCity = 'Westlake Village';
        a.BillingState = 'CA';
        a.BillingPostalCode = '91362';
        a.BillingCountry = 'US';
        system.runas(TestRecordsFactory.getUser())
        {
            insert a; 
        }
        
        Contact con = TestRecordsFactory.createContact( a );
        
        con.Active_Contact__c = false;
        con.Email = null;
        con.Primary_Language__c = null;
        con.SuspendProcessing_Contact__c = true;
        update con;
        
        
        Lead l = new Lead(LastName ='1.8 ln hos', Company = 'NCR Corp', Industry__c = 'Hospitality',Country__c='UNITED STATES', Country_Code__c='US',Email='fff_unique@zzzpartner.com',
                                  Status='Open',Lead_Stage__c='INQ',LeadType__c='Event',LeadSource__c='Sales-Referral (SGL)'); 
        
        insert l ;
        
        caseToLeadConversion.searchExistingLead(l.id);
        List<Sobject> Lead1= caseToLeadConversion.searchExistingLead(l.email);
        system.assert(Lead1[0].id!=null);
        
        
        
  
        
    }
    
}