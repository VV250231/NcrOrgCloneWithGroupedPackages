@isTest(SeeAllData=false)
public class AutoPaySetupReportTest {
    @testSetup
    static void setup(){        
        User Usr = [Select Id,email,ManagerId, profileId from User Where Name = 'Soup User' limit 1];          

        System.runAs(CPQ_TestDataFactory.getSoupUser()) {
            for(Integer i=1; i<10;i++){           
        
                Opportunity o = new Opportunity();
                Contact ct = new Contact(FirstName = 'Test', LastName='ing'+i, Email = 'test.ing'+i+'@ncr.com');
                insert ct;
                System.debug('got Contact in test:'+ i + ' --->' + ct);
                Map<String,String> fieldApiNameToFieldValue = new Map<String,String>();
                Account at = new Account(Name = 'Test Account 2',Master_Customer_Number__c='9789123',Bill_To__c= True, AutoPay_Setup__c='', Primary_Contact__c = ct.Id);
                insert at;
                User usrObj = new User();
                SBQQ__Quote__c qt = new SBQQ__Quote__c(SBQQ__SalesRep__c= Usr.id, qtc_Legal_Document_Status__c = 'Completed',
                                                       qtc_Payments_Only_Quote__c = 'No', SBQQ__Ordered__c = false);
                qt.SBQQ__Account__c = at.Id;
                insert qt;
                Customer_Document__c cdObj = new Customer_Document__c(Name='TestAashirwaad', Account__c= at.id, Quote__r=qt,Customer_Signature_Date__c= datetime.newInstance(2022, 9, 15, 12, 30, 0),
                                                                      Document_Type__c='AE Order Form',Document_Status__c = 'Completed' );
                insert cdObj;
            }
        }
    }
    static testmethod void testAutoPaySetupReportScheduleJob(){
        String sch = '0 5 12 10 2 ?';
        Test.startTest();
        String jobId = System.Schedule('ScheduleAutoPaySetupReportTest', sch, new AutoPaySetupReport());
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='CPQ_Quote_with_FO_for_SalesReps'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce.donotreply@ncr.com'];
        List<SBQQ__Quote__c> QuoteList = [SELECT id,Name,SBQQ__Account__r.Name, SBQQ__Account__r.Master_Customer_Number__c,SBQQ__SalesRep__c,qtc_Legal_Document_Status__c,SBQQ__SalesRep__r.email,SBQQ__SalesRep__r.ManagerId,
                                       (SELECT id,Customer_Signature_Date__c FROM Customer_Documents__r wHERE Document_Status__c = 'Completed' AND
                                        (Document_Type__c ='AE Order Form' OR Document_Type__c = 'AE Amendment') order by Customer_Signature_Date__c DESC limit 1)
                                       FROM SBQQ__Quote__c WHERE AutoPay_Setup__c not in ('True', 'Manual') AND qtc_Legal_Document_Status__c = 'Completed' AND
                                       qtc_Payments_Only_Quote__c = 'No' AND SBQQ__Ordered__c = false];
        Test.stopTest();
    }
    
}