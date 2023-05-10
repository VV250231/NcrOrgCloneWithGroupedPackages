@isTest
private class TestCSVStream {
     public static testMethod void CSVTest() {
        CSVStream csvObj = new CSVStream();
        csvObj.strRptname = 'test';
        csvObj.strEmail = 'test@test.com';
        csvObj.getCSVStream(); 
        csvObj.blobToString(Blob.valueof('Some'),'x-SJIS_0213');
        system.assert( csvObj.getCSVStream()=='test');
     }

}