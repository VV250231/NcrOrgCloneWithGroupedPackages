/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger updates the Sales Org Sharing Model depending on Sharing Rules defined in Salesforce on Sales Org Object.
*/
trigger Tableau_getsalesorg on Tableau_SalesOrg__c(before insert,before update) {

 /* ########################################################################################################## */

if(Trigger.IsInsert){
Tableau_getsalesorg_helperclass.updatefields(Trigger.new);
Tableau_getsalesorg_helperclass.updatescript(Trigger.new);
}
 /* ########################################################################################################## */

if(Trigger.IsUpdate){
Tableau_getsalesorg_helperclass.updatefields(Trigger.new);
Tableau_getsalesorg_helperclass.updatescript(Trigger.new);
}
 /* ##########################################################################################################  */

}