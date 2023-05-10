@isTest
private class EngineerInlineMessageControllerTest {

    static testMethod void testEngineerInlineMessageController() {
       	Engineers__C eng = new Engineers__C();
    	eng.First_name__c ='ABC';
	    eng.Last_Name__c ='XYZ';
	    eng.Active_Engineer__c =true;
	    eng.Email_Address__c ='xyz@ncr.com';
	    eng.City__c='noWhere';
	    eng.Type_of_Portal_Access__c ='Portal Access';
	    eng.Status__c = 'Created';
	    insert eng;
	    
	    Attachment__c obj1 = new Attachment__c();
        obj1.Engineer_Attachment_Type__c='IPP Order Form';
        obj1.Engineers__c =eng.id;
        insert obj1;
                   System.assertNotEquals(obj1, null,'Attachment__c should not be null');

        EngineerInlineMessageController controller = new EngineerInlineMessageController(new ApexPages.StandardController(eng));
        
    }
}