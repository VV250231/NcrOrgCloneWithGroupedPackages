/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger helper class updates the Role Sets depending on Role level Hiererchy in Salesforce.
*/
trigger tableau_getsubroleid on TableauSubRoleIDs__c  (before insert,before update) {
    /* ########################################################################################################## */ 
    if(Trigger.isinsert){
        Tableau_getsubroleid_helperclass.updatescript(Trigger.new);
        Tableau_getsubroleid_helperclass.updatefields(Trigger.new);
    }
    if(Trigger.isupdate){
        Tableau_getsubroleid_helperclass.updatescript(Trigger.new);
        Tableau_getsubroleid_helperclass.updatefields(Trigger.new);
    }
    /* ########################################################################################################## */ 
}