@isTest
public with sharing class NSC_ExceptionHandlerUtilTest {
    
    @isTest
    static void throwDummyException() {
        Test.startTest();
        try {
            Account a;
            update a; // updating the accout withou id.
            System.assert(a.Id!=null);
        } catch (exception ex) {
            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex,'test class');
            System.assert(ex.getMessage()!=null);
        }
        Test.stopTest();
    }
}