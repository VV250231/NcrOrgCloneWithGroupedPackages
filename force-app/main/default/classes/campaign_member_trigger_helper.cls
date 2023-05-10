public class campaign_member_trigger_helper{
    //public static id eloquaadminid = '0050g000006HruFAAS';
    ////Changes done by Yogesh - related to Story EBA_SF-1919 
    public static id mKTUsrId =System.Label.Marketo_Us; 
    //campaign members fields : id,LeadId,CampaignId,LastModifiedDate,CreatedDate,Status,FirstRespondedDate
    public static void sub_dispatcher(List<CampaignMember> triggernew){
        
        List<Lead> lead_list = new List<Lead>();
        List<Id> leadList = new List<Id>();
        List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
        List<Id> leadList1 = new List<Id>();
        List<CampaignMember> CampaignMemberList1 = new List<CampaignMember>();
        Map<id,id> leadid_map = new Map<id,id>();
        Map<id,CampaignMember> leadids = new Map<id,CampaignMember>();
        //below logic is to update the lead, with triggered campaign. First campaign which lead was associated by, will be campaign triggered
        for(CampaignMember cm : triggernew){
            leadids.put(cm.leadid,cm);
            leadList.add(cm.leadid);
            CampaignMemberList.add(cm);
            leadList1.add(cm.leadid);
            CampaignMemberList1.add(cm);
        }
        for(CampaignMember cm : triggernew){
            if(!leadids.containsKey(cm.leadid) && UserInfo.getUserId() == mKTUsrId){
                leadid_map.put(cm.leadid,cm.CampaignId); 
            }
        }
        if(leadid_map.size()>0){ 
            for(Lead l : [Select id,CreatedById from Lead where CreatedById=: mKTUsrId AND id IN:leadid_map.keyset() limit 50000]){
                l.CampaignTrigger__c = leadid_map.get(l.id) ;
                l.Campaign_Trigger_Date__c=datetime.now();
                lead_list.add(l);
            }
        }
        
        if(lead_list.size()>0){
            update lead_list ;
        }
    }
    //End Changes 
}