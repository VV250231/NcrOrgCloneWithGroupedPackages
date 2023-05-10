/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: QuBy_TestCustomerLinkageTrigger.cls                                  
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 23-08-2016
# Description...........: TEST CLASS for QuBy_CustomerLinkageTrigger
##################################################################################################*/
@isTest
private class QuBy_TestCustomerLinkageTrigger{  
    static testmethod void testF(){
        Test.StartTest();
         Account a =TestRecordsFactory.createAccount('myaccmudit');
        
        AccountTeamMember ATM = new AccountTeamMember();
        ATM.AccountId = a.id;
        ATM.UserId = userInfo.getUserId();
        ATM.TeamMemberRole = 'Account Manager';
        insert ATM;
        
        a.OwnerId = [ SELECT id FROM User WHERE usertype='Standard' and profile.name like '%Admin%' limit 1 ].id;
        update a;
        System.assert(a.Id!=null);
        Test.stopTest(); 
    }
     static testmethod void testF1(){
        Test.StartTest();
         Account a =TestRecordsFactory.createAccount('myaccmudit1');      
        
        
        a.OwnerId = [ SELECT id FROM User WHERE usertype='Standard' and profile.name like '%Admin%' limit 1 ].id;
        update a;
        System.assert(a.Id!=null);
        Test.stopTest(); 
    }
}