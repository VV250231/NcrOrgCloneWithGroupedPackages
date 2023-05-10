public class caseDetailsOnChatPageController {

    @AuraEnabled
    public static List<sObject> searchExistingCase(id chatid){
        List<sObject> returnlist= new List<sObject>();
        String Query='select CaseId,Chat_Email__c from LiveChatTranscript where id = :chatid LIMIT 1';
       	List<sObject> caselist=Database.Query(Query);       
        System.debug('@@@@'+caselist);
        if(caselist.size() > 0)
        	{ returnlist = caselist; }           
        return returnlist;
    }

}