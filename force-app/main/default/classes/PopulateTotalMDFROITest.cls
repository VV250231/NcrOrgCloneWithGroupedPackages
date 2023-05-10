@isTest
public class PopulateTotalMDFROITest {
    
    @isTest
    public static void PopulateTotalROIfromPFROITest(){
        List<Partner_Fund_ROI__c> partnerFundList = new List<Partner_Fund_ROI__c>();
        partnerFundList.add(new Partner_Fund_ROI__c(Current_Revenue_earned__c  = 1000));
       
        System.runAs(TestRecordsFactory.getUser()){
        Account accountRecoed  = PRM_TestRecordsFactory.createPartnerAccount('test',null);
        Insert accountRecoed;
                
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecoed.Id, 't', null);
        Insert contactRecord;
        System.assertNotEquals(contactRecord.id, null,'Contact is Null');  
        User camUser = PRM_TestRecordsFactory.createUser(null, '04 NSC UI Administrator', 'x', null);
        Insert camUser; 
        
        SFDC_MDF__c fundRequest = PRM_TestRecordsFactory.createFundRequest('Test Name', accountRecoed.Id, 'Approved');
        fundRequest.CAM__c= camUser.Id;
        fundRequest.Requester_Name__c =contactRecord.Id;
        Insert fundRequest;        
        
        partnerFundList.add(new Partner_Fund_ROI__c(Current_Revenue_earned__c  = 2000, Fund_Request__c = fundRequest.Id,Partner_Account__c = accountRecoed.Id,Partner_Contact__c =contactRecord.Id));
        
        partnerFundList.add(new Partner_Fund_ROI__c(Current_Revenue_earned__c  = 1300));
        partnerFundList.add(new Partner_Fund_ROI__c(Current_Revenue_earned__c  = 1050));
        partnerFundList.add(new Partner_Fund_ROI__c(Current_Revenue_earned__c  = 1800));
        Insert partnerFundList;
        }}
}