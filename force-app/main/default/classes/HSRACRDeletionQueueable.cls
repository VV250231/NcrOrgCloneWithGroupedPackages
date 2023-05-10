/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* A queueable job that handles deleting out-of-date Account-Contact-relations records.
* This class will be queued from JIT User provisioning handler on each user create or
* update when needed.
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

public inherited sharing class HSRACRDeletionQueueable implements Queueable {

    private Id contactId { get; set; }
    private List<Id> parentAccountIds { get; set; }

    private HSRACRDeletionQueueable(Id contactId, List<Id> parentAccountIds) {
        this.contactId = contactId;
        this.parentAccountIds = parentAccountIds;
    }

    public void execute(QueueableContext ctx) {
        Integer recordsLimit = HSRUtil.getMaxNumberOfDMLRows();
        List<AccountContactRelation> pendingACRs = HSRSelector.getPendingACRToDelete(contactId, parentAccountIds, recordsLimit);

        if (!pendingACRs.isEmpty()) {
            List<Database.DeleteResult> drs = Database.delete(pendingACRs, false);
            Integer inx = 0;
            for (Database.DeleteResult dr : drs) {
                if (!dr.isSuccess()) {
                    System.debug('HSRACRDeletionQueueable/execute Error While deleting AccountContactRelation record record: ');
                    System.debug('Original record: ' + JSON.serializePretty(pendingACRs.get(inx)));
                    System.debug('Error details: ' + JSON.serializePretty(dr.getErrors()));
                }
                inx += 1;
            }

            if (hasMoreACRsToDelete()) {
                HSRACRDeletionQueueable.enqueue(contactId, parentAccountIds);
            }
        }
    }

    /* --------------
     * Enqueue Job
     * --------------
     */
    public static void enqueue(Id contactId, List<Id> parentAccountIds) {
        if (HSRUtil.canEnqueue()) {
            Id jobId = System.enqueueJob(new HSRACRDeletionQueueable(contactId, parentAccountIds));
        } else {
            System.debug('HSRACRDeletionQueueable/enqueue The system could not enqueue another job (system limit).');
            throw new HSRACRDeletionException(String.format(System.Label.HSR_ACR_Queueable_Limit_Exception, new List<String>{
                    HSRACRDeletionQueueable.class.getName()
            }));
        }
    }

    /* --------------
     * Util Methods
     * --------------
     */

    private Boolean hasMoreACRsToDelete() {
        return Test.isRunningTest() ? false : !HSRSelector.getPendingACRToDelete(contactId, parentAccountIds, 1).isEmpty();
    }

    /* --------------
     * Inner Classes
     * --------------
     */
    public class HSRACRDeletionException extends Exception {
    }
}