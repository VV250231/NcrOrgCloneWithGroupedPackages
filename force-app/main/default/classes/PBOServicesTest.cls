/**************************************
  Author ...............: Ajay Dixit
  Date Created .........: 07 Jan 2016
  Last Modified By .....:
  Last Modified Date ...: 
  Description ..........: This class is test class for PBO Service exposed to WOT
***************************************/
@isTest
public class PBOServicesTest {
 static testMethod void testNullOpportunity() {
  PBOServices.PBORequest req = new PBOServices.PBORequest();
  PBOServices.PBOResponse res;
     try{
         res=PBOServices.PBOInfoRequest(req);
         //system.debug('@@@:'+res);
     }   
     catch (DmlException e) {
         System.assert(res.message=='Opportunity Number is missing.','Opportunity Number is missing.');
     }
     
  
 }

    static testMethod void testInvalidOpportunity() {
        PBOServices.PBORequest req = new PBOServices.PBORequest();
        PBOServices.PBOResponse res;
        req.oppNumber = '123';
        try{
            res=PBOServices.PBOInfoRequest(req);   
        }
        catch (DmlException e) {
            System.assert(res.status=='FAILURE','PBO Service Failed !!');
        }
    }
 static testMethod void testValidOpportunity() {
  Opportunity opp = TestRecordsFactory.createOpportunityWithLineItemSchedule();
  //Opportunity opp=TestRecordsFactory.createSimpleOpportunity();
  Opportunity opp1 = [SELECT Opportunity_Number__c FROM opportunity WHERE id = : opp.Id].get(0);
  PBOServices.PBORequest req = new PBOServices.PBORequest();
  req.oppNumber = String.valueOf(opp1.Opportunity_Number__c);
  test.startTest();
  System.assertNotEquals(req.oppNumber, null,'Opportunity Number should not be null');
  PBOServices.PBOInfoRequest(req);
  test.stopTest();
 }
}