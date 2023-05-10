@isTest
private class QuoteExtControllerTests {
    private static Id ACCOUNT_SITE_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Site' ).getRecordTypeId();
    
    testMethod static void testSubmit() {
        
        Profile adminProfile = [SELECT id from Profile WHERE Name = '04 NSC UI Administrator' Limit 1];
                
        User testUser = new User(alias = 'standt', email='standarduser11@ncr.com',
                    emailencodingkey='UTF-8', lastname='Testing3',Quicklook_Id__c='ValProfl', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = adminProfile.Id,timezonesidkey='America/Los_Angeles',
                    username='standarduser1@.ncr.com'+System.now().getTime()+'.com');
        insert testUser;
        
        Group testGroup = new Group(Name = 'Account Admin');
        insert testGroup;
        
        GroupMember testMember = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id);
        insert testMember;
                    
       System.runAs(testUser){
           
            Account parentAccount = new Account(Name='Parent Account');
            insert parentAccount;
            
            Account testAccount = new Account(
                RecordTypeId = ACCOUNT_SITE_RECORDTYPEID,
                Name='Test Company Name123',
                Primary_Bill_To__c = true,
                Bill_To__c = true,
                Ship_To__c = true, 
                Primary_Ship_To__c = true,
                Deliver_To__c = true, 
                Primary_Deliver_To__c = true,
                ParentId = parentAccount.Id,
                CDM_Account_Type__c = 'Site');
            insert testAccount;
       
            SBQQ__Quote__c quote = new SBQQ__Quote__c(
                SBQQ__Type__c='Quote', 
                SBQQ__Status__c= 'Draft',
                ApprovalStatus__c = 'Pending',
                qtc_Bill_To_Site__c =testAccount.Id,
                Deliver_To_Site__c =testAccount.Id,
                qtc_Ship_To_Account__c =testAccount.Id,
                SBQQ__Account__c = parentAccount.Id
            );
            insert quote;
        }
        SBQQ__Quote__c testQuote = [SELECT Id,ApprovalStatus__c,SBQQ__Status__c  FROM SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(testQuote));
        con.onSubmit();
        SBQQ__Quote__c resultQuote = [SELECT ApprovalStatus__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id LIMIT 1];
        System.assert(resultQuote.id!=null);
        Test.stopTest();
        
        
    }
    
    testMethod static void testErrorSubmit() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        System.assert(quote.id!=null);
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        
        // Delete the quote in order to throw an error
        delete quote;
        
        con.onSubmit();
        
        Test.stopTest();
        
        con.onCancel();
    }
    
    testMethod static void testRecall() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        QuoteExtController.recallApproval(quote.Id);
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        System.assert(quote.id!=null);
        Test.stopTest();
        
        
    }
    
    testMethod static void testErrorRecall() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        System.assert(quote.id!=null);
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        
        // Delete the quote in order to throw an error
        delete quote;
        
        con.onRecall();
        Test.stopTest();
              
        con.onCancel();
    }
}