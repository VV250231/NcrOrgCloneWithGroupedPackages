@isTest(SeeAllData=true)
public class MassFileDownloaderControllerTest {
    
    static testmethod void getFilesTest() {   
         List<String> caseId =new List<String>() ;
         Test.startTest();
        List<Case> c=[SELECT Id FROM Case where RecordType.Name like '%Deals%' limit 1];
        For(Case cs: c) {
         caseId.add(cs.Id);   
        }
        MassFileDownloaderController.getFiles(caseId);
        MassFileDownloaderController.getCases('s','caseNumber','asc');
        Test.stopTest();
    }

   
    static testmethod void getFilesByIdsTest() {
        Test.startTest();
        ContentVersion cv = new ContentVersion(
            Title = 'DemoFile',
            VersionData = Blob.valueOf('Random String Data'),
            PathOnClient = 'DemoFile.png'
        );
        insert cv;
         List<String> caseId =new List<String>();
        Id demoFileId = [SELECT Id FROM ContentDocument WHERE Title = 'DemoFile'].Id;
        List<Case> c=[SELECT Id FROM Case where RecordType.Name like '%Deals%' limit 1];
        For(Case cs: c) {
         caseId.add(cs.Id);   
        }
            System.assertEquals(0, MassFileDownloaderController.getFilesByIds(new String[] {demoFileId},caseId).size());
        Test.stopTest();
    }
}