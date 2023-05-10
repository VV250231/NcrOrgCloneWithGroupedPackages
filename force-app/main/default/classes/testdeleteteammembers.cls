/*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: testdeleteteammembers.cls                                                        
# Version.....................: 12.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 09-05-2011                                                                               
# Last Modified by......: Darshan Singh Farswan
# Last Modified Date..: 14-10-2013
# Description...............: This class will test the trigger deleteteammembers which deletes Opportunity and Account Team Members.
################################################################################################
*/
@isTest(SeeAllData=True)
public class testdeleteteammembers{
    public static testMethod void test(){ 
        List<User> userList= new List<User>();
        List<User> users = new List<User>();
        List<Account> accountList = new List<Account>();
        List<Opportunity> opportunityList = new List<Opportunity>();
         Account accounts = new Account();
        Opportunity opportunity =  new Opportunity();
        accountList = [select id from Account limit 1];
        if(accountList.size() > 0) {
              accounts = accountList[0];
        }
       
        opportunityList = [select id from Opportunity limit 1];
        if(opportunityList.size() > 0) {
             opportunity = opportunityList[0];
        }
       
        User user;
        Id profilesID= NSCCommonInfoUtil.getIdOf('user_profile_id');
        users = [select u.id from user u where u.Profile.Id =:profilesID and u.isActive=true];
        User us =users[0];
        System.runAs(us){
        userList= [select id,isactive,employeenumber from user where isactive = false and Profile.UserType = 'Standard' limit 1];
        user = userList[0];
        user.isactive = true;
        update user;
        OpportunityTeamMember o = new OpportunityTeamMember();
             if(opportunityList.size() > 0) {
            o.OpportunityId = opportunityList[0].id;
        }
        
        o.userId = user.id;
        AccountTeamMember a = new AccountTeamMember();
            
              if(accountList.size() > 0) {
              a.AccountId = accountList[0].id;
        }
       
       
        a.userId = user.id;
        insert o;
        insert a; 
        
        Test.startTest();
        user.isactive = false;
        update user;
        System.assert(!user.isactive);
        List<Id> dusers = new List<Id>();
        dusers.add(user.id);
        Database.executeBatch(new batchAccTeamDelete(dusers));
        Database.executeBatch(new batchOppTeamDelete(dusers));
                Test.stopTest();

        }
    }      
}