/*
 * Developer sm250665
 * Util class to update owner on Campaign Activity custom object according to Assign_to__c field.
 */
public with sharing class updateCampaignActivityOwnerUtil {

	/* Change Campaign Activity owner to Assign_to__c value. Because they want 'Assign to label' for the owner. 
	 * for custom object we can not change owner label, that's why this method has been implemented.
	 *
	 *
	 * @param	newCampActMap	A map of IDs to the new versions of the sObject records.
	 * @param	oldCampActMap	A map of IDs to the old versions of the sObject records.
	 * @param	campList	    List of the new versions of the sObject records.
	 */   
	public static void updateOwner(Map<Id,Campaign_Activity__c> newCampActMap, Map<Id,Campaign_Activity__c> oldCampActMap, List<Campaign_Activity__c> campList)
	{
		
		for(Campaign_Activity__c campActivity : campList)
		{
			if(campActivity.Assign_to__c != null && campActivity.Assign_to__c != campActivity.OwnerId)
			{
				campActivity.OwnerId = campActivity.Assign_to__c ;
			}
		}
		
	}

}