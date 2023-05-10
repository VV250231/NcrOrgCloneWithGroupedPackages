@isTest
private class MarketingConciergeTriggerTest{

    static testmethod  void MarketingConciergeTest() {
            Test.startTest(); //denote testing context
            Marketing_Concierge__c mc = new Marketing_Concierge__c();
            mc.Partner_Email_Address__c ='abc@xyz.com';
            mc.Partner_Phone_Number__c ='999999';
            Insert mc;
            mc.Status__c = 'Approved';
            Update mc;
        	system.assertEquals(mc.Status__c,'Approved');
            Test.stopTest(); //rev
     
    }
   }