trigger PRM_MdfClaimTrigger on SFDC_MDF_Claim__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new PRM_MdfClaimDispatcher().run();
}