@isTest
public class UpdateAccountGlobalUltimateTest {
    static testMethod void runTest(){
        Account acc1 =new Account();
        Account acc2 =new Account();
        Account childAcc =new Account();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.assertEquals(Usr.id!=null, true);
        System.runAs(Usr){
            List<Account> accList = new List<Account>(); 
            acc1.Name='Test Enterprise1';
            acc1.Customer_Number__c = 'Test1';
            acc1.DUNS__c = 'test1234';
            acc1.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc1);
            
            acc2.Name='Test Enterprise2';
            acc2.Customer_Number__c = 'Test2';
            acc2.DUNS__c = 'test2345';
            acc2.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc2);
            insert accList;  
            
            childAcc.Name='Child Enterprise';
            childAcc.Customer_Number__c = 'Test3';
            childAcc.parentId = acc1.Id;
            childAcc.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            insert childAcc;  
        }
        
        List<Hierarchy_Relation__c> hrlist = new List<Hierarchy_Relation__c>(); 
        Hierarchy_Relation__c hr = new Hierarchy_Relation__c(From_Party_Number__c = 'Test1' , To_Party_Number__c = 'Test2',
                                                             Relationship_Name__c = 'Enterprise Parent',IsProcessed__c = false, 
                                                             Relationship_Code__c = 'Enterprise Child of',Relationship_Status__c ='A',
                                                             Start_Date__c = Date.today(),End_Date__c = Date.today().addDays(10));
        Hierarchy_Relation__c hr1 = new Hierarchy_Relation__c(From_Party_Number__c = 'Test1' , To_Party_Number__c = 'Test2',
                                                             Relationship_Name__c = 'Enterprise Parent',IsProcessed__c = false, 
                                                             Relationship_Code__c = 'Enterprise Child of',Relationship_Status__c ='A',
                                                             Start_Date__c = Date.today(),End_Date__c = Date.today().addDays(-10));
        
        Hierarchy_Relation__c hr2 = new Hierarchy_Relation__c(From_Party_Number__c = 'Test3' , To_Party_Number__c = 'test1234',
                                                             Relationship_Name__c = 'Domestic Ultimate',IsProcessed__c = false);
        
        hrlist.add(hr);
        hrlist.add(hr1);
        hrlist.add(hr2);
        insert hrlist;
        
        Test.startTest();
            String TEST_CRON_EXP = '0 25 * * * ?';
        	System.schedule('Account Hierarchy Calculation',TEST_CRON_EXP , new ScheduleAccountGUUpdate());
            new UpdateAccountGlobalUltimate().processRelation();
            new UpdateAccountGlobalUltimate().processRelation();
        Test.stopTest();
    }
    
    
    static testMethod void runTest2() {
        Account acc1 =new Account();
        Account acc2 =new Account();
        Account childAcc =new Account();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        User Usr = [Select Id from User Where Name = 'Soup User'];
         System.assertEquals(Usr.id!=null, true);
        System.runAs(Usr){
            List<Account> accList = new List<Account>(); 
            acc1.Name='Test Enterprise1';
            acc1.Customer_Number__c = 'Test1';
            acc1.DUNS__c = 'test1234';
            acc1.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc1);
            
            acc2.Name='Test Enterprise2';
            acc2.Customer_Number__c = 'Test2';
            acc2.DUNS__c = 'test2345';
            acc2.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc2);
            insert accList;  
            
            childAcc.Name='Child Enterprise';
            childAcc.Customer_Number__c = 'Test3';
            childAcc.parentId = acc1.Id;
            childAcc.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            insert childAcc;  
        }
        
         Test.startTest();
        List<Hierarchy_Relation__c> hrlist = new List<Hierarchy_Relation__c>(); 
        Hierarchy_Relation__c hr = new Hierarchy_Relation__c(From_Party_Number__c = 'Test1' , To_Party_Number__c = 'Test2',
                                                             Relationship_Name__c = 'Enterprise Parent',IsProcessed__c = false, 
                                                             Relationship_Code__c = 'Enterprise Child of',Relationship_Status__c ='A',
                                                             Start_Date__c = Date.today(),End_Date__c = Date.today().addDays(10));
        insert hr;
        
        Database.executeBatch(new HierarchyInitialSetup(), 1);
       
        Test.stopTest();
    }
    static testMethod void runTest3() {
     	Account acc1 =new Account();
        Account acc2 =new Account();
        Account childAcc =new Account();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        User Usr = [Select Id from User Where Name = 'Soup User'];
         System.assertEquals(Usr.id!=null, true);
        
        System.runAs(Usr){
            List<Account> accList = new List<Account>(); 
            acc1.Name='Test Enterprise1';
            acc1.Customer_Number__c = 'Test1';
            acc1.DUNS__c = 'test1234';
            acc1.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc1);
            
            acc2.Name='Test Enterprise2';
            acc2.Customer_Number__c = 'Test2';
            acc2.DUNS__c = 'test2345';
            acc2.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc2);
            insert accList;  
            
            childAcc.Name='Child Enterprise';
            childAcc.Customer_Number__c = 'Test3';
            childAcc.parentId = acc1.Id;
            childAcc.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            insert childAcc;  
        }  
        
         Hierarchy_Relation__c hr1 = new Hierarchy_Relation__c(From_Party_Number__c = 'Test1' , To_Party_Number__c = 'Test2',
                                                             Relationship_Name__c = 'Enterprise Parent',IsProcessed__c = false, 
                                                             Relationship_Code__c = 'Enterprise Child of',Relationship_Status__c ='A',
                                                             Start_Date__c = Date.today(),End_Date__c = Date.today().addDays(-10));
        insert hr1;
        Database.executeBatch(new HierarchyInitialSetup(), 1);
    }
    
     static testMethod void runTest4() {
    	Account acc1 =new Account();
        Account acc2 =new Account();
        Account childAcc =new Account();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        User Usr = [Select Id from User Where Name = 'Soup User'];
         System.assertEquals(Usr.id!=null, true);
        System.runAs(Usr){
            List<Account> accList = new List<Account>(); 
            acc1.Name='Test Enterprise1';
            acc1.Customer_Number__c = 'Test1';
            acc1.DUNS__c = 'test1234';
            acc1.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc1);
            
            acc2.Name='Test Enterprise2';
            acc2.Customer_Number__c = 'Test2';
            acc2.DUNS__c = 'test2345';
            acc2.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            accList.add(acc2);
            insert accList;  
            
            childAcc.Name='Child Enterprise';
            childAcc.Customer_Number__c = 'Test3';
            childAcc.parentId = acc1.Id;
            childAcc.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            insert childAcc;  
        } 
         
        Hierarchy_Relation__c hr2 = new Hierarchy_Relation__c(From_Party_Number__c = 'Test3' , To_Party_Number__c = 'test1234',
                                                             Relationship_Name__c = 'Domestic Ultimate',IsProcessed__c = false);
        
        insert hr2;
        Database.executeBatch(new HierarchyInitialSetup(), 1);
    }
}