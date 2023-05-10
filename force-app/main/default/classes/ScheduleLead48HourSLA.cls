/*##################################################################################################
# Project Name..........: NSC CRM 2017                                                                    
# File..................: ScheduleLead48HourSLA.cls                                                        
# Version...............: 39.0 
# Created by............: IDC, NSC
# Created Date..........: 27-02-2017                                                                              
# Last Modified by......: IDC, NSC
# Last Modified Date....: 27-02-2017  
# Description...........: NC_AGILE-211 - Once SDL team reassigns the Lead to a sales rep, If sales rep doesn't change 
                          the lead status within 48hrs then an email goes out to the sales rep and their manager.
################################################################################################*/
global Class ScheduleLead48HourSLA implements schedulable {
    global void execute (SchedulableContext sc) {   
       ProcessSalesRep48HourLeadSLA  slaBatch = new ProcessSalesRep48HourLeadSLA();
       Database.executeBatch(slaBatch);                  
    }
}