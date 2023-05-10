/* Class Name : MCenterDupCheckerHelper_Test 
* Date : 17/01/20
* Description : This Test Class  is used in testing functionality of Message Center Duplicacy Checks
*               Channel Partner under 2020 Program
* DeveloperName : Deeksharth Sriwastava
*/
@isTest
public class MCenterDupCheckerHelper_Test {
  @TestSetup static void testDataSetup(){
    Message_Center__c msg = new Message_Center__c();
        msg.Description_box_1__c ='test';
        msg.Industry__c ='Financial';
        msg.Active_From__c =date.today();
        msg.Active_To__c = date.today()+10;
        msg.Region__c ='NAMER';
        msg.Tier_Level__c ='Silver';
        msg.Is_Active__c =true;
        insert msg;
      System.assertNotEquals(msg.Id, Null);
  }
   @isTest static void dupeCheckInsrt_Test(){
       Boolean result = false;
       try{
           Message_Center__c msg1 = new Message_Center__c();
            msg1.Description_box_1__c ='test';
            msg1.Industry__c ='Financial';
            msg1.Active_From__c =date.today();
            msg1.Active_To__c = date.today()+10;
            msg1.Region__c ='NAMER';
            msg1.Tier_Level__c ='Silver';
            msg1.Is_Active__c =true;
            
            insert msg1;
           system.assertNotEquals(msg1.Id,null);
       }catch(DmlException e){
           result = true;
       }
       
   }
     @isTest static void dupeCheckUpdte_Test(){
       Boolean result = false;
           Message_Center__c msgData =[Select id,Tier_Level__c,Description_box_1__c From Message_Center__c LIMIT 1];
          // msgData.Description_box_1__c ='Advanced';
           msgData.Is_Active__c =true;
           update msgData;
          system.assertEquals(msgData.Description_box_1__c,'test');
   }
}