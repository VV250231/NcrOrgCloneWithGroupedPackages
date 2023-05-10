@isTest
public class BPM_Alert_Aging_History_handlerTest {
    @testSetup 
    public static void createTestData(){
        List<BPM_Annuity__c> listBPM = new List<BPM_Annuity__c>();
        for(integer i =0 ; i<=200; i++){
            BPM_Annuity__c obj = new BPM_Annuity__c();
            obj.name = 'bulk insertion '+i;
            obj.CA_Customer_Approval_Alert__c = true;
            obj.CA_Expiration_Alert__c  = true; 
            obj.CA_Hold_Alert__c = true;
            obj.CA_No_PO_Alert__c = true;
            obj.InterfaceDateExpiredAlert__c = true;
            obj.Start_Date_CH__c = System.Today()+1;
            obj.Status_CH__c = 'Hold';
            obj.SendAdhocMail__c = true;
            listBPM.add(obj);
        }
        insert listBPM;
    }
    
    
    public testMethod static void test1(){
        list<BPM_Configuration__c> bmpConfigList = new list<BPM_Configuration__c>();
        BPM_Configuration__c bpmconfig  = new BPM_Configuration__c(Name='Stop Immediate Notification',values__C='false');
        bmpConfigList.add(bpmconfig);
        BPM_Configuration__c bpmconfig1 = new BPM_Configuration__c(Name='Software Action Owner',values__C='test1,test2');
        bmpConfigList.add(bpmconfig1);
        BPM_Configuration__c bpmconfig2 = new BPM_Configuration__c(Name='Default Action Owner',values__C='test1,test2');
        bmpConfigList.add(bpmconfig2);
        BPM_Configuration__c bpmconfig3 = new BPM_Configuration__c(Name='Invalid Hold Reason Action Owner',values__C='test1,test2');
        bmpConfigList.add(bpmconfig3);
        BPM_Configuration__c bpmconfig4 = new BPM_Configuration__c(Name='Invalid Hold Reason SW Action Owner',values__C='test1,test2');
        bmpConfigList.add(bpmconfig4);
        BPM_Configuration__c bpmconfig5 = new BPM_Configuration__c(Name='Software Unbilled Amount Threshold',values__C='1.1');
        bmpConfigList.add(bpmconfig5);
        BPM_Configuration__c bpmconfig6 = new BPM_Configuration__c(Name='Hardware Unbilled Amount Threshold',values__C='1.1');
        bmpConfigList.add(bpmconfig6);	
        BPM_Configuration__c bpmconfig7 = new BPM_Configuration__c(Name='Time-Based Scheduling Time',values__C='1.1');
        bmpConfigList.add(bpmconfig7);	
        BPM_Configuration__c bpmconfig8 = new BPM_Configuration__c(Name='TimeZoneSwitcher',values__C='1.1');
        bmpConfigList.add(bpmconfig8);	
        BPM_Configuration__c bpmconfig9 = new BPM_Configuration__c(Name='BPM BCC ADDRESS LIST',values__C='test1,test2');
        bmpConfigList.add(bpmconfig9);	
        
        insert bmpConfigList;
        List<BPM_Annuity__c> listBPM = [select id,CA_Customer_Approval_Alert__c,
                                        CA_Expiration_Alert__c,
                                        CA_Hold_Alert__c,
                                        CA_No_PO_Alert__c,
                                        InterfaceDateExpiredAlert__c from BPM_Annuity__c];
        
        for(BPM_Annuity__c obj : listBPM){
            obj.CA_Customer_Approval_Alert__c = false;
            obj.CA_Expiration_Alert__c = false;
            obj.CA_No_PO_Alert__c =false;
            obj.CA_Hold_Alert__c = false;
            obj.InterfaceDateExpiredAlert__c = false;
            obj.Industry_Group_Name_CH__c='telecom and tech';
            obj.Unbilled_Amt__c = 26000;
            obj.Hold_Reason_Type__c='true';
           
        }
        update listBPM;
        BPM_Annuity__c bpmObj = [select id,Contract_On_Hold__c,BPMWorkflowCriteriaForHoldReason__c from BPM_Annuity__c where id=:listBPM[0].id];
        system.debug('BPMWorkflowCriteriaForHoldReason__c=='+bpmObj.BPMWorkflowCriteriaForHoldReason__c);
        System.assert(!bpmObj.Contract_On_Hold__c);
    }
}