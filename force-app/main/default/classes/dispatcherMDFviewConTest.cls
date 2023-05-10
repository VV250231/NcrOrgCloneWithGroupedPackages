/*##################################################################################################
# Class Name .....: dispatcherMDFviewConTest
# Last Modified Date....: 19-12-2022
# Description...........: EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 
##################################################################################################*/
@isTest
public class dispatcherMDFviewConTest {
    public static testmethod void testDispatcherMDFview() {
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        PageReference pageRef = Page.dispatcherMDFview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','test');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfReq);
        dispatcherMDFviewCon extensionCon = new dispatcherMDFviewCon(sc);
        extensionCon.getRedir();
        User u = [SELECT Id FROM User where profileId =: NSCCommonInfoUtil.getIdOf('dispClmnPrflId') and isActive = true LIMIT 1];
        system.assert(u.id!=null);
        system.runAs(u)
        {
         ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(mdfReq);
        dispatcherMDFviewCon extensionCon1 = new dispatcherMDFviewCon(sc1);
        extensionCon1.getRedir();
        system.assert(extensionCon1 !=null);
        }
        
    }
}