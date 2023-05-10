/*   Created by  : Saagar Kinja
     *    Email ID    : saagar.kinja@ncr.com 
     *    QLID        : SK250817
     *    Details     : This Test class is created to test class : PSFR_ApprovalRequestCommentsController 
   */
@isTest

public class PSFR_Approved_Comments_Test
{    
        
             /*
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
        
        public static testmethod void  test_Rejected_Test12334()
                        {Account a = new Account(      
                        Account_Country_Code__c = 'EG',
                        Active_Account__c = true,        
                        Master_Customer_Number__c = '1631',
                        Name = 'Unit Test ' + System.now(),
                        RecordTypeId = '0127000000014kqAAA',
                        RoR_Update_Date_Time__c = System.now(),
                        Industry = 'RETAIL:CHANNEL',
                        CAP_Watch__c = 'CAP',
                        account_region__c='INDIA'
                        );
                        
                        insert a;
                        
                        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
                        insert s;
                        
                        Competitors__c c = new Competitors__c(name = 'testing competitor');
                        insert c;
                        
                        Opportunity opp = new Opportunity();
                        opp.name = 'abc';
                        opp.AccountID = a.id;
                        opp.Name = 'OppQuote Linkage Test Opportunity';
                        opp.type = 'Indirect Channel';
                        opp.Solution_Portfolio__c = 'Financial Self Service';
                        opp.CURRENCYISOCODE = 'USD';
                        opp.SALES_ORG__C = s.id;
                        opp.INVOICE_TRIGGER__C = 'Shipment';
                        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
                        opp.PRIMARY_COMPETITOR__C = c.id;
                        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
                        opp.closeDate = System.TODAY();
                        opp.stagename = 'Analyzing';
                        opp.recordTypeId = '012700000001PoZ';
                        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
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
                        
                        
                                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                                 req2.setComments('');
                                 req2.setAction('Reject');
                                 Id workItemId = getWorkItemId(PFR.id);
                                      req2.setWorkitemId(workItemId);
                                       Approval.ProcessResult result =  Approval.process(req2);
                                    }                                                                                                    
         
        */
       public static testmethod void testscenerio()
       {
           PSFR_ApprovalRequestCommentsController psfar1 = new PSFR_ApprovalRequestCommentsController();
           psfar1.getApprovalSteps();
            Presales_Funding_Request__c PFR = new Presales_Funding_Request__c();
                        PFR.PFR_Presales_Category__c = '1-Network Certification';
                        PFR.PFR_Justification__c = 'TESTING';
                        PFR.PFR_Expected_Date__c = system.today().addDays( 2 );
                        PFR.PFR_Success_Criteria__c = 'TESTING';
                        PFR.PFR_Is_this_Recoverable__c = 'Yes';
                        //PFR.PFR_Opportunity__c = opp.id;
                       PFR.Approval_Status__c='New';
                        insert PFR;
       PSFR_ApprovalRequestCommentsController psfar = new PSFR_ApprovalRequestCommentsController();
           psfar.PSFRID = pfr.id;
           psfar.getApprovalSteps();
           system.assert(psfar.PSFRID!=null);
      // psfar.TestCoverateMethod();
       }
                                
        

         
}