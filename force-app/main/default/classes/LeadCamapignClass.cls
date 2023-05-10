public class LeadCamapignClass {
    public static boolean isFirst=true;
    public static String profileLabel = System.Label.Lead_Upload_Profiles;
    public	static Map<String,Lead> leadMaps = new Map<String, Lead>();
    public static  List<CampaignMember> CampaignMemberLists = new List<CampaignMember>();
    public static List<Lead> updateLeadWithCampaign = new List<Lead>();
    public static void addCampaignBasedOnLeadSource(List<lead> LeadList){
        Set<Id> leadIDSet = new Set<ID>();
        Set<String> camSet = new Set<String>();
        List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
        List<Lead> updateLeadWithCampaignRecords = new List<Lead>();
        for(Lead leadObj : LeadList){
            //leadWithCampaign.Case_Conversion_T_F__c = leadObj.Case_Conversion_T_F__c;
            if((leadObj.LeadSource__c ==LeadTriggerVariableClass.LeadSourceValue)){
                camSet.add(LeadTriggerVariableClass.LeadSource_Sales_HOS_RestaurantData);
                //                System.debug('@@@@'+camSet);
            }else if(leadObj.LeadSource__c ==LeadTriggerVariableClass.LeadSourceValue_Sales){
                camSet.add(LeadTriggerVariableClass.LeadSource_Sales_HOS_FabFive);
                //              System.debug('@@@@'+camSet);
            }
            else{
                //This functinality is used to campaign associate in Lead when CaseOrigin is Form
                camSet.add(leadObj.Campaign_Code__c);
                //            System.debug('@@@@'+camSet);
            }
        }
        Map<String,Campaign> campaignMap= new Map<String, Campaign>();
        for(Campaign camObj : [SELECT id,Campaign_Code__c from Campaign where Campaign_Code__c In:camSet]){
            //      System.debug('@@@@'+camSet);
            if(!camSet.contains(null)){
                campaignMap.put(camObj.Campaign_Code__c,camObj);
                //        System.debug('@@@@'+camSet);
            }
        }
        for(Lead l : LeadList){
            CampaignMember CampaignMemberObj = new CampaignMember();
            if(campaignMap.containsKey(l.Campaign_Code__c) || l.LeadSource__c ==LeadTriggerVariableClass.LeadSourceValue || l.LeadSource==LeadTriggerVariableClass.LeadSourceValue_Sales){
                Lead leadWithCampaign = new Lead();
                leadWithCampaign.id = l.id;
                leadWithCampaign.Campaign_Trigger_Date__c = l.CreatedDate;
                if(l.LeadSource__c ==LeadTriggerVariableClass.LeadSourceValue){
                    leadWithCampaign.CampaignTrigger__c = campaignMap.get(LeadTriggerVariableClass.LeadSource_Sales_HOS_RestaurantData).id;
                    CampaignMemberObj.CampaignId = campaignMap.get(LeadTriggerVariableClass.LeadSource_Sales_HOS_RestaurantData).id;
                }else if(l.LeadSource==LeadTriggerVariableClass.LeadSourceValue_Sales){
                    leadWithCampaign.CampaignTrigger__c = campaignMap.get(LeadTriggerVariableClass.LeadSource_Sales_HOS_FabFive).id;
                    CampaignMemberObj.CampaignId = campaignMap.get(LeadTriggerVariableClass.LeadSource_Sales_HOS_FabFive).id;
                }else{
                    leadWithCampaign.CampaignTrigger__c = campaignMap.get(l.Campaign_Code__c).id;
                    CampaignMemberObj.CampaignId = campaignMap.get(l.Campaign_Code__c).id;
                }
                CampaignMemberObj.LeadId = l.id;
                 if(l.is_Flag_Case_Conversion__c){
                    CampaignMemberObj.Status ='Responded';
                }
                //CampaignMemberObj.Status ='Responded';
                //campaignMap.put(camObj.Campaign_Code__c,camObj.id);
                CampaignMemberList.add(CampaignMemberObj);
                //      System.debug('@@@@'+camSet);
                updateLeadWithCampaignRecords.add(leadWithCampaign);
            }
        }
        if(!CampaignMemberList.isEmpty()){
            insert CampaignMemberList;
        }
        Set<String> pSetIds = new Set<String>();
        for(String pId : profileLabel.split(',')){
            pSetIds.add(pId);
        }
        if(pSetIds.contains(userinfo.getProfileId())){
            if(!updateLeadWithCampaignRecords.isEmpty())
                update updateLeadWithCampaignRecords;
        }
    }
    public static void updateAddCampaignBasedOnLeadSource(List<lead> LeadList){
        Map<String,Id> leadMap = new Map<String, Id>();
        Map<Id, CampaignMember> CampaignMemberMap = new Map<Id, CampaignMember>();
        List<CampaignMember> CampaignMemberList1 = new List<CampaignMember>();
        Set<Id> leadIDSet = new Set<ID>();
        for(Lead leadObj : LeadList){
            leadIDSet.add(leadObj.Id);
        }
        for(Lead leadObj : [SELECT Campaign_Code__c, id,LeadSource__c From Lead Where id In: leadIDSet]){
            if((leadObj.LeadSource__c ==LeadTriggerVariableClass.LeadSourceValue)){
                leadMap.put(LeadTriggerVariableClass.LeadSource_Sales_HOS_RestaurantData, leadObj.id);
            }else if(leadObj.LeadSource__c ==LeadTriggerVariableClass.LeadSourceValue_Sales){
                leadMap.put(LeadTriggerVariableClass.LeadSource_Sales_HOS_FabFive, leadObj.id);
            }
        }
        Integer i=0;
        for(CampaignMember CampaignMemberObj : [Select CampaignMember.Campaign.Campaign_Code__c,CampaignMember.Campaign.Id,leadId,leadSource from CampaignMember where  leadId =:leadIDSet]){
            if(CampaignMemberObj.Campaign.Campaign_Code__c ==LeadTriggerVariableClass.LeadSource_Sales_HOS_RestaurantData || CampaignMemberObj.Campaign.Campaign_Code__c==LeadTriggerVariableClass.LeadSource_Sales_HOS_FabFive)
                CampaignMemberList1.add(new CampaignMember(id=CampaignMemberObj.id));
            i=1;
        }
        if(i==1){
            List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
            for(Campaign camObj : [SELECT id,Campaign_Code__c from Campaign where Campaign_Code__c =:leadMap.keySet()]){
                CampaignMember CampaignMemberObj = new CampaignMember();
                if(!leadMap.keyset().contains(null)){
                    CampaignMemberObj.CampaignId = camObj.id;
                    CampaignMemberObj.LeadId = leadMap.get(camObj.Campaign_Code__c);
                    CampaignMemberList.add(CampaignMemberObj);
                }
            }
            if(!CampaignMemberList.isEmpty()){
                insert CampaignMemberList;
            }
        }else if(CampaignMemberList1.size()==0){
            List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
            for(Campaign camObj : [SELECT id,Campaign_Code__c from Campaign where Campaign_Code__c =:leadMap.keySet()]){
                CampaignMember CampaignMemberObj = new CampaignMember();
                if(!leadMap.keyset().contains(null)){
                    CampaignMemberObj.CampaignId = camObj.id;
                    CampaignMemberObj.LeadId = leadMap.get(camObj.Campaign_Code__c);
                    CampaignMemberList.add(CampaignMemberObj);
                }
            }
            if(!CampaignMemberList.isEmpty()){
                insert CampaignMemberList;
            }
        }
        delete CampaignMemberList1;
    }
}