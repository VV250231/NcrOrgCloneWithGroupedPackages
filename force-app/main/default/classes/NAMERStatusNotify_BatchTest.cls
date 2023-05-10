/*This is the test class for NAMERStatusNotify_Batch*/
/*
##################################################################################################
# Class Name............................:NAMERStatusNotify_BatchTest                                                                                                                                
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class NAMERStatusNotify_BatchTest {
    
    public static testMethod void notifytestmethod(){
        
        List<User> UserList=[Select id,name,Email,managerid from User where manager.Name='Maurice Settles'];
        List<Lead> leadlsit=new List<Lead>();
        
        
        Lead ld=new Lead();
        ld.LastName='Doe';
        ld.FirstName='John';
        ld.Company='Test';
        ld.Namer_Six_Days_Notification__c=False;
        ld.status='Open';
        ld.Namer_Date_Field__c =system.today().addDays(-5);
        User u =[Select id,name,Email,managerid from User where manager.Name='Maurice Settles' limit 1];
        u.isActive = true;
        update u;
        system.runas(u){
            insert ld; 
        }
 
        Test.startTest();
   
        String CRON_EXP = '0 0 * * * ?';
        scheduledSixDaysNotification  sch = new scheduledSixDaysNotification();
        system.schedule('Hourly Example Batch Schedule job', CRON_EXP, sch);
        Test.stopTest();
        lead lObj = [select Namer_Six_Days_Notification__c from lead where id=:ld.id];
        System.assert(!lObj.Namer_Six_Days_Notification__c);
        
        
    }
    
}