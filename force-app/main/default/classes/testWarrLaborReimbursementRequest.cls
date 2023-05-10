/*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: testWarrLaborReimbursementRequest.cls                                                        
# Version.....................: 22.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 08-09-2011                                                                               
# Last Modified by......: Darshan Singh Farswan
# Last Modified Date..: 17-11-2011
# Description...............: The test class is used to provide test coverage for WarrLaborReimbursementRequest class.
################################################################################################
*/


@isTest(SeeAllData= true)
private class testWarrLaborReimbursementRequest{
    static testMethod void testRequest(){
        User[] usr = [Select id, ContactId from User where ContactId != null and Contact.AccountId != null and isActive = true limit 1];
        if(/*usr != null*/ usr.size()>0){
            System.runAs(usr[0]){
                PageReference currentPage= Page.WarrLaborReimbursementRequest;
                Test.setCurrentPage(currentPage);
                Equipment_Declaration__c equipment = new Equipment_Declaration__c();
                equipment.Name = '12343';
                Contact ct = [SELECT Id, AccountId from Contact where id = :usr[0].contactId];
                equipment.Partner_Account__c = ct.AccountId;
                equipment.Customer_Name__c = 'TEST Customer';
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
                ApexPages.standardController sc1 = new ApexPages.StandardController(equipment);
                WarrLaborReimbursementRequest rr1 = new WarrLaborReimbursementRequest(sc1);
                PageReference pgObj = rr1.createWarrLabourReimbursementObj();
                System.assert(pgObj!=null);
                //rr1.sendMail();
                rr1.cancel();
                equipment.Active_Unit__c = true;
                update equipment;
                ApexPages.standardController sc2 = new ApexPages.StandardController(equipment);
                WarrLaborReimbursementRequest rr2 = new WarrLaborReimbursementRequest (sc1);
                Equipment_Declaration__c equipment2 = new Equipment_Declaration__c();
            }
        }
    }
}