@isTest

public class PRM_ApprovalProcessTest {
    @isTest public static void testApprovalProcess () {
        // Create partner account with Industry
        Account act = PRM_TestRecordsFactory.createPartnerAccount('1',null);
        System.RunAs(TestRecordsFactory.getUser()){
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
        deal.Partner_Industry__c = 'Financial';
        deal.Status__c = 'Created';
        system.runAs(partnerUser) {         
            insert deal;
			system.assert(deal.Id!=null); 
            PRM_DealRegistrationController.submitDRForApproval(deal.Id, 'Test');
            PRM_ApprovalProcess.getApprovalHistory(deal.Id);
            PRM_ApprovalProcess.processRequest('test Comment',PRM_ApprovalProcessQueue.wiRec,'Approve');
  
    }
    
}
}