public class ContactCreationHelper {
    public static void createContact(List<LiveChatTranscript> chatList){
        Set<String> emails = new Set<String>();
        List<LiveChatTranscript> macChats = new List<LiveChatTranscript>();
        String LiveChatButtonIdLabel = System.Label.LiveChatButtonId;
        String LiveChatNCRAccountIdLabel = System.Label.LiveChatNCRAccountId;
        for(LiveChatTranscript chatObj: chatList ){ 
            if(chatObj.LiveChatDeploymentId== LiveChatButtonIdLabel){
                //old- 5731F000000CafK
                	//5731F000000CafKQAS
               if(!String.isBlank(chatObj.Chat_Email__c)){					   
                emails.add(chatObj.Chat_Email__c);
                System.debug('@@@iddd'+emails);
                macChats.add(chatObj);
               }
            }
        }
        List<Contact> existingContacts = new List<Contact>();
        existingContacts = [SELECT Id, Name, Email FROM contact WHERE email IN : emails];        
        Map<String,Contact> emailToConMap = new Map<String,Contact>();
        for(Contact c : existingContacts) {
            emailToConMap.put(c.Email, c);
        }
        List<Contact> contactToCreate = new List<Contact>();
        for(LiveChatTranscript chatObj: macChats ){ 
            if(emailToConMap.get(chatObj.Chat_Email__c) == null) {
                contact con = new contact();
                con.LastName = chatObj.Chat_Last_Name__c;
                con.FirstName = chatObj.Chat_First_Name__c;
                con.Email = chatObj.Chat_Email__c; 
                con.AccountId=LiveChatNCRAccountIdLabel;
                contactToCreate.add(con);
                System.debug('@@@@'+contactToCreate);
            }
        }        
        if (contactToCreate.size() > 0) {
           //if(existingContacts==null)
                insert contactToCreate;
            System.debug('@@@@@@'+contactToCreate);
        }
        
    }  
}