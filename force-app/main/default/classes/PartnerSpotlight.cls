public with sharing class PartnerSpotlight 
{
	@AuraEnabled
    public static String getSpotlight(String recId)
    {
        System.debug('-------recId---------'+recId);
       	Partner_Spotlight__c objPS = [Select Id, Name, Country_the_Partner_is_located_in__c, Date_Location_and_No_of_Event_Attendees__c, Feedback_and_Interest__c, First_Name__c, Last_Name__c,
                                        	Metrics_Results__c, Partner_Contact_s_Email_Address__c, Partner_Contact_s_Title_or_Position__c, Partner_Name__c, Social_platform_to_share_NCR_Content__c,
                                        	Sponsored_Activity_Name_and_Event_Leader__c, Successful_Event__c, Success_Story__c, What_was_the_Impact_of_this_Event__c, Partner_Name__r.Name, Partner_Spotlight_Type__c,
                                      		Industries_partner_focuses_on__c,share_story_in_NCR_Partner_Communication__c,(Select Id, Name from Attachments)
                                      from Partner_Spotlight__c 
                                      where Id =: recId];
        
        return objPS.Partner_Spotlight_Type__c;
        
    }
}