import { LightningElement,api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getEmailRecipientRecord from  '@salesforce/apex/ReportScheduleController.getEmailRecipientRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';



export default class SendInstantEmail extends LightningElement {
    @api recordId;
    isLoading = false;

    // to close the model window 
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

  // Handle Yes button change
    handleOk() {
        this.isLoading = true;
        getEmailRecipientRecord({ scheduleExternalReportId: this.recordId })
            .then(result => {
                for (let key in result) {
                    // Updating email recipient records
                    this.updateEmailRecipient(key, result[key]);
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('getEmailRecipientRecord Error==' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                )
            })


    }
 
    // Method to update email recipient records
    updateEmailRecipient(recordId, emailFlag) {

        var fields = {
            'updatedByBatch__c': emailFlag == true ? false : true,
            'Id': recordId
        };

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.isLoading = false;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email sent successfully',
                        variant: 'success',
                    })
                )

            })
            .catch(error => {
                this.isLoading = false;
                console.log('updateRecord error==' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

}