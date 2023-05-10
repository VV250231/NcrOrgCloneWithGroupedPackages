@isTest
private class NCR_URLTest {

    static testMethod void myUnitTest() {
        NCR_URL obj = new NCR_URL();
        String str = obj.InstanceURL ;
        System.assert(str!=null);
    }
}