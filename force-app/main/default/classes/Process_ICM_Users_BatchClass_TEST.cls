@isTest
public class Process_ICM_Users_BatchClass_TEST {
    @isTest
    private static void UnitTestMethod(){
        // list<user> userList  = [select id, ICM_User__c,Quicklook_ID__c from user]; 
        list <ICM_User__c> icmList = new  list <ICM_User__c>();
        
        For(integer i= 0;i<3;i++){
            
            ICM_User__c u = new ICM_User__c();
            u.Quicklook_ID__c = 'sj18509'+i;
            u.Data_Load_Date__c = system.today();
            icmList.add(u);
        }
        
        insert icmList;
        
        Test.startTest();
        Process_ICM_Users_BatchClass uca = new Process_ICM_Users_BatchClass();
        Id batchId = Database.executeBatch(uca,200);
        Test.stopTest();
        user uObj =[select ICM_User__c from user where Quicklook_ID__c='sj185091' ];
        System.assert(uObj.ICM_User__c==true);
    }
    @isTest
     private static void UnitTestMethod2(){
        // list<user> userList  = [select id, ICM_User__c,Quicklook_ID__c from user]; 
        list <ICM_User__c> icmList = new  list <ICM_User__c>();
        
        For(integer i= 0;i<3;i++){
            
            ICM_User__c u = new ICM_User__c();
            u.Quicklook_ID__c = null;
            u.Data_Load_Date__c = system.today();
            icmList.add(u);
        }
        
        insert icmList;
        
        Test.startTest();
        Process_ICM_Users_BatchClass uca = new Process_ICM_Users_BatchClass();
        Id batchId = Database.executeBatch(uca,200);
        Test.stopTest();
        user uObj =[select ICM_User__c from user where Quicklook_ID__c=null limit 1 ];
        System.assert(uObj.ICM_User__c==false);
    }
    
     @isTest
     private static void UnitTestMethod3(){
        // list<user> userList  = [select id, ICM_User__c,Quicklook_ID__c from user]; 
        list <ICM_User__c> icmList = new  list <ICM_User__c>();
        
        For(integer i= 0;i<3;i++){
            
            ICM_User__c u = new ICM_User__c();
            u.Quicklook_ID__c = null;
            u.Data_Load_Date__c = system.today()-1;
            icmList.add(u);
        }
        
        insert icmList;
        
        Test.startTest();
        Process_ICM_Users_BatchClass uca = new Process_ICM_Users_BatchClass();
        Id batchId = Database.executeBatch(uca,200);
        Test.stopTest();
        user uObj =[select ICM_User__c from user where Quicklook_ID__c=null limit 1 ];
        System.assert(uObj.ICM_User__c==false);
    }
}