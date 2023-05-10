@isTest
public class BPMSendAdhocNotificationHandlerTest{
	@isTest
    public static void Test1(){
        Test.StartTest(); 
		BPM_Annuity__C bpmrec = new BPM_Annuity__c(Full_contract_nbr_ch__c ='Test');
        insert bpmrec;
        BPMSendAdhocNotificationHandler bpm = new BPMSendAdhocNotificationHandler(new ApexPages.StandardSetController(new List<BPM_Annuity__c>{bpmrec}));
        BPM_Annuity__C bpm1 = [select SendAdhocMail__c from BPM_Annuity__C where id=:bpmrec.id];
        System.assert(bpm1.id!=null);
        Test.stopTest();
        
    }    
}