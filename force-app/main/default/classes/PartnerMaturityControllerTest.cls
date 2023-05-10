@isTest(seeAllData = true)
private class PartnerMaturityControllerTest{

    static testMethod void myTest() {
        Account acc;
        System.runAs(TestRecordsFactory.getUser()) {
            acc=TestRecordsFactory.createAccount();
            
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            Schema.RecordTypeInfo partnerRT =  rtMapByName.get('Partner');
            acc.RecordTypeId = partnerRT.getRecordTypeId();
            update acc;
        }
    
        PartnerMaturityController.getStatusPickListVals();
        List<PartnerMaturityController.MaturityLevelWrapper> partMatLvls = PartnerMaturityController.getPartnerMaturityLevels(acc.Id);
        PartnerMaturityController.MaturityLevelWrapper pmlWrap = partMatLvls.get(0);
        User approver = [Select Id from User where UserType='Standard' and isActive=true Limit 1].get(0);
        
        for(PartnerMaturityController.MaturityActionWrapper pms : pmlWrap.actionsList) {
            pms.dateCompleted = String.ValueOf(Date.today());
            pms.status = 'Green';
            pms.actionOwner = 'test owner';
            pms.estCompleteDate = String.ValueOf(Date.today());
            pms.actionComments = 'test';
            pms.helptext ='test';
            
        }
       
        PartnerMaturityController.saveCurrentMatLevel(pmlWrap.level, acc.Id, JSON.serialize(pmlWrap.actionsList));
        String levelId = [SELECT Id, Approval_Status__c from Partner_Maturity_Level__c WHERE Name=:pmlWrap.level and Account__c = :acc.Id LIMIT 1].get(0).Id;
        
        Partner_Maturity_Level__c pml = [SELECT Id, Approval_Status__c from Partner_Maturity_Level__c WHERE Name =:pmlWrap.level and Account__c = :acc.Id LIMIT 1];
        System.debug('111111111' + pml.Approval_Status__c);
        
        Partner_Maturity_Level__c matLvl1 = new Partner_Maturity_Level__c (Id=levelId ,Account_Owner_Manager__c = approver.Id);
        update matLvl1 ;
        System.assertEquals(matLvl1.id,levelId);
         
        PartnerMaturityController.submitForApproval(acc.Id, pmlWrap.currentMatlevel);
        PartnerMaturityController.getPartnerMaturityStatusList(levelId );
        
        ProcessInstanceWorkitem workItem = [Select Id,ActorId from ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :levelId  ORDER BY CreatedDate DESC LIMIT 1];
        
        Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
        req1.setComments('Approving request.');
        req1.setAction('Approve');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req1.setWorkitemId(workItem.Id);
        Approval.ProcessResult result1 =  Approval.process(req1);
        
        workItem = [Select Id,ActorId from ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :levelId  ORDER BY CreatedDate DESC LIMIT 1];
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(workItem.Id);
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        pml = [SELECT Id, Approval_Status__c from Partner_Maturity_Level__c WHERE Name =:pmlWrap.level and Account__c = :acc.Id LIMIT 1];
        System.debug('222222' + pml.Approval_Status__c);
    }
}