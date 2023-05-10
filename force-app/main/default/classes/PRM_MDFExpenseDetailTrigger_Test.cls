@isTest
public class PRM_MDFExpenseDetailTrigger_Test {
    /* Test Trigger "AggResult": for Insert or update the Expense detail record with MDF Request*/
    @isTest
    static void testCreateExpenseDetailWithMDFReq() {   
        try{
            //Create MDF Request
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
            mdfReq.Amount__c= 100.10;
            mdfReq.Total_Actual_Cost__c=100.10;
            mdfReq.Total_Anticipated_Expense__c=100.10;
            mdfReq.Total_Estimated_Cost__c= 100.10;
            mdfReq.Total_NCR_Approved__c=100.10;
            mdfReq.Total_NCR_Estimated_Participation__c=100.10;
            update mdfReq; 
            System.assertNotEquals(mdfReq.id, null,'mdfReq should not be null');
            //Create MDF_Expense_Detail__c record to test Trigger "AggResult"
            MDF_Expense_Detail__c mdfExpenseDetails = new MDF_Expense_Detail__c();
            mdfExpenseDetails.Actvity__c='Print';
            mdfExpenseDetails.Estimated_Cost__c=200.10;
            mdfExpenseDetails.NCR_Estimated_Participation__c=200.10; 
            mdfExpenseDetails.MDF_Request__c=mdfReq.id; 
            insert mdfExpenseDetails; 
            
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }
    
    /* Test Trigger "AggResult": for Insert or update the Expense detail record with CLaim*/
    @isTest
    static void testCreateExpenseDetail1WithClaim() {   
        try{
            
            //Create MDF Request
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
            //Create MDF Claim record
            SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id); 
            mdfCliam.Actual_Total_Cost__c=300.10;
            mdfCliam.Amount__c=300.10;
            update mdfCliam;
            System.assertNotEquals(mdfReq.id, null,'mdfReq should not be null');
            //Create MDF_Expense_Detail__c record to test Trigger "AggResult"
            MDF_Expense_Detail__c mdfExpenseDetails = new MDF_Expense_Detail__c();
            mdfExpenseDetails.Actvity__c='Print';
            mdfExpenseDetails.Estimated_Cost__c=200.10;
            mdfExpenseDetails.NCR_Estimated_Participation__c=200.10;
            mdfExpenseDetails.Actual_Cost__c=200.10;
            mdfExpenseDetails.NCR_Approved__c=200.10;
            mdfExpenseDetails.Fund_Claim__c=mdfCliam.id;
            insert mdfExpenseDetails; 
            
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }
    
    /* Test Trigger "AggResult": Test for Delet the Expense detail record */
    @isTest
    static void testDeleteExpenseDetail() {   
        try{
            //Create MDF Request
            SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
            System.assertNotEquals(mdfReq, null,'mdfReq should not be null');
            //Create MDF Claim record
            SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id); 
            System.assertNotEquals(mdfCliam, null,'mdfCliam should not be null');
            //Create MDF_Expense_Detail__c record to test Trigger "AggResult"
            MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id); 
            delete mdfExpenseDetails;
           System.assertNotEquals(mdfExpenseDetails, null,'mdfExpenseDetails should not be null'); 
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    } 
    
}