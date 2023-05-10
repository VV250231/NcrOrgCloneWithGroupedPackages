/****************************************************************************************************************
*   TriggerName :   blockDeletion
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1788     02 Feb 2022     Kapil Bhati         Removed hardcoded admin profile Ids

****************************************************************************************************************/
trigger blockDeletion on Sales_org_Code_Mapping__c (before delete, after update) {
    if(Trigger.isDelete){
        
        // Set<Id>AdminIDs = new Set<Id>{'00e700000013gPe','00e700000013gPeAAI','00e70000000x3eg','00e70000000x3egAAA','00e70000000sR8U','00e70000000sR8UAAU','00e700000013YgP', '00e700000013YgPAAU'};
        // EBA_SF-1788  Removed hardcoded admin profile Ids- Modified by Kapil Bhati 
        Set<Id>AdminIDs = NSCCommonInfoUtil.getIdSetOf('Admin_Ids');
        //NEW LIGHTNING CLONE PROFILE ID
        //Set<Id>AdminIDsLTNG = new Set<Id>{};
        
        //Adding new profile ids with old one
        //AdminIDs.addAll(AdminIDsLTNG);
        Integer k;
        
        For(k=0;k<10;k++){
            k=k+1;
        }
        if(!AdminIDs.contains(UserInfo.getProfileId())){
            for(Integer i=0; i<Trigger.size; i++){
                Trigger.old[i].addError(system.label.block_dltn1);
            }
            //Error msg for Custom label block_dltn1
            //You do not have access to delete these records. Only System Administrators can delete these records.
        }
    }
    //Empty If statement was commented
    //if(Trigger.isUpdate){
    /*List<Id> salesOrgId=new List<Id>();
List<Compensation_Team_Member__c> ctm;
for(Sales_org_Code_Mapping__c spm: Trigger.new ){
salesOrgId.add(spm.Id);
}
if(salesOrgId.size()>0){
ctm=[select Id from Compensation_Team_Member__c where Sales_org_Code__c in :salesOrgId];
}
if(ctm.size()>0){
update ctm;
}*/
    //}    
}