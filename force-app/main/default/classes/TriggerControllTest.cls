@IsTest
public class TriggerControllTest {
    @IsTest
    public static void Test_DoNotRunTrigger() {
        User u = [Select id from User where isactive = true and Id = :userinfo.getuserId() limit 1];
        insert new TriggerDeactivation__c(Name = 'Nagendra', UserId__c = u.id/*'0050g000006H3GKAA0'*/, TriggerToSkip__c = 'OpportunityTrigger');
        TriggerControl TC = new TriggerControl();
        TC.RunTrigger('OpportunityTrigger');
        TriggerControl.SendEmailTOIDC('OpportunityTrigger', TriggerControl.Automation.TriggerDeactivationSetting, UserInfo.getUserId());
        system.assertNotEquals(TC.RunTrigger('OpportunityTrigger'), null);

    }
    @IsTest
    public static void Test_RunTrigger() {
        User u = [Select id from User where isactive = true limit 1];
        insert new TriggerDeactivation__c(Name = 'Nagendra', UserId__c = u.id/*'0050g000006H3GKAA0'*/, TriggerToSkip__c = 'OpportunityTrigger');
        TriggerControl TC = new TriggerControl();
        TC.RunTrigger('OpportunityTrigger');
        System.assertNotEquals(TC.RunTrigger('OpportunityTrigger'), null);

    }
    @IsTest
    public static void Test_RunTrigger1() {
        // User u =[Select id from User where isactive=true limit 1];
        // insert new TriggerDeactivation__c(Name='Nagendra',UserId__c = u.id/*'0050g000006H3GKAA0'*/,TriggerToSkip__c = 'OpportunityTrigger');
        TriggerControl TC = new TriggerControl();
        TC.RunTrigger('OpportunityTrigger');
        System.assertNotEquals(TC.RunTrigger('OpportunityTrigger'), null);

    }

    @IsTest
    public static void Test_RunTrigger_ServiceConsole_User() {
        TriggerControl triggerControl = new TriggerControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getUserId(), Skip_Trigger__c = true);

        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_User_multiReference() {
        TriggerControl triggerControl = new TriggerControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getProfileId(), Skip_Trigger__c = false);
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getUserId(), Skip_Trigger__c = true);

        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_Profile() {
        TriggerControl triggerControl = new TriggerControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getProfileId(), Skip_Trigger__c = true);

        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_Profile_multiReference() {
        TriggerControl triggerControl = new TriggerControl();
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getProfileId(), Skip_Trigger__c = true);
        insert new Automation_Setting__c(SetupOwnerId = UserInfo.getUserId(), Skip_Trigger__c = false);

        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_OrgDefault() {
        TriggerControl triggerControl = new TriggerControl();
        insert new Automation_Setting__c(Skip_Trigger__c = true);

        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), false);

    }
    @IsTest
    public static void Test_RunTrigger_ServiceConsole_Enabled() {
        TriggerControl triggerControl = new TriggerControl();
        insert new Automation_Setting__c(Skip_Trigger__c = false);

        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), true);

    }

    @IsTest
    public static void Test_RunTrigger_ServiceConsole_NoSetting() {
        TriggerControl triggerControl = new TriggerControl();
        System.assertEquals(triggerControl.RunTrigger('OpportunityTrigger'), true);

    }
}