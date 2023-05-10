@isTest
public class ValidateContactRecordTypeTest {
  static testMethod void testUpdateContactRecordType() {
    // Get all Active Account RecordTypes that are available to the running user
    Map<String,Id> accountTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
  
    // Get all Active contact RecordTypes that are available to the running user
    Map<String,Id> contactTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Contact.SObjectType);
    
    // Inser Customer Accounts
    List<Account> actList = new List<Account>();
    
    if (accountTypesMap.get('Customer') != null) {
      Account act ;
      for (Integer i = 000 ; i < 100 ; i++) {
        act = new Account();
        act.Name = 'Test Acc' + String.valueOf(i);
        act.RecordTypeId = accountTypesMap.get('Customer');
        act.LOB__c = 'FINANCIAL';
        act.Master_Customer_Number__c = 'TEST000' + String.valueOf(i);
        act.Account_Country_Code__c = 'US';
        act.CurrencyIsoCode = 'USD';
        act.Active_Account__c = true;
        actList.add(act);
      } 
    }
    
    if (actList.size() > 0) {
      insert actList;
      
      // Insert #100 contacts with first account
      List<Contact> conList = new List<Contact>();
      Contact con ;
      for (Integer i = 0; i < 100 ; i++) {
        con = new Contact();
        con.LastName = 'LastName'+String.valueOf(i);
        con.AccountId = actList[0].Id;
        con.Email = 'test.email'+String.valueOf(i)+'@domain.com';
        con.Decision_Maker__c = 'Decision Maker';
        con.Level__c = 'Entry-Level Manager';
        con.Business_Function__c = 'Customer Support/Service';
        con.Primary_Language__c  = 'English US';
        con.Survey_Flag__c = 'Yes'; // Relationship Survey
        conList.add(con);
      }
      
      // Insert #1 contact with each other accounts
      integer j = 100;
      for (Integer i = 1; i < 100 ; i++) {
        
        con = new Contact();
        con.LastName = 'LastName'+String.valueOf(j);
        con.AccountId = actList[i].Id;
        con.Email = 'test.email'+String.valueOf(j)+'@domain.com';
        con.Decision_Maker__c = 'Decision Maker';
        con.Level__c = 'Entry-Level Manager';
        con.Business_Function__c = 'Customer Support/Service';
        con.Primary_Language__c  = 'English US';
        con.Survey_Flag__c = 'Yes'; // Relationship Survey
        conList.add(con);
        j++;
      }
      
      if (conList.size() > 0) {
        insert conList;
      }
      
      // Update Contact with differnt record type
      for (Contact cont : conList) {
        cont.RecordTypeId = contactTypesMap.get('PartnerContact');
      }
      
      try {
        if(conList.size() > 0) {
          update conList;
        }
      } catch (Exception ex) {
        Boolean expectedExceptionThrown =  ex.getMessage().contains('Plese change the related Account\'s Record Type, this will automatically change the Contact\'s Record Type.') ? true : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }
      
    }
  }
}