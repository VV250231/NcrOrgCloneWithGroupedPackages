@isTest
    private class test_ResellerTrigger{
    static testMethod void update_reseller_on_lead(){
        LeadOwnerNotificationSwitch__c l = new LeadOwnerNotificationSwitch__c(name='Lead Owner Switch',Lead_Owner_Swtich__c	= true);
        insert l;
        ResellerNotificationSwitchs__c r = new ResellerNotificationSwitchs__c(name = 'ResellerActivate',ResellerSwitch__c= false);
        insert r;
        Reseller__c res = new Reseller__c(
            CountryCode__c='US',
            NCR_Lead_Owner_Quicklook__c='sk250842',
            ResellerContactFirstName__c='testres',
            ResellerContactLastName__c='testress2',
            ZIPCode__c='1234567', 
            ZIPCode_file__c='1234567',
            ToEmail__c='abc@abc.com',
            Reseller__c='test Reseller',
            CCEmail__c='testccEmail@gmail.com',
            ResellerContactPhone__c='123456789'
        );
        
        insert res;
        
        Lead ld = new Lead(
            LastName ='1.8 ln hos', 
            Company = 'NCR Corp', 
            Industry__c = 'Hospitality',
            Country__c='UNITED STATES', 
            Country_Code__c='US',
            Email='testemail@lead.com',
            Status='Open',
            Lead_Stage__c='INQ',
            LeadType__c='Web',
            LeadSource__c='Paid-Display',
            SubIndustry__c='Airlines'
        ); 
        
        insert ld ;
        
        ld.PostalCode = '1234567' ;
        ld.Status = 'Partner Managed';
        ld.Country__c='UNITED STATES'; 
        ld.Country_Code__c='US';
            
            update ld ;	
        
        res.ToEmail__c='test2@gmail.com';
        res.Reseller__c='testResellerdata';
        res.CCEmail__c='test21@gmail.com';
        res.ResellerContactPhone__c='987654321';
        res.ResellerContactFirstName__c='US2';
        res.ResellerContactLastName__c='US3';
        
        update res;
        system.assert(res.Id!=null);
        
        
    }
}