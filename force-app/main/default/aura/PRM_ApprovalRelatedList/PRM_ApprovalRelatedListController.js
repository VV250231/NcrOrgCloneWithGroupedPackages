({
    doInit : function(component, event, helper) {
        var action = component.get("c.getApprovalHistory");
        action.setParams({"targetObjId" : component.get("v.recordId")});
        action.setCallback(this, function(a) {
            component.set("v.processInstaces",a.getReturnValue());
            component.set("v.processInstanceWorkitemId",a.getReturnValue()[0].workItemId);
            component.set("v.displayBtn",a.getReturnValue()[0].showApproveBtn);
            console.log(a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    closeDocModal: function(component, event, helper) {        
        component.set("v.isRejection", false);
        component.set("v.isApproved", false);
    },
    
    openRejectionModal: function(component, event, helper) {
        
        component.set("v.isRejection", true);
        var opts = [];
        //var reasons = component.get("v.rejectionReasons");
        //for (var i = 0; i < reasons.length; i++) {
        
        //}
        //component.find("SelectRejectionReasons").set("v.options", opts);
        
    },
    
    openApprovalModal: function(component, event, helper) { //alert(1);
        component.set("v.isApproved", true);
    },
    
    doRejectRecord: function(component, event, helper) {
        console.log(component.get("v.selectedReason"));
        var rejectionReason;
        if (component.get("v.selectedReason") == "Other") {
            rejectionReason = component.get("v.strComment");
            if (rejectionReason == "") {
                alert('Please enter reason of rejection.');
                return;
            }
        } else {
            rejectionReason = component.get("v.selectedReason");
            if (rejectionReason == "") {
                alert('Please select reason of rejection.');
                return;
            }
        }
        var action = component.get("c.processRequest");
        action.setParams({'comment':rejectionReason,'workItemId':component.get("v.processInstanceWorkitemId"),'operation':'Reject'});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log('-----------'+result);
             //window.location.href = window.location.href;
            if(result == 'Rejected')
            {
                component.set("v.isRejection", false);
                //$A.get('e.force:refreshView').fire();
                window.location.href = window.location.href;
            }
            
        });
        $A.enqueueAction(action);
    },
    
    doApproveRecord: function(component, event, helper) {
        console.log(component.get("v.selectedReason"));
        var comment = component.get("v.strComment");
        var action = component.get("c.processRequest");
        action.setParams({'comment':comment,'workItemId':component.get("v.processInstanceWorkitemId"),'operation':'Approve'});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result == 'Approved')
            {
                component.set("v.isApproved", false);
                //$A.get('e.force:refreshView').fire();
                window.location.href = window.location.href;
            }
            
        });
        $A.enqueueAction(action);
    }
})