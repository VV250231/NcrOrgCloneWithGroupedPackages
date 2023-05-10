/*
##################################################################################################
# Class Name............................:dispatcherClaimViewConTest.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
@isTest
public class dispatcherClaimViewConTest {
    public static testmethod void testDispatcherMDFview() {
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
         //Create MDF Claim record
        SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfCliam);
        dispatcherClaimViewCon extensionCon = new dispatcherClaimViewCon(sc);
        extensionCon .getRedir();
        system.assert(extensionCon !=null);
    }
}