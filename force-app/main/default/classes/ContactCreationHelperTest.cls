@isTest
public class ContactCreationHelperTest {

    @isTest
    public static void unitTest(){
        
        List<LiveChatTranscript> chatScriptList = new List<LiveChatTranscript>();
        //List<MACC__c> maccDeploymentId = MACC__c.getall().values();
        LiveChatVisitor vc= new LiveChatVisitor();
        Insert vc;
        Id lc =NSCCommonInfoUtil.getIdOf('MACC_LiveChatDeployment');
          System.assertNotEquals(lc, null,'MACC_LiveChatDeployment Configuration not found'); 
        LiveChatTranscript obj = new LiveChatTranscript(Chat_First_Name__c = 'Test', LiveChatDeploymentId = lc, Chat_Last_Name__c = 'Chat',LiveChatVisitorId=vc.id, Chat_Email__c = 'test@chat.com');
        chatScriptList.add(obj);
        insert chatScriptList;
       // ContactCreationHelper.createContact(chatScriptList);
    }
}