({
    getDealRegistration: function (component, event, helper) {
        var action = component.get("c.getDealRegistrationDetail"); 
       
        /*
        * Modified By: Ritesh on 22-11-2019
        * @desc : Stroy No 1325 : 
        *         getting Deal registation Id from url and assgined to DealRegistrationId.
        */
        if (component.get("v.recordId")) {
            component.set("v.DealRegistrationId", component.get("v.recordId"));
        }

        action.setParams({
            "recId": component.get("v.DealRegistrationId")
        });
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCCESS");
                console.log("json >>", response.getReturnValue().objDR);
                component.set("v.ObjDealRegistration", response.getReturnValue().objDR);
                // console.log("picklistValuesTAM",response.getReturnValue().getTAM);
                // component.set("v.picklistValuesTAM",response.getReturnValue().getTAM);
                // console.log(component.get("v.picklistValuesTAM"));
                component.set("v.accountDetail", response.getReturnValue().actDetail);
                component.set("v.isFinance", response.getReturnValue().isFIN);
                console.log('is record lock>>1 ' + response.getReturnValue().isRecordLock);
                component.set("v.isRecordLock", response.getReturnValue().isRecordLock);

                //Pop-UP Message.
                /*if(response.getReturnValue().objDR.Status__c =="Created"){
                    var infoToast = $A.get("e.force:showToast");
                    infoToast.setParams({
                        title : 'Message',
                        message: 'If you exit now this Deal Registration is only Saved. Please use the Submit For Approval button to complete the registration.',
                        messageTemplate: ' ',
                        duration:'10000',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    infoToast.fire();
                }*/
                var mode = component.get("v.mode", 'Edit');
                if (mode == 'Edit') {
                    component.set("v.isView", false);
                    //alert(component.get("v.ObjDealRegistration.Distributor_Channel_Account_Manager__c"));
                    if (component.get("v.ObjDealRegistration.Distributor_Channel_Account_Manager__c") != null)
                        component.set("v.isEditDistributor", true);
                    else
                        component.set("v.isEdit", true);
                }
                
                component.set("v.isDealRegistrationRecordLoad",false);
            } else if (state === "INCOMPLETE") {
                // do something
                
                component.set("v.isDealRegistrationRecordLoad",false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                } 
                component.set("v.isDealRegistrationRecordLoad",false);
            }
        });
        $A.enqueueAction(action);

    },

    openEdit: function (component, event, helper) {
        component.set("v.isView", false);
        //alert(component.get("v.ObjDealRegistration.Distributor_Channel_Account_Manager__c"));
        if (component.get("v.ObjDealRegistration.Distributor_Channel_Account_Manager__c") != null)
            component.set("v.isEditDistributor", true);
        else
            component.set("v.isEdit", true);

    },
    detailDealRequest: function (component, event, helper) {
        component.set("v.isView", true);
        component.set("v.isEdit", false);
        component.set("v.isEditDistributor", false);

        component.set("v.ObjDealRegistration", null);
        var exbRdId = event.getParam("mdfRecordId");
        component.set("v.DealRegistrationId", exbRdId);

        var action = component.get("c.getDealRegistrationDetail");

        action.setParams({
            "recId": component.get("v.DealRegistrationId")
        });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ObjDealRegistration", response.getReturnValue().objDR);
                component.set("v.isFinance", response.getReturnValue().isFIN);

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);


    },
    cancelRequest: function (component, event, helper) {
        if (event.getParam("IsDistributor") != undefined) {
            component.set("v.Distributor", event.getParam("IsDistributor"));
        }
        component.set("v.isView", true);
        component.set("v.isEdit", false);
        component.set("v.isEditDistributor", false);
    },
    redirectToListview: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
            "url": "/dr-list-view"
        }).fire();
    },


    showDealApprovalModal: function (component, event, helper) {
        //alert(component.get("v.ObjDealRegistration.Partner_Industry__c"));
        if (component.get("v.ObjDealRegistration.Partner_Industry__c") != undefined) {
            component.set("v.drApprovalComment", null);
            component.set("v.isDealApproval", true);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({

                "type": "error",
                "message": "Please select \"Partner Industry\" before submitting the request for approval."
            });
            toastEvent.fire();

        }
    },
    closeDocModal: function (component, event, helper) {
        component.set("v.isDealApproval", false);
    },
    submitDealRequest: function (cmp, event, helper) {

        var action = cmp.get("c.submitDRForApproval");
        action.setParams({
            "recId": cmp.get("v.DealRegistrationId"),
            "comment": cmp.get("v.drApprovalComment")
        });

        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            cmp.set("v.isDealApproval", false);

            if (state === "SUCCESS") {
                cmp.set("v.ObjDealRegistration", response.getReturnValue().objDR); 
                // code add by deeksharth on7Aug19 to disable edit once record submit for approval
                cmp.set("v.isRecordLock", response.getReturnValue().isRecordLock);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": 'Record has been submitted successfully.'
                });
                toastEvent.fire();

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") { 

                /*
                * @Code change By : Ritesh Kumar
                * @Story Number : NPC-1369 
                * @Date : 17-12-2019
                */
               let errorMessage ='';  
               for( let index in response.getError()){
                    errorMessage += response.getError()[index].message+'\n';
                } 
                var errorsToastEvent = $A.get("e.force:showToast");
                errorsToastEvent.setParams({ 
                    "title": "Error!",
                    "type": "error",
                    "message":  errorMessage
                });
                errorsToastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    nintyDaysExtension: function (component, event, helper) {
        console.log("Called : ninty Days Extension");
        console.log("Deal Registration Record : " + JSON.stringify(component.get("v.ObjDealRegistration")));
        component.set("v.extensionApprovalComment", null);
        component.set("v.ExtensionRequestModalFlag", true);
    },

    submitExtensionRequest: function (component, event, helper) {
        console.log("Called : submitExtensionRequest");
        var submitAction = component.get("c.approvalSubmitForExtension");
        submitAction.setParams({
            "dealRegistrationId": component.get("v.DealRegistrationId"),
            "extensionComments": component.get("v.extensionApprovalComment")
        });

        submitAction.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": 'Record has been submitted successfully.'
                });
                toastEvent.fire();
                component.set("v.ExtensionRequestModalFlag", false);
                var messageTxt = response.getReturnValue().approvalMessage;
                if (messageTxt.includes("submitted successfully")) {
                    var showbutton = component.find("extensionButton");
                    $A.util.addClass(showbutton, 'slds-hide');
                }

            } else if (response.getState() === "INCOMPLETE") {


            } else if (response.getState() === "ERROR") {

                 /*
                * @Code change By : Ritesh Kumar
                * @Story Number : NPC-1369 
                * @Date : 17-12-2019
                */
               let errorMessage ='';  
               for( let index in response.getError()){
                    errorMessage += response.getError()[index].message+'\n';
                } 
                var errorsToastEvent = $A.get("e.force:showToast");
                errorsToastEvent.setParams({ 
                    "title": "Error!",
                    "type": "error",
                    "message":  errorMessage
                });
                errorsToastEvent.fire();

            }
        });

        $A.enqueueAction(submitAction);

    },
    closeExtensionRequestModal: function (component, event, helper) {
        console.log("Called : closeExtensionRequestModal");
        component.set("v.ExtensionRequestModalFlag", false);
    }
})