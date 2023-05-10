@isTest
public class PRM_MdfClaimTrigger_Test {
    @isTest
    static void mdfClaimTest() {
        // create MDF request
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        // Create claim 
        SFDC_MDF_Claim__c mdfClaim =  PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        // Update Claim Status
        mdfClaim.status__c = 'Submitted';
        update mdfClaim ;
        system.assertEquals( mdfClaim.status__c , 'Submitted');
    }
}