@isTest
public class PRM_DealRegistrationTrigger_Test {
    @TestSetup
    static void makeData(){
        // Create soup user and crete account through him.
        User soupUser = PRM_TestRecordsFactory.createSoupUser();
        insert soupUser;
        System.runAs(soupUser) {
            List<Account> acts = new List<Account>();
            Account partAct = PRM_TestRecordsFactory.createPartnerAccount('1', null);
            Account custAct = PRM_TestRecordsFactory.createCustomerAccount('1', null);
            Account distributorAct = PRM_TestRecordsFactory.createPartnerAccount('2', null);
            distributorAct.Partner_Type__c = 'Distributor';
            acts.add(partAct);
            acts.add(custAct);
            acts.add(distributorAct);
            insert acts;
            Map<String,Account> actNameToAct = new Map<String,Account>();
            for (Account a : [SELECT Id, Name FROM Account LIMIT 10]) {
                actNameToAct.put(a.Name,a);
            }

            List<Contact> conLst = new List<Contact>();
            Contact partCon = PRM_TestRecordsFactory.createPartnerContact(actNameToAct.get('Partner Test Account1').Id, '1', null);
            conLst.add(partCon);
            Contact distCon = PRM_TestRecordsFactory.createPartnerContact(actNameToAct.get('Partner Test Account2').Id, '1', null);
            conLst.add(distCon);
            insert conLst;

        }
    }

    @isTest
    public static void updateSaleOpInfoTest() {
        Test.startTest();
        Account part;
        Account cust;
        for (Account a : [SELECT Id, Name FROM Account WHERE Name IN ('Partner Test Account1','Customer Test Account1')]) {
            if (a.Name == 'Partner Test Account1') {
                part = a;
            } else if (a.Name == 'Customer Test Account1') {
                cust = a;
            }
        }
		Contact partnerCon;
        Profile p;
        User partUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
        partnerCon = [SELECT Id, Name FROM Contact WHERE Name = 'Mahla1' LIMIT 1];
        p = [select Name from Profile WHERE name ='IPT Partner Community Login User'];
        partUser = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                             ContactId = partnerCon.Id,FederationIdentifier = 'sm123993',Quicklook_ID__c = 'sm123993',
                             timezonesidkey='America/Los_Angeles', username='teste23@noemail.com.p');
        insert partUser;
        }
        System.assertNotEquals(partUser,NULL,'Partner user should not be NULL');
        System.runAs(partUser) {
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.End_Customer_Company_Name__c = 'ABC Inc';
            deal.End_Customer_Key_Contact_Name__c = 'Raman Iyr';
            deal.Partner_Industry__c = 'Retail';
            //deal.Deal_Created_By_Distributor__c = true;
            //deal.Partner_Contact__c = partnerCon.Id;
            deal.Is_this_part_of_an_RFP__c = true;
            //deal.OwnerId = userinfo.getUserId();
            deal.Estimated_Close_Date__c = date.today();
            deal.Partner_Submission_Date__c = system.now();
            Insert deal;
            deal.Partner_Submission_Date__c = system.now() +1;
            update deal;
            deal.Partner_Submission_Date__c = system.now() +2;
            update deal;
            deal.Partner_Submission_Date__c = system.now() +3;
            update deal;
            deal.Partner_Submission_Date__c = system.now() +4;
            update deal;
            deal.Partner_Submission_Date__c = system.now() +5;
            update deal;
        }
        Test.stopTest();
    }


    @isTest
    public static void dealSharingTest() {
        Test.startTest();
        
        Map<String,Account> actNameToact = new Map<String,Account>();
        for (Account a : [SELECT Id, Name FROM Account LIMIT 10]) {
            actNameToact.put(a.Name,a);
        }
        Account part = actNameToact.get('Partner Test Account1');
        Account cust = actNameToact.get('Customer Test Account1');
        Account dist = actNameToact.get('Partner Test Account2');
        User partUser;
        Profile p;
        Contact partnerCon;
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
         partnerCon = [SELECT Id, Name FROM Contact WHERE Name = 'Mahla1' LIMIT 1];
         p = [select Name from Profile WHERE name ='IPT Partner Community Login User'];
         partUser = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                             ContactId = partnerCon.Id,FederationIdentifier = 'sm123993',Quicklook_ID__c = 'sm123993',
                             timezonesidkey='America/Los_Angeles', username='teste23@noemail.com.p');
        
        insert partUser;
        }
        
        System.runAs(partUser) {
            Deal_Registration__c deal = new Deal_Registration__c();
            deal.End_Customer_Company_Name__c = 'ABC Inc';
            deal.End_Customer_Key_Contact_Name__c = 'Raman Iyr';
            deal.Partner_Industry__c = 'Retail';
            deal.Deal_Created_By_Distributor__c = true;
            //deal.Partner_Contact__c = partnerCon.Id;
            deal.Is_this_part_of_an_RFP__c = true;
            deal.Partner_Company_Name__c = part.Id;
            deal.Estimated_Close_Date__c = date.today();
            deal.Partner_Submission_Date__c = system.now();
            Insert deal;
            deal.End_Customer_Company_Name__c = cust.Id;
            update deal;
        }
        Test.stopTest();
    }
}