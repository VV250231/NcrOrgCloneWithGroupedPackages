@isTest
public class Reject_FundRequestTest {
    @isTest    
    static void rejFunMethod(){
        Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '1631',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Partner'),
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            CAP_Watch__c = 'CAP',
            account_region__c='INDIA',
            Area__c= 'FRANCE BELGIUM'
        );
        
        System.runas(testRecordsFactory.getUser()){
            insert a;
        }
        
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert s;
        
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        insert c;
        
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
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');//'012700000001PoZ';
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
        
        AssociateResourceandRequest__c aRes = new AssociateResourceandRequest__c();
        //aRes.Email_ID__c = 'Test@test.com'; 
        //aREs.Raise_to_Other__c = true;
        //aRes.status = 'Pending For Approval';
        aRes.Notified_Users__c = 'test';
        aRes.All_Previously_Notified_PS_Team_Users__c = 'test';
        aRes.CC_1__c = 'test@test.com';
        aRes.CC_2__c = 'test@test.com';
        aRes.Additional_Commnets__c = 'test';
        aRes.Notified_Users__c = 'test';
        aRes.Email_ID__c = 'Test@test.com';
        aRes.Presales_Funding_Request__c = PFR.Id;
        aRes.Raise_Query__c = true;
        aRes.Raise_to_Opportunity_Owner__c = true;
        aRes.Raise_to_PS_Team__c = true;
        aRes.Raise_to_Other__c = true; 
        
        
        
        Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(PFR.id);
        
        // Submit on behalf of a specific submitter
        //req1.setSubmitterId(TestRecordsfactory.getUser().id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('PS_Fund_Request_Approval_Activity');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
        
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        //Use the ID from the newly created item to specify the item to be worked
        if(!newWorkItemIds.isEmpty())
            req2.setWorkitemId(newWorkItemIds.get(0));
        try{ 
            insert aRes;
            
        }
        catch(exception ex){
            system.debug(ex.getMessage());               
        }
        
        
    }
     
}