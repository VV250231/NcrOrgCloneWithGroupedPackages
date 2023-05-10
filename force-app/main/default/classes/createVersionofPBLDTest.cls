@isTest
public class createVersionofPBLDTest {
    public static testMethod void unitTest(){
        
         Pricing_bid_log__c pbl = new Pricing_bid_log__c(Industry__c='Financial',End_Customer__c = 'Test', Current_status__c='Approved', create_version__c = False, Direct__c='Yes', Competitor_Offering__c= 'Corporate', 
       Analysis_Request_Date__c= Date.newInstance(2017, 12, 9), Bid_Review_Date__c= Date.newInstance(2017, 12, 10) );
        insert pbl;
        
        pbl.Create_Version__c = True;
        update pbl;
        
        		Id RecordTypeIdSolPBLD = Schema.SObjectType.Pricing_Bid_Log_Detail__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();	
                Pricing_Bid_Log_Detail__c pbld  = new Pricing_Bid_Log_Detail__c(Description__c = 'test description',PID__c='0', wot__c='1', Product_Category__c='INPUT', Local_Currency__c='125.0', Exchange_Rate__c = '0.1', BU_Warranty__c='Yes',
                                                                        Extended_List_Price_Per_Unit__c='0', Extended_MRP_Per_Unit__c='0', Net_Price__c='0', Quantity__c='2', Product_Revenue__c='0', Controllable_GM__c = '0.00%', Standard_GM__c='1.12%', RecordTypeId = RecordTypeIdSolPBLD,
                                                                        MRP_Discount__c='1',Solution_Architect__c = 'Mohd Ahad', pricing_bid_log__c= pbl.id);
        insert pbld;
        System.debug('pbld'+pbld);
        
         Pricing_bid_log_version_history__c pblvh = new Pricing_bid_log_version_history__c(Pricing_bid_log__c = pbl.id , Analyst_Request_Date__c =Date.newInstance(2018, 12, 10), Competitor_Offering__c = 'Corporate' );
        insert pblvh;
        System.debug('pblvh'+pblvh);
		
        Id RecordTypeIdSolPBLDVH = Schema.SObjectType.Pricing_Bid_Log_Detail_Version_History__c.getRecordTypeInfosByName().get('Solution Bid Log').getRecordTypeId();
        Pricing_Bid_Log_Detail_Version_History__c pbldvh = new Pricing_Bid_Log_Detail_Version_History__c(Description__c = 'test description', PID__c='0', wot__c='1', Product_Category__c='INPUT', Local_Currency__c='125.0', Exchange_Rate__c = '0.1', BU_Warranty__c='Yes',
                                                                        Extended_List_Price_Per_Unit__c='0', Extended_MRP_Per_Unit__c='0', Net_Price__c='0', Quantity__c='2', Product_Revenue__c='0', Controllable_GM__c = '0.00%', Standard_GM__c='1.12%' , RecordTypeId = RecordTypeIdSolPBLDVH,
                                                                         MRP_Discount__c='1',Solution_Architect__c = 'Mohd Ahad', Pricing_Bid_Log_Version_History__c = pblvh.id);
        insert pbldvh;

        System.assert(pbldvh.Description__c!=null);

    }

}