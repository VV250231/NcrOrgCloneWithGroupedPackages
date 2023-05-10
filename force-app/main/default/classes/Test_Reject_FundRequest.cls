/*   Created by  : Saagar Kinja
*    Email ID    : saagar.kinja@ncr.com 
*    QLID        : SK250817
*    Details     : This Test class is created to test trigger : Reject_FundRequest in Raise Query Object.
*/
@isTest( seeAllData = true )


public class Test_Reject_FundRequest
{
    public static testmethod void test_First_Check()
    {
        /*
Profile p = [SELECT id from Profile WHERE Name = '04 NSC UI Administrator' OR Name = '04 NSC UI Administrator_LTNG' Limit 1];

UserRole ur = [select id, name from UserRole WHERE Name = 'FIN Global Sales VP' limit 1];

User u =new User(alias = 'standt', email='standarduser11@ncr.com',
emailencodingkey='UTF-8', lastname='Testing3',Quicklook_Id__c='ValProfl', languagelocalekey='en_US',
localesidkey='en_US', profileid = p.Id,timezonesidkey='America/Los_Angeles',UserRoleId = ur.id,
username='standarduser1@.ncr.com'+System.now().getTime()+'.com');
*/   
        // RecordType r =[Select id from recordtype where developername ='Partner'];
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,  
            Area__c= 'NORTHERN EUROPE',
            Master_Customer_Number__c = '1631test',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,//'0127000000014kqAAA',
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.Industry__c = 'Financial';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change -Ahad*/
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;//'012700000001PoZ';
        insert opp;
        
        test.startTest();
        List<PermissionSetAssignment> p =[Select assigneeId from PermissionSetAssignment where Permissionset.Name='PreSales_Approvers' limit 2];
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        PFR.Approval_Status__c='New';
        PFR.OwnerId  = p[0].assigneeId;//'00570000003hDvY';
        PFR.PSFR_Authentication_Trigger__c=True;
        PFR.PS_Rec_Authentication_Email__c = 'new@nre.com';
        PFR.TriggerController__c = True;
        insert PFR;
        
        PFR.Approval_Status__c='Pending from Regional Sales Leader';
        update PFR;
        
        PFR.Approval_Status__c='Pending from Leadership Team';
        update PFR;
        
        PFR.Approval_Status__c='Approved';
        update PFR;
        
        
        PFR.OwnerId  = p[1].assigneeId;//'00570000002U3MI';
        PFR.Approval_Status__c='Sent to PS';
        update PFR;
        
        
        PFR.PSFR_Authentication_Trigger__c=True;
        PFR.Approval_Status__c='Approved';
        update PFR;
        System.assertEquals('Approved', PFR.Approval_Status__c);
        test.stopTest();
    }
    
    public static testmethod void test_PendingforApproval()
    {
        
        test.startTest();
        //RecordType r2 =[Select id from recordtype where developername ='Partner'];
        Id r2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,  
            Area__c =  'South Eastern Europe',
            Master_Customer_Number__c = '1631test',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r2,//'0127000000014kqAAA',
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.Account__c = a.id;
        PFR.Approval_Status__c='New';
        insert PFR;
        
        PFR.Approval_Status__c='Pending for Approval';
        
        update PFR;
        System.assertEquals('Pending for Approval', PFR.Approval_Status__c);
        test.stopTest();
    }
    
    public static testmethod void test_Raised_Objection()
    {
        
        
        
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.Approval_Status__c='New';
        
        
        insert PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to Sales Team';
        
        update PFR;
        
        PFR.Approval_Status__c='New';
        update PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to PS Team';
        update PFR;
        test.startTest();
        PFR.Approval_Status__c='New';
        update PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to Sales Team and PS Team';
        update PFR;
        
        PFR.Approval_Status__c='New';
        update PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to Others';
        update PFR;
        System.assertEquals('On Hold ', PFR.Approval_Status__c);
        test.stopTest();
    }
    
    public static testmethod void test_rasied_objections_2()
    {
        test.startTest();
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.Approval_Status__c='New';
        
        
        insert PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to Sales Team, PS Team and Others';
        
        update PFR;
        
        PFR.Approval_Status__c='New';
        update PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to PS Team and Others';
        update PFR;
        
        PFR.Approval_Status__c='New';
        update PFR;
        
        PFR.Approval_Status__c='On Hold ';
        PFR.Raised_Objection_Status__c = 'Raised to to Sales Team and Others';
        update PFR;
        System.assertEquals('On Hold ', PFR.Approval_Status__c);
        test.stopTest();
    }
    public static testmethod void  test_Rejected_Test12334(){
        Id r = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //RecordType r =[Select id from recordtype where developername ='Partner'];
        
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631test',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = r,//'0127000000014kqAAA',
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA',
            Area__c= 'FRANCE BELGIUM'
        );
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
        }
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        //RecordType r1 = [Select id from RecordType where developername='IncludeinFunnel'];
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.Industry__c = 'Financial';
        opp.AccountID = a.id;
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change -Ahad*/
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;//'012700000001PoZ';
        insert opp;
        
        Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
        PFR.PFR_Presales_Category__c = '1-Network Certification';
        PFR.PFR_Justification__c = 'TESTING';
        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
        PFR.PFR_Success_Criteria__c = 'TESTING';
        PFR.PFR_Is_this_Recoverable__c = 'Yes';
        PFR.PFR_Opportunity__c = opp.id;
        PFR.Approval_Status__c='New';
        
        insert PFR;
        
        
        PFR.Approval_Status__c='Pending For Approval';
        update PFR;
        System.assertEquals('Pending For Approval', PFR.Approval_Status__c);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('');
        req2.setAction('Reject');
        Id workItemId = getWorkItemId(PFR.id);
        if(workItemId != null)
        {
            req2.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req2);
        }
        else     
        {
            system.debug(' "Objection can only be raised, If Fund Request is under Approval, i.e status : Pending For Approval" ');
        } 
    }           
    
    public static Id getWorkItemId(Id targetObjectId)
    {            
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id 
                                                 From   ProcessInstanceWorkitem p
                                                 Where  p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
            system.debug('workItem.Id'+retVal);
        }
        return retVal;
        
    } 
    public static void generateapprove(ID PSFRID)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(PSFRID);
        Approval.ProcessResult result = Approval.process(req);
    }
    
}