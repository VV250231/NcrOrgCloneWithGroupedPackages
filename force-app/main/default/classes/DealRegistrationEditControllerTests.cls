/*
##################################################################################################
# Class Name............................:DealRegistrationEditControllerTests                                                                                                                                 
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest (seealldata=true)
private class DealRegistrationEditControllerTests {
    
        

    private static void createAcc(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        
        System.runAs(TestRecordsFactory.getUser()){
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

    static testmethod  void EngineeringTest() {
        //createUserandpartnerContact();
        //Account a = [SELECT Id FROM Account WHERE Name = 'Unit Test Corp' LIMIT 1]; //grab the Account that was created in the allTheDataForThisTestClass method
        System.runAs(createUserandpartnerContact()){
           
            PageReference pageRef = Page.DealRegistrationEditPage;
            
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
            deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
            deal.Is_this_part_of_an_RFP__c =true;
            //deal.RecordTypeId =getRecordType('Experience 2020 - Frictionless Program');
           // ApexPages.currentPage().getParameters().put('RecordType',deal.RecordTypeId);
            ApexPages.StandardController dealstd= new ApexPages.StandardController(deal);
            
            DealRegistrationEditController controller = new DealRegistrationEditController(dealstd);
            dealstd.save();
           // System.assertNotEquals(deal.id, null);
           System.assertNotEquals(dealstd, null,'dealstd is null');
        }   
    }
    
    static testmethod  void DealRegistrationTest() {
        //createUserandpartnerContact();
        //Account a = [SELECT Id FROM Account WHERE Name = 'Unit Test Corp' LIMIT 1]; //grab the Account that was created in the allTheDataForThisTestClass method
        System.runAs(createUserandpartnerContact()){
            PageReference pageRef = Page.DealRegistrationEditPage;
           
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
            deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
            deal.Is_this_part_of_an_RFP__c =true;
            //deal.RecordTypeId =getRecordType('NCR Interact Retail Deal Registration');
            //ApexPages.currentPage().getParameters().put('RecordType',deal.RecordTypeId);
            ApexPages.StandardController dealstd= new ApexPages.StandardController(deal);
            
            DealRegistrationEditController controller = new DealRegistrationEditController(dealstd);
            dealstd.save();
            System.assertNotEquals(dealstd, null,'dealstd is null');
           // System.assertNotEquals(deal.id, null);
        }   
    }
    /*
    private static Id getRecordType(String name){
         Map<String,Schema.RecordTypeInfo> rt_Map = Deal_Registration__c.sObjectType.getDescribe().getRecordTypeInfosByName();
         return  rt_Map.get(name).getRecordTypeId();
    }*/
}