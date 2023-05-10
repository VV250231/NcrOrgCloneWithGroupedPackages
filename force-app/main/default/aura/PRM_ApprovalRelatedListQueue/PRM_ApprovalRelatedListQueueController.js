({
    doInit : function(component, event, helper) {
        var action = component.get("c.getApprovalHistory");
        action.setParams({"targetObjId" : component.get("v.recordId")});
        component.set("v.timeZone",$A.get("$Locale.timezone")); 
        action.setCallback(this, function(a) {
            component.set("v.processInstaces",a.getReturnValue());
            console.log("==== Approval Realted List doInit A === : ",a.getReturnValue());
            
        });
        $A.enqueueAction(action); 
        var action1 = component.get("c.CheckModiffyAllPermission");
        action1.setCallback(this, function(a) {
            component.set("v.ReAssignModifyAll",a.getReturnValue());
            console.log("==== Approval Realted List doInit B === : ",component.get("v.ReAssignModifyAll"));
            
        });
        $A.enqueueAction(action1); 
    },
    
    closeDocModal: function(component, event, helper) {        
        component.set("v.isRejection", false);
        component.set("v.isApproved", false);
        component.set("v.isReassign", false);
    },
    openReassignModal: function(component, event, helper) {
        var workItem = event.target.id;
        component.set("v.processInstanceWorkitemId",workItem);
        component.set("v.isReassign", true);
    },
    
    openRejectionModal: function(component, event, helper) {
        var workItem = event.target.id;
        component.set("v.processInstanceWorkitemId",workItem);
        component.set("v.isRejection", true);
        var opts = [];
        
        
    },
    
    openApprovalModal: function(component, event, helper) {
        var workItem = event.target.id;
        component.set("v.processInstanceWorkitemId",workItem);
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
            if(result == 'Approved'){
                component.set("v.isApproved", false);
                //$A.get('e.force:refreshView').fire();
                window.location.href = window.location.href;
            }
            
        });
        $A.enqueueAction(action);
    },
    
    doReassignRecord : function(component, event, helper) {
        var comment = component.get("v.strComment");
        var action = component.get("c.requestReassign");
        
        action.setParams({"comment":comment,"workItemId":component.get("v.processInstanceWorkitemId"),"targetObjId" : component.get("v.recordId")});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result == 'Reassigned')
            {
                component.set("v.isReassign", false);
                //$A.get('e.force:refreshView').fire();
                window.location.href = window.location.href;
            }
            
        });
        $A.enqueueAction(action);
    },
    doReassigntoUser :function(component, event, helper){ 
        var Userid = component.get("v.userObj").ObjRecord.Id ; 
        var comment = component.get("v.strComment");
        var action = component.get("c.requestReassignToUser"); 
        action.setParams({"comment":comment,"workItemId":component.get("v.processInstanceWorkitemId"),"targetObjId" : component.get("v.recordId"),"UserID": Userid  });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue(); 
            if(result == 'Reassigned')
            {
                component.set("v.isReassign", false);
                component.set("v.ReAssignModifyAll", false); 
                window.location.href = window.location.href;
            }
        });
        $A.enqueueAction(action);
    }
})