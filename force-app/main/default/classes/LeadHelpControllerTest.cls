@isTest
private class LeadHelpControllerTest{

    static testMethod void myTest() {
        Lead l = TestRecordsFactory.createLead();
        
        LeadHelpController.getLeadContacts('test');
        LeadHelpController.validateLeadOnLoadHelp(l.Id);
        LeadHelpController.updateUserSetting();
        Lead_Help_Access__c leadHelpObj = [select Disabled_Help_Box__c from Lead_Help_Access__c where User__c=:Userinfo.getUserId()];
        System.assert(leadHelpObj.Disabled_Help_Box__c==true);
    }
}