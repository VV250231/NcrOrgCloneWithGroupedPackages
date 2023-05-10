/*************************************************************************************************************************************
  
# Modification History : 

Story No#       Date                DevName             Description
EBA_SF-1210     30th Nov 2021       Saurav Gautam       Moved the Messaging.SingleEmailMessage to a workflow by Using
                                                        NCR_EmailMessage__c object.

SFHS-292        28th Apr 2022       Basel Altamimi      Extend the control logic to include Hospitality Service Cloud
                                                        automation setting
**************************************************************************************************************************************/

public class TriggerControl {

    public Boolean RunTrigger(String TriggerName) {

        if (skipTriggerExecution_ServiceCloud()) {
            SendEmailTOIDC(TriggerName, Automation.AutomationSetting, getActiveCustomSettingOwner());
            return false;
        }

        System.debug('TriggerName' + TriggerName);
        List<TriggerDeactivation__c> listCodes = TriggerDeactivation__c.getAll().values();
        Map<String, TriggerDeactivation__c> UserIdInCustomSetting = new Map<String, TriggerDeactivation__c>();
        System.debug('start map');
        for (TriggerDeactivation__c obj : listCodes) {
            System.debug('inside loop' + obj.UserId__c);
            UserIdInCustomSetting.put(obj.UserId__c, obj);
        }
        System.debug('map filled' + UserIdInCustomSetting);
        if (listCodes.size() > 0) {
            String TriggerToSkip ;
            if (UserIdInCustomSetting.containsKey(UserInfo.getUserId())) {
                TriggerToSkip = UserIdInCustomSetting.get(UserInfo.getUserId()).TriggerToSkip__c;
            }
            System.debug(UserInfo.getUserId() + ' UserId' + TriggerToSkip);
            if (UserIdInCustomSetting.containsKey(UserInfo.getUserId()) && TriggerToSkip.contains(TriggerName)) {
                System.debug('Triggers bypass');
                SendEmailTOIDC(TriggerToSkip, Automation.TriggerDeactivationSetting, UserInfo.getName());
                return false;
                //Don't call dispatcher inside this block
            } else {
                System.debug('Run  Triggers ');
                return true;
            }
        } else {
            System.debug('Run  Triggers ');
            return true;
        }

    }

    public static void SendEmailTOIDC(String triggerName, Automation messageSource, String relatedTo) {
        //Changes for story EBA_SF-1210 start from-----------------------------------------------------------
        NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c();
        String emailBody = '';
        emailBody += generateEmailMessage(triggerName, messageSource, relatedTo);

        ncrEmail.HTML_Body__c = emailBody;
        ncrEmail.Recipient1__c = 'ni230033@ncr.com';
        //ncrEmail.Recipient2__c ='pk185150@ncr.com';
        ncrEmail.Subject__c = 'Trigger Deactivated In Prod';
        ncrEmail.Email_Type__c = 'NCR Update Failed';
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {'ni230033@ncr.com'};
        //String[] toAddresses = new String[] {'pk185150@ncr.com'};
        //mail.setToAddresses(toAddresses);
        //mail.setSubject('Trigger Deactivated In Prod');
        //mail.setplainTextBody(msg);
        //mail.setHtmlBody( emailBody );
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        insert ncrEmail;
        //-----------------------End Here-for EBA_SF-1210 -----------------------------------------------------
    }

    /**
     * As part of the Hospitality Service Cloud rollout, return if the Service Cloud automation setting is set to on/off
     * for specific User/Profile/Org default.
     * @return boolean value that indicates whether to skip the trigger execution or not.
     */
    private static Boolean skipTriggerExecution_ServiceCloud() {
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

        message += 'Thanks,<br/>NSC Administration';
        return message;
    }
}