trigger blockDuplicatePartnerQuickview on Partner_Quickview__c (before insert,before update) {
    Set<String> accRecTypeSet=new Set<String>();
    List<Id> accountNames=new List<Id>();
    Set<String> currentBatch=new Set<String>();
    for(Partner_Quickview__c newPartnerQuickview : Trigger.new){
        String accRecType = String.valueOf(newPartnerQuickview.Account_Name__c) + String.valueOf(newPartnerQuickview.RecordTypeId);
        if(currentBatch.contains(accRecType)){
            newPartnerQuickview.adderror(system.label.BlockDuplicateAcctRtyp1);
        }
        else{
            currentBatch.add(accRecType);
            accountNames.add(newPartnerQuickview.Account_Name__c);
        }
    }
    List<Partner_Quickview__c> partQuickviewList=new List<Partner_Quickview__c>([SELECT Id,Account_Name__c,RecordTypeId from Partner_Quickview__c where Account_Name__c in :accountNames ]);
    for(Partner_Quickview__c oldPartnerQuickview: partQuickviewList ){
        String accRecType=String.valueOf(oldPartnerQuickview.Account_Name__c)+(String.valueOf(oldPartnerQuickview.RecordTypeId)); 
        accRecTypeSet.add(accRecType);
    }
    for(Integer i =0; i<Trigger.new.size(); i++){
            String accRecType=String.valueOf(Trigger.new[i].Account_Name__c)+(String.valueOf(Trigger.new[i].RecordTypeId));
            System.debug('darshan01-'+accRecTypeSet);
            System.debug('darshan02-'+accRecType); 
            if(accRecTypeSet.contains(accRecType))
            {
                if (Trigger.IsInsert){
                    Trigger.new[i].adderror(system.label.BlockDuplicateAcctRtyp1);
                }
                else{
                    if(Trigger.new[i].Account_Name__c != Trigger.old[i].Account_Name__c || Trigger.new[i].RecordTypeId!= Trigger.old[i].RecordTypeId)
                    {
                        Trigger.new[i].adderror(system.label.BlockDuplicateAcctRtyp1);
                    }
                    //Error msg for custom label - BlockDuplicateAcctRtyp1 
                    //Record already exists with same Account Name and Record Type. Please provide different Record Type or Account Name
                }
            }
        }
}