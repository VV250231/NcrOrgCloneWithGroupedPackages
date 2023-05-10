/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector class that contains all Database queries for Hospitality Service Cloud unit tests.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-05-20
* @modified       2022-05-25
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-05-20
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
public class HSRTestSelector {
    @TestVisible
    private static Boolean mockResults = false;

    public static List<Account> getAccounts() {
        return mockResults ?
                mockAccountRecords() : [
                        SELECT
                                Id
                        FROM Account
                ];
    }

    public static List<Contact> getContactsByACRStatus(String status) {
        return mockResults ?
                mockContactRecords() : [
                        SELECT
                                Id,
                                Name
                        FROM Contact
                        WHERE Hospitality_ACR_Processing_Status__c = :status
                ];
    }

    public static List<AccountContactRelation> getAccountContactRelations() {
        return mockResults ?
                mockAccountContactsRelationRecords() : [
                        SELECT
                                Id,
                                AccountId,
                                Account.ParentId,
                                ContactId,
                                Account.Name,
                                Contact.Name
                        FROM AccountContactRelation
                ];
    }

    public static List<Dispute_Integration_Logs__c> getIntegrationLogs() {
        return [
                SELECT
                        Id
                FROM Dispute_Integration_Logs__c
        ];
    }

    public static List<EventBusSubscriber> getEventBus(String topic) {
        return [
                SELECT
                        Name,
                        Position,
                        Retries,
                        LastError
                FROM EventBusSubscriber
                WHERE Topic = :topic
        ];
    }


    // -------------------- Data mock --------------------
    @TestVisible
    private static List<Account> mockAccounts { get; set; }
    private static List<Account> mockAccountRecords() {
        return mockAccounts == null ? new List<Account>() : mockAccounts;
    }

    @TestVisible
    private static List<Contact> mockContacts { get; set; }
    private static List<Contact> mockContactRecords() {
        return mockContacts == null ? new List<Contact>() : mockContacts;
    }

    @TestVisible
    private static List<AccountContactRelation> mockAccountContactRelations { get; set; }
    private static List<AccountContactRelation> mockAccountContactsRelationRecords() {
        return mockAccountContactRelations == null ? new List<AccountContactRelation>() : mockAccountContactRelations;
    }
}