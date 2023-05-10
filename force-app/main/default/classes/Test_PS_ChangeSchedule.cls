/****************************************************************************************************************
//Name          :   Test_PS_ChangeSchedule.cls
//Author        :   Mudit Saxena
//Date          :   2 March 2017
//Version       :   Initial
//Description   :   This is test class for trigger "PS_ChangeSchedule".
****************************************************************************************************************/
@isTest
private class Test_PS_ChangeSchedule{
    public static testMethod void runUnitTest() {
       
        EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
        ebdedd.Name = 'EDSD_Calc';
        ebdedd.isActive__c = true;
        insert ebdedd; 
        System.assertNotEquals(ebdedd.id, null,'ebdedd List Should not be null');
        //Admin User
            User u1 = new User(alias = 'standt', email='standarduser2@ncr.com',
                emailencodingkey='UTF-8', lastname='Testing1',Quicklook_Id__c='AdmProfl', languagelocalekey='en_US',
                localesidkey='en_US', profileid = NSCCommonInfoUtil.getIdOf('NSC_Admin_04_UI_Profile'),timezonesidkey='America/Los_Angeles',
                username='standarduser2@ncr.com'+System.now().getTime()+'.com'); 
        system.runas(u1){ 
            opportunity opp = TestRecordsFactory.createOpportunityWithLineItemSchedule();        
           //opp.Expected_Delivery_Date__c = System.TODAY().addDays(90);
            opp.closeDate = Date.valueOf('2019-04-20');
            update opp;
            //Boolean check = Recursionblocker.flag;
            //opp.closeDate = System.TODAY().addMonths(5);    
            //update opp;
        }
    }
    
     public static testMethod void runUnitTest1() {
       
        
       
       opportunity opp = TestRecordsFactory.createOpportunityWithLineItemSchedule();        
        //opp.Expected_Delivery_Date__c = System.TODAY().addDays(90);
        opp.closeDate = Date.valueOf('2018-08-20');
        opp.stagename = 'Closed/Lost';
        opp.Price_Variance__c = 'NCR above 5%';
         opp.Are_we_the_Incumbent__c='NO';
         opp.Closed_Lost_Comments__c='Test';
         opp.Lose_to_a_Competitor__c='Test';
         opp.CLM_Sales_Acknowledgment__c=true;
         opp.Primary_Loss_Reason__c='Test';
         opp.Primary_Product_Type__c='HW';
        update opp; 
        System.assertNotEquals(opp.id, null,'Opp List Should not be null');
        
        
    }
}