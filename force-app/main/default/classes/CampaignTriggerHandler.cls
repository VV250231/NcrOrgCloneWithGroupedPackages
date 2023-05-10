/*
##################################################################################################                                                  
# Created by................: Dev Admin                                                                   
# Created Date...........: 24-11-2021                                                                                
# Last Modified by......: Stuti Srivastava
# Description...............: In insertMethod at line no 37 function updates the Lead Source Field to 'Phone Inquiry' when '2021_MarketingInboundCalls_Campaign_Hospitality' get attached
# Story.......: EBA_SF-1645 HOSP SMB: Lead updates                                
################################################################################################
*/
public class CampaignTriggerHandler {
    public static boolean isFirst=true;
    public static String profileLabel = System.Label.Lead_Upload_Profiles;
    public static String camId = System.Label.a2021_MarketingInboundCalls_Campaign_Hospitality;
    public static String recTyp = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer Lead').getRecordTypeId();
    /*  public static void UpdateMethod(CampaignMember camMem){
commonMethod(camMem);
}*/
    public static void insertMethod(List<CampaignMember> camMem){
        Boolean isFlag=false;
        Map<Id, Id> leadCamMap = new Map<Id, Id>();
        Set<id> cIds = new Set<Id>();
        List<lead> lList = new List<lead>();
        for(CampaignMember c : camMem){
            cIds.add(c.id);
        }
        if(!cIds.isEmpty()){
            for(CampaignMember camMemObj :[Select Id,CampaignMember.Campaign.Campaign_Code__c,CampaignMember.Campaign.Id,leadId,leadSource from CampaignMember where Id In: cIds]){
                leadCamMap.put(camMemObj.LeadId, camMemObj.Campaign.Id);
            }
        }
        for(Lead lObj :[Select id, Campaign_Code__c, RecordTypeId, CampaignTrigger__c, lenos_campaign__c,createdDate from Lead where id In:leadCamMap.KeySet()]){
            Lead l = new Lead();
            l.id = lObj.id;
            if(lObj.CampaignTrigger__c==null){
                l.Campaign_Trigger_Date__c = lObj.createdDate;
                l.CampaignTrigger__c = leadCamMap.get(lObj.Id);
            }
            /*****Stuti - EBA_SF-1645 start****/
            if(leadCamMap.get(lObj.Id)==camId && lObj.RecordTypeId == recTyp){
                l.LeadSource__c ='Phone Inquiry'; 
                isFlag = true;
            }
            /*****Stuti - EBA_SF-1645 start****/
            lList.add(l);
            
        }
        /* CampaignMemberStatus cms1 = new CampaignMemberStatus(); 
for (CampaignMemberStatus cms: [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
FROM CampaignMemberStatus
WHERE CampaignID in : leadCamMap.Values()]){
cms1.id=cms.id;               
cms1.Label ='Sent11';
//cms1.HasResponded = true;
// cms1.IsDefault =false;
//cms1.SortOrder =1;
//cms1.CampaignId = cms.CampaignId;               
System.debug('@@@CC'+cms1);
}
update cms1;*/
        if(!lList.isEmpty()){
            Set<id> pSetIds = new Set<Id>();
            //  if(!String.isBlank(profileLabel)){
            for(String pId : profileLabel.split(',')){
                pSetIds.add(pId);
            }
            //  }
            if(pSetIds.contains(userinfo.getProfileId()) || isFlag == true){
                update lList;
            }
        }
    }
}