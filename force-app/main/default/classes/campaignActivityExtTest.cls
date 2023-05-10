@isTest
private class campaignActivityExtTest{

    static testmethod void testCampActExt(){
    
        //insert campaign Actvity
        Campaign_Activity__c campAct = new Campaign_Activity__c();
        campAct.Status__c = 'Open';
        insert campAct ;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(campAct);
        campaignActivityExt testCampAct = new campaignActivityExt(sc);
        
        testCampAct.saveWithOldStatus();
        Campaign_Activity__c campObj = [select Status__c from Campaign_Activity__c where id=:campAct.id];
        System.assert(campObj.Status__c =='Open');
    }
}