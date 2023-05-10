/*##################################################################################################
# File..................: QuBy_DataCleanup.cls                                                        
# Version...............: 38.0 
# Created by............: Mudit Saxena
# Created Date..........: 11-02-2016                                                                               
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 11-02-2016                                                                               
# Description...........: This class is used clean up quby data.
################################################################################################*/
global class QuBy_DataCleanup implements Schedulable {

    global void execute(SchedulableContext ctx) {
        
        delete [ SELECT id FROM NSC_To_QuBy_Quote__c ];
        
    }   
}