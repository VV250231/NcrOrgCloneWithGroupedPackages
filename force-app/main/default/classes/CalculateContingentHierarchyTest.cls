@isTest
private class CalculateContingentHierarchyTest {
    @TestSetUp
    public static void unitTest(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];  
        
        User userObj = new User(Alias = 'commuser', Email='standarduser1@testorg.com', quicklook_Id__c = 'ab123456',
                                EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='stand11122@testorg.com');
        insert userObj;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', quicklook_Id__c = 'aa123456',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', Manager = userObj, UserName='stand11111@testorg.com');
        insert u;
        System.debug('u !!'+u.id);
        System.debug('userObj !!'+userObj.id);
        Account acc = new Account();
        User Usr1 = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr1){
            acc=TestRecordsFactory.createAccount('abc');
        }
        Account acc1=TestRecordsFactory.createAccount('acctest');
        Contact con = TestRecordsFactory.createContact(acc);
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
        bpmConfList.add(new BPM_Configuration__c(Name='APOCMail',values__C='vp250252@ncr.com'));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCBCC',values__C='vp250252@ncr.com'));
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
        bpmConfList.add(new BPM_Configuration__c(Name='BPM Email - added into QLID',values__C='@ncr.com.invalid'));
        bpmConfList.add(new BPM_Configuration__c(Name='BPMProfile',values__C='BPM Partner Community User'));
        // bpmConfList.add(new BPM_Configuration__c(Name='excProfileId',values__C='00e70000001NyoaAAC'));
        bpmConfList.add(new BPM_Configuration__c(Name='excProfileId',values__C=NSCCommonInfoUtil.getIdOf('iPaas_Administration_Profile_Id')));
        bpmConfList.add(new BPM_Configuration__c(Name='BPMDefaultPOQLID',values__C='ob230024'));
        
        insert bpmConfList;
        
        Map<Id, ASM_Role_Hierarchy__c> oldMap = new Map<Id, ASM_Role_Hierarchy__c>();
        // Account accObj = new Account(Name = 'Test', Master_Customer_Number__c = '13308');
        //insert accObj;''
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
            //Account acc=TestRecordsFactory.createAccount('abc');
            System.debug('acc 1 '+acc);
            //acc.Active_Account__c = true;
            //update acc;
            
            List<NCR_Employee_Detail__c> ncrlist = new List<NCR_Employee_Detail__c>();
            NCR_Employee_Detail__c n = new NCR_Employee_Detail__c(Name='User1',Quicklook_ID__c='ab123456',Global_ID__c='1000',Contingent_Manager__c='1001',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n);
            NCR_Employee_Detail__c n1 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='ac123456',Global_ID__c='1001',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n1);
            NCR_Employee_Detail__c n2 = new NCR_Employee_Detail__c(Name='User3',Quicklook_ID__c='ad123456',Global_ID__c='1002',Contingent_Manager__c='1003',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n2);
            NCR_Employee_Detail__c n3 = new NCR_Employee_Detail__c(Name='User4',Quicklook_ID__c='ae123456',Global_ID__c='1003',Contingent_Manager__c='1004',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n3);
            NCR_Employee_Detail__c n4 = new NCR_Employee_Detail__c(Name='User5',Quicklook_ID__c='aa123456',Global_ID__c='1004',Manager_Global_ID__c='1005',Employee_type__c='NCR',Inactive__c=false);        
            ncrlist.add(n4);
            NCR_Employee_Detail__c n5 = new NCR_Employee_Detail__c(Name='User6',Quicklook_ID__c='af123456',Global_ID__c='1005',Manager_Global_ID__c='1006',Employee_type__c='NCR',Inactive__c=false);        
            ncrlist.add(n5);
            NCR_Employee_Detail__c n6 = new NCR_Employee_Detail__c(Name='User7',Quicklook_ID__c='ag123456',Global_ID__c='1006',Manager_Global_ID__c='1007',Employee_type__c='NCR',Inactive__c=false);        
            ncrlist.add(n6);
            /*NCR_Employee_Detail__c n7 = new NCR_Employee_Detail__c(Name='User8',Quicklook_ID__c='ah123456',Global_ID__c='1007',Employee_type__c='NCR',Inactive__c=false);        
ncrlist.add(n7);*/
            insert ncrlist;
            ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ab123456',Role_Name__c = 'PO/Billing Person');
            Insert obj;
            ASM_Role_Hierarchy__c obj2 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'Customer Advocate');
            Insert obj2;  
            insert new CA_Hierarchy__c(CA_QuicklookId__c='aa123456');
            insert new BPM_Configuration__c(Name='CAHierarchyJobReciever',values__c='vp250252@ncr.com');
        }
    }
    
    @isTest
    static void Test1(){
        account acc = [select id,name,Active_Account__c,Master_Customer_Number__c from Account limit 1];
        system.assertNotEquals(acc, null);
        System.debug('acc '+acc);
        Test.startTest();
        
        ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ab123456',Role_Name__c = 'Customer Advocate');
        APOC_MassUpdateAllRolesHandler.isInsertFromUI = true; 
        Insert obj;
        String cronExpr = '0 0 0 15 8 ? 2022';
        CalculateContingentHierarchy abs= new CalculateContingentHierarchy();
        String jobId = System.schedule('TestJobNam', cronExpr, abs);
        abs.execute(null);
        //Database.executeBatch(new CalculateContingentHierarchy());
        Test.stopTest();
        CA_Hierarchy__c caObj = [select id from CA_Hierarchy__c where CA_QuicklookId__c=:obj.QuickLook_ID__c limit 1];
        System.assert(caObj.Id!=null);
    }
    
    @isTest
    static void Test2(){
        account acc = [select id,name,Active_Account__c,Master_Customer_Number__c from Account limit 1];
        System.debug('acc '+acc);
        Test.startTest();
        List<NCR_Employee_Detail__c> ncrList = [select id from NCR_Employee_Detail__c where Quicklook_ID__c IN ('ad123456','ac123456','af123456','ag123456') ];
        system.assertNotEquals(ncrList, null);
        delete ncrList;
        ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ab123456',Role_Name__c = 'Customer Advocate');
        APOC_MassUpdateAllRolesHandler.isInsertFromUI = true; 
        Insert obj;
        String cronExpr = '0 0 0 15 8 ? 2022'; 
        CalculateContingentHierarchy abs= new CalculateContingentHierarchy();
        String jobId = System.schedule('TestJobNam', cronExpr, abs);
        abs.execute(null);
        //Database.executeBatch(new CalculateContingentHierarchy());
        Test.stopTest();
         CA_Hierarchy__c caObj = [select id from CA_Hierarchy__c where CA_QuicklookId__c=:obj.QuickLook_ID__c limit 1];
        System.assert(caObj.Id!=null);
    }
    
}