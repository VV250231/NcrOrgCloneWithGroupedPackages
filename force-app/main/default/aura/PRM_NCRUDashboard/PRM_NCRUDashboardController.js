({
	 doInit: function(component, event, helper) {
       	var action = component.get("c.getNCRUDetails");
       	action.setParams({
          	"recId":component.get("v.recordId")
            //"recId" : "001c0000018mwxn"
       	});
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.etNCRUDetails", response.getReturnValue());
                var recordList = response.getReturnValue();
                //alert(recordList.length);
                //alert(recordList[0].isAccess);
                if(recordList.length > 0)
                {
                    //alert(recordList.length);
                	component.set("v.isAccessDashboard", recordList[0].isAccess);
                    //alert(component.get("v.isAccessDashboard"));
                }
                console.log( response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    openModel : function(component, event, helper) {
       	var idx = event.currentTarget;
       	var idd = idx.dataset.ids; 
        
       	var action = component.get("c.getCertificationDetails");
        action.setParams({
            "keyVal" : idd,
            "accId" : component.get("v.recordId")
        });
        
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.etCertifications", response.getReturnValue());
                component.set("v.isModal", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeDocModal: function(component, event, helper) {
    	 component.set("v.isModal", false);
	}
    
})