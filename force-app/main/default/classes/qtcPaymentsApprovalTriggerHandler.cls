public with sharing class qtcPaymentsApprovalTriggerHandler {

    private static string   APPROVAL_ACTION_SUBMIT = 'Submit',
                            APPROVAL_ACTION_RECALLED = 'Recall';
    private List<qtc_PaymentsApproval__c> listPaymentsApproval;
    private Map<Id, qtc_PaymentsApproval__c> mapOldPaymentsApproval;

    public qtcPaymentsApprovalTriggerHandler(List<qtc_PaymentsApproval__c> triggerNew, Map<Id, qtc_PaymentsApproval__c> triggerOldmap) {
        this.listPaymentsApproval = triggerNew;
        this.mapOldPaymentsApproval = triggerOldMap;
    }

    public void handleAfterUpdate(){
        List<qtc_PaymentsApproval__c> listPaymentApprovalToUpdate = new List<qtc_PaymentsApproval__c>();
        for(qtc_PaymentsApproval__c thisPaymentApproval : listPaymentsApproval){
            qtc_PaymentsApproval__c oldPaymentApproval = mapOldPaymentsApproval.get( thisPaymentApproval.Id );

            if( thisPaymentApproval.qtc_ApprovalAction__c != oldPaymentApproval.qtc_ApprovalAction__c ){

                if( thisPaymentApproval.qtc_ApprovalAction__c == APPROVAL_ACTION_SUBMIT ){
                    qtc_PaymentsApproval__c submittedPaymentApproval = submitPaymentAproval( thisPaymentApproval );
                    listPaymentApprovalToUpdate.add( submittedPaymentApproval );
                }
                else if( thisPaymentApproval.qtc_ApprovalAction__c == APPROVAL_ACTION_RECALLED ){
                    qtc_PaymentsApproval__c recalledPaymentApproval = recallPaymentApproval( thisPaymentApproval );
                    listPaymentApprovalToUpdate.add( recalledPaymentApproval );
                }

            }
        }

        if( !listPaymentApprovalToUpdate.isEmpty()){
            try{
                update listPaymentApprovalToUpdate;
            }
            catch(DmlException ex){
                System.debug(ex.getMessage());
            }
        }
    }

    private qtc_PaymentsApproval__c nullApprovalAction(qtc_PaymentsApproval__c paymentApprovalRecord ){
        qtc_PaymentsApproval__c paymentApprovalToUpdate = new qtc_PaymentsApproval__c(
            id = paymentApprovalRecord.Id,
            qtc_ApprovalAction__c = null
        );
        return paymentApprovalToUpdate;
    }

    private qtc_PaymentsApproval__c submitPaymentAproval(qtc_PaymentsApproval__c paymentApprovalRecord){
        try{
            SBAA.ApprovalAPI.submit(paymentApprovalRecord.Id, SBAA__Approval__c.qtc_PaymentsApproval__c);
            return nullApprovalAction(paymentApprovalRecord);
            
        }
        catch( Exception e){
            System.debug( e.getMessage());
            return null;
        }
    }

    private qtc_PaymentsApproval__c recallPaymentApproval(qtc_PaymentsApproval__c paymentApprovalRecord){
        try{
            SBAA.ApprovalAPI.recall(paymentApprovalRecord.Id, SBAA__Approval__c.qtc_PaymentsApproval__c);
            return nullApprovalAction(paymentApprovalRecord);
        }
        catch( Exception ex){
            System.debug( ex.getMessage());
            return null;
        }
    }
}