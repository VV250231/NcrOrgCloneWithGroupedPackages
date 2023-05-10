@IsTest
public class CPQTriggerSkipControlTest {
    @IsTest
    public static void Test_DoNotRunTrigger() {
        User u = [Select id from User where isactive = true and Id = :userinfo.getuserId() limit 1];
        insert new TriggerDeactivation__c(Name = 'Nagendra', UserId__c = u.id, TriggerToSkip__c = 'OpportunityTrigger');
        CPQTriggerSkipControl TC = new CPQTriggerSkipControl();
        TC.runTrigger('FulfillmentOrderTrigger');
        CPQTriggerSkipControl.sendEmailToCPQIDCTeam('FulfillmentOrderTrigger', CPQTriggerSkipControl.Automation.TriggerDeactivationSetting, UserInfo.getUserId());
        system.assertNotEquals(TC.runTrigger('FulfillmentOrderTrigger'), null);

    }
    
    @IsTest
    public static void Test_RunTrigger() {
        User u = [Select id from User where isactive = true limit 1];
        insert new TriggerDeactivation__c(Name = 'Nagendra', UserId__c = u.id, TriggerToSkip__c = 'OpportunityTrigger');
        CPQTriggerSkipControl TC = new CPQTriggerSkipControl();
        TC.runTrigger('FulfillmentOrderTrigger');
        System.assertNotEquals(TC.runTrigger('FulfillmentOrderTrigger'), null);

    }
    @IsTest
    public static void Test_RunTrigger1() {
        // User u =[Select id from User where isactive=true limit 1];
        // insert new TriggerDeactivation__c(Name='Nagendra',UserId__c = u.id/*'0050g000006H3GKAA0'*/,TriggerToSkip__c = 'OpportunityTrigger');
        CPQTriggerSkipControl TC = new CPQTriggerSkipControl();
        TC.runTrigger('FulfillmentOrderTrigger');
        System.assertNotEquals(TC.runTrigger('FulfillmentOrderTrigger'), null);

    }

    @IsTest
    public static void Test_RunTrigger_ServiceConsole_User() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getUserId(), Skip_Trigger__c = true);

        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_User_multiReference() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getProfileId(), Skip_Trigger__c = false);
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getUserId(), Skip_Trigger__c = true);

        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_Profile() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getProfileId(), Skip_Trigger__c = true);

        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_Profile_multiReference() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getProfileId(), Skip_Trigger__c = true);
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getUserId(), Skip_Trigger__c = false);

        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_OrgDefault() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        insert new Automation_Setting__c(Skip_Trigger__c = true);

        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_Enabled() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        insert new Automation_Setting__c(Skip_Trigger__c = false);

        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), true);

    }

    @IsTest
    public static void Test_RunTrigger_ServiceConsole_NoSetting() {
        CPQTriggerSkipControl triggerControl = new CPQTriggerSkipControl();
        System.assertEquals(triggerControl.runTrigger('FulfillmentOrderTrigger'), true);

    }
}