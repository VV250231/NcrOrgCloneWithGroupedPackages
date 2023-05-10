@isTest
public class deleteAttachmentTest {


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
        u1.CommunityNickname = 'test09876';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.Quicklook_ID__c = 'wplUser';
        u1.FederationIdentifier = 'wplUser';
        return u1;   
    }
    
    public static testmethod void deleteAttachmentTest() {
        Account acc = createAccount();
        system.runas(TestRecordsFactory.getUser()){
        insert acc;
        }
        Contact con = createContact(acc.id);
        insert con;
        user u = createUser(con.Id);
        insert u;
        
        // Insert Co-Op Request
        Co_Op__c coOpReq = new Co_Op__c();
        coOpReq.Activity_Name__c = 'Co Op Req';
        coOpReq.Activity_Start_Date__c = System.today();
        coOpReq.Activity_End_Date__c = System.today();
        insert coOpReq;
        system.assert(coOpReq.id!=null);
            
        Co_Op_Supporting_Document__c obj = new Co_Op_Supporting_Document__c ();
        ApexPages.StandardController sc = new ApexPages.StandardController(obj );
        PageReference pageRef = Page.co_op_supporting_document;
        pageRef.getParameters().put('coOpid', String.valueOf(coOpReq.Id));
        Test.setCurrentPage(pageRef);
        
        coOpExtension controller = new coOpExtension(sc);
        controller.att.Name = 'Test';
        controller.att.Body = Blob.valueOf('Test');
        controller.saveSupportingDoc();
        
        delete controller.supportingDoc;
    }
}