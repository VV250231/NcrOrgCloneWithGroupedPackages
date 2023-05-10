/*************************************************************************************************************************************
# Modification History : 
Story No#       Date                DevName             Description
				02-FEB-2023			Dharmendra          Trigger execution controlled by Custom Setting
**************************************************************************************************************************************/

public class CPQTriggerSkipControl {
    public Boolean runTrigger(String TriggerName) {
		
        // when globally trigger skip is required then set Custom Setting "Automation_Setting__c", user, Profile or Org
        if (skipTriggerExecution()) {
            sendEmailToCPQIDCTeam(TriggerName, Automation.AutomationSetting, getActiveCustomSettingOwner());
            return false;
        }
        
        // when specific trigger execution control is required
        List<TriggerDeactivation__c> listCodes = TriggerDeactivation__c.getAll().values();
        Map<String, TriggerDeactivation__c> UserIdInCustomSetting = new Map<String, TriggerDeactivation__c>();
        for (TriggerDeactivation__c obj : listCodes) {
            UserIdInCustomSetting.put(obj.UserId__c, obj);
        }
        
        if (listCodes.size() > 0) {
            String TriggerToSkip ;
            if (UserIdInCustomSetting.containsKey(UserInfo.getUserId())) {
                TriggerToSkip = UserIdInCustomSetting.get(UserInfo.getUserId()).TriggerToSkip__c;
            }
            
            if (UserIdInCustomSetting.containsKey(UserInfo.getUserId()) && TriggerToSkip.contains(TriggerName)) {
                System.debug(UserInfo.getUserId() + ' Skipped Trigger for UserId:' + TriggerName);
                sendEmailToCPQIDCTeam(TriggerToSkip, Automation.TriggerDeactivationSetting, UserInfo.getName());
                return false;
            } else {
                return true;
            }
        } else {
             return true;
        }

    }

    public static void sendEmailToCPQIDCTeam(String triggerName, Automation messageSource, String relatedTo) {
        NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
        String emailBody = '';
        emailBody += generateEmailMessage(triggerName, messageSource, relatedTo);

        ncrEmail.HTML_Body__c = emailBody;
        ncrEmail.Recipient1__c = 'sc230555@ncr.com';
        ncrEmail.Subject__c = 'Trigger Deactivated In Prod';
        ncrEmail.Email_Type__c = 'NCR Update Failed';
        insert ncrEmail;
    }

    /**
     * If logged in user added for skip trigger execution in custom setting then return true else false
     */
    private static Boolean skipTriggerExecution() {
        Automation_Setting__c setting = getActiveCustomSetting();
        return setting != null ? setting.Skip_Trigger__c : false;
    }

    private static String getActiveCustomSettingOwner() {
        Automation_Setting__c setting = getActiveCustomSetting();

        String ownerName;
        if (setting.SetupOwnerId == UserInfo.getUserId()) {
            ownerName = UserInfo.getName();
        } else if (setting.SetupOwnerId == UserInfo.getProfileId()) {
            ownerName = UserInfo.getProfileId() + ' Profile';
        } else {
            ownerName = 'Org default';
        }

        return ownerName;
    }

    private static Automation_Setting__c getActiveCustomSetting() {
        // Get automation setting for the context user
        Automation_Setting__c setting = Automation_Setting__c.getInstance(UserInfo.getUserId());
        if (setting == null || !setting.Skip_Trigger__c) {
            // Get automation setting based on the user profile
            setting = Automation_Setting__c.getInstance(UserInfo.getProfileId());

            if (setting == null || !setting.Skip_Trigger__c) {
                // Get org default
                setting = Automation_Setting__c.getOrgDefaults();
            }
        }

        return setting;
    }

    public enum Automation {
        TriggerDeactivationSetting, AutomationSetting
    }
    
    private static String generateEmailMessage(String triggerName, Automation sourceAutomation, String relatedTo) {
        String message;

        if (sourceAutomation == Automation.TriggerDeactivationSetting) {
            message = String.format('Hello,<br/><br/>{0} has been deactivated for {1}<br/> Please do not forget to reactivate triggers by removing {2} custom setting data.</br></br></br>'
                    , new List<String>{
                            triggerName, relatedTo, 'Trigger Deactivation'
                    });
        } else if (sourceAutomation == Automation.AutomationSetting) {
            message = String.format('Hello,<br/><br/>All triggers have been deactivated<br/> Please do not forget to reactivate triggers by enable it back for {0} in {1} custom setting.</br></br></br>'
                    , new List<String>{
                            relatedTo, 'Automation Setting'
                    });
        } else {
            message = String.format('Hello,<br/><br/>{0} has been deactivated<br/> Please do not forget to reactivate the trigger.</br></br></br>', new List<String>{
                    triggerName
            });
        }

        message += 'Thanks,<br/>NCR CPQ Administration';
        return message;
    }
}