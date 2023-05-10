public class DemingValidateExecution {
    

    Public static Boolean ValidateNotificationSwitch(){
        List<DemingNotificationSwitch__mdt>  NotifyObj = new List<DemingNotificationSwitch__mdt>();
        NotifyObj = [select id,TurnOnNotification__c from DemingNotificationSwitch__mdt];
        return NotifyObj[0].TurnOnNotification__c; 
    }
       
}