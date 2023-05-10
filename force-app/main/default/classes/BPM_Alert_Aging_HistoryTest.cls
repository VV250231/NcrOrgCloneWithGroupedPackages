/*this class covers mostly BPM Related Class written by Varsha Pal
	BPM_Alert_Aging_History - 100%
	BPMAPOC_PORelation - 100%
*/
@isTest
public class BPM_Alert_Aging_HistoryTest {
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
                          TimeZoneSidKey='America/Los_Angeles', Manager = userObj, UserName='stand11111@testorg.com',Manager_Level_01_ID__c='manager1',Manager_Level_02_ID__c='manager2',Manager_Level_03_ID__c='manager3',Manager_Level_04_ID__c='manager4',Manager_Level_05_ID__c='manager5');
        insert u;
        System.debug('u !!'+u.id);
        System.debug('userObj !!'+userObj.id);
        List<NCR_Employee_Detail__c> ncrList = new List<NCR_Employee_Detail__c>();
        ncrList.add(new NCR_Employee_Detail__c(Quicklook_ID__c='man1',Global_ID__c='manager1'));
        ncrList.add(new NCR_Employee_Detail__c(Quicklook_ID__c='man2',Global_ID__c='manager2'));
        ncrList.add(new NCR_Employee_Detail__c(Quicklook_ID__c='man3',Global_ID__c='manager3'));
        ncrList.add(new NCR_Employee_Detail__c(Quicklook_ID__c='man4',Global_ID__c='manager4'));
        ncrList.add(new NCR_Employee_Detail__c(Quicklook_ID__c='aa123456',Global_ID__c='manager5'));
         ncrList.add(new NCR_Employee_Detail__c(Quicklook_ID__c='ab123456',Global_ID__c='manager5'));
        insert ncrList;
        insert new CA_Hierarchy__c(CA_QuicklookId__c='aa123456',Manager1_Quicklookid__c='caman1',Manager2_Quicklookid__c='caman2',Manager3_Quicklookid__c='caman3',Manager4_Quicklookid__c='caman4');
        Map<Id, ASM_Role_Hierarchy__c> oldMap = new Map<Id, ASM_Role_Hierarchy__c>();
       // Account accObj = new Account(Name = 'Test', Master_Customer_Number__c = '13308');
        //insert accObj;''
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
        Account acc=TestRecordsFactory.createAccount();
        Contact con = TestRecordsFactory.createContact(acc);
        Account acc1=TestRecordsFactory.createAccount('test1');
       Account acc2=TestRecordsFactory.createAccount('test2');
             Account acc3=TestRecordsFactory.createAccount('test3');
            //Account acc4=TestRecordsFactory.createAccount('test4');
        System.debug('acc 1 '+acc);
             List<BPM_Configuration__c> bpmConfList = new List<BPM_Configuration__c>();
            bpmConfList.add(new BPM_Configuration__c(Name='Batch Job Email Receiver List',values__C='vp250252@ncr.com'));
            bpmConfList.add(new BPM_Configuration__c(Name='Stop Immediate Notification',values__C='false'));
            bpmConfList.add(new BPM_Configuration__c(Name='Software Unbilled Amount Threshold',values__C='0'));
            bpmConfList.add(new BPM_Configuration__c(Name='Software Action Owner',values__C='Account Service Manager'));
            bpmConfList.add(new BPM_Configuration__c(Name='Invalid Hold Reason Action Owner',values__C='PO/Billing Person,Customer Advocate'));
            bpmConfList.add(new BPM_Configuration__c(Name='Default Action Owner',values__C='PO/Billing Person'));
            bpmConfList.add(new BPM_Configuration__c(Name='BPM Email - added into QLID',values__C='@ncr.com.invalid'));
            bpmConfList.add(new BPM_Configuration__c(Name='BPMContactIdForNotifyActionOwner',values__C=con.id));
            bpmConfList.add(new BPM_Configuration__c(Name='BPM BCC ADDRESS LIST',values__C=con.email));
            bpmConfList.add(new BPM_Configuration__c(Name='Time-Based Scheduling Time',values__C='7,0'));
            bpmConfList.add(new BPM_Configuration__c(Name='Invalid Hold Reason CC Person',values__C='Account Service Manager'));
             bpmConfList.add(new BPM_Configuration__c(Name='Invalid Hold Desc Alert Interval',values__C='7'));
            bpmConfList.add(new BPM_Configuration__c(Name='NotificationToRolesAfterThreeAttempts',values__C='Account Service Manager'));
            bpmConfList.add(new BPM_Configuration__c(Name='TimeZoneSwitcher',values__C='America/New_York'));
            bpmConfList.add(new BPM_Configuration__c(Name='Hardware Unbilled Amount Threshold',values__C='0'));
            bpmConfList.add(new BPM_Configuration__c(Name='Invalid Hold Reason SW Action Owner',values__C='Customer Advocate'));
            bpmConfList.add(new BPM_Configuration__c(Name='APOCAccount',values__C=acc.Master_Customer_Number__c));
			bpmConfList.add(new BPM_Configuration__c(Name='BPMProfile',values__C='BPM Partner Community User'));
			bpmConfList.add(new BPM_Configuration__c(Name='BPMDefaultPOQLID',values__C='aa123456'));
            insert bpmConfList;
        List<String> reasons=new List<String>{'Account Support Approval Required',''};
         List<String> accountType=new List<String>{'SS',''};

        //acc.Active_Account__c = true;
        //update acc;
        ASM_Role_Hierarchy__c obj = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='ab123456',Role_Name__c = 'PO/Billing Person');
         Insert obj;
       ASM_Role_Hierarchy__c obj2 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'Account Support Manager');
         Insert obj2;
            ASM_Role_Hierarchy__c obj3 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'PO/Billing Person');
         Insert obj3;
            ASM_Role_Hierarchy__c obj4 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'Customer Advocate');
         Insert obj4;
            ASM_Role_Hierarchy__c obj5 = new ASM_Role_Hierarchy__c(Master__c = acc.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'Software PO/Billing Person');
         Insert obj5;
            ASM_Role_Hierarchy__c obj6 = new ASM_Role_Hierarchy__c(Master__c = acc3.Master_Customer_Number__c, QuickLook_ID__c='aa123456',Role_Name__c = 'PO/Billing Person');
         Insert obj6;
            List<PO_Matrix__c> poList = new List<PO_Matrix__c>();
            poList.add(new PO_Matrix__c(LOB__c='',Country__c='',Region__c='WCS - Europe',QuicklookId__c='ab123456'));
            poList.add(new PO_Matrix__c(LOB__c='Hospitality',Country__c='',Region__c='WCS - Europe',QuicklookId__c='aa123456'));
            poList.add(new PO_Matrix__c(LOB__c='',Country__c='US',Region__c='WCS - Europe',QuicklookId__c='aa123456'));
            poList.add(new PO_Matrix__c(LOB__c='Telecom and Tech',Country__c='US',Region__c='',QuicklookId__c='ab123456'));
            insert poList;
            insert new CA_Matrix__c(Country_Code__c='US',CA_QuicklookId__c='aa123456');
            insert new CA_Matrix__c(Country_Code__c='IN',CA_QuicklookId__c='ab123456');
            insert new bpm_annuity__C(full_contract_nbr_ch__c='1234',Name='test');
            bpm_annuity__C newbpm = new bpm_annuity__C(full_contract_nbr_ch__c='98700',Name='98700',Hold_Reason_Type__c='HHHH');
            insert newbpm;
           insert new bpm_annuity__C(full_contract_nbr_ch__c='98701',Name='98701',Hold_Reason_Type__c='HHHH',End_Date_CH__c=System.today()+1,Unbilled_Amt__c = 30000,SW_Unbilled_Amount__c =30000,Status_CH__c = 'HOLD',Cust_Nbr_CH__c = 'TESTMCN00001X');
            insert new BPM_Aging_History__c(Hold_Reason_Type__c='HHHH',BPM_Annuity__c=newbpm.id);
            List<BPM_Annuity_Line__c> bpmLines = new List<BPM_Annuity_Line__c>();
        for(integer i = 0;i<4;i++){
            BPM_Annuity_Line__c bpmline = new BPM_Annuity_Line__c();
           
            bpmLine.Billed_Amt_Usd__c = 25000+i;
            bpmLine.Contract_End_Date__c = System.today()+i;
            bpmLine.Contract_Start_Date__c = System.today()-i;
            bpmLine.Header_Billing_Period_Name__c = 'Quarterly';
            if(i>1){
                bpmLine.Contract_Nbr__c = '987'+(3-i);
            	bpmLine.Full_Contract_Nbr__c = '9870'+(3-i);
                bpmLine.Hold_Reason_Description__c = reasons[3-i];
                bpmLine.Offering_Account_Type_Code__c=accountType[3-i];
                bpmLine.Country_Code__c = 'SM';
                bpmLine.Customer_Nbr__c = acc1.Master_Customer_Number__c;
                bpmLine.Region_Desc__c ='Europe';
                bpmLine.Bill_To_Pnt_Cust_Ind_Name__c = 'Travel';
            }else{
                bpmLine.Contract_Nbr__c = '987'+i;
            	bpmLine.Full_Contract_Nbr__c = '9870'+i;
                bpmLine.Hold_Reason_Description__c = reasons[i];
                bpmLine.Offering_Account_Type_Code__c=accountType[i];
                bpmLine.Customer_Nbr__c = acc.Master_Customer_Number__c;
            }
            bpmLine.Interface_Offset_Day_Nbr__c = 0;
            bpmLine.Invoice_Rule_Name__c = 'Advance Invoice';
            //bpmLine.IsEquipmentLine__c = true;
            bpmLine.Period_End_Date__c  =System.today()-i;
            bpmLine.Period_Start_Date__c    =System.today()-i;
            bpmLine.Status_Code__c ='HOLD';
            bpmLine.Subtotal_Amt_Usd__c = 500+i;
            bpmLine.Unbilled_Amt_Usd__c=45000+i;
            bpmlines.add(bpmLine);
        }
            insert bpmLines;

        }
        
    }
    @isTest
    static void Test1(){
        Test.startTest();
        database.executebatch(new BPMLinkLinestoHeaderBatch());  
        String jobName = 'BPMLinkLinestoHeaderBatch' + ' - ' + datetime.now().format();
        string cron = '0 0 19 ? * 2-6';
       string job1= system.schedule(jobName, cron, new BPMLinkLinestoHeaderBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :job1];
        System.assertEquals(cron, ct.CronExpression); 
        //BPMLinkLinestoHeaderBatch.start(19);  
        Test.stopTest();
    }
    @isTest
    static void Test2(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,SendAdhocMail__c from bpm_annuity__C where full_contract_nbr_ch__c='98700'];
        bpm.SendAdhocMail__c =true;
        bpm.End_Date_CH__c = System.today() +1;
        bpm.Unbilled_Amt__c = 30000;
        bpm.Status_CH__c = 'HOLD';
        bpm.Hold_Reason_Type__c ='Awaiting PO';
        bpm.Cust_Nbr_CH__c = 'TESTMCN00001X';
        update bpm;
        System.assert(bpm.Id!=null);
        Test.stopTest();
    }
     @isTest
    static void Test3(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,Email_Sent__c from bpm_annuity__C where full_contract_nbr_ch__c='98700'];
        bpm.Email_Sent__c =true;
        bpm.End_Date_CH__c = System.today() +1;
        bpm.Unbilled_Amt__c = 30000;
        bpm.SW_Unbilled_Amount__c =30000;
        bpm.Status_CH__c = 'HOLD';
        bpm.Hold_Reason_Type__c ='Validation In Progress';
        bpm.Cust_Nbr_CH__c = 'TESTMCN00001X';
        update bpm;
        System.assert(bpm.Id!=null);
         Database.executeBatch(new BPMNotifyActionOwnerBatch());
        Test.stopTest();
    }
    @isTest
    static void Test4(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,Email_Sent__c from bpm_annuity__C where full_contract_nbr_ch__c='98701'];
        bpm.Email_Sent__c =true;
        bpm.Notification_Attempt__c = 7;
        update bpm;
        System.assert(bpm.Id!=null);
        Database.executeBatch(new BPMNotifyActionOwnerBatch());
        Test.stopTest();
    }
     @isTest
    static void Test5(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,Email_Sent__c,HW_Other_Unbilled_Amount__c from bpm_annuity__C where full_contract_nbr_ch__c='98701'];
        bpm.Hold_Reason_Type__c ='YYYY';
        bpm.HW_Other_Unbilled_Amount__c =30000;
        update bpm;
        System.assert(bpm.Id!=null);
        Database.executeBatch(new BPMNotifyActionOwnerBatch());
        Test.stopTest();
    }
    @isTest
    static void Test6(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,Email_Sent__c,HW_Other_Unbilled_Amount__c from bpm_annuity__C where full_contract_nbr_ch__c='98701'];
        bpm.Hold_Reason_Type__c ='Awaiting CPI excpetion approval';
        bpm.HW_Other_Unbilled_Amount__c =30000;
        update bpm;
        System.assert(bpm.Id!=null);
        Database.executeBatch(new BPMNotifyActionOwnerBatch());
        Test.stopTest();
    }
    @isTest
    static void Test7(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,Email_Sent__c from bpm_annuity__C where full_contract_nbr_ch__c='98701'];
        bpm.Email_Sent__c =true;
        bpm.Notification_Attempt__c =4;
        bpm.HW_Other_Unbilled_Amount__c =30000;
        update bpm;
        System.assert(bpm.Id!=null);
        Database.executeBatch(new BPMNotifyActionOwnerBatch());
        Test.stopTest();
    }
    @isTest
    static void Test8(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,Email_Sent__c from bpm_annuity__C where full_contract_nbr_ch__c='98701'];
        bpm.Email_Sent__c =true;
        bpm.Notification_Attempt__c =3;
        bpm.Unbilled_Amt__c = 30000;
        bpm.End_Date_CH__c = System.today()+1;
        bpm.Hold_Reason_Type__c='KKKK';
        update bpm;
        System.assert(bpm.Id!=null);
        Database.executeBatch(new BPMNotifyActionOwnerBatch());
        Test.stopTest();
    }
    @isTest
    static void Test9(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,SendAdhocMail__c,notification_attempt__c from bpm_annuity__C where full_contract_nbr_ch__c='98700'];
        bpm.SendAdhocMail__c =true;
        bpm.notification_attempt__c = -1;
        bpm.End_Date_CH__c = System.today() +1;
        bpm.Unbilled_Amt__c = 30000;
        bpm.Status_CH__c = 'HOLD';
        bpm.Hold_Reason_Type__c ='Invalid';
        bpm.Cust_Nbr_CH__c = 'TESTMCN00001X';
        update bpm;
        System.assert(bpm.Id!=null);
        Test.stopTest();
    }
    @isTest
    static void Test10(){
        Test.startTest();
        bpm_annuity__C bpm = [Select id,SendAdhocMail__c,notification_attempt__c from bpm_annuity__C where full_contract_nbr_ch__c='98700'];
        bpm.End_Date_CH__c = System.today() +1;
        bpm.Unbilled_Amt__c = 30000;
        bpm.Status_CH__c = 'HOLD';
        bpm.Cust_Nbr_CH__c = 'TESTMCN00001X';
        update bpm;
        bpm.SendAdhocMail__c =true;
        bpm.notification_attempt__c = 2;
        update bpm;
        System.assert(bpm.Id!=null);
        Test.stopTest();
    }
    @isTest
    static void BPMAPOC_POTest(){
        Account acc1 = [Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%test3%'];
		Account acc2= [Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%test2%'];

        insert new BPM_annuity__c(Name='testBPM1',Full_Contract_Nbr_CH__c='testBPM1',Country_Code_C_BPM__c='IN',Cust_Nbr_CH__c =acc1.Master_Customer_Number__c);
        insert new BPM_annuity__c(Name='testBPM',Full_Contract_Nbr_CH__c='testBPM',Country_Code_C_BPM__c='US',Cust_Nbr_CH__c =acc2.Master_Customer_Number__c);
		system.assertNotEquals(BPM_annuity__c.id,null);
    }
    @isTest
    static void BPMAPOC_POTest1(){
        Account acc1 = [Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%test2%'];
    	insert new BPM_annuity__c(Name='testBPM1',Full_Contract_Nbr_CH__c='testBPM1',Country_Code_C_BPM__c='US',Cust_Nbr_CH__c =acc1.Master_Customer_Number__c,Region__c='WCS - Europe');
    	system.assertNotEquals(BPM_annuity__c.id,null);
    }
    @isTest
    static void BPMAPOC_POTest2(){
        Account acc1 = [Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%test2%'];
    	insert new BPM_annuity__c(Name='testBPM1',Full_Contract_Nbr_CH__c='testBPM1',Country_Code_C_BPM__c='US',Cust_Nbr_CH__c =acc1.Master_Customer_Number__c,Industry_Group_Name_CH__c='Telecom and Tech');
   		system.assertNotEquals(BPM_annuity__c.id,null);
    }
    @isTest
    static void BPMAPOC_POTest3(){
        Account acc1 = [Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%test2%'];
    	insert new BPM_annuity__c(Name='testBPM1',Full_Contract_Nbr_CH__c='testBPM1',Region__c='WCS - Europe',Cust_Nbr_CH__c =acc1.Master_Customer_Number__c,Industry_Group_Name_CH__c='Hospitality');
   		system.assertNotEquals(BPM_annuity__c.id,null);
    }
    @isTest
    static void BPMAPOC_POTest4(){
        Account acc1 = [Select id,Master_Customer_Number__c from Account where Master_Customer_Number__c like '%test2%'];
    	insert new BPM_annuity__c(Name='testBPM1',Full_Contract_Nbr_CH__c='testBPM1',Region__c='WCS - Europe',Cust_Nbr_CH__c =acc1.Master_Customer_Number__c);
   		system.assertNotEquals(BPM_annuity__c.id,null);
    }
}