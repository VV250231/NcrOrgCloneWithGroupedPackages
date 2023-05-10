({
	getRolesFromSalesforce : function(component,masterSet,role) {
       var action = component.get('c.fetchRolesWithMCN');
       action.setParams({
            "masterNumbers" : JSON.stringify(masterSet),
            "roleName" :role
        });
        action.setCallback(this,function(response){
            component.set("v.rolesInDatabase",response.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    reassignRole: function(component,rolesToDelete,rolesforInsert) {
        component.set("v.spinner",true);
        var action = component.get('c.editRecordBulkData');
        console.log(JSON.stringify(rolesToDelete));
  		console.log(JSON.stringify(rolesforInsert));      
        action.setParams({
            "rolestoDel" : rolesToDelete,
            "rolesToAdd" :rolesforInsert
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                //alert(state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record was Saved Successfully.",
                    "type": "Success"
                }); 
                toastEvent.fire();
                //component.set("v.currentPage",component.get("v.currentPage"));
                //component.set("v.currentTab",component.get("v.currentTab"));
                //var arrDir = component.get("v.arrowDirection")=='arrowup'? 'arrowdown' : 'arrowup';
                //alert(arrDir);
                //component.set("v.arrowDirection",arrDir);
                //var isasc =  component.get("v.isAsc")== true? false : true;
                //component.set("v.isAsc",false);
                
               	var p = component.get("v.parent");
    			p.callParentdoInit();
                component.set("v.isbulkUpdate",false);
                component.set("v.showModal",false);
                component.set("v.isNew",false);
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action);
    }
})