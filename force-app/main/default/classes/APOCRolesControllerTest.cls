@isTest
public class APOCRolesControllerTest {
    @TestSetUp
    public static void unitTest(){
         User u = [select id,quicklook_Id__c,Manager_Level_01_ID__c from user where quicklook_Id__c = 'ad250024' limit 1];

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Account accObj = TestRecordsFactory.createAccount();
        Contact con = TestRecordsFactory.createContact(accObj);
        List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
            bpmConfList.add(new BPM_Configuration__c(Name='APOCMail',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCBCC',values__C='vp250252@ncr.com'));
        bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
        bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=accObj.Master_Customer_Number__c));
            bpmConfList.add(new BPM_Configuration__c(Name='BPM Email - added into QLID',values__C='@ncr.com.invalid'));
        bpmConfList.add(new BPM_Configuration__c(Name='BPMProfile',values__C='BPM Partner Community User'));
        insert bpmConfList;
                    List<NCR_Employee_Detail__c> ncrlist = new List<NCR_Employee_Detail__c>();

        NCR_Employee_Detail__c n = new NCR_Employee_Detail__c(Name='User1',Quicklook_ID__c='ad250024',Global_ID__c='1000',Contingent_Manager__c='1001',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n);
            NCR_Employee_Detail__c n1 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='nb250130',Global_ID__c='1001',Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n1);
        NCR_Employee_Detail__c n2 = new NCR_Employee_Detail__c(Name='User2',Quicklook_ID__c='nb250250',Global_ID__c=u.Manager_Level_01_ID__c,Contingent_Manager__c='1002',Employee_type__c='NCR',Inactive__c=false);
            ncrlist.add(n2);
            insert ncrlist;
    }
    
    @isTest
    public static void isTest(){
        
        User u = [select id,quicklook_Id__c from user where quicklook_Id__c = 'ad250024' limit 1];
        
        
        Account accObj = [select id,Master_Customer_Number__c from account limit 1];
        
        
        System.runAs(u){
            ASM_Role_Hierarchy__c asm = new ASM_Role_Hierarchy__c();
            asm.Role_Name__c = 'PO/Billing Person';
            asm.Master__c = accObj.Master_Customer_Number__c;
            asm.QuickLook_ID__c = 'ad250024';
            ASM_Role_Hierarchy__c asm1 = new ASM_Role_Hierarchy__c();
            asm1.Role_Name__c = 'Customer Advocate';
            asm1.Master__c = accObj.Master_Customer_Number__c;
            asm1.QuickLook_ID__c = 'ad250024';
            ASM_Role_Hierarchy__c asm2 = new ASM_Role_Hierarchy__c();
            asm2.Role_Name__c = 'Account Support Manager';
            asm2.Master__c = accObj.Master_Customer_Number__c;
            asm2.QuickLook_ID__c = 'ad250024';
            ASM_Role_Hierarchy__c asm3 = new ASM_Role_Hierarchy__c();
            asm3.Role_Name__c = 'POC_Others';
            asm3.Master__c = accObj.Master_Customer_Number__c;
            asm3.QuickLook_ID__c = 'ad250024';
            APOCRolesController.getAPOCList('');
            APOCRolesController.getAllRoleNames();
            APOCRolesController.getListViews();
            Set<String> masterSet = new Set<String>{accObj.Master_Customer_Number__c};
                APOCRolesController.fetchRolesWithMCN(JSON.serialize(masterSet),null);
            List<ASM_Role_Hierarchy__c> asmList = new List<ASM_Role_Hierarchy__c>();
            asmList.add(asm);
            asmList.add(asm1);
            asmList.add(asm2);
            asmList.add(asm3);
            APOCRolesController.editRecord(asmList);
            APOCRolesController.getAPOCList('');
            APOCRolesController.getAPOCRcrd(accObj.Id, true);
            APOCRolesController.getAPOCRcrd(accObj.Id, false);
            APOCRolesController.getAPOCList(accObj.Master_Customer_Number__c);
            List<ASM_Role_Hierarchy__c> asmList1 =[Select id,account__c from ASM_Role_Hierarchy__c where master__c = :accObj.Master_Customer_Number__c];
            List<ASM_Role_Hierarchy__c> asmList2 =[Select id,account__c,role_user_name__c,role_name__C from ASM_Role_Hierarchy__c ];   

           //	System.debug('asmList1'+asmList1[0].account__c);
            //System.debug('asmList2'+asmList2[0].role_user_name__c);
            System.debug('asmList2'+asmList2);
            APOCRolesController.editRecordBulkData(asmList1,asmList);   
            APOCRolesController.getUserData('ad250024', null, null);
            APOCRolesController.getselRec(accObj.Master_Customer_Number__c);
            System.assert(accObj.Master_Customer_Number__c!=null);
        }
    }
}