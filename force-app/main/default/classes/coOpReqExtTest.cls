@isTest
public class coOpReqExtTest {
    public static testMethod void testcoOpReqExt() {
        // Insert Co-Op Request
        Co_Op__c coOpReq = new Co_Op__c();
        coOpReq.Activity_Name__c = 'Co Op Req';
        coOpReq.Activity_Start_Date__c = System.today();
        coOpReq.Activity_End_Date__c = System.today();
        insert coOpReq;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(coOpReq);
        coOpReqExt controller = new coOpReqExt(sc);
        System.assert(controller!=null);
         
    }
}