//@isTest(SeeAllData=true)
@isTest
public class Controller_indvidualobject_listview_Test{
    
    public static testMethod void Test_User_Controller(){
        
        Individual i = new Individual();
        i.FirstName = 'Test Test';
        i.LastName = 'Test Test';
        Insert i ;
        
        i.LastName = 'Test Test';
        update i ;
        Individual indobj = [select lastname from Individual where id=:i.id];
        System.assert(indobj.LastName!=null);
    }
    
    public static testMethod void Test_Individual_Trigger(){
        
        Individual i = new Individual();
        i.FirstName = 'Test Test';
        i.LastName = 'Test Test';
        Insert i;
        
        List<Individual> indObj = Controller_indvidualobject_listview.getalldetails(i.id);
        System.assert(indObj.size()>0);
    }
    
    public static testMethod void Test_UserMasking_Trigger(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User us              =  new User();
        us.Profileid         = p.id;
        us.Username          = 't@ncr.com';
        us.Email             = 't@ncr.com';
        us.Alias             = 'alias';           
        us.FirstName         = 'Fname';
        us.LastName          = 'lname';
        us.LocaleSidKey      = 'ar';
        us.LanguageLocaleKey = 'de';
        us.TimeZoneSidKey    = 'Africa/Cairo';
        us.EmailEncodingKey  = 'Big5';
        us.CurrencyIsoCode   = 'AUD';
        us.Quicklook_ID__c   = 'ke532789';
        insert us;
        Account a = TestRecordsFactory.createAccount();
        Contact c = TestRecordsFactory.createContact(a);
        insert new BPM_Configuration__c(Name ='BPMContactIdForNotifyActionOwner',Values__c=c.id);
        insert new BPM_Configuration__c(Name ='APOCAccount',Values__c=a.Master_Customer_Number__c);
        System.runAs ( [Select id from User where profile.name='System Administrator' and IsActive = true][5]){ 
            us.IsActive = false ;
            update us;
            user userObj = [select id,IsActive from user where id=:us.id];
            System.assert(!userObj.IsActive);
        }
        
    }
    
}