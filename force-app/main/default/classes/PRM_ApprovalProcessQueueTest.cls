@isTest
public class PRM_ApprovalProcessQueueTest {
    @isTest public static void testApprovalProcess () {
         User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
        System.runAs(partnerUser)
            // Create partner account with Industry
        {
      Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
            accountRecord.Partner_Industry__c ='Financial';
            insert accountRecord;
        Contact con = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'1',null);
        insert con;
        //Insert Deal Registration
        {
            Deal_Registration__c deal = new Deal_Registration__c();
        deal.Partner_Company_Name__c =   accountRecord.Id;
        deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
        deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
        deal.Is_this_part_of_an_RFP__c =true; 
        deal.Partner_Industry__c = 'Financial';
        system.runAs(partnerUser) {         
            insert deal;
            PRM_DealRegistrationController.submitDRForApproval(deal.Id, 'Test');
        }
        PRM_ApprovalProcessQueue.getApprovalHistory(String.valueOf(deal.Id));
        PRM_ApprovalProcessQueue.processRequest('test Comment',PRM_ApprovalProcessQueue.wiRec,'Approve');
        PRM_ApprovalProcessQueue.getApprovalHistory(String.valueOf(deal.Id));
       // PRM_ApprovalProcessQueue.requestReassignToUser();
        String s= PRM_ApprovalProcessQueue.requestReassign('Test Comment',PRM_ApprovalProcessQueue.wiRec,deal.Id);
            PRM_ApprovalProcessQueue.requestReassignToUser('Test Comment',PRM_ApprovalProcessQueue.wiRec,String.valueof(deal.Id),userinfo.getUserId());
			PRM_ApprovalProcessQueue.CheckModiffyAllPermission();
            System.assert(s!=null);
            
        
    }
}
}
}