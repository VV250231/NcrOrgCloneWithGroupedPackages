trigger CampaignActivityTrigger on Campaign_Activity__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if(checkRecursive.runOnce())
	{
		if(trigger.isBefore)
		{
			if(trigger.isInsert){
				
				//To change record owner to Assign to field vaue .
				updateCampaignActivityOwnerUtil.updateOwner(null, null,trigger.new) ;				
			}		
			else if(trigger.isUpdate){
				
				//To change record owner to Assign to field vaue .
				updateCampaignActivityOwnerUtil.updateOwner(trigger.newMap, trigger.oldMap, trigger.new) ;
			}
		}
	}

}