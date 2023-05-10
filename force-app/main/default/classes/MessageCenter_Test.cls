/* Class Name : Message Center 
* Date : 18/01/20
* Description : This Test Class  is used in testing functionality of Message Center Component Class 
*               Channel Partner under 2020 Program
* DeveloperName : Deeksharth Sriwastava
*/
@isTest
public class MessageCenter_Test {
	//This method is setting-up account record
    @TestSetup static void testDataSetup(){
        Account acc = new Account();
        acc.Name = 'test'; 
        acc.Master_Customer_Number__c = '1221221';
        acc.Partner_Program_Level__c = 'Advanced';
        acc.Partner_Industry__c ='Financial';
        acc.Account_Region__c ='NAMER';
        acc.Dashboard_last_updated_on__c = Date.newInstance(System.today().Year(), System.today().Month(), System.today().Day());
        
        
        System.runAs(TestRecordsFactory.getUser()){
            insert acc;
        }
        
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
    //This method is used to fetch the account record for specific account Id 
    @isTest static void getMessageInfo_Test(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Message_Center__c> msgRecords = MessageCenter.getMessageInfo(accId);
        System.assert(msgRecords != NULL);
        System.assertNotEquals(msgRecords, Null);
    }
}