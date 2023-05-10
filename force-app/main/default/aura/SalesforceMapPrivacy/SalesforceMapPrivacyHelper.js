({
    saveUser : function(component, event, helper) {
        if(component.get('v.isDisAgreeButtonPressed')){
            component.set("v.UserRecord.NCR_Maps_Privacy_Notice_Declined__c", true); 
        }
        else
        {
            component.set("v.UserRecord.NCR_Maps_Privacy_Notice_Acknowledged__c", true); 
        }
        component.find("UserRec").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // alert("Thank you so much for your response.");
                if(component.get('v.isAgreeButtonPressed')){    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: 'Thank you so much for your response.',
                        duration:' 5000',
                        key: 'info_alt', 
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                if(component.get('v.isDisAgreeButtonPressed')){
                    var actions = component.get("c.removeSalesforceMapPermission");
                    actions.setParams({ currentUserId : component.get("v.currentUserId") });
                    actions.setCallback(this, function(response) {
                        var state = response.getState();
                        var responeValues=response.getReturnValue();
                        if (state === "SUCCESS") {
                            if(responeValues==true){ 
                                // console.log('Permission set deleted successfully !!');
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Success Message',
                                    message: 'Access to Maps has been declined. Please reach out to your System Administrator for assistance.',
                                    duration:' 5000',
                                    key: 'info_alt', 
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                            }
                            else{
                                console.log('Permission set deletion failed !!'); 
                            }
                        }
                    });
                    $A.enqueueAction(actions);  
                }
                
            } else if (saveResult.state === "INCOMPLETE") {
                component.set("v.recordSaveError","User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") { 
                var errMsg = "";
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                component.set("v.recordSaveError", errMsg);
                
            } else {
                component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + 
                              JSON.stringify(saveResult.error));
            }
        }));
        
        $A.get("e.force:closeQuickAction").fire();  
    }
    
})