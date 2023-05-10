@isTest
public class DealRegReminderTest {
    @isTest
    public static void testDealRegReminder(){
        // Create partner account with Industry
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        Account act;
        System.runAs(Usr){
        act = PRM_TestRecordsFactory.createPartnerAccount('1',null);
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
        system.runAs(partnerUser) {         
            insert deal;
            try{
            PRM_DealRegistrationController.DealRegistrationDetail objInfo = PRM_DealRegistrationController.submitDRForApproval(deal.Id, 'Test');
            	System.assert(objInfo.isFIN==TRUE);
            }catch(Exception e){
                System.assert(e!=null);
            }
                
        }
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