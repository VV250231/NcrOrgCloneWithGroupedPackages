/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class testValidateOpportunities {

   /* static testMethod void myUnitTest() {
        
        // check if WOT SPOT custom setting is availble, if not create WOT SPOT custom setting record
       
        WOT_SPOT_Validation__c orderValidation = WOT_SPOT_Validation__c.getValues('WOT_SPOT Required Validation');
        if(orderValidation  == null){
            WOT_SPOT_Validation__c  settingObj = new WOT_SPOT_Validation__c(Name = 'WOT_SPOT Required Validation', Active__c = true);  
            insert settingObj; 
        }
        
       
  //set<ID> salesProfileIds = new set<Id>{'00e700000013gXJ','00e700000013gX4','00e700000013gX9','00e700000013b70','00e70000001BOdx','00e70000001BOe2','00e70000001BOe7'};
     set<ID> salesProfileIds = new set<Id>{NSCCommonInfoUtil.getIdOf('Banking_Account_Manager'),NSCCommonInfoUtil.getIdOf('Global_Renewals'),NSCCommonInfoUtil.getIdOf('X50_Hospitality_Account_Director'),NSCCommonInfoUtil.getIdOf('X51_Hospitality_Account_Manager'),NSCCommonInfoUtil.getIdOf('X52_Hospitality_Finance_Manager'),NSCCommonInfoUtil.getIdOf('Global_Renewals')};

        
        //        salesProfileIds.addAll('00e700000013gXJ','00e700000013gX4','00e700000013gX9','00e700000013b70','00e700000013b6P','00e70000001BOL5','00e70000001BOdx','00e70000001BOe2','00e70000001BOe7','00e70000000xBoN','00e70000000xBoS','00e70000000xBoX','00e70000000xFkD');
        List <User> salesUser = [Select id, profileId,User_Profile__C from User where profileId in :salesProfileIds and IsActive = true];
        
        User nonLTNGUser = [Select id, profileId, User_Profile__C from User where Profile.PermissionsLightningExperienceUser  = false and UserType='standard' and IsActive = true limit 1];
        
        //Fetch Customer Record Type
        RecordType r = [Select Id from RecordType where SobjectType = 'Account' and name = 'Customer' and IsActive = true];
        
        
        //create new account
        
        Account a = new Account (RecordTypeId = r.Id, name = 'testing validateAmount trigger', Master_Customer_Number__c = 'TEST000013', Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', Active_Account__c = true);
        system.runAs(TestRecordsFactory.getUser()){
            insert a;}

        //create new salesorg
        Sales_Org__c s = new Sales_Org__c (name = 'testing validateAmount trigger', Is_Active_in_RoR__c = true);
        insert s;

        //create new competitor
        Competitors__c c = new Competitors__c (name = 'testing validateAmount trigger');
        insert c;
        
        r = [Select Id from RecordType where SobjectType = 'Opportunity' and name = 'Include in Funnel' and IsActive = true];
        //get 2X Profile User
        User active2XUser;
        User activeGSalesUser;
        User activeIPSSalesUser;
        User active5XUser;
        

        for(User u : salesUser){
            System.debug(u.ProfileId);
          // if(*u.ProfileId == '00e700000013gXJ' || u.ProfileId == '00e700000013gX4' || ){

            if(u.ProfileId == NSCCommonInfoUtil.getIdOf('Banking_Account_Manager') ){
                active2XUser = u;
            }
            
            // else if(u.ProfileId == '00e700000013b70'  ){
            else if(u.ProfileId == NSCCommonInfoUtil.getIdOf('Banking_Account_Manager')  ){
                activeGSalesUser = u;
            }
            else if(u.ProfileId == '00e70000001BOdx' ||  u.ProfileId == '00e70000001BOe2' || u.ProfileId == '00e70000001BOe7'){
                activeIPSSalesUser = u;
            }
            
            else if(u.ProfileId == NSCCommonInfoUtil.getIdOf('X50_Hospitality_Account_Director') || u.ProfileId == NSCCommonInfoUtil.getIdOf('X51_Hospitality_Account_Manager') ||u.ProfileId == NSCCommonInfoUtil.getIdOf('X52_Hospitality_Finance_Manager') ){
                active5XUser = u;
            }
        }
        //create new opportunity
        EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
        ebdedd.Name = 'EDSD_Calc';
        ebdedd.isActive__c = true;
        insert ebdedd;
        
        Opportunity o1 = new Opportunity (RecordTypeId = r.Id, AccountId =a.Id, name = '2X User Opportunity', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Closed/Lost', Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, ownerid =active2XUser.id);
        Opportunity o2 = new Opportunity (RecordTypeId = r.Id, AccountId =a.Id, name = '30 User Opportunity', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Closed/Lost', Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, ownerid =activeGSalesUser.id);
        Opportunity o3 = new Opportunity (RecordTypeId = r.Id, AccountId =a.Id, name = '31 User Opportunity', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Offering', Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, ownerid =nonLTNGUser.id);
        Opportunity o4 = new Opportunity (RecordTypeId = r.Id, AccountId =a.Id, name = '5X User Opportunity', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Closed/Lost', Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, ownerid =active5XUser.id);
        Opportunity o5 = new Opportunity (RecordTypeId = r.Id, AccountId =a.Id, name = '31 User Opportunity', CurrencyIsoCode = 'USD', Solution_Portfolio__c = 'Retail Assisted Service', Sales_Org__c = s.Id, Type = 'New Customer - New Solution',  CloseDate = System.TODAY() + 2, Marketing_Program__c = 'None - RSD', Expected_Delivery_Date__c = System.TODAY() + 4, Application__c = 'SA None', Invoice_Trigger__c = 'Shipment', StageName = 'Offering', Customer_Service_Area__c = 'US Central', Primary_Competitor__c = c.Id, ownerid =nonLTNGUser.id);
        List<Opportunity> o = new List<Opportunity>{o1,o2,o3,o4, o5};
        insert o;
        test.startTest();       
        System.RunAs(active2XUser){
            try{
                o1.StageName = 'Analyzing';
                update o1;
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
        }
        System.RunAs(activeGSalesUser){
            try{
                o2.StageName = 'Analyzing';
                update o2;
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
        } 
        System.RunAs(nonLTNGUser){
            try{
                
                List<Opportunity> oppList = new List<Opportunity>();
                o3.StageName = 'Analyzing';
                
                oppList.add(o3);
                oppList.add(o5);
                update oppList ;
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
        } 
        
        System.RunAs(active5XUser){
            try{
                o4.StageName = 'Analyzing';
                
                update o4;
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
        }  
        
        CheckRecursive.addValOppTriggerRun();
        CheckRecursive.addValOppTriggerRun();
        update o1;
        test.stopTest();    
    } */
    
     static testMethod void runTestMethod() {
         EBDEDDSetting__c ebdedd1 = new EBDEDDSetting__c();
         ebdedd1.Name = 'EDSD_Calc';
         ebdedd1.isActive__c = true;
         insert ebdedd1;
          Opportunity opp = TestRecordsFactory.createSimpleOpportunity();  

          Profile DIprofile = [SELECT Id FROM Profile WHERE Name = '62 DI Account Manager' LIMIT 1];
          User DIUser = new User(Alias = 'st1234', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing1234', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = DIprofile.Id, Quicklook_ID__c   = 'st1234', 
              TimeZoneSidKey='America/Los_Angeles', UserName='st1234@testorg.com');

         System.runAs(DIUser) {
             Account a = new Account(Id = opp.AccountId);
             Opportunity opp1 = TestRecordsFactory.createSimpleOpportunity(a); 
             System.assert(opp1.id!=null);
         }
    }
}