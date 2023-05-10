trigger RMA_Trigger on RMA__c (before Insert, after insert) {
    
    if (Trigger.IsBefore) {
        //populate partner account and contact
        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        for (RMA__c rma : Trigger.New) {       
            if(rma.Account__c == null && u.AccountId != null) {
                rma.Account__c = u.AccountId;
            }
            
            if (rma.Contact__c == null && u.ContactId != null) {
                rma.Contact__c = u.ContactId;
            }     
        }
    } else if (Trigger.isAfter) {
        list<Case> caseToInsert = new list<Case>();
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Partner_Assist').getRecordTypeId();
        
        for (RMA__c r : Trigger.new){
            Case c = new Case();
            c.Status = 'New';
            c.subject = r.Name;
            c.RecordTypeId = caseRecTypeId;
            c.Is_Partner_Assist_Team_Case__c = true;
            caseToInsert.Add(c);
            c.RMA__c = r.Id;
        }
        insert caseToInsert;
    }
}