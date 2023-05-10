global without sharing class ScheduledImplementationReport2 implements Schedulable 
{
   global void execute(SchedulableContext sc) 
   {
		List<GroupMember> lstGM = [Select id, GroupId, UserOrGroupId 
                           from GroupMember where Group.Name = 'Implementation Report Group' ];
       
       	if(!lstGM.isEmpty())
        {
            List<String> lstToAddress = new List<String>();
            
            for(Integer i = 1 ; i < lstGM.size() ; i++)
            {
                lstToAddress.add(String.valueOf(lstGM[1].UserOrGroupId));
            }
            System.debug('-------targetObjectId--------'+lstGM[0].UserOrGroupId);
            System.debug('-------lstToAddress--------'+lstToAddress);
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); 
    
            mail1.setTargetObjectId(lstGM[0].UserOrGroupId); 
            mail1.setSaveAsActivity(false); 
    
            mail1.setTemplateId([select id from EmailTemplate where Name ='Implementation Report After 2018'].id);
            
            if(!lstToAddress.isEmpty())
            	mail1.setToAddresses(lstToAddress);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 }); 
        }
   }
}