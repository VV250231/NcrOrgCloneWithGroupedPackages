@isTest
private class AAEnablementHomeControllerTest {
    
    @istest static void AAEnablementHomeControllerTest() {

        //tests the email templates and asserts that they have been inserted
        AAEnablementHomeController aaHomePage = new AAEnablementHomeController();

        aaHomePage.createTemplates();
        
        List<sbaa__EmailTemplate__c> queriedEmailTemplates = [  SELECT Id, Name, sbaa__TemplateId__c
                                                                FROM sbaa__EmailTemplate__c
                                                                ORDER BY Name
                                                                ];

        System.debug('queriedEmailTemplates results: ' + queriedEmailTemplates);

        System.assert(queriedEmailTemplates.get(0).Name == 'Approval - Quote Approved Notification');


        //-------------------------------------
        //tests the record types and compares against the custom setting
        aaHomePage.updateCustomSetting();

        SBAA_Enablement_IDs__c recordTypeCustomSetting = SBAA_Enablement_IDs__c.getOrgDefaults();

        System.debug('recordTypeCustomSetting results: ' + recordTypeCustomSetting);

        System.assert(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Approved Quote').getRecordTypeId() == recordTypeCustomSetting.Approved_Quote_RT__c);


        //-------------------------------------
        //tests the email document ID
        aaHomePage.updateEmailLogoId();

        recordTypeCustomSetting = SBAA_Enablement_IDs__c.getOrgDefaults();

        System.debug('recordTypeCustomSetting results: ' + recordTypeCustomSetting);

        System.assert(String.isBlank(recordTypeCustomSetting.Approval_Email_Logo_ID__c) == true);
        
    }
}