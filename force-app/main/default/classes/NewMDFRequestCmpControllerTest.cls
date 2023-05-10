@istest
public class NewMDFRequestCmpControllerTest 
{
    public static testmethod void testNewMDFRequestCmpController() 
    {
        List<SFDC_MDF__c> lstMDF = new List<SFDC_MDF__c>();
        
        for(Integer i = 0 ; i <50 ; i++)
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity' + i;
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c= 'Approved'; 
            lstMDF.add(mdfReq);
        }
        
        insert lstMDF;
        List<SFDC_MDF_Claim__c> lstMDFClaim = new List<SFDC_MDF_Claim__c>();
        for(Integer i = 0 ; i < 50 ; i++)
        {
           
            SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
            mdfClaim.Name = lstMDF[i].Name + ' - Claim' ;
            mdfClaim.Fund_Request__c = lstMDF[i].Id;
        
            lstMDFClaim.add(mdfClaim);
        }
        insert lstMDFClaim;
        
        NewMDFRequestCmpController.PicklistDetail b = NewMDFRequestCmpController.getActivitiesAndVendors();
        NewMDFRequestCmpController.getEditMDFDetail(lstMDF[0].Id);
        NewMDFRequestCmpController.getCloneMDFDetail(lstMDF[0].Id);
        //NewMDFRequestCmpController.getActivitiesAndVendors();
        system.assertNotEquals(b.activityOptions,Null,'NewMDFRequentroller not null');  
    }
    
     private static Account createAccount(){
       
        Account objAccount = new Account();
        objAccount.Name = 'Partner Test Account';
        objAccount.Account_Country_Code__c = 'US';
        objAccount.Active_Account__c = true;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Industry = 'RETAIL:CHANNEL';
        objAccount.Account_Region__c = 'EMEA';
        objAccount.Master_Customer_Number__c = '91663446';
        objAccount.Partner_Industry__c = 'Financial;Retail';
        objAccount.LOB__c = 'FINANCIAL';
        objAccount.Account_Region__c = 'CLA';
        
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if(actRecordtypes.size() > 0)
            objAccount.RecordTypeId = actRecordtypes[0].Id;
            
        return objAccount;
    }
    
    private static Contact createContact(Id AccountID)
    {
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'test@gmail.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        return con;
    }
    
    private static User createUser(Id ContactId)
    {
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'IPT Partner Community Login User' Limit 1];
        User u1 = new User();
        u1.ContactId = contactId;
        u1.Username = 'wplUserTest@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test1231';
        u1.Email = 'sm245987Test@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test123451';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        return u1;   
    }
    public static testmethod void testNewMDFRequestCmpController1() 
    {
        Account acc = createAccount();
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){  
        insert acc;
        }
        
        Contact con = createContact(acc.id);
        insert con;
        
        User u = createUser(con.Id);
         
        system.runAs(u) 
        {
            SFDC_MDF__c mdfReq= new SFDC_MDF__c();
            mdfReq.Name= 'Test Activity';
            mdfReq.Activity_Date__c= Date.today()+ 60;
            mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
            mdfReq.Activity_Type__c= 'Event – Webinar';
            mdfReq.Other_Vendors_Represented__c='Micros';
            mdfReq.Activity_Description__c='TestDescription';
            mdfReq.Number_of_Leads__c= 1000;
            mdfReq.Status__c='Request Created'; 
            
            List<MDF_Expense_Detail__c> lstExpense = new List<MDF_Expense_Detail__c>();
            lstExpense.add(new MDF_Expense_Detail__c(Actvity__c = 'test'));
            
            //NewMDFRequestCmpController.saveMDFDetail(lstExpense, mdfReq, 'Event - Roadshow', 'Micros');
            String st = NewMDFRequestCmpController.saveMDFDetail(lstExpense, mdfReq, 'Event - Roadshow', 'Micros');
            NewMDFRequestCmpController.saveEditMDFDetail(lstExpense, mdfReq, 'Event - Roadshow', 'Micros', null);
            
            SFDC_MDF__c mdfReq1= new SFDC_MDF__c();
            mdfReq1.Name= 'Test Activity';
            mdfReq1.Activity_Date__c= Date.today()+ 60;
            mdfReq1.End_Date__c= mdfReq1.Activity_Date__c.addDays(1);
            mdfReq1.Activity_Type__c= 'Event – Webinar';
            mdfReq1.Other_Vendors_Represented__c='Micros';
            mdfReq1.Activity_Description__c='TestDescription';
            mdfReq1.Number_of_Leads__c= 1000;
            mdfReq1.Status__c='Request Created'; 
            NewMDFRequestCmpController.saveCloneMDFDetail(new List<MDF_Expense_Detail__c>{new MDF_Expense_Detail__c(Actvity__c = 'test')}, mdfReq1, 'Event - Roadshow', 'Micros');
            system.assertNotEquals(st, null, 'The object fund request not inserted succesfully'); 

        }
    }
}