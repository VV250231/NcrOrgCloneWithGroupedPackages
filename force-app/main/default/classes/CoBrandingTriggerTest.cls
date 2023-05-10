@isTest
public class CoBrandingTriggerTest {
	@TestSetup static void testCobranding(){
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('1',null);
        accountRecord.Partner_Industry__c ='Financial;Hospitality;Travel;Telecom & Technology;Retail';
        User soupUser = [Select Id from User WHERE Name = 'Soup User'];
         System.assertNotEquals(soupUser, null,'Soup User not found');  
        System.runAs(soupUser) {
            Insert accountRecord;
        }
        system.debug('**##'+soupUser);    
        system.debug('**##'+accountRecord); 
    }
    
    @isTest
    public static void testCobrandingTrigger() {
        Account act = [SELECT Id, Name FROM Account WHERE Name = 'Partner Test Account1' LIMIT 1];
          System.assertNotEquals(act.id, null,'Account is null');  
        Co_Branding_Request__c req = PRM_TestRecordsFactory.createCoBrandingRequest(act,'subject','description');
        insert req;
    }
}