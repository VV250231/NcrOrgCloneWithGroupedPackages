/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Selector class that contains all Database queries for Hospitality Service Cloud custom
* logic. This class also contains all data mock records used for unit testing, the
* data mock is used to control the values returned by the query and help avoid running any
* unnecessary SOQL or DMLs that might fail due to external factors (like field visibility
* or custom validation).
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
*
* v1.1            ba250204@ncr.com
* 2022-07-15      Code refactoring (switch from hard-coded Strings to HSRConstants).
*                 Add AccountContactRelation selector methods
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public inherited sharing class HSRSelector {

    @TestVisible
    private static Boolean mockResults = false;

    // === Account ===
    public static List<Account> getAccountsByCustomersNumbers(List<String> customersNumbers) {
        return (isMock() ?
                mockAccountRecords() : [
                        SELECT
                                Id,
                                Owner.UserRoleId
                        FROM Account
                        WHERE Master_Customer_Number__c IN :customersNumbers
                        AND (
                                RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_CUSTOMER
                                OR RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_PARTNER
                        )
                ]
        );
    }

    public static Database.QueryLocator getAccountQueryLocator_ARCBatchJob(List<Id> contactsIds) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        ParentId
                FROM Account
                WHERE RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_SITE
                AND Active_Account__c = TRUE
                AND ParentId IN (
                        SELECT
                                AccountId
                        FROM AccountContactRelation
                        WHERE ContactId IN :contactsIds
                        AND (
                                Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_CUSTOMER
                                OR Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_PARTNER
                        )
                )
                AND Id NOT IN (
                        SELECT
                                AccountId
                        FROM AccountContactRelation
                        WHERE ContactId IN :contactsIds
                        AND Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_SITE
                )
        ]);
    }

    public static List<Account> getSiteAccountsByParentId_ACRToCreate(List<Id> contactsIds, Integer numberOfRecords) {
        return isMock() ?
                mockAccountRecords() : [
                        SELECT
                                Id,
                                ParentId
                        FROM Account
                        WHERE RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_SITE
                        AND Active_Account__c = TRUE
                        AND ParentId IN (
                                SELECT
                                        AccountId
                                FROM AccountContactRelation
                                WHERE ContactId IN :contactsIds
                                AND (
                                        Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_CUSTOMER
                                        OR Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_PARTNER
                                )
                        )
                        AND Id NOT IN (
                                SELECT
                                        AccountId
                                FROM AccountContactRelation
                                WHERE ContactId IN :contactsIds
                                AND Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_SITE
                        )
                        LIMIT :numberOfRecords
                ];
    }

    // === Contact ===
    public static List<Contact> getContactsByEmail(String email) {
        return (isMock() ?
                mockContactRecords() : [
                        SELECT
                                Id,
                                (
                                        SELECT
                                                Id
                                        FROM Users
                                )
                        FROM Contact
                        WHERE Email LIKE :email
                        AND Active_Contact__c = TRUE
                ]
        );
    }

    public static List<Contact> getContactsByACRStatus(String status) {
        return (isMock() ?
                mockContactRecords() : [
                        SELECT
                                Id,
                                AccountId,
                                Hospitality_ACR_Processing_Status__c
                        FROM Contact
                        WHERE Hospitality_ACR_Processing_Status__c = :status
                ]);
    }

    public static Boolean hasPendingACRProcessingRequests() {
        return [
                SELECT
                        Id
                FROM Contact
                WHERE Hospitality_ACR_Processing_Status__c = :HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS
                LIMIT 1
        ].size() > 0;
    }

    // === Account Contact Relation ===
    public static List<AccountContactRelation> getPendingACRToDelete(Id contactId, List<Id> parentAccountIds, Integer numberOfRecords) {
        return [
                SELECT
                        Id
                FROM AccountContactRelation
                WHERE ContactId = :contactId
                AND Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_SITE
                AND (
                        Account.Active_Account__c = FALSE
                        OR (
                                Hospitality_Experience_Cloud_Automation__c = TRUE
                                AND Account.ParentId NOT IN :parentAccountIds
                        )
                )
                LIMIT :numberOfRecords
        ];
    }

    public static List<AccountContactRelation> getMCNAccountContactRelations(List<Id> contactIds) {
        return [
                SELECT
                        Id,
                        ContactId,
                        AccountId
                FROM AccountContactRelation
                WHERE ContactId IN :contactIds
                AND (
                        Account.RecordType.DeveloperName LIKE :HSRConstants.ACCOUNT_RT_CUSTOMER
                        OR Account.RecordType.DeveloperName = :HSRConstants.ACCOUNT_RT_PARTNER
                )
        ];
    }

    // === User ===
    public static List<Contact> getContactsByUserIds(List<Id> userIds) {
        return (isMock() ?
                mockContactRecords() : [
                        SELECT
                                Id,
                                AccountId
                        FROM Contact
                        WHERE Id IN (
                                SELECT
                                        ContactId
                                FROM User
                                WHERE Id IN :userIds
                        )
                ]
        );
    }


    // === Work Order ===
    public static List<WorkOrder> getWorkOrdersById(List<String> orderIds) {
        return (isMock() ?
                mockWorkOrderRecords() : [
                        SELECT
                                Id,
                                Street,
                                Street_Line_2__c,
                                City,
                                PostalCode,
                                State,
                                SN_Override_Flag__c,
                                SN_Override__c,
                                Out_of_Scope__c,
                                Shipment_Method__c,
                                Request_Type_Mapping__c,
                                Priority_Type__c,
                                Alt_Work_Site_Flag__c,
                                Customer_External_Id__c,
                                Service_Level_Id__c,
                                Config_Details__c,
                                Description,
                                Serial_Number__c,
                                WorkOrderNumber,
                                Customer_Ticket_Number__c,

                                AccountId,
                                Account.Master_Customer_Number__c,
                                Account.Account_Country_Code__c,

                                Site_Id__c,
                                Site_Id__r.Site_Number__c,
                                Site_Id__r.Name,
                                Site_Id__r.BillingCountry,
                                ContactId,
                                Contact.FirstName,
                                Contact.LastName,
                                Contact.Phone,
                                Contact.Email,

                                CaseId,
                                Case.Subject,
                                Case.CaseNumber,

                                AssetId,
                                Asset.PID__c,

                                Solution_Set_HW_Role_Relation__c,
                                Solution_Set_HW_Role_Relation__r.HW_Role_Id__c,

                                Support_Class_Failure_Reason_Relation__c,
                                Support_Class_Failure_Reason_Relation__r.Failure_Reason_Id__c
                        FROM WorkOrder
                        WHERE Id IN :orderIds
                ]
        );
    }

    // === Profile ===
    public static Profile getProfileByName(String profileName) {
        return [
                SELECT
                        Id
                FROM Profile
                WHERE Name LIKE :profileName
        ];
    }

    // === Async Apex Job ===
    public static List<AsyncApexJob> getRunningBatchByClassName(String className, List<String> jobType) {
        return [
                SELECT
                        Id
                FROM AsyncApexJob
                WHERE ApexClass.Name = :className
                AND Status IN :HSRConstants.ASYNC_JOB_IN_PROGRESS_STATUS
                AND JobType IN :jobType
        ];
    }

    // -------------------- Data mock --------------------
    @TestVisible
    private static List<WorkOrder> mockWorkOrders { get; set; }
    private static List<WorkOrder> mockWorkOrderRecords() {
        return mockWorkOrders == null ? new List<WorkOrder>() : mockWorkOrders;
    }

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

    // -------------------- Util Methods --------------------
    private static Boolean isMock() {
        return Test.isRunningTest() && mockResults;
    }
}