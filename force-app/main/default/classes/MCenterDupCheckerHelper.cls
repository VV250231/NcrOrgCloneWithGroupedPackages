/*
 * Class:	MCenterDupCheckerHelper
 * Description:	This class is using as helper class for MessageCenter DupChecker trigger to pevent from Duplicacy.
 * Date:	18/9/2019
 * DeveloperName:	Deeksharth Sriwastava
*/
public  class MCenterDupCheckerHelper {
    public static void DupChecker(List<Message_Center__c> msgCentr,List<Message_Center__c> msgCentrOld){
        Set<Id> MsgIds = new Set<Id>();
        if(msgCentrOld != NUll && msgCentrOld.size()>0){
            for(Message_Center__c msg : msgCentr){
            	MsgIds.add(msg.Id);
        	}
        }
        Map<Id,Message_Center__c> msgExistLst = New Map<Id,Message_Center__c>([SELECT Id,Industry__c,Region__c,Tier_Level__c FROM Message_Center__c where Is_Active__c =: true limit 50]);
        If(msgExistLst.size()>0 && msgExistLst != NULL){
            for(Message_Center__c msgExst : msgExistLst.values()){
                for(Message_Center__c msg : msgCentr){
                    if(!MsgIds.contains(msgExst.id)){
                        if(msg.Industry__c == msgExst.Industry__c && msg.Region__c == msgExst.Region__c && msg.Tier_Level__c == msgExst.Tier_Level__c){
                            msg.addError(system.label.MCntrDup1);//lRecord with the same combination was already exist.
                        }
                    }
                }
            }
        }
    }
}