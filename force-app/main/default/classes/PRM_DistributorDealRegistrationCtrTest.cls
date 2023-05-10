@isTest
public class PRM_DistributorDealRegistrationCtrTest {
  @isTest
    public static void testPRM_DistributorDealRegistrationCtr () {
        // Create Partner Account
        Account partnerAct = PRM_TestRecordsFactory.createPartnerAccount('1',null);
        partnerAct.Partner_Type__c = 'Distributor';
        partnerAct.Partner_Industry__c ='Financial;Hospitality;Travel;Telecom & Technology;Retail';
        system.runAs(TestRecordsFactory.getUser()){ 
        	insert partnerAct;
        }
        
        System.assertNotEquals(partnerAct,NULL,'Account should not be NULL');
        
        String teamMemberRole = 'Territory Account Manager';
        List<AccountTeamMember> members = new list<AccountTeamMember>();
        members.add(New AccountTeamMember(AccountId = partnerAct.id, TeamMemberRole = teamMemberRole, UserId= UserInfo.getUserId()));
        
        
        insert members;
        // Create Partner Contact
        Contact partnerCon = PRM_TestRecordsFactory.createPartnerContact(partnerAct.Id,'1',null);
        insert partnerCon;
        // Crate Partner User
        Profile p = [select Name from Profile WHERE name ='IPT Partner Community Login User'];
        
        User user = new User(alias = 'test23', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                             ContactId = partnerCon.Id,FederationIdentifier = 'sm123993',Quicklook_ID__c = 'sm123993',
                             timezonesidkey='America/Los_Angeles', username='test123@noemail.com.t');
        
       // insert user;
        system.runAs(TestRecordsFactory.getUser()){ 
        	insert user;
        }
       // system.runAs(user) 
       {
        Deal_Registration__c deal = new Deal_Registration__c();
        deal.End_Customer_Company_Name__c = 'ABC Inc';
        deal.End_Customer_Key_Contact_Name__c = 'Raman Iyr';
        deal.Deal_Created_By_Distributor__c = true;
        deal.Partner_Contact__c = partnerCon.Id;
        deal.Is_this_part_of_an_RFP__c = true;
        deal.OwnerId = userinfo.getUserId();
        deal.Estimated_Close_Date__c = date.today();
        Insert deal;
        
        PRM_DistributorDealRegistrationCtr.getEditDetails(deal.Id); 
        PRM_DistributorDealRegistrationCtr.getPicklistValues();
        PRM_DistributorDealRegistrationCtr.saveDealRegistration(deal,'Channel_Opportunity_2019','Net New Customer','Zambia','Digital Banking','Encor POS Software','--None--','Financial','--None--',null,partnerAct.Name,partnerCon.Name);
        PRM_DistributorDealRegistrationCtr.DealRegistration('Retail','');
       }
    }
  
  @isTest
    public static void testSaveDealRegistration(){
        
        // Creating a Partner Account
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null);
        accountRecord.Partner_Industry__c ='Financial;Hospitality;Travel;Telecom & Technology;Retail';
        accountRecord.Partner_Type__c='Distributor';
        accountRecord.Distributor__c=accountRecord.Name;
        system.runAs(TestRecordsFactory.getUser()){ 
            insert accountRecord;
        }
        
        System.assertNotEquals(accountRecord,NULL,'Account should not be NULL');
        
        // Creating a Contact
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;
        
        //Creating User
        Test.startTest();
        User userRecord = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'test',null);
        Insert userRecord; 

       // Test.startTest();
            System.runas(userRecord) {  
                PRM_DistributorDealRegistrationCtr.getPicklistValues();
            Test.stopTest();
        }
     }  
}