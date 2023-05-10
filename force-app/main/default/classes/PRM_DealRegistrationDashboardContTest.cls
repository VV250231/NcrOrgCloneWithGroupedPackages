@isTest
public class PRM_DealRegistrationDashboardContTest {
    
    static testmethod  void DealRegistrationTest() 
    {
         User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
        System.runAs(partnerUser){
Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
            accountRecord.Partner_Industry__c ='Financial';
            insert accountRecord;
        Contact con = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'1',null);
        insert con;  
        }
        Deal_Registration__c deal = new Deal_Registration__c();
        deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
        deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
        deal.Is_this_part_of_an_RFP__c =true;   
        
        insert deal;
        deal.Partner_Industry__c = 'Retail';
        update deal;
        
        PRM_DealRegistrationDashboardCont.getDealRegistration(deal.Id);
        system.assert(deal.id!=null);
       
        
      
    }

}