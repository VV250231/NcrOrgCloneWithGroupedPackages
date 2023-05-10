/****************************************************************************************************************
*   ClassName :   FulfillmentOrderTrigger
*   Description : Created this trigger to check if order interface status is Order Booked
                  and if Quote has Eligible for ERP Should be True or True-Manual then call the cpq_QteToOppSync to auto close the CPQ Opportunity
*   Author      :   
*   Version     :   53
# Modification History.: 
Story No#       Date              DevName             Description
EBA_SF-1697     6 Jan 2021        Varsha Pal
Story No#       Date              DevName             Description
SFCPQBLG-981    12 July 2022      Suraj               AASE Interim QuickBase Integration: Need a relationship between Fulfillment Order Object and NCR Payments Sites Objects
***************************************************************************************************************/
trigger FulfillmentOrderTrigger on qtc_FulfillmentOrder__c (after update,after insert) {
    
    CPQTriggerSkipControl TC = new CPQTriggerSkipControl(); 
    if(TC.runTrigger('FulfillmentOrderTrigger')){
             System.debug('Run FulfillmentOrderTrigger Triggers ');
              new FulfillmentOrderTriggerDispacher().run();
        }else{
           System.debug('Skip FulfillmentOrderTrigger Triggers ');  
    }
    
}