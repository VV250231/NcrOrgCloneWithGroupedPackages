/*
 test class for the createRsnCodeIDandUpdateIDReferenceObj Trigger
*/
@isTest
public class createRsnCodeIDandUpdateIDReferenceTest    {
    public static testMethod void test() 
    {   
        Test.startTest();
        ID_Reference__c IDRf = new ID_Reference__c();
        IDRf.ReasonCode_Last_Record_ID__c='12345';
        IDRf.Name='TestIDREF1';
        insert IDRf;
        
        Reason_Code__c  RsnCode= new Reason_Code__c(); 
        RsnCode.name='TestRsnCode'; 
        RsnCode.ReasonCode_Name__c='TestRSNCODE';
        RsnCode.Active__c=true;       
        RsnCode.ID__c='test' ;
        insert RsnCode;
        
        
        
        Reason_Code__c RsnCode1 = [Select id,name from Reason_Code__c where name='TestRsnCode'];
        RsnCode1.name='TestRsnCode1';
        update RsnCode1;
        Reason_Code__c RsnCode2 = [Select id,ReasonCode_Name__c from Reason_Code__c where name='TestRsnCode1'];
        RsnCode2.ReasonCode_Name__c='TestRsnCode1';
        update RsnCode2;
        Test.stopTest();
    }
}