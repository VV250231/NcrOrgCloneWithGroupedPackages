@isTest
private class UpdateOppSalesOrgCodeTest {
    
     public static testMethod void myTest() {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        system.assertNotEquals(Usr.Id,null);
        Id pr =NSCCommonInfoUtil.getIdOf('NSC_Admin');  //Change by saurav
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
         
   
        
        Account a;
        
        System.runAs(Usr) {
             a = new Account(name='Account-1');
             a.MDM_Data_Source_Code__c = 'CDM';
             a.Global_Sales_Org_Code__c = 'Test1234';
             insert a;
            
             Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
             Opportunity opp = TestRecordsFactory.createSimpleOpportunity(a);
          
             a.Global_Sales_Org_Code__c = '12345';
             update a;     
            
             Sales_Org__c org1 = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='12345', ownerId= pr, isPrimary__c =true);
             insert org1;
         }
    }
    /*this will cover populateAccountOrgCode trigger*/
    public static testMethod void test2() {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        system.assertNotEquals(Usr.Id,null);
          Id prf =NSCCommonInfoUtil.getIdOf('NSC_Admin'); //Change by saurav 00570000001N9kDAAS
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
         
   
        
        Account a;
        
        System.runAs(Usr) {
             a = new Account(name='Account-1');
             a.MDM_Data_Source_Code__c = 'CDM';
             a.Global_Sales_Org_Code__c = 'Test1234';
             insert a;
            
             Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
             Opportunity opp = TestRecordsFactory.createSimpleOpportunity(a);
          
             a.Global_Sales_Org_Code__c = '12345';
             update a;     
            
             Sales_Org__c org1 = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='12345', ownerId=prf, isPrimary__c =true);
          
            insert org1;
            org1.isPrimary__c = false;
            try{
            update org1;
            }
            catch( exception ex){
                system.debug(ex.getMessage());
            }
            Sales_Org__c org2 = new Sales_Org__c(name = 'test org1', Is_Active_in_RoR__c = true, Sales_Org_Code__c='12345', ownerId=prf, isPrimary__c =false);
          
            insert org2;
            org2.isPrimary__c = true;
            try{
            update org2;
            }
            catch( exception ex){
                system.debug(ex.getMessage());
            }
            try{
             delete org1;
            }
            catch( exception ex){
                system.debug(ex.getMessage());
            }
           
         }
    }
         
}