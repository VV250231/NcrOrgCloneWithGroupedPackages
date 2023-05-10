/*##################################################################################################
# Description...........: This class is for CEC functionality.
# Created by......: Sushant, Saurav, Yogesh, Monika 
# Created Date....: Nov 2021.  
# Story Number ......: EBA_SF-1607 , EBA_SF-1606 , EBA_SF-1605 , EBA_SF-1554
##################################################################################################*/
public class CECMeetingTriggerHandler {
    public static boolean isFlag=true;
    public static void updateStatus(List<Cec__c> cecLst){
        Set<Id> cecLstOpp = new Set<Id>();
        boolean flagCec=false;
        Id oppId;
        Id campId = NSCCommonInfoUtil.getIdOf('CEC_Campaign_id');
        for(CEC__c cecObj:cecLst){
            if(cecObj.Meeting_Status__c =='Cancelled' || cecObj.Meeting_Status__c =='Declined'){
                cecLstOpp.add(cecObj.id);
                oppId=cecObj.Opportunity__c;
            }
        }
        Set<Id> oppCECLst = new Set<Id>();
        for(OpportunityAndCECObject__c Obj : [Select id,CEC_Meeting__c,Opportunity__c from OpportunityAndCECObject__c where Opportunity__c=:oppId]){
            oppCECLst.add(obj.CEC_Meeting__c);
        }
        for(CEC__c cecObj : [Select id, Opportunity__c,Meeting_Status__c from CEC__c where id IN: oppCECLst]){
            if(!cecLstOpp.contains(cecObj.Id)){
                if(cecObj.Meeting_Status__c =='Cancelled' || cecObj.Meeting_Status__c =='Declined'){
                    flagCec=false;
                }else{
                    flagCec=true;
                    break;
                }
            }
        }
        List<Opportunity> oppLst = new List<Opportunity>();
        if(flagCec==false){
            for(Opportunity opp :[Select id,CampaignId from Opportunity where Id=:oppId and CampaignId =:campId]){
                Opportunity objOpp = new Opportunity();
                if(opp.CampaignId!=null){
                    objOpp.Id = opp.id;
                    if(flagCec==false){
                        objOpp.CampaignId = null;
                        oppLst.add(objOpp);
                    }
                }
            }
        }
        if(!oppLst.isEmpty()){
            update oppLst;
        }
        List<campaignMember> camMemLst = new List<campaignMember>();
        Map<id, Id> conCecMettingMap = new Map<Id,Id>();
        System.debug('@@@@'+cecLstOpp);
        Set<Id> conIdsSet = new Set<Id>();
        for(CEC_Attendees__c obj :[Select id, CEC_Meeting__c,Attendee_Name_Contact__c  from CEC_Attendees__c where CEC_Meeting__c IN:cecLstOpp]){
            conIdsSet.add(obj.Attendee_Name_Contact__c);
        }
        System.debug('@@@@'+conIdsSet);
        if(!conIdsSet.isEmpty()){
            for(CampaignMember camObj : [Select ContactId,CEC_Meeting__c, CampaignId,Id from CampaignMember where  ContactId IN:conIdsSet and CampaignId =:campId]){
                conCecMettingMap.put(camObj.ContactId, camObj.CEC_Meeting__c);
                camMemLst.add(camObj);
            }
        }
        system.debug('@@@@@'+camMemLst);
        if(!camMemLst.isEmpty()){
            delete camMemLst;
        }
        
    }
    
}