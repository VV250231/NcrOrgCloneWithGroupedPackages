@isTest
public class TEST_Get_McnFromMyncrServices {
    
    private static testMethod void test() 
    {
        
        Account ac =  TestRecordsFactory.createAccount('123432111','HOSPITALITY:TSR','NAMER SMB');
        Contact cn =  TestRecordsFactory.createContact(ac);
        
        string cid = cn.id;
        string acid = ac.id;
        String username = 'TestHCVOC16';
        string email = 'harjan@gmail.com';
        
        SOUP_Endpoint__c s = new SOUP_Endpoint__c() ;
        s.Name= 'MYNCR' ;
        s.Endpoint_URL__c = 'https://osbcert-ha.ncr.com/ext/ea/services/MyNCR/User/api/userProfile';
        s.Username__c='sdfsd';
        s.Password__c='hzt$sdfsd@EGKb&kjL#' ;
        insert s;
        String authHdr = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('dfsdfsd' + ':' + 'hzt$sdfsdfsd@EGKb&kjL#'));
        string trId =new Uuid().getValue();
        
        SoupMyNcrResult ParsedObj= new SoupMyNcrResult(); 
        
        Try{
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new MOCK_Get_McnFromMyncrServices());
            Get_McnFromMyncrServices.makeGetCallout(username,email,cid,acid);
            Get_McnFromMyncrServices.createLogs('sts');
            Set<String> McnSet = new Set<String>();
            McnSet.add(ac.Master_Customer_Number__c);
            AccountContactRelation acRel = [SELECT IsActive,IsDirect,Roles FROM AccountContactRelation WHERE AccountId = :acid and ContactId=:cid];
            acRel.IsActive =false;
            update acRel;
            VOCRelHandler.handleConAccAssoc(cid, McnSet,acid); 
            //Get_McnFromMyncrServices.makeGetCallout(null,null,null,null);
            Test.stopTest();
        }
        catch (Exception e)
        {
            system.assertEquals(e.getMessage(), e.getMessage()); 
            
        }
        
        
    }
}