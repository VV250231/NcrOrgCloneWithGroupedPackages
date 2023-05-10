/*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: checkDuplicate.cls                                                        
# Version.....................: 22.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 21-09-2011                                                                               
# Last Modified by......: Darshan Singh Farswan and Ajay Dixit
# Last Modified Date..: 03-01-2012
# Description...............: This trigger will prevent the Users from making duplicate Engineers (having same Serial Number and Partner Account)
################################################################################################
*/
trigger checkDuplicate on Equipment_Declaration__c (before insert) {
    Set <String> NameAndAccount = new Set<String>();
    Set <String> currentBatch =new Set<String>();
    for (Equipment_Declaration__c equipment : Trigger.new){
        if(currentBatch.contains(equipment.NameAndAccount__c))
    {
        equipment.adderror(system.label.chk_dup1);
    }
    else{
        currentBatch.add(equipment.NameAndAccount__c);        
    }
    }
    List<Equipment_Declaration__c> existingEquipment = [Select Id, NameAndAccount__c from Equipment_declaration__c where NameAndAccount__c in :currentBatch];
    System.debug('Heap Size - '+Limits.getHeapSize());
    if(existingEquipment!= null && existingEquipment.size()>0){
        for(Equipment_Declaration__c ed : existingEquipment ){
            NameAndAccount.add(ed.NameAndAccount__c);
        }
        for(Equipment_Declaration__c equipment : Trigger.New){    
            if(NameAndAccount.contains(equipment.NameAndAccount__c)){
                equipment.adderror(system.label.chk_dup1);    
            }
        }
    }
    //Error msg for Custom label chk_dup1
    //Record already exists with same Serial Number and Partner Account. Please provide different Serial Number.
}