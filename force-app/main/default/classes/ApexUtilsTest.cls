/**
 * code coverage 92%
 */
@isTest
private class ApexUtilsTest {
    private static Integer sObjectIdCounter = 1;
    public static String getFakeId(Schema.SobjectType sot) {
        String result = String.valueOf(sObjectIdCounter++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    private static List<Account> createTestAccounts() {
        System.runAs(TestRecordsFactory.getUser()){
            List<Account> accounts = new List<Account>();
            accounts.add(new Account(Name = '1'));
            accounts.add(new Account(Name = '2'));
            accounts.add(new Account(Name = '3'));

            insert accounts;
        }
        return [SELECT Id, Name FROM Account];
    }

    @isTest static void test_pluckIdSet() {
        List<Account> accounts = createTestAccounts();
        Set<Id> accountIds = ApexUtils.pluckIdSet(accounts, Schema.Account.Id);
        System.assertEquals(3, accountIds.size());
    }

    @isTest static void test_pluckIdSetNonMatching() {
        List<Account> accounts = createTestAccounts();
        Set<Id> accountIds = ApexUtils.pluckIdSet(accounts, Schema.Contact.Name);
        System.assertEquals(0, accountIds.size());
    }

    @isTest static void test_pluckIdSetRelationship() {
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = '1', Account = new Account(Name = 'Account 1', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-1'))),
            new Contact(LastName = '2', Account = new Account(Name = 'Account 2', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-2'))),
            new Contact(LastName = '3', Account = new Account(Name = 'Account 3', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-3'))),
            new Contact(LastName = '4', Account = new Account(Name = 'Account 4', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-4'))),
            new Contact(LastName = '5', Account = new Account(Name = 'Account 4')),
            new Contact(LastName = '5')
        };
        Set<Id> userIds = ApexUtils.pluckIdSet(contacts, 'Account.Parent.Id');
        System.assertEquals(4, userIds.size());
        // System.assertEquals(contacts[0].Account.Parent.Id, userIds[0]);
        // System.assertEquals(contacts[1].Account.Parent.Id, userIds[1]);
        // System.assertEquals(contacts[2].Account.Parent.Id, userIds[2]);
        // System.assertEquals(contacts[3].Account.Parent.Id, userIds[3]);
    }

    @isTest static void test_pluckStringSet() {
        List<Account> accounts = createTestAccounts();
        Set<String> accountIds = ApexUtils.pluckStringSet(accounts, Schema.Account.Name);
        System.assertEquals(3, accountIds.size());

        System.assert(accountIds.contains('1'));
        System.assert(accountIds.contains('2'));
        System.assert(accountIds.contains('3'));
    }

    @isTest static void test_pluckStringSetRelationship() {
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = '1', Account = new Account(Name = 'Account 1', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-1'))),
            new Contact(LastName = '2', Account = new Account(Name = 'Account 2', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-2'))),
            new Contact(LastName = '3', Account = new Account(Name = 'Account 3', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-3'))),
            new Contact(LastName = '4', Account = new Account(Name = 'Account 4', Parent = new Account(Id = ApexUtilsTest.getFakeId(Account.getSObjectType()), Name = 'parent-account-4'))),
            new Contact(LastName = '5', Account = new Account(Name = 'Account 4')),
            new Contact(LastName = '5')
        };
        Set<String> userNames = ApexUtils.pluckStringSet(contacts, 'Account.Parent.Name');
        System.assertEquals(4, userNames.size());
        // System.assertEquals(userNames[0].Account.Parent.Name, userNames[0]);
        // System.assertEquals(userNames[1].Account.Parent.Name, userNames[1]);
        // System.assertEquals(userNames[2].Account.Parent.Name, userNames[2]);
        // System.assertEquals(userNames[3].Account.Parent.Name, userNames[3]);
    }

    @isTest static void test_pluckMap() {
        List<Account> accounts = createTestAccounts();
        Map<String, String> accountMap = ApexUtils.pluckMap(accounts, Schema.Account.Id, Schema.Account.Name);

        System.assertEquals(accounts[0].Name, accountMap.get(accounts[0].Id));
        System.assertEquals(accounts[1].Name, accountMap.get(accounts[1].Id));
        System.assertEquals(accounts[2].Name, accountMap.get(accounts[2].Id));
    }

    @isTest static void test_groupBy() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Franchise';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Client';

        Map<String, List<SObject>> accountMap = ApexUtils.groupBy(accounts, Schema.Account.Type);

        System.assertEquals(2, accountMap.get('Franchise').size());
        System.assertEquals(1, accountMap.get('Client').size());
    }

    @isTest static void test_groupByString() {
        List<Account> accounts = createTestAccounts();
        
        accounts[0].Parent = new Account();
        accounts[0].Parent.Owner = new User(FirstName = 'Bob');
        accounts[1].Parent = new Account();
        accounts[1].Parent.Owner = new User(FirstName = 'Bob');
        accounts[2].Parent = new Account();
        accounts[2].Parent.Owner = new User(FirstName = 'Sally');

        Map<String, List<SObject>> accountMap = ApexUtils.groupBy(accounts, 'Parent.Owner.FirstName');

        System.assertEquals(2, accountMap.get('Bob').size());
        System.assertEquals(1, accountMap.get('Sally').size());
    }

    @isTest static void test_groupByStringMultiLevel() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Parent = new Account();
        accounts[0].Parent.Owner = new User(FirstName = 'Bob');
        accounts[1].Parent = new Account();
        accounts[1].Parent.Owner = new User(FirstName = 'Bob');
        accounts[2].Parent = new Account();
        accounts[2].Parent.Owner = new User(FirstName = 'Sally');

        Map<String, List<SObject>> accountMap = ApexUtils.groupBy(accounts, 'Parent.Owner.FirstName');

        System.assertEquals(2, accountMap.get('Bob').size());
        System.assertEquals(1, accountMap.get('Sally').size());
    }

    @isTest static void test_pluckMapAny() {
        List<Account> accounts = createTestAccounts();
        Map<String, Object> accountMap = ApexUtils.pluckMapAny(accounts, Schema.Account.Id, Schema.Account.Name);

        System.assertEquals(accounts[0].Name, accountMap.get(accounts[0].Id));
        System.assertEquals(accounts[1].Name, accountMap.get(accounts[1].Id));
        System.assertEquals(accounts[2].Name, accountMap.get(accounts[2].Id));
    }

    @isTest static void test_pluckMapAny2() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Client';
        accounts[1].Type = 'Partner';
        accounts[2].Type = 'Franchise';

        Map<String, SObject> accountMap = ApexUtils.groupByFlat(accounts, Schema.Account.Type);

        System.assertEquals(accounts[0], accountMap.get('Client'));
        System.assertEquals(accounts[1], accountMap.get('Partner'));
        System.assertEquals(accounts[2], accountMap.get('Franchise'));
    }

    @isTest static void test_findChangedRecs() {
        List<Account> accounts = createTestAccounts();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        accounts[0].Name = 'CHANGED1';
        accounts[2].Name = 'CHANGED3';

        List<SObject> changedAccounts = ApexUtils.findChangedRecs(accounts, accountMap, Schema.Account.Name);

        System.assertEquals(2, changedAccounts.size());
        System.assertEquals(accounts[0], changedAccounts[0]);
        System.assertEquals(accounts[2], changedAccounts[1]);
    }

    @isTest static void test_findChangedRecsWithMatchingVal() {
        List<Account> accounts = createTestAccounts();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        accounts[0].Name = 'CHANGED1';
        accounts[2].Name = 'CHANGED3';


        List<SObject> changedAccounts = ApexUtils.findChangedRecsWithMatchingVal(accounts, accountMap, Schema.Account.Name, 'CHANGED1');

        System.assertEquals(1, changedAccounts.size());
        System.assertEquals(accounts[0], changedAccounts[0]);
    }

    @isTest static void test_findChangedRecsWithMatchingVal2() {
        List<Account> accounts = createTestAccounts();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        accounts[0].Name = 'CHANGED1';
        accounts[2].Name = 'CHANGED1';


        List<SObject> changedAccounts = ApexUtils.findChangedRecsWithMatchingVal(accounts, accountMap, Schema.Account.Name, '1', 'CHANGED1');

        System.assertEquals(1, changedAccounts.size());
        System.assertEquals(accounts[0], changedAccounts[0]);
    }

    @isTest static void test_findRecsWithMatchingValue() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Franchise';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Client';

        List<SObject> foundObjects1 = ApexUtils.findRecsWithMatchingValue(accounts, Schema.Account.Type, 'Franchise');
        List<SObject> foundObjects2 = ApexUtils.findRecsWithMatchingValue(accounts, Schema.Account.Type, 'Client');
        List<SObject> foundObjects3 = ApexUtils.findRecsWithMatchingValue(accounts, Schema.Account.Type, 'foo-bar');

        System.assertEquals(accounts[0], foundObjects1[0]);
        System.assertEquals(accounts[1], foundObjects1[1]);
        System.assertEquals(2, foundObjects1.size());
        System.assertEquals(1, foundObjects2.size());
        System.assertEquals(0, foundObjects3.size());
    }

    @isTest static void test_findRecsWithNonMatchingValue() {
        List<Account> accounts = createTestAccounts();
        accounts[0].Type = 'Franchise';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Client';

        List<SObject> foundObjects1 = ApexUtils.findRecsWithNonMatchingValue(accounts, Schema.Account.Type, 'Franchise');
        List<SObject> foundObjects2 = ApexUtils.findRecsWithNonMatchingValue(accounts, Schema.Account.Type, 'Client');
        List<SObject> foundObjects3 = ApexUtils.findRecsWithNonMatchingValue(accounts, Schema.Account.Type, 'foo-bar');

        System.assertEquals(accounts[2], foundObjects1[0]);
        System.assertEquals(accounts[0], foundObjects2[0]);
        System.assertEquals(accounts[1], foundObjects2[1]);
        System.assertEquals(1, foundObjects1.size());
        System.assertEquals(2, foundObjects2.size());
        System.assertEquals(3, foundObjects3.size());
    }
}