import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountDisputeCases from '@salesforce/apex/DisputeCaseController.getAccountDisputeCases';
export default class DisputeCase extends NavigationMixin(LightningElement) {
    @api recordId;
    @api orderBy;
    @api order;
    @wire(getAccountDisputeCases,{ recId: '$recordId', orderBy: '$orderBy',order: '$order' }) disputeCases;

    handleCaseView(event) {
        // Navigate to contact record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                actionName: 'view'
            }
        });
    }

    sort(event) {
        if (this.orderBy === event.currentTarget.dataset.id) {
            this.order = this.order === 'DESC' ? 'ASC' : 'DESC';
        } else {
            this.order = 'ASC';
            this.orderBy = event.currentTarget.dataset.id;
        }
    }
}