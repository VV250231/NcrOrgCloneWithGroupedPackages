public without sharing class listViewController {
 
    @auraEnabled
    public static List<Case> getCaseList(){  
        String closeTheloopChildRecordTypeId= System.Label.closetheloopchild;
        List<String> userQueue = new List<String>();
        List<String> userQueueids = new List<String>();
        List<Case> caseList = new List<Case>();
        String CurrentUserId=UserInfo.getUserId();
        system.debug('CurrentUserId@@@@: '+CurrentUserId); //0050g000005Y66wAAC
        for (GroupMember ocr : [Select Group.Name from GroupMember where UserOrGroupId = :CurrentUserId and Group.Type = 'Queue'])
            userQueue.add(ocr.Group.Name);
        
        //find the userids for the above queue
        for (User udis : [SELECT name,id FROM User WHERE Id IN (SELECT UserorGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND Group.Name IN :userQueue) AND isActive = true]){
            userQueueids.add(udis.id);
        }
        for(Case caseObj : [Select id,casenumber,Contact.Name,Subject,Status,OwnerId,Owner.Name,Owner_Name__c,Priority,createdDate From Case Where 
                            (OwnerId In:userQueueids or Owner.Name In:userQueue) and RecordTypeId=:closeTheloopChildRecordTypeId order by createdDate ASC] ){
            caseList.add(caseObj);
        } 
        System.debug('@@@@'+caseList);
        return caseList;
    }
}