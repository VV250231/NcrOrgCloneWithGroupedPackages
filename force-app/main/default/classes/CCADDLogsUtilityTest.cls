@isTest
public class CCADDLogsUtilityTest {

    static testmethod void runtest1(){
        CCADDLogsUtility.insertCCADDLogs('Test', 'Test', 'Test', '1223455', '32324324322222225454566634', 'test');
        Test.startTest();
    	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/invoiceDispute/status?x-transaction-id=12125412'; 
       
        //req.params.put('x-transaction-id','12125412');
        req.headers.put('x-transaction-id','12125412');
        req.headers.put('x-source-system','12125412');
        //req.params.put('x-source-system','test');
        req.params.put('DisputeID', '123412');
        req.params.put('IsExternalOnly', 'Y');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        SendDisputeStatusToMyncr.getDisputeHeader();
        CCADDLogsUtility.insertDisputeLogs('Test', 'Test', 'Test', '1223455', '32324324322222225454566634', 'test');
        Test.stopTest();
    }
}