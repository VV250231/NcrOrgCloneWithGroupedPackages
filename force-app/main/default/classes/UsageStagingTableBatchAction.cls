public with sharing class UsageStagingTableBatchAction {
    static String   BATCH_NAME = 'UsageStagingTableBatch',
                    STATUS_SUCESS = 'SUCCESS',
                    STATUS_ERROR = 'ERROR';
    
     /**
     * @description Invocable method to be executed from a screen flow
     *              The batch is limtied to batch sizes of 1 to handle logging for MCN/Start month groupings.
     * @return      Inner wrapper to hold batch response dataa
     */
    @InvocableMethod(   label='Usage Staging Table Batch'
                        description = 'Executes the batch UsageStagingTableBatchAction'
                        category = 'Usage')
    public static List<ExecuteBatchResponse> executeBatchAction(){
        ExecuteBatchResponse response = new ExecuteBatchResponse();
       
        UsageStagingTableBatch thisBatch = new UsageStagingTableBatch();
        try{
            Id batchId = Database.executeBatch( thisBatch, 1 );
            response.status = STATUS_SUCESS;
            response.batchId = batchId;
        }
        catch( exception ex){
            response.status = STATUS_ERROR;
            response.message = ex.getMessage();
        }
        return new List<ExecuteBatchResponse>{response};
    }

    public class ExecuteBatchResponse{
        @InvocableVariable ( label='Batch Id' description = 'Id of the batch')
        public Id batchId;
        @InvocableVariable ( label='Status' description = 'Status of the batch')
        public String status;
        @InvocableVariable ( label='Message' description = 'Response message')
        public String message;
    }
}