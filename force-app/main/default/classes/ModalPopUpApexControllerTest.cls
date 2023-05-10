/*
##################################################################################################
# Class Name............................:ModalPopUpApexControllerTest.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
@isTest(seeAllData =true)
public class ModalPopUpApexControllerTest {
    
    private static Engineers__c  createEngineer(String typeOfAccess){
        User u = [Select id from User where email !=null And isActive = true AND Profile.Name='04 NSC UI Administrator' limit 1];
        Engineers__c eng = new Engineers__c();
        eng.First_name__c = 'Test Engineer';
        eng.Last_Name__c ='Last';
        eng.Email_Address__c = 'rahul@test.com';
        eng.Type_of_Portal_Access__c = typeOfAccess ;
        eng.City__c ='Delhi';
        eng.ownerId = u.id;
        eng.Status__c = 'Approved';
        eng.Diagnostics_Approved__c = false;
        return eng;
        
        
    }
    
    private static  Deal_registration__c createdealreg(){
       User partnerUser = [Select Id from User WHERE Name = 'Soup User'];
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
        Contact con = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'1',null);
        System.runAs(partnerUser)
        // Create partner account with Industry
        {
            
            accountRecord.Partner_Industry__c ='Financial';
            insert accountRecord;
            
            insert con;
        } 
       
        Deal_Registration__c deal = new Deal_Registration__c();
        deal.Partner_Company_Name__c =   accountRecord.Id;
        deal.Name_of_Account_Financial_Institution__c ='ABC Inc';
        deal.End_Customer_Key_Contact_Name__c ='Raman Iyr';
        deal.Is_this_part_of_an_RFP__c =true; 
        deal.Partner_Industry__c = 'Financial';
        return deal;
     }
    
    private static Id  approvalProcess(String descion, Id objectId){
         Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest ();
         req1.setComments('Submitting request for approval.');
        System.debug('---->'+ objectId);
         req1.setObjectId(objectId);
         // Submit on behalf of a specific submitter
         req1.setSubmitterId(Userinfo.getUserId());
         // Submit the approval request for the account
        Approval.process(req1);
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('test' );
        req2.setAction(descion);
        ProcessInstanceWorkitem workItem  =[ Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: objectId];
        req2.setWorkitemId(workItem.id);
        Approval.ProcessResult result  = Approval.process(req2); 
        ProcessInstanceStep  step =[Select Id from ProcessInstanceStep where ProcessInstance.TargetObjectId =: objectId AND StepStatus IN ('Approved','Rejected')];
        return step.id;
     }
    
    
    static testmethod void testEngDiagnosticFlow() {
        
      Engineers__c eng = createEngineer('Diagnostics');
      System.assertNotEquals(eng, null,'eng should not be null');
      insert eng;
      
      Id stepNodeID = approvalProcess('Approve',eng.id);  
      ModalPopUpApexController.createContact(eng);
    }
    
     static testmethod void testEngDiagnosticFlowReject() {
      Engineers__c eng = createEngineer('Diagnostics');
      System.assertNotEquals(eng, null,'eng should not be null');

      insert eng;
      Id stepNodeID = approvalProcess('Reject',eng.id);
      
    }

     static testmethod void testDealRegFlow() {
      Deal_Registration__c deal = createdealreg();
      System.assertNotEquals(deal, null,'deal should not be null');

      insert deal;
      Id stepNodeID = approvalProcess('Reject',deal.id);
      ModalPopUpApexController.sendEmailDealReg('test',stepNodeID );
    }
    
}