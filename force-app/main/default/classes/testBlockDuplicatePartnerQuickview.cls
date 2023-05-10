/* This test class covers blockDuplicatePartnerQuickview trigger on Partner_Quickview__c object*/
@isTest
public class testBlockDuplicatePartnerQuickview 
{
    public testMethod  static void test1()
    {      
        Account accB =TestRecordsFactory.createAccount();
        //Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Solution Provider').getRecordTypeId();//012700000005ldxAAA = Solution Provider
        RecordType r1 = [Select id from RecordType where Name='Solution Provider'];
        Account acc =TestRecordsFactory.createAccount('Test');
        Partner_Quickview__c ob3=new Partner_Quickview__c();
        ob3.Account_Name__c=accB.Id;
        ob3.RecordTypeId=r1.id;
        insert ob3;
        try{
            Partner_Quickview__c ob5=new Partner_Quickview__c();
            ob5.Account_Name__c=acc.Id;
            ob5.RecordTypeId =r1.id;        
            insert ob5;   
            List<Partner_Quickview__c> pqList =[Select id,Account_Name__c,RecordTypeId from Partner_Quickview__c];
            Id r2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Managed Service Provider').getRecordTypeId();
            pqList[0].Account_Name__c = acc.Id;
            pqList[1].Account_Name__c = accB.Id;
            pqList[1].RecordTypeId = r2;
            update pqList;
            System.assertEquals(pqList[0].Account_Name__c, acc.Id);
        }
        catch(Exception e){
            System.debug('Exception Caught'+e.getMessage());
        }
        
        Partner_Quickview__c ob1=new Partner_Quickview__c();
        ob1.Account_Name__c=accB.Id;
        ob1.RecordTypeId=r1.id;

        Partner_Quickview__c ob2=new Partner_Quickview__c();
        ob2.Account_Name__c=accB.Id;
        ob2.RecordTypeId =r1.id;        
        
        try{
        List<Partner_Quickview__c> a1=new List<Partner_Quickview__c>(); 
            a1.add(ob1);
            a1.add(ob2);              
            insert a1;
        }
        catch(Exception e){
            System.debug('Exception Caught'+e.getMessage());
        }  
    }
}