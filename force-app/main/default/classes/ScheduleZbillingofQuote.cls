/*
############################################################################################################
# Project Name..........: Subscription Commerce Application                                                                    
# Created by............: Tania Sen                                                               
# Created Date..........: 21-02-2018                                                                               
# Last Modified by......: Tania Sen 
# Last Modified Date....: 22-02-2018 
# Description...........: This class is schedule to run on 3AM IST ,it calls the future method of Zbilling
#############################################################################################################
*/

Global with sharing class ScheduleZbillingofQuote implements schedulable
 //Amend Subscription  &&  objQuote.Error_Message_When_Z_Billing_Fail__c.containsIgnoreCase('lock unknown')
{
  Global void execute(SchedulableContext ctx) {
  Map<String,Set<id>> mpSYandQ = new  Map<String,Set<id>>();
 
     for(zqu__Quote__c  objQuote: [Select id,zqu__SubscriptionType__c,Error_Message_When_Z_Billing_Fail__c from zqu__Quote__c where zqu__Status__c = 'New' and Entered_Approval_Process__c = true and Is_NCR_Quote__c = true and Track_Approval_Steps__c ='Step1' order by lastmodifieddate desc limit 50000 ]){
         if(String.isNotBlank(objQuote.zqu__SubscriptionType__c ) ){
            if(!mpSYandQ.containsKey(objQuote.zqu__SubscriptionType__c )){
                mpSYandQ.put(objQuote.zqu__SubscriptionType__c ,new Set<id>());
            }
                mpSYandQ.get(objQuote.zqu__SubscriptionType__c).add(objQuote.id) ;
         }
      }
     system.debug('+++++mpSYandQ++++++'+mpSYandQ);

     for(String st : mpSYandQ.keyset()){ 
        List<id> lstQtIds = new List<id>();
        lstQtIds.addAll(mpSYandQ.get(st));
        FutureClassForQuotesZbilling.sendToZBilling(lstQtIds);
     }    
      
   

   }

}