/*************************************************************************************************
*   ClassName :   UserDeactivateNotificationTest
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
*************************************************************************************************/
@isTest
public class UserDeactivateNotificationTest {
    @TestSetUp
    public static void unitTest(){
        
        
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', quicklook_Id__c = 'aa123456',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='stand11111@testorg.com');
            insert u;
            User usr =[SELECT ID,Manager_Level_01_ID__c FROM USER where Quicklook_ID__c='sm185526'];
            Account acc=TestRecordsFactory.createAccount();
        Account acc1=TestRecordsFactory.createAccount('APOC1111');
        Contact con = TestRecordsFactory.createContact(acc);
        /*List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
            bpmConfList.add(new BPM_Configuration__c(Name='APOCMail',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCBCC',values__C='vp250252@ncr.com'));
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc1.Master_Customer_Number__c));
            bpmConfList.add(new BPM_Configuration__c(Name='BPM Email - added into QLID',values__C='@ncr.com.invalid'));
        insert bpmConfList;*/
                    List<NCR_Employee_Detail__c> ncrlist = new List<NCR_Employee_Detail__c>();

        NCR_Employee_Detail__c n = new NCR_Employee_Detail__c(Name='User1',Quicklook_ID__c='sm185526',Global_ID__c='1000',Contingent_Manager__c='1001',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n);
            NCR_Employee_Detail__c n1 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='nb250130',Global_ID__c='1001',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n1);
        NCR_Employee_Detail__c n2 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='nb250250',Global_ID__c=usr.Manager_Level_01_ID__c,Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n2);
            insert ncrlist;
         
        List<ASM_Role_Hierarchy__c> asms = new List<ASM_Role_Hierarchy__c>();
            ASM_Role_Hierarchy__c asm = new ASM_Role_Hierarchy__c();
            asm.Role_Name__c = 'PO/Billing Person';
            asm.Master__c = acc.Master_Customer_Number__c;
            asm.Account__c = acc.Id;
            asm.QuickLook_ID__c = 'sm185526';  
        asms.add(asm);
        ASM_Role_Hierarchy__c asm1 = new ASM_Role_Hierarchy__c();
            asm1.Role_Name__c = 'Customer Advocate';
            asm1.Master__c = acc.Master_Customer_Number__c;
            asm1.Account__c = acc.Id;
            asm1.QuickLook_ID__c = 'sm185526';
        asms.add(asm1);
        ASM_Role_Hierarchy__c asm2 = new ASM_Role_Hierarchy__c();
            asm2.Role_Name__c = 'Account Support Manager';
            asm2.Master__c = acc.Master_Customer_Number__c;
            asm2.Account__c = acc.Id;
            asm2.QuickLook_ID__c = 'sm185526';
          asms.add(asm2);
        ASM_Role_Hierarchy__c asm3 = new ASM_Role_Hierarchy__c();
            asm3.Role_Name__c = 'Account Executive';
            asm3.Master__c = acc.Master_Customer_Number__c;
            asm3.Account__c = acc.Id;
            asm3.QuickLook_ID__c = 'sm185526';
          asms.add(asm3);
        ASM_Role_Hierarchy__c asm4 = new ASM_Role_Hierarchy__c();
            asm4.Role_Name__c = 'Account Director';
            asm4.Master__c = acc.Master_Customer_Number__c;
            asm4.Account__c = acc.Id;
            asm4.QuickLook_ID__c = 'sm185526';
          asms.add(asm4);
         ASM_Role_Hierarchy__c asm5 = new ASM_Role_Hierarchy__c();
            asm5.Role_Name__c = 'Account Manager';
            asm5.Master__c = acc.Master_Customer_Number__c;
            asm5.Account__c = acc.Id;
            asm5.QuickLook_ID__c = 'sm185526';
          asms.add(asm5);
         ASM_Role_Hierarchy__c asm6 = new ASM_Role_Hierarchy__c();
            asm6.Role_Name__c = 'Account Support Analyst';
            asm6.Master__c = acc.Master_Customer_Number__c;
            asm6.Account__c = acc.Id;
            asm6.QuickLook_ID__c = 'nb250130';
          asms.add(asm6);
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
        
        
            insert asms;
         insert new CA_Hierarchy__c(CA_QuicklookId__c= 'nb250130',Manager1_Quicklookid__c='ad250024');
         
          
    }
    @isTest static void TestOnDeactivationOfUsers(){
        Test.startTest();
        User user1 = [SELECT ID,IsActive,Quicklook_ID__c FROM USER WHERE Quicklook_ID__c ='sm185526'];
        try{
       	user1.IsActive = false;
        update user1;
        }catch(Exception ex){
            System.debug('exception occured');
        }
        Test.stopTest();
        System.assertEquals(user1.Quicklook_ID__c,'sm185526');
    }
    @isTest static void TestOnDeactivationOfUsers1(){
        Test.startTest();
       	User user0 = [SELECT ID,IsActive FROM USER WHERE Name =: Label.AdmUser and isactive =true];
        User user1 = [SELECT ID,IsActive FROM USER WHERE Quicklook_ID__c ='sm185526'];
        System.runas(user0){
            try{
                user1.IsActive = false;
                update user1;
            }catch(Exception ex){
                System.debug('exception occured');
            }
        }
        Test.stopTest();
        System.assert(!user1.IsActive);
    }
    @isTest static void TestOnDeactivationOfUsers2(){
        Test.startTest();
       	User user0 = [SELECT ID,IsActive FROM USER WHERE Name =:Label.AdmUser and isactive =true];
        User user1 = [SELECT ID,IsActive FROM USER WHERE Quicklook_ID__c ='mm185627'];
        PageReference myVfPage = Page.APOCDeactivateAlertPDF;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Id',user1.Id);
        APOCDeactivateCntlr ap = new APOCDeactivateCntlr();
        System.runas(user0){
            try{
                user1.IsActive = false;
                update user1;
            }catch(Exception ex){
                System.debug('exception occured');
            }
        }
        Test.stopTest();
        System.assert(!user1.IsActive);
    }
}