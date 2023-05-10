/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* A batch job that will handle creating new Account-Contact-relations records.
* This class can be called from JIT User provisioning handler, directly from Anonymous apex, or
* Can be scheduled to run automatically as a scheduled apex.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-07-15
* @modified       2022-07-15
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-07-15
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public inherited sharing class HSRACRCreationBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    @TestVisible
    private Map<Id, Contact> contactsToProcess;
    private static final Integer DEFAULT_BATCH_SIZE = 200;

    private Integer numberAttempted = 0;
    private Integer numSuccessful = 0;

    /* --------------
     * Batch Job
     * --------------
     */
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        contactsToProcess = new Map<Id, Contact>(HSRSelector.getContactsByACRStatus(HSRConstants.CONTACT_ACR_STATUS_TO_PROCESS));

        return HSRSelector.getAccountQueryLocator_ARCBatchJob(
                new List<Id>(contactsToProcess.keySet())
        );
    }

    public void execute(Database.BatchableContext ctx, List<Account> accounts) {
        List<AccountContactRelation> acrToCreate = new List<AccountContactRelation>();
        Map<String, Set<String>> mcnAccountsByContactsIds = getMCNAccountsIdsMap();

        for (Contact contactToProcess : contactsToProcess.values()) {
            Set<String> contactMCNAccountIds = mcnAccountsByContactsIds.get(contactToProcess.Id);
            if (contactMCNAccountIds != null && !contactMCNAccountIds.isEmpty()) {
                for (Account siteAccount : accounts) {
                    if (siteAccount.ParentId != null && contactMCNAccountIds.contains(siteAccount.ParentId)) {
                        acrToCreate.add(
                                HSRUtil.makeAccountContactRelation(siteAccount.Id, contactToProcess.Id)
                        );
                    }
                }
            }
        }

        if (!acrToCreate.isEmpty()) {
            numberAttempted += acrToCreate.size();

            List<Database.SaveResult> srs = Database.insert(acrToCreate, false);
            Integer inx = 0;
            for (Database.SaveResult sr : srs) {
                if (sr.isSuccess()) {
                    numSuccessful += 1;
                } else {
                    System.debug('HSRACRCreationBatch/execute Error While inserting ACR: ');
                    System.debug('Original record: ' + JSON.serializePretty(acrToCreate.get(inx)));
                    System.debug('Error details: ' + JSON.serializePretty(sr.getErrors()));

                    // Set the Contact ACR Processing Status to Error
                    Id contactId = acrToCreate.get(inx).ContactId;
                    Contact failedContact = contactsToProcess.get(contactId);
                    failedContact.Hospitality_ACR_Processing_Status__c = HSRConstants.CONTACT_ACR_STATUS_ERROR;

                    contactsToProcess.put(failedContact.Id, failedContact);
                }

                inx++;
            }
        }
    }

    public void finish(Database.BatchableContext ctx) {
        System.debug('HSRACRCreationBatch/finish ACR Batch Create Results:' +
                '\nNumber attempted: ' + numberAttempted +
                '\nNumber successful: ' + numSuccessful +
                '\nNumber failed: ' + (numberAttempted - numSuccessful)
        );

        updateContactsACRProcessingStatus();

        if (hasMorePendingRequests()) {
            System.debug('HSRACRCreationBatch/finish Found more pending requests, try to schedule another batch job');
            runBatch();
        }
    }


    public static Id runBatch() {
        return runBatch(DEFAULT_BATCH_SIZE);
    }

    /* --------------
     * Anonymous Apex
     * --------------
     */
    public static Id runBatch(Integer batchSize) {
        if (!HSRUtil.isBatchExecuting(HSRACRCreationBatch.class.getName())) {
            return Database.executeBatch(new HSRACRCreationBatch(), batchSize);
        }

        System.debug('HSRACRCreationBatch/runBatch The system could not schedule another job.');
        throw new HSRACRCreationBatchException(
                String.format(System.Label.HSR_ACR_Batch_Running_Exception, new List<String>{
                        HSRACRCreationBatch.class.getName()
                }));
    }

    /* --------------
     * Schedule Job
     * --------------
     */
    public void execute(SchedulableContext ctx) {
        runBatch();
    }


    /* --------------
     * Util Methods
     * --------------
     */

    private Boolean hasMorePendingRequests() {
        return HSRSelector.hasPendingACRProcessingRequests();
    }

    private void updateContactsACRProcessingStatus() {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact processedContact : contactsToProcess.values()) {
            if (processedContact.Hospitality_ACR_Processing_Status__c == HSRConstants.CONTACT_ACR_STATUS_ERROR) {
                contactsToUpdate.add(
                        new Contact(Id = processedContact.Id, Hospitality_ACR_Processing_Status__c = HSRConstants.CONTACT_ACR_STATUS_ERROR)
                );
            } else {
                contactsToUpdate.add(
                        new Contact(Id = processedContact.Id, Hospitality_ACR_Processing_Status__c = HSRConstants.CONTACT_ACR_STATUS_COMPLETE)
                );
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            List<Database.SaveResult> srs = Database.update(contactsToUpdate, false);
            Integer inx = 0;
            for (Database.SaveResult sr : srs) {
                if (!sr.isSuccess()) {
                    System.debug('HSRACRCreationBatch/updateContactsACRProcessingStatus Error While updating Contact record: ');
                    System.debug('Original record: ' + JSON.serializePretty(contactsToUpdate.get(inx)));
                    System.debug('Error details: ' + JSON.serializePretty(sr.getErrors()));
                }
                inx += 1;
            }
        }
    }

    private Map<String, Set<String>> getMCNAccountsIdsMap() {
        List<Id> contactIds = new List<Id>(contactsToProcess.keySet());
        List<AccountContactRelation> mcnACRs = HSRSelector.getMCNAccountContactRelations(contactIds);

        Map<String, Set<String>> mcnAccountIdsByContactIds = new Map<String, Set<String>>();
        for (AccountContactRelation mcnACR : mcnACRs) {
            if (mcnAccountIdsByContactIds.containsKey(mcnACR.ContactId)) {
                Set<String> mcnAccountIds = mcnAccountIdsByContactIds.get(mcnACR.ContactId);
                mcnAccountIds.add(mcnACR.AccountId);

                mcnAccountIdsByContactIds.put(mcnACR.ContactId, mcnAccountIds);
            } else {
                mcnAccountIdsByContactIds.put(mcnACR.ContactId, new Set<String>{
                        mcnACR.AccountId
                });
            }
        }
        return mcnAccountIdsByContactIds;
    }


    /* --------------
     * Inner Classes
     * --------------
     */
    public class HSRACRCreationBatchException extends Exception {
    }
}