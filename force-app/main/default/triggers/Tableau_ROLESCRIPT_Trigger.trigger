/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger updates the User Sets depending on Role level Hiererchy in Salesforce.
*/
trigger Tableau_ROLESCRIPT_Trigger on Tableau__c (before insert,before update) {
    /* ########################################################################################################## */ 
    if(Trigger.isinsert){
        Tableau_getuserset_helperclass.updatescript(Trigger.new);
        Tableau_getuserset_helperclass.updatefields(Trigger.new);
    }
    if(Trigger.isupdate){
        Tableau_getuserset_helperclass.updatescript(Trigger.new);
        Tableau_getuserset_helperclass.updatefields(Trigger.new);
    }
    /* ########################################################################################################## */ 
}