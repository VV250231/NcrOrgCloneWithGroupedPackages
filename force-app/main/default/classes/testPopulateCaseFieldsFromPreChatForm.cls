@isTest
private class testPopulateCaseFieldsFromPreChatForm {    
    static testMethod void PopulateCaseFieldsFromPreChatForm() { 
        Test.startTest();
        LiveChatVisitor vc= new LiveChatVisitor();
        Insert vc;          
        List<String> rid = new List<String>();
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();    		
        Case caseObj = new Case(RecordTypeId=CaseRecordTypeId,Chat_User_Email__c = 'test@test.com',Subject='Test', Description='Test',Origin='Forms');
       	insert caseObj;
        if(caseObj.RecordTypeId == CaseRecordTypeId)
        rid.add(caseObj.id);
      	
       // if(rid.size()>0){
        LiveChatTranscript lc = new LiveChatTranscript
            			(
                         Chat_Last_Name__c = 'TestAgent',
                         Chat_First_Name__c= 'TestAgent',
                         Chat_Email__c= 'Testagent@123.com',
                         Chat_Subject__c= 'Test',
                         Chat_Phone__c='123421',
                         LiveChatVisitorId=vc.id,
                         CaseId=rid[0]);
       
        
        // Insert Chatdata
        insert lc; 
  		caseObj.Subject='test2';
        update caseObj;
    //    List <LiveChatTranscript> livechat = [SELECT Id,Chat_Last_Name__c,Chat_First_Name__c,Chat_Email__c,Chat_Subject__c,Chat_Phone__c FROM LiveChatTranscript WHERE CaseId in : rid];             

		
        // Retrieve the new chat
        lc = [SELECT Id,Chat_Last_Name__c,Chat_First_Name__c,Chat_Email__c,Chat_Subject__c,Chat_Phone__c FROM LiveChatTranscript WHERE Id =:lc.Id];    
        Case ch= new Case(Subject='Test',
                         Description__c='Test Desc',
                         LiveChatTranscriptId__c=lc.Id);  
        
        // Insert Casedata
          insert ch; 
          System.assertNotEquals(ch.id, null,'Case Record Should not be null');
        Test.stopTest();
    }
    private static testMethod void PopulateCaseIDFromPreChatForm() {  
         Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();    		
       
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(RecordTypeId = CaseRecordTypeId,Chat_User_Email__c = 'test@test.com',Subject='Test', Description='Test',Origin='Forms'));
        insert caseList;
        List<Lead> leadList = new List<Lead>();
        leadList.add(new Lead(LastName='Test', Email = 'test@test.com',Company='Test',Industry__c='Test'));
        insert leadList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(LastName='Test', Email ='test@test.com'));        
        insert contactList;
      	List<String> idStr = new List<String>();
        List<Case> obj = [SELECT Chat_User_Email__c, id From Case Where Chat_User_Email__c='test@test.com'];
        idStr.add(obj[0].Chat_User_Email__c);
        List<Lead> lList = [Select id,email,Name from Lead where email = :idStr LIMIT 1];
        System.assertNotEquals(lList[0].id, null,'lList Record Should not be null');
        caseList = new List<Case>();
        List<Contact> cList = [Select id,email,Name from Contact where email = :idStr LIMIT 1];
        for(Case c : Obj){
            c.LeadId__c = lList[0].id;
            c.ContactId = cList[0].id;
            caseList.add(c);
        }
        update caseList;
    }
    //}
}