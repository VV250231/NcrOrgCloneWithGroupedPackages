/*
####################################################################################################################
# Project Name..........: NSC CRM 2017                                                                                                                        
# File............................:ManagerHierarchyScheduledClass.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 20-04-2016                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 20-04-2016                                                                                 
# Description...............: This class is the Scheduled class for Batch class CalculateManagerHierarchy
####################################################################################################################
*/
global class ManagerHierarchyScheduledClass Implements Schedulable
            {
                        global void execute(SchedulableContext sc)
                        {
                                    
                                    CalculateManagerHierarchy mgr = new CalculateManagerHierarchy();
                                    Database.executeBatch(mgr);        
                        }
            }