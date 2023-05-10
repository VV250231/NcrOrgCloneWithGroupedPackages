/*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: testPrometricVoucherRequest.cls                                                        
# Version.....................: 22.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 26-08-2011                                                                               
# Last Modified by......: Darshan Singh Farswan
# Last Modified Date..: 19-09-2011
# Description...............: The test class is used to provide test coverage for PrometricVoucherRequest class.
################################################################################################
*/

@isTest(SeeAllData= true)
private class testPrometricVoucherRequest{
    static testMethod void testrequest(){
        User[] usr = [Select id from User where ContactId != null and Contact.AccountId != null and isActive = true limit 1];
        if(/*usr != null*/ usr.size()>0)
            System.runAs(usr[0]){
                PageReference currentPage= Page.PrometricVoucherRequest;
                Test.setCurrentPage(currentPage);
                Engineers__c engineer = new Engineers__c();
                engineer.Active_Engineer__c = false;
                engineer.Last_Name__c = 'Test';
                engineer.First_Name__c = 'Test';
                engineer.Email_Address__c = 'test@test.com';
                engineer.City__c = 'Test';
                engineer.State_Province__c = 'Test';
                engineer.Certified__c = true;
                engineer.Certification_Deadline__c = System.today()-1;
                insert engineer;
                ApexPages.standardController sc1 = new ApexPages.StandardController(engineer);
                PrometricVoucherRequest pvr1 = new PrometricVoucherRequest(sc1);
                pvr1.sendMail();
                pvr1.cancel();
                engineer.Active_Engineer__c = true;
                update engineer;
                ApexPages.standardController sc2 = new ApexPages.StandardController(engineer);
                PrometricVoucherRequest pvr2 = new PrometricVoucherRequest(sc1);
                system.assert(pvr2.cancel()!=null);
            }
}
}