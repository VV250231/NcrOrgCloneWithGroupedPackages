/**
 * @author ATG
 * @description Invocable apex class to initiate batch from a screen flow
*/
public with sharing class qtcOrderActivationBatchAction {
    static String   BATCH_NAME = 'qtcOrderActivationBatchAction',
                    STATUS_SUCESS = 'SUCCESS',
                    STATUS_ERROR = 'ERROR';
    /**
     * @description invocable method To invoke the Batch Id
     * @param   listRequest     Screen flow input parameters to control the batch size
     * @return  Response data to state if the Batch was successfully executed 
     */
    @InvocableMethod(   label='Order Activation Batch'
                        description = 'Executes the batch qtcOrderActivationBatchAction. The process will create, Activate, and contract an Order'
                        category = 'Fulfillment Orders')
    public static List<ExecuteBatchResponse> executeBatchAction(List<ExecutebatchRequest> listRequest){
        ExecuteBatchResponse response = new ExecuteBatchResponse();
        Integer batchSize = listRequest[0]?.batchSize == null ? 50 : listRequest[0]?.batchSize ;
        qtcOrderActivationBatch thisBatch = new qtcOrderActivationBatch();
        try{
            String batchId = Database.executeBatch( thisBatch, batchSize );
            response.status = STATUS_SUCESS;
            response.batchId = batchId;
        }
        catch( exception ex){
            response.status = STATUS_ERROR;
            response.message = ex.getMessage();
        }
        return new List<ExecuteBatchResponse>{response};
    }
    
    /**
     * @description Inner class object to hold request parameters
     */
    public class ExecutebatchRequest {
        @InvocableVariable ( label= 'Batch Size' description = 'Size to specify size of batch scope')
        public Integer batchSize;
    }

    /**
     * @description Inner class object to hold response parameters
     */
    public class ExecuteBatchResponse{
        @InvocableVariable ( label='Batch Id' description = 'Id of the batch')
        public String batchId;
        @InvocableVariable ( label='Status' description = 'Status of the batch')
        public String status;
        @InvocableVariable ( label='Message' description = 'Response message')
        public String message;
    }
}