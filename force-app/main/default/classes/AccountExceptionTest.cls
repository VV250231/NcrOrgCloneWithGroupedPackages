@isTest
public class AccountExceptionTest
{
    static testmethod void testAutoPopulate()
    {
        Exception_Account__c ea = new Exception_Account__c();
             ea.Name='test';
             insert ea;
             system.debug('-------->' +ea.id); 
        
        Account_Exception__c ex = new Account_Exception__c();
             ex.End_Customer__c = 'test123';
             ex.Customer_Name__c = ea.id;   
             ex.Primary_Contact_Name__c = 'test123';
             ex.Primary_Solution__c = 'test123';
             ex.Opportunity_Value__c = 123;
             ex.Primary_Competitor__c = 'test123';
             ex.Expected_Close_Date__c = system.today();
             insert ex;
             system.debug('id is ========='+ex.id);
             ex.Status__c = 'Approved';
             update ex;
         }
    }