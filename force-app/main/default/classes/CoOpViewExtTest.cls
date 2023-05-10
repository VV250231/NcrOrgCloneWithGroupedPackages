@isTest
public class CoOpViewExtTest {
    private static Account createAccount(){
       
        Account act = new Account();
        act.Name = 'Partner Test Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Industry = 'RETAIL:CHANNEL';
        act.Account_Region__c = 'EMEA';
        act.Master_Customer_Number__c = '91663446';
        return act;
    }
    
    private static Contact createContact(Id AccountID){
        //Insert Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'test@gmail.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        return con;
        
    }
    
    private static User createUser(Id ContactId){
          //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User%' Limit 1];
        User u1 = new User();
        u1.ContactId = contactId;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'test12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        return u1;   
    }
    
    public static testmethod void testCoOpViewExt() {
        Account acc = createAccount();
        System.runAs(TestRecordsFactory.getUser()){
           insert acc;  
        }
       
        Contact con = createContact(acc.id);
        insert con;
        user u = createUser(con.Id);
        insert u;
         
       // system.runAs(u) {
            // Insert Co-Op Request
            Co_Op__c coOpReq = new Co_Op__c();
            coOpReq.Activity_Name__c = 'Co Op Req';
            coOpReq.Activity_Start_Date__c = System.today();
            coOpReq.Activity_End_Date__c = System.today();
            insert coOpReq;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(coOpReq);
            CoOpViewExt controller = new CoOpViewExt(sc);
            PageReference pageRef = Page.ipt_co_op_view;
            pageRef.getParameters().put('id', String.valueOf(coOpReq.Id));
            Test.setCurrentPage(pageRef);
            
            controller.submitRequest();
            
            Attachment att = new Attachment();
            att.ParentId = coOpReq.Id;
            att.Name = 'Test Attachment';
            att.Body = Blob.valueOf('test');
            insert att;
            
            Co_Op_Supporting_Document__c supportingDoc = new Co_Op_Supporting_Document__c ();
            supportingDoc.Name = att.Name;
            supportingDoc.Attachment_Id__c = att.Id;
            supportingDoc.Co_Op_Request__c = coOpReq.Id;
            supportingDoc.Type__c = 'Invoices';
            insert supportingDoc;
            
            Co_Op_Supporting_Document__c supportingDoc1 = new Co_Op_Supporting_Document__c ();
            supportingDoc1.Name = att.Name;
            supportingDoc1.Attachment_Id__c = att.Id;
            supportingDoc1.Co_Op_Request__c = coOpReq.Id;
            supportingDoc1.Type__c = 'Proof of payment';
            insert supportingDoc1;
            
            PageReference pgObj = controller.submitRequest();
            System.assert(pgObj!=null);
            controller.redirectToEdit();
            controller.cancel();
        
       // }
        
    }
}