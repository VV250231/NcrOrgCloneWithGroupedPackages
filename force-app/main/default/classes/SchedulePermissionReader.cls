/****************************************************************************************************************
*   ClassName :   SchedulePermissionReader
Created By : Puneet/Monika
*   Description :  Automate process to provide access of all the fields to Admin 04, Data Backup and Recovery
and 10 Read Only Advance
Classes - PermissionReader, ProfilePermissionProvider, SchedulePermissionReader 
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-2357     1 Dec 2021         Monika            Automate process to provide access of all the fields to Admin 04
                                                     and 10 Read Only Advance
****************************************************************************************************************/
global class SchedulePermissionReader implements Schedulable {
   global void execute(SchedulableContext SC) {
       //if(!Test.isRunningTest())
   		Database.executeBatch(new PermissionReader(), 1);    
   }
}