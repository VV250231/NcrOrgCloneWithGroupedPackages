/*
####################################################################################################################
# Project Name..........: Sales Order Reporting                                                                                                                       
# File............................:SlsScheduledClass.cls                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 28-01-2018                                                                                 
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 28-01-2018                                                                                
# Description...............: This class is the Scheduled class for Batch class CreateSLSUsers
####################################################################################################################
*/
global class SlsScheduledClass Implements Schedulable
            {
                        global void execute(SchedulableContext sc)
                        {
                                    
                                    CreateSLSUser SLSctrl = new CreateSLSUser();
                                    Database.executeBatch(SLSctrl);        
                        }
            }