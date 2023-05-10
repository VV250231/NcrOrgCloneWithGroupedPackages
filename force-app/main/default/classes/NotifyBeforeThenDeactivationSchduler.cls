/*************************************************************************************************
* Author        :   Pankaj Kashyap  // 17/Nov/2021  
* Param         :   User  :  
* Return        :   
* Description   :   This Schedule call will Schedule the  Btach UserNotifyBeforeThenDeactivationBatch
					Please refer story:SF Optimizer: User Logins(EBA_SF-1628 )
*************************************************************************************************/
global class NotifyBeforeThenDeactivationSchduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      UserNotifyBeforeThenDeactivationBatch UsrBchObj = new UserNotifyBeforeThenDeactivationBatch();
      database.executeBatch(UsrBchObj); 
   }
}