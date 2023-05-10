public class BPMSendAdhocNotificationHandler {
    ApexPages.StandardSetController setCon;
	public BPM_Annuity__c bpm{get; set;}
    public BPMSendAdhocNotificationHandler(ApexPages.StandardSetController controller) {
        setCon = controller;
        bpm = (BPM_Annuity__c)controller.getRecord();
        bpm.SendAdhocMail__c = true;
    }
}