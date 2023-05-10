/*
 test class for the createOppTypeIDandUpdateIDReferenceObj Trigger
*/
@isTest(SeeAllData=true)
public class TestcreateOppTypeIDandUpdateIDReference    {
    public static testMethod void test() 
    {   
        Test.startTest();
        Opportunity_Type__c  opptype= new Opportunity_Type__c();
        opptype.name='TestOppType';          
        opptype.Active__c=true;       
        opptype.ID__c=null ;
        insert opptype;
        Opportunity_Type__c opptype1 = [Select id,name from Opportunity_Type__c where name='TestOppType'];
        opptype1.name='TestOppType1';
        update opptype1;
        Opportunity_Type__c opptype2 = [Select id,name,Opportunity_Type_Name__c from Opportunity_Type__c where name='TestOppType1'];
        System.assertEquals(opptype2.Opportunity_Type_Name__c, opptype2.Name);
        Test.stopTest();
    }
}