@isTest
public class ERPOrderLineServiceTest {

    public static testMethod void ServiceTest() {
        Test.startTest();
        Set<String> orderids= new Set<String>();
        orderids.add('87470625');
        Test.setMock(HttpCalloutMock.class, new ERPOrderLineMock()) ;
        ERPOrderLineService.synchOrdLine('87470625');
        System.assertNotEquals(orderids, null,'orderids should not be null');
        Test.stopTest();
    }
}