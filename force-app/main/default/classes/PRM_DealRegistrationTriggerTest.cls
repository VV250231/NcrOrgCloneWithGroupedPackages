@isTest
public class PRM_DealRegistrationTriggerTest {
    @isTest public static void testPRM_DealRegistrationTrigger() {
        // Create partner account with Industry
        Account act = PRM_TestRecordsFactory.createPartnerAccount('1',null);
system.runAs(TestRecordsFactory.getUser()){ 
          
        insert act;
}
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id,'1',null);
        insert con;
        User partnerUser = PRM_TestRecordsFactory.createPartnerUser(con.Id, '1', null);
        insert partnerUser;
        //Insert Deal Registration
        Deal_Registration__c deal = new Deal_Registration__c();
        deal.Partner_Company_Name__c = 	act.Id;
        deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
        deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
        deal.Is_this_part_of_an_RFP__c =true; 
        deal.End_Customer_Company_Name__c = 'Test End Customer';
        deal.Status__c = 'Created';
        deal.Partner_Industry__c = 'Financial';
        system.runAs(partnerUser) {         
            insert deal;
            PRM_DealRegistrationController.submitDRForApproval(deal.Id, 'Test');
            
        }
    
       system.assert(deal.Id!=null);


        deal.End_Customer_Account_name__c = act.id;
        deal.Partner_Submission_Date__c = system.now() +1;
        update deal;
        deal.Partner_Submission_Date__c = system.now() +2;
        update deal;
        deal.Partner_Submission_Date__c = system.now() +3;
        update deal;
        deal.Partner_Submission_Date__c = system.now() +4;
        update deal;
        deal.Partner_Submission_Date__c = system.now() +5;
        update deal;
        
    }
    
}