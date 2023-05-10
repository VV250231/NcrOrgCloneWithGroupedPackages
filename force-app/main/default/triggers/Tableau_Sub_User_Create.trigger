/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger helper class manages the Tableau users
*/
trigger Tableau_Sub_User_Create on TableauUser__c (before insert, before update) {
/* ########################################################################################################## */ 
    if(Trigger.Isinsert){
    Tableau_Sub_User_Create_Helper.create_sub_users(Trigger.new);
    }
/* ########################################################################################################## */ 
    if(Trigger.IsUpdate){
    Tableau_Sub_User_Create_Helper.deleteallexisting(Trigger.new);
    Tableau_Sub_User_Create_Helper.create_sub_users(Trigger.new);
    }
/* ########################################################################################################## */ 
}