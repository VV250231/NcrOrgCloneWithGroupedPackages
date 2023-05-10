/*************************************************************************************************
*   ClassName :   DealRegistrationTriggerTest
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
EBA_SF-2491     17-12-2022      Monika      EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
*************************************************************************************************/
@isTest
private class DealRegistrationTriggerTest {
    

    private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp', Master_Customer_Number__c  ='23213'));
        accounts.add(new Account(Name = 'Unit Test LLC', Master_Customer_Number__c  ='223213'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        User u = [Select Id from User Where Name = 'Soup User'];
        System.runAs(u) {
        insert accounts;
        }

    }

    private static User createUserandpartnerContact(){
        createAcc();
        Account ac = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        Profile p = [select Name from Profile WHERE name ='IPT Partner Community Login User'];     
               
       List<USER> userList = [Select id , name from USER Where ProfileId =:p.id And isActive =true];
       return userList[0];
     
    }
    
    /*
    static testmethod  void EngineeringTest() {
        //createUserandpartnerContact();
        //Account a = [SELECT Id FROM Account WHERE Name = 'Unit Test Corp' LIMIT 1]; //grab the Account that was created in the allTheDataForThisTestClass method
        System.runAs(createUserandpartnerContact()){
            Test.startTest(); //denote testing context
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
            deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
            deal.Is_this_part_of_an_RFP__c =true;
            deal.RecordTypeId =getRecordType('Experience 2020 - Frictionless Program');
            Insert deal;
            System.assertNotEquals(deal.id, null);
            Test.stopTest(); //rev
        }   
    } */
        static testmethod  void DealRegRejectControllerTest() {
        //createUserandpartnerContact();
        //Account a = [SELECT Id FROM Account WHERE Name = 'Unit Test Corp' LIMIT 1]; //grab the Account that was created in the allTheDataForThisTestClass method
        System.runAs(createUserandpartnerContact()){
            Test.startTest(); //denote testing context
            
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
            deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
            deal.Is_this_part_of_an_RFP__c =true;
            //deal.RecordTypeId =getRecordType('Experience 2020 - Frictionless Program');
            deal.VisualTemplate__c ='Test,Test';
            Insert deal;
            DealRegRejectController d = new DealRegRejectController();
            d.dealId = deal.id;
            d.getListOfReason();
           
            System.assertNotEquals(deal.id, null);
            Test.stopTest(); //rev
        }   
    }
    
    static testmethod  void DealRegistrationTest() {
        //createUserandpartnerContact();
        //Account a = [SELECT Id FROM Account WHERE Name = 'Unit Test Corp' LIMIT 1]; //grab the Account that was created in the allTheDataForThisTestClass method
        System.runAs(createUserandpartnerContact()){
            Test.startTest(); //denote testing context
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.End_Customer_Company_Name__c ='ABC Inc';
            deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
            deal.Is_this_part_of_an_RFP__c =true;
            deal.OwnerId =userinfo.getUserId();
            deal.Estimated_Close_Date__c = date.today();
            //deal.NCR_Account_Manager__c =Userinfo.getuserId();
            //deal.RecordTypeId =getRecordType('Retail Deal Registration');
            Insert deal;
            deal.Approved__c =true;
            update deal;
            System.assertNotEquals(deal.id, null);
            Test.stopTest(); //rev
        }   
    }
    
    /*
    private static Id getRecordType(String name){
         Map<String,Schema.RecordTypeInfo> rt_Map = Deal_Registration__c.sObjectType.getDescribe().getRecordTypeInfosByName();
         return  rt_Map.get(name).getRecordTypeId();
    }*/
}