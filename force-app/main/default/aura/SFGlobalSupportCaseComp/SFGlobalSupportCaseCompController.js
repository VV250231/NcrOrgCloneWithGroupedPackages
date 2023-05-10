({
	init : function(component, event, helper) {
		var flow = component.find("flowData");
        var inputVariables = [{name : "objectName", type : "String", value: component.get("v.sObjectName")}];
		//flow.startFlow("Test_Flow1", inputVariables);
        flow.startFlow("New_SF_Support_Case", inputVariables);
	},
    
    handleStatusChange : function(component, event, helper) {
		if(event.getParam("status") == "FINISHED") {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();  
        }             
	}
})