@isTest
public class PRM_PartnerOpportunityApprovalConTest {
    public static testMethod void testPartnerOpportunityApproval() {
         
        // Create Partner Account
        Account act = new Account();
        act.Name = 'Partner Demo Account';
        List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
        if (actRecordtypes.size() > 0)
            act.RecordTypeId = actRecordtypes[0].Id;
        act.Account_Country_Code__c = 'US';
        act.Active_Account__c = true;
        act.CurrencyIsoCode = 'USD';
        act.Partnership_Status__c ='Active';
        act.Industry = 'RETAIL:SPECIALTY RETAIL';
        act.Partner_Industry__c = 'RETAIL';
        act.LOB__c = 'RETAIL';
        act.Account_Region__c = 'MEA';
        act.Partner_Program_Level__c = 'Advanced';
        act.Master_Customer_Number__c = '9166344650';
        System.runAs(TestRecordsFactory.getUser()){
        insert act;
        }
        
        // Create Partner Contact
        Contact con = new Contact();
        con.lastName = 'Mahla';
        con.Email = 'sm245987@gmail.com';
        con.AccountId = act.Id;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser';
        insert con;
        
        // Create Community User for above contact
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%IPT Partner Community Login User%' Limit 1];
        User u1 = new User();
        u1.ContactId = con.Id;
        u1.Username = 'wplUser@ncr.com';
        u1.ProfileId = portalProfile.Id;
        u1.Alias = 'test123';
        u1.isActive =true;
        u1.Email = 'sm245987@gmail.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'McTesty';
        u1.CommunityNickname = 'testxxns12345';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US';
        u1.LanguageLocaleKey = 'en_US';
        u1.FederationIdentifier = 'wplUser';
        insert u1;
        
        Partner_Opportunity__c objtemp = new Partner_Opportunity__c();
        objtemp.Amount__c = 100;
        objtemp.CAM__c = userinfo.getUserId();
        objtemp.End_Customer__c = 'End Customer';
        objtemp.End_Customer_Primary_Contact__c = 'End customer primary contact';
        objtemp.Expected_Book_Date__c = system.today();
        objtemp.Opportunity_Name__c = 'Test Opportunity';
        objtemp.Partner_Account__c = act.Id;
        objtemp.Partner_Sales_Person__c = 'partner sales person';
        //obj.TAM__c = userinfo.getUserId();
        
        AccountTeamMember actobj = new AccountTeamMember();
        actobj.AccountId = act.id;
        actobj.TeamMemberRole = 'Account Manager';
        actobj.UserId = userinfo.getUserId();
        insert actobj;
              
        insert objtemp;
        
        PRM_PartnerOpportunityApprovalCon.ProcessResult res = PRM_PartnerOpportunityApprovalCon.submitPartnerOpportunityRequest(objtemp.Id,'Testing');
        system.assert(res.message =='You will not be able to submit the record for approval without TAM selection. Please click on TAM selection button to continue.');
        
        
        Partner_Opportunity__c obj = new Partner_Opportunity__c();
        obj.Amount__c = 100;
        obj.CAM__c = userinfo.getUserId();
        obj.End_Customer__c = 'End Customer';
        obj.End_Customer_Primary_Contact__c = 'End customer primary contact';
        obj.Expected_Book_Date__c = system.today();
        obj.Opportunity_Name__c = 'Test Opportunity';
        obj.Partner_Account__c = act.Id;
        obj.Partner_Sales_Person__c = 'partner sales person';
        obj.TAM__c = null; 
        insert obj;
        
        //update TAM
        obj.TAM__c = userinfo.getUserId();
        update obj;
        
        res = PRM_PartnerOpportunityApprovalCon.submitPartnerOpportunityRequest(obj.Id,'Testing');
        system.assert(res.message == 'Your request has been submitted');
        
        // Try to submit the request which is already submitted
        res = PRM_PartnerOpportunityApprovalCon.submitPartnerOpportunityRequest(obj.Id,'Testing');
        system.assert(res.message == 'Record is already pending for approval.');
        
        obj.Status__c = 'Rejected';
        update obj;        
        res = PRM_PartnerOpportunityApprovalCon.submitPartnerOpportunityRequest(obj.id,'Testing');
       
        
        Partner_Opportunity__c obj1 = new Partner_Opportunity__c();
        obj1.Amount__c = 100;
        obj1.CAM__c = userinfo.getUserId();
        obj1.End_Customer__c = 'End Customer';
        obj1.End_Customer_Primary_Contact__c = 'End customer primary contact';
        obj1.Expected_Book_Date__c = system.today();
        obj1.Opportunity_Name__c = 'Test Opportunity';
        obj1.Partner_Account__c = act.Id;
        obj1.Partner_Sales_Person__c = 'partner sales person';
        obj1.TAM__c = userinfo.getUserId(); 
        obj1.Status__c = 'Approved';
        insert obj1;
        res = PRM_PartnerOpportunityApprovalCon.submitPartnerOpportunityRequest(obj1.Id,'Testing'); 
        system.assert(res.message == 'You cannot submit a request that is already approved.');
        
    }
}