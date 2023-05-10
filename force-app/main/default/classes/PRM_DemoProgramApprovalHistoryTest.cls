@isTest
public class PRM_DemoProgramApprovalHistoryTest 
{
	@isTest public static void testDemoCon ()
    {
        // Create Partner user
        Account act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
         System.runAs(TestRecordsFactory.getUser()){
           insert act;
        }
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        
        // Create Demo Request
        Demo_Program__c rec = new Demo_Program__c();
        rec.QTY__c = 50;
        rec.MSRP__c = 10000;
        rec.Product_Description__c = 'Description';
        rec.Product_Group_NCR_designation__c = 'Product Group';
        rec.LT__c = 'LT';
        rec.Status__c = 'Draft';
        insert rec;
                System.assertNotEquals(rec, null,'Demo_Program__c should not be null');

        Approval.processSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Test');
        req.setObjectId(rec.id);
        Approval.ProcessResult result = Approval.process(req);
        
        PRM_DemoProgramApprovalHistory.getApprovalHistory(rec.id);
        
        List<ProcessInstance> allPIList = new List<ProcessInstance>();
        allPIList = [Select Id,CompletedDate , (Select Id, OriginalActorId,OriginalActor.Name, ActorId, Actor.Name, CreatedDate From Workitems ORDER BY CreatedDate DESC)
                     From ProcessInstance p WHERE TargetObjectId =: rec.id ORDER BY CreatedDate DESC ];
        
        String workItemId ;
        
        for(ProcessInstance pi: allPIList)
        {            
            if(pi.Workitems.size() > 0)
            {
                workItemId = pi.Workitems[0].Id;
            }
        }
        
        PRM_DemoProgramApprovalHistory.rejectDemoProgram('Test', 'Test', rec.id, workItemId);
        
        // Create Demo Request
        Demo_Program__c rec2 = new Demo_Program__c();
        rec2.QTY__c = 50;
        rec2.MSRP__c = 10000;
        rec2.Product_Description__c = 'Description';
        rec2.Product_Group_NCR_designation__c = 'Product Group';
        rec2.LT__c = 'LT';
        rec2.Status__c = 'Draft';
        insert rec2;
        
        allPIList = [Select Id,CompletedDate , (Select Id, OriginalActorId,OriginalActor.Name, ActorId, Actor.Name, CreatedDate From Workitems ORDER BY CreatedDate DESC)
                     From ProcessInstance p WHERE TargetObjectId =: rec2.id ORDER BY CreatedDate DESC ];
        
        for(ProcessInstance pi: allPIList)
        {            
            if(pi.Workitems.size() > 0)
            {
                workItemId = pi.Workitems[0].Id;
            }
        }
        
        PRM_DemoProgramApprovalHistory.approveDemoProgram(rec2, 'Test', rec2.id, workItemId, false) ;
        
        PRM_DemoProgramApprovalHistory.saveChunk(rec2.Id, 'Test' , 'Test', 'text', '') ;
    }
}