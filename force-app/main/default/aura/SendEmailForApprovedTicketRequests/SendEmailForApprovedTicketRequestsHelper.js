({
    sendEmailHelper: function(component, arr2, getSubject, getbody) {
        var senderEmail = component.get("v.loggedInUserEmail");
        var action = component.get("c.sendMailMethod");
        action.setParams({
            'mMail': arr2,
            'mSubject': getSubject,
            'mbody': getbody,
            'replyTo': senderEmail
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Email Sent!",
                    "message": "Email has been sent successfully to: " + 
                    (component.get("v.customerName")+  ' - '  + component.get("v.ContactsEmail")),
                    "type": "Success",
                    "mode": "sticky"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Error message: "+ errors[0].message,
                                "type": "Error"
                            });
                            toastEvent.fire();
                        }
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    getApprovalStatus : function(component, event, rcrd){
        var action = component.get("c.getApprovalStats");
        action.setParams({ RdId : rcrd });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ContactsEmail",response.getReturnValue()[0].Contact_Name__r.Email );
                component.set("v.EventName",response.getReturnValue()[0].Name);
                component.set("v.customerName", response.getReturnValue()[0].Contact_Name__r.Name);
                component.set("v.Status", response.getReturnValue()[0].Approval_Status__c);
                component.set("v.subject", 'You are Invited for an Event -- ' + component.get("v.EventName"));
                
                component.set("v.body", "Hi " + component.get("v.customerName")+ ",<br/><br/>" + 
                              "We are excited to have you at the Atlanta " + component.get("v.EventName") + ". Tickets and parking passes will be distributed the week of the game.<br/>" + "If you have any questions please let me know.<br/><br/>" + 
                              "Thanks,<br/>" + component.get("v.senderName"));
                
                if(response.getReturnValue()[0].Approval_Status__c != 'Approved'){
                    component.set("v.errorMsg", true);
                    component.set("v.emailModal", false);
                }else {
                    component.set("v.emailModal", true);
                    component.set("v.errorMsg", false);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Error message: "+ errors[0].message,
                                "type": "Error"
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    getLoggedInUserDetail:function(component, event, helper){
        var action = component.get("c.getUserEmail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loggedInUserEmail",response.getReturnValue()[0].Email);
                component.set("v.senderName", response.getReturnValue()[0].Name);
                
                component.set("v.body", "Hi " + component.get("v.customerName")+ ",<br/><br/>" + 
                              "We are excited to have you at the Atlanta " + component.get("v.EventName") + ". Tickets and parking passes will be distributed the week of the game.<br/>" + "If you have any questions please let me know.<br/><br/>" + 
                              "Thanks,<br/>" + component.get("v.senderName"));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Error message: "+ errors[0].message,
                                "type": "Error"
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})