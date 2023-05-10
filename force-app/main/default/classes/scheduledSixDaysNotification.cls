/*
##################################################################################################
# Class Name............................:scheduledSixDaysNotification                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
global class scheduledSixDaysNotification implements Schedulable {
   global void execute(SchedulableContext SC) {
      NAMERStatusNotify_Batch  M = new NAMERStatusNotify_Batch(); 
      Database.executebatch(M);
   }
}