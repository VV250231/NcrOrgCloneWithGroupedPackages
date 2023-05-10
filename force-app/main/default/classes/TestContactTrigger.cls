@isTest
private class TestContactTrigger {
    
    
    Public Static User getUser(){        
       User Usr = [Select Id from User Where Name = 'Soup User'];
       return Usr;
    }

    @isTest static void run() {

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
          System.runAs(getUser()){
      
              insert a;
        }

        Contact con = TestRecordsFactory.createContact( a );

        con.Active_Contact__c = false;
        con.Email = null;
        con.Primary_Language__c = null;
        con.SuspendProcessing_Contact__c = true;
        update con;
		Test.startTest();
        Lead_Trigger_Future_method.updatecontact(new Set<Id>{con.id});
        Test.stopTest();
        contact conOld = [ SELECT id,Active_Contact__c,Survey_Flag__c,Business_Function__c,Level__c,Decision_Maker__c,Email FROM Contact WHERE id =: con.id LIMIT 1 ];
        conOld.Active_Contact__c = true;
        conOld.Decision_Maker__c='None Specified'; 
        conOld.Level__c='None Specified';
        conOld.Business_Function__c='None Specified';
        //update conOld;
        
        Database.SaveResult result = Database.update( conOld, false );
        System.assertEquals( 'Please enter a correct value',result.getErrors()[0].getMessage() );
    }
  
}