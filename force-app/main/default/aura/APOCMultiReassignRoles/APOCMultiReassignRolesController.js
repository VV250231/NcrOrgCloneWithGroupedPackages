({
	closeModal : function(component, event, helper) {
		//alert();
        component.set("v.isbulkUpdate",false);
        component.set("v.showModal",false);
        component.set("v.isNew",false);
	},
    clickNext:function(component,event,helper){
        component.set("v.showUserLookup",true);
        var master = component.get("v.recordToReassign");
        //alert(JSON.stringify(master));
        var selRole = component.get("v.selectedRole");
        //alert(selRole);
		helper.getRolesFromSalesforce(component,master,selRole);        
    },
    clickSave:function(component,event,helper){
        var master = component.get("v.recordToReassign");
        var records = component.get("v.rolesInDatabase");
        var role = component.get("v.selectedRole");
        var qlid;
        if(component.get("v.selectedUser")){
       		qlid = component.get("v.selectedUser").ObjRecord.Quicklook_ID__c;
       	}
        //alert(qlid);
        if(role=='PO/Billing Person' && qlid==undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "message": "PO/Billing Person is required.Please assign a user.",
                "type": "ERROR"
            }); 
            toastEvent.fire();   
        }else{
            var rolesToDelete =[];
            var rolesforInsert = [];
            var msg ='Are you sure you want to reassign all the selected accounts?';
            if (!confirm(msg)) {
                
                console.log('No');
                return false;
            } else {
                for(var i in master){
                    var roletoadd= {'Master__c':'','QuickLook_ID__c':'','Role_Name__c':''};
                    var extId = role+master[i]+qlid;
                    //alert(extId);
                    for(var j in records){
                        if(records[j].Master__c==master[i]){
                            if(records[j].External_Id__c != extId){
                                rolesToDelete.push(records[j]);
                            }
                        }
                    }
                    //alert(master[i]);
                    roletoadd.Master__c = master[i];
                    roletoadd.QuickLook_ID__c = qlid;
                    roletoadd.Role_Name__c = role;
                    rolesforInsert.push(roletoadd);
                }
                helper.reassignRole(component,rolesToDelete,rolesforInsert);
            }
        }
        
    }
})