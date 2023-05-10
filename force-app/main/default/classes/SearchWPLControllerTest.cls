@isTest(seeAlldata = true)
public class SearchWPLControllerTest {
	
	private static void createAcc(){
        User u1 = TestRecordsFactory.getUser();
        System.runAs(u1){
        List<Account> accounts = new List<Account>();
		accounts.add(new Account(Name = 'Unit Test Corp', Master_Customer_Number__c  ='23213'));
		accounts.add(new Account(Name = 'Unit Test LLC', Master_Customer_Number__c  ='223213'));
		accounts.add(new Account(Name = 'Parent Company Inc'));
		insert accounts; 
        }
		

	}

	private static void createContact(){
		createAcc();
		Account ac = [SELECT Id FROM Account WHERE Name = 'Unit Test LLC' LIMIT 1];
		Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Web_portal_login__c ='test');
        insert con;  
        
     
	}	
    
    static testmethod void testSearchWPL(){
        createContact();
        SearchWPLController sc = new SearchWPLController();
        sc.searchString ='test';
        sc.getcontactWrapper();
        sc.grantAccessOfIncentives();
        List<Incentive_WPL_mapping__c> imList = [select id from Incentive_WPL_mapping__c ];
        System.assert(imList.size()>0);
        
    }
    
    static testmethod void testSearchWPL2(){
        Incentive_WPL_mapping__c iw = new Incentive_WPL_mapping__c(name = 'test');
        insert iw;
        createContact();
        SearchWPLController sc = new SearchWPLController();
        sc.searchString ='test';
        sc.getcontactWrapper();
        sc.grantAccessOfIncentives();
        List<Incentive_WPL_mapping__c> imList = [select id from Incentive_WPL_mapping__c where name !='test'];
        System.assert(imList.size()>0);
        sc.tableFlag =true;
        sc.searchContact();
        sc.NoRecordFlag=true;
        
        
    }
}