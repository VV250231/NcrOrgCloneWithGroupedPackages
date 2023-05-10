@isTest
private Class CDMOrgAPIControllerTest {
    
    static testMethod void runTest() {
    
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         
         NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
         insert nscNotification; 
        
         User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
         system.assertNotEquals(Usr.Id,null);
         
         
         User testUser = TestRecordsFactory.createUsers(Usr.profileId, 'test1', 1).get(0);
          System.debug(testUser);
          
          List<Account> accList = new List<Account>();         
          System.runAs(Usr) {
          
             accList.add(new Account(name='Account1', Master_Customer_Number__c = 'Test1', ownerId = testUser.Id, DI_Customer__c = '1234'));
             insert accList;
          }
          
          
          
          NCR_Employee_Detail__c empDetail = new NCR_Employee_Detail__c(User_Name__c = testUser.FirstName, Quicklook_ID__c = testUser.Quicklook_ID__c.toUpperCase(), InActive__c=false);
          insert empDetail;
          
          SOUP_Endpoint__c se = new SOUP_Endpoint__c(name='CDM', Username__c='test', Password__c = 'test', Endpoint_URL__c= 'test.ncr.com');
          insert se;
          
          CDMOrgAPIController cdmcontroller = new CDMOrgAPIController(accList);
          
            String resBody = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing">' + 
                                       '<env:Header>' + 
                                    '<wsa:MessageID>test</wsa:MessageID>' + 
                                    '</env:Header>' + 
                                    '<env:Body>' + 
                                    '<CDMUpdateOrganizationRespABMMsg xmlns:ns2="http://xmlns.ncr.com/SOUP/Common/1.0" xmlns="http://xmlns.ncr.com/SOUP/Service/CDM/Organization/V1">' + 
                                    '<UpdateOrganizationRespABM>' +
                                    '<ns2:ResponseHeader>' + 
                                    '<ns2:TransactionID>81d52e7b-e48f-48c8-8505-342e7afbf4bf</ns2:TransactionID>' +
                                    '<ns2:Timestamp>2020-04-17T15:37:55.928+00:00</ns2:Timestamp>' +
                                    '<ns2:Status>SUCCESS</ns2:Status>' + 
                                    '</ns2:ResponseHeader>' +
                                    '<UpdateOrganizationResponse>' +
                                    '<OrganizationPartyResult>' +
                                    '<Value>' +
                                    '<PartyNumber>10536781</PartyNumber>' +
                                    '<PartyId>300000075863492</PartyId>' +
                                    '<PartyType>ORGANIZATION</PartyType>  ' +
                                    '</Value>' +
                                    '</OrganizationPartyResult>' +
                                    '</UpdateOrganizationResponse>' +
                                    '</UpdateOrganizationRespABM>' +
                                    '</CDMUpdateOrganizationRespABMMsg>' +
                                    '</env:Body>' +
                                    '</env:Envelope>';
         String jsonResp = '{ "UpdateOrganizationRespABM" : {"ResponseHeader" : { "Status":"Success"}}}';
          cdmcontroller.generateRequestBody('test', 'NSC', Date.today().format(), 'test', 'CDM','test','test');  
          cdmcontroller.parseJSONResponse(jsonResp);
          cdmcontroller.parseXMLResponse(resBody);
          cdmcontroller.genCDMlog('Test1','Test','Test', 'SUCCESS');          
          try {
          cdmcontroller.parseErrorResponse(resBody);
          } catch(Exception e) {
            System.debug('Error: '+e.getMessage());
          }
        Test.startTest(); 
            
        System.enqueueJob(new CDMOrgAPIController(accList));        
          
        System.enqueueJob(new CDMOrgAPIController(accList, new Map<String, String>(), new List<CDM_Log__c>(), 0, 0));
        
        Test.stopTest();
        
    }
    
    
       
    
}