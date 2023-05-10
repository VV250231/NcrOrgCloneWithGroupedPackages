/*
##################################################################################################
# Class Name............................:dispatcherClaimViewCon.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class ActiveContactController {
	@AuraEnabled 
    public static Contact getContactActivation(Id Contactid) {
       return [SELECT Id,Active_Contact__c FROM Contact WHERE Id =:Contactid][0];
    }    
}