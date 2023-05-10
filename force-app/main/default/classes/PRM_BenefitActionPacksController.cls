public with sharing class PRM_BenefitActionPacksController {
    /* Created By : Ritesh Kumar
    * @Desc : This Classs is usend in prmDenefitActionPacks LWC. 
    */


    /* @Created By : Ritesh Kumar.
    *  @Method Type : AuraEnabled. 
    *  @Method Name : getChannelBenefitActionPackMap
    *  @Method Param : No param
    *  @Method Desc : This Method return the Map of Benefit Action  packs. 
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Channel_Benefit_Action_Packs__c>> getChannelBenefitActionPackMap(){
        Map<String,List<Channel_Benefit_Action_Packs__c>> ChannelBenefitActionPackMap = new Map<String,List<Channel_Benefit_Action_Packs__c>>();
        
        //for loop is used to fill the map. 
        for(Channel_Benefit_Action_Packs__c benefitActionPack : [SELECT URL__c, Sequence_Number__c, Brief_Description__c, Action_Pack_Category__c, Id, Name FROM Channel_Benefit_Action_Packs__c ORDER BY Sequence_Number__c ASC]){
           
           //Checking benefir action pack category. 
            if(benefitActionPack.Action_Pack_Category__c != null){
               
                // geting action pack category values from map
                if(ChannelBenefitActionPackMap.containsKey(benefitActionPack.Action_Pack_Category__c)){
                    
                    //creating tempBenefitActionPackList and adding action pack category values to the list. 
                    //Customize by Naman Kumar 
                    ChannelBenefitActionPackMap.get(benefitActionPack.Action_Pack_Category__c).add(benefitActionPack);                       
                }else{
                    //maping the record in ChannelBenefitActionPackMap where   Action_Pack_Category__c is key and new List as value
                    ChannelBenefitActionPackMap.put(benefitActionPack.Action_Pack_Category__c, new List<Channel_Benefit_Action_Packs__c>{benefitActionPack});
                }
            }
        }
        // Return ChannelBenefitActionPackMap.
        return ChannelBenefitActionPackMap;
    }
}