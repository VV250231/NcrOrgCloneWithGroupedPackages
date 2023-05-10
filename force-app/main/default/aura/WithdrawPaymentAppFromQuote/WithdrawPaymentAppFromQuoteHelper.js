({ 
    validatePaymentAppWithdrawal : function(component) {
        var action = component.get("c.validatePaymentAppWithdrawal");
        action.setParams({"quoteID":component.get("v.recordId")});
        component.set("v.showSpinner",true);
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            var state = response.getState();
            var msg = '';
            const applStatus = new Set(['Approved', 'ApprovedAndBoarded', 'Declined', 'Withdrawn', 'AcquirerReview']);
            if (state === "SUCCESS") {
                var paymentSites = response.getReturnValue();
                //alert('validatePaymentAppWithdrawal > ' + paymentSites.length + ', ' + paymentSites[0].Quote__r.qtc_Multi_Site__c + ', ' + paymentSites[0].NCR_Payments_Application_Status__c);
                if(paymentSites == null || paymentSites.length == 0){
                    this.showMessage(component, true, 'There is no payment site to withdraw.');
                }else if(paymentSites.length == 1 && paymentSites[0].Quote__r.qtc_Multi_Site__c === false && 
                           applStatus.has(paymentSites[0].NCR_Payments_Application_Status__c)){
                    this.showMessage(component, true, 'You can not send Payment Withdrawal Request of status : '+ paymentSites[0].NCR_Payments_Application_Status__c);
                } else{
                    this.showMessage(component, false,''); 
                    }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    withdrawPaymentApplication : function(component) {
		var action = component.get("c.notifyToWithdrawApplication");
        component.set("v.showSpinner",true);
        component.set("v.inputWithdrawlComment",false);
        action.setParams({
            "quoteID":component.get("v.recordId"),
            "withdrawalComments":component.find("withdrawalNotes").get("v.value")
          });
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            var state = response.getState();
            var msg = '';
            if (state === "SUCCESS") {
               // alert('response.getReturnValue() > ' + response.getReturnValue());
                var jsonRes = JSON.parse(response.getReturnValue());
                //alert('jsonRes > ' + jsonRes.siteResultLst);
                if(!jsonRes.exceptionFlag){
                    var listofQtObj = [];
                    for(var obj of jsonRes.siteResultLst){
                            var sobj = {
                                siteNumber:obj.siteNumber,
                                siteName:obj.siteName,
                                status:obj.status,
                                statusMsg:obj.statusMessage
                            }
                            listofQtObj.push(sobj);
                        }
                        component.set('v.MultiSiteResponseColumns', [
                            {label: 'Site Number', fieldName: 'siteNumber', type: 'text'},
                            {label: 'Site Name', fieldName: 'siteName', type: 'text'},
                            {label: 'Status', fieldName: 'status', type: 'text'},
                            {label: 'Status Message', fieldName: 'statusMsg', type: 'text'}
                        ]); 
                        component.set('v.MultiSiteResponse',listofQtObj);
                        //alert('listofQtObj > ' + listofQtObj);
                    }else{
                        msg='Issue in payment withdrawal : ' + jsonRes.exceptionMessage;
                    component.set("v.msg",msg);
                    }
                } else if (state === "ERROR") {
                    msg='withdrawPaymentApplication Error ';
                    component.set("v.msg",msg);
                   //alert("withdrawPaymentApplication Error > ");
                    
                }
            });
        $A.enqueueAction(action);
     }, 
    showMessage : function(component, errorMsg, message) {
        component.set("v.inputWithdrawlComment",true);
        if(errorMsg){
            component.set("v.showCommentBox",false);
        	component.set("v.showErrorMessage",true);
            component.set("v.msg",message);
        }else{
            component.set("v.showCommentBox",true);
        	component.set("v.showErrorMessage",false);
        }
     }
    
})