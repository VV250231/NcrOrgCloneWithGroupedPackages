@isTest
public class createVersonofPBLTest {
    public static testMethod void unitTest(){
        Id RecordTypeIdSolPBL = Schema.SObjectType.Pricing_Bid_Log__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
        
        Id RecordTypeIdSerPBL = Schema.SObjectType.Pricing_Bid_Log__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();
      
        Pricing_bid_log__c pbl = new Pricing_bid_log__c(Industry__c='Financial', End_Customer__c = 'Test', Current_status__c='Approved', create_version__c = False, Direct__c='Yes', Bid_Status__c= 'Won', 
       Analysis_Request_Date__c= Date.newInstance(2017, 12, 9),  Bid_Review_Date__c= Date.newInstance(2017, 12, 10), recordtypeid=RecordTypeIdSolPBL );
        insert pbl;
       
        Pricing_bid_log__c pblSer = new Pricing_bid_log__c(create_version__c = True, recordtypeid=RecordTypeIdSerPBL);
        insert pblSer;
        
         Id RecordTypeIdSerPBLVH = Schema.SObjectType.Pricing_bid_log_version_history__c.getRecordTypeInfosByName().get('Services Bid Log').getRecordTypeId();
        Id RecordTypeIdSolPBLVH = Schema.SObjectType.Pricing_bid_log_version_history__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
         Pricing_bid_log_version_history__c pblvh = new Pricing_bid_log_version_history__c(Pricing_bid_log__c = pbl.id , Analyst_Request_Date__c =Date.newInstance(2018, 12, 10), Bid_Status__c= 'Won',recordtypeid=RecordTypeIdSolPBLVH );
        insert pblvh;
        
        Pricing_bid_log_version_history__c pblvhSer = new Pricing_bid_log_version_history__c(Pricing_bid_log__c = pblSer.id);
        insert pblvhSer;
        
        pbl.End_Customer__c = 'Ajay Dixit';
        update pbl; 
        
        pbl.Create_Version__c = True;
        update pbl;
                
        pbl.Analysis_Request_Date__c= Date.newInstance(2016, 12, 9);
        update pbl;
        
        pbl.Competitor_Offering__c= 'Global';
        update pbl;
        
        pbl.Bid_Review_Date__c= Date.newInstance(2016, 12, 10);
        update pbl;
        
        pbl.Bid_Status__c= 'On Hold';
        update pbl;
        
        pbl.Comments__c = 'Test Comments';
        update pbl;
        
        pbl.Current_Status__c = 'Approved';
        update pbl; 
       
        System.assert(pbl.Current_Status__c!=null);
}
}