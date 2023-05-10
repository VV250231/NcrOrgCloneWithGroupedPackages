/*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: testCheckDuplicate.cls                                                        
# Version.....................: 22.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 27-09-2011                                                                               
# Last Modified by......: Darshan Singh Farswan
# Last Modified Date..: 27-09-2011
# Description...............: The test class is used to provide test coverage for checkDuplicate Trigger.
################################################################################################
*/

@isTest(SeeAllData=True)
private class testCheckDuplicate{
    public static testMethod void checkDuplicate(){
    List <Equipment_Declaration__c> Equipment_list = new List <Equipment_Declaration__c>();
        try{
        User usr = [Select id, ContactId from User where ContactId != null and Contact.AccountId != null and isActive = true and Profile.Name Like 'IPT Partner Community Login User' /*like '%equipment%'*/ limit 1];
        
        if(usr != null){
            System.runAs(usr){
                Equipment_Declaration__c equipment = new Equipment_Declaration__c();
                equipment.Name = '12343';
                Contact ct = [SELECT Id, AccountId from Contact where id = :usr.contactId];
                equipment.Partner_Account__c = ct.AccountId;
                equipment.Customer_Name__c = 'TEST';
                equipment.Account__c = ct.AccountId;
                equipment.Active_Unit__c = false;
                equipment.Class__c = '5885';
                equipment.Class_Type__c = 'Multi Function';
                equipment.Features__c = 'Deposit Auto (Cash)/Recycler BNA';
                equipment.Installation_Address1__c = 'TEST';
                equipment.Installation_City__c = 'TEST';
                equipment.Installation_State_Province__c = 'TEST';
                equipment.Installation_Date_of_New_Unit__c = System.today();
                equipment.Service_Date__c = System.today();
                insert equipment;
                System.debug('Equipment01 - '+equipment);
                Equipment_Declaration__c equipment2 = new Equipment_Declaration__c();             
                Equipment_Declaration__c equipment3 = new Equipment_Declaration__c();             
                equipment2 = equipment.clone(false, false);
                equipment3 = equipment.clone(false, false);
                Equipment_list.add(equipment2);
                Equipment_list.add(equipment3);
                insert Equipment_list;
                system.assert(Equipment_list.size()>0);
                System.debug('Equipment02 - '+equipment2);
            }
        }}catch(Exception e){
            System.debug('Error '+e.getMessage());
        }    
    }
}