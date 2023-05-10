@isTest
public class caseDetailsOnChatPageControllerTest {
	@isTest
    private static void caseDetailsOnChatPageControllerUnitTest(){
        LiveChatVisitor vc= new LiveChatVisitor();
        Insert vc;
         LiveChatTranscript lc = new LiveChatTranscript
            			(
                         Chat_Last_Name__c = 'TestAgent',
                         Chat_First_Name__c= 'TestAgent',
                         Chat_Email__c= 'Testagent@123.com',
                         Chat_Subject__c= 'Test',
                         Chat_Phone__c='123421',
                         LiveChatVisitorId=vc.id
                         );
       
        
        // Insert Chatdata
        insert lc; 
        
          System.assertNotEquals(lc.id, null,'LiveChatTranscript with TestAgent name not found'); 
        caseDetailsOnChatPageController.searchExistingCase(lc.id);
    }
}