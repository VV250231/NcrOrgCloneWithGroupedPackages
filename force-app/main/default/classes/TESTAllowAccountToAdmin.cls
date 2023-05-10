/*##################################################################################################
# File..................: TESTAllowAccountToAdmin.cls                                                        
# Version...............: 38.0 
# Created by............: Mudit Saxena
# Created Date..........: 11-02-2016                                                                               
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 11-02-2016                                                                               
# Description...........: This class is Test Class for AllowAccountToAdmin class.
################################################################################################*/
@isTest
private class TESTAllowAccountToAdmin {  
    
    static testMethod void UnitTestFirst() {
        
        Account account = TestRecordsFactory.createAccount();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        
        AllowAccountToAdmin AATA = new AllowAccountToAdmin( sc );
        AATA.getislightningView();
        AATA.getisAllowedView();
        AATA.getErrorMsg();
        system.assertEquals(AATA.getErrorMsg(),'You are not authorized to create an account in NSC. Please raise Account creation request through Customer Portal');
    }
}